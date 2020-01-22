angular.module('dahlia.components')
.component 'listingContainer',
  transclude: true
  templateUrl: 'listings/components/listing-container.html'
  controller: ['$window', '$translate', 'ListingDataService', 'ListingIdentityService', 'ListingUnitService', 'SharedService',
  ($window, $translate, ListingDataService, ListingIdentityService, ListingUnitService, SharedService) ->
    ctrl = @

    @$onInit = ->
      # TODO: remove Shared Service once we create a Shared Container
      ctrl.currentGroup = SharedService.currentGroup
      ctrl.listingEmailAlertUrl = "http://eepurl.com/dkBd2n"
      ctrl.additionalResourcesUrl = $translate.instant('WELCOME.ADDITIONAL_RESOURCES_URL')
      ctrl.assetPaths = SharedService.assetPaths
      ctrl.listing = ListingDataService.listing
      ctrl.listings = ListingDataService.listings
      ctrl.loading  = ListingDataService.loading
      ctrl.error = ListingDataService.error
      ctrl.toggleStates = ListingDataService.toggleStates
      ctrl.AMICharts = ListingDataService.AMICharts
      ctrl.openListings = ListingDataService.openListings
      ctrl.closedListings = ListingDataService.closedListings

    @reservedLabel = (listing, type, modifier) ->
      ListingDataService.reservedLabel(listing, type, modifier)
    
    @reservedForLabels = (listing) ->
      types = []
      _.each listing.reserved_descriptor, (descriptor) ->
        if descriptor.name
          type = descriptor.name
          types.push(ListingDataService.reservedLabel(listing, type, 'reservedForWhoAre'))
      if types.length then types.join(' or ') else ''

    @getListingAMI =(listing) ->
      ListingDataService.getListingAMI(listing)

    @listingIsReservedCommunity = (listing) ->
      !! listing.Reserved_community_type

    @listingHasReservedUnits = (listing) ->
      ListingUnitService.listingHasReservedUnits(listing)

    @listingApplicationClosed = (listing) ->
      !ListingIdentityService.isOpen(listing)

    @formattedBuildingAddress = (listing, display) ->
      ListingDataService.formattedAddress(listing, 'building', display)

    @formattedLeasingAgentAddress = (listing) ->
      ListingDataService.formattedAddress(listing, 'leasing_agent')

    @getListingUnits = (listing) ->
      ListingUnitService.getListingUnits(listing)

    @listingHasSROUnits = (listing) ->
      ListingUnitService.listingHasSROUnits(listing)

    @listingIsSimplifiedSROWithNoDeadline = (listing) ->
      # NOTE: this is not an ideal approach…
      listing.id == 9

    @listingSupportsDevelopmentalDisabilities = (listing) ->
      ListingUnitService.listingSupportsDevelopmentalDisabilities(listing)

    @agentInfoAvailable = (listing) ->
      listing.leasing_agent_phone || listing.leasing_agent_email || listing.leasing_agent_street

    return ctrl
  ]
