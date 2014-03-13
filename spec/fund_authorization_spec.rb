require 'spec_helper'

describe FundAuthorization do
  
  it "should return true if fee < $500" do
    expect(FundAuthorization.authorize(20.00)).to be_true
  end

  it "should return false if the fee > $500" do
    expect(FundAuthorization.authorize(600.00)).to be_false
  end

  it "should false if fee < 0" do
    expect(FundAuthorization.authorize(-50.00)).to be_false
  end
end
