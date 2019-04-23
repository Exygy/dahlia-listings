remote = require('selenium-webdriver/remote')

PageUtil = {
  testListingId: 'a0W0P00000F8YG4UAN'
  goTo: (url) ->
    browser.get(url)
  scrollToElement: (element) ->
    browser.actions().mouseMove(element).perform()
}

module.exports = PageUtil
