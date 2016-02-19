Backbone = require('backbone')

_ = require('lodash')
$ = require('jquery')
Handsontable = require('imports?this=>window!../../../../public/lib/handsontable/dist/handsontable.full.js') #Handsontable || () ->
require("bootstrap-webpack!./bootstrap.config.js");

PlateFillerFactory = require('./PlateFillerFactory.coffee').PlateFillerFactory
ADD_CONTENT_MODEL_FIELDS = require('./AddContentModel.coffee').ADD_CONTENT_MODEL_FIELDS

PLATE_TABLE_CONTROLLER_EVENTS =
  REGION_SELECTED: "RegionSelected"
  PLATE_CONTENT_UPADATED: "PlateContentUpdated"


class PlateTableController extends Backbone.View
  template: _.template(require('html!./PlateTableView.tmpl'))

  initialize: ->
    @plateFillerFactory = new PlateFillerFactory()

  render: =>
    $(@el).html @template()

    @

  completeInitialization: =>
    container = document.getElementsByName("handsontablecontainer")[0]
    @handsOnTable = new Handsontable(container, {
      rowHeaders: true
      colHeaders: true
      outsideClickDeselects: false
      startCols: 48
      startRows: 32
      renderer: @cellRenderer
      afterChange: @handleContentUpdated
      afterSelection: @handleRegionSelected
    })

  handleContentAdded: (addContentModel) =>
    validatedIdentifiers = addContentModel.get(ADD_CONTENT_MODEL_FIELDS.VALIDATED_IDENTIFIERS)
    console.log addContentModel.get(ADD_CONTENT_MODEL_FIELDS.FILL_STRATEGY)

    plateFiller = @plateFillerFactory.getPlateFiller(addContentModel.get(ADD_CONTENT_MODEL_FIELDS.FILL_STRATEGY), validatedIdentifiers, @selectedRegionBoundries)
    [@plateWells, identifiersToRemove] = plateFiller.getWells()
    console.log "@plateWells"
    console.log @plateWells
    @addContent @plateWells

  addContent: (data) =>
    @handsOnTable.setDataAtCell data
    window.FOOHANDSONTABLE = @handsOnTable
    @handsOnTable.init() # force re-render so tooltip content is updated

  handleRegionSelected: (rowStart, colStart, rowStop, colStop) =>
    @selectedRegionBoundries =
      rowStart: rowStart
      colStart: colStart
      rowStop:  rowStop
      colStop: colStop

    @trigger PLATE_TABLE_CONTROLLER_EVENTS.REGION_SELECTED, @selectedRegionBoundries

  handleContentUpdated: (changes, source) =>
    updatedValues = @reformatUpdatedValues changes
    @trigger PLATE_TABLE_CONTROLLER_EVENTS.PLATE_CONTENT_UPADATED, updatedValues

  reformatUpdatedValues: (changes) ->
    updateValue = []
    _.each(changes, (change) ->
      updateValue.push
        rowIdx: change[0]
        colIdx: change[1]
        value: change[3]
    )

    updateValue

  getWellDataAtRowCol: (row, col) =>
    wellData = ""
    _.each(@plateWells, (well) ->
      if well[0] is row and well[1] is col
        wellData = well[2]
    )

    wellData

  cellRenderer: (instance, td, row, col, prop, value, cellProperties) =>
    Handsontable.renderers.TextRenderer.apply(@, arguments)
    wellData = @getWellDataAtRowCol(row, col)

    t = '<div class="popover left"> <div class="arrow"></div> <h3 class="popover-title">Well Details</h3> <div class="popover-content"><p>' + wellData + '</p> </div> </div>'


    $(td).tooltip({
      trigger: 'hover active',
      title: 'Tooltip -- boom!',
      placement: 'right',
      container: 'body',
      template: t #'<div class="tooltip" role="tooltip"><div class="tooltip-arrow"></div><div class="tooltip-inner"></div></div>'
    })


    return td



module.exports =
  PlateTableController: PlateTableController
  PLATE_TABLE_CONTROLLER_EVENTS: PLATE_TABLE_CONTROLLER_EVENTS


