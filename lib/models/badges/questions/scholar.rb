require_relative '../badge'

class Scholar < Badge

  def progress_description
    question = service.fetch('users', 'questions', {
      ids: user_id,
      sort: 'votes',
      order: 'desc',
      pagesize: 1,
      fetch_all_pages: false
    }).first

    if question
      "Accept an answer to one of your questions and you will be awarded this badge!"
    else
      "You have not asked any questions yet! To be awarded this badge, ask a question and accept an answer."
    end
  end

  def service
    @service ||= StackExchangeService.new('stackoverflow')
  end
end
