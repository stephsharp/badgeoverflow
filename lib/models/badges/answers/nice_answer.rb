require_relative '../badge'

class NiceAnswer < Badge
  series :nice_answer

  def progress_title
    "You're getting close to..."
  end

  def progress_description
    answer = service.fetch('users', 'answers', {
      ids: user_id,
      sort: 'votes',
      order: 'desc',
      pagesize: 1,
      fetch_all_pages: false
    }).first

    question = service.fetch('questions', ids: answer['question_id']).first

    question_title = question['title']
    score = answer['score']
    remaining = required_score - score

    score_str = "#{score} " + "vote".pluralize(score, "votes")
    remaining_str = "#{remaining} " + "vote".pluralize(remaining, "votes")

    "Your answer on \"#{question_title.truncate(65)}\" has #{score_str}. #{remaining_str} to go!"
  end

  def required_score
    10
  end
end

class GoodAnswer < NiceAnswer
  series :nice_answer

  def required_score
    25
  end
end

class GreatAnswer < NiceAnswer
  series :nice_answer

  def required_score
    100
  end
end
