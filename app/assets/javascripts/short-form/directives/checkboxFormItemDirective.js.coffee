angular.module('dahlia.directives')
.directive 'checkboxFormItem', ->
  replace: true
  scope: true
  templateUrl: 'short-form/directives/checkbox-form-item.html'

  link: (scope, elem, attrs) ->
    scope.name = attrs.name
    scope.option = attrs.option
    scope.label = attrs.label || attrs.option
    scope.user = scope[attrs.user || 'applicant']
    scope.isDisabled = scope[attrs.isDisabled]
    scope.id = "#{attrs.name}_#{_.kebabCase(attrs.option)}"