############################################################################################
####################################### SERVICE ############################################
############################################################################################

# This service contains functions that check properties of a listing to determine
# whether the listing is or is not a certain kind of listing.
#
# TODO: It's not fully clear that this service needs to be a separate service.
# Look further into where/how the functions in this service are used to see if
# there is a reasonable alternative way to manage these functions.
ListingIdentityService = (ListingConstantsService) ->
  Service = {}

  # Business logic for determining if a listing is open
  # `due date` should be a datetime, to include precise hour of deadline
  Service.isOpen = (listing) ->
    return false unless listing && listing.application_due_date
    now = moment()
    deadline = moment(listing.application_due_date).tz('America/Los_Angeles')
    # listing is open if deadline is in the future
    return deadline > now

  return Service

############################################################################################
######################################## CONFIG ############################################
############################################################################################

ListingIdentityService.$inject = ['ListingConstantsService']

angular
  .module('dahlia.services')
  .service('ListingIdentityService', ListingIdentityService)
