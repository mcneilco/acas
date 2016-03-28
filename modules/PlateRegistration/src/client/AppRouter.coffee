Backbone = require('backbone')

#DataServiceController = require('./DataServiceController.coffee').DataServiceController

AppController = require('./AppController.coffee').AppController
appController = new AppController()

$("#app-container").html appController.render().el
appController.completeInitialization()

class AppRouter extends Backbone.Router
  routes:
    "createPlate": "createPlateRoute"
    "plateDesign/:plateCodeName": "plateDesignRoute"
    "": "createPlateRoute"

  plateDesignRoute: (plateBarcode) ->
    console.log "plateBarcode"
    console.log plateBarcode
    appController.displayPlateDesignForm(plateBarcode)

    #

  createPlateRoute: ->
    appController.displayCreatePlateForm()


module.exports =
  AppRouter: AppRouter
