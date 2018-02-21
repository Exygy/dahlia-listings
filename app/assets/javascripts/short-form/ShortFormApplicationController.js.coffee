############################################################################################
###################################### CONTROLLER ##########################################
############################################################################################

ShortFormApplicationController = (
  $scope,
  $state,
  $window,
  $document,
  $translate,
  Idle,
  ShortFormApplicationService,
  ShortFormNavigationService,
  ShortFormHelperService,
  FileUploadService,
  AnalyticsService,
  AddressValidationService,
  AccountService,
  SharedService,
  inputMaxLength
) ->

  $scope.form = ShortFormApplicationService.form
  $scope.$state = $state
  $scope.application = ShortFormApplicationService.application
  $scope.accountApplication = ShortFormApplicationService.accountApplication
  $scope.chosenApplicationToKeep = null
  $scope.applicant = ShortFormApplicationService.applicant
  $scope.preferences = ShortFormApplicationService.preferences
  $scope.alternateContact = ShortFormApplicationService.alternateContact
  $scope.currentCustomProofPreference = ShortFormApplicationService.currentCustomProofPreference
  $scope.householdMember = ShortFormApplicationService.householdMember
  $scope.householdMembers = ShortFormApplicationService.householdMembers
  $scope.householdIncome = ShortFormApplicationService.application.householdIncome
  $scope.listing = ShortFormApplicationService.listing
  $scope.currentRentBurdenAddress = ShortFormApplicationService.currentRentBurdenAddress
  $scope.validated_mailing_address = AddressValidationService.validated_mailing_address
  $scope.validated_home_address = AddressValidationService.validated_home_address
  $scope.notEligibleErrorMessage = $translate.instant('ERROR.NOT_ELIGIBLE')
  $scope.eligibilityErrors = []
  $scope.communityEligibilityErrorMsg = []
  $scope.latinRegex = ShortFormApplicationService.latinRegex
  # read more toggler
  $scope.readMoreDevelopmentalDisabilities = false
  # store label values that get overwritten by child directives
  $scope.labels = {}
  $scope.customInvalidMessage = null
  $scope.INPUT_MAX_LENGTH = inputMaxLength
  # community screening

  ## form options
  $scope.alternate_contact_options = ShortFormHelperService.alternate_contact_options
  $scope.priority_options = ShortFormHelperService.priority_options
  $scope.gender_options = ShortFormHelperService.gender_options
  $scope.sex_at_birth_options = ShortFormHelperService.sex_at_birth_options
  $scope.relationship_options = ShortFormHelperService.relationship_options
  $scope.ethnicity_options = ShortFormHelperService.ethnicity_options
  $scope.race_options = ShortFormHelperService.race_options
  $scope.sexual_orientation_options = ShortFormHelperService.sexual_orientation_options
  $scope.listing_referral_options = ShortFormHelperService.listing_referral_options

  # hideAlert tracks if the user has manually closed the alert "X"
  $scope.hideAlert = false
  $scope.hideMessage = false
  $scope.addressError = ShortFormApplicationService.addressError
  # Account / Login
  $scope.loggedInUser = AccountService.loggedInUser
  $scope.userAuth = AccountService.userAuth
  $scope.accountError = AccountService.accountError
  $scope.accountSuccess = AccountService.accountSuccess
  $scope.rememberedShortFormState = AccountService.rememberedShortFormState
  $scope.submitDisabled = false

  $scope.emailRegex = SharedService.emailRegex

  $scope.trackAutofill = ->
    AnalyticsService.trackFormSuccess('Application', 'Start with these details')

  $scope.resetAndStartNewApp = ->
    # always pull answeredCommunityScreening from the current session since that Q is answered first
    data =
      # will be null if the listing didn't have a screening Q
      answeredCommunityScreening: $scope.application.answeredCommunityScreening
    ShortFormApplicationService.resetApplicationData(data)
    $scope.applicant = ShortFormApplicationService.applicant
    $scope.preferences = ShortFormApplicationService.preferences
    $scope.alternateContact = ShortFormApplicationService.alternateContact
    $scope.householdMember = ShortFormApplicationService.householdMember
    $scope.householdMembers = ShortFormApplicationService.householdMembers
    delete $scope.application.autofill
    AnalyticsService.trackFormSuccess('Application', 'Reset and start from scratch')
    $state.go('dahlia.short-form-application.name')

  $scope.atAutofillPreview = ->
    $state.current.name == "dahlia.short-form-application.autofill-preview"

  $scope.atShortFormState = ->
    ShortFormApplicationService.isShortFormPage($state.current)

  if $scope.atShortFormState() && !$window.jasmine && !window.protractor
    # don't add this onbeforeunload inside of jasmine tests
    $window.addEventListener 'beforeunload', ShortFormApplicationService.onExit

  $scope.submitForm = ->
    form = $scope.form.applicationForm
    ShortFormNavigationService.isLoading(true)
    if form.$valid
      # reset page form state (i.e. reset error messages)
      form.$setPristine()
      $scope.handleFormSuccess()
    else
      $scope.trackFormErrors()
      $scope.handleErrorState()

  $scope.trackFormErrors = ->
    # track global form error
    AnalyticsService.trackFormError('Application')
    form = $scope.form.applicationForm
    fieldErrors = _.chain(form.$error).values().flatten().map('$name').uniq().value()
    fieldErrors.forEach (field) ->
      # track individual field errors
      AnalyticsService.trackFormFieldError('Application', field)

  $scope.handleFormSuccess = ->
    options = ShortFormNavigationService.submitOptionsForCurrentPage()
    if options.callback
      options.callback.forEach (callback) ->
        $scope[callback](options.params) if $scope[callback]
    if options.path
      $scope.goToAndTrackFormSuccess(options.path)

  $scope.goToAndTrackFormSuccess = (path, params) ->
    AnalyticsService.trackFormSuccess('Application')
    if params
      $state.go(path, params)
    else
      $state.go(path)

  $scope.go = (path, params) ->
    # go to a page without the Form Success analytics tracking
    if params
      $state.go(path, params)
    else
      $state.go(path)

  # called on stateChangeSuccess
  $scope.clearErrors = ->
    $scope.addressError = false
    $scope.clearRentBurdenError()
    $scope.clearEligibilityErrors()
    form = $scope.form.applicationForm
    form.$setPristine() if form

  $scope.handleErrorState = ->
    # show error alert
    $scope.hideAlert = false
    ShortFormNavigationService.isLoading(false)
    el = angular.element(document.getElementById('short-form-alerts'))
    # uses duScroll aka 'angular-scroll' module
    topOffset = 0
    duration = 400 # animation speed in ms
    $document.scrollToElement(el, topOffset, duration)

  $scope.currentForm = ->
    # pick up which ever one is defined (the other will be undefined)
    $scope.form.signIn ||
    $scope.form.applicationForm

  $scope.inputInvalid = (fieldName) ->
    form = $scope.currentForm()
    ShortFormApplicationService.inputInvalid(fieldName, form)

  # uncheck the "no" option e.g. noPhone or noEmail if you're filling out a valid value
  $scope.uncheckNoOption = (fieldName) ->
    return if !$scope.applicant[fieldName] || $scope.inputValid(fieldName)
    # e.g. "phone" --> "noPhone"
    fieldToDisable = "no#{fieldName.charAt(0).toUpperCase() + fieldName.slice(1)}"
    $scope.applicant[fieldToDisable] = false

  $scope.beginApplication = (lang = 'en') ->
    if $scope.listing.Reserved_community_type
      $scope.goToAndTrackFormSuccess('dahlia.short-form-welcome.community-screening', {lang: lang})
    else
      $scope.goToAndTrackFormSuccess('dahlia.short-form-welcome.overview', {lang: lang})

  $scope.onCommunityScreeningPage = ->
    $state.current.name == 'dahlia.short-form-welcome.community-screening'

  $scope.checkCommunityScreening = ->
    # ng-change action for answering 'Yes' to screening
    $scope.eligibilityErrors = []

  $scope.validateCommunityEligibility = ->
    $scope.eligibilityErrors = []
    if $scope.application.answeredCommunityScreening == 'No'
      $scope.eligibilityErrors = $scope.communityEligibilityErrorMsg
      $scope.handleErrorState()
    else if $scope.application.answeredCommunityScreening ==  'Yes'
      $scope.goToAndTrackFormSuccess('dahlia.short-form-welcome.overview')

  $scope.addressInputInvalid = (identifier = '') ->
    return true if $scope.addressValidationError(identifier)
    $scope.inputInvalid('address1', identifier) ||
    $scope.inputInvalid('city', identifier) ||
    $scope.inputInvalid('state', identifier) ||
    $scope.inputInvalid('zip', identifier)

  $scope.addressValidationError = (identifier = '') ->
    return false unless $scope.addressError
    validated = $scope["validated_#{identifier}"]
    return AddressValidationService.validationError(validated)

  $scope.inputValid = (fieldName, formName = 'applicationForm') ->
    form = $scope.form.applicationForm
    field = form[fieldName]
    field.$valid if form && field

  $scope.blankIfInvalid = (fieldName) ->
    form = $scope.form.applicationForm
    if typeof form[fieldName] != 'undefined'
      $scope.applicant[fieldName] = '' if form[fieldName].$invalid

  $scope.noPrioritiesSelected = ->
    selected = $scope.application.adaPrioritiesSelected
    !_.some([selected['Mobility impaired'], selected['Vision impaired'], selected['Hearing impaired'], selected.None])

  $scope.prioritiesSelectedExists = ->
    !_.isEmpty($scope.application.adaPrioritiesSelected)

  $scope.clearPriorityOptions = ->
    selected = $scope.application.adaPrioritiesSelected
    _.map selected, (val, k) ->
      selected[k] = false unless k == 'None'

  $scope.clearPriorityNoOption = ->
    $scope.application.adaPrioritiesSelected.None = false

  $scope.priorityNoSelected = ->
    $scope.application.adaPrioritiesSelected.None

  $scope.clearPhoneData = (type) ->
    ShortFormApplicationService.clearPhoneData(type)

  $scope.validMailingAddress = ->
    ShortFormApplicationService.validMailingAddress()

  $scope.notRequired = ->
    return false

  $scope.addressChange = (model) ->
    member = $scope[model]
    # invalidate preferenceAddressMatch to ensure that they re-confirm address
    member.preferenceAddressMatch = null
    if member == $scope.applicant
      $scope.copyHomeToMailingAddress()
      ShortFormApplicationService.invalidateContactForm()
    if ShortFormApplicationService.eligibleForRentBurden()
      # make sure they step back through the household section to update groupedHouseholdAddresses + rents
      ShortFormApplicationService.invalidateHouseholdForm()

  $scope.copyHomeToMailingAddress = ->
    ShortFormApplicationService.copyHomeToMailingAddress()

  $scope.resetHomeAddress = ->
    #reset home address
    $scope.applicant.home_address = {}

  $scope.resetHouseholdMemberAddress = ->
    $scope.householdMember.home_address = {}

  $scope.resetAndCheckMailingAddress = ->
    #reset mailing address
    $scope.applicant.mailing_address = {}
    $scope.copyHomeToMailingAddress()

  $scope.checkIfAddressVerificationNeeded = ->
    if $scope.applicant.preferenceAddressMatch && $scope.application.validatedForms.You['verify-address'] != false
      ###
      skip ahead if their current address has already been confirmed.
      $scope.applicant.preferenceAddressMatch doesn't have to be 'Matched',
       just that it has a value
      ###
      $scope.goToAndTrackFormSuccess('dahlia.short-form-application.alternate-contact-type')
    else
      # validate + geocode address, but kick out if we have errors
      ShortFormApplicationService.validateApplicantAddress( ->
        $scope.goToAndTrackFormSuccess('dahlia.short-form-application.verify-address')
      ).error( ->
        $scope.addressError = true
        $scope.handleErrorState()
      )


  $scope.checkIfAlternateContactInfoNeeded = ->
    if $scope.alternateContact.alternateContactType == 'None'
      ShortFormApplicationService.clearAlternateContactDetails()
      # skip ahead if they aren't filling out an alt. contact
      $scope.goToLandingPage('Household')
    else
      if $scope.alternateContact.alternateContactType != 'Social Worker or Housing Counselor'
        $scope.alternateContact.agency = null
      $scope.goToAndTrackFormSuccess('dahlia.short-form-application.alternate-contact-name')

  $scope.hasNav = ->
    ShortFormNavigationService.hasNav()

  $scope.hasBackButton = ->
    ShortFormNavigationService.hasBackButton()

  $scope.backPageState = ->
    ShortFormNavigationService.backPageState()

  $scope.getLandingPage = (section) ->
    ShortFormNavigationService.getLandingPage(section)

  $scope.goToLandingPage = (section) ->
    page = ShortFormNavigationService.getLandingPage({name: section})
    $scope.goToAndTrackFormSuccess("dahlia.short-form-application.#{page}")

  $scope.getStartOfHouseholdDetails = ->
    ShortFormNavigationService.getStartOfHouseholdDetails()

  ###### Proof of Preferences Logic ########
  # this is called after e0-preferences-intro
  $scope.checkIfPreferencesApply = ->
    if ShortFormApplicationService.eligibleForAssistedHousing()
      $scope.goToAndTrackFormSuccess('dahlia.short-form-application.assisted-housing-preference')
    else if ShortFormApplicationService.eligibleForRentBurden()
      $scope.goToAndTrackFormSuccess('dahlia.short-form-application.rent-burdened-preference')
    else
      $scope.checkForNeighborhoodOrLiveWork()

  $scope.checkForNeighborhoodOrLiveWork = ->
    if ShortFormApplicationService.eligibleForNRHP()
      $scope.goToAndTrackFormSuccess('dahlia.short-form-application.neighborhood-preference')
    else if ShortFormApplicationService.eligibleForADHP()
      $scope.goToAndTrackFormSuccess('dahlia.short-form-application.adhp-preference')
    else if ShortFormApplicationService.eligibleForLiveWork()
      $scope.goToAndTrackFormSuccess('dahlia.short-form-application.live-work-preference')
    else
      $scope.checkAfterLiveWork()

  $scope.checkAfterLiveInTheNeighborhood = (preference) ->
    # preference is either neighborhoodResidence or antiDisplacement
    if ShortFormApplicationService.applicationHasPreference(preference)
      # you already selected Neighborhood, so skip live/work
      $scope.checkAfterLiveWork()
    else
      # you opted out of Neighborhood, so go to live/work
      $scope.goToAndTrackFormSuccess('dahlia.short-form-application.live-work-preference')

  $scope.checkAfterLiveWork = ->
    # after Live/Work, go to preferences-programs
    $scope.goToAndTrackFormSuccess('dahlia.short-form-application.preferences-programs')

  ##### Custom Preferences Logic ####
  # this called after preferences programs
  $scope.checkForCustomPreferences = ->
    if $scope.listing.customPreferences.length > 0
      $scope.goToAndTrackFormSuccess('dahlia.short-form-application.custom-preferences')
    else
      $scope.checkForCustomProofPreferences()

  $scope.checkForCustomProofPreferences = ->
    nextIndex = null
    currentIndex = parseInt($state.params.prefIdx)
    if currentIndex >= 0 && currentIndex < $scope.listing.customProofPreferences.length - 1
      nextIndex = currentIndex + 1
    else if isNaN(currentIndex) && $scope.listing.customProofPreferences.length
      nextIndex = 0
    if nextIndex != null
      $scope.goToAndTrackFormSuccess('dahlia.short-form-application.custom-proof-preferences', {prefIdx: nextIndex})
    else
      $scope.checkIfNoPreferencesSelected()

  $scope.claimedCustomPreference = (preference) ->
    ShortFormApplicationService.claimedCustomPreference(preference)

  $scope.eligibleForAssistedHousingOrRentBurden = ->
    ShortFormApplicationService.eligibleForAssistedHousing() || ShortFormApplicationService.eligibleForRentBurden()

  # this is called after custom-preferences or preferences-programs
  $scope.checkIfNoPreferencesSelected = ->
    if ShortFormApplicationService.applicantHasNoPreferences()
      # only show general lottery notice if they have no preferences
      $scope.goToAndTrackFormSuccess('dahlia.short-form-application.general-lottery-notice')
    else
      # otherwise go to the Review section
      $scope.goToLandingPage('Review')

  $scope.applicantHasNoPreferences = ->
    ShortFormApplicationService.applicantHasNoPreferences()

  $scope.checkPreferenceEligibility = (type = 'liveWorkInSf') ->
    # this mainly gets used as one of the submit callbacks for relevant pages in ShortFormNavigationService
    ShortFormApplicationService.refreshPreferences(type)

  $scope.preferenceWarning = ->
    return false unless $scope.form.currentPreferenceType
    if $scope.inputInvalid($scope.form.currentPreferenceType)
      return 'preferenceNotSelected'
    else if $scope.preferences[$scope.form.currentPreferenceType] &&
      $scope.form.applicationForm.$invalid &&
      $scope.form.applicationForm.$submitted
        return 'preferenceIncomplete'
    else
      false

  $scope.checkForRentBurdenFiles = ->
    if $scope.preferences.optOut.rentBurden || ShortFormApplicationService.hasCompleteRentBurdenFiles()
      $scope.checkForNeighborhoodOrLiveWork()
    else
      $scope.setRentBurdenError()
      $scope.handleErrorState()

  $scope.hasCompleteRentBurdenFilesForAddress = (address) ->
    ShortFormApplicationService.hasCompleteRentBurdenFilesForAddress(address)

  $scope.cancelRentBurdenFilesForAddress = (address) ->
    ShortFormNavigationService.isLoading(true)
    FileUploadService.deleteRentBurdenPreferenceFiles($scope.listing.Id, address).then ->
      $scope.go('dahlia.short-form-application.rent-burdened-preference')

  $scope.setRentBurdenError = ->
    ShortFormApplicationService.invalidatePreferencesForm()
    $scope.customInvalidMessage = $translate.instant('E3B_RENT_BURDEN_PREFERENCE.FORM_ERROR')

  $scope.clearRentBurdenError = (message) ->
    $scope.customInvalidMessage = null

  $scope.liveInSfMembers = ->
    ShortFormApplicationService.liveInSfMembers()

  $scope.showPreference = (preference) ->
    ShortFormApplicationService.showPreference(preference)

  $scope.workInSfMembers = ->
    ShortFormApplicationService.workInSfMembers()

  $scope.liveInTheNeighborhoodAddresses = (opts = {}) ->
    addresses = []
    _.each ShortFormApplicationService.liveInTheNeighborhoodMembers(), (member) ->
      street = member.home_address.address1
      addresses.push(street) unless _.isNil(street)
    addresses = _.uniq(addresses)
    addresses = _.map(addresses, (x) -> "<strong>#{x}</strong>") if opts.strong
    addresses

  $scope.liveInTheNeighborhoodAddress = (opts = {}) ->
    # turn the list of addresses into a string
    $scope.liveInTheNeighborhoodAddresses(opts).join(' and ')

  $scope.cancelPreference = (preference) ->
    $scope.clearRentBurdenError() if preference == 'rentBurden'
    ShortFormApplicationService.cancelPreference(preference)

  $scope.cancelOptOut = (preference) ->
    ShortFormApplicationService.cancelOptOut(preference)

  $scope.preferenceRequired = (preference) ->
    return false unless $scope.showPreference(preference)
    ShortFormApplicationService.preferenceRequired(preference)

  ###### Household Section ########
  $scope.addHouseholdMember = ->
    noAddress = $scope.householdMember.hasSameAddressAsApplicant == 'Yes'
    if $scope.applicantDoesNotMeetSeniorRequirements('householdMember')
      age = { minAge: $scope.listing.Reserved_community_minimum_age }
      $scope.eligibilityErrors = [$translate.instant('ERROR.SENIOR_EVERYONE', age)]
      $scope.handleErrorState()
      return
    else
      $scope.clearEligibilityErrors()
    if noAddress || $scope.householdMember.preferenceAddressMatch
      # addHouseholdMember and skip ahead if they aren't filling out an address
      # or their current address has already been confirmed
      ShortFormApplicationService.addHouseholdMember($scope.householdMember)
      $scope.goToAndTrackFormSuccess('dahlia.short-form-application.household-members')
    else
      # validate + geocode address, but kick out if we have errors
      ShortFormApplicationService.validateHouseholdMemberAddress( ->
        opts = {member_id: $scope.householdMember.id}
        $scope.goToAndTrackFormSuccess('dahlia.short-form-application.household-member-verify-address', opts)
      ).error( ->
        $scope.addressError = true
        $scope.handleErrorState()
      )

  $scope.cancelHouseholdMember = ->
    ShortFormApplicationService.cancelHouseholdMember()
    $scope.form.applicationForm.$setPristine()
    # go back to household members page without tracking Form Success
    $scope.go('dahlia.short-form-application.household-members')

  $scope.validateHouseholdEligibility = (match) ->
    $scope.clearEligibilityErrors()
    form = $scope.form.applicationForm
    # skip the check if we're doing an incomeMatch and the applicant has vouchers
    if match == 'incomeMatch' && $scope.application.householdVouchersSubsidies == 'Yes'
      $scope.goToLandingPage('Preferences')
      return
    ShortFormApplicationService.checkHouseholdEligiblity($scope.listing)
      .then( (response) ->
        eligibility = response.data
        if match == 'householdMatch'
          error = eligibility.householdEligibilityResult.toLowerCase()
          $scope._respondToHouseholdEligibilityResults(eligibility, error)
        else if match == 'incomeMatch'
          error = eligibility.incomeEligibilityResult.toLowerCase()
          $scope._respondToIncomeEligibilityResults(eligibility, error)
      )

  $scope.clearEligibilityErrors = ->
    $scope.eligibilityErrors = []

  $scope._respondToHouseholdEligibilityResults = (eligibility, error) ->
    seniorReqError = $scope.householdDoesNotMeetSeniorRequirements()
    if eligibility.householdMatch && !seniorReqError
      # determine next page of household section
      if ShortFormApplicationService.hasHouseholdPublicHousingQuestion()
        $scope.goToAndTrackFormSuccess('dahlia.short-form-application.household-public-housing')
      else
        $scope.checkIfReservedUnits()
    else
      $scope._determineHouseholdEligibilityErrors(error, seniorReqError)
      $scope.handleErrorState()

  $scope._respondToIncomeEligibilityResults = (eligibility, error) ->
    if eligibility.incomeMatch
      $scope.goToLandingPage('Preferences')
    else
      $scope._determineIncomeEligibilityErrors(error)
      $scope.handleErrorState()

  $scope._determineHouseholdEligibilityErrors = (error, seniorReqError) ->
    ShortFormApplicationService.invalidateHouseholdForm()
    # send household errors to analytics
    analyticsOpts =
      householdSize: ShortFormApplicationService.householdSize()
    AnalyticsService.trackFormError('Application', "household #{error}", analyticsOpts)
    # display household eligibility errors, there may be more than one so we `.push()`
    if error == 'too big'
      $scope.eligibilityErrors.push($translate.instant("ERROR.HOUSEHOLD_TOO_BIG"))
    else if error == 'too small'
      $scope.eligibilityErrors.push($translate.instant("ERROR.HOUSEHOLD_TOO_SMALL"))
    if seniorReqError
      # special case for "you or anyone" must be a senior, and you did not meet the reqs
      age = { minAge: $scope.listing.Reserved_community_minimum_age }
      $scope.eligibilityErrors.push($translate.instant('ERROR.SENIOR_ANYONE', age))

  $scope._determineIncomeEligibilityErrors = (error = 'too low') ->
    # error message from salesforce seems to be blank when income == 0, so default to 'too low'
    ShortFormApplicationService.invalidateIncomeForm()
    # send income errors to analytics
    analyticsOpts =
      householdSize: ShortFormApplicationService.householdSize()
      value: ShortFormApplicationService.calculateHouseholdIncome()
    AnalyticsService.trackFormError('Application', "income #{error}", analyticsOpts)
    # display income eligibility errors
    if error == 'too low'
      message = $translate.instant("ERROR.HOUSEHOLD_INCOME_TOO_LOW")
    else if error == 'too high'
      message = $translate.instant("ERROR.HOUSEHOLD_INCOME_TOO_HIGH")
    $scope.eligibilityErrors = [message]

  $scope.checkIfPublicHousing = ->
    if $scope.application.hasPublicHousing == 'No'
      $scope.goToAndTrackFormSuccess('dahlia.short-form-application.household-monthly-rent')
    else
      $scope.checkIfReservedUnits()

  # Check for need to ask about reserved units on the listing
  $scope.checkIfReservedUnits = (type) ->
    page = ShortFormNavigationService.getNextReservedPageIfAvailable(type, 'next')
    $scope.goToAndTrackFormSuccess("dahlia.short-form-application.#{page}")

  $scope.publicHousingYes = ->
    ShortFormApplicationService.resetMonthlyRentForm()
    # make sure they're forced through now that they have the assistedHousing option
    ShortFormApplicationService.invalidatePreferencesForm()
    ShortFormApplicationService.resetPreference('rentBurden')

  $scope.publicHousingNo = ->
    ShortFormApplicationService.invalidateMonthlyRentForm()
    ShortFormApplicationService.resetAssistedHousingForm()
    ShortFormApplicationService.resetPreference('assistedHousing')

  $scope.listingLink = ->
    linkText = $translate.instant('LABEL.ON_THE_LISTING')
    link = $state.href('dahlia.listing', { id: $scope.listing.listingID })
    {listingLink: "<a href='#{link}'>#{linkText}</a>"}

  $scope.onIncomeValueChange = ->
    ShortFormApplicationService.invalidateIncomeForm()
    return if !ShortFormApplicationService.listingHasPreference('rentBurden') ||
              ShortFormApplicationService.eligibleForRentBurden()
    ShortFormApplicationService.resetPreference('rentBurden')

  $scope.onMonthlyRentChange = ->
    return if !ShortFormApplicationService.listingHasPreference('rentBurden') ||
              ShortFormApplicationService.eligibleForRentBurden()
    ShortFormApplicationService.resetPreference('rentBurden')

  $scope.invalidateAltContactTypeForm = ->
    ShortFormApplicationService.invalidateAltContactTypeForm()

  $scope.checkSurveyComplete = ->
    ShortFormApplicationService.checkSurveyComplete()

  $scope.confirmReviewedApplication = ->
    if AccountService.loggedIn()
      $scope.goToAndTrackFormSuccess('dahlia.short-form-application.review-terms')
    else
      $scope.goToAndTrackFormSuccess('dahlia.short-form-application.review-sign-in')

  ## helpers
  $scope.alternateContactRelationship = ->
    ShortFormHelperService.alternateContactRelationship($scope.alternateContact)

  $scope.applicationVouchersSubsidies = ->
    ShortFormHelperService.applicationVouchersSubsidies($scope.application)

  $scope.applicationIncomeAmount = ->
    ShortFormHelperService.applicationIncomeAmount($scope.application)

  $scope.translateLoggedInMessage = (page) ->
    ShortFormHelperService.translateLoggedInMessage(page)

  $scope.applicantFullName = (applicant) ->
    if (!applicant || !applicant.firstName || !applicant.lastName)
      return "No name entered"
    else
      "#{applicant.firstName} #{applicant.lastName}"

  $scope.chooseDraft = ->
    if ($scope.chosenApplicationToKeep == 'recent')
      user = AccountService.loggedInUser
      ShortFormApplicationService.keepCurrentDraftApplication(user).then( ->
        $scope.goToAndTrackFormSuccess('dahlia.my-applications', {skipConfirm: true})
      )
    else
      $scope.goToAndTrackFormSuccess('dahlia.my-applications', {skipConfirm: true})

  $scope.chooseAccountSettings = ->
    if ($scope.chosenAccountSettingsToKeep == 'account')
      ShortFormApplicationService.importUserData(AccountService.loggedInUser)
    ShortFormApplicationService.submitApplication().then( ->
      AccountService.importApplicantData($scope.applicant)
      $scope.goToAndTrackFormSuccess('dahlia.short-form-application.review-terms', {loginMessage: 'update'})
    )

  ## account service
  $scope.loggedIn = ->
    AccountService.loggedIn()

  ## translation helpers
  $scope.preferenceProofOptions = (pref_type) ->
    ShortFormHelperService.proofOptions(pref_type)

  $scope.householdMemberForPreference = (pref_type) ->
    ShortFormHelperService.householdMemberForPreference($scope.application, pref_type)

  $scope.fileAttachmentForPreference = (pref_type) ->
    ShortFormHelperService.fileAttachmentForPreference($scope.application, pref_type)

  $scope.fileAttachmentsForRentBurden = ->
    ShortFormHelperService.fileAttachmentsForRentBurden($scope.application)

  $scope.certificateNumberForPreference = (pref_type) ->
    ShortFormHelperService.certificateNumberForPreference($scope.application, pref_type)

  $scope.addressTranslateVariable = (address) ->
    ShortFormHelperService.addressTranslateVariable(address)

  $scope.membersTranslateVariable = (members) ->
    ShortFormHelperService.membersTranslateVariable(members)

  $scope.isLoading = ->
    ShortFormNavigationService.isLoading()

  $scope.submitApplication = ->
    ShortFormNavigationService.isLoading(true)
    ShortFormApplicationService.submitApplication({finish: true})
      .then(  ->
        ShortFormNavigationService.isLoading(false)
        $scope.goToAndTrackFormSuccess('dahlia.short-form-application.confirmation')
      ).catch( ->
        ShortFormNavigationService.isLoading(false)
      )

  ## Save and finish later
  $scope.saveAndFinishLater = (ev) ->
    # prevent normal short form page submit
    ev.preventDefault()
    ShortFormNavigationService.isLoading(true)
    if AccountService.loggedIn()
      ShortFormApplicationService.submitApplication().then((response) ->
        # ShortFormNavigationService.isLoading(false) will happen after My Apps are loaded
        # go to my applications without tracking Form Success
        $scope.go('dahlia.my-applications', {skipConfirm: true})
      ).catch( ->
        ShortFormNavigationService.isLoading(false)
      )
    else
      ShortFormNavigationService.isLoading(false)
      # go to Create Account without tracking Form Success
      $scope.go('dahlia.short-form-application.create-account')

  $scope.signIn = ->
    form = $scope.form.signIn
    # have to manually set this because it's an ng-form
    form.$submitted = true
    if form.$valid
      $scope.submitDisabled = true
      # AccountService.userAuth will have been modified by form inputs
      ShortFormNavigationService.isLoading(true)
      AccountService.signIn().then( (success) ->
        $scope.submitDisabled = false
        if success
          form.$setUntouched()
          form.$setPristine()
          ShortFormApplicationService.signInSubmitApplication(
            type: 'review-sign-in'
            loggedInUser: AccountService.loggedInUser
            submitCallback: ->
              $scope.goToAndTrackFormSuccess('dahlia.short-form-application.review-terms', {loginMessage: 'sign-in'})
          )
      ).catch( ->
        $scope.handleErrorState()
        $scope.submitDisabled = false
      )
    else
      AnalyticsService.trackFormError('Application')
      $scope.handleErrorState()


  $scope.print = -> $window.print()

  $scope.checkPrimaryApplicantAge = ->
    if $scope.applicantDoesNotMeetSeniorRequirements()
      ShortFormNavigationService.isLoading(false)
      age = { minAge: $scope.listing.Reserved_community_minimum_age }
      $scope.eligibilityErrors = [$translate.instant('ERROR.SENIOR_EVERYONE', age)]
      $scope.handleErrorState()
    else
      $scope.clearEligibilityErrors()
      $scope.goToAndTrackFormSuccess('dahlia.short-form-application.contact')

  $scope.DOBValid = (field, value, model = 'applicant') ->
    values = $scope.DOBValues(model)
    values[field] = parseInt(value)
    ShortFormApplicationService.DOBValid(field, values)

  $scope.DOBValues = (model = 'applicant') ->
    {
      month: parseInt($scope[model].dob_month)
      day: parseInt($scope[model].dob_day)
      year: parseInt($scope[model].dob_year)
    }

  $scope.primaryApplicantValidAge = ->
    age = $scope.applicantAge('applicant')
    return true unless age
    return false if $scope.primaryApplicantUnder18()
    return false if $scope.applicantDoesNotMeetSeniorRequirements()
    true

  $scope.applicantDOB_hasError = ->
    $scope.inputInvalid('date_of_birth_day') ||
    $scope.inputInvalid('date_of_birth_month') ||
    $scope.inputInvalid('date_of_birth_year') ||
    $scope.eligibilityErrors.length

  $scope.applicantDoesNotMeetSeniorRequirements = (member = 'applicant') ->
    listing = $scope.listing
    requirement = listing.Reserved_Community_Requirement || ''
    reservedType = listing.Reserved_community_type || ''
    age = $scope.applicantAge(member)
    reservedType.match(/senior/i) && requirement.match(/entire household/i) &&
      age < listing.Reserved_community_minimum_age

  $scope.householdDoesNotMeetSeniorRequirements = ->
    listing = $scope.listing
    requirement = listing.Reserved_Community_Requirement || ''
    reservedType = listing.Reserved_community_type || ''
    # senior, but not entire household
    reservedType.match(/senior/i) && !requirement.match(/entire household/i) &&
      # check if the oldest person in the house does not meet the min requirements
      ShortFormApplicationService.maxHouseholdAge() < listing.Reserved_community_minimum_age

  $scope.primaryApplicantUnder18 = ->
    $scope.applicantAge('applicant') < 18

  $scope.householdMemberUnder0 = ->
    dob = $scope.applicantDOBMoment('householdMember')
    return false unless dob
    ageDays = moment().add(10, 'months').diff(dob, 'days')
    # HH member allowed to be 10 months "unborn"
    return ageDays < 0

  $scope.applicantAge = (member = 'applicant') ->
    dob = $scope.applicantDOBMoment(member)
    return unless dob
    moment().diff(dob, 'years')

  $scope.applicantDOBMoment = (member = 'applicant') ->
    values = $scope.DOBValues(member)
    form = $scope.form.applicationForm
    # have to grab viewValue because if the field is in error state the model will be undefined
    year = parseInt(form['date_of_birth_year'].$viewValue)
    return false unless values.month && values.day && year >= 1900
    moment("#{year}-#{values.month}-#{values.day}", 'YYYY-MM-DD')

  $scope.householdMemberValidAge = ->
    age = $scope.applicantAge('householdMember')
    return true unless age
    return false if $scope.householdMemberUnder0()
    return false if $scope.applicantDoesNotMeetSeniorRequirements('householdMember')
    true

  $scope.recheckDOB = (member) ->
    form = $scope.form.applicationForm
    day = form['date_of_birth_day']
    # have to "reset" the dob_day form input by setting it to its current value
    # which will auto-trigger its ui-validation
    day.$setViewValue(day.$viewValue + ' ')
    # also re-check year to see if age is valid (primary > 18, HH > "10 months in the future")
    year = form['date_of_birth_year']
    year.$setViewValue(year.$viewValue + ' ')
    if $scope.listing.Reserved_community_type == 'Senior'
      # make sure we re-check them at the Household section, in case they are no longer senior eligible
      ShortFormApplicationService.invalidateHouseholdForm()
    if (member == 'applicant' && $scope.primaryApplicantValidAge()) ||
      (member == 'householdMember' && $scope.householdMemberValidAge())
        $scope.clearEligibilityErrors()

  $scope.formattedBuildingAddress = (listing, display) ->
    ShortFormApplicationService.formattedBuildingAddress(listing, display)

  $scope.isLocked = (field) ->
    AccountService.lockedFields[field]

  $scope.today = ->
    moment().tz('America/Los_Angeles').format('YYYY-MM-DD')

  $scope.applicationCompletionPercentage = (application) ->
    ShortFormApplicationService.applicationCompletionPercentage(application)

  $scope.$on 'auth:login-error', (ev, reason) ->
    $scope.accountError.messages.user = $translate.instant('SIGN_IN.BAD_CREDENTIALS')
    $scope.handleErrorState()

  $scope.$on '$stateChangeError', (e, toState, toParams, fromState, fromParams, error) ->
    # NOTE: not sure when this will ever really get hit any more
    #  used to be for address validation errors
    $scope.handleErrorState()

  $scope.$on '$stateChangeSuccess', (e, toState, toParams, fromState, fromParams) ->
    $scope.onStateChangeSuccess(e, toState, toParams, fromState, fromParams)

  # separate this method out for better unit testing
  $scope.onStateChangeSuccess = (e, toState, toParams, fromState, fromParams) ->
    $scope.clearErrors()
    ShortFormNavigationService.isLoading(false)
    ShortFormApplicationService.setApplicationLanguage(toParams.lang)
    if ShortFormApplicationService.isEnteringShortForm(toState, fromState) &&
      ShortFormApplicationService.application.id
        ShortFormApplicationService.sendToLastPageofApp(toState)
    ShortFormApplicationService.storeLastPage(toState.name)

  $scope.$on '$stateChangeStart', (e, toState, toParams, fromState, fromParams, options) ->
    $scope.stateChangeStart(e, toState, toParams, fromState, fromParams)

  $scope.stateChangeStart = (e, toState, toParams, fromState, fromParams) ->
    ShortFormApplicationService.setApplicationLanguage(toParams.lang)

  # TODO: -- REMOVE HARDCODED FEATURES --
  $scope.listingIs = (name) ->
    ShortFormApplicationService.listingIs(name)

ShortFormApplicationController.$inject = [
  '$scope', '$state', '$window', '$document', '$translate', 'Idle',
  'ShortFormApplicationService', 'ShortFormNavigationService',
  'ShortFormHelperService', 'FileUploadService',
  'AnalyticsService',
  'AddressValidationService',
  'AccountService',
  'SharedService',
  'inputMaxLength'
]

angular
  .module('dahlia.controllers')
  .controller('ShortFormApplicationController', ShortFormApplicationController)
