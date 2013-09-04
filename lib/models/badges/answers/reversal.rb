require_relative '../badge'
require 'helpers/hash_struct'

class Reversal < Badge
  REQUIRED_SCORE = 20

  def progress_description
    eligible_answers = answers_scoring_in(1...REQUIRED_SCORE)

    map_answer_questions!(eligible_answers)

    eligible_answer = eligible_answers.find { |a| a.question.score <= -5 }

    if eligible_answer
      score = eligible_answer.score
      remaining = REQUIRED_SCORE - score

      score_str = "#{score} " + "vote".pluralize(score, "votes")
      remaining_str = "#{remaining} " + "vote".pluralize(remaining, "votes")

      question = eligible_answer.question

      "Your answer on \"#{question.title.truncate(60).link_to(question.link)}\" has #{score_str}. #{remaining_str} to go!"
    else
      super + ". You haven't answered any questions with a score of -5!"
    end
  end

  private

  def answers_scoring_in(range)
    service.fetch('users', 'answers', {
      ids: user_id,
      sort: 'votes',
      pagesize: 100,
      min: range.min,
      max: range.max,
      fetch_all_pages: true
    }).map { |a| HashStruct.new(a) }
  end

  def map_answer_questions!(eligible_answers)
    answers_by_question_id = eligible_answers.reduce({}) do |hash, a|
      hash[a.question_id] = a; hash
    end

    eligible_answers.each_slice(100) do |answers|
      question_ids = answers.map(&:question_id)
      service.fetch('questions', ids: question_ids).each_with_index do |question|
        question = HashStruct.new(question)
        answer = answers_by_question_id[question.question_id]
        answer.question = question
      end
    end
  end

  def question_for(answer)
    service.fetch('questions', ids: answer['question_id']).first
  end
end
