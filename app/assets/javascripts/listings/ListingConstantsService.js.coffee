############################################################################################
####################################### SERVICE ############################################
############################################################################################

ListingConstantsService = () ->
  Service = {}

  Service._mohcdPaperAppURLBase = 'https://sfmohcd.org/sites/default/files/Documents/MOH/'
  Service._mohcdRentalPaperAppURLTemplate =
    Service._mohcdPaperAppURLBase +
    'BMR%20Rental%20Paper%20Applications/' +
    '{lang}%20BMR%20Rent%20Short%20Form%20Paper%20App.pdf'

  Service.paperAppLanguages = [
    { language: 'English', label: 'English' }
    { language: 'Spanish', label: 'Español' }
    { language: 'Traditional Chinese', label: '中文', slug: 'Chinese' }
    { language: 'Tagalog', label: 'Filipino' }
  ]
  Service.rentalPaperAppURLs = Service.paperAppLanguages.map((l) -> {
    language: l.language
    label: l.label
    url: Service._mohcdRentalPaperAppURLTemplate.replace('{lang}', l.slug || l.language)
  })

  Service.fieldsForUnitGrouping = [
    'monthly_income_min',
    'monthly_rent_as_percent_of_income',
    'monthly_rent',
    'reserved_type',
    'status',
    'unit_type_label',
    'unit_type',
  ]

  Service.priorityLabelMap =
    'Vision impairments':
      name: 'Vision Impairments'
      description: 'impaired vision'
    'Hearing impairments':
      name: 'Hearing Impairments'
      description: 'impaired hearing'
    'Hearing/Vision impairments':
      name: 'Vision and/or Hearing Impairments'
      description: 'impaired vision and/or hearing'
    'Mobility/hearing/vision impairments':
      name: 'Mobility, Hearing and/or Vision Impairments'
      description: 'impaired mobility, hearing and/or vision'
    'Mobility impairments':
      name: 'Mobility Impairments'
      description: 'impaired mobility'

  Service.preferenceMap =
    certOfPreference: "Certificate of Preference (COP)"
    displaced: "Displaced Tenant Housing Preference (DTHP)"
    liveWorkInSf: "Live or Work in San Francisco Preference"
    liveInSf: "Live or Work in San Francisco Preference"
    workInSf: "Live or Work in San Francisco Preference"
    neighborhoodResidence: "Neighborhood Resident Housing Preference (NRHP)"
    assistedHousing: "Rent Burdened / Assisted Housing Preference"
    rentBurden: "Rent Burdened / Assisted Housing Preference"
    antiDisplacement: "Anti-Displacement Housing Preference (ADHP)"
    aliceGriffith: "Alice Griffith Housing Development Resident"

  # Create a mapping to Salesforce naming conventions
  Service.RESERVED_TYPES = {
    VETERAN: 'Veteran'
    DISABLED: 'Developmental disabilities'
    SENIOR: 'Senior'
  }

  return Service


############################################################################################
######################################## CONFIG ############################################
############################################################################################

ListingConstantsService.$inject = []

angular
  .module('dahlia.services')
  .service('ListingConstantsService', ListingConstantsService)
