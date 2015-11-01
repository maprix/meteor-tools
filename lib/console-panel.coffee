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
    ele = @find("#consoleContent")
    ele.append(
      '<div class="log">' +
      text.replace(new RegExp('\r?\n','g'), '<br />')
       + '</div>')
    ele.scrollTop(ele[0].scrollHeight)

  error: (text) ->
    ele = @find("#consoleContent")
    ele.append(
      '<div class="error">' +
      text.replace(new RegExp('\r?\n','g'), '<br />')
       + '</div>')
    ele.scrollTop(ele[0].scrollHeight)

  activityOn: () ->
    @find("#activityIndicator").show()

  activityOff: () ->
    @find("#activityIndicator").hide()
