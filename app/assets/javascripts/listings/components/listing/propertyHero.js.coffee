angular.module('dahlia.components')
.component 'propertyHero',
  templateUrl: 'listings/components/listing/property-hero.html'
  require:
    parent: '^listingContainer'
  controller: [
    'ListingDataService', 'ListingUnitService', '$sce', '$timeout', '$window',
    (ListingDataService, ListingUnitService, $sce, $timeout, $window) ->
      ctrl = @

      @$onInit = ->
        ctrl.carouselHeight = 300

      @isLoadingUnits = () ->
        ListingUnitService.loading.units

      @hasUnitsError = () ->
        ListingUnitService.error.units

      @adjustCarouselHeight = (elem) ->
        $timeout ->
          ctrl.carouselHeight = elem[0].offsetHeight
        , 0, false

      @reservedUnitIcons = [
        $sce.trustAsResourceUrl('#i-star')
        $sce.trustAsResourceUrl('#i-cross')
        $sce.trustAsResourceUrl('#i-oval')
        $sce.trustAsResourceUrl('#i-polygon')
      ]

      @listingImages = (listing) ->
        # TODO: update when we are getting multiple images from Salesforce
        # right now it's just an array of one
        [listing.image_url]

      @hasMultipleAMIUnits = ->
        _.keys(this.parent.listing.groupedUnits).length > 1

      @reservedDescriptorIcon = (listing, descriptor) ->
        index = _.findIndex(listing.reserved_descriptor, ['name', descriptor])
        @reservedUnitIcons[index]

      return ctrl
  ]
