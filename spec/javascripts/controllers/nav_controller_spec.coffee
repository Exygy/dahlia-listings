do ->
  'use strict'
  describe 'NavController', ->
    fakeWindow = {}
    fakeWindow['env'] = {showSaleListings: 'true'}
    fakeDocument = {}
    scope = undefined
    state = undefined
    fakeTimeout = {}
    fakeTranslate =
      instant: ->
    fakeModalService =
      alert: ->

    beforeEach module('dahlia.controllers', ($provide) ->
      $provide.value 'ModalService', fakeModalService
      $provide.value '$window', fakeWindow
      return
    )

    beforeEach inject(($rootScope, $controller) ->
      state = jasmine.createSpyObj('$state', ['go'])
      scope = $rootScope.$new()
      $controller 'NavController',
        $document: fakeDocument
        $scope: scope
        $state: state
        $timeout: fakeTimeout
        $translate: fakeTranslate
      return
    )

    describe 'blank test that needs to be filled out!', ->
      it 'runs a blank test. add some tests!', ->
        return null


