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

    httpConfig = { etagCache: true }
    httpConfig.params = { force: true } if forceRecache
    $http.get("/api/v1/listings/#{listing.id}/preferences", httpConfig)
    .success((data, status, headers, config) ->
      if data && data.preferences
        listing.preferences = data.preferences
        Service.loading.preferences = false
    ).error( (data, status, headers, config) ->
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
