Feature: Switching Groups
    As a web user
    I should be able to view the right group site

    Scenario: Attempting to view a group site
      Given I try to view the group homepage
      Then I should see the correct group site title
      And I view a different group homepage
      Then I should see the correct second group site title

    Scenario: Seeing common content across groups
      Given I try to view the group homepage
      Then I should see a common headline
      And I view a different group homepage
      Then I should see a common headline