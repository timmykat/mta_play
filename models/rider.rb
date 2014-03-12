class Rider 
  include ::DataMapper::Resource
  include ::DataMapper::Validate
  
  #--Define------------------------
  property :id,         Serial
  timestamps :at
  
  # Assocations
  has n, :oyster_cards

  
#   options for purchase_card:
#       :rider_type => one of the rider types
#       
#       { :pass => one of the transport types
#    OR {
#       { :amount => floating point cash amount
  def purchase_card(options = {})
    add_amount = options.delete(:amount)
    rider = self
    oyster_card = rider.oyster_cards.new(options)
    begin
      oyster_card.save
    rescue DataMapper::SaveFailureError
      puts "There was an error purchasing the Oyster Card."
      oyster_card.errors.each do |e| 
        puts e
      end
      return false
    end
        
    case
      when !options[:pass_type].nil?
        fee = TransitFee.calculate_pass(oyster_card.rider_type, options[:pass_type])
        transaction = oyster_card.transactions.new(transaction_type: 'buy_pass', transport_type: options[:pass_type], mode: 'pass', fee: fee)
      when !add_amount.nil? && (add_amount > 0.1)
        transaction = oyster_card.transactions.new(transaction_type: 'add_value_to_card', fee: add_amount, mode: 'debit_card')
      else
        puts "You need to enter an amount or select a pass type (bus, subway, commuter_rail or special_bus)"
        return false
    end
    
    if transaction.authorized?
      case
        when options[:pass_type]
          oyster_card.month_valid = Time.now.month.to_s
          oyster_card.year_valid = Time.now.year.to_s
          oyster_card.pass_type = options[:pass_type]
        when !add_amount.nil? && (add_amount > 0.1)
          oyster_card.balance += add_amount
      end

      begin
        oyster_card.save
      rescue DataMapper::SaveFailureError => e
        oyster_card.errors.each do |e| 
          puts e
        end
        puts "There was an updating your Oyster Card."
        return false
      end
    else
      puts "Sorry, your transaction was not authorized."
      return false
    end
    oyster_card.display_info
    oyster_card
  end  
end
