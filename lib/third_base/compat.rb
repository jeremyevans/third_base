#!/usr/bin/env ruby
require 'third_base'

Object.send(:remove_const, :Date) if Object.const_get(:Date) rescue nil
Object.send(:remove_const, :DateTime) if Object.const_get(:DateTime) rescue nil
  
module ThirdBase
  MJD_JD    =  2400001 
  LD_JD     =  2299160
  ITALY     =  2299161
  ENGLAND   =  2361222
  JULIAN    = -100000000000000000000000000000000000
  GREGORIAN =  100000000000000000000000000000000000
  
  # Compatibility class methods for Date and DateTime, necessary because ruby doesn't
  # support multiple inheritance.
  module CompatClassMethods
    [ %w(os?	julian?),
      %w(ns?	gregorian?),
      %w(exist1?	valid_jd?),
      %w(exist2?	valid_ordinal?),
      %w(exist3?	valid_date?),
      %w(exist?	valid_date?),
      %w(existw?	valid_commercial?),
      %w(new0	new!),
      %w(new1	jd),
      %w(new2	ordinal),
      %w(new3	new),
      %w(neww	commercial)
    ].each{|old, new| module_eval("def #{old}(*args, &block); #{new}(*args, &block); end")}
    
    # Return the parts of the parsed date as a hash witht he following keys:
    #
    # * :hour : hour
    # * :mday : day of month
    # * :min : minute
    # * :mon : month
    # * :offset : time zone offset from UTC in seconds
    # * :sec : second
    # * :sec_fraction : fraction of a second
    # * :year : year
    # * :zone : time zone offset as string
    def _parse(str, comp=false)
      d = DateTime.parse(str)
      {:mon=>d.mon, :zone=>d.zone, :sec=>d.sec, :year=>d.year, :hour=>d.hour, :offset=>d.offset, :mday=>d.day, :min=>d.min, :sec_fraction=>d.usec/1000000.0}
    end
    
    # Converts an Astronomical Julian Date to an Astronomical Modified Julian Date (substracts an integer from ajd)
    def ajd_to_amjd(ajd)
      ajd - MJD_JD
    end
    
    # Converts an Astronomical Julian Date to a Julian Date (returns ajd, ignores of)
    def ajd_to_jd(ajd, of=0)
      ajd
    end
    
    # Converts an Astronomical Modified Julian Date to an Astronomical Julian Date (adds an integer to amjd)
    def amjd_to_ajd(amjd)
      amjd + MJD_JD
    end
    
    # Returns the julian date for the given civil date arguments, ignores sg.
    def civil_to_jd(year, mon, day, sg=nil)
      civil(year, mon, day).jd
    end
    
    # Returns the julian date for the given commercial date arguments, ignores sg.
    def commercial_to_jd(cwyear, cweek, cwday, sg=nil)
      commercial(cwyear, cweek, cwday).jd
    end
    
    # Returns the fraction of the date as an array of hours, minutes, seconds, and fraction on a second.
    def day_fraction_to_time(fr)
      hours, fr = (fr * 24).divmod(1)
      minutes, fr = (fr * 60).divmod(1)
      seconds, sec_fract = (fr * 60).divmod(1)
      [hours, minutes, seconds, sec_fract]
    end
    
    # True if jd is greater than sg, false otherwise.
    def gregorian?(jd, sg)
      jd > sg
    end
    
    # All years divisible by 4 are leap years in the Gregorian calendar,
    # except for years divisible by 100 and not by 400.
    def leap?(y)
      y % 4 == 0 && y % 100 != 0 || y % 400 == 0
    end
    alias gregorian_leap? leap?
    
    # Converts a Julian Date to an Astronomical Julian Date (returns j, ignores fr and of)
    def jd_to_ajd(j, fr, of=0)
      j
    end
    
    # Returns [year, month, day] for the given julian date, ignores sg.
    def jd_to_civil(j, sg=nil)
      jd(j).send(:civil)
    end
    
    # Returns [cwyear, cweek, cwday] for the given julian date, ignores sg.
    def jd_to_commercial(j, sg=nil)
      jd(j).send(:commercial)
    end
    
    # Converts a julian date to the number of days since the adoption of
    # the gregorian calendar in Italy (subtracts an integer from j).
    def jd_to_ld(j)
      j - LD_JD
    end
    
    # Convert a Julian Date to a Modified Julian Date (subtracts an integer from j).
    def jd_to_mjd(j)
      j - MJD_JD
    end
    
    # Returns [year, yday] for the given julian date, ignores sg.
    def jd_to_ordinal(j, sg=nil)
      jd(j).send(:ordinal)
    end
    
    # Returns the day of week for the given julian date.
    def jd_to_wday(j)
      jd(j).wday
    end
    
    # Returns true if jd is less than sg, false otherwise.
    def julian?(jd, sg)
      jd < sg
    end
    
    # All years divisible by 4 are leap years in the Julian calendar.
    def julian_leap?(y)
      y % 4 == 0
    end
    
    # Converts a number of days since the adoption of the gregorian calendar in Italy
    # to a julian date (adds an integer to ld).
    def ld_to_jd(ld)
      ld + LD_JD
    end
    
    # Converts a Modified Julian Date to a Julian Date (adds an integer to mjd).
    def mjd_to_jd(mjd)
      mjd + MJD_JD
    end
    
    # Converts the given year and day of year to a julian date, ignores sg.
    def ordinal_to_jd(year, yday, sg=nil)
      ordinal(year, yday).jd
    end
    
    # Converts the given hour, minute, and second to a fraction of a day as a Float.
    def time_to_day_fraction(h, min, s)
      (h*3600 + min*60 + s)/86400.0
    end
    
    # Return the julian date of the given year, month, and day if valid, or nil if not, ignores sg.
    def valid_civil?(year, mon, day, sg=nil)
      civil(year, mon, day).jd rescue nil
    end
    alias valid_date? valid_civil?
    
    # Return the julian date of the given commercial week year, commercial week, and commercial
    # week day if valid, or nil if not, ignores sg.
    def valid_commercial?(cwyear, cweek, cwday, sg=nil)
      commercial(cwyear, cweek, cwday).jd rescue nil
    end
    
    # Returns the julian date if valid (always returns jd, ignores sg).
    def valid_jd?(jd, sg=nil)
      jd
    end
    
    # Return the julian date of the given year and day of year if valid, or nil if not, ignores sg.
    def valid_ordinal?(year, yday, sg=nil)
      ordinal(year, yday).jd rescue nil
    end
    
    # Returns the fraction of the day if the time is valid, or nil if the time is not valid.
    def valid_time?(h, min, s)
      h   += 24 if h   < 0
      min += 60 if min < 0
      s   += 60 if s   < 0
      return unless ((0..23) === h &&
                     (0..59) === min &&
                     (0..59) === s) ||
                    (24 == h &&
                      0 == min &&
                      0 == s)
      time_to_day_fraction(h, min, s)
    end
    
    # Converts a time zone string to a offset from UTC in seconds.
    def zone_to_diff(zone)
      if m = /\A([+-](?:\d{4}|\d\d:\d\d))\z/.match(zone)
        x = m[1].gsub(':','')
        x[0..2].to_i*3600 + x[3..4].to_i*60
      else
        0
      end
    end
  end
  
  # Compatibility instance methods for Date and DateTime, necessary because ruby doesn't
  # support multiple inheritance.
  module CompatInstanceMethods
    # Returns the Astronomical Julian Date for this date (alias for jd)
    def ajd
      jd
    end
    
    # Returns the Astronomical Modified Julian Date for this date (jd plus an integer)
    def amjd
      jd - MJD_JD
    end
    alias mjd amjd
    
    # Returns self.
    def gregorian
      self
    end
    alias england gregorian
    alias julian gregorian
    alias italy gregorian
    
    # True, since the gregorian calendar is always used.
    def gregorian?
      true
    end
    alias ns? gregorian?
    
    # False, since the gregorian calendar is never used.
    def julian?
      false
    end
    alias os? julian?
    
    # Returns the days since the date of the adoption of the gregorian calendar in Italy
    # (substracts an integer from jd).
    def ld
      jd - LD_JD
    end
    
    # Alias for day.
    def mday
      day
    end
    
    # Returns self, ignores sg.
    def new_start(sg=nil)
      self
    end
    alias newsg new_start
    
    # Returns 0, since the gregorian calendar is always used.
    def start
      0
    end
    alias sg start
  end

  # ThirdBase's top level Date compatibility class, striving to be as close as possible
  # to the standard Date class's API.
  class ::Date < Date
    extend CompatClassMethods
    include CompatInstanceMethods
    
    # Parse the date using strptime with the given format.
    def self._strptime(str, fmt='%F')
      strptime(str, fmt)
    end
    
    # Creates a new Date with the given year, month, and day of month, ignores sg.
    def self.civil(year=-4712, mon=1, day=1, sg=nil)
      super(year, mon, day)
    end
    
    # Creates a new Date with the given commercial week year, commercial week, and commercial week day, ignores sg.
    def self.commercial(cwyear=1582, cweek=41, cwday=5, sg=nil)
      super(cwyear, cweek, cwday)
    end
    
    # Creates a new Date with the given julian date, ignores sg.
    def self.jd(j=0, sg=nil)
      super(j)
    end
    
    # Creates a new Date with the given year and day of year, ignores sg.
    def self.ordinal(year=-4712, yday=1, sg=nil)
      super(year, yday)
    end
    
    # Parse given string using ThirdBase::Date's date parser, ignores comp and sg.
    def self.parse(str="-4712-01-01", comp=false, sg=nil)
      super(str)
    end
    
    # Parse given string using given format, ignores sg.
    def self.strptime(str="-4712-01-01", fmt='%F', sg=nil)
      super(str, fmt)
    end
    
    # Creates a new Date with today's date, ignores sg.
    def self.today(sg=nil)
      super()
    end
    
    # Returns a formatted string representing the date.
    def asctime
      strftime('%a %b %e 00:00:00 %Y')
    end
    alias ctime asctime
    
    # Returns 0.0, since Date don't have fractional days.
    def day_fraction
      0.0
    end
  end

  # ThirdBase's top level DateTime compatibility class, striving to be as close as possible
  # to the standard DateTime class's API.
  class ::DateTime < DateTime
    extend CompatClassMethods
    include CompatInstanceMethods
    
    # Parse the datetime using strptime with the given format.
    def self._strptime(str, fmt='%FT%T%z')
      strptime(str, fmt)
    end
    
    # Creates a new DateTime with the given year, month, day of month, hour, minute, second, and offset, ignores sg.
    def self.civil(year=-4712, mon=1, day=1, hour=0, min=0, sec=0, offset=0, sg=nil)
      super(year, mon, day, hour, min, sec, 0, (offset*86400).to_i)
    end
    
    # Creates a new DateTime with the given commercial week year, commercial week, commercial week day,
    # hour, minute, second, and offset, ignores sg.
    def self.commercial(cwyear=1582, cweek=41, cwday=5, hour=0, min=0, sec=0, offset=0, sg=nil)
      super(cwyear, cweek, cwday, hour, min, sec, 0, (offset*86400).to_i)
    end
    
    # Creates a new DateTime with the given julian date, hour, minute, second, and offset, ignores sg.
    def self.jd(j=0, hour=0, min=0, sec=0, offset=0, sg=nil)
      super(j, hour, min, sec, 0, (offset*86400).to_i)
    end
    
    # Creates a new DateTime with the given year, day of year, hour, minute, second, and offset, ignores sg.
    def self.ordinal(year=-4712, yday=1, hour=0, min=0, sec=0, offset=0, sg=nil)
      super(year, yday, hour, min, sec, 0, (offset*86400).to_i)
    end
    
    # Parse given string using ThirdBase::DateTime's date parser, ignores comp and sg.
    def self.parse(str="-4712-01-01T00:00:00+00:00", comp=false, sg=nil)
      super(str)
    end
    
    # Parse given string using given format, ignores sg.
    def self.strptime(str="-4712-01-01T00:00:00+00:00", fmt='%FT%T%z', sg=nil)
      super(str, fmt)
    end
    
    # Creates a new DateTime with the current date and time, ignores sg.
    def self.now(sg=nil)
      super()
    end
    
    # Returns a formatted string representing the date.
    def asctime
      strftime('%c')
    end
    alias ctime asctime
    
    alias day_fraction fract
    
    # Returns a new DateTime with the same date and time as this datetime, but with a new offset.
    def new_offset(offset=0)
      self.class.new!(:civil=>civil, :parts=>time_parts, :offset=>(offset*86400).to_i)
    end
    alias newof new_offset
    
    # Return the offset as a Float representing the fraction of the day different from UTC.
    def offset
      @offset/86400.0
    end
    alias of offset
    
    # Return the offset as a number of seconds from UTC.
    def offset_sec
      @offset
    end

    # The fraction of a second represented as a fraction of the entire day.
    def sec_fraction
      usec/86400000000.0
    end
  end
end

$:.unshift(File.join(File.dirname(__FILE__), 'compat'))
require 'date'
require 'date/format'
$:.shift
