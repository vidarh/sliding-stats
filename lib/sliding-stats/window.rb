
require 'sliding-stats/stats'
require 'sliding-stats/persist'
require 'cgi'

module SlidingStats
  DEFAULT_WINDOW = 500

  # Provides a "sliding window" over the stats. You provide
  # a limit, and then feeds data into it. When the number of
  # lines of data exceeds the limit, the oldest gets removed.
  #
  # The actual stats calculation is handled by the Stats class
  #
  # At any point you can extract stats from from the current
  # window.
  #
  # The following options can be passed in the opts argument:
  #  * :limit => the number of stats lines to keep
  #  * :ignore => Requests where this matches *either* the referer *or* the request
  #                *or* the user agent will not be considered at all.
  #  * :request_methods => Array of HTTP methods to track. Defaults to :get
  #                as POST, PUT etc. on "normal" sites rarely happen
  #                on inbound referrals, and so we'd be likely to overcount
  #                access to a specific page
  #  * :exclude_[referers|pages] => Arrays that will be matched against
  #                REQUEST_URI and HTTP_REFERER to decide
  #                whether or not to exclude this request from
  #                the appropriate stats.
  #  * :rewrite_referer => 
  #                An Array of arrays consisting of regexps
  #                and a rewrite pattern to filter the 
  #                HTTP_REFERER against
  class Window
    attr_reader :stats

    def initialize app, opts = {}
      @app = app
      @limit = (opts[:limit] || DEFAULT_WINDOW).to_i
      @exclude_referers = opts[:exclude_referers] || []
      @rewrite_referers = opts[:rewrite_referers] || []
      @request_methods = opts[:request_methods] || [:get]
      @exclude_pages = opts[:exclude_pages] || []
      @ignore = opts[:ignore] || []
      @persist = opts[:persist]
      
      @requests = []
      if @persist.is_a?(Numeric)
        @persist = SlidingStats::Persist.new(@persist)
        @requests = @persist.load
      end
      @stats = Stats.new(@requests,@exclude_referers,@exclude_pages)
    end

    def call env
      ref = env["HTTP_REFERER"] || "-"
      req = env["REQUEST_URI"]
      ua = env["HTTP_USER_AGENT"]
      req_meth = env["REQUEST_METHOD"].downcase.to_sym

      if @request_methods.include?(req_meth) && !@ignore.detect{|pat| ref =~ pat || req =~ pat || ua =~ pat}
        newref = @rewrite_referers.inject(ref) { |nr,r| nr.gsub(r[0],r[1]) }
        ref = CGI.unescape(newref) if newref != ref
      
        stats = {
          "HTTP_REFERER" => ref,
          "REQUEST_URI"  => req
        }
        @requests << stats
        @stats.add(stats)
        while @requests.size > @limit
          @stats.sub(@requests.shift) 
        end
        @persist.save(@requests) if @persist
      end

      env["slidingstats"] = self
      @app.call(env)
    end
  end
end
