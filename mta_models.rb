class Rider 
  include DataMapper::Resource
  include DataMapper::Validate
  
  #--Define------------------------
  property :id,         Serial
  property :type,       String
  timestamps :at
  
  # Validations
  validates_within :type, :set => $config['rider'].keys

  # Assocations
  has n, :oyster_cards

  attr_accessor :type
  
  #-- Methods---------------------
  def self.create(attributes = { :type => 'regular' })
    r = Rider.new(attributes)
    if r
      unless r.save
        puts "There was an error saving the rider"
        return false
      end
    else
      puts "There was an error creating the rider."
    end
    r
  end  

  def initialize(attributes = { :type => 'regular' })
    @type = attributes[:type]
    self.save
  end

  def purchase_card(options)
    oyster_card = self.oyster_cards.new
    
    # Bill the rider
    if bill_rider(options)
      case
        when options[:pass]
          oyster_card.valid_month = Time.now.month.to_s
          oyster_card.valid_year = Time.now.year.to_s
          oyster_card.pass_type = options[:pass]
        when options[:amount] && (options[:amount] > 0.0)
          oyster_card.balance += options[:amount]
      end
      oyster_card.save
    else
      puts "That is not a valid purchase option"
      return false
    end
    oyster_card
  end
  
  def bill_rider(options)
    case
      when options[:pass]
        amount = prorate_pass($fee_lookup[@type][options[:pass]]['pass'])
      when options[:amount]
        amount = prorate_per_ride(options[:amount])
    end
    if amount > 0
      puts "Your charge card will be debited: #{amount.to_currency}"
    else
      puts "This is free for you."
    end
    amount < 0.01 or authorize_transaction(amount)  
  end
  
  # Stubbed out transaction method
  def authorize_transaction(amount)
    puts "Your transaction has been authorized\n\n"
    true
  end
  
  def prorate_pass(amount)
    today = Time.now.day
    amount * $config['prorate']['pass'].inject(1) { |prorate, d|  (today > d['day'].to_i) ? d['amount'] : prorate }
  end
  
  def prorate_per_ride(amount)
    Time.now.weekend? ? ($config['prorate']['per_ride']['weekend'] * amount) : amount
  end
end


class OysterCard
  include DataMapper::Resource
  include DataMapper::Validate
  
  #--Define------------------------
  property :id,                 Serial
  property :valid_month,        String
  property :valid_year,         String
  property :pass_type,          String
  property :current_transport,  String
  property :balance,            Float, :default => 0.0
  property :active,             Boolean, :default => false
  property :discount,           Float
  property :rider_id,           Integer
  
  timestamps :at
  
  # Validations

  # Assocations
  belongs_to :rider
  has 1,      :trip
  
  attr_accessor :valid_month, :valid_year, :balance, :active, :discount, :location, :rider_id, :pass_type

  #-- Methods---------------------

  def initialize(attributes)
    @balance = 0.0
    self.save
  end

  # Swipe the card
  def swipe(transport_type, location = nil)
    
    # Check if the rider is allowed to ride this type of transportation
    unless $config['transport'][transport_type]['allowed_riders'].include? 'all' or $config['transport'][transport_type]['allowed_riders'].include? transport_type
      puts "Sorry, but you're not allowed on the #{transport_type.gsub('_',' ').upcase} because you are a #{@rider.type.upcase} rider."
      return false
    end
    @current_transport = transport_type
    @active = !@trip.nil? and (Time.now - @trip.start_time.to_time < ($config['oyster_card']['validity_period']))
    @location = location
    self.save

    puts "You are taking a trip on the #{@current_transport.gsub('_',' ').upcase}" if initiate_trip
    
    # Initiate a trip if the card is not currently active
