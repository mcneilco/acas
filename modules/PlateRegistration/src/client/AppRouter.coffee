Backbone = require('backbone')

AppController = require('./AppController.coffee').AppController
appController = new AppController()

$("#app-container").html appController.render().el
appController.completeInitialization()

class AppRouter extends Backbone.Router
  routes:
    "createPlate": "createPlateRoute"
    "plateDesign": "plateDesignRoute"

  plateDesignRoute: ->
    appController.displayPlateDesignForm()

  createPlateRoute: ->
    appController.displayCreatePlateForm()


module.exports =
  AppRouter: AppRouter
