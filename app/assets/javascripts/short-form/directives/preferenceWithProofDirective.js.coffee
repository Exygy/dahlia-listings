angular.module('dahlia.directives')
.directive 'preferenceWithProof', ->
  scope: true
  templateUrl: 'short-form/directives/preference-with-proof.html'

  link: (scope, elem, attrs) ->
    scope.title = attrs.title
    scope.description = attrs.translatedDescription
    scope.shortDescription = attrs.translatedShortDescription
    scope.uploaderLabel = attrs.uploaderLabel
    scope.buttonLabel = attrs.buttonLabel
    scope.preference = attrs.preference
    scope.pref_data_event = attrs.dataevent
    scope.required = attrs.required
    # allows a hardcoded proof option, e.g. "Copy of Lease" rather than showing the selector
    scope.proofOption = attrs.proofOption

    scope.reset_preference_data = (preference) ->
      scope.preferences["#{preference}_household_member"] = null
      # set proof_option to hardcoded value if present
      scope.preferences["#{preference}_proof_option"] = scope.proofOption || null
      scope.cancelOptOut(preference)
      scope.deletePreferenceFile(preference)
