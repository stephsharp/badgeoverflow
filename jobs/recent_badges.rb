require 'net/http'
require 'json'

require 'badgeoverflow/core'

user_id = BadgeOverflowConfig.user_id
site = BadgeOverflowConfig.site || 'stackoverflow'

# Get timeline for user - /users/{ids}/timeline 
SCHEDULER.every '1h', :first_in => '30s' do |job|
  stack_exchange = Net::HTTP.new('api.stackexchange.com')
  recent_badges = []
  number_of_badges = 5
  page_number = 1
  
  loop do
    user_timeline_response = JSON.parse(stack_exchange.get("/2.2/users/#{user_id}/timeline?page=#{page_number}&pagesize=100&site=#{site}").body)

    # Get badges in timeline
    user_timeline_response.fetch('items').each do |item|
      if item['timeline_type'] == "badge" && recent_badges.length < number_of_badges
        badge_response = JSON.parse(stack_exchange.get("/2.2/badges/#{item['badge_id']}?site=#{site}").body)
        badge_rank = badge_response.fetch('items').first['rank']
        recent_badges << { rank: badge_rank, label: item['detail'] }

        backoff = badge_response['backoff']
        if backoff
          sleep backoff
        end
      end
    end

    page_number += 1
    backoff = user_timeline_response['backoff']

    if backoff
      sleep backoff
    end

    # break loop unless there are more pages to search and not enough badges have been found
    break unless (user_timeline_response['has_more'] && recent_badges.length < number_of_badges)
  end  

  # Check if user has no badges
  if recent_badges.empty?
    recent_badges["No Badges"] = { rank: "", label: "No Badges" }
  end

  # Display recently awarded badges
  send_event('recent_badges', { items: recent_badges })
end
