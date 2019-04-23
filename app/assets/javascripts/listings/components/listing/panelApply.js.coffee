angular.module('dahlia.components')
.component 'panelApply',
  templateUrl: 'listings/components/listing/panel-apply.html'
  require:
    parent: '^listingContainer'
  controller: [
    'ListingDataService', 'ListingLotteryService', 'AnalyticsService',
    (ListingDataService, ListingLotteryService, AnalyticsService) ->
      ctrl = @
      @listingPaperAppURLs = ListingDataService.listingPaperAppURLs

      @lotteryComplete = (listing) ->
        ListingLotteryService.lotteryComplete(listing)

      @toggleApplicationOptions = () ->
        ctrl.showApplicationOptions = !ctrl.showApplicationOptions

      return ctrl
  ]
