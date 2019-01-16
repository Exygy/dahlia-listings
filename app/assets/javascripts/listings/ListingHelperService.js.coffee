############################################################################################
####################################### SERVICE ############################################
############################################################################################

ListingHelperService = (ListingService) ->
  Service = {}

  Service.priorityLabel = (priority, modifier) ->
    labelMap =
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

    return priority unless labelMap[priority]
    return labelMap[priority][modifier]


  Service.reservedLabel = (listing, type,  modifier) ->
    labelMap =
      "#{ListingService.RESERVED_TYPES.SENIOR}":
        building: 'Senior'
        eligibility: 'Seniors'
        reservedFor: "seniors #{Service.seniorMinimumAge(listing)}"
        reservedForWhoAre: "seniors #{Service.seniorMinimumAge(listing)}"
        unitDescription: "seniors #{Service.seniorMinimumAge(listing)}"
      "#{ListingService.RESERVED_TYPES.VETERAN}":
        building: 'Veterans'
        eligibility: 'Veterans'
        reservedFor: 'veterans'
        reservedForWhoAre: 'veterans'
        unitDescription: 'veterans of the U.S. Armed Forces'
      "#{ListingService.RESERVED_TYPES.DISABLED}":
        building: 'Developmental Disability'
        eligibility: 'People with developmental disabilities'
        reservedFor: 'people with developmental disabilities'
        reservedForWhoAre: 'developmentally disabled'
        unitDescription: 'people with developmental disabilities'

    return type unless labelMap[type]
    return labelMap[type][modifier]

  Service.seniorMinimumAge = (listing) ->
    if listing.Reserved_community_minimum_age
      "#{listing.Reserved_community_minimum_age}+"
    else
      ''

  Service.formattedAddress = (listing, type='Building', display='full') ->
    street = "#{type}_Street_Address"
    zip = "#{type}_Postal_Code"
    if type == 'Leasing_Agent'
      street = "#{type}_Street"
      zip = "#{type}_Zip"
    else if type == 'Building'
      zip = "#{type}_Zip_Code"

    # If Street address is undefined, then return false for display and google map lookup
    if listing[street] == undefined
      return
    # If other fields are undefined, proceed, with special string formatting
    if listing[street] != undefined
      Street_Address = listing[street] + ', '
    else
      Street_Address = ''
    if listing["#{type}_City"] != undefined
      City = listing["#{type}_City"]
    else
      City = ''
    if listing["#{type}_State"] != undefined
      State = listing["#{type}_State"]
    else
      State = ''
    if listing[zip] != undefined
      Zip_Code = listing[zip]
    else
      Zip_Code = ''

    if display == 'street'
      return "#{Street_Address}"
    else if display == 'city-state-zip'
      return "#{City} #{State}, #{Zip_Code}"
    else
      "#{Street_Address}#{City} #{State}, #{Zip_Code}"

  return Service

############################################################################################
######################################## CONFIG ############################################
############################################################################################

ListingHelperService.$inject = ['ListingService']

angular
  .module('dahlia.services')
  .service('ListingHelperService', ListingHelperService)
