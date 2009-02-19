
# This demonstrates how to configure the stats and generates an SVG of 1000 requests by page.
# The exclusion patterns are geared towards my website, and so you'd want to adapt them.

require 'sliding-stats'

opts = {
  # The number of requests that is considered
  :limit => 1000,

  # If set to an integer, the number of requests between each time the data is persisted
  # (using Marshal) to /var/tmp/slidingstats. You can provide a path by passing
  # SlidingStats::Persist.new(number, path) instead, or you can provide any class that
  # provides a #load and #save method -- see SlidingStats::Persist
  :persist => nil,

  # Pages where either the request or referrer match :ignore is not processed further,
  # and doesn't count towards :limit
  :ignore => [ 
    /\.xml/, /\/feed/, /\.rdf/, /\.ico/, /\/static\//,/\/robots.txt/
    /\/referers/, /\/stats.*/,
    /http:\/\/search.live.com\/results.aspx/, # MSN referer spam
  ],

  # Exclude entries from the referer graph and the referer to pages table
  :exclude_referers => [
    /http:\/\/www\.hokstad\.com/,  # Not interested in seeing internal clicks
    /^-/                           # Direct traffic.
  ],

  # Exclude entries from the page graph and referer to pages table.
  :exclude_pages => [
  ],

  # Rewrite referrer entries to make them more friendly, and group together
  # referrers that don't have exactly the same URL
  :rewrite_referers =>
    [
    [/http:\/\/.*\.google\..*?[?&]q=([^&]*)?&*.*/,"Google Search: '\\1'"],
    [/http:\/\/www.google..*\/reader.*/,"Google Reader"]
    ]
}

view   = SlidingStats::Controller.new(nil,"/stats")
window = SlidingStats::Window.new(view, opts)

# First we feed it stats from STDIN:

STDIN.each do |line|
  line = line.split(" ")
  window.call({"REQUEST_URI"  => line[6],
               "HTTP_REFERER" => line[10][1..-2]})
end

# Then we fake a stats request:

window.call({"REQUEST_URI" => "/stats/pages.svg"}).each do |line|
  puts line
end

