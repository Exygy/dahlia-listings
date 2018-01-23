angular.module('dahlia.directives')
.directive 'communityScreeningHeader', ['$translate', ($translate) ->
  replace: true
  scope: true
  templateUrl: 'short-form/directives/community-screening-header.html'

  link: (scope, elem, attrs) ->
    listing = scope.listing
    restriction = listing.Reserved_Community_Requirement
    age = { minAge: listing.Reserved_community_minimum_age }

    switch listing.Reserved_community_type
      when 'Veteran'
        scope.title = $translate.instant('A2_COMMUNITY_SCREENING.VETERAN.YOU_OR_ANYONE')
        scope.description = $translate.instant('A2_COMMUNITY_SCREENING.VETERAN.YOU_OR_ANYONE_DESC')
        scope.labels.communityScreeningYes = $translate.instant('T.YES')
        scope.communityEligibilityErrorMsg.push($translate.instant('ERROR.VETERAN_ANYONE'))
      when 'Senior'
        if restriction == 'Entire household'
          scope.title = $translate.instant('A2_COMMUNITY_SCREENING.SENIOR.YOU_AND_EVERYONE')
          scope.description = $translate.instant('A2_COMMUNITY_SCREENING.SENIOR.YOU_AND_EVERYONE_DESC', age)
          scope.labels.communityScreeningYes = $translate.instant('A2_COMMUNITY_SCREENING.SENIOR.YOU_AND_EVERYONE_LABEL', age)
          scope.communityEligibilityErrorMsg.push($translate.instant('ERROR.SENIOR_EVERYONE', age))
        else
          scope.title = $translate.instant('A2_COMMUNITY_SCREENING.SENIOR.YOU_OR_ANYONE')
          scope.description = $translate.instant('A2_COMMUNITY_SCREENING.SENIOR.YOU_OR_ANYONE_DESC', age)
          scope.labels.communityScreeningYes = $translate.instant('A2_COMMUNITY_SCREENING.SENIOR.YOU_OR_ANYONE_LABEL', age)
          scope.communityEligibilityErrorMsg.push($translate.instant('ERROR.SENIOR_ANYONE', age))

]
