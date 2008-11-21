require(File.join(File.dirname(__FILE__), '..', 'datetime_spec_helper'))

describe "DateTime#eql?" do
  it "should be able determine equality between date objects" do
    DateTime.civil(2007, 10, 11).should eql(DateTime.civil(2007, 10, 11))
    DateTime.civil(2007, 10, 11, 10, 11, 12, 13).should eql(DateTime.civil(2007, 10, 11, 10, 11, 12, 13))
    DateTime.civil(2007, 10, 11, 10, 11, 12, 13).usec.should eql((DateTime.civil(2007, 10, 12, 10, 11, 12, 13) - 1).usec)
    DateTime.civil(2007, 10, 11, 10, 11, 12, 13).should eql(DateTime.civil(2007, 10, 12, 10, 11, 12, 13) - 1)
    DateTime.civil(2007, 10, 11, 10, 11, 12, 13).should_not eql(DateTime.civil(2007, 10, 11, 10, 11, 12, 12))
  end
end