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
    @trigger PLATE_VIEW_CONTROLLER_EVENTS.MASTER_VIEW_SELECTED

  updateSelectedView: (selectedView) =>
    @$("button[name='selectedView']").html selectedView

  handleDisplayToolTipsToggled: =>
    console.log "handleDisplayToolTipsToggled"
    $("button[name='displayToolTips']").toggleClass("active")
    @plateTableController.displayToolTips = !@plateTableController.displayToolTips
    @plateTableController.renderHandsOnTable()

  initialize: ->
    @plateTableController = new PlateTableController()
    @plateTableController.on PLATE_TABLE_CONTROLLER_EVENTS.REGION_SELECTED, @handleRegionSelected

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

  handleContentUpdated: (updatedValues) =>
    @trigger PLATE_TABLE_CONTROLLER_EVENTS.PLATE_CONTENT_UPADATED, updatedValues

  addContent: (data) =>
    @plateTableController.handleContentAdded data

  applyDilution: (dilutionModel) =>
    @plateTableController.applyDilution dilutionModel


module.exports =
  PlateViewController: PlateViewController