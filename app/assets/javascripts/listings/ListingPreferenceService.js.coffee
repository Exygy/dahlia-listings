############################################################################################
####################################### SERVICE ############################################
############################################################################################

ListingPreferenceService = ($http) ->
  Service = {}
  Service.loading = {}
  Service.error = {}

  Service.getListingPreferences = (listing, forceRecache = false) ->
    Service.loading.preferences = true
    # Reset preferences that might already exist
    angular.copy([], listing.preferences)
    Service.error.preferences = false

    httpConfig = { }
    httpConfig.params = { force: true } if forceRecache
    $http.get("/api/v1/listings/#{listing.id}/preferences", httpConfig)
    .then((response) ->
      data = response.data
      if data && data.preferences
        listing.preferences = data.preferences
        Service.loading.preferences = false
    ).catch((response) ->
      Service.loading.preferences = false
      Service.error.preferences = true
    )

  return Service


############################################################################################
######################################## CONFIG ############################################
############################################################################################

ListingPreferenceService.$inject = ['$http']

angular
  .module('dahlia.services')
  .service('ListingPreferenceService', ListingPreferenceService)
