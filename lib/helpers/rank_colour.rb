module RankColour

  def colour_for_rank
    case self.rank
    when 'bronze'
      '#BF8753'
    when 'silver'
      '#B8B8B8'
    when 'gold'
      '#FEC337'
    else
      '#808080'
    end
  end

end