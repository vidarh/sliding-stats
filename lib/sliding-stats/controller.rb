
require 'rack'

module SlidingStats

  class Controller
    def initialize app, opts
      @app = app
      @base = opts[:base] || "/stats"
      @view = opts[:view] || View.new
      @max_entries = opts[:max_entries] || 100
    end

    def call env
      return Rack::Response.new("Missing 'slidingstats' object -- did you forget to set up SlidingStats::Window before SlidingStats::Controller ? ").finish if !env["slidingstats"]
 
      uri = env["REQUEST_URI"]
      @window = env["slidingstats"]

      case uri
      when @base
        r_to_p = @window.stats.referers_to_pages.sort_by{|k,v| -v[:total]}[0..@max_entries-1]
        referers = @window.stats.referers.sort_by{|k,v| -v}[0..@max_entries-1]
        pages = @window.stats.pages.sort_by{|k,v| -v}[0..@max_entries-1]
        return @view.show({:referers => referers, :pages => pages, :referers_to_pages => r_to_p, :base => @base})
      when @base+"/referers.svg"
        data = @window.stats.referers.sort_by{|k,v| -v}[0..@max_entries-1]
        return @view.show_svg(data)
      when @base+"/pages.svg"
        data = @window.stats.pages.sort_by{|k,v| -v}[0..@max_entries-1]
        return @view.show_svg(data)
      else
        return @app.call(env) if @app
        return Rack::Response.new("(empty)").finish
      end
    end
  end
end
