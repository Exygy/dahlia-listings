'use strict';
module.exports = function(grunt) {

  grunt.initConfig({

  // Define our Pattern Library and Application Assets paths
  applicationAssetsPath: 'app/assets',
  patternLibraryPath: '../sf-dahlia-pattern-library',

  // Delete the old toolkit.css
  clean: {
    css: ['<%= applicationAssetsPath %>/stylesheets/toolkit.css']
  },

  //Copy the latest compiled toolkit.css file from the pattern library into our app
  copy: {
    main: {
      files: [
        {
          src: '<%= patternLibraryPath %>/dist/assets/toolkit/styles/toolkit.css',
          dest: '<%= applicationAssetsPath %>/stylesheets/toolkit.scss'
        }
      ],
    },
  },

  //Make any string replacements that are needed when transfering assets to app.
  replace: {
    dist: {
      options: {
        patterns: [
          {
            match: 'http://fonts.googleapis.com',
            replacement: '//fonts.googleapis.com'
          },
          {
            match: /"\.\.\/images\/([a-zA-Z0-9\-_]*\.(png|jpg|svg))"/g,
            replacement: "asset-path('$1')"
          }
        ],
        usePrefix: false
      },
      files: [
        {
          expand: true, flatten: true,
          src: ['<%= applicationAssetsPath %>/stylesheets/toolkit.scss'],
          dest: '<%= applicationAssetsPath %>/stylesheets/'
        }
      ]
    }
  },

  i18nextract: {
    default_options: {
      src: [
        'app/assets/javascripts/**/*.js',
        'app/assets/javascripts/**/*.js.coffee',
        'app/assets/javascripts/**/*.html',
        'app/assets/javascripts/**/*.html.slim',
        'app/views/layouts/application.html.slim'
      ],
      customRegex: [
         '\{\{\\s*(?:::)?\'((?:\\\\.|[^\'\\\\])*)\'\\s*\\|\\s*translate(:.*?)?\\s*(?:\\s*\\|\\s*[a-zA-Z]*)?\}\}',
         '="\'((?:\\\\.|[^\'\\\\])*)\'\\s*\\|\\s*translate"',
         'translated-error="([A-Z\.\-\_]*)"',
         'translated-description="([A-Z\.\-\_]*)"',
         'translated-short-description="([A-Z\.\-\_]*)"',
         'translatedLabel: \'([A-Z\.\-\_]*)\'',
         /\', t\(\'([A-Z\.\-\_]*)\'\)/
       ],
      namespace: true,
      lang:     ['locale-en'],
      dest:     'app/assets/json/translations'
    }
  },
  json_remove_fields: {
    locale_es: {
        src: 'app/assets/json/translations/locale-es.json'
    },
    locale_tl: {
        src: 'app/assets/json/translations/locale-tl.json'
    },
    locale_zh: {
        src: 'app/assets/json/translations/locale-zh.json'
    }
  },
  sortJSON: {
    src: [
      'app/assets/json/translations/locale-en.json',
      'app/assets/json/translations/locale-es.json',
      'app/assets/json/translations/locale-tl.json',
      'app/assets/json/translations/locale-zh.json'
    ],
    // options: {
    //   spacing: 2
    // }
  },
});

  // load tasks
  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-replace');
  grunt.loadNpmTasks('grunt-angular-translate');
  grunt.loadNpmTasks('grunt-sort-json');
  grunt.loadNpmTasks('grunt-json-remove-fields');


  // register task
  grunt.registerTask('default', [
    'clean',
    'copy',
    'replace'
  ]);

  grunt.registerTask('translations', [
    'i18nextract',
    'json_remove_fields',
    'sortJSON',
  ]);

  grunt.registerTask('deploy', [
    'clean',
    'copy',
    'replace'
  ]);

};
