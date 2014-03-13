class Swipe
  attr_accessor :mode, :fee
  
  def initialize(oyster_card, transport_type)
    @oc = oyster_card
    @transport_type = transport_type
  end 
  
  def is_valid?
    use_pass? || sufficient_funds? 
  end
  
  def use_pass?
    if @oc.pass_current? and pass_valid?
      @mode = 'pass'
      puts 'Using pass'
      true
    else
      false
    end
  end
  
  def pass_valid?
    is_valid = true
    if @oc.pass_type.nil?
      puts "You have not purchased a pass"
      is_valid = false
    end
        
    unless transport_valid?
      puts "You need a higher level pass to ride this (commuter rail > subway > bus)"
      is_valid = false
    end
    is_valid  
  end
  
  def transport_valid?
    @oc.valid_transport_modes.include? @transport_type
  end
  
  def sufficient_funds?
    @mode = 'debit_card'
    # First check to see if the card should be active from the previous swipe
    if @oc.trip_active and (Time.now - @oc.updated_at.to_time > $config['oyster_card']['validity_period'])
      @oc.trip.destroy
      @oc.trip_active = false
      @oc.save
      @fee = 0.0
      true
    else
      fee = TransitFee.calculate_ride(@oc.rider_type, @transport_type)
      unless @oc.balance > fee
        puts "Your card balance is too low - please refill"
        return false
      end
      @fee = fee
      true
    end
  end
end
