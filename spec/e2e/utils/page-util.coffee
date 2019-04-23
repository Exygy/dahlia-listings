remote = require('selenium-webdriver/remote')

PageUtil = {
  testListingId: 'a0W0P00000F8YG4UAN'
  seniorListingId: 'a0W0P00000GwGl3'
  saleListingId: process.env.TEST_SALE_LISTING_ID || 'a0W0P00000GlKfBUAV'
  goTo: (url) ->
    browser.get(url)
  scrollToElement: (element) ->
    browser.actions().mouseMove(element).perform()
}

module.exports = PageUtil
