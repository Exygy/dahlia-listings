angular.module('dahlia.components')
.component 'listingResultsToggler',
  templateUrl: 'listings/components/listing-results-toggler.html'
  bindings:
    listingResults: '<'
    sectionName: '@'
    icon: '@'
  controller: ['$translate', ($translate) ->
    ctrl = @

    @$onInit = ->
      ctrl.toggleStates = {}
      ctrl.displayToggledSection = ctrl.toggleStates[ctrl.sectionName] ? false
      ctrl.togglerId = "#{ctrl.sectionName}-toggler"
      ctrl.text = {
        title: $translate.instant('LISTINGS.UPCOMING_LOTTERIES.TITLE')
        showResults: $translate.instant('LISTINGS.UPCOMING_LOTTERIES.SHOW')
        hideResults: $translate.instant('LISTINGS.UPCOMING_LOTTERIES.HIDE')
        noResults: $translate.instant('LISTINGS.UPCOMING_LOTTERIES.NO_RESULTS')
      }
      ctrl.hasListings = !!ctrl.listingResults.length

    @toggleListings = (e) ->
      # When you use keyboard nav to click on the button inside the header
      # for some reason it triggers both a MouseEvent and KeyboardEvent.
      # So, we ignore the KeyboardEvent.
      return if e.constructor.name == 'KeyboardEvent' and angular.element(e.target).hasClass('button')
      e.currentTarget.blur() if e
      @displayToggledSection = !@displayToggledSection
      @toggleStates[@sectionName] = @displayToggledSection

    return ctrl
  ]
