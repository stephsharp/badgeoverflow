require_relative '../badge'

class PopularQuestion < Badge
  def series
    :popular_question
  end

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

    # Get badge with highest view_count
    highest_views_question = questions.reduce do |highest_views, question|
      question['view_count'] > highest_views['view_count'] ? question : highest_views
    end

    if highest_views_question
      title = highest_views_question['title']
      link = highest_views_question['link']
      views = highest_views_question['view_count']
      remaining = required_views - views

      views_str = "#{views.with_commas} " + "view".pluralize(views, "views")
      remaining_str = "#{remaining.with_commas} " + "view".pluralize(remaining, "views")

      "Your question \"#{title.truncate(70).link_to(link)}\" has #{views_str}. #{remaining_str} to go!"
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
