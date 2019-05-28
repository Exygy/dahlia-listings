angular.module('dahlia.components')
.component 'legalSection',
  templateUrl: 'listings/components/listing/legal-section.html'
  require:
    parent: '^listingContainer'
