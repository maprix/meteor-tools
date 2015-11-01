ConsolePanel = require './console-panel'
ProjectInput = require './project-input'
{CompositeDisposable} = require 'atom'
ChildProcess = require 'child_process'

module.exports =
MeteorTools =
  console: null
  consolePanel: null
  inputPanel: null
  projectInput: null
  subscriptions: null
  projectName: null
  projectPath: null
  meteorProcess: null
  activeProjectPath: null

  stdoutCallback: (data) ->
    @console.log(data)

  stderrCallback: (data) ->
    @console.error(data)

  createProjectExitCallback: (data) ->
    @console.activityOff()
    if data == 0
      # open new project
      path = @projectPath + '\\' + @projectName
      atom.project.addPath(path)
      atom.workspace.open(path + '\\' + @projectName + '.js')
    else
      alert('Error during creating project')

  meteorExitCallback: (data) ->
    @console.activityOff()
    @meteorProcess = null
    @activeProjectPath = null
    @console.log("Meteor was stopped\n&nbsp")
    @console.activityOff()

  keyUpCallback: (event) ->
    code = event.keyCode
    if code == 27
      @inputPanel.hide()
    else if code == 13
      @inputPanel.hide()

      @projectName = @projectInput.getText()
      @projectPath = atom.config.get("meteor-tools.meteorProjectHome")

      @consolePanel.show()
      @console.activityOn()
      @console.log("=== Creating Meteor project " + @projectName + " in " + @projectPath + "... ===")
      child = ChildProcess.exec('meteor create '+@projectName, cwd: @projectPath)
      # bind callback for output from the child process
      child.stdout.on 'data', (data) => @stdoutCallback(data)
      child.stderr.on 'data', (data) => @stderrCallback(data)
      child.on 'exit', (data) => @createProjectExitCallback(data)

  getProjectPathForActiveBuffer: () ->
    editor = atom.workspace.getActivePaneItem()
    editorPath = editor?.buffer.getPath()
    projectPaths = atom.project.getPaths()
    result = projectPath for projectPath in projectPaths when editorPath?.startsWith(projectPath)
    return result

  activate: (state) ->
    @console = new ConsolePanel()
    @console.activityOff()
    @consolePanel = atom.workspace.addBottomPanel(item: @console, visible: false)
    @console.setPanel(@consolePanel)
    @projectInput = new ProjectInput()
    @projectInput.projectNameEditor.on 'keyup', (event) => @keyUpCallback(event)
    @inputPanel = atom.workspace.addModalPanel(item: @projectInput, visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable
    # Register commands that toggles this package
    @subscriptions.add atom.commands.add 'atom-workspace',
      'meteor-tools:toggleConsole': => @toggleConsole()
      'meteor-tools:createNewProject': => @createNewProject()
      'meteor-tools:startMeteor': => @startMeteor()
      'meteor-tools:stopMeteor': => @stopMeteor()

  deactivate: ->
    @consolePanel.destroy()
    @inputPanel.destroy()
    @projectInput.destroy()
    @subscriptions.dispose()

  serialize: ->
    meteorToolsViewState: @consolePanel.serialize()

  config:
    'meteorProjectHome':
      title: 'Meteor Path'
      type: 'string'
      description: 'Home directory where your meteor projects are located.'
      default: process.env.USERPROFILE
      order: 1

  toggleConsole: ->
      if @consolePanel.isVisible()
        @consolePanel.hide()
      else
        @consolePanel.show()

  createNewProject: ->
    @projectInput.setText('new-project')
    @inputPanel.show()
    @projectInput.projectNameEditor.focus()
    @projectInput.projectNameEditor.getModel().selectAll()

  checkMeteorOutput: (data) ->
    if data.match /App running/
      @console.log("Meteor is running\n&nbsp")
      @console.activityOff()

  startMeteor: ->
    # get project path for active editor
    @activeProjectPath = @getProjectPathForActiveBuffer()

    @consolePanel.show()
    @console.activityOn()
    @console.log("=== Starting Meteor process in " + @activeProjectPath + "... ===")

    if @activeProjectPath == null
      alert("No active project found.")
    else
      @meteorProcess = ChildProcess.exec('meteor', cwd: @activeProjectPath)
      @console.log("pid: "+@meteorProcess.pid)
      # @meteorProcess = ChildProcess.spawn(, cwd: @activeProjectPath)
      # bind callback for output from the child process
      @meteorProcess.stdout.on 'data', (data) =>
        @stdoutCallback(data)
        @checkMeteorOutput(data)
      @meteorProcess.stderr.on 'data', (data) => @stderrCallback(data)
      @meteorProcess.on 'exit', (data) => @meteorExitCallback(data)

  stopMeteor: ->
    # get project path for active editor
    if  @meteorProcess == null
      alert('No know Meteor process.')
    else
      @consolePanel.show()
      @console.activityOn()
      @console.log("=== Stopping Meteor process... ===")
      ChildProcess.spawn("taskkill", ["/pid", @meteorProcess.pid, '/f', '/t']);
      #@meteorProcess.kill('SIGKILL')
