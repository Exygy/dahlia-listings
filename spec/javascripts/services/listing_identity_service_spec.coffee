do ->
  'use strict'
  describe 'ListingIdentityService', ->
    ListingIdentityService = undefined
    fakeListing = getJSONFixture('listings-api-show.json').listing
    tomorrow = new Date()
    tomorrow.setDate(tomorrow.getDate() + 1)
    lastWeek = new Date()
    lastWeek.setDate(lastWeek.getDate() - 7)
    testListing = null

    beforeEach module('dahlia.services', ($provide) ->
      return
    )

    beforeEach inject((_ListingIdentityService_) ->
      ListingIdentityService = _ListingIdentityService_
      return
    )

    describe 'Service.isOpen', ->
      beforeEach ->
        testListing = angular.copy(fakeListing)

      it 'returns true if listing application due date has not passed', ->
        testListing.application_due_date = tomorrow.toString()
        expect(ListingIdentityService.isOpen(testListing)).toEqual true
      it 'returns false if listing application due date has passed', ->
        testListing.application_due_date = lastWeek.toString()
        expect(ListingIdentityService.isOpen(testListing)).toEqual false

