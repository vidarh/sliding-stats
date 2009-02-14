
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
  #  * :exclude_[referers|pages] => Arrays that will be matched against
  #                REQUEST_URI and HTTP_REFERER to decide
  #                whether or not to exclude this request
  #  * :rewrite_referer => 
  #                An Array of arrays consisting of regexps
  #                and a rewrite pattern to filter the 
  #                HTTP_REFERER against
  class Window
    attr_reader :stats

    def initialize app, opts = {}
      @app = app
      @limit = DEFAULT_WINDOW
      @exclude_referers = []
      @rewrite_referers = []
      @exclude_pages = []
      opts.each do |k,v|
        @limit = v.to_i if k == :limit
        @exclude_referers = v if k == :exclude_referers
        @rewrite_referers = v if k == :rewrite_referers
        @exclude_pages = v if k == :exclude_pages
        @persist = v if k == :persist
      end
      
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

      newref = @rewrite_referers.inject(ref) { |ref,r| ref.gsub(r[0],r[1]) }
      ref = CGI.unescape(newref) if ref != newref
      
      stats = {
        "HTTP_REFERER" => ref,
        "REQUEST_URI"  => req
      }
      @requests << stats
      @stats.add(stats)
      @stats.sub(@requests.shift) if @requests.size > @limit
      @persist.save(@requests) if @persist

      env["slidingstats"] = self
      @app.call(env)
    end
  end
end