#     unless active?
#       initiate_trip
#     else
#       make_transfer
#     end
  end

  private
    def pass_valid?
    
      # Check to see if this is a pass
      return false if @pass_type.nil?
      
      # Is it valid for the month
      if !(Time.now.year.to_s == @valid_year or Time.now.month.to_s == @valid_month)
        puts "Your pass is not current."
        return false
      end

      # Is it valid on this type of transport?
      unless transport_mode_ok?
        puts "You need a higher level pass to ride this (commuter rail > subway > bus > special_bus)"
        return false
      end
              
      true  
    end
    
    def transport_mode_ok?
      ordering = %w(special_bus bus  subway commuter_rail)
      case
        when @rider.type == 'employee'
          return true
        when ordering.index(@current_transport) <= ordering.index(@pass_type)
          return true
      end
      false    
    end

    def initiate_trip
      if pass_valid?
        ok = use_monthly_pass
      else
        ok = debit_balance
      end
      
      if ok
        @trip = Trip.new(transport_type: @current_transport)
        self.save
      else
        false
      end
    end

    def use_monthly_pass
      puts "You have used your valid pass for this trip"
      @active = true
    end

    def debit_balance
      fee = $fee_lookup[@rider['type']][@current_transport]['fee']

      # Check to see if there is enough money on the card
      if @balance <  fee 
        puts "You need to add money to your card for this trip. Buzz Buzz!"
        return false
      end

      # Debit the card and set it active
      @balance -= fee
      puts "Your remaining card balance is #{@balance.to_currency}"
      @active = true
    end

#     def make_transfer(new_transport_type)
#       unless pass_valid?
#         if self.trip.transfer_fee(new_transport_type) > self.balance
#           puts "You need to add money to your card for this transfer. Buzz Buzz!"
#           return false
#         else
#           self.balance -= self.trip.transfer_fee(new_transport_type) > self.balance
#         end
#       end
#       self.trip.leg = Leg.create(:type => new_transport_type)
#     end
end

class Trip
  include DataMapper::Resource
  include DataMapper::Validate
  
  #--Define------------------------
  property :id,                 Serial
  property :start_time,         DateTime
  property :oyster_card_id,     Integer
  property :current_transport,  String
  timestamps :at
  
  # Validations

  # Associations
  belongs_to  :oyster_card
  has n,      :legs

  attr_accessor :start_time, :oyster_card_id
  
  #-- Methods---------------------
  def initialize(attributes)
    @current_transport = attributes[:transport_type]
    @start_time = (attributes[:start_time].nil? ? Time.now : attributes[:start_time]).to_datetime
#    @leg = Leg.create(attributes[:transport_type])
    self.save
  end

#   def transfer_fee(new_transport_type)
#     if $config['transport'][new_transport_type]['fee'] > $config['transport'][self.leg.last.type]['fee']
#       $config['transport'][tt2]['fee'] > $config['transport'][tt2]['fee']
#     else
#       0.0
#     end 
#   end
  
  def legs?
    @legs.count
  end
end

class Leg
  include DataMapper::Resource
  include DataMapper::Validate
  
  #--Define------------------------
  property :id,               Serial
  property :transport_type,   String
  property :trip_id,          Integer
  property :start_point_id,   Integer
  property :end_point_id,     Integer
  timestamps :at
  
#   has 1, :start_point, :class => Location
#   has 1, :end_point, :class => Location

  belongs_to :trip

  attr_accessor :transport_type, :trip_id, :start_point_id, :end_point_id
  
  #-- Methods---------------------
  def initialize(attributes)
    @leg_type = attributes[:transport_type]
    self.save
  end
end

# class Location
#   include DataMapper::Resource
#   include DataMapper::Validate
# 
#   #--Define------------------------
#   property :id,         Serial
#   property :lat,        String
#   property :long,       String
#   property :zone,       Integer
# 
#   belongs_to :leg, :as => :start_point
#   belongs_to :leg, :as => :end_point
#   
#   attr_accessor :lat, :long, :zone
# end

# Auxiliary methods
class Float
  def to_currency
    "$#{sprintf('%.2f', self)}"
  end
end

class Time
  def weekend?
    self.saturday? or self.sunday?
  end
end

