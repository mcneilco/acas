$ = require('jquery')
$ ->
  require('css!./plateReg.css')
  $ = require('jquery')

  AppRouter = require('./AppRouter.coffee').AppRouter

  window.appRouter = new AppRouter
  Backbone.history.start()