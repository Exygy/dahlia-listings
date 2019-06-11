do ->
  'use strict'
  describe 'ListingPreferenceService', ->
    ListingPreferenceService = undefined
    httpBackend = undefined
    fakeListing = getJSONFixture('listings-api-show.json').listing
    listing = null
    fakePreferences = getJSONFixture('listings-api-listing-preferences.json')
    loading = {}

    beforeEach module('ui.router')
    beforeEach module('dahlia.services', ->
      return
    )

    beforeEach inject((_ListingPreferenceService_, _$httpBackend_) ->
      httpBackend = _$httpBackend_
      ListingPreferenceService = _ListingPreferenceService_
      return
    )

    describe 'Service.getListingPreferences', ->
      beforeEach (done) ->
        # have to populate listing first
        listing = angular.copy(fakeListing)
        listing.id = 'fakeId-123'
        # just to divert from our hardcoding
        preferences = angular.copy(fakePreferences)
        stubAngularAjaxRequest httpBackend, "/api/v1/listings/#{listing.id}/preferences", preferences
        ListingPreferenceService.getListingPreferences(listing)
        done()

      afterEach ->
        httpBackend.verifyNoOutstandingExpectation()
        httpBackend.verifyNoOutstandingRequest()

      it 'assigns Service.listing.preferences with the Preference results', ->
        httpBackend.flush()
        expect(listing.preferences).toEqual fakePreferences.preferences
        expect(ListingPreferenceService.loading.preferences).toEqual false
