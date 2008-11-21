#!/usr/bin/env ruby
require 'benchmark'
require 'date'
require 'third_base/datetime'
n = 20000
puts "DateTime vs. ThirdBase::DateTime: #{n} Iterations"
Benchmark.bm do |x|
  GC.start; x.report("DateTime.new                "){n.times{DateTime.new(2008, 1, 1, 10, 15, 16)}}
  GC.start; x.report("ThirdBase::DateTime.new     "){n.times{ThirdBase::DateTime.new(2008, 1, 1, 10, 15, 16)}}
  GC.start; x.report("DateTime.new >>             "){n.times{DateTime.new(2008, 1, 1, 10, 15, 16)>>3}}
  GC.start; x.report("ThirdBase::DateTime.new >>  "){n.times{ThirdBase::DateTime.new(2008, 1, 1, 10, 15, 16)>>3}}
  GC.start; x.report("DateTime.new +              "){n.times{DateTime.new(2008, 1, 1, 10, 15, 16)+3.5}}
  GC.start; x.report("ThirdBase::DateTime.new +   "){n.times{ThirdBase::DateTime.new(2008, 1, 1, 10, 15, 16)+3.5}}
  GC.start; x.report("DateTime.parse              "){n.times{DateTime.parse("2008-01-01 10:15:16")}}
  GC.start; x.report("ThirdBase::DateTime.parse   "){n.times{ThirdBase::DateTime.parse("2008-01-01 10:15:16")}}
  GC.start; x.report("DateTime.strptime           "){n.times{DateTime.strptime("2008-01-01 10:15:16", "%F %T")}}
  GC.start; x.report("ThirdBase::DateTime.strptime"){n.times{ThirdBase::DateTime.strptime("2008-01-01 10:15:16", "%F %T")}}
end
