FileUploadService = ($http, $q, Upload, uuid, ListingService) ->
  Service = {}
  # these are to be overridden
  Service.preferences = {}
  Service.session_uid = -> null

  Service.hasPreferenceFile = (fileType) ->
    Service.preferences[fileType] && !Service.preferenceFileIsLoading(fileType)

  Service.deletePreferenceFile = (pref_type, listing_id, opts = {}) ->
    pref = ListingService.getPreference(pref_type)
    # might be calling deletePreferenceFile on a preference that this listing doesn't have
    pref_id = if pref then pref.listingPreferenceID else pref_type
    return $q.reject() unless ListingService.getPreferenceById(pref_id)
    params =
      uploaded_file:
        session_uid: Service.session_uid()
        listing_id: listing_id
        listing_preference_id: pref_id

    if opts.rentBurdenType
      params.uploaded_file.rent_burden_type = opts.rentBurdenType
      params.uploaded_file.address = opts.address
      params.uploaded_file.rent_burden_index = opts.index
      proofDocument = Service.rentBurdenFile(opts)
    else
      proofDocument = Service.preferences.documents[pref_type]
    if _.isEmpty(proofDocument) || _.isEmpty(proofDocument.file)
      proofDocument.proofOption = null if proofDocument
      return $q.resolve()

    $http.delete('/api/v1/short-form/proof', {
      data: params,
      headers: {
        'Content-Type': 'application/json'
      },
    }).success((data, status, headers, config) ->
      # clear out fileObj
      if opts.rentBurdenType
        Service.clearRentBurdenFile(opts)
      else
        proofDocument.file = null
        proofDocument.proofOption = null
    ).error( (data, status, headers, config) ->
      return
    )

  Service._processProofFile = (file, upload) ->
    if file.size > 2 * 1000 * 1000 # 2MB
      options =
        width: 2112,
        height: 2112,
        quality: 0.8
      Upload.resize(file, options).then( (resizedFile) ->
        upload(resizedFile)
      )
    else
      upload(file)

  Service.uploadProof = (file, pref_type, listing_id, opts = {}) ->
    preference = ListingService.getPreference(pref_type)
    pref_id = if preference then preference.listingPreferenceID else pref_type
    return $q.reject() unless ListingService.getPreferenceById(pref_id)
    uploadedFileParams =
      session_uid: Service.session_uid()
      listing_id: listing_id
      listing_preference_id: pref_id

    if opts.rentBurdenType
      proofDocument = Service.rentBurdenFile(opts)
      uploadedFileParams.address = opts.address
      uploadedFileParams.rent_burden_type = opts.rentBurdenType
      uploadedFileParams.rent_burden_index = opts.index
    else
      Service.preferences.documents[pref_type] ?= {}
      proofDocument = Service.preferences.documents[pref_type]

    uploadedFileParams.document_type = proofDocument.proofOption

    if (!file)
      proofDocument.error = true
      return $q.reject()

    proofDocument.loading = true
    Service._processProofFile file, (resizedFile) ->
      if resizedFile.size > 5 * 1000 * 1000 # 5MB
        # error handler
        Service.preferences[fileType] = null
        Service.preferences["#{fileType}_loading"] = false
        Service.preferences["#{fileType}_error"] = true
      else
        uploadedFileParams.file = resizedFile
        Upload.upload(
          url: '/api/v1/short-form/proof'
          method: 'POST'
          data:
            uploaded_file: uploadedFileParams
        ).then( ((resp) ->
          proofDocument.loading = false
          proofDocument.error = false
          proofDocument.file = resp.data
        ), ((resp) ->
          # error handler
          proofDocument.loading = false
          proofDocument.error = true
        ))

  # Rent Burden specific functions
  Service.uploadedRentBurdenRentFiles = (address) ->
    addressFiles = Service.preferences.documents.rentBurden[address]
    if !_.isEmpty(addressFiles)
      rentFiles = addressFiles.rent
      _.filter(rentFiles, (file) -> !_.isEmpty(file.file))
    else
      []

  Service.rentBurdenFile = (opts) ->
    rentBurdenDocs = Service.preferences.documents.rentBurden[opts.address]
    return {} unless rentBurdenDocs
    if opts.rentBurdenType == 'lease'
      rentBurdenDocs.lease
    else
      rentBurdenDocs.rent[opts.index]

  Service.clearRentBurdenFile = (opts) ->
    rentBurdenDocs = Service.preferences.documents.rentBurden[opts.address]
    return unless rentBurdenDocs
    if opts.rentBurdenType == 'lease'
      angular.copy({}, rentBurdenDocs.lease)
    else
      # remove pref file at opts.index
      delete rentBurdenDocs.rent[opts.index]

  Service.hasRentBurdenFiles = (address = null) ->
    hasFiles = false
    if address
      docs = Service.preferences.documents.rentBurden[address]
      return false unless docs
      hasFiles = !!(docs.lease.file || _.some(_.map(docs.rent, 'file')))
    else
      _.map Service.preferences.documents.rentBurden, (doc, address) ->
        hasFiles = hasFiles || Service.hasRentBurdenFiles(address)
    return hasFiles

  Service.clearRentBurdenFiles = (address = null) ->
    if address
      rentBurdenDocs = Service.preferences.documents.rentBurden[address]
      angular.copy({}, rentBurdenDocs.lease)
      angular.copy({}, rentBurdenDocs.rent)
    else
      _.each Service.preferences.documents.rentBurden, (docs, address) ->
        rentBurdenDocs = Service.preferences.documents.rentBurden[address]
        angular.copy({}, rentBurdenDocs.lease)
        angular.copy({}, rentBurdenDocs.rent)

  Service.deleteRentBurdenPreferenceFiles = (listing_id, address = null) ->
    pref = ListingService.getPreference('rentBurden')
    return unless pref
    pref_id = pref.listingPreferenceID
    unless Service.hasRentBurdenFiles(address)
      return $q.resolve()
    params =
      uploaded_file:
        session_uid: Service.session_uid()
        listing_preference_id: pref_id
        listing_id: listing_id
    # if no address provided, we are deleting *all* rentBurdenFiles for this user/listing
    params.uploaded_file.address = address if address

    $http.delete('/api/v1/short-form/proof', {
      data: params,
      headers: {
        'Content-Type': 'application/json'
      },
    }).success((data, status, headers, config) ->
      # clear out fileObj
      Service.clearRentBurdenFiles(address)
    ).error( (data, status, headers, config) ->
      return
    )

  return Service

############################################################################################
######################################## CONFIG ############################################
############################################################################################

FileUploadService.$inject = [
  '$http', '$q', 'Upload', 'uuid', 'ListingService'
]

angular
  .module('dahlia.services')
  .service('FileUploadService', FileUploadService)
