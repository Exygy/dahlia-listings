do ->
  'use strict'
  describe 'Listing Container Component', ->
    $componentController = undefined
    ctrl = undefined
    locals = undefined
    listing = undefined
    yesterday = new Date()
    yesterday.setDate(yesterday.getDate() - 1)
    tomorrow = new Date()
    tomorrow.setDate(tomorrow.getDate() + 1)
    fakeListingDataService = {}
    $translate =
      instant: ->
    fakeWindow = {}
    fakeSharedService = {}
    fakeAnalyticsService = {}
    fakeListings = getJSONFixture('listings-api-index.json').listings
    fakeListing = getJSONFixture('listings-api-show.json').listing
    hasFilters = false
    fakeListingDataService =
      listings: fakeListings
      openListings: []
      closedListings: []
      listing: fakeListing
      AMICharts: []
      stubFeatures: () -> null
      loading: {}
      formattedAddress: jasmine.createSpy()
      getListingAMI: jasmine.createSpy()
      reservedLabel: jasmine.createSpy()
    fakeListingIdentityService =
      isOpen: jasmine.createSpy()
    fakeListingUnitService =
      getListingUnits: jasmine.createSpy()
      listingHasReservedUnits: jasmine.createSpy()
      listingHasSROUnits: jasmine.createSpy()

    beforeEach module('dahlia.components')
    beforeEach inject((_$componentController_) ->
      $componentController = _$componentController_
      locals = {
        $translate: $translate
        $window: fakeWindow
        ListingDataService: fakeListingDataService
        ListingIdentityService: fakeListingIdentityService
        ListingUnitService: fakeListingUnitService
        SharedService: fakeSharedService
      }
    )

    describe 'listingContainer', ->
      beforeEach ->
        ctrl = $componentController 'listingContainer', locals

      describe '$ctrl.$onInit', ->
        beforeEach ->
          ctrl.$onInit()

        it 'populates ctrl with array of listings', ->
          expect(ctrl.listings).toEqual fakeListings

        it 'populates ctrl with a single listing', ->
          expect(ctrl.listing).toEqual fakeListing

        it 'populates ctrl with AMICharts', ->
          expect(ctrl.AMICharts).toBeDefined()

        it 'populates ctrl with openListings', ->
          expect(ctrl.openListings).toBeDefined()

        it 'populates ctrl with closedListings', ->
          expect(ctrl.closedListings).toBeDefined()

      describe '$ctrl.reservedLabel', ->
        it 'calls ListingDataService.reservedLabel with the given arguments', ->
          type = 'foo'
          modifier = 'bar'
          ctrl.reservedLabel(fakeListing, type, modifier)
          expect(fakeListingDataService.reservedLabel).toHaveBeenCalledWith(fakeListing, type, modifier)

      describe '$ctrl.getListingAMI', ->
        it 'calls ListingDataService.getListingAMI with the given listing', ->
          ctrl.getListingAMI(fakeListing)
          expect(fakeListingDataService.getListingAMI).toHaveBeenCalledWith(fakeListing)

      describe '$ctrl.listingIsReservedCommunity', ->
        it "returns true if the listing's Reserved_community_type property is truthy", ->
          listing = fakeListing
          listing.Reserved_community_type = 'Senior'
          expect(ctrl.listingIsReservedCommunity(listing)).toEqual true
        it "returns false if the listing's Reserved_community_type property is falsey", ->
          listing = fakeListing
          listing.Reserved_community_type = null
          expect(ctrl.listingIsReservedCommunity(listing)).toEqual false

      describe '$ctrl.listingHasReservedUnits', ->
        it "calls ListingUnitService.listingHasReservedUnits with the given listing", ->
          ctrl.listingHasReservedUnits(fakeListing)
          expect(fakeListingUnitService.listingHasReservedUnits).toHaveBeenCalledWith(fakeListing)

      describe '$ctrl.listingApplicationClosed', ->
        it 'expects ListingIdentityService.isOpen to be called', ->
          ctrl.listingApplicationClosed(fakeListing)
          expect(fakeListingIdentityService.isOpen).toHaveBeenCalled()

      describe '$ctrl.formattedBuildingAddress', ->
        it 'expects ListingDataService.formattedAddress to be called', ->
          display = 'full'
          ctrl.formattedBuildingAddress(fakeListing, display)
          expect(fakeListingDataService.formattedAddress).toHaveBeenCalledWith(fakeListing, 'building', display)

      describe '$ctrl.getListingUnits', ->
        it 'calls ListingUnitService.getListingUnits with the given listing', ->
          ctrl.getListingUnits(fakeListing)
          expect(fakeListingUnitService.getListingUnits).toHaveBeenCalledWith(fakeListing)

      describe '$ctrl.formattedLeasingAgentAddress', ->
        it 'calls ListingDataService.formattedAddress', ->
          ctrl.formattedLeasingAgentAddress(fakeListing)
          expect(fakeListingDataService.formattedAddress).toHaveBeenCalledWith(fakeListing, 'leasing_agent')

      describe '$ctrl.listingHasSROUnits', ->
        it 'calls ListingUnitService.listingHasSROUnits with the given listing', ->
          ctrl.listingHasSROUnits(fakeListing)
          expect(fakeListingUnitService.listingHasSROUnits).toHaveBeenCalledWith(fakeListing)

      describe '$ctrl.agentInfoAvailable', ->
        it 'returns undefined if agents info is not available', ->
          fakeListing.leasing_agent_street = undefined
          expect(ctrl.agentInfoAvailable(fakeListing)).not.toBeDefined()

        it 'returns defined object if agents info is available', ->
          fakeListing.leasing_agent_street = '1 South Van Ness Ave San Francisco CA 94131'
          expect(ctrl.agentInfoAvailable(fakeListing)).toBeDefined()
