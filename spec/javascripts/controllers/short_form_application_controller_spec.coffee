do ->
  'use strict'
  describe 'ShortFormApplicationController', ->
    scope = undefined
    state = undefined
    translate = {
      instant: jasmine.createSpy().and.returnValue('newmessage')
    }
    fakeIdle = undefined
    fakeTitle = undefined
    eligibility = undefined
    error = undefined
    callbackUrl = undefined
    fakeListing = getJSONFixture('listings-api-show.json').listing
    validHousehold = getJSONFixture('short_form-api-validate_household-match.json')
    invalidHousehold = getJSONFixture('short_form-api-validate_household-not-match.json')
    fakeAnalyticsService =
      trackFormSuccess: jasmine.createSpy()
      trackFormError: jasmine.createSpy()
      trackFormAbandon: jasmine.createSpy()
    fakeShortFormApplicationService =
      form:
        applicationForm:
          $valid: true
          $setPristine: -> undefined
      inputInvalid: ->
      listing: fakeListing
      applicant:
        home_address: { address1: null, city: null, state: null, zip: null }
        language: "English"
        phone: null
        mailing_address: { address1: null, city: null, state: null, zip: null }
        gender: {}
      householdMembers: []
      preferences: {
        optOut: {}
      }
      application:
        validatedForms:
          You: {}
          Household: {}
          Preferences: {}
          Income: {}
          Review: {}
      applicationDefaults:
        applicant:
          home_address: { address1: null, address2: "", city: null, state: null, zip: null }
          phone: null
          mailing_address: { address1: null, address2: "", city: null, state: null, zip: null }
          terms: {}
      alternateContact: {}
      householdMember: {
        firstName: "Oberon"
      }
      isWelcomePage: jasmine.createSpy()
      isShortFormPage: jasmine.createSpy().and.returnValue(true)
      copyHomeToMailingAddress: jasmine.createSpy()
      addHouseholdMember: jasmine.createSpy()
      cancelHouseholdMember: jasmine.createSpy()
      householdSize: -> 1
      calculateHouseholdIncome: -> 1000
      clearPhoneData: jasmine.createSpy()
      validMailingAddress: jasmine.createSpy()
      liveInSfMembers: () ->
      workInSfMembers: () ->
      liveInTheNeighborhoodMembers: () ->
      copyNeighborhoodToLiveInSf: jasmine.createSpy()
      clearAlternateContactDetails: jasmine.createSpy()
      invalidateHouseholdForm: jasmine.createSpy()
      invalidateIncomeForm: jasmine.createSpy()
      invalidateContactForm: jasmine.createSpy()
      resetMonthlyRentForm: jasmine.createSpy()
      invalidateMonthlyRentForm: jasmine.createSpy()
      invalidatePreferencesForm: jasmine.createSpy()
      resetAssistedHousingForm: jasmine.createSpy()
      signInSubmitApplication: jasmine.createSpy()
      preferenceRequired: jasmine.createSpy()
      refreshPreferences: jasmine.createSpy()
      resetPreference: jasmine.createSpy()
      showPreference: jasmine.createSpy()
      validateHouseholdMemberAddress: ->
        { error: -> null }
      validateApplicantAddress: ->
        { error: -> null }
      checkHouseholdEligiblity: (listing) ->
      hasHouseholdPublicHousingQuestion: ->
      submitApplication: (options={}) ->
      listingHasPreference: ->
      applicationHasPreference: ->
      eligibleForAssistedHousing: ->
      eligibleForRentBurden: ->
      eligibleForADHP: ->
      hasCompleteRentBurdenFiles: ->
      hasCompleteRentBurdenFilesForAddress: jasmine.createSpy()
      cancelPreference: jasmine.createSpy()
      setApplicationLanguage: jasmine.createSpy()
      claimedCustomPreference: jasmine.createSpy()
      resetApplicationData: ->
      isEnteringShortForm: jasmine.createSpy()
      storeLastPage: jasmine.createSpy()
    fakeFunctions =
      fakeGetLandingPage: (section, application) ->
        'household-intro'
      fakeIsLoading: -> false
      fakeSubmitOptionsForCurrentPage: -> {}
    fakeAccountService = {}
    fakeShortFormNavigationService = undefined
    fakeShortFormHelperService =
      fileAttachmentsForRentBurden: jasmine.createSpy()
    fakeAccountService =
      loggedIn: () ->
    fakeAddressValidationService =
      validationError: jasmine.createSpy()
    fakeFileUploadService =
      deletePreferenceFile: jasmine.createSpy()
      hasPreferenceFile: jasmine.createSpy()
      deleteRentBurdenPreferenceFiles: ->
    fakeSharedService = {}
    fakeEvent =
      preventDefault: ->
    fakeHHOpts = {}
    fakeIncomeOpts = {}

    beforeEach module('dahlia.controllers', ($provide) ->
      fakeShortFormNavigationService =
        sections: []
        hasNav: jasmine.createSpy()
        getLandingPage: spyOn(fakeFunctions, 'fakeGetLandingPage').and.callThrough()
        isLoading: spyOn(fakeFunctions, 'fakeIsLoading').and.callThrough()
        submitOptionsForCurrentPage: spyOn(fakeFunctions, 'fakeSubmitOptionsForCurrentPage').and.callThrough()
        _currentPage: jasmine.createSpy()
        getNextReservedPageIfAvailable: jasmine.createSpy()
      return
    )

    beforeEach inject(($rootScope, $controller, $q, _$document_) ->
      scope = $rootScope.$new()
      state = jasmine.createSpyObj('$state', ['go'])
      fakeTitle = jasmine.createSpyObj('Title', ['restore'])
      state.current = {name: 'dahlia.short-form-welcome.overview'}
      state.params = {}

      deferred = $q.defer()
      deferred.resolve('resolveData')
      spyOn(fakeFileUploadService, 'deleteRentBurdenPreferenceFiles').and.returnValue(deferred.promise)
      spyOn(fakeShortFormApplicationService, 'checkHouseholdEligiblity').and.returnValue(deferred.promise)
      spyOn(fakeShortFormApplicationService, 'validateApplicantAddress').and.callThrough()
      spyOn(fakeShortFormApplicationService, 'validateHouseholdMemberAddress').and.callThrough()
      spyOn(fakeShortFormApplicationService, 'hasHouseholdPublicHousingQuestion').and.callThrough()
      spyOn(fakeShortFormApplicationService, 'resetApplicationData').and.callThrough()
      spyOn(fakeShortFormApplicationService, 'submitApplication').and.callFake ->
        state.go('dahlia.my-applications', {skipConfirm: true})
        deferred.promise

      _$document_.scrollToElement = jasmine.createSpy()

      $controller 'ShortFormApplicationController',
        $scope: scope
        $state: state
        $document: _$document_
        Idle: fakeIdle
        Title: fakeTitle
        $translate: translate
        ShortFormApplicationService: fakeShortFormApplicationService
        ShortFormNavigationService: fakeShortFormNavigationService
        ShortFormHelperService: fakeShortFormHelperService
        AnalyticsService: fakeAnalyticsService
        FileUploadService: fakeFileUploadService
        AddressValidationService: fakeAddressValidationService
        AccountService: fakeAccountService
        SharedService: fakeSharedService
        inputMaxLength: {}
      return
    )

    describe '$scope.listing', ->
      it 'populates scope with a single listing', ->
        expect(scope.listing).toEqual fakeListing

    describe '$scope.hasNav', ->
      it 'calls function on navService', ->
        scope.hasNav()
        expect(fakeShortFormNavigationService.hasNav).toHaveBeenCalled()

    describe '$scope.submitForm', ->
      it 'calls submitOptionsForCurrentPage function on navService if form is valid', ->
        scope.submitForm()
        expect(fakeShortFormNavigationService.submitOptionsForCurrentPage).toHaveBeenCalled()

      it 'calls isLoading function on navService', ->
        scope.submitForm()
        expect(fakeShortFormNavigationService.isLoading).toHaveBeenCalled()

    describe '$scope.checkIfAlternateContactInfoNeeded', ->
      describe 'No alternate contact indicated', ->
        it 'navigates ahead to optional info', ->
          scope.alternateContact.alternateContactType = 'None'
          scope.checkIfAlternateContactInfoNeeded()
          expect(state.go).toHaveBeenCalledWith('dahlia.short-form-application.household-intro')

        it 'calls clearAlternateContactDetails from ShortFormApplicationService', ->
          scope.alternateContact.alternateContactType = 'None'
          scope.checkIfAlternateContactInfoNeeded()
          expect(fakeShortFormApplicationService.clearAlternateContactDetails).toHaveBeenCalled()

      describe 'Alternate contact type indicated', ->
        it 'navigates ahead to alt contact name page', ->
          scope.alternateContact.alternateContactType = 'Friend'
          scope.checkIfAlternateContactInfoNeeded()
          expect(state.go).toHaveBeenCalledWith('dahlia.short-form-application.alternate-contact-name')

    describe '$scope.copyHomeToMailingAddress', ->
      describe 'hasAltMailingAddress unchecked', ->
        it 'calls Service function to copy home address to mailing', ->
          scope.applicant.hasAltMailingAddress = false
          scope.copyHomeToMailingAddress()
          expect(fakeShortFormApplicationService.copyHomeToMailingAddress).toHaveBeenCalled()

    describe '$scope.addressChange', ->
      it 'unsets preferenceAddressMatch on member', ->
        scope.applicant.preferenceAddressMatch = 'Matched'
        scope.addressChange('applicant')
        expect(scope.applicant.preferenceAddressMatch).toEqual null

      it 'calls copyHomeToMailingAddress if member == applicant', ->
        scope.applicant.preferenceAddressMatch = 'Matched'
        scope.addressChange('applicant')
        expect(fakeShortFormApplicationService.copyHomeToMailingAddress).toHaveBeenCalled()

      it 'calls invalidateHouseholdForm if eligibleForRentBurden', ->
        spyOn(fakeShortFormApplicationService, 'eligibleForRentBurden').and.returnValue(true)
        scope.addressChange('applicant')
        expect(fakeShortFormApplicationService.invalidateHouseholdForm).toHaveBeenCalled()

    describe '$scope.addHouseholdMember', ->
      describe 'user has same address applicant', ->
        it 'directly calls addHouseholdMember in ShortFormApplicationService', ->
          scope.form.applicationForm.date_of_birth_year = {$viewValue: '1955'}
          scope.householdMember.hasSameAddressAsApplicant = 'Yes'
          scope.addHouseholdMember()
          expect(fakeShortFormApplicationService.addHouseholdMember).toHaveBeenCalledWith(scope.householdMember)

      describe 'user does not have same address applicant', ->
        it 'calls validateHouseholdMemberAddress in ShortFormApplicationService', ->
          scope.householdMember.hasSameAddressAsApplicant = 'No'
          scope.householdMember.preferenceAddressMatch = false
          scope.addHouseholdMember()
          expect(fakeShortFormApplicationService.validateHouseholdMemberAddress).toHaveBeenCalled()

    describe '$scope.cancelHouseholdMember', ->
      it 'calls cancelHouseholdMember in ShortFormApplicationService', ->
        scope.cancelHouseholdMember()
        expect(fakeShortFormApplicationService.cancelHouseholdMember).toHaveBeenCalled()

      it 'navigates to household members index', ->
        scope.cancelHouseholdMember()
        expect(state.go).toHaveBeenCalledWith('dahlia.short-form-application.household-members')

    describe '$scope.addressValidationError', ->
      it 'calls validationError in AddressValidationService', ->
        scope.validated_home_address = {street1: 'x'}
        scope.addressError = true
        scope.addressValidationError('home_address')
        expect(fakeAddressValidationService.validationError).toHaveBeenCalled()

    describe '$scope.addressInputInvalid', ->
      it 'calls validationError in AddressValidationService', ->
        scope.form = {applicationForm: {}}
        scope.validated_home_address = {street1: 'x'}
        scope.addressError = true
        scope.addressInputInvalid('home_address')
        expect(fakeAddressValidationService.validationError).toHaveBeenCalled()

    describe '$scope.checkIfAddressVerificationNeeded', ->
      it 'navigates ahead to alt contact type if verification already happened', ->
        scope.applicant.preferenceAddressMatch = 'Matched'
        scope.application.validatedForms.You['verify-address'] = true
        scope.checkIfAddressVerificationNeeded()
        expect(state.go).toHaveBeenCalledWith('dahlia.short-form-application.alternate-contact-type')

      it 'navigates ahead to verify address page if verification had not happened', ->
        scope.applicant.preferenceAddressMatch = null
        scope.application.validatedForms.You['verify-address'] = null
        scope.checkIfAddressVerificationNeeded()
        expect(fakeShortFormApplicationService.validateApplicantAddress).toHaveBeenCalled()

    describe '$scope.getLandingPage', ->
      it 'calls getLandingPage in ShortFormNavigationService', ->
        scope.getLandingPage({name: 'Household'})
        expect(fakeShortFormNavigationService.getLandingPage).toHaveBeenCalled()

    describe '$scope.checkPreferenceEligibility', ->
      it 'calls refreshPreferences in ShortFormApplicationService', ->
        scope.checkPreferenceEligibility()
        expect(fakeShortFormApplicationService.refreshPreferences).toHaveBeenCalled()

    describe '$scope.liveInSfMembers', ->
      it 'calls liveInSfMembers in ShortFormApplicationService', ->
        spyOn(fakeShortFormApplicationService, 'liveInSfMembers').and.returnValue([])
        scope.liveInSfMembers()
        expect(fakeShortFormApplicationService.liveInSfMembers).toHaveBeenCalled()

    describe '$scope.workInSfMembers', ->
      it 'calls workInSfMembers in ShortFormApplicationService', ->
        spyOn(fakeShortFormApplicationService, 'workInSfMembers').and.returnValue([])
        scope.workInSfMembers()
        expect(fakeShortFormApplicationService.workInSfMembers).toHaveBeenCalled()

    describe 'validateHouseholdEligibility', ->
      it 'resets the eligibility error messages', ->
        scope.eligibilityErrors = ['Error']
        scope.validateHouseholdEligibility()
        expect(scope.eligibilityErrors).toEqual([])
      it 'calls checkHouseholdEligiblity in ShortFormApplicationService', ->
        scope.listing = fakeListing
        scope.validateHouseholdEligibility('householdMatch')
        expect(fakeShortFormApplicationService.checkHouseholdEligiblity).toHaveBeenCalledWith(fakeListing)
      it 'skips ahead if incomeMatch and vouchers', ->
        scope.listing = fakeListing
        scope.application.householdVouchersSubsidies = 'Yes'
        scope.validateHouseholdEligibility('incomeMatch')
        expect(state.go).toHaveBeenCalled()

    describe 'checkIfPublicHousing', ->
      it 'goes to household-monthly-rent page if publicHousing answer is "No"', ->
        scope.application.hasPublicHousing = 'No'
        scope.checkIfPublicHousing()
        expect(state.go).toHaveBeenCalledWith('dahlia.short-form-application.household-monthly-rent')
      it 'skips ahead to next household page if publicHousing answer is "Yes"', ->
        scope.application.hasPublicHousing = 'Yes'
        scope.checkIfPublicHousing()
        expect(fakeShortFormNavigationService.getNextReservedPageIfAvailable).toHaveBeenCalled()

    describe 'checkIfReservedUnits', ->
      it 'calls getNextReservedPageIfAvailable on navService', ->
        scope.checkIfReservedUnits()
        expect(fakeShortFormNavigationService.getNextReservedPageIfAvailable).toHaveBeenCalled()

    describe 'publicHousingYes', ->
      it 'calls resetMonthlyRentForm in ShortFormApplicationService', ->
        scope.publicHousingYes()
        expect(fakeShortFormApplicationService.resetMonthlyRentForm).toHaveBeenCalled()
      it 'calls invalidatePreferencesForm in ShortFormApplicationService', ->
        scope.publicHousingYes()
        expect(fakeShortFormApplicationService.invalidatePreferencesForm).toHaveBeenCalled()

    describe 'publicHousingNo', ->
      it 'calls invalidateMonthlyRentForm in ShortFormApplicationService', ->
        scope.publicHousingNo()
        expect(fakeShortFormApplicationService.invalidateMonthlyRentForm).toHaveBeenCalled()
      it 'calls resetAssistedHousingForm in ShortFormApplicationService', ->
        scope.publicHousingNo()
        expect(fakeShortFormApplicationService.resetAssistedHousingForm).toHaveBeenCalled()

    describe '$scope.clearPhoneData', ->
      it 'calls clearPhoneData in ShortFormApplicationService', ->
        type = 'phone'
        scope.clearPhoneData(type)
        expect(fakeShortFormApplicationService.clearPhoneData).toHaveBeenCalledWith(type)

    describe '$scope.validMailingAddress', ->
      it 'calls validMailingAddress in ShortFormApplicationService', ->
        scope.validMailingAddress()
        expect(fakeShortFormApplicationService.validMailingAddress).toHaveBeenCalled()

    describe '_respondToHouseholdEligibilityResults', ->
      describe 'when householdMatch is true', ->
        beforeEach ->
          eligibility = { householdMatch: true }
          error = null

        it 'navigates to the given callback url for household', ->
          scope._respondToHouseholdEligibilityResults(eligibility, error)
          expect(fakeShortFormNavigationService.getNextReservedPageIfAvailable).toHaveBeenCalled()

      describe 'when householdMatch is false', ->
        beforeEach ->
          eligibility = { householdMatch: false }
          error = 'too big'
          fakeHHOpts =
            householdSize: fakeShortFormApplicationService.householdSize()

        it 'expects household section to be invalidated', ->
          scope._respondToHouseholdEligibilityResults(eligibility, error)
          expect(fakeShortFormApplicationService.invalidateHouseholdForm).toHaveBeenCalled()

        it 'assigns an error message function', ->
          scope.eligibilityErrors = []
          scope._respondToHouseholdEligibilityResults(eligibility, error)
          expect(scope.eligibilityErrors).not.toEqual([])

        it 'tracks a household size form error in analytics', ->
          scope._respondToHouseholdEligibilityResults(eligibility, error)
          expect(fakeAnalyticsService.trackFormError).toHaveBeenCalledWith('Application', 'household too big', fakeHHOpts)

    describe '_respondToIncomeEligibilityResults', ->
      describe 'when incomeMatch is true', ->
        beforeEach ->
          eligibility = { incomeMatch: true }
          error = null

        it 'navigates to the given callback url for income', ->
          scope._respondToIncomeEligibilityResults(eligibility, error)
          expect(fakeShortFormNavigationService.getLandingPage).toHaveBeenCalledWith({name: 'Preferences'})

      describe 'when incomeMatch is false', ->
        beforeEach ->
          eligibility = { incomeMatch: false }
          error = 'too high'

          fakeHHOpts =
            householdSize: fakeShortFormApplicationService.householdSize()
          fakeIncomeOpts =
            householdSize: fakeShortFormApplicationService.householdSize()
            value: fakeShortFormApplicationService.calculateHouseholdIncome()

        it 'expects income section to be invalidated', ->
          scope._respondToIncomeEligibilityResults(eligibility, error)
          expect(fakeShortFormApplicationService.invalidateIncomeForm).toHaveBeenCalled()

        it 'assigns an error message function', ->
          scope.eligibilityErrors = []
          scope._respondToIncomeEligibilityResults(eligibility, error)
          expect(scope.eligibilityErrors).not.toEqual([])

        it 'tracks an income form error in analytics', ->
          scope._respondToIncomeEligibilityResults(eligibility, error)
          expect(fakeAnalyticsService.trackFormError).toHaveBeenCalledWith('Application', 'income too high', fakeIncomeOpts)


    describe 'clearEligibilityErrors', ->
      it 'empties scope.eligibilityErrors', ->
        scope.eligibilityErrors = ['some error message']
        scope.clearEligibilityErrors()
        expect(scope.eligibilityErrors).toEqual([])

    describe 'submitApplication', ->
      it 'calls submitApplication ShortFormApplicationService', ->
        scope.submitApplication()
        expect(fakeShortFormApplicationService.submitApplication).toHaveBeenCalledWith({finish: true})

    describe 'checkIfPreferencesApply', ->
      beforeEach ->
        members = ['somemembers']
        spyOn(fakeShortFormApplicationService, 'liveInSfMembers').and.returnValue(members)
        spyOn(fakeShortFormApplicationService, 'workInSfMembers').and.returnValue(members)
        spyOn(fakeShortFormApplicationService, 'liveInTheNeighborhoodMembers').and.returnValue([])

      describe 'household is eligible for RB/AH preferences',->
        it 'routes user to assistedHousing preference page', ->
          fakeShortFormApplicationService.eligibleForRentBurden = jasmine.createSpy().and.returnValue(false)
          fakeShortFormApplicationService.eligibleForAssistedHousing = jasmine.createSpy().and.returnValue(true)
          scope.checkIfPreferencesApply()
          path = 'dahlia.short-form-application.assisted-housing-preference'
          expect(state.go).toHaveBeenCalledWith(path)

        it 'routes user to rentBurden preference page', ->
          fakeShortFormApplicationService.eligibleForAssistedHousing = jasmine.createSpy().and.returnValue(false)
          fakeShortFormApplicationService.eligibleForRentBurden = jasmine.createSpy().and.returnValue(true)
          scope.checkIfPreferencesApply()
          path = 'dahlia.short-form-application.rent-burdened-preference'
          expect(state.go).toHaveBeenCalledWith(path)

      describe 'preferences do not apply to household',->
        it 'routes user to general lottery notice page', ->
          fakeShortFormApplicationService.eligibleForAssistedHousing = jasmine.createSpy().and.returnValue(false)
          fakeShortFormApplicationService.eligibleForRentBurden = jasmine.createSpy().and.returnValue(false)
          fakeShortFormApplicationService.eligibleForNRHP = jasmine.createSpy().and.returnValue(false)
          fakeShortFormApplicationService.eligibleForLiveWork = jasmine.createSpy().and.returnValue(false)
          fakeShortFormApplicationService.applicantHasNoPreferences = jasmine.createSpy().and.returnValue(true)
          scope.checkIfPreferencesApply()
          path = 'dahlia.short-form-application.preferences-programs'
          expect(state.go).toHaveBeenCalledWith(path)

      describe 'household is not eligible for RB/AH, neighborhood but has live/work',->
        it 'routes user to live work preferences page', ->
          fakeShortFormApplicationService.eligibleForRentBurden = jasmine.createSpy().and.returnValue(false)
          fakeShortFormApplicationService.eligibleForNRHP = jasmine.createSpy().and.returnValue(false)
          fakeShortFormApplicationService.eligibleForLiveWork = jasmine.createSpy().and.returnValue(true)
          scope.checkIfPreferencesApply()
          path = 'dahlia.short-form-application.live-work-preference'
          expect(state.go).toHaveBeenCalledWith(path)

    describe 'checkAfterLiveInTheNeighborhood', ->
      it 'goes to live-work-preference page if you did not select the preference', ->
        spyOn(fakeShortFormApplicationService, 'applicationHasPreference').and.returnValue(false)
        scope.checkAfterLiveInTheNeighborhood('neighborhoodResidence')
        expect(state.go).toHaveBeenCalledWith('dahlia.short-form-application.live-work-preference')

    describe 'checkAfterLiveWork', ->
      it 'goes to preferences-programs page', ->
        scope.checkAfterLiveWork()
        path = 'dahlia.short-form-application.preferences-programs'
        expect(state.go).toHaveBeenCalledWith(path)

    describe 'saveAndFinishLater', ->
      describe 'logged in', ->
        beforeEach ->
          spyOn(fakeAccountService, 'loggedIn').and.returnValue(true)
          scope.saveAndFinishLater(fakeEvent)

        it 'submits application as a draft', ->
          expect(fakeShortFormApplicationService.submitApplication).toHaveBeenCalled()

        it 'routes user to my applications', ->
          expect(state.go).toHaveBeenCalledWith('dahlia.my-applications', {skipConfirm: true})

      describe 'not logged in', ->
        it 'routes directly to create account', ->
          spyOn(fakeAccountService, 'loggedIn').and.returnValue(false)
          scope.saveAndFinishLater(fakeEvent)
          expect(state.go).toHaveBeenCalledWith('dahlia.short-form-application.create-account')

    describe 'showPreference', ->
      it 'calls function on ShortFormApplicationService', ->
        scope.showPreference('liveInSf')
        expect(fakeShortFormApplicationService.showPreference).toHaveBeenCalledWith 'liveInSf'

    describe 'preferenceRequired', ->
      it 'calls function on ShortFormApplicationService', ->
        fakeShortFormApplicationService.showPreference = jasmine.createSpy().and.returnValue(true)
        scope.preferenceRequired('liveInSf')
        expect(fakeShortFormApplicationService.preferenceRequired).toHaveBeenCalledWith 'liveInSf'

    describe 'preferenceWarning', ->
      it 'calls inputInvalid with currentPreferenceType', ->
        spyOn(fakeShortFormApplicationService, 'inputInvalid')
        scope.form.currentPreferenceType = 'liveInSf'
        scope.preferenceWarning()
        expect(fakeShortFormApplicationService.inputInvalid).toHaveBeenCalled()

    describe 'primaryApplicantUnder18', ->
      it 'checks form values for primary applicant DOB that is under 18', ->
        year = new Date().getFullYear()
        scope.form.applicationForm.date_of_birth_year = {$viewValue: year}
        scope.applicant.dob_month = 1
        scope.applicant.dob_day = 1
        scope.applicant.dob_year = year
        expect(scope.primaryApplicantUnder18()).toEqual true

      it 'checks form values for primary applicant DOB that is over 18', ->
        scope.form.applicationForm.date_of_birth_year = {$viewValue: '1995'}
        scope.applicant.dob_month = 10
        scope.applicant.dob_day = 10
        scope.applicant.dob_year = 1995
        expect(scope.primaryApplicantUnder18()).toEqual false

    describe 'householdMemberValidAge', ->
      it 'checks form values for household member age', ->
        year = new Date().getFullYear()
        scope.form.applicationForm.date_of_birth_year = {$viewValue: year}
        # due to "unborn child rule" 8-1-YYYY of current year should always be valid
        scope.householdMember.dob_month = 8
        scope.householdMember.dob_day = 1
        scope.householdMember.dob_year = year
        expect(scope.householdMemberValidAge()).toEqual true

    describe 'goToLandingPage', ->
      it 'expects state.go to be called with landing page path', ->
        scope.goToLandingPage('Household')
        # Expect route path that is set up in FakeShortFormNavigationService, above
        expect(state.go).toHaveBeenCalledWith('dahlia.short-form-application.household-intro')

    describe 'beginApplication', ->
      it 'expects state.go to be called with community screening page if listing is a community building', ->
        scope.listing.Reserved_community_type = 'Veteran'
        lang = 'en'
        scope.beginApplication(lang)
        expect(state.go).toHaveBeenCalledWith('dahlia.short-form-welcome.community-screening', {lang: lang})

      it 'expects state.go to be called with overview page and language param', ->
        scope.listing.Reserved_community_type = null
        lang = 'es'
        scope.beginApplication(lang)
        expect(state.go).toHaveBeenCalledWith('dahlia.short-form-welcome.overview', {lang: lang})

    describe 'validateCommunityEligibility', ->
      it 'expects state.go to be called with short form overview page if applicant answered Yes to screening question', ->
        scope.application.answeredCommunityScreening = 'Yes'
        scope.validateCommunityEligibility()
        expect(state.go).toHaveBeenCalledWith('dahlia.short-form-welcome.overview')

      it 'expects a community eligibility error if applicant answered No to screening question', ->
        scope.application.answeredCommunityScreening = 'No'
        scope.eligibilityErrors = []
        scope.communityEligibilityErrorMsg = ['At least one member of your household must be a Veteran']
        scope.validateCommunityEligibility()
        expect(scope.eligibilityErrors).toEqual scope.communityEligibilityErrorMsg

    describe 'checkForRentBurdenFiles', ->
      describe 'with rent burden opted out', ->
        it 'expects scope.checkForNeighborhoodOrLiveWork to be called to determine next page', ->
          scope.preferences.optOut.rentBurden = true
          fakeShortFormApplicationService.eligibleForNRHP = jasmine.createSpy().and.returnValue(true)
          scope.checkForRentBurdenFiles()
          expect(state.go).toHaveBeenCalledWith('dahlia.short-form-application.neighborhood-preference')

      describe 'with complete rent burden files', ->
        it 'expects scope.checkForNeighborhoodOrLiveWork to be called to determine next page', ->
          scope.preferences.optOut.rentBurden = false
          fakeShortFormApplicationService.eligibleForNRHP = jasmine.createSpy().and.returnValue(true)
          fakeShortFormApplicationService.hasCompleteRentBurdenFiles = -> true
          scope.checkForRentBurdenFiles()
          expect(state.go).toHaveBeenCalledWith('dahlia.short-form-application.neighborhood-preference')

      describe 'with incomplete rent burden files', ->
        it 'sets custom invalid message', ->
          fakeShortFormApplicationService.hasCompleteRentBurdenFiles = -> false
          scope.checkForRentBurdenFiles()
          expect(scope.customInvalidMessage).not.toEqual(null)

    describe 'cancelRentBurdenFilesForAddress', ->
      it 'expects deleteRentBurdenPreferenceFiles to be called on Service', ->
        address = '123 Main St'
        scope.cancelRentBurdenFilesForAddress(address)
        expect(fakeFileUploadService.deleteRentBurdenPreferenceFiles).toHaveBeenCalledWith(scope.listing.Id, address)

    describe 'hasCompleteRentBurdenFilesForAddress', ->
      it 'expects hasCompleteRentBurdenFilesForAddress to be called on Service', ->
        address = '123 Main St'
        scope.hasCompleteRentBurdenFilesForAddress(address)
        expect(fakeShortFormApplicationService.hasCompleteRentBurdenFilesForAddress).toHaveBeenCalledWith(address)

    describe 'cancelPreference', ->
      it 'clears rent burden error for rent burden preference', ->
        scope.customInvalidMessage = 'some value'
        scope.cancelPreference('rentBurden')
        expect(scope.customInvalidMessage).toEqual null

      it 'calls cancelPreference on ShortFormApplicationService', ->
        scope.cancelPreference()
        expect(fakeShortFormApplicationService.cancelPreference).toHaveBeenCalled()

    describe 'fileAttachmentsForRentBurden', ->
      it 'called on fileAttachmentsForRentBurden on ShortFormHelperService', ->
        scope.fileAttachmentsForRentBurden()
        expect(fakeShortFormHelperService.fileAttachmentsForRentBurden).toHaveBeenCalled()

    describe 'onStateChangeSuccess', ->
      it 'expects setApplicationLanguage to be called on ShortFormApplicationService', ->
        lang = 'es'
        toState = {name: 'state'}
        scope.onStateChangeSuccess(null, toState, {lang: lang})
        expect(fakeShortFormApplicationService.setApplicationLanguage).toHaveBeenCalledWith(lang)

      it 'expects isLoading to be set to false on ShortFormNavigationService', ->
        lang = 'es'
        toState = {name: 'state'}
        scope.onStateChangeSuccess(null, toState, {lang: lang})
        expect(fakeShortFormNavigationService.isLoading).toHaveBeenCalledWith(false)

    describe 'resetAndStartNewApp', ->
      beforeEach ->
        scope.resetAndStartNewApp()

      it 'calls resetApplicationData on ShortFormApplicationService', ->
        expect(fakeShortFormApplicationService.resetApplicationData).toHaveBeenCalled()

      it 'unsets application autofill value', ->
        expect(scope.application.autofill).toBeUndefined()

      it 'send user to You section of short form', ->
        expect(state.go).toHaveBeenCalledWith('dahlia.short-form-application.name')

    describe 'checkForCustomPreferences', ->
      describe 'listing has custom preferences', ->
        it 'takes user to custom preferences page', ->
          scope.listing.customPreferences = [{preferenceName: 'customPreference', listingPreferenceID: '123456'}]
          scope.checkForCustomPreferences()
          expect(state.go).toHaveBeenCalledWith('dahlia.short-form-application.custom-preferences')

    describe 'checkForCustomProofPreferences', ->
      beforeEach ->
        scope.listing.customProofPreferences = ['pref1', 'pref2']

      describe 'checking custom proof preferences for the first time', ->
        it 'sends user to custom proof pref page with index 0', ->
          state.params.prefIdx = NaN
          scope.checkForCustomProofPreferences()
          expect(state.go).toHaveBeenCalledWith('dahlia.short-form-application.custom-proof-preferences', {prefIdx: 0})

      describe 'paging thru custom preferences', ->
        it 'sends user to custom proof pref page with the subsequent index', ->
          state.params.prefIdx = 0
          scope.checkForCustomProofPreferences()
          expect(state.go).toHaveBeenCalledWith('dahlia.short-form-application.custom-proof-preferences', {prefIdx: 1})

      describe 'at last page of custom preferences', ->
        it 'checks if there are no preferences selected', ->
          state.params.prefIdx = 1
          scope.checkIfNoPreferencesSelected = jasmine.createSpy()
          scope.checkForCustomProofPreferences()
          expect(scope.checkIfNoPreferencesSelected).toHaveBeenCalled()

    describe 'claimedCustomPreference', ->
      it ' calls claimedCustomPreference on ShortFormApplicationService', ->
        scope.claimedCustomPreference()
        expect(fakeShortFormApplicationService.claimedCustomPreference).toHaveBeenCalled()
