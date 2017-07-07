World = require('../world.coffee').World
Chance = require('chance')
chance = new Chance()
EC = protractor.ExpectedConditions

# QA "280 Fell"
listingId = 'a0W0P00000DZTkAUAX'
sessionEmail = chance.email()
janedoeEmail = chance.email()
accountPassword = 'password123'

# reusable functions
fillOutNamePage = (fullName, opts = {}) ->
  firstName = fullName.split(' ')[0]
  lastName  = fullName.split(' ')[1]
  month = opts.month || '02'
  day = opts.day || '22'
  year = opts.year || '1990'

  element(By.model('applicant.firstName')).clear().sendKeys(firstName)
  element(By.model('applicant.lastName')).clear().sendKeys(lastName)
  element(By.model('applicant.dob_month')).clear().sendKeys(month)
  element(By.model('applicant.dob_day')).clear().sendKeys(day)
  element(By.model('applicant.dob_year')).clear().sendKeys(year)
  submitPage()

fillOutContactPage = (opts = {}) ->
  opts.address1 ||= '4053 18th St.'
  element(By.model('applicant.phone')).clear().sendKeys('2222222222')
  element(By.model('applicant.phoneType')).sendKeys('home')
  element(By.model('applicant.email')).clear().sendKeys(opts.email) if opts.email
  element(By.id('applicant_home_address_address1')).clear().sendKeys(opts.address1)
  element(By.id('applicant_home_address_city')).clear().sendKeys('San Francisco')
  element(By.id('applicant_home_address_state')).sendKeys('california')
  element(By.id('applicant_home_address_zip')).clear().sendKeys('94114')
  element(By.id('workInSf_yes')).click()
  submitPage()

fillOutSurveyPage = ->
  element(By.id('referral_newspaper')).click()
  submitPage()

getSelectedLiveMember = () ->
  liveInSfMember = element.all(By.id('liveInSf_household_member')).filter((elem) ->
    elem.isDisplayed()
  ).first()

submitPage = ->
  element(By.id('submit')).click()

optOutAndSubmit = ->
  # opt out + submit preference page (e.g. NRHP, Live/Work)
  element(By.id('preference-optout')).click()
  submitPage()

getUrlAndCatchPopup = (url) ->
  # always catch and confirm popup alert in case we are leaving an existing application
  # (i.e. from a previous test)
  browser.get(url).catch ->
    browser.switchTo().alert().then (alert) ->
      alert.accept()
      browser.get(url)

submitPage = () ->
  element(By.id('submit')).click()

