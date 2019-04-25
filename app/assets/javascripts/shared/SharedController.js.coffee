############################################################################################
###################################### CONTROLLER ##########################################
############################################################################################

SharedController = ($scope, $state, $stateParams, $translate, $window, SharedService) ->
  $scope.assetPaths = SharedService.assetPaths
  $scope.housingCounselors = SharedService.housingCounselors

  $scope.doNotGoogleTranslate = ->
    $scope.isEnglish()

  $scope.isEnglish = ->
    $state.params.lang == 'en'

  $scope.feedbackUrl = () ->
    $translate.instant('NAV.FEEDBACK_URL')

  $scope.listingEmailAlertUrl = "http://eepurl.com/dkBd2n"

  $scope.alertMessage = if $window.ALERT_MESSAGE then $window.ALERT_MESSAGE else ''

  $scope.hasCenterBody = () ->
    return false

  $scope.focusOnMainContent = ->
    SharedService.focusOn('main-content')

############################################################################################
######################################## CONFIG ############################################
############################################################################################

SharedController.$inject = [
  '$scope', '$state', '$stateParams', '$translate', '$window', 'SharedService'
]

angular
  .module('dahlia.controllers')
  .controller('SharedController', SharedController)
