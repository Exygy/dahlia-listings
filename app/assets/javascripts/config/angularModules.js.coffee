# Custom Directives
angular.module('dahlia.directives', ['pageslide-directive', 'ngTextTruncate'])
# Service and Controller modules
angular.module('dahlia.services', ['ngStorage'])
angular.module('dahlia.controllers',['ngSanitize', 'angular-carousel', 'ngFileUpload'])
angular.module('dahlia.components', [])

# Raven must be configured before including `ngRaven` module below
# SENTRY_JS_URL is defined globally in application.html.slim

if SENTRY_JS_URL?
  Raven
    .config(SENTRY_JS_URL)
    .addPlugin(Raven.Plugins.Angular)
    .install()

@dahlia = angular.module 'dahlia', [
  'dahlia.components',
  'dahlia.controllers',
  'dahlia.directives',
  'dahlia.services',
  # filters
  'customFilters',
  'ng-currency',
  # dependencies
  'angular-carousel',
  'angular-clipboard',
  'angular-uuid',
  'angular.filter',
  'bsLoadingOverlay',
  'duScroll',
  'http-etag',
  'linkify',
  'mm.foundation',
  'ngAria',
  'ngIdle',
  'ngMessages',
  'ngMeta',
  'ngRaven',
  'pascalprecht.translate',
  'templates',
  'ui.mask',
  'ui.router.title',
  'ui.router',
  'ui.validate'
]
