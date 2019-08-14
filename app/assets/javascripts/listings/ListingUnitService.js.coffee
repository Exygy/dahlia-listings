############################################################################################
####################################### SERVICE ############################################
############################################################################################

ListingUnitService = ($http, ListingConstantsService, ListingIdentityService) ->
  Service = {}
  Service.loading = {}
  Service.error = {}

  Service._sortGroupedUnits = (units) ->
    # little hack to re-sort Studio to the top
    _.map units, (u) ->
      u.unit_type = '000Studio' if u.unit_type == 'Studio'
      u.unit_type = '000SRO' if u.unit_type == 'SRO'
      return u
    # sort everything based on the order presented in pickList
    units = _.sortBy units, ListingConstantsService.fieldsForUnitGrouping
    # put "Studio" back to normal
    _.map units, (u) ->
      u.unit_type = 'Studio' if u.unit_type == '000Studio'
      u.unit_type = 'SRO' if u.unit_type == '000SRO'
      return u

  Service.unitAreaRange = (units) ->
    min = (_.minBy(units, 'sq_ft') || {})['sq_ft']
    max = (_.maxBy(units, 'sq_ft') || {})['sq_ft']
    if min != max
      "#{min} - #{max}"
    else
      min

  ordinalize = (num) ->
    standardSuffix = 'th'
    oneToThreeSuffixes = ['st', 'nd', 'rd']

    numStr = num.toString()
    lastTwoDigits = +(numStr.slice(-2))
    lastDigit = +(numStr.slice(-1))

    suffix = if ((1 <= lastDigit <= 3) && !(11 <= lastTwoDigits <= 13))
      oneToThreeSuffixes[lastDigit - 1]
    else
      standardSuffix

    return "#{num}#{suffix}"

  Service.unitFloorRange = (units) ->
    floorNums = _.filter(_.map(units, 'floor'), (f) ->
      /^[1-9]+$/.test(f)
    )
    uniqSortedFloorNums = _.sortBy(_.uniq(floorNums))

    return '' if _.isEmpty(uniqSortedFloorNums)

    if uniqSortedFloorNums.length == 1
      "#{ordinalize(uniqSortedFloorNums[0]) } floor"
    else
      lowestFloor = ordinalize(uniqSortedFloorNums[0])
      highestFloor = ordinalize(_.last(uniqSortedFloorNums))
      "#{lowestFloor} - #{highestFloor} floors"

  Service.combineUnitSummaries = (listing) ->
    # combined unit_summaries is useful e.g. for overall occupancy levels across the whole listing
    listing.unit_summaries ?= {}
    combined = _.concat(listing.unit_summaries.reserved, listing.unit_summaries.general)
    combined = _.omitBy(_.uniqBy(combined, 'unit_type'), _.isNil)
    # rename the unit_type field to match how individual units are labeled
    _.map(combined, (u) -> u.unit_type = u.unit_type)
    Service._sortGroupedUnits(combined)

  Service.groupUnitDetails = (units) ->
    grouped = _.groupBy units, 'ami_percentage'
    flattened = {}
    _.forEach grouped, (amiUnits, percent) ->
      percent = parseInt(percent)
      flattened[percent] = []
      grouped[percent] = _.groupBy amiUnits, (unit) ->
        # create an identity function to group by all unit features in the pickList
        _.flatten(_.toPairs(_.pick(unit, ListingConstantsService.fieldsForUnitGrouping)))
      _.forEach grouped[percent], (groupedUnits, id) ->
        # summarize each group by combining the unit details + total # of units
        summary = _.pick(groupedUnits[0], ListingConstantsService.fieldsForUnitGrouping)
        summary.total = groupedUnits.length
        flattened[percent].push(summary)

      # make sure each array is sorted according to our desired order
      flattened[percent] = Service._sortGroupedUnits(flattened[percent])
    return flattened

  Service.groupUnitTypes = (units) ->
    # get a grouping of unit types across both "general" and "reserved"
    grouped = _.groupBy units, 'unit_type'
    unitTypes = []
    _.forEach grouped, (groupedUnits, type) ->
      group = {}
      group.unitType = type
      group.unitTypeLabel = groupedUnits[0].unit_type_label
      group.units = groupedUnits
      group.unitAreaRange = Service.unitAreaRange(groupedUnits)
      group.unitFloorRange = Service.unitFloorRange(groupedUnits)
      unitTypes.push(group)
    unitTypes

  Service.groupSpecialUnits = (units, type) ->
    grouped = _.groupBy units, type
    delete grouped['undefined']
    delete grouped[null]
    grouped

  Service.getListingUnits = (listing, forceRecache = false) ->
    Service.loading.units = true
    Service.error.units = false
    httpConfig = {}
    httpConfig.params = { force: true } if forceRecache
    $http.get("/api/v1/listings/#{listing.id}/units", httpConfig)
    .then((response) ->
      data = response.data
      Service.loading.units = false
      Service.error.units = false
      if data && data.units
        units = data.units
        listing.Units = units
        listing.groupedUnits = Service.groupUnitDetails(units)
        listing.unitTypes = Service.groupUnitTypes(units)
        listing.priorityUnits = Service.groupSpecialUnits(listing.Units, 'priority_type')
        listing.reservedUnits = Service.groupSpecialUnits(listing.Units, 'reserved_type')
    ).catch((response) ->
      Service.loading.units = false
      Service.error.units = true
      return
    )

  Service.listingHasPriorityUnits = (listing) ->
    !_.isEmpty(listing.priorityUnits)

  Service.listingHasReservedUnits = (listing) ->
    !_.isEmpty(listing.unit_summaries.reserved)

  # `type` should match what we get from Salesforce e.g. "Veteran"
  Service.listingHasReservedUnitType = (listing, type) ->
    return false unless Service.listingHasReservedUnits(listing)
    types = _.map listing.reserved_descriptor, (descriptor) -> descriptor.name
    _.includes(types, type)

  Service.listingHasSROUnits = (listing) ->
    combined = Service.combineUnitSummaries(listing)
    _.some(combined, { unit_type: 'SRO' })

  Service.listingSupportsDevelopmentalDisabilities = (listing) ->
    # NOTE: this is not shown ever at present…subject to future revision
    return false

  Service.listingHasOnlySROUnits = (listing) ->
    combined = Service.combineUnitSummaries(listing)
    _.every(combined, { unit_type: 'SRO' })

  return Service

############################################################################################
######################################## CONFIG ############################################
############################################################################################

ListingUnitService.$inject = ['$http', 'ListingConstantsService', 'ListingIdentityService']

angular
  .module('dahlia.services')
  .service('ListingUnitService', ListingUnitService)
