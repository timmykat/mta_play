require 'spec_helper'

describe Rider do
  it 'should create a regular rider as default' do
    expect(Rider.new.type).to eq('regular')
  end
  
  %w(student elderly employee).each do |rtype|
    it "should create a #{rtype} rider" do
      expect(Rider.new(type: rtype).type).to eq(rtype)
    end
  end
    
  it 'should not create a rider when an invalid type is supplied' do
    expect { Rider.new(type: 'blarg') }.to raise_error
  end 
end

describe OysterCard do
  before(:each) do
    r = Rider.new      # Creates a regular rider
    @oyster_card = r.oyster_card.
  end
  
  
end