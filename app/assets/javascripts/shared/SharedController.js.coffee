############################################################################################
###################################### CONTROLLER ##########################################
############################################################################################

SharedController = ($scope, $state, $stateParams, $translate, $window, SharedService, ExternalTranslateService) ->
  $scope.assetPaths = SharedService.assetPaths
  $scope.housingCounselors = SharedService.housingCounselors
  $scope.alternateLanguageLinks = SharedService.alternateLanguageLinks

  $scope.doNotGoogleTranslate = ->
    $scope.isShortFormPage() || $scope.isWelcomePage() || $scope.isEnglish()

  $scope.showTranslationExpertMessage = ->
    $scope.isShortFormPage() || $scope.isWelcomePage()

  $scope.isShortFormPage = ->
    $state.includes('dahlia.short-form-welcome') || $state.includes('dahlia.short-form-application')

  $scope.isWelcomePage = ->
    SharedService.isWelcomePage()

  $scope.isEnglish = ->
    $state.params.lang == 'en'

  $scope.feedbackUrl = () ->
    $translate.instant('NAV.FEEDBACK_URL')

  $scope.listingEmailAlertUrl = "http://eepurl.com/dkBd2n"

  $scope.alertMessage = if $window.ALERT_MESSAGE then $window.ALERT_MESSAGE else ''

  $scope.hasCenterBody = () ->
    if $state.includes('dahlia.short-form-welcome') ||
      $state.includes('dahlia.short-form-application') ||
      $state.includes('dahlia.my-applications')
        return 'center-body'

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
