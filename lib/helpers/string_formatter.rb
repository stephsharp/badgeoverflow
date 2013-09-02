module StringFormatter
  def truncate(count)
    total_length = 0
    truncated = false
    new_string = ""

    self.to_s.strip.split(/\s/).each do |word|
      word = word.strip
      total_length += word.length

      if total_length == 0
        new_string << word
      elsif total_length <= count
        new_string << " " + word
        total_length += 1
      else
        truncated = true
      end
    end

    new_string.strip!
    new_string << "..." if truncated
    new_string
  end

  def pluralize(count, plural)
    if (count == 1)
      self
    else
      plural
    end
  end

  def link_to(url)
    "<a href=\"#{url}\" target=\"_blank\">#{self}</a>"
  end
end

class String
  include StringFormatter
end
