# TODO: Add option to service.fetch to disable paging
# TODO: Restrict question title length to n characters

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
      pagesize: 1
    }).to_a.first

    title = question['title']
    score = question['score']
    remaining = 10 - score

    "Your question \"#{title}\" has #{score} votes. #{remaining} votes to go!"
  end

  def service
    @service ||= StackExchangeService.new('stackoverflow')
  end
end
