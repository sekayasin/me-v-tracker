module CheckMinMaxHelper
  def check_min_max
    return unless min && max

    if min > max
      self.min, self.max = max, min
    end
  end
end
