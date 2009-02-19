
Feature: Maintain stats
  In order to keep an eye on traffic the
  Stats Module must keep track of
  referrers and pages at all times.

  Scenario Outline: Adding requests
	Given there are <start> requests in the stats
	When I add <requests> requests that are not excluded
	Then there should be <total> pageviews
	And there should be <total> referrers

  Examples:
	| start | requests | total |
    |   5   |    1     |   6   |
    |  10   |   23     |  33   |
    |   0   |    5     |   5   |

  Scenario Outline: Removing requests
	Given there are <start> requests in the stats
	When I remove <requests> requests that are not excluded
	Then there should be <total> pageviews
	And there should be <total> referrers
    And there should be no pages rows with value 0
	And there should be no referers rows with value 0
	And there should be no rows with 0 in referers_to_pages
 
  Examples:
	| start | requests | total |
	|   0   |     1    |    0  |
    |   1   |     1    |    0  |
    |   3   |     2    |    1  |
    |   3   |     5    |    0  |
    
