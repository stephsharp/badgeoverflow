SCHEDULER.every '3m', :first_in => 0 do |job|

  # get all badge ids and store in an array
  # only get named badges, not tag based badges


  # get all badge ids the user has earned and store in array


  # get unearned badge ids (in array 1, but not in array 2)


  # where there is a set of badges (bronze, silver, gold),
  # only keep lowest ranked unearned badge in array


  # choose badge at random from the array


  # display name of badge, and what is required to earn the badge (description)
  # personalise the description to what the user needs to earn the bagde?
  # e.g. "You only need 4 more comments with score of 5 or more."


  # set background colour of widget to colour of badge rank



  send_event('unearned_badges', { :background => badge_colour })
end

# Set background colour of widget to badge rank
def badge_colour (badge_rank = nil)
  case badge_rank
  when 'bronze'
    '#BF8753'
  when 'silver'
    '#B8B8B8'
  when 'gold'
    '#FEC337'
  else
    '#808080'
  end
end
