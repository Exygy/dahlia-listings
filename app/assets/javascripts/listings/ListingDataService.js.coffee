############################################################################################
####################################### SERVICE ############################################
############################################################################################

ListingDataService = (
  $http, $localStorage, $q, $state, $translate, $timeout,
  ListingConstantsService, ListingIdentityService,
  ListingPreferenceService, ListingUnitService, SharedService) ->
  Service = {}
  MAINTENANCE_LISTINGS = [] unless MAINTENANCE_LISTINGS
  Service.listing = {}
  Service.listings = []
  Service.openListings = []
  Service.closedListings = []
  # these get loaded after the listing is loaded
  Service.AMICharts = []
  Service.loading = {}
  Service.error = {}
  Service.toggleStates = {}
  Service.listingPaperAppURLs = []
  Service.preferenceMap = ListingConstantsService.preferenceMap

  Service.sortByDate = (sessions) ->
    # used for sorting Open_Houses and Information_Sessions
    _.sortBy sessions, (session) ->
      moment("#{session.Date} #{session.Start_Time}", 'YYYY-MM-DD h:mmA')

  ###################################### Salesforce API Calls ###################################

  Service.getListing = (_id, forceRecache = false, retranslate = false) ->
    if Service.listing && Service.listing.id == _id
      # return a resolved promise if we already have the listing
      return $q.when(Service.listing)
    Service.resetListingData()

    deferred = $q.defer()
    httpConfig = { }
    httpConfig.params = { force: true } if forceRecache
    $http.get("/api/v1/listings/#{_id}.json", httpConfig)
    .then(
      Service.getListingResponse(deferred, retranslate)
    ).catch((response) ->
      deferred.reject(response)
    )
    return deferred.promise

  # Remove the previous listing and all it's associated data
  Service.resetListingData = () ->
    angular.copy({}, Service.listing)
    angular.copy([], Service.AMICharts)
    angular.copy([], Service.listingPaperAppURLs)

  Service.getListingResponse = (deferred, retranslate = false) ->
    (response) ->
      data = response.data
      status = response.status
      deferred.resolve()
      if !data || !data.listing
        return
      angular.copy(data.listing, Service.listing)
      # fallback for fixing the layout when a listing is missing an image
      Service.listing.image_url ?= 'https://unsplash.it/g/780/438'
      # create a combined unit_summaries
      unless Service.listing.unit_summaries
        Service.listing.unit_summaries = ListingUnitService.combineUnitSummaries(Service.listing)
      Service.toggleStates[Service.listing.id] ?= {}

  Service.getListings = (opts = {}) ->
    deferred = $q.defer()
    $http.get("/api/v1/listings.json", {
      params: opts.params
    }).then(
      Service.getListingsResponse(deferred, opts.retranslate)
    ).catch((response) ->
      deferred.reject(response)
    )
    return deferred.promise

  Service.getListingsResponse = (deferred, retranslate = false) ->
    (response) ->
      data = response.data
      status = response.status
      listings = if data and data.listings then data.listings else []
      listings = Service.cleanListings(listings)
      Service.groupListings(listings)
      deferred.resolve()

  Service.cleanListings = (listings) ->
    _.map listings, (listing) ->
      # fallback for fixing the layout when a listing is missing an image
      listing.image_url ?= 'https://unsplash.it/g/780/438'
    _.filter listings, (listing) ->
      !_.includes(MAINTENANCE_LISTINGS, listing.id)

  Service.groupListings = (listings) ->
    openListings = []
    closedListings = []

    sortedListings = _.sortBy listings, (i) -> moment(i.application_due_date)

    sortedListings.forEach (listing) ->
      if ListingIdentityService.isOpen(listing)
        openListings.push(listing)
      else
        closedListings.push(listing)

    angular.copy(openListings, Service.openListings)
    angular.copy(closedListings, Service.closedListings)

  Service.getListingsByIds = (ids) ->
    angular.copy([], Service.listings)
    params = {params: {ids: ids.join(',') }}
    $http.get("/api/v1/listings.json", params).then((response) ->
      data = response.data
      listings = if data and data.listings then data.listings else []
      angular.copy(listings, Service.listings)
    ).catch((response) ->
      return
    )

  Service.isAcceptingOnlineApplications = (listing) ->
    return false if _.isEmpty(listing)
    return false unless ListingIdentityService.isOpen(listing)
    return listing.accepting_online_applications

  Service.getListingAndCheckIfOpen = (id) ->
    deferred = $q.defer()
    Service.getListing(id).then(() ->
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

    return $q.when() unless listing.amiChartSummaries

    sortedAmiChartSummaries = _.sortBy(listing.amiChartSummaries, 'percent')
    data =
      'chart_ids[]': _.map(sortedAmiChartSummaries, 'chart_id')
      'percents[]': _.map(sortedAmiChartSummaries, 'percent')

    $http.get('/api/v1/listings/ami.json', { params: data }).then((response) ->
      data = response.data
      if data && data.ami
        angular.copy(Service._consolidatedAMICharts(data.ami), Service.AMICharts)
      Service.loading.ami = false
    ).catch((response) ->
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
    Service.collectTypes(listing, 'priorities_descriptor')

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
    if listing.reserved_community_minimum_age
      "#{listing.reserved_community_minimum_age}+"
    else
      ''

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

  Service.getListingPaperAppURLs = (listing) ->
    urls = angular.copy(ListingConstantsService.rentalPaperAppURLs)

    english = _.find(urls, { language: 'English' })
    chinese = _.find(urls, { language: 'Traditional Chinese' })
    spanish = _.find(urls, { language: 'Spanish' })
    tagalog = _.find(urls, { language: 'Tagalog' })

    # replace download URLs if they are customized on the listing
    english.url = listing.Download_URL if listing.Download_URL
    chinese.url = listing.Download_URL_Cantonese if listing.Download_URL_Cantonese
    spanish.url = listing.Download_URL_Spanish if listing.Download_URL_Spanish
    tagalog.url = listing.Download_URL_Tagalog if listing.Download_URL_Tagalog
    angular.copy(urls, Service.listingPaperAppURLs)

  return Service

############################################################################################
######################################## CONFIG ############################################
############################################################################################

ListingDataService.$inject = [
  '$http', '$localStorage', '$q', '$state', '$translate', '$timeout',
  'ListingConstantsService', 'ListingIdentityService',
  'ListingPreferenceService', 'ListingUnitService', 'SharedService'
]

angular
  .module('dahlia.services')
  .service('ListingDataService', ListingDataService)
