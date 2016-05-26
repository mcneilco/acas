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
    "mergeOrSplitPlates": "mergeOrSplitPlates"
    "mergePlates": "mergePlates"
    "splitPlates": "splitPlates"

  plateDesignRoute: (plateBarcode) ->
    appController.displayPlateDesignForm(plateBarcode)

  createPlateRoute: ->
    appController.displayCreatePlateForm()

  plateSearchRoute: ->
    appController.displayPlateSearch()

  mergeOrSplitPlates: ->
    appController.displayMergeOrSplitPlatesForm()

  mergePlates: ->
    appController.displayMergePlatesForm()

  splitPlates: ->
    appController.displaySplitPlatesForm()

module.exports =
  AppRouter: AppRouter
