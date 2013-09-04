require_relative '../badge'

class Teacher < Badge

  def progress_description
    answer = service.fetch('users', 'answers', {
      ids: user_id,
      sort: 'votes',
      order: 'desc',
      fetch_all_pages: true
    }).first

    if answer
      "Answered first question with score of 1 or more. None of your answers have any upvotes yet!"
    else
      "Answered first question with score of 1 or more. You have not answered any questions yet!"
    end
  end

  def service
    @service ||= StackExchangeService.new('stackoverflow')
  end
end
