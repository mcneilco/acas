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
    @createPlateController = new CreatePlateController({model: new PlateModel()})
    @listenTo @createPlateController, CREATE_PLATE_CONTROLLER_EVENTS.CREATE_PLATE, @handleCreatePlate
    @dataServiceController = new DataServiceController()

  completeInitialization: =>
    #@newPlateDesignController.completeInitialization()

  handleCreatePlate: (plateModel) =>
    console.log "plateModel"
    console.log plateModel

    @dataServiceController.setupService(new CreatePlateSaveController({plateModel: plateModel, successCallback: @createPlateController.handleSuccessfulSave}))
    @dataServiceController.doServiceCall((resp) ->
      console.log "save callback"
      console.log resp
    )

#alert "add content..."

  handleAddContent: (addContentModel) =>
    console.log "identifiers"
    console.log addContentModel

    @dataServiceController.setupService(new IdentifierValidationController({addContentModel: addContentModel, successCallback: @newPlateDesignController.handleAddContentSuccessCallback}))
    @dataServiceController.doServiceCall(@handleAddContentSuccess)

    #alert "add content..."

  handleAddContentSuccess: () =>
    @newPlateDesignController.handleAddContentSuccessCallback()
    @newPlateDesignController.completeInitialization()


  displayCreatePlateForm: =>
    @$("div[name='formContainer']").html @createPlateController.render().el

  displayPlateDesignForm: (plateBarcode) =>
    #@dataServiceController = new DataServiceController()
    @dataServiceController.setupService(new LoadPlateController({plateBarcode: plateBarcode, successCallback: @handleAllDataLoadedForPlateDesignForm}))
    @dataServiceController.doServiceCall()
#    (resp) ->
#      console.log "plate load callback"
#      console.log resp
#    )

  handleAllDataLoadedForPlateDesignForm: (data) =>
    console.log "handleAllDataLoadedForPlateDesignForm"
    #console.log data
    @$("div[name='formContainer']").html @newPlateDesignController.render().el
    @newPlateDesignController.completeInitialization(data)

  render: =>
    $(@el).html @template()

    @$("div[name='dataServiceControllerContainer']").html @dataServiceController.render().el

    @



module.exports =
  AppController: AppController