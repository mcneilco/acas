$ = require('jquery')
$ ->
  $ = require('jquery')

  AppRouter = require('./AppRouter.coffee').AppRouter

  window.appRouter = new AppRouter
  Backbone.history.start()