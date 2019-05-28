World = require('../world.coffee')
Utils = require('../utils')
{ Given, When, Then, setWorldConstructor } = require('cucumber')

setWorldConstructor(World)

Given 'I go to the SMC group homepage', ->
  url = "/?switch_domain=#{Utils.Page.smcDomain}"
  Utils.Page.goTo(url)

Then 'I should see the correct SMC group site title', ->
  topTitle = element(By.cssContainingText('.name-logo .header-logo-group', 'San Mateo County'))
  @expect(topTitle.isPresent()).to.eventually.equal(true)

When 'I view a different group homepage', ->
  url = "/?switch_domain=#{Utils.Page.testDomain}"
  Utils.Page.goTo(url)

Then 'I should see the correct second group site title', ->
  topTitle = element(By.cssContainingText('.name-logo .header-logo-group', 'Test Group'))
  @expect(topTitle.isPresent()).to.eventually.equal(true)

Then 'I should see a common headline', ->
  mainHeadline = element(By.cssContainingText('h1.hero-title', 'Apply for affordable housing'))
  @expect(mainHeadline.isPresent()).to.eventually.equal(true)
