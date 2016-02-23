$ = require('jquery')
$ ->
  require('css!./plateReg.css')
  $ = require('jquery')

  AppRouter = require('./AppRouter.coffee').AppRouter

  new AppRouter
  Backbone.history.start()

#  AppController = require('./AppController.coffee').AppController
#  appController = new AppController()
#
#  $("#app-container").html appController.render().el
#  appController.completeInitialization()
  #newPlateDesignController.delegateEvents()