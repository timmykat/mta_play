FactoryGirl.define do
  to_create { |instance| instance.save }
      
  factory :oyster_card do
    rider_type    'regular'
    pass_type     'bus'
    
    trait :bad_rider do
      rider_type    'blarg'
    end
  
    trait :valid_pass do
      month_valid   Time.now.month
      year_valid    Time.now.year
    end
    
    trait :big_balance do
      pass_type     nil
      balance       50.00
    end
    
    trait :little_balance do
      pass_type     nil
      balance       0.10
    end
  end
    
  factory :swipe do
    oyster_card
    transport_type 'bus'
    initialize_with { new(oyster_card, transport_type) }  
  end
end