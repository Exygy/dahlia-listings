@dahlia.run [
  '$rootScope', '$state', '$window', '$translate', '$document', '$timeout',
  'Idle', 'bsLoadingOverlayService', 'ngMeta',
  'AnalyticsService', 'ExternalTranslateService', 'SharedService',
  ($rootScope, $state, $window, $translate, $document, $timeout, Idle, bsLoadingOverlayService, ngMeta,
  AnalyticsService, ExternalTranslateService, SharedService) ->
    timeoutRetries = 2

    ngMeta.init()

    bsLoadingOverlayService.setGlobalConfig({
      delay: 0
      activeClass: 'loading'
      templateUrl: 'shared/templates/spinner.html'
    })

    $rootScope.$on '$stateChangeStart', (e, toState, toParams, fromState, fromParams) ->
      # always start the loading overlay
      bsLoadingOverlayService.start()

      if SharedService.isWelcomePage(toState)
        # on welcome pages, the language is determined by the language of the
        # welcome page, not by toParams.lang
        welcomePageLanguage = SharedService.getWelcomePageLanguage(toState.name).code
        ExternalTranslateService.setLanguage(welcomePageLanguage)

        if toParams.lang != welcomePageLanguage
          # if toState is a language welcome page and a different lang is set in the
          # params, reload the welcome page with the matching lang param. even though
          # toParams.lang doesn't determine the language set on a welcome page, we
          # still want the URL to appear consistent, e.g. the Spanish welcome page
          # path should always be 'es/welcome-spanish'
          e.preventDefault()
          $state.go(toState.name, {lang: welcomePageLanguage})

    $rootScope.$on '$stateChangeSuccess', (e, toState, toParams, fromState, fromParams) ->
      # always stop the loading overlay
      bsLoadingOverlayService.stop()

      SharedService.updateAlternateLanguageLinks()

      # track routes as we navigate EXCEPT for initial page load which is already tracked
      AnalyticsService.trackCurrentPage()

      ExternalTranslateService.setLanguage(toParams.lang)
      ExternalTranslateService.loadAPI().then ->
        # Wait until $digest is finished and all content on page has been updated
        # before triggering automated translation
        $timeout(ExternalTranslateService.translatePageContent, 0, false)

    $rootScope.$on '$viewContentLoaded', ->
      # Utility function to scroll to top of page when state changes
      $document.scrollTop(0)

      # After elements are rendered, make sure to re-focus keyboard input
      # on elements either at the top or on a designated section
      $timeout ->
        SharedService.focusOnBody()
      , 0, false

    $rootScope.$on '$stateChangeError', (e, toState, toParams, fromState, fromParams, error) ->
      # always stop the loading overlay
      bsLoadingOverlayService.stop()

      # fromState.name is empty on initial page load
      if fromState.name == ''
        if _.isObject(error) && error.status >= 500
          timeoutRetries -= 1
          # if timing out on initial page load, retry a couple times before giving up
          $window.location.href = '/500.html' if timeoutRetries <= 0

        # redirect when there's an error
        if toState.name == 'dahlia.listing' && error.status == 404
          return $state.go('dahlia.listings-for-rent')
        else
          return $state.go('dahlia.welcome')
]
