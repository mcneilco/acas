$ = require('jquery')
$ ->
  require('css!./plateReg.css')
  $ = require('jquery')

  AppRouter = require('./AppRouter.coffee').AppRouter

  new AppRouter
  Backbone.history.start()