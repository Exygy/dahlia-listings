angular.module('dahlia.components')
.component 'featuresSection',
  templateUrl: 'listings/components/listing/features-section.html'
  require:
    parent: '^listingContainer'
  controller: ['ListingDataService', '$translate', (ListingDataService, $translate) ->
    ctrl = @

    @toggleTable = (table) ->
      ListingDataService.toggleStates[this.parent.listing.id][table] = !ListingDataService.toggleStates[this.parent.listing.id][table]

    @formatBaths = (numberOfBathrooms) ->
      return 'Shared' if numberOfBathrooms == 0
      return '1/2 ' + $translate.instant('LISTINGS.BATH') if numberOfBathrooms == 0.5

      fullBaths = Math.floor numberOfBathrooms
      andAHalf = numberOfBathrooms - fullBaths == 0.5

      if andAHalf
        fullBaths + ' 1/2 ' + $translate.instant('LISTINGS.BATH')
      else
        numberOfBathrooms

    @listingIsBMR = ->
      ['IH-RENTAL', 'IH-OWN'].indexOf(this.parent.listing.program_type) >= 0

    return ctrl
  ]
