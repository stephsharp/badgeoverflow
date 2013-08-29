def with_suffix (count)
  suffix = ["k", "m"]
  if (count < 1000)
    count.to_s
  else
    exp = (Math.log(count) / Math.log(1000)).to_i
    "%.1f%c" % [(count.to_f / 1000 ** exp).round(1), suffix[exp-1]]
  end
end
