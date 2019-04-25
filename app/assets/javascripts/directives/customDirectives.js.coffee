angular.module('dahlia.directives')
.directive 'adjustCarouselHeight', ['$window', ($window) ->
  link: (scope, elem, attrs) ->
    ## REFACTOR TO DO: Fix this in propertyHero
    elem.bind 'load', ->
      scope.$ctrl.adjustCarouselHeight(elem)

    # to support resize of the carousel after you resize your window
    angular.element($window).bind 'resize', ->
      scope.$ctrl.adjustCarouselHeight(elem)
]
.directive 'ngModel', ->
  link: (scope, element, attrs) ->
    return unless scope.inputInvalid
    element.attr 'aria-invalid', scope.inputInvalid(attrs.name)
    scope.$watch (->
      scope.inputInvalid attrs.name
    ), (newVal) ->
      element.attr 'aria-invalid', newVal
.directive 'target', ->
  link: (scope, elem, attrs) ->
    if attrs.target == '_blank'
      elem.attr('aria-label', 'Opens in new window')

