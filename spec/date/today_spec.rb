require(File.join(File.dirname(__FILE__), '..', 'date_spec_helper'))

describe "Date.today" do
  it "should be today's date" do
    t = Time.now
    d = Date.today
    d.year.should == t.year
    d.mon.should == t.mon
    d.day.should == t.day
  end
end