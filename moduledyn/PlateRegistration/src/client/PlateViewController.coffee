Backbone = require('backbone')
PlateTableController = require('./PlateTableController.coffee').PlateTableController
PLATE_TABLE_CONTROLLER_EVENTS = require('./PlateTableController.coffee').PLATE_TABLE_CONTROLLER_EVENTS

_ = require('lodash')
#$ = require('jquery')
require('expose?$!expose?jQuery!jquery');
require("bootstrap-webpack!./bootstrap.config.js");

PLATE_VIEW_CONTROLLER_EVENTS =
  COMPOUND_VIEW_SELECTED: "CompundViewSelected"
  VOLUME_VIEW_SELECTED: "VolumeViewSelected"
  CONCENTRATION_VIEW_SELECTED: "ConcentrationViewSelected"
  MASTER_VIEW_SELECTED: "MasterViewSelected"


class PlateViewController extends Backbone.View
  template: _.template(require('html!./PlateViewView.tmpl'))

  events:
    "click a[name='compoundView']": "handleCompoundViewClick"
    "click a[name='volumeView']": "handleVolumeViewClick"
    "click a[name='concentrationView']": "handleConcentrationViewClick"
    "click a[name='masterView']": "handleMasterViewClick"
    "click a[name='colorByCompound']": "handleColorByCompoundClick"
    "click a[name='colorByVolume']": "handleColorByVolumeClick"
    "click a[name='colorByConcentration']": "handleColorByConcentrationClick"
    "click a[name='colorByNone']": "handleColorByNoneClick"
    "click a[name='showAll']": "handleShowAll"
    "click a[name='fitToContents']": "handleFitToContents"
    "click a[name='fitToScreen']": "fitToScreen"
    "click button[name='increaseFontSize']": "handleIncreaseFontSizeClick"
    "click button[name='decreaseFontSize']": "handleDecreaseFontSizeClick"
    "click button[name='displayToolTips']": "handleDisplayToolTipsToggled"

  handleCompoundViewClick: (e) =>
    e.preventDefault()
    @updateSelectedView "Compound View"
    @plateTableController.updateDataDisplayed "batchCode"
    @trigger PLATE_VIEW_CONTROLLER_EVENTS.COMPOUND_VIEW_SELECTED

  handleVolumeViewClick: (e) =>
    e.preventDefault()
    @updateSelectedView "Volume View"
    @plateTableController.updateDataDisplayed "amount"
    @trigger PLATE_VIEW_CONTROLLER_EVENTS.VOLUME_VIEW_SELECTED

  handleConcentrationViewClick: (e) =>
    e.preventDefault()
    @updateSelectedView "Concentration View"
    @plateTableController.updateDataDisplayed "batchConcentration"
    @trigger PLATE_VIEW_CONTROLLER_EVENTS.CONCENTRATION_VIEW_SELECTED

  handleMasterViewClick: (e) =>
    e.preventDefault()
    @updateSelectedView "Master View"
    @$("button[name='displayToolTips']").addClass("active")
    @plateTableController.updateDataDisplayed "masterView"
    @trigger PLATE_VIEW_CONTROLLER_EVENTS.MASTER_VIEW_SELECTED

  handleColorByCompoundClick: (e) =>
    e.preventDefault()
    @updateSelectedColorBy "Color By Compound"
    @plateTableController.updateColorBy "batchCode"
    @trigger PLATE_VIEW_CONTROLLER_EVENTS.COMPOUND_VIEW_SELECTED

  handleColorByVolumeClick: (e) =>
    e.preventDefault()
    @updateSelectedColorBy "Color By Volume"
    @plateTableController.updateColorBy "amount"
    @trigger PLATE_VIEW_CONTROLLER_EVENTS.COMPOUND_VIEW_SELECTED

  handleColorByConcentrationClick: (e) =>
    e.preventDefault()
    @updateSelectedColorBy "Color By Concentration"
    @plateTableController.updateColorBy "batchConcentration"
    @trigger PLATE_VIEW_CONTROLLER_EVENTS.COMPOUND_VIEW_SELECTED

  handleColorByNoneClick: (e) =>
    e.preventDefault()
    @updateSelectedColorBy "No Color"
    @plateTableController.updateColorBy "noColor"
    @trigger PLATE_VIEW_CONTROLLER_EVENTS.COMPOUND_VIEW_SELECTED

  handleIncreaseFontSizeClick: =>
    @plateTableController.increaseFontSize()

  handleDecreaseFontSizeClick: =>
    @plateTableController.decreaseFontSize()

  handleShowAll: (e) =>
    e.preventDefault()
    @updateSelectedTableFitMode "Show All"
    @plateTableController.showAll()

  handleFitToContents: (e) =>
    e.preventDefault()
    @updateSelectedTableFitMode "Fit to Contents"
    @plateTableController.fitToContents()

  fitToScreen: (e) =>
    e.preventDefault()
    @updateSelectedTableFitMode "Fit to Screen"
    @plateTableController.fitToScreen()

  updateSelectedTableFitMode: (displayMode) =>
    @$("button[name='cellZoom']").html displayMode

  updateSelectedView: (selectedView) =>
    @$("button[name='selectedView']").html selectedView

  updateSelectedColorBy: (colorBy) =>
    @$("button[name='selectedColorBy']").html colorBy

  handleDisplayToolTipsToggled: =>

    $("button[name='displayToolTips']").toggleClass("active")
    @plateTableController.displayToolTips = !@plateTableController.displayToolTips
    @plateTableController.renderHandsOnTable()

  initialize: ->
    @plateTableController = new PlateTableController()
    @plateTableController.on PLATE_TABLE_CONTROLLER_EVENTS.REGION_SELECTED, @handleRegionSelected
    @plateTableController.on PLATE_TABLE_CONTROLLER_EVENTS.ADD_IDENTIFIER_CONTENT_FROM_TABLE, @handleContentUpdated
    @plateTableController.on PLATE_TABLE_CONTROLLER_EVENTS.PLATE_CONTENT_UPADATED, @handlePlateContentUpdated

  completeInitialization: (plateWells, plateMetaData) =>
    @wells = plateWells
    @plateMetaData = plateMetaData
    @plateTableController.completeInitialization(@wells, @plateMetaData)

  render: =>
    $(@el).html @template()
    @$("div[name='plateTableContainer']").html @plateTableController.render().el

    @

  handleRegionSelected: (selectedRegionBoundries) =>
    @trigger PLATE_TABLE_CONTROLLER_EVENTS.REGION_SELECTED, selectedRegionBoundries

  handleContentUpdated: (addContentModel) =>
    @trigger PLATE_TABLE_CONTROLLER_EVENTS.ADD_IDENTIFIER_CONTENT_FROM_TABLE, addContentModel

  handlePlateContentUpdated: (identifiersToRemove) =>
    @trigger PLATE_TABLE_CONTROLLER_EVENTS.PLATE_CONTENT_UPADATED, identifiersToRemove

  addContent: (data) =>
    console.log "addContent"
    @plateTableController.handleContentAdded data

  applyDilution: (dilutionModel) =>
    @plateTableController.applyDilution dilutionModel


module.exports =
  PlateViewController: PlateViewController