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
    @displayToolTips = false

  render: =>
    $(@el).html @template()

    @

  completeInitialization: (wells) =>
    console.log "PlateTableController?!?!?!?"
    @wells = wells
    @renderHandsOnTable()


  renderHandsOnTable: =>
    container = document.getElementsByName("handsontablecontainer")[0]
    columnHeaders = [1..48]
    rowHeaders = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'W', 'Z', 'AA', 'AB', 'AC', 'AD', 'AE', 'AF']
    if @displayToolTips
      @handsOnTable = new Handsontable(container, {
        rowHeaders: rowHeaders #true
        colHeaders: columnHeaders #true
        outsideClickDeselects: false
        startCols: 48
        startRows: 32
        renderer: @cellRenderer
        afterChange: @handleContentUpdated
        afterSelection: @handleRegionSelected
      })
    else
      @handsOnTable = new Handsontable(container, {
        rowHeaders: rowHeaders #true
        colHeaders: columnHeaders #true
        outsideClickDeselects: false
        startCols: 48
        startRows: 32
        afterChange: @handleContentUpdated
        afterSelection: @handleRegionSelected
      })

    hotData = @convertWellsDataToHandsonTableData("batchCode")
    @addContent(hotData)

  updateDataDisplayed: (dataFieldToDisplay) =>
    hotData = @convertWellsDataToHandsonTableData(dataFieldToDisplay)
    @addContent(hotData)

  convertWellsDataToHandsonTableData: (dataField) =>
    console.log "convertWellsDataToHandsonTableData"
    hotData = []
    _.each(@wells, (well) ->
      hotData.push [well.rowIndex, well.columnIndex, well[dataField]]
    )
    console.log "hotData "
    console.log hotData
    return hotData

  handleContentAdded: (addContentModel) =>
    validatedIdentifiers = addContentModel.get(ADD_CONTENT_MODEL_FIELDS.VALIDATED_IDENTIFIERS)
    console.log addContentModel.get(ADD_CONTENT_MODEL_FIELDS.FILL_STRATEGY)
    console.log "console.log addContentModel"
    console.log addContentModel
    plateFiller = @plateFillerFactory.getPlateFiller(addContentModel.get(ADD_CONTENT_MODEL_FIELDS.FILL_STRATEGY), validatedIdentifiers, @selectedRegionBoundries)
    [@plateWells, identifiersToRemove] = plateFiller.getWells(@wells, addContentModel.get("batchConcentration"), addContentModel.get("amount"))
    console.log "@plateWells"
    console.log @plateWells

    @addContent @plateWells

  addContent: (data) =>
    @handsOnTable.setDataAtCell data
    #window.FOOHANDSONTABLE = @handsOnTable
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

  lookupWellByRowCol: (row, col) =>

    _.each(@wells, (well) ->
    )

  cellRenderer: (instance, td, row, col, prop, value, cellProperties) =>
    Handsontable.renderers.TextRenderer.apply(@, arguments)
    wellData = @getWellDataAtRowCol(row, col)
    well = _.find(@wells, (w) ->
      if w.columnIndex is col and w.rowIndex is row
        return true
      else
        return false
    )

    unless well.batchCode?
      well.batchCode = ""
    unless well.amount?
      well.amount = ""
    unless well.batchConcentration?
      well.batchConcentration = ""
    t = '<div class="popover left"> <div class="arrow"></div> <h3 class="popover-title">Well Details: ' + well.wellName + '</h3> <div class="popover-content"><p>Batch Code: ' + well.batchCode + '</p><p>Volume: ' + well.amount + '</p><p>Concentration: ' + well.batchConcentration + '</p></div> </div>'

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


