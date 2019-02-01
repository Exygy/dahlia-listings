Feature: Listings
    As a web user
    I should be able to view a listing

    Scenario: Attempting to go to a listing page using an invalid ID
      Given I try to go to a listing page with an invalid ID
      Then I should be redirected to the welcome page

    Scenario: Attempting to go to the Ownership listings page
      Given I try to go to the Ownership listings page
      Then I should see available units
