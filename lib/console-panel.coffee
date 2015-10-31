{$, ScrollView, View} = require 'atom-space-pen-views'

module.exports =
class ConsolePanel extends View
  console: null

  @content: ->
    @div id: 'consolePane', =>
      @div id: 'consoleTitle', =>
        @div class: "left-title", "Meteo Console"
        @div class: 'right-title', =>
          @div id: "activityIndicator", class: "icon-gear"
      @div id: 'consoleContent'

  log: (text) ->
    text.replace(new RegExp('\r?\n','g'), '<br />');
    @find("#consoleContent").append(
      '<div class="log">' +
      text.replace(new RegExp('\r?\n','g'), '<br />')
       + '</div>')

  error: (text) ->
    text.replace(new RegExp('\r?\n','g'), '<br />');
    @find("#consoleContent").append(
      '<div class="log">' +
      text.replace(new RegExp('\r?\n','g'), '<br />')
       + '</div>')

  activityOn: () ->
    @find("#activityIndicator").show()

  activityOff: () ->
    @find("#activityIndicator").hide()
