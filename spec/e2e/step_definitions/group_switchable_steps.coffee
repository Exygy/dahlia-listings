World = require('../world.coffee')
Utils = require('../utils')
{ Given, When, Then, setWorldConstructor } = require('cucumber')

setWorldConstructor(World)

Given 'I go to the SMC group homepage', ->
  url = "/?switch_domain=#{Utils.Page.smcDomain}"
  Utils.Page.goTo(url)

When 'I view a different group homepage', ->
  url = "/?switch_domain=#{Utils.Page.testDomain}"
  Utils.Page.goTo(url)

When 'I click on the footer Disclaimer link', ->
  element(By.cssContainingText('a', 'Disclaimer')).click()

When 'I click on the footer Privacy Policy link', ->
  element(By.cssContainingText('a', 'Privacy Policy')).click()

Then 'I should see the correct SMC group site title', ->
  topTitle = element(By.cssContainingText('.name-logo .header-logo-group', 'San Mateo County'))
  @expect(topTitle.isPresent()).to.eventually.equal(true)

Then 'I should see the correct second group site title', ->
  topTitle = element(By.cssContainingText('.name-logo .header-logo-group', 'Test Group'))
  @expect(topTitle.isPresent()).to.eventually.equal(true)

Then 'I should see the SMC Disclaimer headline', ->
  smcDisclaimerHeadline = element(By.cssContainingText('h1.lead-header_title', 'Endorsement Disclaimers'))
  @expect(smcDisclaimerHeadline.isPresent()).to.eventually.equal(true)

Then 'I should see the SMC Privacy Policy headline', ->
  smcDisclaimerHeadline = element(By.cssContainingText('h1.lead-header_title', 'Privacy Policy'))
  @expect(smcDisclaimerHeadline.isPresent()).to.eventually.equal(true)
