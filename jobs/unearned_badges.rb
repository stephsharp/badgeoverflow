require 'net/http'
require 'json'

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

    # get all badge ids the user has earned and store in array
    user_badges = service.fetch('users', 'badges', ids: user_id)
    user_badge_ids = user_badges.map { |b| b['badge_id'] }

    # get unearned badge ids (in array 1, but not in array 2)
    named_badge_ids = named_badges.map { |badge| badge.badge_id }
    unearned_badge_ids = named_badge_ids - user_badge_ids

    # where there is a set of badges (bronze, silver, gold),
    # only keep lowest ranked unearned badge in array



    # choose badge at random from the array
    random_badge_id = unearned_badge_ids.sample
    random_badge = named_badges.find { |badge| badge.badge_id == random_badge_id }

    # user.get_progress_toward_badge(Badge.new(random_badge)) do |progress|
    #   send_event 'unearned_badges', progress.to_h
    # end

    # display name of badge, and what is required to earn the badge (description)
    # personalise the description to what the user needs to earn the bagde?
    # e.g. "You only need 4 more comments with score of 5 or more."

    send_event('unearned_badges', { :text => random_badge.name,
                                    :link => random_badge.link,
                                    :moreinfo => random_badge.progress,
                                    :background => badge_colour(random_badge.rank) })
  end
end

SCHEDULER.every '1h', :first_in => 0 do
  # Steph Sharp: 1367622
  # Adam Sharp: 1164143
  # David Underwood: 131066
  # Daniel Beauchamp: 208314
  # Edward Ocampo-Gooding: 95705
  # Jeff Atwood: 1
  user_id = 1367622

  UnearnedBadgesJob.run(user_id)
end
