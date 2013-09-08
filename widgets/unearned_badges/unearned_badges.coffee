class Dashing.UnearnedBadges extends Dashing.Widget

  onData: (data) ->
    if data.background
      $('.widget-unearned-badges').css 'background-color', data.background
