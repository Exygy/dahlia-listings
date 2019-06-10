do ->
  'use strict'
  describe 'ListingDataService', ->
    ListingDataService = undefined
    httpBackend = undefined
    fakeListings = getJSONFixture('listings-api-index.json')
    fakeListing = getJSONFixture('listings-api-show.json')
    fakeAMI = getJSONFixture('listings-api-ami.json')
    fakeListingConstantsService = {
      rentalPaperAppURLs: [
        {
          language: 'English'
          label: 'English'
          url: 'https://englishrentalapp.com'
        }
        {
          language: 'Spanish'
          label: 'Español'
          url: 'https://spanishrentalapp.com'
        }
      ]
    }
    fakeListingIdentityService =
      isOpen: ->
      resetData: jasmine.createSpy()
    $localStorage = undefined
    $state = undefined
    $translate = {}
    loading = {}
    error = {}
    requestURL = undefined
    listing = undefined

    beforeEach module('ui.router')
    # have to include http-etag to allow `$http.get(...).success(...).cached(...)` to work in the tests
    beforeEach module('http-etag')
    beforeEach module('dahlia.services', ($provide) ->
      $provide.value '$translate', $translate
      $provide.value 'ListingConstantsService', fakeListingConstantsService
      $provide.value 'ListingIdentityService', fakeListingIdentityService
      return
    )

    beforeEach inject((_ListingDataService_, _$httpBackend_, _$localStorage_, _$state_) ->
      httpBackend = _$httpBackend_
      $localStorage = _$localStorage_
      $state = _$state_
      $state.go = jasmine.createSpy()
      ListingDataService = _ListingDataService_
      requestURL = ListingDataService.requestURL
      return
    )

    describe 'Service setup', ->
      it 'initializes defaults', ->
        expect(ListingDataService.listings).toEqual []
      it 'initializes defaults', ->
        expect(ListingDataService.openListings).toEqual []

    describe 'Service.groupListings', ->
      beforeEach ->
        # Give fakeListingIdentityService.isOpen an array of return values
        # that makes half the listings appear open and half appear closed.
        numListings = fakeListings.listings.length
        numOpenListings = _.times(numListings / 2, _.constant(true))
        numClosedListings = _.times(numListings / 2, _.constant(false))
        isOpenReturnValues = _.concat(numOpenListings, numClosedListings)
        spyOn(fakeListingIdentityService, 'isOpen').and.returnValues(isOpenReturnValues...)

      it 'assigns ListingDataService listing buckets with grouped arrays of listings', ->
        ListingDataService.groupListings(fakeListings.listings)
        combinedLength =
          ListingDataService.openListings.length +
          ListingDataService.closedListings.length
        expect(combinedLength).toEqual fakeListings.listings.length

      it 'sorts open listings by application due date ascending', ->
        ListingDataService.groupListings(fakeListings.listings)
        dates = _.compact(_.map(ListingDataService.openListings, 'application_due_date'))
        expect(dates[0] <= dates[1]).toEqual true

      it 'sorts closed listings by application due date ascending', ->
        ListingDataService.groupListings(fakeListings.listings)
        dates = _.compact(_.map(ListingDataService.closedListings, 'application_due_date'))
        expect(dates[0] <= dates[1]).toEqual true

    describe 'Service.getListings', ->
      it 'passes params to http request', ->
        fakeParams = {params: {foo: 'bar'}}
        httpBackend.expect('GET', "/api/v1/listings.json?foo=bar").respond(fakeListings)
        ListingDataService.getListings(fakeParams)
        expect(httpBackend.flush).not.toThrow()
        httpBackend.verifyNoOutstandingExpectation()
        httpBackend.verifyNoOutstandingRequest()

    describe 'Service.getListing', ->
      beforeEach ->
        ListingDataService.resetListingData = jasmine.createSpy()

      afterEach ->
        httpBackend.verifyNoOutstandingExpectation()
        httpBackend.verifyNoOutstandingRequest()

      it 'resets the listing data before getting a new listing', ->
        stubAngularAjaxRequest httpBackend, requestURL, fakeListing
        ListingDataService.getListing 'abc123'
        httpBackend.flush()
        expect(ListingDataService.resetListingData).toHaveBeenCalled()

      it 'does not reset listing data before getting the same listing', ->
        # setup the initial listing
        ListingDataService.listing = angular.copy(fakeListing.listing)

        # request the same listing
        ListingDataService.getListing(ListingDataService.listing.id)
        expect(ListingDataService.resetListingData).not.toHaveBeenCalled()

      it 'assigns Service.listing with an individual listing', ->
        fakeListing.listing.units_available = 0
        stubAngularAjaxRequest httpBackend, requestURL, fakeListing
        ListingDataService.getListing 'abc123'
        httpBackend.flush()
        expect(ListingDataService.listing.Id).toEqual fakeListing.listing.Id

    describe 'Service.resetListingData', ->
      it 'resets the listing', ->
        ListingDataService.listing = angular.copy(fakeListing.listing)
        ListingDataService.resetListingData()
        expect(ListingDataService.listing).toEqual {}

      it 'resets the AMICharts', ->
        ListingDataService.AMICharts = ListingDataService._consolidatedAMICharts(fakeAMI.ami)
        ListingDataService.resetListingData()
        expect(ListingDataService.AMICharts).toEqual []

      it 'resets the download URLs', ->
        ListingDataService.listingPaperAppURLs = angular.copy(fakeListingConstantsService.rentalPaperAppURLs)
        ListingDataService.resetListingData()
        expect(ListingDataService.listingPaperAppURLs).toEqual []

    describe 'Service.getListingAMI', ->
      afterEach ->
        httpBackend.verifyNoOutstandingExpectation()
        httpBackend.verifyNoOutstandingRequest()
      it 'assigns Service.AMI with the consolidated AMI results', ->
        stubAngularAjaxRequest httpBackend, requestURL, fakeAMI
        listing = angular.copy(fakeListing)
        listing.amiChartSummaries = [{
          chart_id: 1
          percent: 50
        }]
        ListingDataService.getListingAMI(listing)
        httpBackend.flush()
        consolidated = ListingDataService._consolidatedAMICharts(fakeAMI.ami)
        expect(ListingDataService.AMICharts).toEqual consolidated

    describe 'Service.isAcceptingOnlineApplications', ->
      it 'returns false if an empty listing is passed in', ->
        expect(ListingDataService.isAcceptingOnlineApplications({})).toEqual false

      it 'returns false if listing is not open', ->
        listing = fakeListing.listing
        spyOn(fakeListingIdentityService, 'isOpen').and.returnValue(false)
        expect(ListingDataService.isAcceptingOnlineApplications(listing)).toEqual false

      it 'returns true if listing is open and accepting_online_applications', ->
        listing = fakeListing.listing
        listing.accepting_online_applications = true
        spyOn(fakeListingIdentityService, 'isOpen').and.returnValue(true)
        expect(ListingDataService.isAcceptingOnlineApplications(listing)).toEqual true

    describe 'Service.getListingsByIds', ->
      afterEach ->
        httpBackend.verifyNoOutstandingExpectation()
        httpBackend.verifyNoOutstandingRequest()
      it 'assigns Service.listings with the returned listing results', ->
        ListingDataService.listings = [fakeListing]
        listingIds = fakeListings.listings.map((listing) ->
          return listing.id
        )
        stubAngularAjaxRequest httpBackend, requestURL, fakeListings
        ListingDataService.getListingsByIds(listingIds)
        httpBackend.flush()
        expect(ListingDataService.listings).toEqual fakeListings.listings

    describe 'Service.sortByDate', ->
      it 'returns sorted list of Open Houses', ->
        listing = fakeListing.listing
        fakeOpenHouses = [
          {Date: '2016-10-15', Start_Time: '10:00 AM'}
          {Date: '2016-10-13', Start_Time: '10:00 AM'} # <-- should be first
          {Date: '2016-10-13', Start_Time: '1:00 PM'}
          {Date: '2016-10-17', Start_Time: '1:00 PM'}
        ]
        sorted = ListingDataService.sortByDate(angular.copy(fakeOpenHouses))
        expect(sorted[0]).toEqual fakeOpenHouses[1]

    describe 'Service.getListingPaperAppURLs', ->
      describe 'for a listing with no custom download URLs', ->
        beforeEach ->
          listing = angular.copy(fakeListing.listing)

        it 'should set Service.listingPaperAppURLs to the default rental paper application download URLs', ->
          ListingDataService.getListingPaperAppURLs(listing)
          expect(ListingDataService.listingPaperAppURLs).toEqual fakeListingConstantsService.rentalPaperAppURLs

      describe 'for a listing with custom download URLs', ->
        beforeEach ->
          listing = angular.copy(fakeListing.listing)
          listing.Download_URL = 'https://englishcustomappurl.com'

        it 'should set Service.listingPaperAppURLs to the default rental paper application download URLs merged with any available corresponding custom URLs', ->
          ListingDataService.getListingPaperAppURLs(listing)
          listingEnglishUrl = _.find(ListingDataService.listingPaperAppURLs, { language: 'English'})
          listingSpanishUrl = _.find(ListingDataService.listingPaperAppURLs, { language: 'Spanish'})
          defaultSpanishURL = _.find(fakeListingConstantsService.rentalPaperAppURLs, { language: 'Spanish'})
          expect(listingEnglishUrl.url).toEqual listing.Download_URL
          expect(listingSpanishUrl.url).toEqual defaultSpanishURL.url
