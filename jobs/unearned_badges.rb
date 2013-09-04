require 'net/http'
require 'json'
require 'helpers/rank_colour'

class Badge
  include RankColour
end

class UnearnedBadgesJob
  attr_reader :user_id, :service

  def self.run(*args)
    new(*args).run
  end

  def initialize(user_id)
    @user_id = user_id
  end

  def service
    @service ||= StackExchangeService.new
  end

  def run
    stack_exchange = Net::HTTP.new('api.stackexchange.com')

    named_badges = service.fetch 'badges/name', {
      filter: '!9j_cPloMN',
      order: 'desc',
      sort: 'rank',
      pagesize: 100
    }

    named_badges.map! { |b| Badge.new(b, user_id) }

    user_badges = service.fetch('users', 'badges', ids: user_id)
    user_badges.map! { |b| Badge.new(b, user_id) }

    # get unearned badges
    #
    # where there is a set of badges (bronze, silver, gold),
    # only keep lowest ranked unearned badge in array
    unearned_badges = Badge.first_badges_in_series(named_badges - user_badges)

    random_badge = unearned_badges.sample

    send_event('unearned_badges', { :title => random_badge.progress_title,
                                    :text => random_badge.name,
                                    :link => random_badge.link,
                                    :moreinfo => random_badge.progress_description,
                                    :background => random_badge.colour_for_rank })
  end
end

SCHEDULER.every '1h', :first_in => '8m' do
  # Steph Sharp: 1367622
  # Adam Sharp: 1164143
  # David Underwood: 131066
  # Daniel Beauchamp: 208314
  # Edward Ocampo-Gooding: 95705
  # Jeff Atwood: 1
  #
  # Others:
  # 1493368 (eligible for Reversal)
  user_id = 131066

  UnearnedBadgesJob.run(user_id)
end
