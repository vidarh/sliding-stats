$: << File.expand_path(File.dirname(__FILE__)+"/../../lib/")
require 'sliding-stats'

def valid_request
  {"HTTP_REFERER" => "valid_referer",
    "REQUEST_URI" => "valid_uri"}
end

Given /^there is a limit of (\d+) requests in the window$/ do |n|
  @window = SlidingStats::Window.new(Proc.new {},
                                     {:limit => n})
end

When /^I add (\d+) request[s]? that are not excluded to the window$/ do |n|
end

Then /^there should be (\d+) pageview[s]? in the window$/ do |n|
  @window.stats.pages.to_a.inject(0) {|s,a| s+a[1]} == n.to_i
end

Then /^there should be (\d+) referrer[s]? in the window$/ do |n|
  @window.stats.referers.to_a.inject(0) {|s,a| s+a[1]} == n.to_i
end

