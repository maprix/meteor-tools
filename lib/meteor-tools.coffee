ProjectInput = require './project-input'
{CompositeDisposable} = require 'atom'
ChildProcess = require 'child_process'

module.exports =
MeteorTools =
  inputPanel: null
  subscriptions: null
  projectName: null

  execCallback: (error, stdout, stderr) ->
    console.log('stdout: ' + stdout)
    console.log('stderr: ' + stderr)
    if error != null
      console.log('exec error: ' + error)

  keyUpCallback: (event) ->
    code = event.keyCode
    if code == 27
      @inputPanel.hide()
      console.log('Close!!!')
    else if code == 13
      @inputPanel.hide()
      projectName = @projectInput.getText()
      projectPath = atom.config.get("meteor-tools.meteorPath")+'\\'+projectName
      alert('Create project: '+projectPath)
      #child_process = require('child_process')
      #child_process = new ChildProcess
      child = ChildProcess.exec('meteor list',
        cwd: 'C:\\Users\\Marcus\\simple-todos',
        MeteorTools.execCallback)
      #atom.project.addPath(projectPath)
      #atom.workspace.open(projectPath+'\\'+projectName+'.js')

  activate: (state) ->
    @projectInput = new ProjectInput()
    @projectInput.projectNameEditor.on 'keyup', (event) ->
      MeteorTools.keyUpCallback(event)
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
