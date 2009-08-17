require(File.join(File.dirname(__FILE__), '..', 'datetime_spec_helper'))

describe "DateTime#parse" do
  it "can't handle a empty string" do
    lambda{ DateTime.parse("") }.should raise_error(ArgumentError)
  end

  # Specs using numbers
  it "can't handle a single digit" do
    lambda{ DateTime.parse("1") }.should raise_error(ArgumentError)
  end

  it "can handle many different types of time values" do
    DateTime.parse("01:02:03").should == DateTime.civil(DateTime.today.year, DateTime.today.month, DateTime.today.day, 1, 2, 3)
    DateTime.parse("01:02:03a").should == DateTime.civil(DateTime.today.year, DateTime.today.month, DateTime.today.day, 1, 2, 3)
    DateTime.parse(" 1:02:03a").should == DateTime.civil(DateTime.today.year, DateTime.today.month, DateTime.today.day, 1, 2, 3)
    DateTime.parse("1:02:03a").should == DateTime.civil(DateTime.today.year, DateTime.today.month, DateTime.today.day, 1, 2, 3)
    DateTime.parse("01:02:03am").should == DateTime.civil(DateTime.today.year, DateTime.today.month, DateTime.today.day, 1, 2, 3)
    DateTime.parse("01:02:03p").should == DateTime.civil(DateTime.today.year, DateTime.today.month, DateTime.today.day, 13, 2, 3)
    DateTime.parse("01:02:03pm").should == DateTime.civil(DateTime.today.year, DateTime.today.month, DateTime.today.day, 13, 2, 3)
    DateTime.parse("12:02:03am").should == DateTime.civil(DateTime.today.year, DateTime.today.month, DateTime.today.day, 0, 2, 3)
    DateTime.parse("12:02:03p").should == DateTime.civil(DateTime.today.year, DateTime.today.month, DateTime.today.day, 12, 2, 3)
    proc{DateTime.parse("13:02:03p")}.should raise_error(ArgumentError)
    proc{DateTime.parse("00:02:03p")}.should raise_error(ArgumentError)
    proc{DateTime.parse("00:02:03rsdf")}.should raise_error(ArgumentError)
  end

  it "should use the current time offset if no time offset is specified" do
    DateTime.parse("01:02:03").should == DateTime.civil(DateTime.today.year, DateTime.today.month, DateTime.today.day, 1, 2, 3, 0, Time.now.utc_offset)
    DateTime.parse("01:02:03Z").should == DateTime.civil(DateTime.today.year, DateTime.today.month, DateTime.today.day, 1, 2, 3, 0, 0)
    DateTime.parse("01:02:03+0100").should == DateTime.civil(DateTime.today.year, DateTime.today.month, DateTime.today.day, 1, 2, 3, 0, 3600)
    DateTime.parse("01:02:03-01:00").should == DateTime.civil(DateTime.today.year, DateTime.today.month, DateTime.today.day, 1, 2, 3, 0, -3600)
    DateTime.parse("01:02:03+01").should == DateTime.civil(DateTime.today.year, DateTime.today.month, DateTime.today.day, 1, 2, 3, 0, 3600)
    DateTime.parse("01:02:03-01").should == DateTime.civil(DateTime.today.year, DateTime.today.month, DateTime.today.day, 1, 2, 3, 0, -3600)
  end

  it "should parse the time zone abbreviations supported by ruby's Time class" do
    DateTime.parse("01:02:03 UTC").offset.should == 0
    DateTime.parse("01:02:03 UT").offset.should == 0
    DateTime.parse("01:02:03 GMT").offset.should == 0
    DateTime.parse("01:02:03 EST").offset.should == -5*3600
    DateTime.parse("01:02:03 EDT").offset.should == -4*3600
    DateTime.parse("01:02:03 CST").offset.should == -6*3600
    DateTime.parse("01:02:03 CDT").offset.should == -5*3600
    DateTime.parse("01:02:03 MST").offset.should == -7*3600
    DateTime.parse("01:02:03 MDT").offset.should == -6*3600
    DateTime.parse("01:02:03 PST").offset.should == -8*3600
    DateTime.parse("01:02:03 PDT").offset.should == -7*3600
    DateTime.parse("01:02:03 A").offset.should == 1*3600
    DateTime.parse("01:02:03 B").offset.should == 2*3600
    DateTime.parse("01:02:03 C").offset.should == 3*3600
    DateTime.parse("01:02:03 D").offset.should == 4*3600
    DateTime.parse("01:02:03 E").offset.should == 5*3600
    DateTime.parse("01:02:03 F").offset.should == 6*3600
    DateTime.parse("01:02:03 G").offset.should == 7*3600
    DateTime.parse("01:02:03 H").offset.should == 8*3600
    DateTime.parse("01:02:03 I").offset.should == 9*3600
    DateTime.parse("01:02:03 K").offset.should == 10*3600
    DateTime.parse("01:02:03 L").offset.should == 11*3600
    DateTime.parse("01:02:03 M").offset.should == 12*3600
    DateTime.parse("01:02:03 N").offset.should == -1*3600
    DateTime.parse("01:02:03 O").offset.should == -2*3600
    DateTime.parse("01:02:03 P").offset.should == -3*3600
    DateTime.parse("01:02:03 Q").offset.should == -4*3600
    DateTime.parse("01:02:03 R").offset.should == -5*3600
    DateTime.parse("01:02:03 S").offset.should == -6*3600
    DateTime.parse("01:02:03 T").offset.should == -7*3600
    DateTime.parse("01:02:03 U").offset.should == -8*3600
    DateTime.parse("01:02:03 V").offset.should == -9*3600
    DateTime.parse("01:02:03 W").offset.should == -10*3600
    DateTime.parse("01:02:03 X").offset.should == -11*3600
    DateTime.parse("01:02:03 Y").offset.should == -12*3600
    DateTime.parse("01:02:03 Z").offset.should == 0
  end

  it "should parse the time strings output by ruby's Time class" do
    proc{DateTime.parse(Time.now.to_s)}.should_not raise_error
    proc{DateTime.parse(Time.now.strftime('%+'))}.should_not raise_error
  end

  it "can handle DD as month day number" do
    DateTime.parse("10").should == DateTime.civil(DateTime.today.year, DateTime.today.month, 10)
    DateTime.parse("10 01:02:03").should == DateTime.civil(DateTime.today.year, DateTime.today.month, 10, 1, 2, 3)
  end

  it "can handle DDD as year day number" do
    DateTime.parse("050").should == DateTime.civil(DateTime.today.year, 2, 19)
    DateTime.parse("050 1:02:03").should == DateTime.civil(DateTime.today.year, 2, 19, 1, 2, 3)
  end

  it "can handle MMDD as month and day" do
    DateTime.parse("1108").should == DateTime.civil(DateTime.today.year, 11, 8)
    DateTime.parse("1108 10:02:03").should == DateTime.civil(DateTime.today.year, 11, 8, 10, 2, 3)
  end

  it "can handle YYDDD as year and day number" do
    DateTime.parse("10100").should == DateTime.civil(2010, 4, 10)
    DateTime.parse("10100 23:02:03").should == DateTime.civil(2010, 4, 10, 23, 2, 3)
  end

  it "can handle YYMMDD as year month and day" do
    DateTime.parse("201023").should == DateTime.civil(2020, 10, 23)
    DateTime.parse("201023 23:02:03 +0800").should == DateTime.civil(2020, 10, 23, 23, 2, 3, 0, 28800)
  end

  it "can handle YYYYDDD as year and day number" do
    DateTime.parse("1910100").should == DateTime.civil(1910, 4, 10)
    DateTime.parse("1910100 23:02:03 -0101").should == DateTime.civil(1910, 4, 10, 23, 2, 3, 0, -3660)
  end

  it "can handle YYYYMMDD as year and day number" do
    DateTime.parse("19101101").should == DateTime.civil(1910, 11, 1)
    DateTime.parse("19101101T23:02:03 +0000").should == DateTime.civil(1910, 11, 1, 23, 2, 3)
  end
