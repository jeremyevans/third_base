require(File.join(File.dirname(__FILE__), '..', 'datetime_spec_helper'))

describe "DateTime#fract" do
  it "should be able to determine the fraction of a day" do
    DateTime.jd_fract(2007).fract.should be_close(0.0, 0.000000001)
    DateTime.jd_fract(2007, 0.5).fract.should be_close(0.5, 0.000000001)
    DateTime.jd(2007, 12).fract.should be_close(0.5, 0.000000001)
  end
end

describe "DateTime#hour" do
  it "should be able to determine the hour of the day" do
    DateTime.jd(2007, 1).hour.should == 1
    DateTime.jd_fract(2007, 0.5).hour.should == 12
  end
end

describe "DateTime#min" do
  it "should be able to determine the minute of the day" do
    DateTime.jd(2007, 1, 2).min.should == 2
    DateTime.jd_fract(2007, 0.021).min.should == 30
  end
end

describe "DateTime#offset and #utc_offset" do
  it "should be able to determine the offset of the day from UTC" do
    DateTime.jd(2007, 1, 2, 3, 4, 6).offset.should == 6
    DateTime.jd_fract(2007, 1.15740740740741e-006, 10).offset.should == 10
    DateTime.jd(2007, 1, 2, 3, 4, 6).utc_offset.should == 6
    DateTime.jd_fract(2007, 1.15740740740741e-006, 10).utc_offset.should == 10
  end 
end

describe "DateTime#sec" do
  it "should be able to determine the second of the day" do
    DateTime.jd(2007, 1, 2, 3).sec.should == 3
    DateTime.jd_fract(2007, 0.00035).sec.should == 30
  end 
end

describe "DateTime#usec" do
  it "should be able to determine the millisecond of the day" do
    DateTime.jd(2007, 1, 2, 3, 4).usec.should == 4
    DateTime.jd_fract(2007, 0.000001158).usec.should == 100051
  end 
end

describe "DateTime#zone" do
  it "should give the offset as a string" do
    DateTime.jd(0).zone.should == '+00:00'
    DateTime.jd(2007, 0, 0, 0, 0, -3600).zone.should == '-01:00'
  end 
end