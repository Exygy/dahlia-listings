############################################################################################
####################################### SERVICE ############################################
############################################################################################

ListingDataService = (
  $http, $localStorage, $q, $state, $translate, $timeout,
  ExternalTranslateService, ListingConstantsService, ListingEligibilityService, ListingIdentityService,
  ListingLotteryService, ListingPreferenceService, ListingUnitService, SharedService) ->
  Service = {}
  MAINTENANCE_LISTINGS = [] unless MAINTENANCE_LISTINGS
  Service.listing = {}
  Service.listings = []
  Service.openListings = []
  Service.openMatchListings = []
  Service.openNotMatchListings = []
  Service.closedListings = []
  Service.lotteryResultsListings = []
  # these get loaded after the listing is loaded
  Service.AMICharts = []
  Service.loading = {}
  Service.error = {}
  Service.toggleStates = {}
  Service.listingDownloadURLs = []
  $localStorage.favorites ?= []
  Service.favorites = $localStorage.favorites
  Service.preferenceMap = ListingConstantsService.preferenceMap

  Service.getFavoriteListings = () ->
    Service.getListingsByIds(Service.favorites, true)

  # Service.checkFavorites makes sure that Service.listings contains our favorited listings
  # if not, it means the listing doesn't exist and we should remove it from favorites
  Service.checkFavorites = () ->
    listing_ids = []
    Service.listings.forEach (listing) -> listing_ids.push(listing['Id'])
    Service.favorites.forEach (favorite_id) ->
      if listing_ids.indexOf(favorite_id) == -1
        Service.toggleFavoriteListing(favorite_id)

  Service.toggleFavoriteListing = (listing_id) ->
    # toggle the value for listing_id
    index = Service.favorites.indexOf(listing_id)
    if index == -1
      # add the favorite
      Service.favorites.push(listing_id)
    else
      # remove the favorite
      Service.favorites.splice(index, 1)

  Service.isFavorited = (listing_id) ->
    Service.favorites.indexOf(listing_id) > -1

  Service.sortByDate = (sessions) ->
    # used for sorting Open_Houses and Information_Sessions
    _.sortBy sessions, (session) ->
      moment("#{session.Date} #{session.Start_Time}", 'YYYY-MM-DD h:mmA')

  ###################################### Salesforce API Calls ###################################

  Service.getListing = (_id, forceRecache = false, retranslate = false) ->
    _id = Service.mapSlugToId(_id)

    if Service.listing && Service.listing.Id == _id
      # return a resolved promise if we already have the listing
      return $q.when(Service.listing)
    Service.resetListingData()

    deferred = $q.defer()
    httpConfig = { etagCache: true }
    httpConfig.params = { force: true } if forceRecache
    $http.get("/api/v1/listings/#{_id}.json", httpConfig)
    .success(
      Service.getListingResponse(deferred, retranslate)
    ).cached(
      Service.getListingResponse(deferred, retranslate)
    ).error( (data, status, headers, config) ->
      deferred.reject(data)
    )
    return deferred.promise

  # Remove the previous listing and all it's associated data
  Service.resetListingData = () ->
    angular.copy({}, Service.listing)
    angular.copy([], Service.AMICharts)
    angular.copy([], Service.listingDownloadURLs)
    ListingLotteryService.resetData()

  Service.getListingResponse = (deferred, retranslate = false) ->
    (data, status, headers, config, itemCache) ->
      itemCache.set(data) unless status == 'cached'
      deferred.resolve()
      if !data || !data.listing
        return
      angular.copy(data.listing, Service.listing)
      # fallback for fixing the layout when a listing is missing an image
      Service.listing.imageURL ?= 'https://unsplash.it/g/780/438'
      # create a combined unitSummary
      unless Service.listing.unitSummary
        Service.listing.unitSummary = ListingUnitService.combineUnitSummaries(Service.listing)
      # On listing and listings pages, we are experiencing an issue where
      # where the Google translation will try to keep up with digest re-calcs
      # happening during page load and will get tripped up and fail, leaving
      # the page untranslated. This quick fix runs the Google Translation
      # again to cover for a possible earlier failed translate.
      # TODO: Remove this quick fix for translation issues on listing pages
      # and replace with a real fix based on actual digest timing.
      $timeout(ExternalTranslateService.translatePageContent, 0, false) if retranslate
      Service.toggleStates[Service.listing.Id] ?= {}

  Service.getListings = (opts = {}) ->
    # check for eligibility options being set in the session
    if opts.checkEligibility && ListingEligibilityService.hasEligibilityFilters()
      return Service.getListingsWithEligibility()
    deferred = $q.defer()
    $http.get("/api/v1/listings.json", {
      etagCache: true
    }).success(
      Service.getListingsResponse(deferred, opts.retranslate)
    ).cached(
      Service.getListingsResponse(deferred, opts.retranslate)
    ).error((data, status, headers, config) ->
      deferred.reject(data)
    )
    return deferred.promise

  Service.getListingsResponse = (deferred, retranslate = false) ->
    (data, status, headers, config, itemCache) ->
      itemCache.set(data) unless status == 'cached'
      listings = if data and data.listings then data.listings else []
      listings = Service.cleanListings(listings)
      Service.groupListings(listings)
      # On listing and listings pages, we are experiencing an issue where
      # where the Google translation will try to keep up with digest re-calcs
      # happening during page load and will get tripped up and fail, leaving
      # the page untranslated. This quick fix runs the Google Translation
      # again to cover for a possible earlier failed translate.
      # TODO: Remove this quick fix for translation issues on listing pages
      # and replace with a real fix based on actual digest timing.
      $timeout(ExternalTranslateService.translatePageContent, 0, false) if retranslate
      deferred.resolve()

  Service.getListingsWithEligibility = ->
    params =
      householdsize: ListingEligibilityService.eligibility_filters.household_size
      incomelevel: ListingEligibilityService.eligibilityYearlyIncome()
      includeChildrenUnder6: ListingEligibilityService.eligibility_filters.include_children_under_6
      childrenUnder6: ListingEligibilityService.eligibility_filters.children_under_6
    deferred = $q.defer()
    $http.get("/api/v1/listings/eligibility.json?#{SharedService.toQueryString(params)}",
      { etagCache: true }
    ).success(
      Service.getListingsWithEligibilityResponse(deferred)
    ).cached(
      Service.getListingsWithEligibilityResponse(deferred)
    ).error( (data, status, headers, config) ->
      deferred.reject(data)
    )
    return deferred.promise

  Service.getListingsWithEligibilityResponse = (deferred) ->
    (data, status, headers, config, itemCache) ->
      itemCache.set(data) unless status == 'cached'
      listings = (if data and data.listings then data.listings else [])
      listings = Service.cleanListings(listings)
      Service.groupListings(listings)
      deferred.resolve()

  Service.cleanListings = (listings) ->
    _.map listings, (listing) ->
      # fallback for fixing the layout when a listing is missing an image
      listing.imageURL ?= 'https://unsplash.it/g/780/438'
    _.filter listings, (listing) ->
      !_.includes(MAINTENANCE_LISTINGS, listing.Id)

  Service.groupListings = (listings) ->
    openListings = []
    openMatchListings = []
    openNotMatchListings = []
    closedListings = []
    lotteryResultsListings = []

    listings.forEach (listing) ->
      if ListingIdentityService.isOpen(listing)
        # All Open Listings Array
        openListings.push(listing)
        if listing.Does_Match
          openMatchListings.push(listing)
        else
          openNotMatchListings.push(listing)
      else
        if ListingLotteryService.lotteryIsUpcoming(listing)
          closedListings.push(listing)
        else
          lotteryResultsListings.push(listing)

    angular.copy(Service.sortListings(openListings, 'openListings'), Service.openListings)
    angular.copy(Service.sortListings(openMatchListings, 'openMatchListings'), Service.openMatchListings)
    angular.copy(Service.sortListings(openNotMatchListings, 'openNotMatchListings'), Service.openNotMatchListings)
    angular.copy(Service.sortListings(closedListings, 'closedListings'), Service.closedListings)
    angular.copy(Service.sortListings(lotteryResultsListings, 'lotteryResultsListings'), Service.lotteryResultsListings)

  Service.sortListings = (listings, type) ->
    # openListing types
    if ['openListings', 'openMatchListings', 'openNotMatchListings'].indexOf(type) > -1
      _.sortBy listings, (i) -> moment(i.Application_Due_Date)
    # closedListing types
    else if ['closedListings', 'lotteryResultsListings'].indexOf(type) > -1
      listings = _.sortBy listings, (i) ->
        # fallback to Application_Due_Date, really only for the special case of First Come First Serve
        moment(i.Lottery_Results_Date || i.Application_Due_Date)
      # lotteryResults get reversed (latest lottery results date first)
      if type == 'lotteryResultsListings' then _.reverse listings else listings

  Service.getListingsByIds = (ids, checkFavorites = false) ->
    angular.copy([], Service.listings)
    params = {params: {ids: ids.join(',') }}
    $http.get("/api/v1/listings.json", params).success((data, status, headers, config) ->
      listings = if data and data.listings then data.listings else []
      angular.copy(listings, Service.listings)
      Service.checkFavorites() if checkFavorites
    ).error( (data, status, headers, config) ->
      return
    )

  Service.isAcceptingOnlineApplications = (listing) ->
    return false if _.isEmpty(listing)
    return false if ListingLotteryService.lotteryComplete(listing)
    return false unless ListingIdentityService.isOpen(listing)
    return listing.Accepting_Online_Applications

  Service.getListingAndCheckIfOpen = (id) ->
    deferred = $q.defer()
    Service.getListing(id).then( ->
      deferred.resolve(Service.listing)
      if _.isEmpty(Service.listing)
        # kick them out unless there's a real listing
        return $state.go('dahlia.welcome')
      else if !Service.isAcceptingOnlineApplications(Service.listing)
        # kick them back to the listing
        return $state.go('dahlia.listing', {id: id})
    ).catch( (response) ->
      deferred.reject(response)
    )
    deferred.promise

  Service.getListingAMI = (listing) ->
    angular.copy([], Service.AMICharts)
    Service.loading.ami = true
    Service.error.ami = false
    # shouldn't happen, but safe to have a guard clause
    return $q.when() unless listing.chartTypes
    allChartTypes = _.sortBy(listing.chartTypes, 'percent')
    data =
      'year[]': _.map(allChartTypes, 'year')
      'chartType[]': _.map(allChartTypes, 'chartType')
      'percent[]': _.map(allChartTypes, 'percent')
    $http.get('/api/v1/listings/ami.json', { params: data }).success((data, status, headers, config) ->
      if data && data.ami
        angular.copy(Service._consolidatedAMICharts(data.ami), Service.AMICharts)
      Service.loading.ami = false
    ).error( (data, status, headers, config) ->
      Service.loading.ami = false
      Service.error.ami = true
      return
    )

  Service._consolidatedAMICharts = (amiData) ->
    charts = []
    amiData.forEach (chart) ->
      # look for an existing chart at the same percentage level
      amiPercentChart = _.find charts, (c) -> c.percent == chart.percent
      if !amiPercentChart
        # only push chart if it has any values
        charts.push(chart) if chart.values.length
      else
        # if it exists, modify it with the max values
        i = 0
        amiPercentChart.values.forEach (incomeLevel) ->
          chartAmount = if chart.values[i] then chart.values[i].amount else 0
          incomeLevel.amount = Math.max(incomeLevel.amount, chartAmount)
          i++
    charts

  Service.priorityTypes = (listing) ->
    Service.collectTypes(listing, 'prioritiesDescriptor')

  Service.collectTypes = (listing, specialType) ->
    _.map listing[specialType], (descriptor) ->
      descriptor.name

  Service.priorityLabel = (priority, modifier) ->
    return priority unless ListingConstantsService.priorityLabelMap[priority]
    return ListingConstantsService.priorityLabelMap[priority][modifier]

  Service.reservedLabel = (listing, type,  modifier) ->
    labelMap =
      "#{ListingConstantsService.RESERVED_TYPES.SENIOR}":
        building: 'Senior'
        eligibility: 'Seniors'
        reservedFor: "seniors #{Service.formatSeniorMinimumAge(listing)}"
        reservedForWhoAre: "seniors #{Service.formatSeniorMinimumAge(listing)}"
        unitDescription: "seniors #{Service.formatSeniorMinimumAge(listing)}"
      "#{ListingConstantsService.RESERVED_TYPES.VETERAN}":
        building: 'Veterans'
        eligibility: 'Veterans'
        reservedFor: 'veterans'
        reservedForWhoAre: 'veterans'
        unitDescription: 'veterans of the U.S. Armed Forces'
      "#{ListingConstantsService.RESERVED_TYPES.DISABLED}":
        building: 'Developmental Disability'
        eligibility: 'People with developmental disabilities'
        reservedFor: 'people with developmental disabilities'
        reservedForWhoAre: 'developmentally disabled'
        unitDescription: 'people with developmental disabilities'

    return type unless labelMap[type]
    return labelMap[type][modifier]

  Service.formatSeniorMinimumAge = (listing) ->
    if listing.Reserved_community_minimum_age
      "#{listing.Reserved_community_minimum_age}+"
    else
      ''

  # used by My Applications -- when you load an application we also parse the attached listing data
  Service.loadListing = (listing) ->
    return if Service.listing && Service.listing.Id == listing.Id && listing.preferences
    # TODO: won't be needed if we ever consolidate Listing_Lottery_Preferences and /preferences API
    listing.preferences = _.map listing.Listing_Lottery_Preferences, (lotteryPref) ->
      {
        listingPreferenceID: lotteryPref.Id
        preferenceName: lotteryPref.Lottery_Preference.Name
      }
    angular.copy(listing, Service.listing)

  Service.formattedAddress = (listing, type='Building', display='full') ->
    street = "#{type}_Street_Address"
    zip = "#{type}_Postal_Code"
    if type == 'Leasing_Agent'
      street = "#{type}_Street"
      zip = "#{type}_Zip"
    else if type == 'Building'
      zip = "#{type}_Zip_Code"

    # If Street address is undefined, then return false for display and google map lookup
    if listing[street] == undefined
      return
    # If other fields are undefined, proceed, with special string formatting
    if listing[street] != undefined
      Street_Address = listing[street] + ', '
    else
      Street_Address = ''
    if listing["#{type}_City"] != undefined
      City = listing["#{type}_City"]
    else
      City = ''
    if listing["#{type}_State"] != undefined
      State = listing["#{type}_State"]
    else
      State = ''
    if listing[zip] != undefined
      Zip_Code = listing[zip]
    else
      Zip_Code = ''

    if display == 'street'
      return "#{Street_Address}"
    else if display == 'city-state-zip'
      return "#{City} #{State}, #{Zip_Code}"
    else
      "#{Street_Address}#{City} #{State}, #{Zip_Code}"

  Service.getListingDownloadURLs = ->
    urls = angular.copy(ListingConstantsService.defaultApplicationURLs)
    english = _.find(urls, { language: 'English' })
    chinese = _.find(urls, { language: 'Traditional Chinese' })
    spanish = _.find(urls, { language: 'Spanish' })
    tagalog = _.find(urls, { language: 'Tagalog' })
    # replace download URLs if they are customized on the listing
    listing = Service.listing
    english.url = listing.Download_URL if listing.Download_URL
    chinese.url = listing.Download_URL_Cantonese if listing.Download_URL_Cantonese
    spanish.url = listing.Download_URL_Spanish if listing.Download_URL_Spanish
    tagalog.url = listing.Download_URL_Tagalog if listing.Download_URL_Tagalog
    angular.copy(urls, Service.listingDownloadURLs)

  Service.getProjectIdForBoundaryMatching = (listing) ->
    return unless listing
    if ListingPreferenceService.hasPreference('antiDisplacement', listing)
      'ADHP'
    else if ListingPreferenceService.hasPreference('neighborhoodResidence', listing)
      listing.Project_ID
    else
      null

  Service.mapSlugToId = (id) ->
    # strip spaces and lowercase the listing names e.g. "Argenta 909" => "argenta909"
    mapping = _.mapKeys _.invert(ListingConstantsService.LISTING_MAP), (v, k) -> k.toLowerCase().replace(/ /g, '')
    slug = id.toLowerCase()
    # by default will just return the id, unless it finds a matching slug
    return if mapping[slug] then mapping[slug] else id

  return Service

############################################################################################
######################################## CONFIG ############################################
############################################################################################

ListingDataService.$inject = [
  '$http', '$localStorage', '$q', '$state', '$translate', '$timeout',
  'ExternalTranslateService', 'ListingConstantsService', 'ListingEligibilityService', 'ListingIdentityService',
  'ListingLotteryService', 'ListingPreferenceService', 'ListingUnitService', 'SharedService'
]

angular
  .module('dahlia.services')
  .service('ListingDataService', ListingDataService)
