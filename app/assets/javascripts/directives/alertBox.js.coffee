angular.module('dahlia.directives')
.directive 'alertBox', ['$translate', '$state', ($translate, $state) ->
  restrict: 'E'
  scope:
    customMessage: '=?'
    customSubMessage: '=?'
    hideAlert: '=?'
    info: '=?'
    invert: '=?'
    primary: '=?'

  templateUrl: 'directives/alert-box.html'

  link: (scope, elem, attrs) ->
    scope.showAlert = ->
      if scope.customMessage
        return scope.hideAlert == false
      else
        return true

    scope.alertText = ->
      if scope.customMessage
        return scope.customMessage
      else
        return "This alert does not have a message."

    scope.close = (e) ->
      e.preventDefault()
      scope.hideAlert = true

    scope.getStyles = ->
      styles = ''
      if scope.invert
        styles += 'invert no-margin '
      if scope.primary
        styles += 'primary '
        unless scope.info
          styles += 'no-icon '
      styles

    scope.isIconInverted = ->
      if !scope.invert
        return 'i-oil'
]
