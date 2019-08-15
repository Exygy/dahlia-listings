angular.module('dahlia.components')
.component 'unitSummaryAccordion',
  templateUrl: 'listings/components/listing/unit-summary-accordion.html'
  bindings:
    expandable: '<'
    toggleStates: '<'
    toggleTable: '<'
    unitGroups: '<'
  controller: ['$translate', ($translate) ->
    ctrl = @

    ctrl.formatBaths = (numberOfBathrooms) ->
      return 'Shared' if numberOfBathrooms == 0
      return '1/2 ' + $translate.instant('LISTINGS.BATH') if numberOfBathrooms == 0.5

      fullBaths = Math.floor numberOfBathrooms
      andAHalf = numberOfBathrooms - fullBaths == 0.5

      if andAHalf
        fullBaths + ' 1/2 ' + $translate.instant('LISTINGS.BATH')
      else
        numberOfBathrooms

    return ctrl
  ]
