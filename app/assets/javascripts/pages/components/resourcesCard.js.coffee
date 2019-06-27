angular.module('dahlia.components')
.component 'resourcesCard',
  templateUrl: 'pages/components/resources-card.html'
  bindings:
    title: '@'
    description: '@'
    region: '@'
    link: '@'
  controller: [ '$translate', ($translate) ->
    ctrl = @
  ]