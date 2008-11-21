require(File.join(File.dirname(__FILE__), '..', 'date_spec_helper'))

describe "Date#<<" do

  it "should substract a number of months from a date" do
    (Date.civil(2007, 12, 27) << 10).should == Date.civil(2007,2,27)
    (Date.commercial(2007, 45, 5) << 10).should == Date.commercial(2007,2,2)
    (Date.jd(2455086) << 10).should == Date.jd(2454782)
    (Date.ordinal(2008, 315) << 10).should == Date.ordinal(2008, 10)
    (Date.civil(2007, 12, 27) << 12).should == Date.civil(2006,12,27)
    (Date.civil(2007, 12, 27) << -12).should == Date.civil(2008,12,27)
  end

  it "should result in the last day of a month if the day doesn't exist" do
    d = Date.civil(2008,3,31) << 1
    d.should == Date.civil(2008, 2, 29)
  end

  it "should raise an error on non numeric parameters" do
    lambda { Date.civil(2007,2,27) << :hello }.should raise_error(NoMethodError)
    lambda { Date.civil(2007,2,27) << "hello" }.should raise_error(NoMethodError)
    lambda { Date.civil(2007,2,27) << Date.new(2007,10,27) }.should raise_error(NoMethodError)
    lambda { Date.civil(2007,2,27) << Object.new }.should raise_error(NoMethodError)
  end
  
end
