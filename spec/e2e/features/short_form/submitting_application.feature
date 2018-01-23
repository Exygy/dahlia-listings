Feature: Short Form Application
    As a web user
    I should be able to fill out the short form application
    In order to apply online to a listing

    Scenario: Submitting a basic application, creating an account on the confirmation page
      Given I go to the first page of the Test Listing application
      When I fill out the Name page as "Jane Doe"
      And I fill out the Contact page with an address (non-NRHP match) and WorkInSF
      And I confirm my address
      And I don't indicate an alternate contact
      And I indicate I will live alone
      And I indicate living in public housing
      And I indicate no ADA priority
      And I indicate having vouchers
      And I fill out my income as "25000"
      And I continue past the Lottery Preferences intro
      And I opt out of Assisted Housing preference
      And I opt out of Live/Work preference
      And I don't choose COP/DTHP preferences
      And I continue past the general lottery notice page
      And I fill out the optional survey
      And I confirm details on the review page
      And I continue confirmation without signing in
      And I agree to the terms and submit
      Then I should see my lottery number on the confirmation page
      # now that we've submitted, also create an account
      When I click the Create Account button
      And I fill out my account info with my locked-in application email
      And I wait "18" seconds
      And I submit the Create Account form
      Then I should be on the login page with the email confirmation popup

    Scenario: Leaving the application pops up a modal
      Given I go to the first page of the Test Listing application
      When I try to navigate to the Favorites page
      And I cancel the modal pop-up
      Then I should still be on the Test Listing application page
      Given I try to navigate to the Favorites page
      When I confirm the modal
      Then I should see the Favorites page

    Scenario: Filling out all details of application and saving draft
      Given I go to the first page of the Test Listing application
      # you
      When I fill out the Name page as "Jane Valerie Doe"
      And I fill out the Contact page with my account email, address (NRHP match), mailing address
      And I confirm my address
      And I fill out an alternate contact
      # household
      And I indicate living with other people
      And I add another household member named "Coleman Francis" with same address as primary
      And I indicate being done adding people
      And I indicate not living in public housing
      And I enter "4000" for each of my monthly rents
      And I indicate ADA Mobility and Vision impairments
      # income
      And I do not indicate having vouchers
      And I fill out my income as "72000"
      # preferences
      And I continue past the Lottery Preferences intro

      And I select Rent Burdened Preference
      And I upload a Copy of Lease and "Money order" as my proof for Rent Burden
      And I hit the Next button "1" time

      And I select "Jane Doe" for "neighborhoodResidence" preference
      And I upload a "Gas bill" as my proof of preference for "neighborhoodResidence"
      And I click the Next button on the Live in the Neighborhood page

      And I select "Jane Doe" for "certOfPreference" preference
      And I fill out my "certOfPreference" certificate number
      And I select "Coleman Francis" for "displaced" preference
      And I fill out my "displaced" certificate number
      And I submit my preferences
      # review
      And I fill out the optional survey
      # confirm everything has shown up
      Then on the Review Page I should see my contact details
      Then on the Review Page I should see my alternate contact details
      Then on the Review Page I should see my household member details
      Then on the Review Page I should see my income details
      Then on the Review Page I should see my preference details on my "draft" application
      And I click the Save and Finish Later button
      And I fill out my account info
      And I submit the Create Account form
      Then I should be on the login page with the email confirmation popup

    Scenario: Filling out anonymous draft, reaching Choose Draft page
      Given I have a confirmed account
      And I go to the first page of the Test Listing application
      And I fill out the Name page as "Thomas Huckleberry Sawyer"
      And I click the Save and Finish Later button
      And I click the Sign In button
      And I sign in
      Then I should be on the Choose Draft page
      When I select my original application and submit
      Then I should land on the My Applications page

    Scenario: Logging into account (created in earlier scenario), continuing saved application
      Given I go to the Sign In page
      And I sign in
      And I go to My Applications
      And I click the Continue Application button
      # I should land back on the Review page where I clicked "save and finish later"
      Then on the Review Page I should see my contact details

    Scenario: Continuing draft, confirming all previously entered details and submitting
      Given I go to My Applications
      And I click the Continue Application button
      # you
      And I navigate to the "You" section
      Then on the Name page I should see my correct info for "Jane Valerie Doe"
      Then on the Contact page I should see my correct info
      Then on the Alternate Contact pages I should see my correct info
      # household
      Then on the Household page I should see my correct info
      And I indicate being done adding people
      Then on the Public Housing page I should see my correct info
      Then on the Monthly Rent page I should see my correct info
      Then on the ADA Priorities page I should see my correct info
      # income
      Then on the Income pages I should see my correct info
      # preferences
      And I continue past the Lottery Preferences intro
      Then on the Rent Burdened page I should see my correct info
      Then on the Live in the Neighborhood page I should see my correct info
      Then on the Preferences Programs page I should see my correct info

      # review
      Then on the optional survey page I should see my correct info
      # confirm everything has shown up (again)
      Then on the Review Page I should see my contact details
      Then on the Review Page I should see my alternate contact details
      Then on the Review Page I should see my household member details
      Then on the Review Page I should see my income details
      Then on the Review Page I should see my preference details on my "draft" application

      When I confirm details on the review page
      And I agree to the terms and submit
      Then I should see my lottery number on the confirmation page
      And I view the application from My Applications
      # then confirm one last time how things appear on the submitted app
      Then on the Review Page I should see my contact details
      Then on the Review Page I should see my alternate contact details
      Then on the Review Page I should see my household member details
      Then on the Review Page I should see my income details
      Then on the Review Page I should see my preference details on my "submitted" application

    Scenario: Signing out
      When I sign out
      Then I should land on the Sign In page
      Then I should see the sign out success message
