require(File.join(File.dirname(__FILE__), '..', 'datetime_spec_helper'))

describe "DateTime#<=>" do

  it "should be able to compare two same DateTimes" do
    (DateTime.civil(2000, 04, 06) <=> DateTime.civil(2000, 04, 06)).should == 0
    (DateTime.civil(2000, 04, 06, 10, 12, 11) <=> DateTime.civil(2000, 04, 06, 10, 12, 11)).should == 0
  end

  it "should be able to compute the difference between two DateTimes" do
    (DateTime.civil(2000, 04, 05) <=> DateTime.civil(2000, 04, 06)).should == -1
    (DateTime.civil(2001, 04, 05) <=> DateTime.civil(2000, 04, 06)).should == 1
    (DateTime.civil(2000, 04, 05, 10, 12, 13, 1) <=> DateTime.civil(2000, 04, 05, 10, 12, 13, 2)).should == -1
    (DateTime.civil(2001, 04, 05, 10, 12, 13, 1) <=> DateTime.civil(2001, 04, 05, 10, 12, 13, 0)).should == 1
  end

  it "should be able to compare to another numeric" do
    (DateTime.civil(2000, 04, 05) <=> DateTime.civil(2000, 04, 06).jd).should == -1
    (DateTime.civil(2001, 04, 05) <=> DateTime.civil(2000, 04, 06).jd).should == 1
    
    (DateTime.civil(2000, 04, 05).jd <=> 2451640).should == 0
    (DateTime.civil(2000, 04, 05) <=> 2451640.00000001).should == -1
    (DateTime.civil(2000, 04, 05) <=> 2451639.99999999).should == 1
  end

end

describe "DateTime#between?" do
   it "should be true if the DateTime falls in between the two given DateTimes" do
    (DateTime.civil(2000, 04, 06).between?(DateTime.civil(2000, 04, 05), DateTime.civil(2000, 04, 07))).should == true
    (DateTime.civil(2000, 04, 06).between?(DateTime.civil(2000, 04, 06), DateTime.civil(2000, 04, 07))).should == true
    (DateTime.civil(2000, 04, 06).between?(DateTime.civil(2000, 04, 05), DateTime.civil(2000, 04, 06))).should == true
    
    (DateTime.civil(2000, 04, 06, 10, 12, 11, 13).between?(DateTime.civil(2000, 04, 06, 10, 12, 11, 12), DateTime.civil(2000, 04, 06, 10, 12, 11, 14))).should == true
    (DateTime.civil(2000, 04, 06, 10, 12, 11, 12).between?(DateTime.civil(2000, 04, 06, 10, 12, 11, 12), DateTime.civil(2000, 04, 06, 10, 12, 11, 14))).should == true
    (DateTime.civil(2000, 04, 06, 10, 12, 11, 14).between?(DateTime.civil(2000, 04, 06, 10, 12, 11, 12), DateTime.civil(2000, 04, 06, 10, 12, 11, 14))).should == true
  end 
  
   it "should be false if the DateTime does not fall in between the two given DateTimes" do
    (DateTime.civil(2000, 04, 05).between?(DateTime.civil(2000, 04, 06), DateTime.civil(2000, 04, 07))).should == false
    (DateTime.civil(2000, 04, 06, 10, 12, 11, 14).between?(DateTime.civil(2000, 04, 06, 10, 12, 11, 15), DateTime.civil(2000, 04, 06, 10, 12, 11, 16))).should == false
  end 
end