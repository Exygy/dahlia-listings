angular.module('dahlia.components')
.component 'favoritesComponent',
  templateUrl: 'listings/components/favorites-component.html'
  require:
    parent: '^listingContainer'
