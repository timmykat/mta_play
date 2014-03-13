require 'spec_helper'

describe Swipe do
  # Test special bus separately
  TRANSPORT_OPTS.each do |ttype|
    allowed = TRANSPORT_OPTS.slice(0..TRANSPORT_OPTS.index(ttype))
    allowed.each do |a|
      it "should allow a rider with a #{a} pass on the #{ttype}" do
        oc = create(:oyster_card, :little_balance, :pass_type => ttype)
        swipe = build(:swipe, :oyster_card => oc, :transport_type => a)
        expect(swipe.transport_valid?).to be_true
      end
    end
    disallowed = TRANSPORT_OPTS.slice(TRANSPORT_OPTS.index(ttype)+1..TRANSPORT_OPTS.length-1)
    disallowed.each do |d|
      it "should not allow a rider with a #{d} pass on the #{ttype}" do
        oc = create(:oyster_card, :little_balance, :pass_type => ttype)
        swipe = build(:swipe, :oyster_card => oc, :transport_type => d)
        expect(swipe.transport_valid?).to be_false
      end
    end
  end
end  

