do ->
  'use strict'
  describe 'Unit Summary Accordion Component', ->
    $componentController = undefined
    ctrl = undefined
    locals = undefined
    $translate =
      instant: ->

    beforeEach module('dahlia.components')
    beforeEach inject((_$componentController_) ->
      $componentController = _$componentController_
      locals = {
        $translate: $translate
      }
    )

    describe 'unitSummaryAccordion', ->
      beforeEach ->
        ctrl = $componentController 'unitSummaryAccordion', locals

      describe 'formatBaths', ->
        describe 'when the given number of bathrooms is 0', ->
          it 'returns "Shared"', ->
            expect(ctrl.formatBaths(0)).toEqual('Shared')
        describe 'when the given number of bathrooms is 0.5', ->
          it 'returns "1/2 " plus the translation of the key "LISTINGS.BATH"', ->
            spyOn($translate, 'instant').and.returnValue('baths')
            output = ctrl.formatBaths(0.5)
            expect($translate.instant).toHaveBeenCalledWith('LISTINGS.BATH')
            expect(output).toEqual('1/2 ' + $translate.instant('LISTINGS.BATH'))
        describe 'when the given number of bathrooms is neither 0 nor 0.5', ->
          describe 'and it is a decimal of the format X.5', ->
            it 'returns a string consisting of the floor of the given number, plus " 1/2 ", plus the translation of the key "LISTINGS.BATH"', ->
              spyOn($translate, 'instant').and.returnValue('baths')
              output = ctrl.formatBaths(1.5)
              expect($translate.instant).toHaveBeenCalledWith('LISTINGS.BATH')
              expect(output).toEqual('1 1/2 ' + $translate.instant('LISTINGS.BATH'))
          describe 'and it is not a decimal of the format X.5', ->
            it 'returns the given number', ->
              expect(ctrl.formatBaths(1)).toEqual(1)
