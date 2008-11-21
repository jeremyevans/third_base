require(File.join(File.dirname(__FILE__), '..', 'datetime_spec_helper'))

describe "DateTime.now" do
  it "should be right now as a DateTime" do
    t = Time.now
    d = DateTime.now
    d.year.should == t.year
    d.mon.should == t.mon
    d.day.should == t.day
    d.hour.should == t.hour
    d.min.should == t.min
    d.sec.should == t.sec
  end
end