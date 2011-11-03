module Vendor

  class Version

    include Comparable

    VERSION_PATTERN = '[0-9]+(\.[0-9a-zA-Z]+)*' # :nodoc:
    ANCHORED_VERSION_PATTERN = /\A\s*(#{VERSION_PATTERN})*\s*\z/ # :nodoc:

    ##
    # A string representation of this Version.

    attr_reader :version
    alias to_s version

    ##
    # True if the +version+ string matches Vendor's requirements.

    def self.correct? version
      version.to_s =~ ANCHORED_VERSION_PATTERN
    end

    ##
    # Factory method to create a Version object. Input may be a Version
    # or a String. Intended to simplify client code.
    #
    #   ver1 = Version.create('1.3.17')   # -> (Version object)
    #   ver2 = Version.create(ver1)       # -> (ver1)
    #   ver3 = Version.create(nil)        # -> nil

    def self.create input
      if input === Vendor::Version
        input
      elsif input.nil? then
        nil
      else
        new input
      end
    end

    ##
    # Constructs a Version from the +version+ string.  A version string is a
    # series of digits or ASCII letters separated by dots.

    def initialize version
      raise ArgumentError, "Malformed version number string #{version}" unless
        self.class.correct?(version)

      @version = version.to_s
      @version.strip!
    end

    ##
    # Return a new version object where the next to the last revision
    # number is one greater (e.g., 5.3.1 => 5.4).
    #
    # Pre-release (alpha) parts, e.g, 5.3.1.b.2 => 5.4, are ignored.

    def bump
      segments = self.segments.dup
      segments.pop while segments.any? { |s| String === s }
      segments.pop if segments.size > 1

      segments[-1] = segments[-1].succ
      self.class.new segments.join(".")
    end

    ##
    # A Version is only eql? to another version if it's specified to the
    # same precision. Version "1.0" is not the same as version "1".

    def eql? other
      self.class === other and @version == other.version
    end

    def inspect # :nodoc:
      "#<#{self.class} #{version.inspect}>"
    end

    ##
    # Dump only the raw version string, not the complete object. It's a
    # string for backwards (RubyGems 1.3.5 and earlier) compatibility.

    def marshal_dump
      [version]
    end

    ##
    # Load custom marshal format. It's a string for backwards (RubyGems
    # 1.3.5 and earlier) compatibility.

    def marshal_load array
      initialize array[0]
    end

    ##
    # A version is considered a prerelease if it contains a letter.

    def prerelease?
      @prerelease ||= @version =~ /[a-zA-Z]/
    end

    def pretty_print q # :nodoc:
      q.text "Vendor::Version.new(#{version.inspect})"
    end

    ##
    # The release for this version (e.g. 1.2.0.a -> 1.2.0).
    # Non-prerelease versions return themselves.

    def release
      return self unless prerelease?

      segments = self.segments.dup
      segments.pop while segments.any? { |s| String === s }
      self.class.new segments.join('.')
    end

    def segments # :nodoc:

      # segments is lazy so it can pick up version values that come from
      # old marshaled versions, which don't go through marshal_load.

      @segments ||= @version.scan(/[0-9]+|[a-z]+/i).map do |s|
        /^\d+$/ =~ s ? s.to_i : s
      end
    end

    ##
    # A recommended version for use with a ~> Requirement.

    def spermy_recommendation
      segments = self.segments.dup

      segments.pop    while segments.any? { |s| String === s }
      segments.pop    while segments.size > 2
      segments.push 0 while segments.size < 2

      "~> #{segments.join(".")}"
    end

    ##
    # Compares this version with +other+ returning -1, 0, or 1 if the
    # other version is larger, the same, or smaller than this
    # one. Attempts to compare to something that's not a
    # <tt>Vendor::Version</tt> return +nil+.

    def <=> other
      return unless Vendor::Version === other
      return 0 if @version == other.version

      lhsegments = segments
      rhsegments = other.segments

      lhsize = lhsegments.size
      rhsize = rhsegments.size
      limit  = (lhsize > rhsize ? lhsize : rhsize) - 1

      i = 0

      while i <= limit
        lhs, rhs = lhsegments[i] || 0, rhsegments[i] || 0
        i += 1

        next      if lhs == rhs
        return -1 if String  === lhs && Numeric === rhs
        return  1 if Numeric === lhs && String  === rhs

        return lhs <=> rhs
      end

      return 0
    end
  end

end
