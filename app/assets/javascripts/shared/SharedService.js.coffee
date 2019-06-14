############################################################################################
####################################### SERVICE ############################################
############################################################################################

SharedService = ($http, $state, $window, $document) ->
  Service = {}
  Service.assetPaths = $window.STATIC_ASSET_PATHS || {}
  Service.currentGroup = document.body.dataset.group
  Service.housingCounselors =
    all: []
  # email regex source: https://web.archive.org/web/20080927221709/http://www.regular-expressions.info/email.html
  # using an RFC 2822 compliant regex, not RFC 5322, in order to match Salesforce's email regex which complies w/ 2822
  Service.emailRegex = new RegExp([
    "[a-zA-Z0-9!#$%&'*+\\/=?^_`{|}~-]+(?:\\.[a-zA-Z0-9!#$%&'*+\\/=?^_`{|}~-]+)*",
    '@',
    '(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?\\.)+[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?'
  ].join(''))

  # method adapted from:
  # https://www.bignerdranch.com/blog/web-accessibility-skip-navigation-links
  Service.focusOn = (id) ->
    toFocus = document.getElementById(id)
    return unless toFocus
    angularElement = angular.element(toFocus)
    Service.focusOnElement(angularElement)
    $document.scrollToElement(angularElement)

  Service.focusOnElement = (el) ->
    return unless el
    # Setting 'tabindex' to -1 takes an element out of normal tab flow
    # but allows it to be focused via javascript
    el.attr 'tabindex', -1
    el.on 'blur focusout', ->
      # when focus leaves this element, remove the tabindex
      angular.element(@).removeAttr('tabindex')
    el[0].focus()

  Service.focusOnBody = ->
    body = angular.element(document.body)
    Service.focusOnElement(body)

  Service.getHousingCounselors = ->
    housingCounselorJsonPath = Service.assetPaths['housing_counselors.json']
    # if we've already loaded this asset, no need to reload
    return if Service.housingCounselors.loaded == housingCounselorJsonPath
    $http.get(housingCounselorJsonPath).then((response) ->
      data = response.data
      Service.housingCounselors.all = data.locations
      Service.housingCounselors.loaded = housingCounselorJsonPath
    )

  Service.onDocChecklistPage = ->
    $state.current.name == "dahlia.document-checklist"

  Service.toQueryString = (params) ->
    Object.keys(params).reduce(((a, k) ->
      a.push k + '=' + encodeURIComponent(params[k])
      a
    ), []).join '&'

  return Service


############################################################################################
######################################## CONFIG ############################################
############################################################################################

SharedService.$inject = ['$http', '$state', '$window', '$document']

angular
  .module('dahlia.services')
  .service('SharedService', SharedService)
