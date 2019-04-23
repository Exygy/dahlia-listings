@dahlia.config ['$httpProvider', ($httpProvider) ->
  $httpProvider.defaults.useXDomain = true
  delete $httpProvider.defaults.headers.common["X-Requested-With"]
  $httpProvider.defaults.headers.common["Accept"] = "application/json"
  $httpProvider.defaults.headers.common["Content-Type"] = "application/json"
  $httpProvider.defaults.headers.get = {}

  $httpProvider.interceptors.push [
    '$location', '$rootScope', '$injector', '$q',
    ($location, $rootScope, $injector, $q) ->

      return {
        # This is set up to universally capture HTTP errors, particularly 503
        # or 504, when a bad request / timeout occurred. It will pop up an alert
        # and stop the spinning loader so that the user can try again.
        responseError: (error) ->
          if error.status >= 500
            $injector.invoke [
              '$http', 'bsLoadingOverlayService', '$state',
              ($http, bsLoadingOverlayService, $state) ->
                bsLoadingOverlayService.stop()

                # don't display alerts in E2E tests
                return if window.protractor

                # AMI, lottery_ranking, unit data, preferences and lottery_buckets have their own handler
                return if error.config.url.match(RegExp('listings/ami|lottery_ranking|units|lottery_buckets'))

                if error.status == 504
                  # handle timeout errors
                  # if the timeout was encountered when trying to validate user token,
                  # don't show alert, instead redirect to sign in page
                  if (error.data.message.indexOf('user_token_validation') >= 0)
                    $state.go('dahlia.sign-in', {userTokenValidationTimeout: true})
                    return
                  else
                    # TODO: Resolve circular dependency that was caused by the previous version
                    # of the below line: $translate.instant('ERROR.ALERT.TIMEOUT_PLEASE_TRY_AGAIN')
                    alertMessage = "Timeout error. Please try again."
                else
                  # handle non-timeout errors
                  # TODO: Resolve circular dependency that was caused by the previous version
                  # of the below line: $translate.instant('ERROR.ALERT.BAD_REQUEST')
                  alertMessage = "Bad request."
                alert(alertMessage)
                error
            ]
          return $q.reject(error)
      }
  ]
]

@dahlia.config ['uiMask.ConfigProvider', (uiMaskConfigProvider) ->
  uiMaskConfigProvider.clearOnBlur(false)
  uiMaskConfigProvider.clearOnBlurPlaceholder(true)
]

# ng-idle configuration
@dahlia.config ['IdleProvider', 'TitleProvider', (IdleProvider, TitleProvider) ->
  # don't override the title with timeout countdowns/warnings
  TitleProvider.enabled(false)
  IdleProvider.idle(300)
  IdleProvider.timeout(60)
]

@dahlia.config ['$translateProvider', ($translateProvider) ->
  $translateProvider
    .preferredLanguage('ORG')
    .fallbackLanguage('ORG')
    .useSanitizeValueStrategy('sceParameters')
    .useLoader('assetPathLoader') # custom loader, see below
]

@dahlia.factory 'assetPathLoader', ['$q', '$http', '$window', ($q, $http, $window) ->
  (options) ->
    deferred = $q.defer()
    # asset paths have unpredictable hash suffixes, which is why we need the custom loader
    if options.key == 'ORG'
      organization = getCurrentOrganization()
      locale_path = "locale-#{organization}-en.json"
    else
      locale_path = "locale-#{options.key}.json"

    $http.get($window.STATIC_ASSET_PATHS[locale_path]).success((data) ->
      deferred.resolve(data)
    ).error( ->
      deferred.reject({status: 503})
    )
    return deferred.promise
]

@dahlia.config ['$titleProvider', ($titleProvider) ->
  $titleProvider.documentTitle ['$rootScope', ($rootScope) ->
    defaultTitle = 'DAHLIA San Francisco Housing Portal'
    if $rootScope.$title then "#{$rootScope.$title}  |  #{defaultTitle}" else defaultTitle
  ]
]

@dahlia.config ['httpEtagProvider', (httpEtagProvider) ->
  httpEtagProvider.defineCache 'persistentCache',
    cacheService: 'localStorage'
]

getAvailableStorageType = ->
  # When Safari (OS X or iOS) is in private browsing mode, it appears as though localStorage and sessionStorage
  # is available, but trying to call .setItem throws an exception below:
  # "QUOTA_EXCEEDED_ERR: DOM Exception 22: An attempt was made to add something to storage that exceeded the quota."
  key = '__' + Math.round(Math.random() * 1e7)
  try
    sessionStorage.setItem key, key
    sessionStorage.removeItem key
    return 'sessionStorage'
  catch e
    # private window can use cookies, they will just be cleared when you close the window
    return 'cookies'

getCurrentOrganization = ->
  return document.body.dataset.organization
