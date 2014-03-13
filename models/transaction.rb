class Transaction
  include ::DataMapper::Resource
  include ::DataMapper::Validate

  #--Define------------------------
  property :id,               Serial
  property :transaction_type, String
  property :transport_type,   String
  property :fee,              Float
  property :mode,             String
  property :authorized,       Boolean, :default => false

  timestamps :at

  # Associations
  belongs_to :oyster_card
  
  # Validations--------------------
  validates_within :transport_type,   :set => $config['transport'].keys, :unless => lambda { |res| res.transport_type.nil? }
  validates_within :transaction_type, :set => ['buy_pass', 'add_value_to_card', 'take_trip']
  validates_within :mode,             :set => ['pass', 'debit_card']
  
  
  attr_accessor :fee, :transaction_type, :transport_type, :mode
  
  def initialize(attributes = {})
    @transaction_type = attributes[:transaction_type]
    @transport_type   = attributes[:transport_type]
    @fee              = attributes[:fee]
    @mode             = attributes[:mode]
    @authorized       = false
  end
  
  def authorized?
    case @transaction_type
      when 'buy_pass'
        if FundAuthorization.authorize(fee)
          @authorized = true
          self.save
          return true
        end
      when 'take_trip'      
        case @mode
          when 'pass'
            @authorized = true
            self.save
            return true
          when 'debit_card'
            if FundAuthorization(@fee)
              @authorized = true
              self.save
              return true
            end
        end
      when 'add_value_to_card'
        if FundAuthorization.authorize(@fee)
          @authorized = true
          self.save
          return true
        end
    end 
    false
  end
end
