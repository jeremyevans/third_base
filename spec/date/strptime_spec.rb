require(File.join(File.dirname(__FILE__), '..', 'date_spec_helper'))

describe "Date#stpftime" do
  it "should be able to parse the default date format" do
    Date.strptime("2000-04-06").should == Date.civil(2000, 4, 6)
    Date.civil(2000, 4, 6).strftime.should == Date.civil(2000, 4, 6).to_s
  end

  it "should be able to parse the full day name" do
    d = Date.today
    # strptime assumed week that start on sunday, not monday
    week = d.cweek
    week += 1 if d.cwday == 7
    Date.strptime("Thursday", "%A").should == Date.commercial(d.cwyear, week, 4)
  end

  it "should be able to parse the short day name" do
    d = Date.today
    # strptime assumed week that start on sunday, not monday
    week = d.cweek
    week += 1 if d.cwday == 7
    Date.strptime("Thu", "%a").should == Date.commercial(d.cwyear, week, 4)
  end

  it "should be able to parse the full month name" do
    d = Date.today
    Date.strptime("April", "%B").should == Date.civil(d.year, 4, 1)
  end

  it "should be able to parse the short month name" do
    d = Date.today
    Date.strptime("Apr", "%b").should == Date.civil(d.year, 4, 1)
    Date.strptime("Apr", "%h").should == Date.civil(d.year, 4, 1)
  end

  it "should be able to parse the century" do
    Date.strptime("06 20", "%y %C").should == Date.civil(2006, 1, 1)
  end

  it "should be able to parse the month day with leading zeroes" do
    d = Date.today
    Date.strptime("06", "%d").should == Date.civil(d.year, d.month, 6)
  end

  it "should be able to parse the month day with leading spaces" do
    d = Date.today
    Date.strptime(" 6", "%e").should == Date.civil(d.year, d.month, 6)
  end

  it "should be able to parse the commercial year with leading zeroes" do
    Date.strptime("2000", "%G").should == Date.civil(2000,  1,  3)
    Date.strptime("2002", "%G").should == Date.civil(2001, 12, 31)
  end

  it "should be able to parse the commercial year with only two digits" do
    Date.strptime("68", "%g").should == Date.civil(2068,  1,  2)
    Date.strptime("69", "%g").should == Date.civil(1968, 12, 30)
  end

  it "should be able to parse the year day with leading zeroes" do
    d = Date.today
    Date.strptime("050", "%j").should == Date.civil(2008, 2, 19)
  end

  it "should be able to parse the month with leading zeroes" do
    d = Date.today
    Date.strptime("04", "%m").should == Date.civil(d.year, 4, 1)
  end

  it "should be able to show the commercial day" do
    Date.strptime("1", "%u").should == Date.commercial(Date.today.year, Date.today.cweek, 1)
    Date.strptime("15 3", "%V %u").should == Date.commercial(Date.today.year, 15, 3)
  end

  it "should be able to show the commercial week" do
    d = Date.commercial(Date.today.year,1,1)
    Date.strptime("1", "%V").should == d
    Date.strptime("15", "%V").should == Date.commercial(d.cwyear, 15, 1)
  end

  it "should be able to show the year in YYYY format" do
    Date.strptime("2007", "%Y").should == Date.civil(2007, 1, 1)
  end

  it "should be able to show the year in YY format" do
    Date.strptime("00", "%y").should == Date.civil(2000, 1, 1)
  end
  
  it "should be able to parse escapes" do
    Date.strptime("00 % \n \t %1", "%y %% %n %t %1").should == Date.civil(2000, 1, 1)
  end

  ############################
  # Specs that combine stuff #
  ############################


  it "should be able to parse the date with slashes" do
    Date.strptime("04/06/00", "%D").should == Date.civil(2000, 4, 6)
    Date.strptime("04/06/00", "%m/%d/%y").should == Date.civil(2000, 4, 6)
  end

  it "should be able to parse the date as YYYY-MM-DD" do
    Date.strptime("2000-04-06", "%F").should == Date.civil(2000, 4, 6)
    Date.strptime("2000-04-06", "%Y-%m-%d").should == Date.civil(2000, 4, 6)
  end

  it "should be able to show the commercial week" do
    Date.strptime(" 9-Apr-2000", "%v").should == Date.civil(2000, 4, 9)
    Date.strptime(" 9-Apr-2000", "%e-%b-%Y").should == Date.civil(2000, 4, 9)
  end
  
  it "should be able to show MM/DD/YY" do
    Date.strptime("04/06/00", "%x").should == Date.civil(2000, 4, 6)
    Date.strptime("04/06/00", "%m/%d/%y").should == Date.civil(2000, 4, 6)
  end

end