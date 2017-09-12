ShortFormNavigationService = (
  $state, bsLoadingOverlayService, ShortFormApplicationService, AccountService
) ->
  Service = {}
  RESERVED_TYPES = ShortFormApplicationService.RESERVED_TYPES
  Service.loading = false
  Service.sections = [
    { name: 'You', pages: [
        'name'
        'contact'
        'verify-address'
        'alternate-contact-type'
        'alternate-contact-name'
        'alternate-contact-phone-address'
      ]
    },
    { name: 'Household', pages: [
        'household-intro'
        'household-overview'
        'household-members'
        'household-member-form'
        'household-member-form-edit'
        'household-public-housing'
        'household-monthly-rent'
        'household-reserved-units-veteran'
        'household-reserved-units-disabled'
        'household-priorities'
      ]
    },
    { name: 'Income', pages: [
        'income-vouchers'
        'income'
      ]
    },
    { name: 'Preferences', pages: [
        'preferences-intro'
        'assisted-housing-preference'
        'rent-burden-preference'
        'rent-burden-preference-edit'
        'neighborhood-preference'
        'adhp-preference'
        'live-work-preference'
        'preferences-programs'
        'custom-preferences'
        'general-lottery-notice'
      ]
    },
    { name: 'Review', pages: [
        'review-optional'
        'review-summary'
        'review-sign-in'
        'review-terms'
      ]
    }
  ]

  Service.submitActions =
    # intro
    'community-screening': {callback: ['validateCommunityEligibility']}
    # you
    'name': {callback: ['checkPrimaryApplicantAge']}
    'contact': {callback: ['checkIfAddressVerificationNeeded', 'checkPreferenceEligibility']}
    'verify-address': {path: 'alternate-contact-type', callback: ['checkPreferenceEligibility']}
    'alternate-contact-type': {callback: ['checkIfAlternateContactInfoNeeded']}
    'alternate-contact-name': {path: 'alternate-contact-phone-address'}
    'alternate-contact-phone-address': {callback: ['goToLandingPage'], params: 'Household'}
    # household
    'household-intro': {callback: ['validateHouseholdEligibility'], params: 'householdMatch'}
    'household-members': {callback: ['validateHouseholdEligibility'], params: 'householdMatch'}
    'household-member-form': {callback: ['addHouseholdMember', 'checkPreferenceEligibility']}
    'household-member-form-edit': {callback: ['addHouseholdMember', 'checkPreferenceEligibility']}
    'household-member-verify-address': {path: 'household-members', callback: ['checkPreferenceEligibility']}
    'household-public-housing': {callback: ['checkIfPublicHousing']}
    'household-monthly-rent': {callback: ['checkIfReservedUnits']}
    'household-reserved-units-veteran': {callback: ['checkIfReservedUnits'], params: RESERVED_TYPES.DISABLED}
    'household-reserved-units-disabled': {path: 'household-priorities'}
    'household-priorities': {path: 'income-vouchers'}
    # income
    'income-vouchers': {path: 'income'}
    'income': {callback: ['validateHouseholdEligibility'], params: 'incomeMatch'}
    # preferences
    'preferences-intro': {callback: ['checkIfPreferencesApply']}
    'assisted-housing-preference': {callback: ['checkForNeighborhoodOrLiveWork']}
    'rent-burden-preference': {callback: ['checkForRentBurdenFiles']}
    'rent-burden-preference-edit': {path: 'rent-burden-preference'}
    'neighborhood-preference': {callback: ['checkAfterLiveInTheNeighborhood'], params: 'neighborhoodResidence'}
    'adhp-preference': {callback: ['checkAfterLiveInTheNeighborhood'], params: 'antiDisplacement'}
    'live-work-preference': {callback: ['checkAfterLiveWork']}
    'preferences-programs': {callback: ['checkForCustomPreferences']}
    'custom-preferences': {callback: ['checkIfNoPreferencesSelected']}
    'general-lottery-notice': {callback: ['goToLandingPage'], params: 'Review'}
    # review
    'review-optional': {path: 'review-summary', callback: ['checkSurveyComplete']}
    'review-summary': {callback: ['confirmReviewedApplication']}
    'review-sign-in': {path: 'review-terms'}
    'review-terms': {callback: ['submitApplication']}
    # save + finish workflow
    'choose-draft': {callback: ['chooseDraft']}
    'choose-account-settings': {callback: ['chooseAccountSettings']}

  Service.submitOptionsForCurrentPage = ->
    options = angular.copy(Service.submitActions[Service._currentPage()] || {})
    options.path = "dahlia.short-form-application.#{options.path}" if options.path
    options

  Service.getLandingPage = (section) ->
    application = ShortFormApplicationService.application
    switch section.name
      when 'Household'
        if application.householdMembers.length
          'household-members'
        else
          'household-intro'
      when 'Income'
        'income-vouchers'
      when 'Preferences'
        'preferences-intro'
      when 'Review'
        if application.surveyComplete
          'review-summary'
        else
          'review-optional'
      else
        section.pages[0]

  Service.isLoading = (bool = null) ->
    if bool == null
      return Service.loading
    else
      Service.loading = bool
      if Service.loading
        bsLoadingOverlayService.start()
      else
        bsLoadingOverlayService.stop()

  Service.hasNav = ->
    hideNav = ['intro', 'confirmation']
    hideNav.indexOf(Service._currentPage()) < 0

  Service.hasBackButton = ->
    return false if $state.current.name == 'dahlia.short-form-review'
    hideBackButton = [
      'intro',
      'overview',
      'name',
      'verify-address',
      'household-members',
      'household-member-form',
      'household-member-form-edit',
      'household-member-verify-address',
      'rent-burden-preference-edit',
      'review-summary',
      'confirmation'
    ]
    hideBackButton.indexOf(Service._currentPage()) < 0

  Service.isActiveSection = (section) ->
    section.pages.indexOf(Service._currentPage()) > -1

  Service.isPreviousSection = (section) ->
    _sectionNames = Service._sectionNames()
    if Service.activeSection()
      indexOfActiveSection = _sectionNames.indexOf(Service.activeSection().name)
      indexofSection = _sectionNames.indexOf(section.name)
      indexofSection < indexOfActiveSection

  Service.activeSection = () ->
    Service._sectionOfPage(Service._currentPage())

  Service.backPageState = ->
    "dahlia.short-form-application.#{Service.previousPage()}"

  Service.previousPage = ->
    application = ShortFormApplicationService.application
    page = switch Service._currentPage()
      # -- Pages that follow normal deterministic order
      when 'contact'
        ,'alternate-contact-name'
        ,'alternate-contact-phone-address'
        ,'household-overview'
        ,'income'
        ,'preferences-intro'
        ,'review-summary'
        ,'review-sign-in'
          Service._getPreviousPage()
      # -- Alt Contact
      when 'alternate-contact-type'
        'contact'
      # -- Household
      when 'household-intro'
        if application.alternateContact.alternateContactType == 'None'
          'alternate-contact-type'
        else
          'alternate-contact-phone-address'
      when 'household-public-housing'
        if application.householdMembers.length
          'household-members'
        else
          'household-intro'
      when 'household-monthly-rent'
        'household-public-housing'
      when 'household-reserved-units-veteran'
        Service.getPrevPageOfHouseholdSection()
      when 'household-reserved-units-disabled'
        Service.getNextReservedPageIfAvailable(RESERVED_TYPES.VETERAN, 'prev')
      when 'household-priorities'
        Service.getNextReservedPageIfAvailable(RESERVED_TYPES.DISABLED, 'prev')
      # -- Income
      when 'income-vouchers'
        'household-priorities'
      # -- Preferences
      when 'rent-burden-preference'
        , 'assisted-housing-preference'
          'preferences-programs'
      when 'neighborhood-preference'
        , 'adhp-preference'
          Service.goBackToRentBurden()
      when 'live-work-preference'
        if ShortFormApplicationService.eligibleForNRHP()
          'neighborhood-preference'
        else if ShortFormApplicationService.eligibleForADHP()
          'adhp-preference'
        else
          Service.goBackToRentBurden()
      when 'preferences-programs'
        , 'general-lottery-notice'
          Service.getPrevPageOfPreferencesSection()
      when 'custom-preferences'
        'preferences-programs'
      # -- Review
      when 'review-optional'
        if ShortFormApplicationService.applicantHasNoPreferences()
          'general-lottery-notice'
        else
          'preferences-programs'
      when 'review-terms'
        if AccountService.loggedIn()
          'review-summary'
        else
          'review-sign-in'
      when 'review-submitted'
        'confirmation'
      # -- catch all
      else
        'intro'
    page

  Service.getNextReservedPageIfAvailable = (type = RESERVED_TYPES.VETERAN, dir = 'next') ->
    hasType = ShortFormApplicationService.listingHasReservedUnitType(type)
    switch type
      when RESERVED_TYPES.VETERAN
        if hasType
          'household-reserved-units-veteran'
        else
          if dir == 'next'
            # move on to the next type
            Service.getNextReservedPageIfAvailable(RESERVED_TYPES.DISABLED, 'next')
          else
            Service.getPrevPageOfHouseholdSection()
      when RESERVED_TYPES.DISABLED
        if hasType
          'household-reserved-units-disabled'
        else
          if dir == 'next'
            # once we've gotten to the end of our types, go to Income
            'household-priorities'
          else
            Service.getNextReservedPageIfAvailable(RESERVED_TYPES.VETERAN, 'prev')


  Service.getPrevPageOfHouseholdSection = ->
    application = ShortFormApplicationService.application
    if application.hasPublicHousing == 'No'
      'household-monthly-rent'
    else if application.hasPublicHousing == 'Yes'
      'household-public-housing'
    else if application.householdMembers.length
      'household-members'
    else
      'household-intro'

  Service.goBackToRentBurden = ->
    if ShortFormApplicationService.eligibleForAssistedHousing()
      'assisted-housing-preference'
    else if ShortFormApplicationService.eligibleForRentBurden()
      'rent-burden-preference'
    else
      'preferences-intro'

  Service.goBackToLiveWorkNeighborhood = ->
    if ShortFormApplicationService.applicationHasPreference('neighborhoodResidence')
      'neighborhood-preference'
    else if ShortFormApplicationService.applicationHasPreference('antiDisplacement')
      'adhp-preference'
    else if ShortFormApplicationService.eligibleForLiveWork()
      'live-work-preference'
    else
      Service.goBackToRentBurden()

  Service.getPrevPageOfPreferencesSection = ->
    if Service._currentPage() == 'preferences-programs'
      Service.goBackToLiveWorkNeighborhood()
    else if Service._currentPage() == 'general-lottery-notice' && ShortFormApplicationService.listing.customPreferences.length > 0
      'custom-preferences'
    else if Service._currentPage() == 'general-lottery-notice' && ShortFormApplicationService.listing.customPreferences.length == 0
      'preferences-programs'

  Service.getStartOfHouseholdDetails = ->
    # This returns the page in the household section that comes directly after
    # the household members page
    application = ShortFormApplicationService.application
    listing = ShortFormApplicationService.listing
    return '' if application.status.toLowerCase() == 'submitted'
    if application.hasPublicHousing
      'household-public-housing'
    else if ShortFormApplicationService.listingHasReservedUnitType(RESERVED_TYPES.VETERAN)
      'household-reserved-units-veteran'
    else if ShortFormApplicationService.listingHasReservedUnitType(RESERVED_TYPES.DISABLED)
      'household-reserved-units-disabled'
    else
      'household-priorities'

  Service._currentPage = () ->
    Service._getSuffix($state.current.name)

  Service._getSuffix = (stateName) ->
    stateName.replace(/dahlia.short-form-(welcome|application)\./, "")

  Service._getPreviousPage = () ->
    pages = _.flatten _.map(Service.sections, (section) -> section.pages)
    index = pages.indexOf(Service._currentPage())
    return pages[index - 1]

  Service.getShortFormSectionFromState = (state) ->
    return false unless state.name.match(/dahlia.short-form-application\./)
    # store in ShortFormApplicationService
    section = Service._sectionOfPage(Service._getSuffix(state.name))
    ShortFormApplicationService.activeSection = section
    section

  Service._sectionOfPage = (stateName) ->
    currentSection = null
    Service.sections.forEach (section) ->
      if section.pages.indexOf(stateName) > -1
        currentSection = section
    return currentSection

  Service._sectionNames = () ->
    Service.sections.map (section) ->
      return section.name

  return Service

ShortFormNavigationService.$inject = [
  '$state', 'bsLoadingOverlayService', 'ShortFormApplicationService', 'AccountService'
]

angular
  .module('dahlia.services')
  .service('ShortFormNavigationService', ShortFormNavigationService)
