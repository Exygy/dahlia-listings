GoogleTranslateService = ($q, $timeout) ->
  Service = {}
  Service.URL = '//translate.google.com/translate_a/element.js?cb=initGoogleTranslate'
  Service.translateElement = {}
  Service.loaded = false
  Service.language = 'en'

  Service.loadAPI = ->
    deferred = $q.defer()
    unless Service.loaded
      window['initGoogleTranslate'] = ->
        Service.init()
        Service.loaded = true
        deferred.resolve(window.google.translate)
      Service.loadScript()
    else
      deferred.resolve()

    deferred.promise

  Service.loadScript = ->
    node = document.createElement('script')
    node.src = Service.URL
    node.type = 'text/javascript'
    document.getElementsByTagName('head')[0].appendChild(node)

  Service.setLanguage = (language) ->
    Service.language = language
    googleTranslateOption = document.querySelector(".goog-te-combo option[value=\"#{language}\"]")
    if googleTranslateOption
      googleTranslateOption.selected = true
      event = new Event('change',
          'bubbles': true
          'cancelable': true
      )
      googleTranslateOption.dispatchEvent(event)
    else
      $timeout Service.setLanguage, 100, true, language

  Service.init = ->
    Service.translateElement = new window.google.translate.TranslateElement(
      pageLanguage: 'en'
      includedLanguages: 'en,es,tl,zh-TW'
      layout: window.google.translate.TranslateElement.InlineLayout.HORIZONTAL
      autoDisplay: false
      multilanguagePage: true
      gaTrack: true
      gaId: 'UA-71549528-1'
    , 'google_translate_element')

  Service

GoogleTranslateService.$inject = ['$q', '$timeout']

angular
  .module('dahlia.services')
  .service('GoogleTranslateService', GoogleTranslateService)
