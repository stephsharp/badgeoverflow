require 'net/http'
require 'json'

require 'badgeoverflow/core'

service = StackExchangeService.new
user_id = BadgeOverflowConfig.user_id

# Get timeline for user - /users/{ids}/timeline 
SCHEDULER.every '1h', :first_in => '90s' do
  recent_badges = []
  number_of_badges = 5
  page_number = 1
  
  loop do
    user_timeline_response = service.fetch 'users', 'timeline', {
      ids: user_id,
      page: page_number,
      pagesize: 100,
      fetch_all_pages: false
    }

    # Get badges in timeline
    user_timeline_response.each do |item|
      if item['timeline_type'] == "badge" && recent_badges.length < number_of_badges
        badge_response = service.fetch 'badges', ids: item['badge_id']
        badge_rank = badge_response.first['rank']
        recent_badges << { rank: badge_rank, label: item['detail'] }

        backoff = badge_response['backoff']
        if backoff
          sleep backoff
        end
      end
    end

    page_number += 1

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
