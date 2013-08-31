require_relative 'badge'

class Promoter < Badge
  # add callbacks here to return progress percentage, progress string,
  # to fetch required data, etc.

  def progress_description
    "Offer a bounty on your own question"
  end

end