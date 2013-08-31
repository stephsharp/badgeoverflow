module NumberFormatter
  def with_suffix
    suffix = ["k", "m"]
    if (self < 1000)
      self.to_s
    else
      exp = (Math.log(self) / Math.log(1000)).to_i
      "%.1f%c" % [(self.to_f / 1000 ** exp).round(1), suffix[exp-1]]
    end
  end

  def with_commas
    self.to_s.reverse.gsub(/...(?=.)/,'\&,').reverse
  end
end

class Numeric
  include NumberFormatter
end
