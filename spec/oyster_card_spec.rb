require 'spec_helper'

describe OysterCard do 

  it "should be created with a pass_type of 'bus' as default if the amount is 0" do
    expect(build(:oyster_card).pass_type).to eq('bus')
  end

  [:valid_pass, :little_balance].each do |trait|    
    RIDER_OPTS.each do |rtype|
      it "should be created as a #{trait} for a #{rtype} rider" do
        expect(build(:oyster_card, rider_type: rtype).rider_type).to eq(rtype)
      end
    end
  end
    
  RIDER_OPTS.each do |rtype|
    it 'should raise an error for a #{rtype} when an invalid pass (transport) type is supplied' do  
      expect(build(:oyster_card, :pass_type => 'blarg', :rider_type => rtype)).not_to be_valid
    end
    
    it "should create a #{rtype} with zero balance if pass_type is missing" do
      expect(build(:oyster_card, rider_type: rtype).balance).to eq(0)
    end
  end
    
  TRANSPORT_OPTS.each do |ttype|
    it "should be created as a #{ttype} pass" do
      expect(build(:oyster_card, pass_type: ttype).pass_type).to eq(ttype)
    end
    it "should not be valid for a monthly pass when an invalid rider type is supplied" do  
      expect {create(:oyster_card, :bad_rider, pass_type: ttype) }.to raise_error(DataMapper::ValidationError)
    end 
  end
  
  it "should not create a card if rider_type is missing" do
    expect { create(:oyster_card, :rider_type => nil)  }.to raise_error(DataMapper::ValidationError)
  end  
end