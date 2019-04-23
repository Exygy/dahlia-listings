do ->
  'use strict'
  describe 'SharedService', ->
    SharedService = undefined
    httpBackend = undefined
    $state = undefined
    $window = undefined
    $document = undefined

    beforeEach module('ui.router')
    beforeEach module('dahlia.services', ($provide) ->
    )

    beforeEach inject((_SharedService_, _$httpBackend_, _$state_, _$window_, _$document_) ->
      httpBackend = _$httpBackend_
      $state = _$state_
      $window = _$window_
      $window.STATIC_ASSET_PATHS = {}
      $document = _$document_
      SharedService = _SharedService_
      return
    )

    describe 'toQueryString', ->
      it 'returns a query-string-formatted version of the given params', ->
        params = {foo: 1, bar: 2}
        queryString = 'foo=1&bar=2'
        expect(SharedService.toQueryString(params)).toEqual queryString
