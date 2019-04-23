angular.module('dahlia.components')
.component 'browseListings',
  templateUrl: 'listings/components/browse-listings.html'
  require:
    parent: '^listingContainer'
  bindings:
    tenureType: '@'
  controller: ['$state', 'ListingDataService',
  ($state, ListingDataService) ->
    ctrl = @

    return ctrl
  ]