module.exports = ->
  # import global cucumber options
  @World = World

  @Given 'I go to the first page of the Test Listing application', ->
    url = "/listings/#{listingId}/apply/name"
    getUrlAndCatchPopup(url)

  @Given 'I go to the welcome page of the Test Listing application', ->
    url = "/listings/#{listingId}/apply-welcome/intro"
    getUrlAndCatchPopup(url)

  @Given 'I have a confirmed account', ->
    # confirm the account
    browser.ignoreSynchronization = true
    url = "/api/v1/account/confirm/?email=#{sessionEmail}"
    getUrlAndCatchPopup(url)
    browser.ignoreSynchronization = false

  @When /^I select "([^"]*)" as my language$/, (language) ->
    switch language
      when "Spanish"
        element(By.id('submit-es')).click()
      when "English"
        element(By.id('submit-en')).click()

  @When 'I continue past the community screening and welcome overview', ->
    element(By.id('answeredCommunityScreening_yes')).click()
    # community screening
    submitPage()
    # welcome overview
    submitPage()

  @When /^I fill out the Name page as "([^"]*)"$/, (fullName) ->
    fillOutNamePage(fullName)

  @When 'I submit the Name page with my account info', ->
    submitPage()

  @When 'I fill out the Contact page with an address (non-NRHP match) and WorkInSF', ->
    fillOutContactPage({email: janedoeEmail})

  @When 'I fill out the Contact page with an address (NRHP match) and WorkInSF', ->
    fillOutContactPage({email: janedoeEmail, address1: '1222 Harrison St.'})

  @When 'I fill out the Contact page with my account email, an address (non-NRHP match) and WorkInSF', ->
    fillOutContactPage()

  @When 'I confirm my address', ->
    element(By.id('confirmed_home_address_yes')).click()
    submitPage()

  @When 'I don\'t indicate an alternate contact', ->
    element(By.id('alternate_contact_none')).click()
    submitPage()

  @When 'I indicate I will live alone', ->
    element(By.id('live-alone')).click()

  @When 'I indicate other people will live with me', ->
    element(By.id('other-people')).click()
    # also submit the household overview page
    submitPage()

  @When /^I add another household member named "([^"]*)"$/, (fullName) ->
    # click into the Add Household Member form
    element(By.id('add-member')).click()


    firstName = fullName.split(' ')[0]
    lastName  = fullName.split(' ')[1]
    element(By.model('householdMember.firstName')).sendKeys(firstName)
    element(By.model('householdMember.lastName')).sendKeys(lastName)
    element(By.model('householdMember.dob_month')).sendKeys('10')
    element(By.model('householdMember.dob_day')).sendKeys('04')
    element(By.model('householdMember.dob_year')).sendKeys('1985')
    element(By.id('hasSameAddressAsApplicant_yes')).click()
    element(By.id('workInSf_no')).click()
    element.all(By.cssContainingText('option', 'Spouse')).filter((elem) ->
      elem.isDisplayed()
    ).first().click()
    # finish adding member
    submitPage()

  @When 'I indicate being done adding other people', ->
    submitPage()

  @When 'I indicate living in public housing', ->
    element(By.id('hasPublicHousing_yes')).click()
    submitPage()

  @When 'I indicate not living in public housing', ->
    element(By.id('hasPublicHousing_no')).click()
    submitPage()

  @When /^I enter "([^"]*)" for my monthly rent$/, (monthlyRent) ->
    element(By.id('monthlyRent_0')).sendKeys(monthlyRent)
    submitPage()

  @When 'I indicate no priority', ->
    element(By.id('adaPrioritiesSelected_none')).click()
    submitPage()

  @When 'I go to the income page', ->
    submitPage()

  @When 'I indicate having vouchers', ->
    element(By.id('householdVouchersSubsidies_yes')).click()
    submitPage()

  @When 'I fill out my income', ->
    element(By.id('incomeTotal')).sendKeys('22000')
    element(By.id('per_year')).click()
    submitPage()

  @When 'I continue past the Lottery Preferences intro', ->
    submitPage()

  @When 'I opt out of Assisted Housing preference', ->
    optOutAndSubmit()

  @When 'I don\'t choose COP/DTHP preferences', ->
    # skip preferences programs
    submitPage()

  @When 'I continue past the general lottery notice', ->
    # also skip general lottery notice
    submitPage()

  @When 'I opt out of Live/Work preference', ->
    optOutAndSubmit()

  @When 'I opt out of NRHP preference', ->
    optOutAndSubmit()

  @When 'I select Rent Burden Preference', ->
    element(By.id('preferences-rentBurden')).click()


  @When /^I select "([^"]*)" for COP preference$/, (fullName) ->
    element(By.id('preferences-certOfPreference')).click()
    element.all(By.id('certOfPreference_household_member')).filter((elem) ->
      elem.isDisplayed()
    ).first().click()
    element.all(By.cssContainingText('option', fullName)).filter((elem) ->
      elem.isDisplayed()
    ).first().click()

  @When /^I select "([^"]*)" for DTHP preference$/, (fullName) ->
    element(By.id('preferences-displaced')).click()
    element.all(By.id('displaced_household_member')).filter((elem) ->
      elem.isDisplayed()
    ).last().click()
    element.all(By.cssContainingText('option', fullName)).filter((elem) ->
      elem.isDisplayed()
    ).last().click()

  @When 'I go to the income page', ->
    submitPage()

  @When /^I select "([^"]*)" for "([^"]*)" in Live\/Work preference$/, (fullName, preference) ->
    # select either Live or Work preference in the combo Live/Work checkbox
    element(By.id('preferences-liveWorkInSf')).click()
    element(By.id('liveWorkPrefOption')).click()
    element(By.cssContainingText('option', preference)).click()
    # select the correct HH member in the dropdown
    pref = (if preference == 'Live in San Francisco' then 'liveInSf' else 'workInSf')
    # there are multiple liveInSf_household_members, click the visible one
    element.all(By.id("#{pref}_household_member")).filter((elem) ->
      elem.isDisplayed()
    ).first().click()
    # there are multiple Jane Doe options, click the visible one matching fullName
    element.all(By.cssContainingText('option', fullName)).filter((elem) ->
      elem.isDisplayed()
    ).first().click()

  @When /^I upload a "([^"]*)" as my proof of preference$/, (documentType) ->
    # open the proof option selector and pick the indicated documentType
    element.all(By.id("liveInSf_proofDocument")).filter((elem) ->
      elem.isDisplayed()
    ).first().click()
    element.all(By.cssContainingText('option', documentType)).filter((elem) ->
      elem.isDisplayed()
    ).first().click()
    filePath = "#{process.env.PWD}/public/images/logo-city.png"
    element.all(By.css('input[type="file"]')).then( (items) ->
      items[0].sendKeys(filePath)
    )
    browser.sleep(5000)

  @When 'I click the Next button on the Live/Work Preference page', ->
    element.all(By.id("submit")).filter((elem) ->
      elem.isDisplayed()
    ).first().click()

  @When 'I go back to the Contact page and change WorkInSF to No', ->
    element(By.cssContainingText('.progress-nav_item', 'You')).click()
    submitPage()
    element(By.id('workInSf_no')).click()

  @When 'I go back to the Live/Work preference page', ->
    element(By.cssContainingText('.progress-nav_item', 'Preferences')).click()
    # skip intro
    submitPage()
    # skip NRHP (if exists)
    if element(By.id('preferences-neighborhoodResidence'))
      submitPage()

  @When 'I submit my preferences', ->
    submitPage()

  @When 'I fill out the optional survey', ->
    fillOutSurveyPage()

  @When 'I confirm details on the review page', ->
    submitPage()

  @When 'I continue confirmation without signing in', ->
    element(By.id('confirm_no_account')).click()

  @When 'I agree to the terms and submit', ->
    element(By.id('terms_yes')).click()
    submitPage()

  @When 'I click the Save and Finish Later button', ->
    element(By.id('save_and_finish_later')).click()

  @When 'I click the Create Account button', ->
    element(By.id('create-account')).click()

  @When 'I fill out my account info', ->
    element(By.id('auth_email')).sendKeys(sessionEmail)
    element(By.id('auth_email_confirmation')).sendKeys(sessionEmail)
    element(By.id('auth_password')).sendKeys(accountPassword)
    element(By.id('auth_password_confirmation')).sendKeys(accountPassword)

  @When 'I fill out my account info with my locked-in application email', ->
    element(By.id('auth_email_confirmation')).sendKeys(janedoeEmail)
    element(By.id('auth_password')).sendKeys(accountPassword)
    element(By.id('auth_password_confirmation')).sendKeys(accountPassword)

  @When 'I submit the Create Account form', ->
    submitPage()
    browser.waitForAngular()

  @When /^I wait "([^"]*)" seconds/, (delay) ->
    # pause before continuing
    delay = parseInt(delay) * 1000
    browser.sleep(delay)

  @When 'I sign in', ->
    signInUrl = "/sign-in"
    getUrlAndCatchPopup(signInUrl)
    element(By.id('auth_email')).sendKeys(sessionEmail)
    element(By.id('auth_password')).sendKeys(accountPassword)
    element(By.id('sign-in')).click()
    browser.waitForAngular()

  @When 'I view the application from My Applications', ->
    element(By.cssContainingText('.button', 'Go to My Applications')).click()
    element(By.cssContainingText('.button', 'View Application')).click()
    browser.waitForAngular()

  @When 'I go to My Applications', ->
    element(By.cssContainingText('.dash-item', 'My Applications')).click()
    browser.waitForAngular()

  @When 'I click the Continue Application button', ->
    element(By.cssContainingText('.feed-item-action a', 'Continue Application')).click()
    browser.waitForAngular()

  @When 'I use the browser back button', ->
    browser.navigate().back()

  @When 'I go to the listings page in Spanish', ->
    getUrlAndCatchPopup('/es/listings')

  @When /^I navigate to the "([^"]*)" section$/, (section) ->
    element.all(By.css('.progress-nav'))
      .all(By.linkText(section.toUpperCase()))
      .first()
      .click()
    browser.waitForAngular()

  #######################
  # --- Error cases --- #
  #######################

  @When "I don't fill out the Name page", ->
    submitPage()

  @When "I fill out the Name page with non-latin characters", ->
    element(By.model('applicant.firstName')).sendKeys('Jane中文')
    element(By.id('submit')).click()

  @When "I fill out the Name page with an invalid DOB", ->
    fillOutNamePage( 'Jane Doe', {
      month: '12'
      day: '33'
      year: '2019'
    })

  @When "I fill out the Contact page with an address that isn't found", ->
    fillOutContactPage({email: janedoeEmail, address1: '38383 Philz Way'})

  @When "I don't select opt out or Live/Work preference", ->
    submitPage()


  ########################
  # --- Expectations --- #
  ########################

  @Then 'I should see the Preferences Programs screen', ->
    certificateOfPreferenceLabel = element(By.cssContainingText('strong', 'Certificate of Preference (COP)'))
    @expect(certificateOfPreferenceLabel.isPresent()).to.eventually.equal(true)

  @Then 'I should see the successful file upload info', ->
    attachmentUploaded = element.all(By.id('successful-upload')).filter((elem) ->
      elem.isDisplayed()
    ).first()
    @expect(attachmentUploaded.isPresent()).to.eventually.equal(true)

  @Then 'I should see my lottery number on the confirmation page', ->
    lotteryNumberMarkup = element(By.id('lottery_number'))
    @expect(lotteryNumberMarkup.isPresent()).to.eventually.equal(true)

  @Then 'I should be on the login page with the email confirmation popup', ->
    confirmationPopup = element(By.id('confirmation_needed'))
    @expect(confirmationPopup.isPresent()).to.eventually.equal(true)

  @Then 'I should still see the single Live in San Francisco preference selected', ->
    liveInSf = element(By.id('preferences-liveInSf'))
    browser.wait(EC.elementToBeSelected(liveInSf), 5000)

  @Then 'I should still see the preference options and uploader input visible', ->
    # there are multiple liveInSf_household_members, click the visible one
    liveInSfMember = getSelectedLiveMember()
    # expect the member selection field to still be there
    @expect(liveInSfMember.isPresent()).to.eventually.equal(true)

  @Then 'I should see proof uploaders for rent burden files', ->
    # expect the rentBurdenPreference component to render with the proof uploaders inside, rather than the dashboard
    uploader = element(By.model('$ctrl.proofDocument.file.name'))
    @expect(uploader.isPresent()).to.eventually.equal(true)

  @Then 'I should see my draft application with a Continue Application button', ->
    continueApplication = element(By.cssContainingText('.feed-item-action a', 'Continue Application'))
    @expect(continueApplication.isPresent()).to.eventually.equal(true)

  @Then 'I should see my name, DOB, email, COP and DTHP options all displayed as expected', ->
    appName = element(By.id('full-name'))
    @expect(appName.getText()).to.eventually.equal('JANE DOE')
    appDob = element(By.id('dob'))
    @expect(appDob.getText()).to.eventually.equal('2/22/1990')
    appEmail = element(By.id('email'))
    @expect(appEmail.getText()).to.eventually.equal(sessionEmail.toUpperCase())
    certOfPref = element(By.cssContainingText('.info-item_name', 'Certificate of Preference (COP)'))
    @expect(certOfPref.isPresent()).to.eventually.equal(true)
    DTHP = element(By.cssContainingText('.info-item_name', 'Displaced Tenant Housing Preference (DTHP)'))
    @expect(DTHP.isPresent()).to.eventually.equal(true)

  @Then /^I should see "([^"]*)" selected in the short form language switcher$/, (language) ->
    activeLang = element(By.cssContainingText('li.active.lined-nav_item', language))
    @expect(activeLang.isPresent()).to.eventually.equal(true)

  @Then 'I should be redirected back to the listings page in English', ->
    # we check that it is at the ":3000/listings" URL rather than ":3000/es/listings"
    browser.wait(EC.urlContains(':3000/listings'), 6000)

  @Then /^I should see "([^"]*)" preference claimed for "([^"]*)"$/, (preference, name) ->
    claimedPreference = element(By.cssContainingText('.info-item_name', preference))
    @expect(claimedPreference.isPresent()).to.eventually.equal(true)
    claimedMember = element(By.cssContainingText('.info-item_note', name))
    @expect(claimedMember.isPresent()).to.eventually.equal(true)

    preferenceMember = element(By.cssContainingText('.info-item_note', name))
    @expect(preferenceMember.isPresent()).to.eventually.equal(true)


  ###################################
  # --- Error case expectations --- #
  ###################################

  # helper functions
  expectAlertBox = (context, errorText = "You'll need to resolve any errors") ->
    alertBox = element(By.cssContainingText('.alert-box', errorText))
    context.expect(alertBox.isPresent()).to.eventually.equal(true)

  expectError = (context, errorText) ->
    error = element(By.cssContainingText('.error', errorText))
    context.expect(error.isPresent()).to.eventually.equal(true)

  @Then 'I should see name field errors on the Name page', ->
    expectAlertBox(@)
    expectError(@, 'Please enter a First Name')

  @Then 'I should see an error about providing answers in English on the Name page', ->
    expectAlertBox(@)
    expectError(@, 'Please provide your answers in English')

  @Then 'I should see DOB field errors on the Name page', ->
    expectAlertBox(@)
    expectError(@, 'Please enter a valid Date of Birth')

  @Then 'I should see an address error on the Contact page', ->
    expectAlertBox(@)
    expectError(@, 'This address was not found.')

  @Then 'I should see an error about selecting an option', ->
    expectAlertBox(@, 'Please select and complete one of the options below in order to continue')
    expectError(@, 'Please select one of the options above')
