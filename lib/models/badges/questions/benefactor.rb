require_relative '../badge'

class Benefactor < Badge
  # add callbacks here to return progress percentage, progress string,
  # to fetch required data, etc.

  def progress_description
    "Manually award a bounty on your own question"
  end

end