end

describe :date_parse, :shared => true do
  it "can parse a mmm-YYYY string into a DateTime object" do
    d = DateTime.parse("feb#{@sep}2008")
    d.year.should  == 2008
    d.month.should == 2
    d.day.should   == 1
    
    d = DateTime.parse("feb#{@sep}2008  1:02:03")
    d.year.should  == 2008
    d.month.should == 2
    d.day.should   == 1
    d.hour.should  == 1
    d.min.should   == 2
    d.sec.should   == 3
  end

  it "can parse a 'DD mmm YYYY' string into a DateTime object" do
    d = DateTime.parse("23#{@sep}feb#{@sep}2008")
    d.year.should  == 2008
    d.month.should == 2
    d.day.should   == 23
    
    d = DateTime.parse("23#{@sep}feb#{@sep}2008 11:02:03")
    d.year.should  == 2008
    d.month.should == 2
    d.day.should   == 23
    d.hour.should  == 11
    d.min.should   == 2
    d.sec.should   == 3
  end

  it "can parse a 'mmm DD YYYY' string into a DateTime object" do
    d = DateTime.parse("feb#{@sep}23#{@sep}2008")
    d.year.should  == 2008
    d.month.should == 2
    d.day.should   == 23
    
    d = DateTime.parse("feb#{@sep}23#{@sep}2008 01:02:03")
    d.year.should  == 2008
    d.month.should == 2
    d.day.should   == 23
    d.hour.should  == 1
    d.min.should   == 2
    d.sec.should   == 3
  end

  it "can parse a 'YYYY mmm DD' string into a DateTime object" do
    d = DateTime.parse("2008#{@sep}feb#{@sep}23")
    d.year.should  == 2008
    d.month.should == 2
    d.day.should   == 23
    
    d = DateTime.parse("2008#{@sep}feb#{@sep}23 01:02")
    d.year.should  == 2008
    d.month.should == 2
    d.day.should   == 23
    d.hour.should  == 1
    d.min.should   == 2
    d.sec.should   == 0
  end

  it "can parse a month name and day into a Date object" do
    DateTime.parse("november#{@sep}5th").should == DateTime.civil(Date.today.year, 11, 5)
    DateTime.parse("november#{@sep}5th 1:02").should == DateTime.civil(Date.today.year, 11, 5, 1, 2)
  end

  it "can parse a month name, day and year into a Date object" do
    DateTime.parse("november#{@sep}5th#{@sep}2005").should == DateTime.civil(2005, 11, 5)
    DateTime.parse("november#{@sep}5th#{@sep}2005  1:02").should == DateTime.civil(2005, 11, 5, 1, 2)
  end

  it "can parse a year, month name and day into a Date object" do
    DateTime.parse("2005#{@sep}november#{@sep}5th").should == DateTime.civil(2005, 11, 5)
    DateTime.parse("2005#{@sep}november#{@sep}5th 01:02 +0100").should == DateTime.civil(2005, 11, 5, 1, 2, 0, 0, 3600)
  end

  it "can parse a year, day and month name into a Date object" do
    DateTime.parse("5th#{@sep}november#{@sep}2005").should == DateTime.civil(2005, 11, 5)
    DateTime.parse("5th#{@sep}november#{@sep}2005  1:02 -0100").should == DateTime.civil(2005, 11, 5, 1, 2, 0, 0, -3600)
  end

  it "can handle negative year numbers" do
    DateTime.parse("5th#{@sep}november#{@sep}-2005").should == DateTime.civil(-2005, 11, 5)
    DateTime.parse("5th#{@sep}november#{@sep}-2005 1:02 -0100").should == DateTime.civil(-2005, 11, 5, 1, 2, 0, 0, -3600)
  end
