require(File.join(File.dirname(__FILE__), '..', 'date_spec_helper'))

describe "Date#upto" do
  
  it "should be able to step forward in time" do
    ds    = Date.civil(2008, 10, 11)
    de    = Date.civil(2008,  9, 29)
    count = 0
    de.upto(ds) do |d|
      d.should <= ds
      d.should >= de
      count += 1
    end
    count.should == 13
  end

end