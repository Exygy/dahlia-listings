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
    fakeListingContainer = {
      listing: fakeListing
      openListings: []
      closedListings: []
      priorityTypeNames: jasmine.createSpy()
    }
    fakeListingDataService =
      listings: fakeListings
      priorityTypes: ->
      reservedLabel: -> 'fake'
      priorityLabel: ->
    beforeEach module('dahlia.components')
    beforeEach inject((_$componentController_) ->
      $componentController = _$componentController_
      locals = {
        ListingDataService: fakeListingDataService
        $state: state
      }
    )

    describe 'propertyCard', ->
      beforeEach ->
        ctrl = $componentController 'propertyCard', locals, {listingContainer: fakeListingContainer}

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
        it 'returns values joined with or', ->
          fakeListing.reservedDescriptor = [{name: 'fake'}, {name: 'not'}]
          expect(ctrl.reservedForLabels(fakeListing)).toEqual 'fake or fake'

        it 'returns empty string for empty reservedDescriptor', ->
          fakeListing.reservedDescriptor = null
          expect(ctrl.reservedForLabels(fakeListing)).toEqual ''
