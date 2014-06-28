require 'net/http'
require 'json'

require 'badgeoverflow/core'

class StackOverflow::Badge
  include RankColour
end

user_id = BadgeOverflowConfig.user_id
site = BadgeOverflowConfig.site || 'stackoverflow'

# Get all badges for user - /users/{ids}/badges
SCHEDULER.every '1h', :first_in => '40s' do |job|
  stack_exchange = Net::HTTP.new('api.stackexchange.com')
  badge_ids = []
  page_number = 1
  
  loop do
    user_badges_response = JSON.parse(stack_exchange.get("/2.2/users/#{user_id}/badges?page=#{page_number}&pagesize=30&site=#{site}").body)
    
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
      badges_response = JSON.parse(stack_exchange.get("/2.2/badges/#{badge_ids.join(';')}?page=#{page_number}&pagesize=30&site=#{site}").body)

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

    rarest_badge = StackOverflow::Badge.new(rarest_badge, user_id)

    # Display badge name with award_count below
    formatted_award_count = rarest_badge.award_count.with_suffix
    send_event('rarest_badge', { :text => rarest_badge.name,
                                 :link => rarest_badge.link,
                                 :moreinfo => "Awarded #{formatted_award_count} times",
                                 :background => rarest_badge.colour_for_rank
                                })
  end
end
