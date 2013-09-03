require_relative '../badge'

class SelfLearner < Badge

  def progress_title
    "You're getting close to..."
  end

  def progress_description
    # Get all answers the user has, ordered by votes
    answers = service.fetch('users', 'answers', {
      ids: user_id,
      sort: 'votes',
      order: 'desc',
      filter: '!9cC8zqAGM',
      fetch_all_pages: true
    })

    # Get all questions related to those answers (question_id)
    answers.each do |answer|
      question = service.fetch('questions', ids: answer['question_id']).first
      answer['question'] = question
    end

    # Make array of answers to your own questions (where question owner user_id == self.user_id)
    answers.keep_if { |answer| answer['question']['owner']['user_id'] == self.user_id }

    # Get first answer in array (highest score)
    answer = answers.first
  
    if answer
      title = answer['question']['title']
      link = answer['link']
      score = answer['score']
      remaining = required_score - score
    
      score_str = "#{score} " + "vote".pluralize(score, "votes")
      remaining_str = "#{remaining} " + "vote".pluralize(remaining, "votes")

      "Your answer to your own question \"#{title.truncate(65).link_to(link)}\" has #{score_str}. #{remaining_str} to go!"
    else
      "Answered your own question with score of #{required_votes} or more. You have not answered any of your own questions yet!"
    end
  end

  def required_score
    3
  end

  def service
    @service ||= StackExchangeService.new('stackoverflow')
  end
end
