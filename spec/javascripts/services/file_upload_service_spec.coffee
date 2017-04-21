do ->
  'use strict'
  describe 'FileUploadService', ->
    FileUploadService = undefined
    fakeShortFormApplicationService =
      preferences: {
        documents: {
          liveInSf: {}
        }
      }
    $translate = {}
    Upload =
      upload: ->
    uuid = {v4: jasmine.createSpy()}
    success = { success: true }
    httpBackend = undefined
    fakeFile = {name: 'img.jpg'}
    prefType = 'liveInSf'

    beforeEach module('dahlia.services', ($provide)->
      $provide.value '$translate', $translate
      $provide.value 'Upload', Upload
      $provide.value 'uuid', uuid
      $provide.value 'ShortFormApplicationService', fakeShortFormApplicationService
      return
    )

    beforeEach inject((_$httpBackend_, _FileUploadService_, _$q_) ->
      httpBackend = _$httpBackend_
      FileUploadService = _FileUploadService_
      FileUploadService.preferences = fakeShortFormApplicationService.preferences
      FileUploadService.session_uid = -> '123'
      $q = _$q_
      spyOn(Upload, 'upload').and.callFake ->
        deferred = $q.defer()
        deferred.resolve {data: fakeFile}
        deferred.promise
      return
    )

    describe 'Service setup', ->
      it 'initializes session_uid', ->
        expect(FileUploadService.session_uid).not.toEqual null

    describe 'Service.uploadProof', ->
      it 'calls Upload.upload function', ->

        FileUploadService.uploadProof(fakeFile, prefType)
        expect(Upload.upload).toHaveBeenCalled()

    describe 'Service.deletePreferenceFile', ->
      afterEach ->
        httpBackend.verifyNoOutstandingExpectation()
        httpBackend.verifyNoOutstandingRequest()

      it 'unsets FileUploadService prefType_proof_file', ->
        stubAngularAjaxRequest httpBackend, '/api/v1/short-form/proof', success
        FileUploadService.preferences.documents[prefType].file = fakeFile
        FileUploadService.deletePreferenceFile(prefType)
        httpBackend.flush()
        expect(FileUploadService.preferences.documents[prefType].file).toEqual null

    describe 'Service.rentBurdenFile', ->
      beforeEach ->
        FileUploadService.preferences =
          documents:
            rentBurden:
              '123 Main St':
                lease: 'lease file'
                rent:
                  1: 'rent file'
      describe 'lease file', ->
        it 'returns the correct lease file', ->
          opts =
            address: '123 Main St'
            rentBurdenType: 'lease'
          expect(FileUploadService.rentBurdenFile(opts)).toEqual('lease file')

      describe 'rent file', ->
        it 'returns the correct rent file', ->
          opts =
            address: '123 Main St'
            rentBurdenType: 'rent'
            index: 1
          expect(FileUploadService.rentBurdenFile(opts)).toEqual('rent file')

    describe 'Service.clearRentBurdenFile', ->
      beforeEach ->
        FileUploadService.preferences =
          documents:
            rentBurden:
              '123 Main St':
                lease: {}

      it 'clears pertinent file', ->
        opts =
          address: '123 Main St'
          rentBurdenType: 'lease'
        FileUploadService.clearRentBurdenFile(opts)
        leaseFile = FileUploadService.preferences.documents.rentBurden['123 Main St'].lease
        expect(leaseFile).toEqual {}

    describe 'Service.clearRentBurdenFiles', ->
      beforeEach ->
        FileUploadService.preferences =
          documents:
            rentBurden:
              '123 Main St':
                lease: {this: 'some file'}
                rent:
                  1: {this: 'some file'}

      it 'clears all rent burden files', ->
        FileUploadService.clearRentBurdenFiles('123 Main St')
        rentBurdenFiles = FileUploadService.preferences.documents.rentBurden['123 Main St']
        expectedResult = { lease: {  }, rent: {  } }
        expect(rentBurdenFiles).toEqual expectedResult

    describe 'Service.deleteRentBurdenPreferenceFiles', ->
      afterEach ->
        httpBackend.verifyNoOutstandingExpectation()
        httpBackend.verifyNoOutstandingRequest()

      beforeEach ->
        FileUploadService.preferences =
          documents:
            rentBurden:
              '123 Main St':
                lease: {this: 'some file'}
                rent:
                  1: {this: 'some file'}

      it 'should delete all rent burden preference files', ->
        stubAngularAjaxRequest httpBackend, "/api/v1/short-form/rent-burden-proof", 200
        FileUploadService.deleteRentBurdenPreferenceFiles('listingID')
        httpBackend.flush()
        expectedResult = { lease: {  }, rent: {  } }
        rentBurdenFiles = FileUploadService.preferences.documents.rentBurden['123 Main St']
        expect(rentBurdenFiles).toEqual expectedResult
