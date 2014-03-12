class Trip
  include ::DataMapper::Resource
  include ::DataMapper::Validate
  
  #--Define------------------------
  property :id,                 Serial
  property :start_time,         DateTime
  property :current_transport,  String
  timestamps :at
  
  # Validations

  # Associations
  belongs_to  :oyster_card

  attr_accessor :start_time, :current_transport
  
  #-- Methods---------------------
  def initialize(attributes)
    @current_transport = attributes[:transport_type]
    @start_time = (attributes[:start_time].nil? ? Time.now : attributes[:start_time]).to_datetime
  end

end
