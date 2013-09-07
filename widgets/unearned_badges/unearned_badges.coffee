class Dashing.UnearnedBadges extends Dashing.Widget

  onData: (data) ->
    if data.background
      # reset background colour
      $('.widget-unearned-badges').css 'background-color', data.background
