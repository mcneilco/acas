Backbone = require('backbone')
BackboneValidation = require('backbone-validation')
_ = require('lodash')
require('expose?$!expose?jQuery!jquery');
require("bootstrap-webpack!./bootstrap.config.js");

NewPlateDesignController = require('./NewPlateDesignController.coffee').NewPlateDesignController
NEW_PLATE_DESIGN_CONTROLLER_EVENTS = require('./NewPlateDesignController.coffee').NEW_PLATE_DESIGN_CONTROLLER_EVENTS

CreatePlateController = require('./CreatePlateController.coffee').CreatePlateController
CREATE_PLATE_CONTROLLER_EVENTS = require('./CreatePlateController.coffee').CREATE_PLATE_CONTROLLER_EVENTS
CreatePlateSaveController = require('./CreatePlateSaveController.coffee').CreatePlateSaveController
PlateTypeCollection = require('./PlateTypeCollection.coffee').PlateTypeCollection
PlateModel = require('./PlateModel.coffee').PlateModel

DataServiceController = require('./DataServiceController.coffee').DataServiceController
AddContentIdentifierValidationController = require('./IdentifierValidationController.coffee').AddContentIdentifierValidationController
PlateTableIdentifierValidationController = require('./IdentifierValidationController.coffee').PlateTableIdentifierValidationController
LoadPlateController = require('./LoadPlateController.coffee').LoadPlateController
PlateSearchController = require('./PlateSearchController.coffee').PlateSearchController

APP_CONTROLLER_EVENTS = {}

class AppController extends Backbone.View
  template: _.template(require('html!./AppView.tmpl'))

  initialize: ->
    @newPlateDesignController = new NewPlateDesignController()
    @listenTo @newPlateDesignController, NEW_PLATE_DESIGN_CONTROLLER_EVENTS.ADD_CONTENT, @handleAddContent
    @listenTo @newPlateDesignController, NEW_PLATE_DESIGN_CONTROLLER_EVENTS.ADD_IDENTIFIER_CONTENT_FROM_TABLE, @handleAddIdentifierContentFromTable

    @createPlateController = new CreatePlateController({model: new PlateModel(), plateTypes: new PlateTypeCollection()})
    @listenTo @createPlateController, CREATE_PLATE_CONTROLLER_EVENTS.CREATE_PLATE, @handleCreatePlate
    @dataServiceController = new DataServiceController()

    @plateSearchController = new PlateSearchController()

  completeInitialization: =>
    #@newPlateDesignController.completeInitialization()

  handleCreatePlate: (plateModel) =>
    @dataServiceController.setupService(new CreatePlateSaveController({plateModel: plateModel, successCallback: @createPlateController.handleSuccessfulSave}))
    @dataServiceController.doServiceCall()

  handleAddContent: (addContentModel) =>
    @dataServiceController.setupService(new AddContentIdentifierValidationController({addContentModel: addContentModel, successCallback: @newPlateDesignController.handleAddContentSuccessCallback}))
    @dataServiceController.doServiceCall(@handleAddContentSuccess)

  handleAddIdentifierContentFromTable: (addContentModel) =>
    @dataServiceController.setupService(new PlateTableIdentifierValidationController({addContentModel: addContentModel, successCallback: @newPlateDesignController.handleAddContentFromTableSuccessCallback, mode: "plateTable"}))
    @dataServiceController.doServiceCall()

  handleAddContentSuccess: () =>
    @newPlateDesignController.handleAddContentSuccessCallback()
    @newPlateDesignController.completeInitialization()

  displayCreatePlateForm: =>
    plateTypeFetchPromise = @createPlateController.plateTypes.fetch()
    plateTypeFetchPromise.complete(() =>
      @$("div[name='formContainer']").html @createPlateController.render().el
      @createPlateController.completeInitialization()
    )

  displayPlateSearch: =>
    @$("div[name='formContainer']").html @plateSearchController.render().el
    @plateSearchController.completeInitialize()

  displayPlateDesignForm: (plateBarcode) =>
    @dataServiceController.setupService(new LoadPlateController({plateBarcode: plateBarcode, successCallback: @handleAllDataLoadedForPlateDesignForm}))
    @dataServiceController.doServiceCalls()

  handleAllDataLoadedForPlateDesignForm: (plateAndWellData) =>
    @$("div[name='formContainer']").html @newPlateDesignController.render().el
    @newPlateDesignController.completeInitialization(plateAndWellData)

  render: =>
    $(@el).html @template()
    @$("div[name='dataServiceControllerContainer']").html @dataServiceController.render().el

    @



module.exports =
  AppController: AppController