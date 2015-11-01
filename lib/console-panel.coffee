{$, View} = require 'atom-space-pen-views'

module.exports =
class ConsolePanel extends View
  panel: null

  @content: ->
    @div id: 'consolePane', =>
      @div id: 'consoleTitle', =>
        @div class: "left-title", "Meteor Console"
        @div class: 'right-title', =>
          @div id: "activityIndicator", class: "icon-gear"
          @div id: "showConsole", class: "icon-chevron-up"
          @div id: "hideConsole", class: "icon-chevron-down"
          @div id: "closeConsole", class: "icon-x"
      @div id: 'consoleContent'

  initialize: ->
    @find("#showConsole").hide()
    @find("#closeConsole").on 'click', (event) =>
      @panel?.hide()
    @find("#showConsole").on 'click', (event) =>
        @find("#consoleContent").show()
        @find("#showConsole").hide()
        @find("#hideConsole").show()
    @find("#hideConsole").on 'click', (event) =>
        @find("#consoleContent").hide()
        @find("#showConsole").show()
        @find("#hideConsole").hide()

  setPanel: (panel) ->
    @panel = panel

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
