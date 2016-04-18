Backbone = require('backbone')

#DataServiceController = require('./DataServiceController.coffee').DataServiceController

AppController = require('./AppController.coffee').AppController
appController = new AppController()

$("#app-container").html appController.render().el
appController.completeInitialization()

class AppRouter extends Backbone.Router
  routes:
    "": "createPlateRoute"
    "createPlate": "createPlateRoute"
    "plateDesign/:plateCodeName": "plateDesignRoute"
    "plateSearch": "plateSearchRoute"

  plateDesignRoute: (plateBarcode) ->
    appController.displayPlateDesignForm(plateBarcode)

  createPlateRoute: ->
    appController.displayCreatePlateForm()

  plateSearchRoute: ->
    appController.displayPlateSearch()


module.exports =
  AppRouter: AppRouter
