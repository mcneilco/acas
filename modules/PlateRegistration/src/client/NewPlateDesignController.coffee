PlateInfoController = require('./PlateInfoController.coffee').PlateInfoController
AddContentController = require('./AddContentController.coffee').AddContentController
ADD_CONTENT_CONTROLLER_EVENTS = require('./AddContentController.coffee').ADD_CONTENT_CONTROLLER_EVENTS
AddContentModel = require("./AddContentModel.coffee").AddContentModel
ADD_CONTENT_MODEL_FIELDS = require("./AddContentModel.coffee").ADD_CONTENT_MODEL_FIELDS
PlateTypeCollection = require('./PlateTypeCollection.coffee').PlateTypeCollection
PlateStatusCollection = require('./PlateStatusCollection.coffee').PlateStatusCollection
PlateViewController = require('./PlateViewController.coffee').PlateViewController
PLATE_TABLE_CONTROLLER_EVENTS = require('./PlateTableController.coffee').PLATE_TABLE_CONTROLLER_EVENTS
TemplateController = require('./TemplateController.coffee').TemplateController
SerialDilutionController = require('./SerialDilutionController.coffee').SerialDilutionController
EditorFormTabViewController = require('./EditorFormTabViewController.coffee').EditorFormTabViewController
PlateInfoModel = require('./PlateInfoModel.coffee').PlateInfoModel

$ = require('jquery')

NEW_PLATE_DESIGN_CONTROLLER_EVENTS =
  ADD_CONTENT: "AddContent"

class NewPlateDesignController extends Backbone.View
  template: require('html!./NewPlateDesignTemplate.tmpl')
  initialize: ->
    @startUpParams =
      plateTypes: new PlateTypeCollection([{value: '', displayValue: ''}, {value: 'plate', displayValue: 'Plate'}])
      plateStatuses: new PlateStatusCollection([{value: '', displayValue: ''}, {value: 'complete', displayValue: 'Complete'}])
      model: new PlateInfoModel()

    @plateInfoController = new PlateInfoController(@startUpParams)
    addContentControllerStartUpParams =
      model: new AddContentModel()
    @addContentController = new AddContentController(addContentControllerStartUpParams)
    @listenTo @addContentController, ADD_CONTENT_CONTROLLER_EVENTS.ADD_CONTENT, @handleAddContent

    @plateViewController = new PlateViewController()
    @listenTo @plateViewController, PLATE_TABLE_CONTROLLER_EVENTS.REGION_SELECTED, @handleRegionSelected
    @listenTo @plateViewController, PLATE_TABLE_CONTROLLER_EVENTS.PLATE_CONTENT_UPADATED, @handleContentUpdated

    @templateController = new TemplateController()
    @serialDilutionController = new SerialDilutionController()

    @editorFormsTabView = new EditorFormTabViewController({plateInfoController: @plateInfoController, addContentController: @addContentController, templateController: @templateController, serialDilutionController: @serialDilutionController})

  completeInitialization: (plate) =>
    @plateInfoController.updatePlate plate
    @plateViewController.completeInitialization(plate)

  render: =>
    $(@el).html @template
    @$("div[name='plateViewContainer']").html @plateViewController.render().el
    @$("div[name='editorFormTabViewContainer']").html @editorFormsTabView.render().el

    @

  handleRegionSelected: (regionSelectedBoundries) =>
    @addContentController.updateSelectedRegion regionSelectedBoundries

  handleContentUpdated: (regionSelectedBoundries) =>
    console.log "NewPlateDesignController - handleRegionSelected"
    console.log regionSelectedBoundries

  handleAddContent: (addContentModel) =>
    @trigger NEW_PLATE_DESIGN_CONTROLLER_EVENTS.ADD_CONTENT, addContentModel

  handleAddContentSuccessCallback: (addContentModel) =>
    console.log "addContentModel"
    console.log addContentModel
    @plateViewController.addContent addContentModel
    @addContentController.handleIdentifiersAdded addContentModel.get(ADD_CONTENT_MODEL_FIELDS.VALID_IDENTIFIERS)





module.exports =
  NewPlateDesignController: NewPlateDesignController
  NEW_PLATE_DESIGN_CONTROLLER_EVENTS: NEW_PLATE_DESIGN_CONTROLLER_EVENTS