// Karma configuration
// Generated on Wed Jan 20 2016 06:50:15 GMT-0700 (MST)

var webpack = require('webpack');

module.exports = function(config) {
  config.set({

    // base path that will be used to resolve all patterns (eg. files, exclude)
    basePath: '',


    // frameworks to use
    // available frameworks: https://npmjs.org/browse/keyword/karma-adapter
    frameworks: ['jasmine-jquery', 'jasmine'],


    // list of files / patterns to load in the browser
    files: [
      'build/public/compiled/spec.bundle.js'
    ],

    plugins: [ 'karma-chrome-launcher', 'karma-firefox-launcher', 'karma-jasmine-jquery', 'karma-jasmine', 'karma-sourcemap-loader', 'karma-webpack', 'karma-coverage'],


    // list of files to exclude
    exclude: [
    ],


    // preprocess matching files before serving them to the browser
    // available preprocessors: https://npmjs.org/browse/keyword/karma-preprocessor
    // list of preprocessors
    //preprocessors: {
    //  'public/compiled/spec.bundle.js': ['coverage']
    //},
    preprocessors: {
      'build/public/compiled/spec.bundle.js': ['webpack', 'coverage']
    },

    // test results reporter to use
    // possible values: 'dots', 'progress'
    // available reporters: https://npmjs.org/browse/keyword/karma-reporter
    reporters: ['progress', 'coverage'],
    webpack: {
      resolve: {
        extensions: ["", ".js", ".coffee"]
      },
      module: {
        loaders: [
          { test: /\.coffee$/, loader: "coffee-loader" }
        ]
      }
    },

    // web server port
    port: 9876,


    // enable / disable colors in the output (reporters and logs)
    colors: true,


    // level of logging
    // possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
    logLevel: config.LOG_INFO,


    // enable / disable watching file and executing tests whenever any file changes
    autoWatch: true,


    // start these browsers
    // available browser launchers: https://npmjs.org/browse/keyword/karma-launcher
    browsers: ['Firefox', 'Chrome', 'Safari'],


    // Continuous Integration mode
    // if true, Karma captures browsers, runs the tests and exits
    singleRun: false,

    // Concurrency level
    // how many browser should be started simultaneous
    concurrency: Infinity,
    coverageReporter: { type : 'html', dir : 'coverage1/' }
  })
}
