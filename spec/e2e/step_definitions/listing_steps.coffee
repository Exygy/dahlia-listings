World = require('../world.coffee')
Utils = require('../utils')
{ Given, When, Then, setWorldConstructor } = require('cucumber')

setWorldConstructor(World)

Given 'I try to go to a listing page with an invalid ID', ->
  url = '/listings/foofoofoofoo'
  Utils.Page.goTo(url)

Given /^I go to the "([^"]*)" listing page$/, (listing) ->
  url = switch listing
    when 'Test Listing'
      "/listings/#{Utils.Page.testListingId}"
  Utils.Page.goTo(url)

When 'I click the Download Application button', ->
  element.all(By.id('download-application')).filter((elem) ->
    elem.isDisplayed()
  ).first().click()

Given 'I go to the welcome page', ->
  Utils.Page.goTo('/')

When 'I click the Rent link', ->
  element(By.cssContainingText('.button', 'Rent')).click()
  browser.waitForAngular()

######################
# --- Expectations --- #
######################

Then 'I should be redirected to the welcome page', ->
  welcomeComponent = element(By.tagName('welcome-component'))
  @expect(welcomeComponent.isPresent()).to.eventually.equal(true)

Then 'I should see available units', ->
  propertyCard = element(By.tagName('property-card'))
  @expect(propertyCard.isPresent()).to.eventually.equal(true)

Then 'I should see at least one paper application download link', ->
  paperApplicationDownloadLink = element(By.className('paper-application-download'))
  @expect(paperApplicationDownloadLink.isPresent()).to.eventually.equal(true)

Then 'I should see the Rent link', ->
  rentLink = element(By.cssContainingText('.button', 'Rent'))
  @expect(rentLink.isPresent()).to.eventually.equal(true)

Then 'I should be on the Rental listings page', ->
  @expect(browser.getCurrentUrl()).to.eventually.contain('/listings')
