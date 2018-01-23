angular.module('dahlia.directives')
.directive 'myApplication', [
  '$translate', '$window', 'ShortFormApplicationService', 'ListingService', 'ModalService',
  ($translate, $window, ShortFormApplicationService, ListingService, ModalService) ->
    replace: true
    scope:
      application: '=application'
    templateUrl: 'account/directives/my-application.html'

    link: (scope, elem, attrs) ->
      scope.listing = scope.application.listing
      scope.application.deleted = false

      scope.isDeleted = ->
        scope.application.deleted

      scope.unitSummary = ->
        return '' unless scope.listing.unitSummary
        # Studio: 22 units, 1 Bedroom: 33 units 2 Bedroom: 38 units
        summary = []
        scope.listing.unitSummary.forEach (type) ->
          str = "#{type.unitType}: #{type.totalUnits} unit"
          str += 's' if type.totalUnits > 1
          summary.push str
        summary.join(', ')

      scope.deleteApplication = (id) ->
        content =
          title: $translate.instant('T.DELETE_APPLICATION')
          cancel: $translate.instant('LABEL.CANCEL')
          continue: $translate.instant('T.DELETE')
          message: $translate.instant('MY_APPLICATIONS.ARE_YOU_SURE_YOU_WANT_TO_DELETE')
          alert: true
        ModalService.alert(content,
          onConfirm: ->
            ShortFormApplicationService.deleteApplication(id).success ->
              scope.application.deleted = true
        )

      scope.formattedAddress = ->
        ListingService.formattedAddress(scope.listing, 'Building')

      scope.applicationStyle = ->
        {
          'is-submitted': scope.isSubmitted()
          'is-past-due': scope.isPastDue()
          'is-editable': !scope.isSubmitted()
        }

      scope.isSubmitted = ->
        ShortFormApplicationService.applicationWasSubmitted(scope.application)

      scope.isPastDue = ->
        moment(scope.listing.Application_Due_Date) < moment()

      scope.lotteryNumber = ->
        { lotteryNumber: scope.application.lotteryNumber }

      scope.getLanguageCode = (application) ->
        ShortFormApplicationService.getLanguageCode(application)

]
