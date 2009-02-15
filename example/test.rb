
# This demonstrates how to configure the stats and generates an SVG of 1000 requests by page.
# The exclusion patterns are geared towards my website, and so you'd want to adapt them.

require 'sliding-stats'

opts = {
  :limit => 1000,
  :persist => 10,
  :exclude_referers => [
    /http:\/\/www\.hokstad\.com/,             # Not interested in seeing internal clicks
    /http:\/\/search.live.com\/results.aspx/, # MSN referer spam
    /^-/
  ],
  :exclude_pages => [
    /\/referers/, /\/stats.*/,
    /\.xml/, /\/feed/, /\.rdf/, /\.ico/, /\/static\//,/\/robots.txt/
  ],
  :rewrite_referers =>
    [
    [/http:\/\/.*\.google\..*?[?&]q=([^&]*)?&*.*/,"Google Search: '\\1'"],
    [/http:\/\/www.google..*\/reader.*/,"Google Reader"]
    ]
}

view   = SlidingStats::View.new(nil,"/stats")
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

