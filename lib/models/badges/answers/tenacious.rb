require_relative '../badge'

class Tenacious < Badge
  series :tenacious

  def progress_title
    "You're getting close to..."
  end

  def progress_description
    answers = service.fetch('users', 'answers', {
      ids: user_id,
      sort: 'votes',
      order: 'desc',
      fetch_all_pages: true
    })

    total_answers = answers.length

    # Get array of zero score accepted answers
    answers.keep_if { |answer| answer['is_accepted'] && answer['score'] == 0}

    # Get all questions related to those answers
    question_ids = answers.map { |answer| answer['question_id'] }
    questions = []

    # {ids} can contain up to 100 semicolon delimited ids
    if question_ids.length < 100
      questions = service.fetch('questions', ids: question_ids)
    else
      question_ids.each_slice(100) { |slice| questions += service.fetch('questions', ids: slice) }
    end

    answers.each do |answer|
      answer['question'] = questions.find { |question| question['question_id'] == answer['question_id'] }
    end

    # Make array of accepted answers that are not answers to your own questions
    answers.keep_if { |answer| answer['question']['owner']['user_id'] != self.user_id }

    zero_score_accepted_answers = answers.length
    percentage_of_answers = zero_score_accepted_answers.to_f / total_answers * 100
    formatted_percentage = "%.1f%%" % [percentage_of_answers]
    remaining_accepted_answers = required_accepted_answers - zero_score_accepted_answers

    intro_component = "More than #{required_accepted_answers - 1} zero score accepted answers and #{required_percentage}% of total."
    answers_component = ""
    percentage_component = "and your percentage is #{formatted_percentage}."

    if remaining_accepted_answers > 0
      answers_component = "You need #{remaining_accepted_answers} more " + "answer".pluralize(remaining_accepted_answers, "answers")
    else
      answers_component = "You need 0 more answers"
    end

    "%s %s %s" % [intro_component, answers_component, percentage_component]
  end

  def required_accepted_answers
    6 # more than 5
  end

  def required_percentage
    20
  end

  def service
    @service ||= StackExchangeService.new('stackoverflow')
  end
end

class  UnsungHero < Tenacious
  def required_accepted_answers
    11 # more than 10
  end

  def required_percentage
    25
  end
end
