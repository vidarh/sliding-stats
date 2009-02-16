
Feature: Maintain a sliding window
  In order to keep an eye on traffic the
  Window class must maintain a sliding window
  with an upper size limit at all times.

  Scenario Outline: Adding requests
	Given there is a limit of <limit> requests in the window
	When I add <requests> requests that are not excluded to the window
	Then there should be <total> pageviews in the window
	And there should be <total> referrers in the window

  Examples:
	| limit | requests | total |
    |   0   |    1     |   0   |
    |   5   |    3     |   3   |
    |   5   |    5     |   5   |
    |   5   |   10     |   5   |

