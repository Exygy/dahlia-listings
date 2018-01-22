AccountController = (
  $scope,
  $state,
  $document,
  $translate,
  AccountService,
  AnalyticsService,
  ShortFormApplicationService,
  SharedService
  inputMaxLength
) ->
  $scope.rememberedShortFormState = AccountService.rememberedShortFormState
  $scope.form = { current: {} }
  # userAuth is used as model for inputs in create-account form
  $scope.userAuth = AccountService.userAuth
  $scope.myApplications = AccountService.myApplications
  $scope.createdAccount = AccountService.createdAccount
  $scope.currentApplication = AccountService.currentApplication
  # hideAlert tracks if the user has manually closed the alert "X"
  $scope.hideAlert = false
  $scope.hideMessage = false
  $scope.accountError = AccountService.accountError
  $scope.accountSuccess = AccountService.accountSuccess
  $scope.submitDisabled = false
  $scope.resendDisabled = false
  # track if user has re-sent confirmation inside the modal
  $scope.resentConfirmationMessage = null
  $scope.userDataForContact = {}
  $scope.emailChanged = false
  $scope.nameOrDOBChanged = false
  $scope.INPUT_MAX_LENGTH = inputMaxLength

  $scope.passwordRegex = /^(?=.*[0-9])(?=.*[a-zA-Z])(.+){8,}$/
  $scope.emailRegex = SharedService.emailRegex

  $scope.accountForm = ->
    # pick up which ever one is defined (the other will be undefined)
    $scope.form.signIn ||
    $scope.form.createAccount ||
    $scope.form.updatePassword ||
    $scope.form.passwordReset ||
    $scope.form.current

  $scope.closeAlert = ->
    $scope.hideAlert = true

  $scope.handleErrorState = ->
    if !$scope.accountError.messages.user
      $scope.accountError.messages.user = $translate.instant('ERROR.FORM_SUBMISSION')
    # show error alert
    $scope.hideAlert = false
    el = angular.element(document.getElementById('form-wrapper'))
    # uses duScroll aka 'angular-scroll' module
    topOffset = 0
    duration = 400 # animation speed in ms
    $document.scrollToElement(el, topOffset, duration)

  $scope.inputInvalid = (fieldName, identifier = '') ->
    form = $scope.accountForm()
    return false unless form
    fieldName = if identifier then "#{identifier}_#{fieldName}" else fieldName
    field = form[fieldName]
    if form && field
      field.$invalid && (field.$touched || form.$submitted)
    else
      false

  $scope.createAccount = ->
    form = $scope.accountForm()
    if form.$valid
      AnalyticsService.trackFormSuccess('Accounts')
      $scope.accountError.messages.user = null
      $scope.submitDisabled = true
      # AccountService.userAuth will have been modified by form inputs
      shortFormSession = null
      if $scope.userInShortFormSession()
        shortFormSession =
          uid: ShortFormApplicationService.session_uid
      $scope.userDataForContact = AccountService.userDataForContact()
      AccountService.createAccount(shortFormSession).then( (success) ->
        if success
          form.$setUntouched()
          form.$setPristine()
          if $scope.userInShortFormSession()
            $scope._createAccountSubmitApplication()
          else
            $state.go('dahlia.sign-in', {newAccount: true})
          $scope.userDataForContact = {}
      ).catch( ->
        $scope.handleErrorState()
        $scope.submitDisabled = false
      )
    else
      AnalyticsService.trackFormError('Accounts')
      $scope.handleErrorState()

  $scope.signIn = ->
    form = $scope.accountForm()
    if form.$valid
      AnalyticsService.trackFormSuccess('Accounts')
      $scope.submitDisabled = true
      # AccountService.userAuth will have been modified by form inputs
      AccountService.signIn().then( (success) ->
        $scope.submitDisabled = false
        if success
          form.$setUntouched()
          form.$setPristine()
          # user signs in and saves an application
          if $scope.userInShortFormSession()
            ShortFormApplicationService.signInSubmitApplication(
              loggedInUser: AccountService.loggedInUser
              submitCallback: (changed) ->
                $state.go('dahlia.my-applications', {skipConfirm: true, infoChanged: changed})
            )
          # if user hasn't started the application at all and signs in from welcome page
          else if $state.params.fromShortFormIntro
            $state.go('dahlia.short-form-welcome.intro', {id: ShortFormApplicationService.listing.Id})
          else if $state.current.name == 'dahlia.continue-draft-sign-in'
            $state.go('dahlia.short-form-application.name', id: $state.params.listing_id)
          else
            $scope._signInRedirect()
      ).catch( ->
        $scope.handleErrorState()
        $scope.submitDisabled = false
      )
    else
      AnalyticsService.trackFormError('Accounts')
      $scope.handleErrorState()

  $scope.requestPasswordReset = ->
    form = $scope.form.passwordReset
    if form.$valid
      AnalyticsService.trackFormSuccess('Accounts')
      $scope.submitDisabled = true
      AccountService.requestPasswordReset().then( (success) ->
        $scope.submitDisabled = false
      )
    else
      AnalyticsService.trackFormError('Accounts')
      $scope.handleErrorState()

  $scope.$on 'auth:login-error', (ev, reason) ->
    if (reason.error == 'not_confirmed')
      AccountService.openConfirmEmailModal(reason.email)
    else
      $scope.accountError.messages.user = $translate.instant('SIGN_IN.BAD_CREDENTIALS')
      $scope.handleErrorState()

  $scope.updatePassword = (type) ->
    $scope.form.current = $scope.form.accountPassword
    form = $scope.form.current
    if form.$valid
      $scope.submitDisabled = true
      AccountService.updatePassword(type).then ->
        $scope.submitDisabled = false
        form.$setUntouched()
        form.$setPristine()

  $scope.updateEmail = ->
    $scope.form.current = $scope.form.accountEmail
    if $scope.form.current.$valid
      $scope.submitDisabled = true
      AccountService.updateAccount('email').then( ->
        $scope.submitDisabled = false
      )

  $scope.updateNameDOB = ->
    $scope.form.current = $scope.form.accountNameDOB
    if $scope.form.current.$valid
      $scope.submitDisabled = true
      AccountService.updateAccount('nameDOB').then( ->
        $scope.submitDisabled = false
      )

  $scope.isLocked = (field) ->
    AccountService.lockedFields[field]

  $scope.emailConfirmInstructions = ->
    $translate.instant('CREATE_ACCOUNT.EMAIL_CONFIRM_INSTRUCTIONS')

  $scope.confirmEmailSentMessage = ->
    interpolate = { email: $scope.createdAccount.email }
    $translate.instant('CONFIRM_ACCOUNT.EMAIL_HAS_BEEN_SENT_TO', interpolate)

  $scope.confirmEmailExpiredMessage = ->
    interpolate = { email: $scope.createdAccount.email }
    $translate.instant('CONFIRM_ACCOUNT.EXPIRED_EMAIL_SENT_TO', interpolate)

  $scope.resendConfirmationEmail = ->
    $scope.resendDisabled = true
    $scope.resentConfirmationMessage = null
    AccountService.resendConfirmationEmail().then( ->
      $scope.resendDisabled = false
      $scope.resentConfirmationMessage = $translate.instant('SIGN_IN.RESENT_CONFIRMATION_MESSAGE')
    ).catch( ->
      $scope.resendDisabled = false
    )

  $scope.hasApplications = ->
    return false if $scope.myApplications.length == 0
    # as long as we have some where !deleted
    _.some($scope.myApplications, {deleted: false})

  $scope._signInRedirect = ->
    return false unless AccountService.loggedIn()
    if AccountService.loginRedirect
      AccountService.goToLoginRedirect()
    else
      $state.go('dahlia.my-account')

  $scope._createAccountSubmitApplication = ->
    # make sure short form data inherits created account user data
    ShortFormApplicationService.importUserData($scope.userDataForContact)
    ShortFormApplicationService.submitApplication({attachToAccount: true}).then ->
      # send to sign in state if user created account from saving application
      $state.go('dahlia.sign-in', {skipConfirm: true, newAccount: true})

  $scope.userInShortFormSession = ->
    $state.current.name.indexOf('dahlia.short-form-application') > -1

  $scope.clearCreatedAccount = ->
    angular.copy({}, $scope.createdAccount)

  $scope.informationChangeNotice = ->
    $translate.instant('ACCOUNT_SETTINGS.INFORMATION_CHANGE_NOTICE')

  $scope.displayChangeNotice = (attributesChanged) ->
    AccountService.clearAccountMessages()
    $scope[attributesChanged] = true

  $scope.dahliaContactEmail = ->
    { email: '<a href="mailto:dahliahousingportal@sfgov.org">dahliahousingportal@sfgov.org</a>' }

  $scope.DOBValid = (field, value) ->
    values =
      month: parseInt($scope.userAuth.contact.dob_month)
      day: parseInt($scope.userAuth.contact.dob_day)
      year: parseInt($scope.userAuth.contact.dob_year)
    values[field] = parseInt(value)
    ShortFormApplicationService.DOBValid(field, values)

  $scope.recheckDOBDay = (formName = '') ->
    if formName
      form = $scope.form[formName]
    else
      form = $scope.accountForm()
    day = form['date_of_birth_day']
    # have to "reset" the dob_day form input by setting it to its current value
    # which will auto-trigger its ui-validation
    day.$setViewValue(day.$viewValue + ' ')

AccountController.$inject = [
  '$scope', '$state', '$document', '$translate',
  'AccountService', 'AnalyticsService', 'ShortFormApplicationService',
  'SharedService',
  'inputMaxLength'
]

angular
  .module('dahlia.controllers')
  .controller('AccountController', AccountController)
