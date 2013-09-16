require 'badgeoverflow/core'
require 'badgeoverflow/helpers'

class StackOverflow::Badge
  include RankColour
end

service = StackExchangeService.new
user_id = BadgeOverflowConfig.user_id

SCHEDULER.every '10m', :first_in => 0 do
  named_badges = service.fetch 'badges/name', {
    filter: '!9j_cPloMN',
    order: 'desc',
    sort: 'rank',
    pagesize: 100
  }

  named_badges.map! { |b| StackOverflow::Badge.new(b, user_id) }

  user_badges = service.fetch('users', 'badges', ids: user_id)
  user_badges.map! { |b| StackOverflow::Badge.new(b, user_id) }

  # get unearned badges
  #
  # where there is a set of badges (bronze, silver, gold),
  # only keep lowest ranked unearned badge in array
  unearned_badges = StackOverflow::Badge.first_badges_in_series(named_badges - user_badges)

  random_badge = unearned_badges.sample
  random_badge.calculate_progress!

  send_event('unearned_badges', { :title => random_badge.progress_title,
                                  :text => random_badge.name,
                                  :link => random_badge.link,
                                  :moreinfo => random_badge.progress_description,
                                  :background => random_badge.colour_for_rank })
end
