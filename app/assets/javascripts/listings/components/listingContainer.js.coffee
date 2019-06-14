angular.module('dahlia.components')
.component 'listingContainer',
  transclude: true
  templateUrl: 'listings/components/listing-container.html'
  controller: ['$window', 'ListingDataService', 'ListingIdentityService', 'ListingUnitService', 'SharedService',
  ($window, ListingDataService, ListingIdentityService, ListingUnitService, SharedService) ->
    ctrl = @

    @$onInit = ->
      # TODO: remove Shared Service once we create a Shared Container
      ctrl.listingEmailAlertUrl = "http://eepurl.com/dkBd2n"
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

    @getListingAMI =(listing) ->
      ListingDataService.getListingAMI(listing)

    @listingIsReservedCommunity = (listing) ->
      !! listing.Reserved_community_type

    @listingHasReservedUnits = (listing) ->
      ListingUnitService.listingHasReservedUnits(listing)

    @listingApplicationClosed = (listing) ->
      !ListingIdentityService.isOpen(listing)

    @formattedBuildingAddress = (listing, display) ->
      ListingDataService.formattedAddress(listing, 'Building', display)

    @formattedLeasingAgentAddress = (listing) ->
      ListingDataService.formattedAddress(listing, 'leasing_agent')

    @getListingUnits = (listing) ->
      ListingUnitService.getListingUnits(listing)

    @listingHasSROUnits = (listing) ->
      ListingUnitService.listingHasSROUnits(listing)

    @agentInfoAvailable = (listing) ->
      listing.leasing_agent_phone || listing.leasing_agent_email || listing.leasing_agent_street

    return ctrl
  ]
