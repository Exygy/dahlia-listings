angular.module('dahlia.components')
.component 'eligibilitySection',
  templateUrl: 'listings/components/listing/eligibility-section.html'
  require:
    parent: '^listingContainer'
  controller: [
    '$filter', '$translate', 'ListingDataService', 'ListingEligibilityService', 'ListingPreferenceService', 'ListingUnitService',
    ($filter, $translate, ListingDataService, ListingEligibilityService, ListingPreferenceService, ListingUnitService) ->
      ctrl = @

      @loading = ListingPreferenceService.loading
      @error = ListingPreferenceService.error

      @formatUnitSummaryOccupancy = (unitSummary) ->
        if unitSummary.occupancy_range.max == 1
          '1'
        else if unitSummary.occupancy_range.max == null
          "at least #{unitSummary.occupancy_range.min}"
        else
          "#{unitSummary.occupancy_range.min}-#{unitSummary.occupancy_range.max}"

      @occupancyLabel = (numberOfPeople) ->
        return $translate.instant('LISTINGS.PERSON') if numberOfPeople == 1
        $translate.instant('LISTINGS.PEOPLE')

      @showAMItoggler = ->
        return false if _.isEmpty(ListingDataService.AMICharts)
        amiLevel = _.last(ListingDataService.AMICharts)
        lastHouseholdIncomeLevel = ListingEligibilityService.occupancyIncomeLevels(this.parent.listing, amiLevel)
        maxNumOfHousehold = _.max(_.map(lastHouseholdIncomeLevel, 'numOfHousehold'))
        maxNumOfHousehold > ListingEligibilityService.householdAMIChartCutoff(this.parent.listing)

      @hasMultipleAMICharts = ->
        ListingDataService.AMICharts.length > 1

      @listingHasPreferences = ->
        this.parent.listing.preferences && this.parent.listing.preferences.length > 0

      @listingHasOnlySROUnits = ->
        ListingUnitService.listingHasOnlySROUnits(this.parent.listing)

      @getListingPreferences = ->
        ListingPreferenceService.getListingPreferences(this.parent.listing)

      @listingHasPriorityUnits = ->
        ListingUnitService.listingHasPriorityUnits(this.parent.listing)

      @priorityLabel = (priority, modifier) ->
        ListingDataService.priorityLabel(priority, modifier)

      @occupancyIncomeLevels = (amiLevel) ->
        ListingEligibilityService.occupancyIncomeLevels(this.parent.listing, amiLevel)

      @householdAMIChartCutoff = ->
        ListingEligibilityService.householdAMIChartCutoff(this.parent.listing)

      @formatIncomeForHouseholdSize = (amiChart, householdIncomeLevel) ->
        income = ListingEligibilityService.incomeForHouseholdSize(amiChart, householdIncomeLevel)
        if income
          $filter('currency')(income, '$', 0) + '<small>/year</small>'

      return ctrl
  ]
