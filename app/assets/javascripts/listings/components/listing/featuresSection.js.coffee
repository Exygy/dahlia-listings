angular.module('dahlia.components')
.component 'featuresSection',
  templateUrl: 'listings/components/listing/features-section.html'
  require:
    parent: '^listingContainer'
  controller: ['ListingDataService', (ListingDataService) ->
    ctrl = @

    ctrl.toggleTable = (table) ->
      ListingDataService.toggleStates[ctrl.parent.listing.id][table] = !ListingDataService.toggleStates[ctrl.parent.listing.id][table]

    @listingIsBMR = ->
      this.parent.listing.program_type == 'IH-RENTAL'

    return ctrl
  ]
