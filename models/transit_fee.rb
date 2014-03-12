class TransitFee
  # Fee lookup
  @@fee_lookup = {}
  $config['rider'].each do |k, v|
    @@fee_lookup[k] = {}
    $config['transport'].each do |kk, vv|
      @@fee_lookup[k][kk] = {
        'pass' => v['discount'].to_f * vv['pass'].to_f,
        'fee'  => v['discount'].to_f * vv['fee'].to_f
      }
    end
  end

  def self.calculate_ride(rider_type, transport_type)
    prorate_ride(@@fee_lookup[rider_type][transport_type]['fee'])
  end

  def self.prorate_ride(amount)
    Time.now.weekend? ? ($config['prorate']['per_ride']['weekend'] * amount) : amount
  end  

  def self.calculate_pass(rider_type, transport_type)
    prorate_pass(@@fee_lookup[rider_type][transport_type]['pass'])
  end

  def self.prorate_pass(amount)
    today = Time.now.day
    amount * $config['prorate']['pass'].inject(1) { |prorate, d|  (today > d['day'].to_i) ? d['amount'] : prorate }
  end  
end
