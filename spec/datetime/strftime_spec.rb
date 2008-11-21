require(File.join(File.dirname(__FILE__), '..', 'datetime_spec_helper'))

describe "DateTime#strftime" do

  it "should be able to print the date time" do
    DateTime.civil(2000, 4, 6, 10, 11, 12).strftime.should == "2000-04-06T10:11:12+00:00"
    DateTime.civil(2000, 4, 6, 10, 11, 12).strftime.should == DateTime.civil(2000, 4, 6, 10, 11, 12).to_s
  end

  it "should be able to print the hour in a 24 hour clock with leading zero" do
    DateTime.civil(2000, 4, 6, 10, 11, 12).strftime('%H').should == "10"
    DateTime.civil(2000, 4, 6, 13, 11, 12).strftime('%H').should == "13"
  end

  it "should be able to print the hour in a 12 hour clock with leading zero" do
    DateTime.civil(2000, 4, 6, 10, 11, 12).strftime('%I').should == "10"
    DateTime.civil(2000, 4, 6, 13, 11, 12).strftime('%I').should == "01"
  end
  
  it "should be able to print the hour in a 24 hour clock with leading space" do
    DateTime.civil(2000, 4, 6, 9, 11, 12).strftime('%k').should == " 9"
    DateTime.civil(2000, 4, 6, 13, 11, 12).strftime('%k').should == "13"
  end

  it "should be able to print the hour in a 12 hour clock with leading space" do
    DateTime.civil(2000, 4, 6, 10, 11, 12).strftime('%l').should == "10"
    DateTime.civil(2000, 4, 6, 13, 11, 12).strftime('%l').should == " 1"
  end
  
  it "should be able to print the minute with leading zero" do
    DateTime.civil(2000, 4, 6, 10, 11, 12).strftime('%M').should == "11"
    DateTime.civil(2000, 4, 6, 10, 14, 12).strftime('%M').should == "14"
  end
  
  it "should be able to print the meridian indicator in lower case" do
    DateTime.civil(2000, 4, 6, 10, 11, 12).strftime('%P').should == "am"
    DateTime.civil(2000, 4, 6, 13, 11, 12).strftime('%P').should == "pm"
  end
  
  it "should be able to print the meridian indicator in upper case" do
    DateTime.civil(2000, 4, 6, 10, 11, 12).strftime('%p').should == "AM"
    DateTime.civil(2000, 4, 6, 13, 11, 12).strftime('%p').should == "PM"
  end
  
  it "should be able to print the second with leading zero" do
    DateTime.civil(2000, 4, 6, 10, 11, 12).strftime('%S').should == "12"
    DateTime.civil(2000, 4, 6, 10, 11, 13).strftime('%S').should == "13"
  end
  
  it "should be able to print the number of seconds since the unix epoch" do
    DateTime.civil(2008, 11, 12, 14, 3, 30, 0, -28800).strftime('%s').should == "1226527410"
    DateTime.civil(2008, 11, 12, 14, 3, 31, 0, -28800).strftime('%s').should == "1226527411"
  end
  
  it "should be able to print the time zone offset as a Z if the offset is zero" do
    DateTime.civil(2000, 4, 6, 10, 11, 12).strftime('%Z').should == "Z"
    DateTime.civil(2000, 4, 6, 10, 11, 12, 0, -43200).strftime('%Z').should == "-12:00"
  end
  
  it "should be able to print the time zone offset as a string of hours and minutes" do
    DateTime.civil(2000, 4, 6, 10, 11, 12).strftime('%z').should == "+00:00"
    DateTime.civil(2000, 4, 6, 10, 11, 12, 0, -43200).strftime('%z').should == "-12:00"
    DateTime.civil(2000, 4, 6, 10, 11, 12, 0, 43200).strftime('%z').should == "+12:00"
    DateTime.civil(2000, 4, 6, 10, 11, 12, 0, -3600).strftime('%z').should == "-01:00"
    DateTime.civil(2000, 4, 6, 10, 11, 12, 0, 3600).strftime('%z').should == "+01:00"
  end
  
  ############################
  # Specs that combine stuff #
  ############################

  it "should be able to print the common date" do
    DateTime.civil(2000, 4, 6, 10, 11, 12).strftime("%c").should == "Thu Apr  6 10:11:12 2000"
    DateTime.civil(2000, 4, 6, 10, 11, 12).strftime("%c").should == DateTime.civil(2000, 4, 6, 10, 11, 12).strftime('%a %b %e %H:%M:%S %Y')  
  end

  it "should be able to print the hour and minute" do
    DateTime.civil(2000, 4, 6, 10, 11, 12).strftime("%R").should == "10:11"
    DateTime.civil(2000, 4, 6, 10, 11, 12).strftime("%R").should == DateTime.civil(2000, 4, 6, 10, 11, 12).strftime('%H:%M')
  end

  it "should be able to show the hour, minute, second, and am/pm flag" do
    DateTime.civil(2000, 4,  9, 10, 11, 12).strftime("%r").should == "10:11:12 AM"
    DateTime.civil(2000, 4,  9, 13, 11, 12).strftime("%r").should == "01:11:12 PM"
    DateTime.civil(2000, 4,  9, 10, 11, 12).strftime("%r").should == DateTime.civil(2000, 4,  9, 10, 11, 12).strftime('%I:%M:%S %p')
  end

  it "should be able to show the hour, minute, and second" do
    DateTime.civil(2000, 4,  9, 10, 11, 12).strftime("%T").should == "10:11:12"
    DateTime.civil(2000, 4,  9, 13, 11, 12).strftime("%T").should == "13:11:12"
    DateTime.civil(2000, 4,  9, 10, 11, 12).strftime("%T").should == DateTime.civil(2000, 4,  9, 10, 11, 12).strftime('%H:%M:%S')
    DateTime.civil(2000, 4,  9, 10, 11, 12).strftime("%X").should == "10:11:12"
    DateTime.civil(2000, 4,  9, 13, 11, 12).strftime("%X").should == "13:11:12"
    DateTime.civil(2000, 4,  9, 10, 11, 12).strftime("%X").should == DateTime.civil(2000, 4,  9, 10, 11, 12).strftime('%H:%M:%S')
  end
  
  it "should be able to print the common date and timezone" do
    DateTime.civil(2000, 4, 6, 10, 11, 12).strftime("%+").should == "Thu Apr  6 10:11:12 +00:00 2000"
    DateTime.civil(2000, 4, 6, 10, 11, 12, 0, 43200).strftime("%+").should == "Thu Apr  6 10:11:12 +12:00 2000"
    DateTime.civil(2000, 4, 6, 10, 11, 12).strftime("%+").should == DateTime.civil(2000, 4, 6, 10, 11, 12).strftime('%a %b %e %H:%M:%S %z %Y')  
  end
end
