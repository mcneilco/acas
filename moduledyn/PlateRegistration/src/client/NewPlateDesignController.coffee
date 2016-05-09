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
SERIAL_DILUTION_CONTROLLER_EVENTS = require('./SerialDilutionController.coffee').SERIAL_DILUTION_CONTROLLER_EVENTS
SerialDilutionModel = require('./SerialDilutionModel.coffee').SerialDilutionModel
EditorFormTabViewController = require('./EditorFormTabViewController.coffee').EditorFormTabViewController
EDITOR_FORM_TABLE_VIEW_CONTROLLER_EVENTS = require('./EditorFormTabViewController.coffee').EDITOR_FORM_TABLE_VIEW_CONTROLLER_EVENTS
PlateInfoModel = require('./PlateInfoModel.coffee').PlateInfoModel

$ = require('jquery')

NEW_PLATE_DESIGN_CONTROLLER_EVENTS =
  ADD_CONTENT: "AddContent"
  ADD_CONTENT_FROM_TABLE: "AddContentFromTable"
  ADD_IDENTIFIER_CONTENT_FROM_TABLE: "AddIdentifierContentFromTable"


class NewPlateDesignController extends Backbone.View
  template: require('html!./NewPlateDesignTemplate.tmpl')
  initialize: (options) ->
    @plateStatuses = options.plateStatuses
    @plateTypes = options.plateTypes
    @startUpParams =
      plateTypes: @plateTypes
      plateStatuses: @plateStatuses
      model: new PlateInfoModel()

    @plateInfoController = new PlateInfoController(@startUpParams)
    addContentControllerStartUpParams =
      model: new AddContentModel()
    @addContentController = new AddContentController(addContentControllerStartUpParams)
    @listenTo @addContentController, ADD_CONTENT_CONTROLLER_EVENTS.ADD_CONTENT, @handleAddContent
    @listenTo @addContentController, ADD_CONTENT_CONTROLLER_EVENTS.ADD_CONTENT_NO_VALIDATION, @handleAddContentNoValidation

    @plateViewController = new PlateViewController()
    @listenTo @plateViewController, PLATE_TABLE_CONTROLLER_EVENTS.REGION_SELECTED, @handleRegionSelected
    @listenTo @plateViewController, PLATE_TABLE_CONTROLLER_EVENTS.ADD_IDENTIFIER_CONTENT_FROM_TABLE, @handleContentUpdated
    @listenTo @plateViewController, PLATE_TABLE_CONTROLLER_EVENTS.PLATE_CONTENT_UPADATED, @handPlateContentUpdated

    @templateController = new TemplateController()
    @serialDilutionController = new SerialDilutionController({model: new SerialDilutionModel()})
    @listenTo @serialDilutionController, SERIAL_DILUTION_CONTROLLER_EVENTS.APPLY_DILUTION, @handleApplyDilution
    @editorFormsTabView = new EditorFormTabViewController({plateInfoController: @plateInfoController, addContentController: @addContentController, templateController: @templateController, serialDilutionController: @serialDilutionController})
    @listenTo @editorFormsTabView,  EDITOR_FORM_TABLE_VIEW_CONTROLLER_EVENTS.EDITOR_FORMS_MAXIMIZED, @handleEditorFormsMaximized
    @listenTo @editorFormsTabView,  EDITOR_FORM_TABLE_VIEW_CONTROLLER_EVENTS.EDITOR_FORMS_MINIMIZED, @handleEditorFormsMinimized

  completeInitialization: (plateAndWellData) =>
    @plateInfoController.updatePlate plateAndWellData.plateMetadata
    @plateViewController.completeInitialization(plateAndWellData.wellContent, plateAndWellData.plateMetadata)
    @serialDilutionController.completeInitialization(plateAndWellData.plateMetadata)

  render: =>
    $(@el).html @template
    @$("div[name='plateViewContainer']").html @plateViewController.render().el
    @$("div[name='editorFormTabViewContainer']").html @editorFormsTabView.render().el

    @

  handleRegionSelected: (regionSelectedBoundries) =>
    @serialDilutionController.updateSelectedRegion regionSelectedBoundries
    @addContentController.updateSelectedRegion regionSelectedBoundries

  handleContentUpdated: (addContentModel) =>
    @trigger NEW_PLATE_DESIGN_CONTROLLER_EVENTS.ADD_IDENTIFIER_CONTENT_FROM_TABLE, addContentModel

  handleAddContent: (addContentModel) =>
    @trigger NEW_PLATE_DESIGN_CONTROLLER_EVENTS.ADD_CONTENT, addContentModel

  handleAddContentNoValidation: (addContentModel) =>
    @trigger ADD_CONTENT_CONTROLLER_EVENTS.ADD_CONTENT_NO_VALIDATION, addContentModel

  handleAddContentSuccessCallback: (addContentModel) =>
    @plateViewController.addContent addContentModel
    #@addContentController.handleIdentifiersAdded addContentModel.get(ADD_CONTENT_MODEL_FIELDS.VALID_IDENTIFIERS)

  handPlateContentUpdated: (identifiersToRemove) =>
    @addContentController.handleIdentifiersAdded identifiersToRemove

  handleAddContentFromTableSuccessCallback: (addContentModel) =>
    @plateViewController.plateTableController.identifiersValidated addContentModel

  handleApplyDilution: (dilutionModel) =>
    @plateViewController.applyDilution dilutionModel

  handleEditorFormsMaximized: =>
    @$(".editorMain").css("margin-left", "315px")
    @plateViewController.plateTableController.minimizeTable()

  handleEditorFormsMinimized: =>
    @$(".editorMain").css("margin-left", "65px")
    @plateViewController.plateTableController.maximizeTable()


module.exports =
  NewPlateDesignController: NewPlateDesignController
  NEW_PLATE_DESIGN_CONTROLLER_EVENTS: NEW_PLATE_DESIGN_CONTROLLER_EVENTS