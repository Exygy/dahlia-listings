do ->
  'use strict'
  describe 'Neighborhood Section Component', ->
    $componentController = undefined
    ctrl = undefined
    locals = undefined
    fakeListings = getJSONFixture('listings-api-index.json').listings
    fakeListing = getJSONFixture('listings-api-show.json').listing
    fakeParent = {
      listing: fakeListing
      formattedBuildingAddress: jasmine.createSpy()
    }
    fakeListingDataService =
      listings: fakeListings
    $sce = {
      trustAsResourceUrl: jasmine.createSpy()
    }

    beforeEach module('dahlia.components')
    beforeEach inject((_$componentController_) ->
      $componentController = _$componentController_
      locals = {
        ListingDataService: fakeListingDataService
        $sce: $sce
      }
    )

    describe 'neighborhoodSection', ->
      beforeEach ->
        ctrl = $componentController 'neighborhoodSection', locals, {parent: fakeParent}

      describe 'blank test', ->
        it 'does nothing. add some tests!', ->
          return false
