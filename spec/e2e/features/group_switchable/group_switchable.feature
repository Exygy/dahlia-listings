Feature: Switching Groups
    As a web user
    I should be able to view the right group site

    Scenario: Going to a group homepage
      Given I go to the SMC group homepage
      Then I should see the correct SMC group site title
      And I view a different group homepage
      Then I should see the correct second group site title

    Scenario: Going to group Disclaimer and Privacy pages
      Given I go to the SMC group homepage
      And I click on the footer Disclaimer link
      Then I should see the SMC Disclaimer headline

      When I click on the footer Privacy Policy link
      Then I should see the SMC Privacy Policy headline
