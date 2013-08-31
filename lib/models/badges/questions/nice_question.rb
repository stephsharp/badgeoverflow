require_relative '../badge'

class NiceQuestion < Badge
  series :nice_question

  def progress_title
    "You're getting close to..."
  end

  def progress_description
    question = service.fetch('users', 'questions', {
      ids: user_id,
      sort: 'votes',
      order: 'desc',
      pagesize: 1,
      fetch_all_pages: false
    })

    title = question['title']
    score = question['score']
    remaining = required_score - score

    "Your question \"#{title.truncate(75)}\" has #{score} votes. #{remaining} votes to go!"
  end

  def required_score
    10
  end
end

class GoodQuestion < NiceQuestion
  def required_score
    25
  end
end

class GreatQuestion < NiceQuestion
  def required_score
    100
  end
end
