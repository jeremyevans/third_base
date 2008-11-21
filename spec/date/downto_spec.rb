require(File.join(File.dirname(__FILE__), '..', 'date_spec_helper'))

describe "Date#downto" do

  it "should be able to step backward in time" do
    ds    = Date.civil(2000, 4, 14)
    de    = Date.civil(2000, 3, 29)
    count = 0
    ds.step(de, -1) do |d|
      d.should <= ds
      d.should >= de
      count += 1
    end
    count.should == 17
  end

end
