require_relative '../badge'

class Student < Badge
  # add callbacks here to return progress percentage, progress string,
  # to fetch required data, etc.

  def progress_title
    "You're getting close to..."
  end

  def progress_description
    "Asked first question with score of 1 or more. You could try improving an existing question, or asking more questions!"
  end

end
