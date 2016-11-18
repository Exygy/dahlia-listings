do ->
  'use strict'
  describe 'ListingService', ->

    ListingService = undefined
    httpBackend = undefined
    fakeListings = getJSONFixture('listings-api-index.json')
    fakeListing = getJSONFixture('listings-api-show.json')
    fakeAMI = getJSONFixture('listings-api-ami.json')
    fakeUnits = getJSONFixture('listings-api-units.json')
    fakePreferences = getJSONFixture('listings-api-listing-preferences.json')
    fakeLotteryResults = getJSONFixture('listings-api-lottery-results.json')
    fakeLotteryBuckets = getJSONFixture('listings-api-lottery-buckets.json')
    fakeLotteryRanking = getJSONFixture('listings-api-lottery-ranking.json')
    fakeEligibilityListings = getJSONFixture('listings-api-eligibility-listings.json')
    $localStorage = undefined
    $state = undefined
    modalMock = undefined
    requestURL = undefined

    beforeEach module('ui.router')
    beforeEach module('dahlia.services', ($provide)->
      $provide.value '$modal', modalMock
      return
    )

    beforeEach inject((_ListingService_, _$httpBackend_, _$localStorage_, _$state_) ->
      httpBackend = _$httpBackend_
      $localStorage = _$localStorage_
      $state = _$state_
      $state.go = jasmine.createSpy()
      ListingService = _ListingService_
      requestURL = ListingService.requestURL
      return
    )

    describe 'Service setup', ->
      it 'initializes defaults', ->
        expect(ListingService.listings).toEqual []
      it 'initializes defaults', ->
        expect(ListingService.openListings).toEqual []

    describe 'Service.getListings', ->
      afterEach ->
        httpBackend.verifyNoOutstandingExpectation()
        httpBackend.verifyNoOutstandingRequest()
      it 'assigns ListingService listing buckets with grouped arrays of listings', ->
        stubAngularAjaxRequest httpBackend, requestURL, fakeListings
        ListingService.getListings()
        httpBackend.flush()
        combinedLength =
          ListingService.openListings.length +
          ListingService.closedListings.length +
          ListingService.lotteryResultsListings.length
        expect(combinedLength).toEqual fakeListings.listings.length

        openLength =
          ListingService.openMatchListings.length +
          ListingService.openNotMatchListings.length
        expect(openLength).toEqual ListingService.openListings.length

      it 'sorts groupedListings based on their dates', ->
        stubAngularAjaxRequest httpBackend, requestURL, fakeListings
        ListingService.getListings()
        httpBackend.flush()
        date1 = ListingService.lotteryResultsListings[0].Lottery_Results_Date
        date2 = ListingService.lotteryResultsListings[1].Lottery_Results_Date
        expect(date1 >= date2).toEqual true


    describe 'Service.getListing', ->
      afterEach ->
        httpBackend.verifyNoOutstandingExpectation()
        httpBackend.verifyNoOutstandingRequest()
      it 'assigns Service.listing with an individual listing', ->
        stubAngularAjaxRequest httpBackend, requestURL, fakeListing
        ListingService.getListing 'abc123'
        httpBackend.flush()
        expect(ListingService.listing).toEqual fakeListing.listing

    describe 'Service.getListingAMI', ->
      afterEach ->
        httpBackend.verifyNoOutstandingExpectation()
        httpBackend.verifyNoOutstandingRequest()
      it 'assigns Service.AMI with the AMI results', ->
        stubAngularAjaxRequest httpBackend, requestURL, fakeAMI
        ListingService.getListingAMI()
        httpBackend.flush()
        expect(ListingService.AMI).toEqual fakeAMI.ami

    describe 'Service.maxIncomeLevelsFor', ->
      it 'returns incomeLevels with occupancy, yearly, monthly values', ->
        listing = fakeListing.listing
        listing.unitSummary = [
          {unitType: 'Studio', minOccupancy: 1, maxOccupancy: 2}
          {unitType: '1 BR', minOccupancy: 1, maxOccupancy: 3}
        ]
        expect(ListingService.occupancyMinMax(listing)).toEqual [1,3]
        ami = fakeAMI.ami
        incomeLevels = ListingService.maxIncomeLevelsFor(listing, ami)
        # number of income levels should == maxOccupancy + 2
        expect(incomeLevels.length).toEqual 5

    describe 'Service.listingIsOpen', ->
      it 'checks if listing application due date has passed', ->
        listing = fakeListing.listing
        tomorrow = new Date()
        tomorrow.setDate(tomorrow.getDate() + 1)
        listing.Application_Due_Date = tomorrow.toString()
        expect(ListingService.listingIsOpen(listing)).toEqual true

    describe 'Service.isAcceptingOnlineApplications', ->
      it 'returns false if an empty listing is passed in', ->
        expect(ListingService.isAcceptingOnlineApplications({})).toEqual false

      it 'returns false if due date has passed', ->
        listing = fakeListing.listing
        past = new Date()
        past.setDate(past.getDate() - 10)
        listing.Application_Due_Date = past.toString()
        expect(ListingService.isAcceptingOnlineApplications(listing)).toEqual false

      it 'returns true if due date in future and Accepting_Online_Applications', ->
        listing = fakeListing.listing
        listing.Accepting_Online_Applications = true
        tomorrow = new Date()
        tomorrow.setDate(tomorrow.getDate() + 1)
        listing.Application_Due_Date = tomorrow.toString()
        expect(ListingService.isAcceptingOnlineApplications(listing)).toEqual true

    describe 'Service.toggleFavoriteListing', ->
      describe 'When a listing is favorited', ->
        expectedResult = [1]
        listingId = 1
        beforeEach ->
          ListingService.favorites = $localStorage.favorites = []
          ListingService.toggleFavoriteListing listingId

        it 'should store Service.favorites in localStorage', ->
          expect($localStorage.favorites).toEqual expectedResult
          expect($localStorage.favorites).toEqual ListingService.favorites
        it 'should update Service.favorites', ->
          expect(ListingService.favorites).toEqual expectedResult

      describe 'When a favorited listing is unfavorited', ->
        expectedResult = []
        listingId = 1
        beforeEach ->
          ListingService.favorites = $localStorage.favorites = []
          #favoriting listing
          ListingService.toggleFavoriteListing listingId
          #unfavoriting listing
          ListingService.toggleFavoriteListing listingId

        it 'should update Service.favorites in localStorage', ->
          expect($localStorage.favorites).toEqual expectedResult
          expect($localStorage.favorites).toEqual ListingService.favorites
        it 'should updated Service.favorites', ->
          expect(ListingService.favorites).toEqual expectedResult

    describe 'Service.getFavorites', ->
      describe 'When a listing has been favorited', ->
        beforeEach ->
          ListingService.favorites = $localStorage.favorites = []
        it 'updates Service.favorites with appropriate data', ->
          ListingService.toggleFavoriteListing 1
          expect(ListingService.favorites).toEqual [1]
      describe 'When a favorite is not found', ->
        beforeEach ->
          ListingService.favorites = $localStorage.favorites = []
        afterEach ->
          httpBackend.verifyNoOutstandingExpectation()
          httpBackend.verifyNoOutstandingRequest()
        it 'removes it from favorites', ->
          # this listing does not exist
          ListingService.toggleFavoriteListing '123xyz'
          expect(ListingService.favorites).toEqual ['123xyz']
          stubAngularAjaxRequest httpBackend, requestURL, fakeListings
          # this should remove the non-existent favorite
          ListingService.getFavoriteListings()
          httpBackend.flush()
          expect(ListingService.favorites).toEqual []

    describe 'Service.setEligibilityFilters', ->
      describe 'When filters have been set', ->
        fakeFilters =
          household_size: 2
          income_timeframe: 'per_month'
          income_total: 3500
        beforeEach ->
          # reset eligibility filters
          ListingService.setEligibilityFilters angular.copy(ListingService.eligibility_filter_defaults)
        afterEach ->
          # reset eligibility filters
          ListingService.setEligibilityFilters angular.copy(ListingService.eligibility_filter_defaults)
        it 'updates Service.eligibility_filters with appropriate data', ->
          ListingService.setEligibilityFilters(fakeFilters)
          expect(ListingService.eligibility_filters.income_total).toEqual 3500
          expect(ListingService.eligibility_filters.household_size).toEqual 2
        it 'checks if eligibility filters have been set', ->
          expect(ListingService.hasEligibilityFilters()).toEqual false
          ListingService.setEligibilityFilters(fakeFilters)
          expect(ListingService.hasEligibilityFilters()).toEqual true
        it 'returns yearly income', ->
          ListingService.setEligibilityFilters(fakeFilters)
          expect(ListingService.eligibilityYearlyIncome()).toEqual 3500*12

    describe 'Service.getListingUnits', ->
      afterEach ->
        httpBackend.verifyNoOutstandingExpectation()
        httpBackend.verifyNoOutstandingRequest()
      it 'assigns Service.listing.Units with the Unit results', ->
        # have to populate listing first
        ListingService.listing = fakeListing.listing
        stubAngularAjaxRequest httpBackend, requestURL, fakeUnits
        ListingService.getListingUnits()
        httpBackend.flush()
        expect(ListingService.listing.Units).toEqual fakeUnits.units

    describe 'Service.getListingPreferences', ->
      afterEach ->
        httpBackend.verifyNoOutstandingExpectation()
        httpBackend.verifyNoOutstandingRequest()
      it 'assigns Service.listing.preferences with the Preference results', ->
        # have to populate listing first
        ListingService.listing = fakeListing.listing
        stubAngularAjaxRequest httpBackend, requestURL, fakePreferences
        ListingService.getListingPreferences()
        httpBackend.flush()
        expect(ListingService.listing.preferences).toEqual fakePreferences.preferences

    describe 'Service.getListingsByIds', ->
      afterEach ->
        httpBackend.verifyNoOutstandingExpectation()
        httpBackend.verifyNoOutstandingRequest()
      it 'assigns Service.listings with the returned listing results', ->
        ListingService.listings = [fakeListing]
        listingIds = fakeListings.listings.map((listing) ->
          return listing.id
        )
        stubAngularAjaxRequest httpBackend, requestURL, fakeListings
        ListingService.getListingsByIds(listingIds)
        httpBackend.flush()
        expect(ListingService.listings).toEqual fakeListings.listings

    describe 'Service.getListingsWithEligibility', ->
      afterEach ->
        httpBackend.verifyNoOutstandingExpectation()
        httpBackend.verifyNoOutstandingRequest()

      it 'calls groupListings function with returned listings', ->
        ListingService.groupListings = jasmine.createSpy()
        fakeFilters =
          household_size: 2
          income_timeframe: 'per_month'
          income_total: 3500
          include_children_under_6: true
          children_under_6: 1
        ListingService.setEligibilityFilters(fakeFilters)
        stubAngularAjaxRequest httpBackend, requestURL, fakeEligibilityListings
        ListingService.getListingsWithEligibility()
        httpBackend.flush()
        expect(ListingService.groupListings).toHaveBeenCalledWith(fakeEligibilityListings.listings)

    describe 'Service.getLotteryBuckets', ->
      afterEach ->
        httpBackend.verifyNoOutstandingExpectation()
        httpBackend.verifyNoOutstandingRequest()

      it 'assigns Service.listing.Lottery_Buckets with bucket results', ->
        stubAngularAjaxRequest httpBackend, requestURL, fakeLotteryBuckets
        ListingService.getLotteryBuckets()
        httpBackend.flush()
        expect(ListingService.listing.Lottery_Buckets).toEqual fakeLotteryBuckets.lottery_buckets

    describe 'Service.getLotteryRanking', ->
      afterEach ->
        httpBackend.verifyNoOutstandingExpectation()
        httpBackend.verifyNoOutstandingRequest()

      it 'assigns Service.listing.Lottery_Ranking with ranking results', ->
        stubAngularAjaxRequest httpBackend, requestURL, fakeLotteryRanking
        ListingService.getLotteryRanking('00002612')
        httpBackend.flush()
        expect(ListingService.listing.Lottery_Ranking).toEqual fakeLotteryRanking.lottery_ranking

    describe 'Service.showNeighborhoodPreferences', ->
      it 'returns true if URL is available and <9 and >2 days from lottery', ->
        # have to populate listing first
        listing = fakeListing.listing
        listing.Lottery_Date = moment().add(4, 'days').toString()
        listing.NeighborHoodPreferenceUrl = 'http://www.url.com'
        expect(ListingService.showNeighborhoodPreferences(listing)).toEqual true

      it 'returns false if URL is unavailable', ->
        # have to populate listing first
        listing = fakeListing.listing
        listing.NeighborHoodPreferenceUrl = null
        expect(ListingService.showNeighborhoodPreferences(listing)).toEqual false

      it 'returns false if URL is available but <2 days from lottery', ->
        # have to populate listing first
        listing = fakeListing.listing
        listing.Lottery_Date = moment().add(1, 'days').toString()
        listing.NeighborHoodPreferenceUrl = 'http://www.url.com'
        expect(ListingService.showNeighborhoodPreferences(listing)).toEqual false

    describe 'Service.sortByDate', ->
      it 'returns sorted list of Open Houses', ->
        listing = fakeListing.listing
        fakeOpenHouses = [
          {Date: '2016-10-15', Start_Time: '10:00 AM'}
          {Date: '2016-10-13', Start_Time: '10:00 AM'} # <-- should be first
          {Date: '2016-10-13', Start_Time: '1:00 PM'}
          {Date: '2016-10-17', Start_Time: '1:00 PM'}
        ]
        sorted = ListingService.sortByDate(angular.copy(fakeOpenHouses))
        expect(sorted[0]).toEqual fakeOpenHouses[1]