end

describe :date_parse_us, :shared => true do
  it "parses a YYYY#{@sep}MM#{@sep}DD string into a DateTime object" do
    d = DateTime.parse("2007#{@sep}10#{@sep}01")
    d.year.should  == 2007
    d.month.should == 10
    d.day.should   == 1
    
    d = DateTime.parse("2007#{@sep}10#{@sep}01 01:02:03")
    d.year.should  == 2007
    d.month.should == 10
    d.day.should   == 1
    d.hour.should  == 1
    d.min.should   == 2
    d.sec.should   == 3
  end

  it "parses a MM#{@sep}DD#{@sep}YYYY string into a DateTime object" do
    d = DateTime.parse("10#{@sep}01#{@sep}2007")
    d.year.should  == 2007
    d.month.should == 10
    d.day.should   == 1
    
    
    d = DateTime.parse("10#{@sep}01#{@sep}2007 01:02:03")
    d.year.should  == 2007
    d.month.should == 10
    d.day.should   == 1
    d.hour.should  == 1
    d.min.should   == 2
    d.sec.should   == 3
  end

  it "parses a MM#{@sep}DD#{@sep}YY string into a DateTime object using the year digits as 20XX" do
    d = DateTime.parse("10#{@sep}01#{@sep}07")
    d.year.should  == 2007
    d.month.should == 10
    d.day.should   == 1
    
    d = DateTime.parse("10#{@sep}01#{@sep}97 01:02:03 Z")
    d.year.should  == 1997
    d.month.should == 10
    d.day.should   == 1
    d.hour.should  == 1
    d.min.should   == 2
    d.sec.should   == 3
  end
end

