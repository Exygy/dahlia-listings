angular.module('dahlia.components')
.component 'panelApply',
  templateUrl: 'listings/components/listing/panel-apply.html'
  require:
    parent: '^listingContainer'
  controller: [
    'ListingDataService', 'AnalyticsService',
    (ListingDataService, AnalyticsService) ->
      ctrl = @

      @$onInit = ->
        ctrl.listingAppURLs = ListingDataService.listingAppURLs

      @toggleApplicationOptions = () ->
        ctrl.showApplicationOptions = !ctrl.showApplicationOptions

      return ctrl
  ]
