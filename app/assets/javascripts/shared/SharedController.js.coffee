############################################################################################
###################################### CONTROLLER ##########################################
############################################################################################

SharedController = ($scope, $state, $stateParams, $translate, $window, SharedService, ExternalTranslateService) ->
  $scope.assetPaths = SharedService.assetPaths
  $scope.housingCounselors = SharedService.housingCounselors
  $scope.alternateLanguageLinks = SharedService.alternateLanguageLinks

  $scope.doNotGoogleTranslate = ->
    $scope.isWelcomePage() || $scope.isEnglish()

  $scope.showTranslationExpertMessage = ->
    $scope.isWelcomePage()

  $scope.isWelcomePage = ->
    SharedService.isWelcomePage()

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

  $scope.translateWelcomePath = ->
    translateWelcomeMap =
      'zh': 'welcome-chinese'
      'es': 'welcome-spanish'
      'en': 'welcome'
      'tl': 'welcome-filipino'

    stateName = translateWelcomeMap[$stateParams.lang]
    return "dahlia.#{stateName}({'#': 'translation-disclaimer'})"

############################################################################################
######################################## CONFIG ############################################
############################################################################################

SharedController.$inject = [
  '$scope', '$state', '$stateParams', '$translate', '$window', 'SharedService', 'ExternalTranslateService'
]

angular
  .module('dahlia.controllers')
  .controller('SharedController', SharedController)
