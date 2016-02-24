Backbone = require('backbone')

AppController = require('./AppController.coffee').AppController
appController = new AppController()

$("#app-container").html appController.render().el
appController.completeInitialization()

class AppRouter extends Backbone.Router
  routes:
    "createPlate": "createPlateRoute"
    "plateDesign/:plateCodeName": "plateDesignRoute"

  plateDesignRoute: (plateCodeName) ->
    console.log "plateCodeName"
    console.log plateCodeName
    appController.displayPlateDesignForm()

  createPlateRoute: ->
    appController.displayCreatePlateForm()


module.exports =
  AppRouter: AppRouter
