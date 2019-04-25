remote = require('selenium-webdriver/remote')

PageUtil = {
  testListingId: '1'
  goTo: (url) ->
    browser.get(url)
  scrollToElement: (element) ->
    browser.actions().mouseMove(element).perform()
}

module.exports = PageUtil
