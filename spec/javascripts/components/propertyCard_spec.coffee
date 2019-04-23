do ->
  'use strict'
  describe 'Property Card Component', ->
    $componentController = undefined
    ctrl = undefined
    locals = undefined
    state = {current: {name: undefined}}
    $translate =
      instant: ->
    fakeListings = getJSONFixture('listings-api-index.json').listings
    fakeListing = getJSONFixture('listings-api-show.json').listing
    fakeSharedService = {
      showSharing: jasmine.createSpy()
    }
    fakeListing.reservedDescriptor = [{name: 'fake'}, {name: 'not'}]
    fakeListingContainer = {
      listing: fakeListing
      openNotMatchListings: []
      openListings: []
      closedListings: []
      lotteryResultsListings: []
      priorityTypeNames: jasmine.createSpy()
    }
    fakeListingDataService =
      listings: fakeListings
      priorityTypes: ->
      reservedLabel: ->
      priorityLabel: ->
    beforeEach module('dahlia.components')
    beforeEach inject((_$componentController_) ->
      $componentController = _$componentController_
      locals = {
        ListingDataService: fakeListingDataService
        SharedService: fakeSharedService
        $state: state
      }
    )

    describe 'propertyCard', ->
      beforeEach ->
        ctrl = $componentController 'propertyCard', locals, {listingContainer: fakeListingContainer}

      describe '$ctrl.showMatches', ->
        describe 'dahlia.listings-for-rent state with filters available', ->
          it 'returns true', ->
            state.current.name = 'dahlia.listings-for-rent'
            expect(ctrl.showMatches()).toEqual true

        describe 'filters unavailable', ->
          it 'returns false', ->
            state.current.name = 'dahlia.listings-for-rent'
            expect(ctrl.showMatches()).toEqual false

        describe 'state is not dahlia.listings-for-rent', ->
          it 'returns false', ->
            state.current.name = 'dahlia.home'
            expect(ctrl.showMatches()).toEqual false

      describe '$ctrl.isOpenNotMatchListing', ->
        describe 'open not matched listing', ->
          it 'returns true',->
            fakeListingContainer.openNotMatchListings = [fakeListing]
            expect(ctrl.isOpenNotMatchListing(fakeListing)).toEqual true

      describe '$ctrl.isOpenListing', ->
        describe 'open listing', ->
          it 'returns true',->
            fakeListingContainer.openListings = [fakeListing]
            expect(ctrl.isOpenListing(fakeListing)).toEqual true

        describe 'closed listing', ->
          it 'returns false',->
            fakeListingContainer.openListings = []
            expect(ctrl.isOpenListing(fakeListing)).toEqual false

      describe '$ctrl.isClosedListing', ->
        describe 'closed listing', ->
          it 'returns true',->
            fakeListingContainer.closedListings = [fakeListing]
            expect(ctrl.isClosedListing(fakeListing)).toEqual true

      describe '$ctrl.isLotteryResultsListing', ->
        describe 'lottery results listing', ->
          it 'returns true',->
            fakeListingContainer.lotteryResultsListings = [fakeListing]
            expect(ctrl.isLotteryResultsListing(fakeListing)).toEqual true

      describe '$ctrl.showSharing', ->
        it 'calls SharedService.showSharing', ->
          ctrl.showSharing()
          expect(fakeSharedService.showSharing).toHaveBeenCalled()

      describe '$ctrl.priorityTypes', ->
        it 'calls ListingDataService.priorityTypes', ->
          spyOn(fakeListingDataService, 'priorityTypes')
          ctrl.priorityTypes(fakeListing)
          expect(fakeListingDataService.priorityTypes).toHaveBeenCalledWith(fakeListing)

      describe '$ctrl.priorityTypeNames', ->
        it 'calls ListingDataService.priorityTypes', ->
          spyOn(fakeListingDataService, 'priorityLabel')
          spyOn(fakeListingDataService, 'priorityTypes').and.returnValue([1])
          ctrl.priorityTypeNames(fakeListing)
          expect(fakeListingDataService.priorityLabel).toHaveBeenCalledWith(1, 'name')
        it 'calls ListingDataService.priorityTypes', ->
          spyOn(fakeListingDataService, 'priorityTypes')
          spyOn(fakeListingDataService, 'priorityLabel')
          ctrl.priorityTypeNames(fakeListing)
          expect(fakeListingDataService.priorityTypes).toHaveBeenCalledWith(fakeListing)
        it 'returns joined names', ->
          spyOn(fakeListingDataService, 'priorityTypes').and.returnValue([1, 2])
          spyOn(fakeListingDataService, 'priorityLabel')
          ctrl.priorityTypeNames(fakeListing)
          expect(fakeListingDataService.priorityTypes).toHaveBeenCalledWith(fakeListing)

      describe '$ctrl.reservedForLabels', ->
        it 'calls ListingDataService.reservedLabel', ->
          spyOn(fakeListingDataService, 'reservedLabel').and.returnValue('fake')
          ctrl.reservedForLabels(fakeListing)
          expect(fakeListingDataService.reservedLabel).toHaveBeenCalled()
        it 'returns values joined with or', ->
          spyOn(fakeListingDataService, 'reservedLabel').and.returnValue('fake')
          expect(ctrl.reservedForLabels(fakeListing)).toEqual 'fake or fake'
        it 'returns empty string for empty reservedDescriptor', ->
          fakeListing.reservedDescriptor = null
          spyOn(fakeListingDataService, 'reservedLabel').and.returnValue('fake')
          expect(ctrl.reservedForLabels(fakeListing)).toEqual ''
