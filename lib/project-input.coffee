{$, TextEditorView, View} = require 'atom-space-pen-views'

module.exports =
class ProjectInput extends View
  projectNameEditor: null

  @content: ->
    @div =>
      @div "Project name:"
      @subview 'projectNameEditor', new TextEditorView(mini: true)

  getText: ->
    return @projectNameEditor.getText()

  setText: (text) ->
    @projectNameEditor.setText(text)
