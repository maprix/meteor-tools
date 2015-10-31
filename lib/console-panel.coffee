{$, ScrollView, View} = require 'atom-space-pen-views'

module.exports =
class ConsolePanel extends View
  console: null

  @content: ->
    @div =>
      @div "Console:"
      @div id: 'console', style: 'position: relative; padding: 5px; height: 150px; overflow: auto'

  setText: (text) ->
    @find("#console").append('<div>' + text + '</div>')
