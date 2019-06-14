# Angular UI-router setup
@dahlia.config [
  '$stateProvider',
  '$urlRouterProvider',
  '$urlMatcherFactoryProvider',
  '$locationProvider',
  ($stateProvider, $urlRouterProvider, $urlMatcherFactoryProvider, $locationProvider) ->
    # allow trailing slashes and don't force case sensitivity on routes
    $urlMatcherFactoryProvider.caseInsensitive(true)
    $urlMatcherFactoryProvider.strictMode(false)

    $stateProvider
    .state('dahlia', {
      url: '/{lang:(?:en|es|tl|zh)}'
      abstract: true
      params:
        lang: { squash: true, value: 'en' }
        skipConfirm: { squash: true, value: false }
      views:
        'version@':
          templateUrl: 'shared/templates/version.html'
        'navigation@':
          templateUrl: 'shared/templates/nav/navigation.html'
          controller: 'NavController'
        'footer@':
          templateUrl: 'shared/templates/footer.html'
      data:
        meta:
          'description': 'Search and apply for affordable housing on the DAHLIA Housing Portal.'
      resolve:
        translations: ['$stateParams', '$translate', ($stateParams, $translate) ->
          # this should happen after preferredLanguage is initially set
          $translate.use($stateParams.lang)
        ]
        data: ['ngMeta', 'SharedService', (ngMeta, SharedService) ->
          img = SharedService.assetPaths['dahlia_social-media-preview.jpg']
          ngMeta.setTag('og:image', img)
        ]
    })
    # Home page
    .state('dahlia.welcome', {
      url: ''
      views:
        'container@':
          templateUrl: 'pages/templates/welcome.html'
      resolve:
        listing: ['$stateParams', 'ListingDataService', ($stateParams, ListingDataService) ->
          ListingDataService.getListings()
        ]
    })
    .state('dahlia.housing-counselors', {
      url: '/housing-counselors'
      views:
        'container@':
          templateUrl: 'pages/templates/housing-counselors.html',
      resolve:
        $title: ['$translate', ($translate) ->
          $translate('PAGE_TITLE.HOUSING_COUNSELORS')
        ]
        counselors: ['SharedService', (SharedService) ->
          SharedService.getHousingCounselors()
        ]
    })
    .state('dahlia.listings', {
      url: '/listings'
      views:
        'container@':
          templateUrl: 'listings/templates/listings.html'
      resolve:
        listings: ['$stateParams', 'ListingDataService', ($stateParams, ListingDataService) ->
          ListingDataService.getListings({retranslate: true, clearFilters: false})
        ]
        $title: ['$translate', ($translate) ->
          # translate used without ".instant" so that it will async resolve
          $translate('PAGE_TITLE.RENTAL_LISTINGS')
        ]
    })
    .state('dahlia.listing', {
      url: '/listings/:id?preview',
      params:
        skipConfirm: { squash: true, value: false }
        timeout: { squash: true, value: false }
        preview: null
      views:
        'container@':
          templateUrl: ($stateParams) ->
            # templateUrl is a special function that only takes $stateParams
            # which is why we can't include ListingDataService here
            if _.includes(MAINTENANCE_LISTINGS, $stateParams.id)
              'listings/templates/listing-maintenance.html'
            else
              'listings/templates/listing.html'
      resolve:
        listing: [
          '$stateParams', '$state', '$q', 'ListingDataService', 'ListingPreferenceService', 'ListingUnitService',
          ($stateParams, $state, $q, ListingDataService, ListingPreferenceService, ListingUnitService) ->
            deferred = $q.defer()
            forceRecache = $stateParams.preview
            ListingDataService.getListing($stateParams.id, forceRecache, true).then(() ->
              deferred.resolve(ListingDataService.listing)
              if _.isEmpty(ListingDataService.listing)
                # kick them out unless there's a real listing
                return $state.go('dahlia.welcome')
              if _.includes(MAINTENANCE_LISTINGS, $stateParams.id)
                return deferred.promise

              # trigger this asynchronously, allowing the listing page to load first
              setTimeout(ListingDataService.getListingAMI.bind(null, ListingDataService.listing))
              setTimeout(ListingUnitService.getListingUnits.bind(null, ListingDataService.listing, forceRecache))
              setTimeout(ListingPreferenceService.getListingPreferences.bind(null, ListingDataService.listing, forceRecache))
              setTimeout(ListingDataService.getListingPaperAppURLs.bind(null, ListingDataService.listing))
              # be sure to reset all relevant data in ListingDataService.resetListingData() if you add to this list !
            ).catch( (response) ->
              deferred.reject(response)
            )
            return deferred.promise
        ]
        $title: ['$title', 'listing', ($title, listing) ->
          listing.Name
        ]
        data: ['ngMeta', 'listing', (ngMeta, listing) ->
          desc = "Apply for affordable housing at #{listing.name} on the DAHLIA Housing Portal."
          ngMeta.setTag('description', desc)
          ngMeta.setTag('og:image', listing.image_url)
        ]
      # https://github.com/vinaygopinath/ngMeta#using-custom-data-resolved-by-ui-router
      meta:
        disableUpdate: true
    })
    .state('dahlia.disclaimer', {
      url: '/disclaimer'
      views:
        'container@':
          templateUrl: 'pages/templates/disclaimer.html'
      resolve:
        $title: ['$translate', ($translate) ->
          $translate('PAGE_TITLE.DISCLAIMER')
        ]
    })
    .state('dahlia.privacy', {
      url: '/privacy'
      views:
        'container@':
          templateUrl: 'pages/templates/privacy.html'
      resolve:
        $title: ['$translate', ($translate) ->
          $translate('PAGE_TITLE.PRIVACY')
        ]
    })
    .state('dahlia.get-assistance',{
      url: '/get-assistance'
      views:
        'container@':
          templateUrl: 'pages/templates/get-assistance.html'
      resolve:
        $title: ['$translate', ($translate) ->
          $translate('PAGE_TITLE.GET_ASSISTANCE')
        ]
    })
    .state('dahlia.additional-resources',{
      url: '/additional-resources'
      views:
        'container@':
          templateUrl: 'pages/templates/additional-resources.html'
      resolve:
        $title: ['$translate', ($translate) ->
          $translate('PAGE_TITLE.ADDITIONAL_RESOURCES')
        ]
    })
    .state('dahlia.document-checklist',{
      url: '/document-checklist'
      params:
        section: null
      views:
        'container@':
          templateUrl: 'pages/templates/document-checklist.html'
      resolve:
        $title: ['$translate', ($translate) ->
          $translate('PAGE_TITLE.DOCUMENT_CHECKLIST')
        ]
    })

    $urlRouterProvider.otherwise('/') # default to welcome screen

    # have to check if browser supports html5mode (http://stackoverflow.com/a/22771095)
    if !!(window.history && history.pushState)
      $locationProvider.html5Mode({enabled: true, requireBase: false})
]
