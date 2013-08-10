class Dashing.LargeText extends Dashing.Widget

  ready: ->
    # This is fired when the widget is done being rendered

  onData: (data) ->
    if data.background
      # reset background colour
      $('.widget-large-text').css 'background-color', data.background