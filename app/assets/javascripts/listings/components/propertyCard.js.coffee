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

      @reservedForLabels = (listing) ->
        types = []
        _.each listing.reserved_descriptor, (descriptor) ->
          if descriptor.name
            type = descriptor.name
            types.push(ListingDataService.reservedLabel(listing, type, 'reservedForWhoAre'))
        if types.length then types.join(' or ') else ' . '

      return ctrl
  ]
