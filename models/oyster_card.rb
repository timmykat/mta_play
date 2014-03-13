class OysterCard
  include ::DataMapper::Resource
  include ::DataMapper::Validate
  
  #--Define------------------------
  property :id,                 Serial
  property :pass_type,          String
  property :rider_type,         String
  property :month_valid,        String
  property :year_valid,         String
  property :current_transport,  String
  property :balance,            Float,    :default => 0.0
  property :trip_active,        Boolean,  :default => false
  property :discount,           Float
  
  timestamps :at

  # Assocations
  has 1,      :trip
  has n,      :transactions
  
  # Validations--------------------
  validates_presence_of :rider_type
  validates_within :pass_type, :set => $config['transport'].keys, :unless => lambda { |t| t.pass_type.nil? }
  validates_within :rider_type, :set => $config['rider'].keys
  validates_within :current_transport, :set => $config['transport'].keys, :unless => lambda { |t| t.current_transport.nil? }

  
#  attr_accessor :pass_type, :rider_type 
  attr_accessor :month_valid, :year_valid,  :current_transport, :balance, :trip_active, :discount 

  #-- Methods---------------------
  def initialize(attributes = {})
    @balance = 0.0
    @trip_active = false
    @pass_type = (attributes[:pass_type].nil? ? 'bus' : attributes[:pass_type]) if attributes[:amount].nil?
    @rider_type = attributes[:rider_type]
  end

#   options for purchase_card:
#       :rider_type => one of the rider types
#       
#       { :pass => one of the transport types
#    OR {
#       { :amount => floating point cash amount
  def self.purchase(options = {})
    add_amount = options.delete(:amount)
    oyster_card = OysterCard.new(options)
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

  # Swipe the card
  def swipe(transport_type)
  
    oyster_card = self
  
    swipe = Swipe.new(self, transport_type)
  
    unless swipe.is_valid?
      return false
    end
    
    transaction = oyster_card.transactions.new(:transport_type => transport_type, :transaction_type => 'take_trip', :mode => swipe.mode, :fee => swipe.fee)  
    unless transaction.authorized?
      transaction = nil
      return false
    end
    
    oyster_card.current_transport = transport_type
    oyster_card.save

    puts "\nYou are taking a trip on the #{@current_transport.pop}" 
    oyster_card.trip
  end
    
  def display_info
    puts "+------------------------------------------------"
    puts "| <Transport for London> **Oyster Card**"
    if pass_current?
      puts "| Your pass is valid for #{Date::MONTHNAMES[@month_valid.to_i]} #{@year_valid}."
      puts "| Your monthly pass is valid on these modes of transport:"
      puts "| #{valid_transport_modes.join(', ').pop}"
    else
      puts "| Your card is not currently valid as a monthly pass. Your card balance will be debited when you ride"
    end
    puts "| Your current balance is: #{@balance.to_currency}"
    puts "+------------------------------------------------"    
  end

  def pass_current?
    unless
      Time.now.year.to_s == @year_valid and Time.now.month.to_s == @month_valid
      return true
    end
    put "Your pass is not valid for the current month"
    false
  end

  def valid_transport_modes
    valid_modes = []
    tmodes = $config['transport'].keys
    tmodes.each do |mode|
      if @rider_type == 'employee'
        valid_modes << mode
      elsif mode == 'special_bus' and @rider_type == 'elderly'
        valid_modes << mode
      elsif tmodes.index(@pass_type) <= tmodes.index(mode)
        valid_modes << mode
      end
    end
    valid_modes
  end
end
