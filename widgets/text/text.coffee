class Dashing.Text extends Dashing.Widget

  onData: (data) ->
    if data.background
      # reset background colour
      $('.widget-text').css 'background-color', data.background

        
