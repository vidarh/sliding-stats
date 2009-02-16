$: << File.expand_path(File.dirname(__FILE__)+"/../../lib/")
require 'sliding-stats'

def valid_request
  {"HTTP_REFERER" => "valid_referer",
    "REQUEST_URI" => "valid_uri"}
end

Given /^there are (\d+) requests in the stats$/ do |n|
  r = []
  n.to_i.times { r << valid_request }
  @stats = SlidingStats::Stats.new([],{},{})
end

When /^I add (\d+) request[s]? that are not excluded$/ do |n|
  n.to_i.times { @stats.add(valid_request) }
end

When /^I remove (\d+) request[s]? that are not excluded$/ do |n|
  n.to_i.times { @stats.sub(valid_request) }
end

Then /^there should be (\d+) pageview[s]?$/ do |n|
  @stats.pages.to_a.inject(0) {|s,a| s+a[1]} == n.to_i
end

Then /^there should be (\d+) referrer[s]?$/ do |n|
  @stats.referers.to_a.inject(0) {|s,a| s+a[1]} == n.to_i
end

