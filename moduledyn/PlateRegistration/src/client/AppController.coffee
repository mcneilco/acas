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
PlateStatusCollection = require('./PlateStatusCollection.coffee').PlateStatusCollection


MergeOrSplitPlatesController = require('./MergeOrSplitPlatesController.coffee').MergeOrSplitPlatesController

PlateDefinitionCollection = require('./PlateDefinitionCollection.coffee').PlateDefinitionCollection
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
    @newPlateDesignController = new NewPlateDesignController({plateStatuses: new PlateStatusCollection(), plateTypes: new PlateTypeCollection()})
    @listenTo @newPlateDesignController, NEW_PLATE_DESIGN_CONTROLLER_EVENTS.ADD_CONTENT, @handleAddContent
    @listenTo @newPlateDesignController, NEW_PLATE_DESIGN_CONTROLLER_EVENTS.ADD_IDENTIFIER_CONTENT_FROM_TABLE, @handleAddIdentifierContentFromTable

    @createPlateController = new CreatePlateController({model: new PlateModel(), plateDefinitions: new PlateDefinitionCollection()})
    @listenTo @createPlateController, CREATE_PLATE_CONTROLLER_EVENTS.CREATE_PLATE, @handleCreatePlate
    @dataServiceController = new DataServiceController()

    @plateSearchController = new PlateSearchController({plateDefinitions: new PlateDefinitionCollection(), plateStatuses: new PlateStatusCollection(), plateTypes: new PlateTypeCollection()})

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
    plateTypeFetchPromise = @createPlateController.plateDefinitions.fetch()
    plateTypeFetchPromise.complete(() =>
      @$("div[name='formContainer']").html @createPlateController.render().el
      @createPlateController.completeInitialization()
    )

  displayPlateSearch: =>
    promises = []
    promises.push(@plateSearchController.plateStatuses.fetch())
    promises.push(@plateSearchController.plateTypes.fetch())
    promises.push(@plateSearchController.plateDefinitions.fetch())
    $.when(promises).done(() =>
      @$("div[name='formContainer']").html @plateSearchController.render().el
      @plateSearchController.completeInitialize()
    )

  displayPlateDesignForm: (plateBarcode) =>

    @dataServiceController.setupService(new LoadPlateController({plateBarcode: plateBarcode, successCallback: @handleAllDataLoadedForPlateDesignForm}))
    @dataServiceController.doServiceCalls()

  displayMergeOrSplitPlatesForm: () =>
    @mergeOrSplitPlatesController = new MergeOrSplitPlatesController()
    @$("div[name='formContainer']").html @mergeOrSplitPlatesController.render().el
  
  handleAllDataLoadedForPlateDesignForm: (plateAndWellData) =>
    promises = []
    promises.push(@newPlateDesignController.plateStatuses.fetch())
    promises.push(@newPlateDesignController.plateTypes.fetch())
    $.when(promises).done(() =>
      @$("div[name='formContainer']").html @newPlateDesignController.render().el
      @newPlateDesignController.completeInitialization(plateAndWellData)
    )

  render: =>
    $(@el).html @template()
    @$("div[name='dataServiceControllerContainer']").html @dataServiceController.render().el

    @



module.exports =
  AppController: AppController