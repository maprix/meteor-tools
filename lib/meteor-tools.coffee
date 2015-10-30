ProjectInput = require './project-input'
{CompositeDisposable} = require 'atom'

module.exports =
MeteorTools =
  inputPanel: null
  subscriptions: null
  projectName: null

  keyUpCallback: (event) ->
    code = event.keyCode
    if code == 27
      @inputPanel.hide()
      console.log('Close!!!')
    else if code == 13
      @inputPanel.hide()
      projectName = @projectInput.getText()
      projectPath = 'C:\\Users\\Marcus\\'+projectName
      alert('Create project: '+projectName)
      #child_process = require('child_process');
      #child = child_process.spawn('C:\\Program Files (x86)\\Notepad++\\notepad++.exe')
      atom.project.addPath(projectPath)
      atom.workspace.open(projectPath+'\\'+projectName+'.js')

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
    'TestPath':
      title: 'Test Path'
      type: 'string'
      description: 'Maximum height of a console window.'
      default: 'C:/TestPath'
      order: 1

  createNewProject: ->
    @projectInput.setText('new-project')
    @inputPanel.show()
    @projectInput.projectNameEditor.focus()
    @projectInput.projectNameEditor.getModel().selectAll()
