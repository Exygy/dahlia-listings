do ->
  'use strict'
  describe 'ListingEligibilityService', ->
    ListingEligibilityService = undefined
    fakeListing = getJSONFixture('listings-api-show.json')
    fakeEligibilityListings = getJSONFixture('listings-api-eligibility-listings.json')
    fakeAMI = getJSONFixture('listings-api-ami.json')
    # fakeListingAllSRO has only one unit summary, in general, for SRO
    fakeListingAllSRO = angular.copy(fakeListing.listing)
    fakeListingAllSRO.unit_summaries =
      reserved: null
      general: [angular.copy(fakeListing.listing.unit_summaries.general[0])]
    fakeListingAllSRO.unit_summaries.general[0].unit_type = 'SRO'
    fakeListingAllSRO.unit_summaries.general[0].occupancy_range.max = 1
    $localStorage = undefined
    incomeLevels = undefined
    minMax = undefined

    beforeEach module('dahlia.services', ->
    )

    beforeEach inject((_$localStorage_, _ListingEligibilityService_) ->
      $localStorage = _$localStorage_
      ListingEligibilityService = _ListingEligibilityService_
      return
    )

    describe 'Service.incomeForHouseholdSize', ->
      it 'should get the income amount for the selected AMI Chart and householdIncomeLevel', ->
        fakeChart = fakeAMI.ami[0]
        fakeIncomeLevel = {numOfHousehold: 2}
        amount = ListingEligibilityService.incomeForHouseholdSize(fakeChart, fakeIncomeLevel)
        expect(amount).toEqual fakeChart.values[1].amount

    describe 'Service.occupancyIncomeLevels', ->
      beforeEach ->
        minMax = [1, 2]
        ListingEligibilityService.occupancyMinMax = jasmine.createSpy().and.returnValue(minMax)
        incomeLevels = ListingEligibilityService.occupancyIncomeLevels(fakeListing.listing, fakeAMI.ami[0])

      it 'should filter the incomeLevels to start from min household', ->
        expect(incomeLevels[0].numOfHousehold).toEqual minMax[0]

      it 'should filter the incomeLevels to end at max household + 2', ->
        expect(incomeLevels.slice(-1)[0].numOfHousehold).toEqual minMax[1] + 2

      it 'should filter the incomeLevels to only show 1 person if all SROs', ->
        incomeLevels = ListingEligibilityService.occupancyIncomeLevels(fakeListingAllSRO, fakeAMI.ami[0])
        minMax = ListingEligibilityService.occupancyMinMax(fakeListingAllSRO)
        expect(incomeLevels.slice(-1)[0].numOfHousehold).toEqual 1

    describe 'Service.householdAMIChartCutoff', ->
      it 'returns 1 if all units are SROs', ->
        expect(ListingEligibilityService.householdAMIChartCutoff(fakeListingAllSRO)).toEqual(1)
