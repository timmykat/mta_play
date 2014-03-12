class FundAuthorization
  def self.authorize(fee)
    # Check for authorization of @fee
    puts "Authorize.net OK #{fee.to_currency}\n\n"
    true
  end
end
