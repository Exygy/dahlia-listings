############################################################################################
####################################### SERVICE ############################################
############################################################################################

ListingEligibilityService = ($localStorage, ListingIdentityService, ListingUnitService) ->
  Service = {}

  Service.occupancyMinMax = (listing) ->
    minMax = [1, 1]
    if listing.unit_summaries
      min = _.min(_.map(listing.unit_summaries, 'occupancy_range.min')) || 1
      max = _.max(_.map(listing.unit_summaries, 'occupancy_range.max')) || null
      minMax = [min, max]
    return minMax

  Service.maxAmiNumHousehold = (amiLevel) ->
    _.max(_.map(amiLevel.values, (v) -> v.numOfHousehold))

  Service.occupancyIncomeLevels = (listing, amiLevel) ->
    return [] unless amiLevel
    occupancyMinMax = Service.occupancyMinMax(listing)
    min = occupancyMinMax[0]
    # We add '+ 2' for 2 children under 6 as part of householdsize but not occupancy. Unless it's max
    max = if _.isNumber(occupancyMinMax[1]) then occupancyMinMax[1] + 2 else Service.maxAmiNumHousehold(amiLevel)
    max = 1 if ListingUnitService.listingHasOnlySROUnits(listing)

    _.filter amiLevel.values, (value) ->
      # where numOfHousehold >= min && <= max
      value.numOfHousehold >= min && value.numOfHousehold <= max

  Service.incomeForHouseholdSize = (amiChart, householdIncomeLevel) ->
    incomeLevel = _.find amiChart.values, (value) ->
      value.numOfHousehold == householdIncomeLevel.numOfHousehold
    return unless incomeLevel
    incomeLevel.amount

  Service.householdAMIChartCutoff = (listing) ->
    return 1 if ListingUnitService.listingHasOnlySROUnits(listing)

    occupancyMinMax = Service.occupancyMinMax(listing)
    max = if _.isNumber(occupancyMinMax[1]) then occupancyMinMax[1] else 2
    # cutoff at 2x the num of bedrooms
    Math.floor(max/2) * 2

  return Service

############################################################################################
######################################## CONFIG ############################################
############################################################################################

ListingEligibilityService.$inject = ['$localStorage', 'ListingIdentityService', 'ListingUnitService']

angular
  .module('dahlia.services')
  .service('ListingEligibilityService', ListingEligibilityService)
