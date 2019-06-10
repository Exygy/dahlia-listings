remote = require('selenium-webdriver/remote')

PageUtil = {
  testListingId: '2'
  smcDomain: 'smc.housingbayarea.org'
  testDomain: 'localhost'
  goTo: (url) ->
    browser.get(url)
  scrollToElement: (element) ->
    browser.actions().mouseMove(element).perform()
}

module.exports = PageUtil
