require_relative '../badge'

class Investor < Badge
  # add callbacks here to return progress percentage, progress string,
  # to fetch required data, etc.

  def progress_description
    "Offer a bounty on another person's question"
  end

end
