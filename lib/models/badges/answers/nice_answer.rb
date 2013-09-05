require_relative '../badge'

class NiceAnswer < Badge
  def series
    :nice_answer
  end

  def progress_title
    "You're getting close to..."
  end

  def progress_description
    answer = service.fetch('users', 'answers', {
      ids: user_id,
      sort: 'votes',
      order: 'desc',
      pagesize: 1,
      filter: '!9cC8zqAGM',
      fetch_all_pages: false
    }).first

    question = service.fetch('questions', ids: answer['question_id']).first

    question_title = question['title']
    link = answer['link']
    score = answer['score']
    remaining = required_score - score

    score_str = "#{score} " + "vote".pluralize(score, "votes")
    remaining_str = "#{remaining} " + "vote".pluralize(remaining, "votes")

    "Your answer on \"#{question_title.truncate(65).link_to(link)}\" has #{score_str}. #{remaining_str} to go!"
  end

  def required_score
    10
  end
end

class GoodAnswer < NiceAnswer
  def required_score
    25
  end
end

class GreatAnswer < NiceAnswer
  def required_score
    100
  end
end
