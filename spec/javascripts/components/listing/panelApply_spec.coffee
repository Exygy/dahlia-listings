do ->
  'use strict'
  describe 'Panel Apply Component', ->
    $componentController = undefined
    ctrl = undefined
    locals = undefined
    $translate =
      instant: ->
    fakeListings = getJSONFixture('listings-api-index.json').listings
    fakeListing = getJSONFixture('listings-api-show.json').listing
    fakeParent = {
      listing: fakeListing
    }
    fakeListingDataService =
      listings: fakeListings
    fakeAnalyticsService = {
      trackTimerEvent: jasmine.createSpy()
    }
    beforeEach module('dahlia.components')
    beforeEach inject((_$componentController_) ->
      $componentController = _$componentController_
      locals = {
        ListingDataService: fakeListingDataService
        AnalyticsService: fakeAnalyticsService
      }
    )

    describe 'panelApply', ->
      beforeEach ->
        ctrl = $componentController 'panelApply', locals, {parent: fakeParent}

      describe '$ctrl.toggleApplicationOptions', ->
        it 'toggles showApplicationOptions', ->
          ctrl.showApplicationOptions = false
          ctrl.toggleApplicationOptions()
          expect(ctrl.showApplicationOptions).toEqual true
