remote = require('selenium-webdriver/remote')

PageUtil = {
  testListingId: '1'
  smcDomain: 'herokuapp.com'
  testDomain: 'localhost'
  goTo: (url) ->
    browser.get(url)
  scrollToElement: (element) ->
    browser.actions().mouseMove(element).perform()
}

module.exports = PageUtil
