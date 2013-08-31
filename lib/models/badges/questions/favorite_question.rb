require_relative '../badge'

class FavoriteQuestion < Badge
  series :favorite_question

  def progress_title
    "You're getting close to..."
  end

  def progress_description
    questions = service.fetch('users', 'questions', {
      ids: user_id,
      sort: 'votes',
      order: 'desc',
      filter: '!9cC8zbO*T',
      fetch_all_pages: true
    })

    if questions.length > 0
      highest_favorites_question = questions.first

      # Get badge with highest favorite_count
      if questions.length > 1
        highest_favorites_question = questions.reduce do |highest_favorites, question|
          question['favorite_count'] > highest_favorites['favorite_count'] ? question : highest_favorites
        end
      end

      title = highest_favorites_question['title']
      favorites = highest_favorites_question['favorite_count']
      remaining = required_favorites - favorites

      favorites_str = "#{favorites} " + "favorite".pluralize(favorites, "favorites")
      remaining_str = "#{remaining} " + "favorite".pluralize(remaining, "favorites")

      "Your question \"#{title.truncate(70)}\" has #{favorites_str}. #{remaining_str} to go!"
    else
      "Question favorited by #{required_favorites} users. You have not asked any questions yet!"
    end
  end

  def required_favorites
    25
  end

  def service
    @service ||= StackExchangeService.new('stackoverflow')
  end
end

class StellarQuestion < FavoriteQuestion
  def required_favorites
    100
  end
end
