require 'spec_helper'

describe Rider do
  before(:all) { silence_output }
  after(:all)  { enable_output }
  
  it 'should create a rider' do
    expect(Rider.new.class).to eq(Rider)
  end
  
  it "should purchase a card" do
    rider = Rider.create
    expect(rider.purchase_card(:rider_type => 'regular', :pass_type => 'bus').class).to eq(OysterCard)
  end  
    
  RIDER_OPTS.each do |rtype|
    it "should purchase a card for a #{rtype.gsub('_', '')}" do
      rider = Rider.create
      expect(rider.purchase_card(:rider_type => rtype, :pass_type => 'bus').rider_type).to eq(rtype)
    end
  end
  
  TRANSPORT_OPTS_WITH_SPECIAL.each do |ttype|
    it "should purchase apass for the #{ttype.gsub('_', '')}" do
      rider = Rider.create
      expect(rider.purchase_card(:rider_type => 'regular', :pass_type => ttype).pass_type).to eq(ttype)
    end
  end

  it "should purchase a card with a specified amount" do
    rider = Rider.create
    oc = rider.purchase_card(:amount => 34.00)
    expect(oc.balance).to eq(34.00)
  end
end
