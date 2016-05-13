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
AuthorCollection = require('./AuthorCollection.coffee').AuthorCollection

MergeOrSplitPlatesController = require('./MergeOrSplitPlatesController.coffee').MergeOrSplitPlatesController

PlateDefinitionCollection = require('./PlateDefinitionCollection.coffee').PlateDefinitionCollection
PlateModel = require('./PlateModel.coffee').PlateModel

DataServiceController = require('./DataServiceController.coffee').DataServiceController
AddContentIdentifierValidationController = require('./IdentifierValidationController.coffee').AddContentIdentifierValidationController
ADD_CONTENT_CONTROLLER_EVENTS = require('./AddContentController.coffee').ADD_CONTENT_CONTROLLER_EVENTS
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
    @listenTo @newPlateDesignController, ADD_CONTENT_CONTROLLER_EVENTS.ADD_CONTENT_NO_VALIDATION, @handleAddContentNoValidation

    @createPlateController = new CreatePlateController({model: new PlateModel(), plateDefinitions: new PlateDefinitionCollection()})
    @listenTo @createPlateController, CREATE_PLATE_CONTROLLER_EVENTS.CREATE_PLATE, @handleCreatePlate
    @dataServiceController = new DataServiceController()

    @plateSearchController = new PlateSearchController({plateDefinitions: new PlateDefinitionCollection(), plateStatuses: new PlateStatusCollection(), plateTypes: new PlateTypeCollection(), users: new AuthorCollection()})

  completeInitialization: =>
    #@newPlateDesignController.completeInitialization()

  handleCreatePlate: (plateModel) =>
    @dataServiceController.setupService(new CreatePlateSaveController({plateModel: plateModel, successCallback: @createPlateController.handleSuccessfulSave}))
    @dataServiceController.doServiceCall()

  handleAddContent: (addContentModel) =>
    @dataServiceController.setupService(new AddContentIdentifierValidationController({addContentModel: addContentModel, successCallback: @newPlateDesignController.handleAddContentSuccessCallback}))
    @dataServiceController.doServiceCall(@handleAddContentSuccess)

  handleAddContentNoValidation: (addContentModel) =>
    console.log "handleAddContentNoValidation"
    @newPlateDesignController.handleAddContentSuccessCallback(addContentModel)

  handleAddIdentifierContentFromTable: (addContentModel) =>
    @dataServiceController.setupService(new PlateTableIdentifierValidationController({addContentModel: addContentModel, successCallback: @newPlateDesignController.handleAddContentFromTableSuccessCallback, mode: "plateTable"}))
    @dataServiceController.doServiceCall()

  handleAddContentSuccess: () =>
    @newPlateDesignController.handleAddContentSuccessCallback()
    @newPlateDesignController.completeInitialization()

  resetCurrentlyDisplayedForm: =>
    if @currentFormController?
      console.log "removing current form controller"
      @currentFormController.remove()

  displayCreatePlateForm: =>
    @resetCurrentlyDisplayedForm()
    plateTypeFetchPromise = @createPlateController.plateDefinitions.fetch()
    plateTypeFetchPromise.complete(() =>
      @createPlateController.plateDefinitions.convertLabelsToNumeric()
      @createPlateController.plateDefinitions.comparator = "numericPlateName"
      @createPlateController.plateDefinitions.sort()
      @$("div[name='formContainer']").html @createPlateController.render().el
      @currentFormController = @createPlateController
      #@createPlateController.completeInitialization()
    )

  displayPlateSearch: =>
    @resetCurrentlyDisplayedForm()
#    promises = []
#    promises.push(@plateSearchController.plateStatuses.fetch())
#    promises.push(@plateSearchController.plateTypes.fetch())
#    promises.push(@plateSearchController.plateDefinitions.fetch())
#    promises.push(@plateSearchController.users.fetch())

    plateStatusesDeferred = $.Deferred()
    plateTypesDeferred = $.Deferred()
    plateDefinitionsDeferred = $.Deferred()
    usersDeferred = $.Deferred()

    @plateSearchController.plateStatuses.fetch({
      success: () =>
        plateStatusesDeferred.resolve()
    })
    @plateSearchController.plateTypes.fetch({
      success: () =>
        plateTypesDeferred.resolve()
    })
    @plateSearchController.plateDefinitions.fetch({
      success: () =>
        plateDefinitionsDeferred.resolve()
    })
    @plateSearchController.users.fetch({
      success: () =>
        usersDeferred.resolve()
    })
    $.when(plateStatusesDeferred, plateTypesDeferred, plateDefinitionsDeferred).done(() =>
      @plateSearchController.plateDefinitions.convertLabelsToNumeric()
      @plateSearchController.plateDefinitions.comparator = "numericPlateName"
      @plateSearchController.plateDefinitions.sort()
      @currentFormController = @plateSearchController
      @$("div[name='formContainer']").html @plateSearchController.render().el
      @plateSearchController.completeInitialize()
    )

  displayPlateDesignForm: (plateBarcode) =>
    @resetCurrentlyDisplayedForm()
    @dataServiceController.setupService(new LoadPlateController({plateBarcode: plateBarcode, successCallback: @handleAllDataLoadedForPlateDesignForm}))
    @dataServiceController.doServiceCalls()

  displayMergeOrSplitPlatesForm: () =>
    @resetCurrentlyDisplayedForm()
    @mergeOrSplitPlatesController = new MergeOrSplitPlatesController()
    @currentFormController = @mergeOrSplitPlatesController
    @$("div[name='formContainer']").html @mergeOrSplitPlatesController.render().el
  
  handleAllDataLoadedForPlateDesignForm: (plateAndWellData) =>
    plateStatusesDeferred = $.Deferred()
    plateTypesDeferred = $.Deferred()
    @newPlateDesignController.plateStatuses.fetch({
      success: () =>
        plateStatusesDeferred.resolve()
    })
    @newPlateDesignController.plateTypes.fetch({
      success: () =>
        plateTypesDeferred.resolve()
    })
    $.when(plateStatusesDeferred, plateTypesDeferred).done(() =>
      @$("div[name='formContainer']").html @newPlateDesignController.render().el
      @currentFormController = @newPlateDesignController
      @newPlateDesignController.completeInitialization(plateAndWellData)
    )

  render: =>
    $(@el).html @template()
    @$("div[name='dataServiceControllerContainer']").html @dataServiceController.render().el

    @



module.exports =
  AppController: AppController