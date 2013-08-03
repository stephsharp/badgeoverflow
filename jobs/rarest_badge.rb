require 'net/http'
require 'json'

# Steph Sharp: 1367622 
# Adam Sharp: 1164143
# David Underwood: 131066
# Daniel Beauchamp: 208314
# Edward Ocampo-Gooding: 95705
# Jeff Atwood: 1
user_id = 1

# Get all badges for user - /users/{ids}/badges
SCHEDULER.every '1h', :first_in => 0 do |job|
  stack_exchange = Net::HTTP.new('api.stackexchange.com')
  badge_ids = []
  page_number = 1
  
  loop do
    user_badges_response = JSON.parse(stack_exchange.get("/2.1/users/#{user_id}/badges?page=#{page_number}&pagesize=30&site=stackoverflow").body)
    
    # Create array of badge ids
    badge_ids << user_badges_response['items'].map { |badge| badge['badge_id'] }
    page_number += 1
    backoff = user_badges_response['backoff']
    
    if backoff
      sleep backoff
    end

    # break loop if there are no more pages
    break unless user_badges_response['has_more']
  end   
      
  if badge_ids.empty?
    send_event('rarest_badge', { :text => "No badges", :moreinfo => "", :background => badge_colour})
  else
    page_number = 1
    rarest_badge = nil
    
    loop do
      # Get all badges with ids - /badges/{ids} 
      badges_response = JSON.parse(stack_exchange.get("/2.1/badges/#{badge_ids.join(';')}?page=#{page_number}&pagesize=30&site=stackoverflow").body)

      # Get badge with lowest award_count
      rarest_badge = badges_response['items'].reduce do |rarest, badge|
        badge['award_count'] < rarest['award_count'] ? badge : rarest
      end
    
      page_number += 1
      backoff = badges_response['backoff']
      
      if backoff
        sleep backoff
      end

      # break loop if there are no more pages
      break unless badges_response['has_more']
    end  

    # Display badge name with award_count below
    send_event('rarest_badge', { :text => rarest_badge['name'], 
                                 :moreinfo => "Awarded #{rarest_badge['award_count']} times",
                                 :background => badge_colour(rarest_badge['rank'])
                                })
  end
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
