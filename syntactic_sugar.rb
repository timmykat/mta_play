#--- Auxiliary methods ----
class Float
  def to_currency
    "$#{sprintf('%.2f', self)}"
  end
end
class String
  def pop
    self.gsub('_', ' ').upcase
  end
end
class Time
  def weekend?
    self.saturday? or self.sunday?
  end
end
