require_relative 'badge'

class Altruist < Badge
  # add callbacks here to return progress percentage, progress string,
  # to fetch required data, etc.

  def progress_description
    "Manually award a bounty on another person's question"
  end

end
