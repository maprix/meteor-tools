ProjectInput = require './project-input'
{CompositeDisposable} = require 'atom'
ChildProcess = require 'child_process'

module.exports =
MeteorTools =
  inputPanel: null
  subscriptions: null
  projectName: null
  projectPath: null

  cpExecStdoutCallback: (data) ->
   console.log(data)

  cpExecStderrCallback: (data) ->
   console.error(data)

  cpExecExitCallback: (data) ->
    if data == 0
      # open new project
      path = @projectPath + '\\' + @projectName
      atom.project.addPath(path)
      atom.workspace.open(path + '\\' + @projectName + '.js')
    else
      alert('Error during creating project')

  keyUpCallback: (event) ->
    code = event.keyCode
    if code == 27
      @inputPanel.hide()
      console.log('Canceled')
    else if code == 13
      @inputPanel.hide()
      @projectName = @projectInput.getText()
      @projectPath = atom.config.get("meteor-tools.meteorPath")

      child = ChildProcess.exec('meteor create '+@projectName, cwd: @projectPath)
      # bind callback for output from the child process
      child.stdout.on 'data', (data) => @cpExecStdoutCallback(data)
      child.stderr.on 'data', (data) => @cpExecStderrCallback(data)
      child.on 'exit', (data) => @cpExecExitCallback(data)

  getProjectPathForActiveBuffer: () ->
    editor = atom.workspace.getActivePaneItem()
    editorPath = editor?.buffer.getPath()
    projectPaths = atom.project.getPaths()
    result = projectPath for projectPath in projectPaths when editorPath?.startsWith(projectPath)
    return result

  activate: (state) ->
    @projectInput = new ProjectInput()
    @projectInput.projectNameEditor.on 'keyup', (event) => @keyUpCallback(event)
    @inputPanel = atom.workspace.addModalPanel(item: @projectInput, visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace',
      'meteor-tools:createNewProject': => @createNewProject()

  deactivate: ->
    @inputPanel.destroy()
    @subscriptions.dispose()
    @projectInput.destroy()

  serialize: ->
    meteorToolsViewState: @inputPanel.serialize()

  config:
    'meteorPath':
      title: 'Meteor Path'
      type: 'string'
      description: 'Path where the meteor projects resist.'
      default: process.env.USERPROFILE
      order: 1

  createNewProject: ->
    @projectInput.setText('new-project')
    @inputPanel.show()
    @projectInput.projectNameEditor.focus()
    @projectInput.projectNameEditor.getModel().selectAll()

  startMeteor: ->
    # get project path for active editor
    activeProjectPath = @getProjectPathForActiveBuffer()
    console.log(activeProjectPath)