describe :date_parse_eu, :shared => true do
  before do
    DateTime.use_parsers(:iso, :eu)
  end
  after do
    DateTime.reset_parsers!
  end
  
  # The - separator let's it work like European format, so it as a different spec
  it "can parse a YYYY-MM-DD string into a DateTime object" do
    d = DateTime.parse("2007#{@sep}10#{@sep}01")
    d.year.should  == 2007
    d.month.should == 10
    d.day.should   == 1
    
    d = DateTime.parse("2007#{@sep}10#{@sep}01 01:02:03Z")
    d.year.should  == 2007
    d.month.should == 10
    d.day.should   == 1
    d.hour.should  == 1
    d.min.should   == 2
    d.sec.should   == 3
  end

  it "can parse a DD-MM-YYYY string into a DateTime object" do
    d = DateTime.parse("10#{@sep}01#{@sep}2007")
    d.year.should  == 2007
    d.month.should == 1
    d.day.should   == 10
    
    d = DateTime.parse("10#{@sep}01#{@sep}2007 01:02:03-01:00")
    d.year.should  == 2007
    d.month.should == 1
    d.day.should   == 10
    d.hour.should  == 1
    d.min.should   == 2
    d.sec.should   == 3
    d.offset.should == -3600
  end

  it "can parse a YY-MM-DD string into a DateTime object" do
    d = DateTime.parse("10#{@sep}01#{@sep}07")
    d.year.should  == 2010
    d.month.should == 1
    d.day.should   == 7
    
    d = DateTime.parse("97#{@sep}01#{@sep}07 01:02:03+01:00")
    d.year.should  == 1997
    d.month.should == 1
    d.day.should   == 7
    d.hour.should  == 1
    d.min.should   == 2
    d.sec.should   == 3
    d.offset.should == 3600
  end
end


describe "DateTime#parse with '.' separator" do
  before :all do
    @sep = '.'
  end

  it_should_behave_like "date_parse"
end

describe "DateTime#parse with '/' separator" do
  before :all do
    @sep = '/'
  end

  it_should_behave_like "date_parse"
end

describe "DateTime#parse with ' ' separator" do
  before :all do
    @sep = ' '
  end

  it_should_behave_like "date_parse"
end

describe "DateTime#parse with '/' separator US-style" do
  before :all do
    @sep = '/'
  end

  it_should_behave_like "date_parse_us"
end

ruby_version_is "" ... "1.8.7" do
  describe "DateTime#parse with '.' separator US-style" do
    before :all do
      @sep = '.'
    end

    it_should_behave_like "date_parse_us"
  end
end

describe "DateTime#parse with '-' separator EU-style" do
  before :all do
    @sep = '-'
  end

  it_should_behave_like "date_parse_eu"
end

describe "DateTime parser modifications" do
  after do
    DateTime.reset_parsers!
  end
  
  it "should raise an ArgumentError if it can't parse a date" do
    proc{DateTime.parse("today")}.should raise_error(ArgumentError)
  end

  it "should be able to add a parser to an existing parser type that takes precedence" do
    d = DateTime.now
    DateTime.add_parser(:iso, /\Anow\z/){{:civil=>[d.year, d.mon, d.day], :parts=>[d.hour, d.min, d.sec, d.usec], :offset=>d.offset}}
    DateTime.parse("now").should == d
  end
  
  it "should be able to handle parsers that return Date instances" do
    d = DateTime.now
    DateTime.add_parser(:iso, /\Anow\z/){d}
    DateTime.parse("now").should == d
  end
  
  it "should be able to specify a strptime format string for a parser" do
    DateTime.add_parser(:iso, "%Z||%S>>%M>>%H||%d<<%m<<%Y")
    DateTime.parse("UTC||06>>05>>04||03<<02<<2001").should == DateTime.new(2001,2,3,4,5,6)
  end

  it "should assume current seconds if just offset is given" do
    DateTime.add_parser_type(:mine)
    DateTime.use_parsers(:mine)
    DateTime.add_parser(:mine, "%Z")
    DateTime.parse("UTC").sec.should == DateTime.now.sec
  end

  it "should be able to add new parser types" do
    DateTime.add_parser_type(:mine)
    d = DateTime.now
    DateTime.add_parser(:mine, /\Anow\z/){{:civil=>[d.year, d.mon, d.day], :parts=>[d.hour, d.min, d.sec, d.usec], :offset=>d.offset}}
    proc{DateTime.parse("now")}.should raise_error(ArgumentError)
    DateTime.parse("now", :parser_types=>[:mine]).should == d
    DateTime.use_parsers(:mine)
    DateTime.parse("now").should == d
  end
end
