do ->
  'use strict'
  describe 'Feature Section Component', ->
    $componentController = undefined
    ctrl = undefined
    locals = undefined
    fakeListings = getJSONFixture('listings-api-index.json').listings
    fakeListing = getJSONFixture('listings-api-show.json').listing
    fakeParent = {
      listing: fakeListing
    }
    fakeStates = {}
    fakeTable = {
      table1: true,
      table2: false
    }
    fakeStates[fakeListing.id] = fakeTable
    fakeListingDataService =
      listings: fakeListings
      toggleStates: fakeStates

    beforeEach module('dahlia.components')
    beforeEach inject((_$componentController_) ->
      $componentController = _$componentController_
      locals = {
        ListingDataService: fakeListingDataService
      }
    )

    describe 'featuresSection', ->
      beforeEach ->
        ctrl = $componentController 'featuresSection', locals, {parent: fakeParent}

      describe 'toggleTable', ->
        describe "when the given table's toggle state is true", ->
          it 'set its toggle state to false', ->
            table1ToggleStateVal = fakeListingDataService.toggleStates[fakeListing.id]['table1']
            ctrl.toggleTable('table1')
            expect(fakeListingDataService.toggleStates[fakeListing.id]['table1']).toEqual false
        describe "when the given table's toggle state is false", ->
          it 'set its toggle state to true', ->
            table1ToggleStateVal = fakeListingDataService.toggleStates[fakeListing.id]['table2']
            ctrl.toggleTable('table2')
            expect(fakeListingDataService.toggleStates[fakeListing.id]['table2']).toEqual true

      describe 'listingIsBMR', ->
        it 'returns false if the listing program type is not a BMR type', ->
          ctrl.parent.listing.program_type = 'OCII-RENTAL'
          expect(ctrl.listingIsBMR()).toEqual false

        it 'returns true if the listing program type is a BMR type', ->
          ctrl.parent.listing.program_type = 'IH-RENTAL'
          expect(ctrl.listingIsBMR()).toEqual true
