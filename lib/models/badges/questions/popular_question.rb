require_relative '../badge'

class PopularQuestion < Badge
  series :popular_question

  def progress_title
    "You're getting close to..."
  end

  def progress_description
    questions = service.fetch('users', 'questions', {
      ids: user_id,
      sort: 'votes',
      order: 'desc',
      fetch_all_pages: true
    })

    # If only 1 question is returned, it is a Hash, not an array of Hashes
    if (!questions.is_a? Array)
      questions = Array.new [questions]
    end

    if (questions.length > 0)
      highest_views_question = questions.first

      # Get badge with highest view_count
      if (questions.length > 1)
        highest_views_question = questions.reduce do |highest_views, question|
          question['view_count'] > highest_views['view_count'] ? question : highest_views
        end
      end

      title = highest_views_question['title']
      views = highest_views_question['view_count']
      remaining = required_views - views

      views_str = "#{views.with_commas} " + "view".pluralize(views, "views")
      remaining_str = "#{remaining.with_commas} " + "view".pluralize(remaining, "views")

      #Asked a question with 1,000 views
      "Your question \"#{title.truncate(70)}\" has #{views_str}. #{remaining_str} to go!"
    else
      "Asked a question with #{required_views.with_commas} views. You have not asked any questions yet!"
    end
  end

  def required_views
    1000
  end

  def service
    @service ||= StackExchangeService.new('stackoverflow')
  end
end

class NotableQuestion < PopularQuestion
  def required_views
    2500
  end
end

class FamousQuestion < PopularQuestion
  def required_views
    10000
  end
end
