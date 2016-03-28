Backbone = require('backbone')
BackboneValidation = require('backbone-validation')
_ = require('lodash')
#$ = require('jquery')
require('expose?$!expose?jQuery!jquery');
require("bootstrap-webpack!./bootstrap.config.js");

NewPlateDesignController = require('./NewPlateDesignController.coffee').NewPlateDesignController
NEW_PLATE_DESIGN_CONTROLLER_EVENTS = require('./NewPlateDesignController.coffee').NEW_PLATE_DESIGN_CONTROLLER_EVENTS

CreatePlateController = require('./CreatePlateController.coffee').CreatePlateController
CREATE_PLATE_CONTROLLER_EVENTS = require('./CreatePlateController.coffee').CREATE_PLATE_CONTROLLER_EVENTS
CreatePlateSaveController = require('./CreatePlateSaveController.coffee').CreatePlateSaveController
PlateModel = require('./PlateModel.coffee').PlateModel

DataServiceController = require('./DataServiceController.coffee').DataServiceController
IdentifierValidationController = require('./IdentifierValidationController.coffee').IdentifierValidationController
LoadPlateController = require('./LoadPlateController.coffee').LoadPlateController

APP_CONTROLLER_EVENTS = {}

class AppController extends Backbone.View
  template: _.template(require('html!./AppView.tmpl'))

  initialize: ->
    @newPlateDesignController = new NewPlateDesignController()
    @listenTo @newPlateDesignController, NEW_PLATE_DESIGN_CONTROLLER_EVENTS.ADD_CONTENT, @handleAddContent
    @listenTo @newPlateDesignController, NEW_PLATE_DESIGN_CONTROLLER_EVENTS.ADD_CONTENT_FROM_TABLE, @handleAddContentFromTable

    @createPlateController = new CreatePlateController({model: new PlateModel()})
    @listenTo @createPlateController, CREATE_PLATE_CONTROLLER_EVENTS.CREATE_PLATE, @handleCreatePlate
    @dataServiceController = new DataServiceController()

  completeInitialization: =>
    #@newPlateDesignController.completeInitialization()

  handleCreatePlate: (plateModel) =>
    @dataServiceController.setupService(new CreatePlateSaveController({plateModel: plateModel, successCallback: @createPlateController.handleSuccessfulSave}))
    @dataServiceController.doServiceCall()
#    @dataServiceController.doServiceCall((resp) ->
#      console.log "save callback"
#      console.log resp
#    )

  handleAddContent: (addContentModel) =>
    console.log "identifiers"
    console.log addContentModel

    @dataServiceController.setupService(new IdentifierValidationController({addContentModel: addContentModel, successCallback: @newPlateDesignController.handleAddContentSuccessCallback}))
    @dataServiceController.doServiceCall(@handleAddContentSuccess)

    #alert "add content..."

  handleAddContentFromTable: (addContentModel) =>
    console.log "identifiers"
    console.log addContentModel

    @dataServiceController.setupService(new IdentifierValidationController({addContentModel: addContentModel, successCallback: @newPlateDesignController.handleAddContentFromTableSuccessCallback}))
    @dataServiceController.doServiceCall()

  handleAddContentSuccess: () =>
    @newPlateDesignController.handleAddContentSuccessCallback()
    @newPlateDesignController.completeInitialization()


  displayCreatePlateForm: =>
    @$("div[name='formContainer']").html @createPlateController.render().el

  displayPlateDesignForm: (plateBarcode) =>
    @dataServiceController.setupService(new LoadPlateController({plateBarcode: plateBarcode, successCallback: @handleAllDataLoadedForPlateDesignForm}))
    @dataServiceController.doServiceCalls()

  handleAllDataLoadedForPlateDesignForm: (plateAndWellData) =>
    console.log "handleAllDataLoadedForPlateDesignForm"
    console.log plateAndWellData
    @$("div[name='formContainer']").html @newPlateDesignController.render().el
    @newPlateDesignController.completeInitialization(plateAndWellData)

  render: =>
    $(@el).html @template()

    @$("div[name='dataServiceControllerContainer']").html @dataServiceController.render().el

    @



module.exports =
  AppController: AppController