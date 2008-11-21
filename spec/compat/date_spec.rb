require(File.join(File.dirname(__FILE__), '..', 'compat_spec_helper'))

describe Date do

  it "._strptime should be the same as strptime with a no default date" do
    Date._strptime('2008-10-11').should == Date.strptime('2008-10-11')
    Date._strptime('2008-10-11', '%Y-%m-%d').should == Date.strptime('2008-10-11', '%Y-%m-%d')
  end

  it ".civil should have defaults and an optional sg value" do
    Date.civil(2008, 1, 1, 1).should == Date.civil(2008, 1, 1)
    Date.civil.should == Date.civil(-4712, 1, 1)
  end

  it ".commercial should have defaults and an optional sg value" do
    Date.commercial(2008, 1, 1, 1).should == Date.commercial(2008, 1, 1)
    Date.commercial.should == Date.commercial(1582, 41, 5)
  end

  it ".jd should have defaults and an optional sg value" do
    Date.jd(2008, 1).should == Date.jd(2008)
    Date.jd.should == Date.jd(0)
  end

  it ".ordinal should have defaults and an optional sg value" do
    Date.ordinal(2008, 1, 1).should == Date.ordinal(2008, 1)
    Date.ordinal.should == Date.ordinal(-4712, 1)
  end

  it ".parse should have defaults and an optional sg value" do
    Date.parse('2008-10-11').should == Date.civil(2008, 10, 11)
    Date.parse('2008-10-11', true).should == Date.civil(2008, 10, 11)
    Date.parse('2008-10-11', true, 1).should == Date.civil(2008, 10, 11)
    Date.parse.should == Date.civil(-4712, 1, 1)
  end

  it ".strptime should have defaults and an optional sg value" do
    Date.strptime('2008-10-11').should == Date.civil(2008, 10, 11)
    Date.strptime('2008-10-11', '%Y-%m-%d').should == Date.civil(2008, 10, 11)
    Date.strptime('2008-10-11', '%Y-%m-%d', 1).should == Date.civil(2008, 10, 11)
    Date.strptime.should == Date.civil(-4712, 1, 1)
  end

  it ".today should have an optional sg value" do
    Date.today(1).should == Date.today
  end

  it "#asctime and #ctime should be a string with the date formatted" do
    Date.new(2008, 1, 1).asctime.should == 'Tue Jan  1 00:00:00 2008'
    Date.new(2008, 1, 1).ctime.should == 'Tue Jan  1 00:00:00 2008'
  end

  it "#day_fraction should be 0.0" do
    Date.new(2008, 1, 1).day_fraction.should == 0.0
  end
end
