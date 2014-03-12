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
  belongs_to  :rider
  has 1,      :trip
  has n,      :transactions
  
  # Validations--------------------
  validates_within :pass_type, :set => $config['transport'].keys, :unless => lambda { |res| res.pass_type.nil? }
  validates_within :rider_type, :set => $config['rider'].keys
  validates_within :current_transport, :set => $config['transport'].keys, :unless => lambda { |res| res.current_transport.nil? }

  
#  attr_accessor :pass_type, :rider_type 
  attr_accessor :rider_type, :pass_type, :month_valid, :year_valid,  :current_transport, :balance, :trip_active, :discount 

  #-- Methods---------------------
  def initialize(attributes = {})
    attributes[:rider_type] ||= 'regular'
    @balance = 0.0
    @trip_active = false
    @pass_type = (attributes[:pass_type].nil? ? 'bus' : attributes[:pass_type]) if attributes[:amount].nil?
    @rider_type = attributes[:rider_type]
  end

  # Swipe the card
  def swipe(transport_type, location = nil)
  
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
    Time.now.year.to_s == @year_valid and Time.now.month.to_s == @month_valid
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
