require 'net/http'
require 'json'

class UnearnedBadgesJob
  attr_reader :user_id

  def initialize(user_id)
    @user_id = user_id
  end

  def run
    stack_exchange = Net::HTTP.new('api.stackexchange.com')
    named_badges = []
    user_badge_ids = []
    page_number = 1

    # get all named badge ids and store in an array
    loop do
      named_badges_response = JSON.parse(stack_exchange.get("/2.1/badges/name?page=#{page_number}&pagesize=30&order=desc&sort=rank&site=stackoverflow&filter=!9j_cPloMN").body)

      # Create array of badges
      named_badges += named_badges_response['items'].map do |badge_data|
        StackExchange::Badge.new(badge_data, user_id)
      end

      page_number += 1
      backoff = named_badges_response['backoff']

      if backoff
        sleep backoff
      end

      # break loop if there are no more pages
      break unless named_badges_response['has_more']
    end

    # get all badge ids the user has earned and store in array
    # REFACTOR THIS LOOP... IT'S PRETTY MUCH THE SAME AS ABOVE
    page_number = 1
    loop do
      user_badges_response = JSON.parse(stack_exchange.get("/2.1/users/#{user_id}/badges?page=#{page_number}&pagesize=30&site=stackoverflow").body)

      # Create array of badge ids
      user_badge_ids += user_badges_response['items'].map { |badge| badge['badge_id'] }
      page_number += 1
      backoff = user_badges_response['backoff']

      if backoff
        sleep backoff
      end

      # break loop if there are no more pages
      break unless user_badges_response['has_more']
    end

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

  private

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
end

SCHEDULER.every '1h', :first_in => 0 do
  # Steph Sharp: 1367622
  # Adam Sharp: 1164143
  # David Underwood: 131066
  # Daniel Beauchamp: 208314
  # Edward Ocampo-Gooding: 95705
  # Jeff Atwood: 1
  user_id = 1367622

  UnearnedBadgesJob.new(user_id).run
end
