require 'net/http'
require 'json'

require 'badgeoverflow/core'

class StackOverflow::Badge
  include RankColour
end

service = StackExchangeService.new
user_id = BadgeOverflowConfig.user_id

# Get all badges for user - /users/{ids}/badges
SCHEDULER.every '1h', :first_in => '40s' do |job|

  # Create array of badge ids
  user_badges = service.fetch('users', 'badges', ids: user_id)
  badge_ids = user_badges.map { |badge| badge['badge_id'] }
      
  if badge_ids.empty?
    send_event('rarest_badge', { :text => "No badges", :moreinfo => "", :background => badge_colour})
    return
  end

  # Get all badges with ids - /badges/{ids}
  badges = service.fetch('badges', ids: badge_ids)

  # Get badge with lowest award_count
  rarest_badge = badges.reduce do |rarest, badge|
    badge['award_count'] < rarest['award_count'] ? badge : rarest
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
