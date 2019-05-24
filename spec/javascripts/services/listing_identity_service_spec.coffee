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

    describe 'Service.isRental', ->
      beforeEach ->
        testListing = angular.copy(fakeListing)

      describe 'when the listing has a rental tenure', ->
        it 'returns true', ->
          testListing.Tenure = 'New rental'
          expect(ListingIdentityService.isRental(testListing)).toEqual true
          testListing.Tenure = 'Re-rental'
          expect(ListingIdentityService.isRental(testListing)).toEqual true

      describe 'when the listing does not have a tenure defined', ->
        it 'returns false', ->
          delete testListing.Tenure
          expect(ListingIdentityService.isRental(testListing)).toEqual false

    describe 'Service.isOpen', ->
      beforeEach ->
        testListing = angular.copy(fakeListing)

      it 'returns true if listing application due date has not passed', ->
        testListing.application_due_date = tomorrow.toString()
        expect(ListingIdentityService.isOpen(testListing)).toEqual true
      it 'returns false if listing application due date has passed', ->
        testListing.application_due_date = lastWeek.toString()
        expect(ListingIdentityService.isOpen(testListing)).toEqual false

