Feature: Custom Params
  Scenario:
    Given I live in New York and need to travel to Istanbul arriving before Friday, 21 July 2017
     When I input all these details into the UI
     Then I will see: Take LHRL-OSL from New York to Istanbul on Wednesday, 19 July 2017 at 13:40 to arrive by Thursday, 20 July 2017 at 09:00 for a total flight time of 17 hours at a discounted price of 2500 USD in total
