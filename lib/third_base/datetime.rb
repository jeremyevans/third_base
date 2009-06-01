require 'third_base/date'

module ThirdBase
  # ThirdBase's DateTime class, which builds on the Date class and adds a time component of
  # hours, minutes, seconds, microseconds, and an offset from UTC.
  class DateTime < Date
    
    PARSER_LIST = []
    DEFAULT_PARSER_LIST = [:time, :iso, :us, :num]
    DEFAULT_PARSERS = {}
    TIME_RE_STRING = '(?:[T ]?([\d ]?\d):(\d\d)(?::(\d\d(\.\d+)?))?([ap]m?)? ?(Z|[+-](?:\d\d:?(?:\d\d)?))?)?'
    DEFAULT_PARSERS[:time] = [[%r{\A#{TIME_RE_STRING}\z}io, proc do |m|
        unless m[0] == ''
          t = Time.now
          add_parsed_time_parts(m, {:civil=>[t.year, t.mon, t.day], :not_parsed=>[:year, :mon, :mday]}, 1)
        end
      end]]
    DEFAULT_PARSERS[:iso] = [[%r{\A(-?\d{4})[-./ ](\d\d)[-./ ](\d\d)#{TIME_RE_STRING}\z}io, proc{|m| add_parsed_time_parts(m, :civil=>[m[1].to_i, m[2].to_i, m[3].to_i])}]]
    DEFAULT_PARSERS[:us] = [[%r{\A(\d\d?)[-./ ](\d\d?)[-./ ](\d\d(?:\d\d)?)#{TIME_RE_STRING}\z}io, proc{|m| add_parsed_time_parts(m, :civil=>[two_digit_year(m[3]), m[1].to_i, m[2].to_i])}],
      [%r{\A(\d\d?)/(\d?\d)#{TIME_RE_STRING}\z}o, proc{|m| add_parsed_time_parts(m, {:civil=>[Time.now.year, m[1].to_i, m[2].to_i], :not_parsed=>:year}, 3)}],
      [%r{\A#{MONTHNAME_RE_PATTERN}[-./ ](\d\d?)(?:st|nd|rd|th)?,?(?:[-./ ](-?(?:\d\d(?:\d\d)?)))?#{TIME_RE_STRING}\z}io, proc{|m| add_parsed_time_parts(m, :civil=>[m[3] ? two_digit_year(m[3]) : Time.now.year, MONTH_NUM_MAP[m[1].downcase], m[2].to_i], :not_parsed=>m[3] ? [] : [:year])}],
      [%r{\A(\d\d?)(?:st|nd|rd|th)?[-./ ]#{MONTHNAME_RE_PATTERN}[-./ ](-?\d{4})#{TIME_RE_STRING}\z}io, proc{|m| add_parsed_time_parts(m, :civil=>[m[3].to_i, MONTH_NUM_MAP[m[2].downcase], m[1].to_i])}],
      [%r{\A(-?\d{4})[-./ ]#{MONTHNAME_RE_PATTERN}[-./ ](\d\d?)(?:st|nd|rd|th)?#{TIME_RE_STRING}\z}io, proc{|m| add_parsed_time_parts(m, :civil=>[m[1].to_i, MONTH_NUM_MAP[m[2].downcase], m[3].to_i])}],
      [%r{\A#{MONTHNAME_RE_PATTERN}[-./ ](-?\d{4})#{TIME_RE_STRING}\z}io, proc{|m| add_parsed_time_parts(m, {:civil=>[m[2].to_i, MONTH_NUM_MAP[m[1].downcase], 1]}, 3)}]]
    DEFAULT_PARSERS[:eu] = [[%r{\A(\d\d?)[-./ ](\d\d?)[-./ ](\d{4})#{TIME_RE_STRING}\z}io, proc{|m| add_parsed_time_parts(m, :civil=>[m[3].to_i, m[2].to_i, m[1].to_i])}],
      [%r{\A(\d\d?)[-./ ](\d?\d)[-./ ](\d?\d)#{TIME_RE_STRING}\z}io, proc{|m| add_parsed_time_parts(m, :civil=>[two_digit_year(m[1]), m[2].to_i, m[3].to_i])}]]
    DEFAULT_PARSERS[:num] = [[%r{\A(\d{2,8})#{TIME_RE_STRING}\z}io, proc do |n|
        m = n[1]
        add_parsed_time_parts(n, (
        case m.length
        when 2
          t = Time.now
          {:civil=>[t.year, t.mon, m.to_i], :not_parsed=>[:year, :mon, :mday]}
        when 3
          {:ordinal=>[Time.now.year, m.to_i], :not_parsed=>[:year, :mon, :mday]}
        when 4
          {:civil=>[Time.now.year, m[0..1].to_i, m[2..3].to_i], :not_parsed=>[:year]}
        when 5
          {:ordinal=>[two_digit_year(m[0..1]), m[2..4].to_i]}
        when 6
          {:civil=>[two_digit_year(m[0..1]), m[2..3].to_i, m[4..5].to_i]}
        when 7
          {:ordinal=>[m[0..3].to_i, m[4..6].to_i]}
        when 8
          {:civil=>[m[0..3].to_i, m[4..5].to_i, m[6..7].to_i]}
        end
        ), 2)
      end
      ]]
    
    STRPTIME_PROC_H = proc{|h,x| h[:hour] = x.to_i}
    STRPTIME_PROC_M = proc{|h,x| h[:min] = x.to_i}
    STRPTIME_PROC_P = proc{|h,x| h[:meridian] = x.downcase == 'pm' ? :pm : :am}
    STRPTIME_PROC_S = proc{|h,x| h[:sec] = x.to_i}
    STRPTIME_PROC_s = proc do |h,x|
      j, i = x.to_i.divmod(86400)
      hours, i = i.divmod(3600)
      minutes, seconds = i.divmod(60)
      h.merge!(:jd=>j+UNIXEPOCH, :hour=>hours, :min=>minutes, :sec=>seconds)
    end
    STRPTIME_PROC_z = proc{|h,x| x=x.gsub(':',''); h[:offset] = (x == 'Z' ? 0 : x[0..2].to_i*3600 + x[3..4].to_i*60)}
    
    # Public Class Methods
    
    # Create a new DateTime with the given year, month, day of month, hour, minute, second, microsecond and offset.
    def self.civil(year, mon, day, hour=0, min=0, sec=0, usec=0, offset=0)
      new!(:civil=>[year, mon, day], :parts=>[hour, min, sec, usec], :offset=>offset)
    end
    
    # Create a new DateTime with the given commercial week year, commercial week, commercial week day, hour, minute
    # second, microsecond, and offset.
    def self.commercial(cwyear, cweek, cwday=5, hour=0, min=0, sec=0, usec=0, offset=0)
      new!(:commercial=>[cwyear, cweek, cwday], :parts=>[hour, min, sec, usec], :offset=>offset)
    end
    
    # Create a new DateTime with the given julian date, hour, minute, second, microsecond, and offset.
    def self.jd(jd, hour=0, min=0, sec=0, usec=0, offset=0)
      new!(:jd=>jd, :parts=>[hour, min, sec, usec], :offset=>offset)
    end
    
    # Create a new DateTime with the given julian day, fraction of the day (0.5 is Noon), and offset.
    def self.jd_fract(jd, fract=0.0, offset=0)
      new!(:jd=>jd, :fract=>fract, :offset=>offset)
    end
    
    # Create a new DateTime with the current date and time.
    def self.now
      t = Time.now
      new!(:civil=>[t.year, t.mon, t.day], :parts=>[t.hour, t.min, t.sec, t.usec], :offset=>t.utc_offset)
    end
    
    # Create a new DateTime with the given year, day of year, hour, minute, second, microsecond, and offset.
    def self.ordinal(year, yday, hour=0, min=0, sec=0, usec=0, offset=0)
      new!(:ordinal=>[year, yday], :parts=>[hour, min, sec, usec], :offset=>offset)
    end
    
    # Private Class Methods
    
    def self._expand_strptime_format(v)
      case v
      when '%c' then '%a %b %e %H:%M:%S %Y'
      when '%T', '%X' then '%H:%M:%S'
      when '%R' then '%H:%M'
      when '%r' then '%I:%M:%S %p'
      when '%+' then '%a %b %e %H:%M:%S %z %Y'
      else super(v)
      end
    end
    
    def self._strptime_part(v)
      case v
      when 'H', 'I' then ['(\d\d)', STRPTIME_PROC_H]
      when 'k', 'l' then ['(\d?\d)', STRPTIME_PROC_H]
      when 'M' then ['(\d\d)', STRPTIME_PROC_M]
      when 'P', 'p' then ['([ap]m)', STRPTIME_PROC_P]
      when 'S' then ['(\d\d)', STRPTIME_PROC_S]
      when 's' then ['(\d+)', STRPTIME_PROC_s]
      when 'z', 'Z' then ['(Z|[+-](?:\d{4}|\d\d:\d\d))', STRPTIME_PROC_z]
      else super(v)
      end
    end
    
    # m:
    # * i + 0 : hour
    # * i + 1 : minute
    # * i + 2 : second
    # * i + 3 : sec fraction
    # * i + 4 : meridian indicator
    # * i + 5 : time zone
    def self.add_parsed_time_parts(m, h, i=4)
      not_parsed = h[:not_parsed] || []
      hour = m[i].to_i
      meridian = m[i+4]
      hour = hour_with_meridian(hour, /a/io.match(meridian) ? :am : :pm) if meridian
      offset = if of = m[i+5]
        x = of.gsub(':','')
        offset = x == 'Z' ? 0 : x[0..2].to_i*3600 + x[3..4].to_i*60
      else
        not_parsed.concat([:zone, :offset])
        Time.now.utc_offset
      end
      min = m[i+1].to_i
      sec = m[i+2].to_i
      sec_fraction = m[i+3].to_f 
      not_parsed << :hour unless m[i]
      not_parsed << :min unless m[i+1]
      not_parsed << :sec unless m[i+2]
      not_parsed << :sec_fraction unless m[i+3]
      h.merge!(:parts=>[hour, min, sec, (sec_fraction/0.000001).to_i], :offset=>offset, :not_parsed=>not_parsed)
      h
    end
    
    def self.default_parser_hash
      DEFAULT_PARSERS
    end
    
    def self.default_parser_list
      DEFAULT_PARSER_LIST
    end

    def self.hour_with_meridian(hour, meridian)
      raise(ArgumentError, 'invalid date') unless hour and hour >= 1 and hour <= 12
      if meridian == :am
        hour == 12 ? 0 : hour
      else
        hour < 12 ? hour + 12 : hour 
      end
    end
    
    def self.new_from_parts(date_hash)
      date_hash[:hour] = hour_with_meridian(date_hash[:hour], date_hash[:meridian]) if date_hash[:meridian]
      d = now
      weights = {:cwyear=>1, :year=>1, :cweek=>2, :cwday=>3, :yday=>3, :month=>2, :day=>3, :hour=>4, :min=>5, :sec=>6}
      columns = {}
      min = 7
      max = 0
      date_hash.each do |k,v|
        if w = weights[k]
          min = w if w < min
          max = w if w > max
        end
      end
      offset = date_hash[:offset] || d.offset
      hour = date_hash[:hour] || (min > 4 ? d.hour : 0)
      minute = date_hash[:min] || (min > 5 ? d.min : 0)
      sec = date_hash[:sec] || 0
      if date_hash[:jd]
        jd(date_hash[:jd], hour, minute, sec, 0, offset)
      elsif date_hash[:year] || date_hash[:yday] || date_hash[:month] || date_hash[:day] || !(date_hash[:cwyear] || date_hash[:cweek])
        if date_hash[:yday]
          ordinal(date_hash[:year]||d.year, date_hash[:yday], hour, minute, sec, 0, offset)
        else
          civil(date_hash[:year]||d.year, date_hash[:month]||(min > 2 ? d.mon : 1), date_hash[:day]||(min > 3 ? d.day : 1), hour, minute, sec, 0, offset)
        end
      elsif date_hash[:cwyear] || date_hash[:cweek] || date_hash[:cwday]
        commercial(date_hash[:cwyear]||d.cwyear, date_hash[:cweek]||(min > 2 ? d.cweek : 1), date_hash[:cwday]||(min > 3 ? d.cwday : 1), hour, minute, sec, 0, offset)
      else
        raise ArgumentError, 'invalid date'
      end
    end
    
    def self.parser_hash
      PARSERS
    end
    
    def self.parser_list
      PARSER_LIST
    end
    
    def self.strptime_default
      '%Y-%m-%dT%H:%M:%S'
    end
    
    private_class_method :_expand_strptime_format, :_strptime_part, :add_parsed_time_parts, :default_parser_hash, :default_parser_list, :new_from_parts, :parser_hash, :parser_list, :strptime_default
    
    reset_parsers!
    
    # Instance Methods
    
    # This datetime's offset from UTC, in seconds.
    attr_reader :offset
    alias utc_offset offset
    
    # Which parts of this datetime were guessed instead of being parsed from the input.
    attr_reader :not_parsed

    # Called by DateTime.new!, should be a hash with the following possible keys:
    #
    # * :civil, :commericial, :jd, :ordinal : See ThirdBase::Date#initialize
    # * :fract : The fraction of the day (0.5 is Noon)
    # * :offset : offset from UTC, in seconds.
    # * :parts : an array with 4 elements, hour, minute, second, and microsecond
    #
    # Raises an ArgumentError if an invalid date is used.  DateTime objects are immutable once created.
    def initialize(opts)
      @not_parsed = opts[:not_parsed] || []
      @offset = opts[:offset]
      raise(ArgumentError, 'invalid datetime') unless @offset.is_a?(Integer) and @offset <= 43200 and @offset >= -43200
      if opts[:parts]
        @hour, @min, @sec, @usec = opts[:parts]
        raise(ArgumentError, 'invalid datetime') unless @hour.is_a?(Integer) and @min.is_a?(Integer) and @sec.is_a?(Integer) and @usec.is_a?(Integer)
      elsif opts[:fract]
        @fract = opts[:fract]
        raise(ArgumentError, 'invalid datetime') unless @fract.is_a?(Float) and @fract < 1.0 and @fract >= 0.0
      else
        raise(ArgumentError, 'invalid datetime')
      end
      super(opts)
    end
    
    # Return a new datetune with the given number of days added to this datetime.  If d is a Float
    # adds a fractional date, with possible loss of precision.  If d is an integer, 
    # the returned date has the same time components as the current date. In both
    # cases, the offset for the new date is the same as for this date.
    def +(d)
      case d
      when Float
        d, f = d.to_f.divmod(1)
        f = fract + f
        m, f = f.divmod(1)
        self.class.jd_fract(jd+d+m, f, @offset)
      when Integer
        new_jd(jd+d)
      else
        raise(TypeError, "d must be a Float or Integer")
      end
    end
    
    # Return a new datetune with the given number of days subtracted from this datetime.
    # If d is a DateTime, returns the difference between the two datetimes as a Float,
    # considering both datetimes date, time, and offest.
    def -(d)
      case d
      when self.class
        (jd - d.jd) + (fract - d.fract) + (@offset - d.offset)/86400.0
      when Integer, Float
        self + -d
      else
        raise TypeError, "d should be #{self.class}, Float, or Integer"
      end
    end
    
    # Compares two datetimes.  If the given datetime is an Integer, returns 1 unless
    # this datetime's time components are all 0, in which case it returns 0.
    # If the given datetime is a Float, calculates this date's julian date plus the
    # date fraction and compares it to the given datetime, and returns 0 only if the
    # two are very close together. This code does not take into account time offsets.
    def <=>(datetime)
      case datetime
      when Integer
        if ((d = (jd <=> datetime)) == 0)
          (hour == 0 and min == 0 and sec == 0 and usec == 0) ? 0 : 1
        else
          d
        end
      when Float
        diff = jd+fract - datetime
        if diff.abs <= 1.15740740740741e-011
          0
        else
          diff > 0.0 ? 1 : -1
        end
      when self.class
        ((d = super) == 0) && ((d = (hour <=> datetime.hour)) == 0) && ((d = (min <=> datetime.min)) == 0) && ((d = (sec <=> datetime.sec)) == 0) && ((d = (usec <=> datetime.usec)) == 0)
        d
      else
        raise TypeError, "d should be #{self.class}, Float, or Integer"
      end
    end
    
    # Two DateTimes are equal only if their dates and time components are the same, not counting the offset.
    def ==(datetime)
      return false unless DateTime === datetime
      super and hour == datetime.hour and min == datetime.min and sec == datetime.sec and usec == datetime.usec 
    end
    alias_method :eql?, :==
    
    # Returns the fraction of the day for this datetime (Noon is 0.5)
    def fract
      @fract ||= (@hour*3600+@min*60+@sec+@usec/1000000.0)/86400.0
    end
    
    # Returns the hour of this datetime.
    def hour
      @hour ||= time_parts[0]
    end
    
    # Returns the minute of this datetime.
    def min
      @min ||= time_parts[1]
    end
    
    # Returns the second of this datetime.
    def sec
      @sec ||= time_parts[2]
    end
    
    # Returns the microsecond of this datetime.
    def usec
      @usec ||= time_parts[3]
    end
    
    # Return the offset as a time zone string (+/-HHMM).
    def zone
      strftime('%z')
    end
    
    private

    def _strftime(v)
      case v
      when 'c' then strftime('%a %b %e %H:%M:%S %Y')
      when 'H' then '%02d' %   hour
      when 'I' then '%02d' % ((hour % 12).nonzero? or 12)
      when 'k' then '%2d'  % hour
      when 'l' then '%2d'  % ((hour % 12).nonzero? or 12)
      when 'M' then '%02d' % min
      when 'P' then hour < 12 ? 'am' : 'pm'
      when 'p' then hour < 12 ? 'AM' : 'PM'
      when 'R' then strftime('%H:%M')
      when 'r' then strftime('%I:%M:%S %p')
      when 'S' then '%02d' % sec
      when 's' then '%d' % ((jd - UNIXEPOCH)*86400 + hour*3600 + min*60 + sec - @offset)
      when 'T', 'X' then strftime('%H:%M:%S')
      when '+' then strftime('%a %b %e %H:%M:%S %z %Y')
      when 'Z' then @offset == 0 ? 'Z' : _strftime('z')
      when 'z' then "%+03d:%02d" % (@offset/60).divmod(60)
      else super(v)
      end
    end
    
    def fract_to_hmsu(p)
      hour, p = (p.to_f*24).divmod(1)
      min, p = (p*60).divmod(1)
      sec, sec_fract = (p*60).divmod(1)
      [hour, min, sec, (sec_fract*1000000).to_i]
    end
    
    def new_civil(y, m, d)
      self.class.new(y, m, d, hour, min, sec, usec, @offset)
    end
    
    def new_jd(j)
      self.class.jd(j, hour, min, sec, usec, @offset)
    end

    def strftime_default
      '%Y-%m-%dT%H:%M:%S%z'
    end
    
    def time_parts
      unless @hour && @min && @sec && @usec
        @hour, @min, @sec, @usec = fract_to_hmsu(fract)
      end
      [@hour, @min, @sec, @usec]
    end
  end
end
