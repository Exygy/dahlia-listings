{ When } = require('cucumber')

When 'I pause', ->
  browser.pause()

When 'I use the browser back button', ->
  browser.navigate().back()

When /^I wait "([^"]*)" seconds/, (delay) ->
  # pause before continuing
  delay = parseInt(delay) * 1000
  browser.sleep(delay)

