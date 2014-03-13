class FundAuthorization
  def self.authorize(fee)
    if fee > 500.0
      puts "Authorize.net DENIED-above $500 limit"
      false
    elsif fee < 0.0
      puts "Authorize.net DENIED < 0"
      false
    else
      # Check for authorization of @fee
      puts "Authorize.net OK #{fee.to_currency}"
      true
    end
  end
end
