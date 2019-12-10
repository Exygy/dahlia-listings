angular.module('dahlia.components')
.component 'propertyCard',
  templateUrl: 'listings/components/property-card.html'
  bindings:
    listing: '<'
  require:
    listingContainer: '^listingContainer'
  controller: [
    'ListingDataService', '$state',
    (ListingDataService, $state) ->
      ctrl = @

      @isOpenListing = (listing) ->
        this.listingContainer.openListings.indexOf(listing) > -1

      @isClosedListing = (listing) ->
        this.listingContainer.closedListings.indexOf(listing) > -1

      @priorityTypes = (listing) ->
        ListingDataService.priorityTypes(listing)

      @priorityTypeNames = (listing) ->
        names = _.map @priorityTypes(listing), (priority) ->
          ListingDataService.priorityLabel(priority, 'name')
        names.join(', ')

      return ctrl
  ]
