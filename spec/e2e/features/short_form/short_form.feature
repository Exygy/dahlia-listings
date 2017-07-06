Feature: Short Form Application
    As a web user
    I should be able to fill out the short form application
    In order to apply online to a listing

    Scenario: Seeing errors while filling out the form with missing or bad data
      Given I go to the first page of the Test Listing application
      When I don't fill out the Name page
      # error: not filling out the first page
      Then I should see name field errors on the Name page
      When I fill out the Name page with an invalid DOB
      # error: invalid DOB
      Then I should see DOB field errors on the Name page
      When I fill out the Name page as "Jane Doe"
      And I fill out the Contact page with an address that isn't found
      # error: address not found
      Then I should see an address error on the Contact page
      When I fill out the Contact page with an address (non-NRHP match) and WorkInSF
      And I confirm my address
      And I don't indicate an alternate contact
      And I indicate I will live alone
      And I indicate living in public housing
      And I indicate no priority
      And I indicate having vouchers
      And I fill out my income
      And I continue past the Lottery Preferences intro
      And I don't select opt out or Live/Work preference
      # error: preference option not chosen
      Then I should see an error about selecting an option

    Scenario: Submitting a basic application, creating an account on the confirmation page
      Given I go to the first page of the Test Listing application
      When I fill out the Name page as "Jane Doe"
      And I fill out the Contact page with an address (non-NRHP match) and WorkInSF
      And I confirm my address
      And I don't indicate an alternate contact
      And I indicate I will live alone
      And I indicate living in public housing
      And I indicate no priority
      And I indicate having vouchers
      And I fill out my income
      And I continue past the Lottery Preferences intro
      And I opt out of Live/Work preference
      And I opt out of Assisted Housing preference
      And I don't choose COP/DTHP preferences
      And I continue past the general lottery notice
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

    Scenario: Being eligible for Rent Burden preference with a single address
      Given I go to the first page of the Test Listing application
      When I fill out the Name page as "Jane Doe"
      And I fill out the Contact page with an address (non-NRHP match) and WorkInSF
      And I confirm my address
      And I don't indicate an alternate contact
      And I indicate other people will live with me
      And I add another household member named "Jonny Doe"
      And I indicate being done adding other people
      And I indicate not living in public housing
      And I enter "1200" for my monthly rent
      And I indicate no priority
      And I indicate having vouchers
      And I fill out my income
      And I continue past the Lottery Preferences intro
      And I opt out of Live/Work preference
      And I select Rent Burden Preference
      Then I should see proof uploaders for rent burden files
      # as opposed to seeing rent burden dashboard, which could be its own test...

    Scenario: Creating an account in order to "Save and Finish Later"
      Given I go to the first page of the Test Listing application
      When I fill out the Name page as "Jane Doe"
      And I click the Save and Finish Later button
      And I fill out my account info
      And I submit the Create Account form
      Then I should be on the login page with the email confirmation popup

    Scenario: Logging into account (created in earlier scenario), submitting and viewing saved application
      Given I have a confirmed account
      When I sign in
      And I go to My Applications
      Then I should see my draft application with a Continue Application button
      # now submit the application
      When I click the Continue Application button
      And I submit the Name page with my account info
      And I fill out the Contact page with my account email, an address (non-NRHP match) and WorkInSF
      And I confirm my address
      And I don't indicate an alternate contact
      And I indicate I will live alone
      And I indicate living in public housing
      And I indicate no priority
      And I indicate having vouchers
      And I fill out my income
      And I continue past the Lottery Preferences intro
      And I opt out of Live/Work preference
      And I opt out of Assisted Housing preference
      And I select "Jane Doe" for COP preference
      And I select "Jane Doe" for DTHP preference
      And I submit my preferences
      And I fill out the optional survey
      And I confirm details on the review page
      And I agree to the terms and submit
      And I view the application from My Applications
      Then I should see my name, DOB, email all displayed as expected
      Then I should see my name, DOB, email, COP and DTHP options all displayed as expected
      #
      # NOTE: if any Scenarios are added after this one, you may have to create a "sign out" step
      #
