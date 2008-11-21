#!/usr/bin/env ruby
require 'benchmark'
require 'date'
require 'third_base/date'
n = 20000
puts "Date vs. ThirdBase::Date: #{n} Iterations"
Benchmark.bm do |x|
  GC.start; x.report("Date.new                "){n.times{Date.new(2008, 1, 1)}}
  GC.start; x.report("ThirdBase::Date.new     "){n.times{ThirdBase::Date.new(2008, 1, 1)}}
  GC.start; x.report("Date.new >>             "){n.times{Date.new(2008, 1, 1)>>3}}
  GC.start; x.report("ThirdBase::Date.new >>  "){n.times{ThirdBase::Date.new(2008, 1, 1)>>3}}
  GC.start; x.report("Date.new +              "){n.times{Date.new(2008, 1, 1)+3}}
  GC.start; x.report("ThirdBase::Date.new +   "){n.times{ThirdBase::Date.new(2008, 1, 1)+3}}
  GC.start; x.report("Date.parse              "){n.times{Date.parse("2008-01-01")}}
  GC.start; x.report("ThirdBase::Date.parse   "){n.times{ThirdBase::Date.parse("2008-01-01")}}
  GC.start; x.report("Date.strptime           "){n.times{Date.strptime("2008-01-01", "%Y-%m-%d")}}
  GC.start; x.report("ThirdBase::Date.strptime"){n.times{ThirdBase::Date.strptime("2008-01-01", "%Y-%m-%d")}}
end
