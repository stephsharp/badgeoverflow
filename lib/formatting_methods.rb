# Set background colour of widget to badge rank
def badge_colour (badge_rank = nil)
  case badge_rank
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

def with_suffix (count)
  suffix = ["k", "m"]
  if (count < 1000)
    count.to_s
  else
    exp = (Math.log(count) / Math.log(1000)).to_i
    "%.1f%c" % [(count.to_f / 1000 ** exp).round(1), suffix[exp-1]]
  end
end
