#!/usr/bin/env ruby

Object.send(:remove_const, :Date) if Object.const_get(:Date) rescue nil
Object.send(:remove_const, :DateTime) if Object.const_get(:DateTime) rescue nil
  
require 'third_base/make_compat'

class Date < ThirdBase::Date
end
class DateTime < ThirdBase::DateTime
end

$:.unshift(File.join(File.dirname(__FILE__), 'compat'))
require 'date'
require 'date/format'
$:.shift
