# Top level module for holding ThirdBase classes.
module ThirdBase
  # ThirdBase's date class, a simple class which, unlike the standard
  # Date class, does not include any time information. 
  #
  # This class is significantly faster than the standard Date class
  # for two reasons.  First, it does not depend on the Rational class
  # (which is slow).  Second, it doesn't convert all dates to julian
  # dates unless it is necessary.
  class Date
    include Comparable
    
    MONTHNAMES = [nil] + %w(January February March April May June July August September October November December)
    ABBR_MONTHNAMES = [nil] + %w(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)
    MONTH_NUM_MAP = {}
    MONTHNAMES.each_with_index{|x, i| MONTH_NUM_MAP[x.downcase] = i if x}
    ABBR_MONTHNAMES.each_with_index{|x, i| MONTH_NUM_MAP[x.downcase] = i if x}
    
    DAYNAMES = %w(Sunday Monday Tuesday Wednesday Thursday Friday Saturday)
    ABBR_DAYNAMES = %w(Sun Mon Tue Wed Thu Fri Sat)
    DAY_NUM_MAP = {}
    DAYNAMES.each_with_index{|x, i| DAY_NUM_MAP[x.downcase] = i}
    ABBR_DAYNAMES.each_with_index{|x, i| DAY_NUM_MAP[x.downcase] = i}

    CUMMULATIVE_MONTH_DAYS = {1=>0, 2=>31, 3=>59, 4=>90, 5=>120, 6=>151, 7=>181, 8=>212, 9=>243, 10=>273, 11=>304, 12=>334}
    LEAP_CUMMULATIVE_MONTH_DAYS = {1=>0, 2=>31, 3=>60, 4=>91, 5=>121, 6=>152, 7=>182, 8=>213, 9=>244, 10=>274, 11=>305, 12=>335}
    DAYS_IN_MONTH = {1=>31, 2=>28, 3=>31, 4=>30, 5=>31, 6=>30, 7=>31, 8=>31, 9=>30, 10=>31, 11=>30, 12=>31}
    LEAP_DAYS_IN_MONTH = {1=>31, 2=>29, 3=>31, 4=>30, 5=>31, 6=>30, 7=>31, 8=>31, 9=>30, 10=>31, 11=>30, 12=>31}
    
    MONTHNAME_RE_PATTERN = "(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec|january|february|march|april|may|june|july|august|september|october|november|december)"
    FULL_MONTHNAME_RE_PATTERN = "(january|february|march|april|may|june|july|august|september|october|november|december)"
    ABBR_MONTHNAME_RE_PATTERN = "(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)"
    FULL_DAYNAME_RE_PATTERN = "(sunday|monday|tuesday|wednesday|thursday|friday|saturday)"
    ABBR_DAYNAME_RE_PATTERN = "(sun|mon|tue|wed|thu|fri|sat)"
      
    PARSER_LIST = []
    DEFAULT_PARSER_LIST = [:iso, :us, :num]
    PARSERS = {}
    DEFAULT_PARSERS = {}
    DEFAULT_PARSERS[:iso] = [[%r{\A(-?\d{4})[-./ ](\d\d)[-./ ](\d\d)\z}o, proc{|m| {:civil=>[m[1].to_i, m[2].to_i, m[3].to_i]}}]]
    DEFAULT_PARSERS[:us] = [[%r{\A(\d\d?)[-./ ](\d\d?)[-./ ](\d\d(?:\d\d)?)\z}o, proc{|m| {:civil=>[two_digit_year(m[3]), m[1].to_i, m[2].to_i]}}],
      [%r{\A(\d\d?)/(\d?\d)\z}o, proc{|m| {:civil=>[Time.now.year, m[1].to_i, m[2].to_i]}}],
      [%r{\A#{MONTHNAME_RE_PATTERN}[-./ ](\d\d?)(?:st|nd|rd|th)?,?(?:[-./ ](-?(?:\d\d(?:\d\d)?)))?\z}io, proc{|m| {:civil=>[m[3] ? two_digit_year(m[3]) : Time.now.year, MONTH_NUM_MAP[m[1].downcase], m[2].to_i]}}],
      [%r{\A(\d\d?)(?:st|nd|rd|th)?[-./ ]#{MONTHNAME_RE_PATTERN}[-./ ](-?\d{4})\z}io, proc{|m| {:civil=>[m[3].to_i, MONTH_NUM_MAP[m[2].downcase], m[1].to_i]}}],
      [%r{\A(-?\d{4})[-./ ]#{MONTHNAME_RE_PATTERN}[-./ ](\d\d?)(?:st|nd|rd|th)?\z}io, proc{|m| {:civil=>[m[1].to_i, MONTH_NUM_MAP[m[2].downcase], m[3].to_i]}}],
      [%r{\A#{MONTHNAME_RE_PATTERN}[-./ ](-?\d{4})\z}io, proc{|m| {:civil=>[m[2].to_i, MONTH_NUM_MAP[m[1].downcase], 1]}}]]
    DEFAULT_PARSERS[:eu] = [[%r{\A(\d\d?)[-./ ](\d\d?)[-./ ](\d\d\d\d)\z}o, proc{|m| {:civil=>[m[3].to_i, m[2].to_i, m[1].to_i]}}],
      [%r{\A(\d\d?)[-./ ](\d?\d)[-./ ](\d?\d)\z}o, proc{|m| {:civil=>[two_digit_year(m[1]), m[2].to_i, m[3].to_i]}}]]
    DEFAULT_PARSERS[:num] = [[%r{\A\d{2,8}\z}o, proc do |m|
        m = m[0]
        case m.length
        when 2
          t = Time.now
          {:civil=>[t.year, t.mon, m.to_i]}
        when 3
          {:ordinal=>[Time.now.year, m.to_i]}
        when 4
          {:civil=>[Time.now.year, m[0..1].to_i, m[2..3].to_i]}
        when 5
          {:ordinal=>[two_digit_year(m[0..1]), m[2..4].to_i]}
        when 6
          {:civil=>[two_digit_year(m[0..1]), m[2..3].to_i, m[4..5].to_i]}
        when 7
          {:ordinal=>[m[0..3].to_i, m[4..6].to_i]}
        when 8
          {:civil=>[m[0..3].to_i, m[4..5].to_i, m[6..7].to_i]}
        end
      end
      ]]
      
    STRFTIME_RE = /%./o
      
    STRPTIME_PROC_A = proc{|h,x| h[:cwday] = DAY_NUM_MAP[x.downcase]}
    STRPTIME_PROC_B = proc{|h,x| h[:month] = MONTH_NUM_MAP[x.downcase]}
    STRPTIME_PROC_C = proc{|h,x| h[:year] ||= x.to_i*100}
    STRPTIME_PROC_d = proc{|h,x| h[:day] = x.to_i}
    STRPTIME_PROC_G = proc{|h,x| h[:cwyear] = x.to_i}
    STRPTIME_PROC_g = proc{|h,x| h[:cwyear] = two_digit_year(x)}
    STRPTIME_PROC_j = proc{|h,x| h[:yday] = x.to_i}
    STRPTIME_PROC_m = proc{|h,x| h[:month] = x.to_i}
    STRPTIME_PROC_u = proc{|h,x| h[:cwday] = x.to_i}
    STRPTIME_PROC_V = proc{|h,x| h[:cweek] = x.to_i}
    STRPTIME_PROC_y = proc{|h,x| h[:year] = two_digit_year(x)}
    STRPTIME_PROC_Y = proc{|h,x| h[:year] = x.to_i}
    
    UNIXEPOCH = 2440588
    
    # Public Class Methods
    
    class << self
      alias new! new
    end
    
    # Add a parser to the parser type.  re should be
    # a Regexp, and a block must be provided.  The block
    # should take a single MatchData argument, a return
    # either nil specifying it could not parse the string,
    # or a hash of values to be passed to new!.
    def self.add_parser(type, re, &block)
      parser_hash[type].unshift([re, block])
    end
    
    # Add a parser type to the list of parser types.
    # Should be used if you want to add your own parser
    # types.
    def self.add_parser_type(type)
      parser_hash[type] ||= []
    end
    
    # Returns a new Date with the given year, month, and day.
    def self.civil(year, mon, day)
      new!(:civil=>[year, mon, day])
    end
    
    # Returns a new Date with the given commercial week year,
    # commercial week, and commercial week day.
    def self.commercial(cwyear, cweek, cwday=5)
      new!(:commercial=>[cwyear, cweek, cwday])
    end
    
    # Returns a new Date with the given julian date.
    def self.jd(j)
      new!(:jd=>j)
    end
    
    # Calls civil with the given arguments.
    def self.new(*args)
      civil(*args)
    end
    
    # Returns a new Date with the given year and day of year.
    def self.ordinal(year, yday)
      new!(:ordinal=>[year, yday])
    end
    
    # Parses the given string and returns a Date.  Raises an ArgumentError if no
    # parser can correctly parse the date. Takes the following options:
    #
    # * :parser_types : an array of parser types to use,
    #   overriding the default or the ones specified by
    #   use_parsers.
    def self.parse(str, opts={})
      s = str.strip
      parsers(opts[:parser_types]) do |pattern, block|
        if m = pattern.match(s)
          if res = block.call(m)
            return new!(res)
          end
        end
      end
      raise ArgumentError, 'invalid date'
    end
    
    # Reset the parsers, parser types, and order of parsers used to the default.
    def self.reset_parsers!
      parser_hash.clear
      default_parser_hash.each do |type, parsers|
        add_parser_type(type)
        parsers.reverse.each do |re, parser|
          add_parser(type, re, &parser)
        end
      end
      use_parsers(*default_parser_list)
    end
    
    # Parse the string using the provided format (or the default format).
    # Raises an ArgumentError if the format does not match the string.
    def self.strptime(str, fmt=strptime_default)
      blocks = []
      s = str.strip
      date_hash = {}
      pattern = Regexp.escape(expand_strptime_format(fmt)).gsub(STRFTIME_RE) do |x|
        pat, *blks = _strptime_part(x[1..1])
        blocks += blks
        pat
      end
      if m = /#{pattern}/i.match(s)
        m.to_a[1..-1].zip(blocks) do |x, blk|
          blk.call(date_hash, x)
        end
        new_from_parts(date_hash)
      else
        raise ArgumentError, 'invalid date'
      end
    end
    
    # Returns a date with the current year, month, and date.
    def self.today
      t = Time.now
      civil(t.year, t.mon, t.day)
    end
    
    # Set the order of parser types to use to the given parser types.
    def self.use_parsers(*parsers)
      parser_list.replace(parsers)
    end
    
    # Private Class Methods
    
    def self._expand_strptime_format(v)
      case v
      when '%D', '%x' then '%m/%d/%y'
      when '%F' then '%Y-%m-%d'
      when '%v' then '%e-%b-%Y'
      else v
      end
    end

    def self._strptime_part(v)
      case v
      when 'A' then [FULL_DAYNAME_RE_PATTERN, STRPTIME_PROC_A]
      when 'a' then [ABBR_DAYNAME_RE_PATTERN, STRPTIME_PROC_A]
      when 'B' then [FULL_MONTHNAME_RE_PATTERN, STRPTIME_PROC_B]
      when 'b', 'h' then [ABBR_MONTHNAME_RE_PATTERN, STRPTIME_PROC_B]
      when 'C' then ['([+-]?\d\d?)', STRPTIME_PROC_C]
      when 'd' then ['([0-3]?\d)', STRPTIME_PROC_d]
      when 'e' then ['([1-3 ]?\d)', STRPTIME_PROC_d]
      when 'G' then ['(\d{4})', STRPTIME_PROC_G]
      when 'g' then ['(\d\d)', STRPTIME_PROC_g]
      when 'j' then ['(\d{1,3})', STRPTIME_PROC_j]
      when 'm' then ['(\d\d?)', STRPTIME_PROC_m]
      when 'n' then ['\n']
      when 't' then ['\t']
      when 'u' then ['(\d)', STRPTIME_PROC_u]
      when 'V' then ['(\d\d?)', STRPTIME_PROC_V]
      when 'y' then ['(\d\d)', STRPTIME_PROC_y]
      when 'Y' then ['([+-]?\d{4})', STRPTIME_PROC_Y]
      when '%' then ['%']
      else ["%#{v}"]
      end
    end
    
    def self.default_parser_hash
      DEFAULT_PARSERS
    end
    
    def self.default_parser_list
      DEFAULT_PARSER_LIST
    end
    
    def self.expand_strptime_format(fmt)
      fmt.gsub(STRFTIME_RE){|x| _expand_strptime_format(x)}
    end
    
    def self.new_from_parts(date_hash)
      d = today
      if date_hash[:year] || date_hash[:yday] || date_hash[:month] || date_hash[:day]
        if date_hash[:yday]
          ordinal(date_hash[:year]||d.year, date_hash[:yday])
        else
          civil(date_hash[:year]||d.year, date_hash[:month]||(date_hash[:day] ? d.mon : 1), date_hash[:day]||1)
        end
      elsif date_hash[:cwyear] || date_hash[:cweek] || date_hash[:cwday]
        commercial(date_hash[:cwyear]||d.cwyear, date_hash[:cweek]||(date_hash[:cwday] ? d.cweek : 1), date_hash[:cwday]||1)
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
    
    def self.parsers(parser_families=nil)
      (parser_families||parser_list).each do |parser_family|
        parsers_for_family(parser_family) do |pattern, block|
          yield(pattern, block)
        end
      end
    end
    
    def self.parsers_for_family(parser_family)
      parser_hash[parser_family].each do |pattern, block|
        yield(pattern, block)
      end
    end
    
    def self.strptime_default
      '%Y-%m-%d'
    end
    
    def self.two_digit_year(y)
      y = if y.length == 2
        y = y.to_i
        (y < 69 ? 2000 : 1900) + y
      else
        y.to_i
      end
    end
    
    private_class_method :_expand_strptime_format, :_strptime_part, :default_parser_hash, :default_parser_list, :expand_strptime_format, :new_from_parts, :parser_hash, :parser_list, :parsers, :parsers_for_family, :strptime_default, :two_digit_year
    
    reset_parsers!
    
    # Public Instance Methods
    
    # Called by Date.new!, Takes a hash with one of the following keys:
    #
    # * :civil : should be an array with 3 elements, a year, month, and day
    # * :commercial : should be an array with 3 elements, a commercial week year, commercial week, and commercial week day
    # * :jd : should be an integer specifying the julian date
    # * :ordinal : should be an array with 2 elements, a year and day of year.
    #
    # An ArgumentError is raised if the date is invalid.  All Date objects are immutable once created.
    def initialize(opts)
      if opts[:civil]
        @year, @mon, @day = opts[:civil]
        raise(ArgumentError, "invalid date") unless @year.is_a?(Integer) && @mon.is_a?(Integer) && @day.is_a?(Integer) && valid_civil?
      elsif opts[:ordinal]
        @year, @yday = opts[:ordinal]
        raise(ArgumentError, "invalid date") unless @year.is_a?(Integer) && @yday.is_a?(Integer) && valid_ordinal?
      elsif opts[:jd]
        @jd = opts[:jd]
        raise(ArgumentError, "invalid date") unless @jd.is_a?(Integer)
      elsif opts[:commercial]
        @cwyear, @cweek, @cwday = opts[:commercial]
        raise(ArgumentError, "invalid date") unless @cwyear.is_a?(Integer) && @cweek.is_a?(Integer) && @cwday.is_a?(Integer) && valid_commercial?
      else
        raise(ArgumentError, "invalid date format")
      end
    end
    
    # Returns a new date with d number of days added to this date.
    def +(d)
      raise(TypeError, "d must be an integer") unless d.is_a?(Integer)
      jd_to_civil(jd + d)
    end
    
    # Returns a new date with d number of days subtracted from this date.
    # If d is a Date, returns the number of days between the two dates.
    def -(d)
      if d.is_a?(self.class)
        jd - d.jd
      elsif d.is_a?(Integer)
        self + -d
      else
        raise TypeError, "d should be #{self.class} or Integer"
      end
    end
    
    # Returns a new date with m number of months added to this date.
    # If the day of self does not exist in the new month, set the
    # new day to be the last day of the new month.
    def >>(m)
      raise(TypeError, "m must be an integer") unless m.is_a?(Integer)
      y = year
      n = mon + m
      if n > 12 or n <= 0
        a, n = n.divmod(12)
        if n == 0
          n = 12
          y += a - 1
        else
          y += a
        end
      end
      ndays = days_in_month(n, y)
      d = day > ndays ? ndays : day
      new_civil(y, n, d)
    end
    
    # Returns a new date with m number of months subtracted from this date.
    def <<(m)
      self >> -m
    end
    
    # Compare two dates.  If the given date is greater than self, return -1, if it is less,
    # return 1, and if it is equal, return 0.  If given date is a number, compare this date's julian
    # date to it.
    def <=>(date)
      if date.is_a?(Numeric)
        jd <=> date
      else
        ((d = (year <=> date.year)) == 0) && ((d = (mon <=> date.mon)) == 0) && ((d = (day <=> date.day)) == 0)
        d
      end
    end
    
    # Dates are equel only if their year, month, and day match.
    def ==(date)
      return false unless Date === date
      year == date.year and mon == date.mon and day == date.day
    end
    alias_method :eql?, :==
    
    # If d is a date, only true if it is equal to this date.  If d is Numeric, only true if it equals this date's julian date.
    def ===(d)
      case d
      when Numeric then jd == d
      when Date then self == d
      else false
      end
    end
    
    # The commercial week day for this date.
    def cwday
      @cwday || commercial[2]
    end
    
    # The commercial week for this date.
    def cweek
      @cweek || commercial[1]
    end
    
    # The commercial week year for this date.
    def cwyear
      @cwyear || commercial[0]
    end
    
    # The day of the month for this date.
    def day
      @day || civil[2]
    end
    alias mday day
    
    # Yield every date between this date and given date to the block. The
    # given date should be less than this date.
    def downto(d, &block)
      step(d, -1, &block)
    end
    
    # Unique value for this date, based on it's year, month, and day of month.
    def hash
      civil.hash
    end
    
    # Programmer friendly readable string, much more friendly than the one
    # in the standard date class.
    def inspect
      "#<#{self.class} #{self}>"
    end
    
    # This date's julian date.
    def jd
      @jd ||= ( 
        y = year
        m = mon
        d = day
        if m <= 2
          y -= 1
          m += 12
        end
        a = (y / 100.0).floor
        jd = (365.25 * (y + 4716)).floor +
          (30.6001 * (m + 1)).floor +
          d - 1524 + (2 - a + (a / 4.0).floor)
      )
    end

    # Whether this date is in a leap year.
    def leap?
      _leap?(year)
    end
    
    # The month number for this date (January is 1, December is 12).
    def mon
      @mon || civil[1]
    end
    alias month mon
    
    # Yield each date between this date and limit, adding step number
    # of days in each iteration.  Returns current date.
    def step(limit, step=1)
      da = self
      op = %w(== <= >=)[step <=> 0]
      while da.__send__(op, limit)
        yield da
        da += step
      end
      self
    end
    
    # Format the time using a format string, or the default format string.
    def strftime(fmt=strftime_default)
      fmt.gsub(STRFTIME_RE){|x| _strftime(x[1..1])}
    end
    
    # Return the day after this date.
    def succ
      self + 1
    end
    alias next succ
    
    # Alias for strftime with the default format
    def to_s
      strftime
    end

    # Yield every date between this date and the given date to the block. The given date
    # should be greater than this date.
    def upto(d, &block)
      step(d, &block)
    end
    
    # Return the day of the week for this date.  Sunday is 0, Saturday is 6.
    def wday
      (jd + 1) % 7
    end
    
    # Return the day of the year for this date. January 1 is 1.
    def yday
      h = leap? ? LEAP_CUMMULATIVE_MONTH_DAYS : CUMMULATIVE_MONTH_DAYS
      @yday ||= h[mon] + day
    end
    
    # Return the year for this date.
    def year
      @year || civil[0]
    end
    
    protected
    
    def civil
      unless @year && @mon && @day
        if @year && @yday
          @mon, @day = month_day_from_yday
        else
          date = jd_to_civil(@jd || commercial_to_jd(*commercial))
          @year = date.year
          @mon = date.mon
          @day = date.day
        end
      end
      [@year, @mon, @day]
    end
    
    def commercial
      unless @cwyear && @cweek && @cwday
        a = jd_to_civil(jd - 3).year
        @cwyear = if jd >= commercial_to_jd(a + 1, 1, 1) then a + 1 else a end
        @cweek = 1 + ((jd - commercial_to_jd(@cwyear, 1, 1)) / 7).floor
        @cwday = (jd + 1) % 7
        @cwday = 7 if @cwday == 0
      end
      [@cwyear, @cweek, @cwday]
    end
    
    def ordinal
      [year, yday]
    end
    
    private
    
    def _leap?(year)
      if year % 400 == 0
        true
      elsif year % 100 == 0
        false
      elsif year % 4 == 0
        true
      else
        false
      end
    end
    
    def _strftime(v)
      case v
      when '%' then '%'
      when 'A' then DAYNAMES[wday]
      when 'a' then ABBR_DAYNAMES[wday]
      when 'B' then MONTHNAMES[mon]
      when 'b', 'h' then ABBR_MONTHNAMES[mon]
      when 'C' then '%02d' % (year / 100.0).floor
      when 'D', 'x' then strftime('%m/%d/%y')
      when 'd' then '%02d' % day
      when 'e' then '%2d' % day
      when 'F' then strftime('%Y-%m-%d')
      when 'G' then '%.4d' % cwyear
      when 'g' then '%02d' % (cwyear % 100)
      when 'j' then '%03d' % yday
      when 'm' then '%02d' % mon
      when 'n' then "\n"
      when 't' then "\t"
      when 'U', 'W'
        firstday = self - ((v == 'W' and wday == 0) ? 6 : wday)
        y = firstday.year
        '%02d' % (y != year ? 0 : ((firstday - new_civil(y, 1, 1))/7 + 1))
      when 'u' then '%d' % cwday
      when 'V' then '%02d' % cweek
      when 'v' then strftime('%e-%b-%Y')
      when 'w' then '%d' % wday
      when 'Y' then '%04d' % year
      when 'y' then '%02d' % (year % 100)
      else "%#{v}"
      end
    end
    
    def commercial_to_jd(y, w, d)
      jd = new_civil(y, 1, 4).jd
      jd - (jd % 7) + 7 * (w - 1) + (d - 1)
    end
    
    def days_in_month(m=nil, y=nil)
      (_leap?(y||year) ? LEAP_DAYS_IN_MONTH : DAYS_IN_MONTH)[m||mon]
    end
    
    def jd_to_civil(jd)
      new_civil(*jd_to_ymd(jd))
    end
    
    def jd_to_ymd(jd)
      x = ((jd - 1867216.25) / 36524.25).floor
      a = jd + 1 + x - (x / 4.0).floor
      b = a + 1524
      c = ((b - 122.1) / 365.25).floor
      d = (365.25 * c).floor
      e = ((b - d) / 30.6001).floor
      dom = b - d - (30.6001 * e).floor
      if e <= 13
        m = e - 1
        y = c - 4716
      else
        m = e - 13
        y = c - 4715
      end
      [y, m, dom]
    end
    
    def julian_jd?(jd)
      jd < 2299161
    end
    
    def last_yday
      leap? ? 366 : 365
    end
    
    def month_day_from_yday
      yday = @yday
      y = @year
      h = leap? ? LEAP_CUMMULATIVE_MONTH_DAYS : CUMMULATIVE_MONTH_DAYS
      12.downto(0) do |i|
        if (c = h[i]) < yday
          return [i, yday - c] 
        end
      end
    end
    
    def new_civil(y, m, d)
      self.class.new(y, m, d)
    end
    
    def new_jd(j)
      self.class.jd(jd)
    end
    
    def strftime_default
      '%Y-%m-%d'
    end
    
    def valid_civil?
      day >= 1 and day <= days_in_month(mon) and mon >= 1 and mon <= 12
    end
    
    def valid_commercial?
      if cwday >= 1 and cwday <= 7 and cweek >= 1 and cweek <= 53
        new_jd(jd).commercial == commercial
      else
        false
      end
    end
    
    def valid_ordinal?
      yday >= 1 and yday <= (_leap?(year) ? 366 : 365)
    end
    
    def yday_from_month_day
      CUMMULATIVE_MONTH_DAYS[mon] + day + ((month > 2 and leap?) ? 1 : 0)
    end
  end
end
