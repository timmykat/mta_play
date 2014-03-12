require 'spec_helper'

describe OysterCard do  
  before(:each) do
    @rider = Rider.create
  end

  before(:all) { silence_output }
  after(:all)  { enable_output }
  
  it "should be created with a 'regular' @rider as default" do
    oc = @rider.oyster_cards.new
    expect(oc.rider_type).to eq('regular')
  end
  
  it "should be created with a pass_type of 'bus' as default if the amount is 0" do
    oc = @rider.oyster_cards.new
    expect(oc.pass_type).to eq('bus')
  end

  RIDER_OPTS.each do |rtype|
    it "should be created for a #{rtype} @rider" do
      oc = @rider.oyster_cards.new(rider_type: rtype)
      expect(oc.rider_type).to eq(rtype)
    end
  end

  TRANSPORT_OPTS.each do |ttype|
    it "should be created as a #{ttype} pas" do
      oc = @rider.oyster_cards.new(pass_type: ttype)
      expect(oc.pass_type).to eq(ttype)
    end
  end
    
  it 'should raise an error when an invalid rider type is supplied' do  
    expect { @rider.oyster_cards.create(rider_type: 'blarg') }.to raise_error
  end 
    
  it 'should raise an error when an invalid pass (transport) type is supplied' do  
    expect { @rider.oyster_cards.create(pass_type: 'blarg') }.to raise_error
  end
  
  it 'should create a card with a zero balance' do
    oc = @rider.oyster_cards.new
    expect(oc.balance).to eq(0)
  end
  
  it "should not create a card if pass_type is missing" do
    expect { @rider.oyster_cards.create(rider_type: 'regular') }.to raise_error
  end
  
  it "should not create a card if rider_type is missing" do
    expect { @rider.oyster_cards.create(pass_type: 'bus')  }.to raise_error
  end
  
  TRANSPORT_OPTS_WITH_SPECIAL.each do |ttype|
    it "should be swipeable as a pass (#{ttype})" do
      oc = @rider.purchase_card(pass_type: ttype)
      expect(oc.swipe(ttype).class).to eq(Trip)
    end
  end
  
  TRANSPORT_OPTS.each do |ttype|
    allowed = TRANSPORT_OPTS.slice(TRANSPORT_OPTS.index(ttype)..TRANSPORT_OPTS.length-1)
    allowed.each do |a|
      it "should allow a rider with a #{ttype} pass on the #{a}" do
        oc = @rider.purchase_card(pass_type: ttype)
        expect(oc.swipe(ttype).class).to eq(Trip)
      end
    end
    disallowed = TRANSPORT_OPTS.slice(0..TRANSPORT_OPTS.index(ttype)-1)
    disallowed.each do |d|
      it "should not allow a rider with a #{ttype} pass on the #{d}" do
        oc = @rider.purchase_card(pass_type: ttype)
        expect(oc.swipe(ttype)).to be_false
      end
    end
  end  
end