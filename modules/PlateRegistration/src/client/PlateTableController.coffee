Backbone = require('backbone')

_ = require('lodash')
$ = require('jquery')
Handsontable = require('imports?this=>window!../../../../public/lib/handsontable/dist/handsontable.full.js') #Handsontable || () ->
require("bootstrap-webpack!./bootstrap.config.js")

PlateFillerFactory = require('./PlateFillerFactory.coffee').PlateFillerFactory
SerialDilutionFactory = require('./SerialDilutionFactory.coffee').SerialDilutionFactory
WellsModel = require('./WellModel.coffee').WellsModel

ADD_CONTENT_MODEL_FIELDS = require('./AddContentModel.coffee').ADD_CONTENT_MODEL_FIELDS
AddContentModel = require('./AddContentModel.coffee').AddContentModel

HANDS_ON_TABLE_EVENTS =
  PASTE: "paste"
  EDIT: "edit"
  AUTOFILL: "autofill"


PLATE_TABLE_CONTROLLER_EVENTS =
  REGION_SELECTED: "RegionSelected"
  PLATE_CONTENT_UPADATED: "PlateContentUpdated"


class PlateTableController extends Backbone.View
  template: _.template(require('html!./PlateTableView.tmpl'))

  events:
    "click button[name='pasteTruncatedIdentifiersAnyway']": "handleAcceptTruncatedPaste"
  initialize: ->
    @plateFillerFactory = new PlateFillerFactory()
    @serialDilutionFactory = new SerialDilutionFactory()
    @displayToolTips = false
    @dataFieldToDisplay = "batchCode"
    @dataFieldToColorBy = "noColor"
    @listOfBatchCodes = {}

  render: =>
    $(@el).html @template()

    @

  completeInitialization: (wells, plateMetaData) =>
    @wells = wells
    @plateMetaData = plateMetaData
    @wellsToUpdate = new WellsModel({allWells: @wells})
    @renderHandsOnTable()


  renderHandsOnTable: =>
    console.log "renderHandsOnTable"

    container = document.getElementsByName("handsontablecontainer")[0]

    columnHeaders = [1..@plateMetaData.numberOfColumns]
    rowHeaders = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'W', 'Z', 'AA', 'AB', 'AC', 'AD', 'AE', 'AF']
    if @displayToolTips
      @handsOnTable = new Handsontable(container, {
        rowHeaders: rowHeaders
        colHeaders: columnHeaders
        outsideClickDeselects: false
        startCols: @plateMetaData.numberOfColumns
        startRows: @plateMetaData.numberOfRows
        renderer: @toolTipCellRenderer
        beforeChange: @handleTableChangeRangeValidation
        afterChange: @handleContentUpdated
        afterSelection: @handleRegionSelected
      })
    else
      @handsOnTable = new Handsontable(container, {
        rowHeaders: rowHeaders.slice(0, @plateMetaData.numberOfRows) #true
        colHeaders: columnHeaders #true
        outsideClickDeselects: false
        startCols: @plateMetaData.numberOfColumns
        startRows: @plateMetaData.numberOfRows
        renderer: @defaultCellRenderer
        afterChange: @handleContentUpdated
        beforeChange: @handleTableChangeRangeValidation
        afterSelection: @handleRegionSelected
      })

    hotData = @convertWellsDataToHandsonTableData(@dataFieldToDisplay)
    @addContent(hotData)

  updateDataDisplayed: (dataFieldToDisplay) =>
    @dataFieldToDisplay = dataFieldToDisplay
    if @dataFieldToDisplay is "masterView"
      @displayToolTips = true
      @renderHandsOnTable()
    hotData = @convertWellsDataToHandsonTableData(dataFieldToDisplay)
    @addContent(hotData)

  updateColorBy: (dataFieldToColorBy) =>
    @dataFieldToColorBy = dataFieldToColorBy
    unless @dataFieldToColorBy is "noColor"
      if @dataFieldToColorBy is "batchCode"
        @listOfBatchCodes = {}
        rComponent = 0
        gComponent = 0
        bComponent = 50

        _.each(@wells, (well) =>
          if well["batchCode"]?
            unless @listOfBatchCodes[well["batchCode"]]?

              color = "rgb(#{rComponent},#{gComponent},#{bComponent})"
              console.log "well"
              console.log well
              console.log "color"
              console.log color
              @listOfBatchCodes[well["batchCode"]] = color
              bComponent += 80
              if bComponent > 255
                bComponent = 0
                gComponent += 80
                if bComponent > 255
                  gComponent = 0
                  rComponent += 80
        )
      else
        minValue = Infinity
        maxValue = -Infinity
        _.each(@wells, (well) =>
          unless isNaN(parseFloat(well[@dataFieldToColorBy]))
            if well[@dataFieldToColorBy] < minValue
              minValue = well[@dataFieldToColorBy]
            else if well[@dataFieldToColorBy] > maxValue
              maxValue = well[@dataFieldToColorBy]
        )

        if minValue < 0
          minValue = 0
        if minValue is 0
          @minValue = minValue
        else
          @minValue = Math.log(minValue)
        if maxValue < 0
          maxValue = 0

        if maxValue is 0
          @maxValue = maxValue
        else
          @maxValue = Math.log(maxValue)

    @renderHandsOnTable()

  convertWellsDataToHandsonTableData: (dataField) =>
    hotData = []
    _.each(@wells, (well) ->
      wellData = ""
      unless dataField is "masterView"
        wellData = well[dataField]
      hotData.push [well.rowIndex, well.columnIndex, wellData]
    )
    return hotData

  handleContentAdded: (addContentModel) =>
    validatedIdentifiers = addContentModel.get(ADD_CONTENT_MODEL_FIELDS.VALIDATED_IDENTIFIERS)
    plateFiller = @plateFillerFactory.getPlateFiller(addContentModel.get(ADD_CONTENT_MODEL_FIELDS.FILL_STRATEGY), addContentModel.get(ADD_CONTENT_MODEL_FIELDS.FILL_DIRECTION),  validatedIdentifiers, @selectedRegionBoundries)
    [@plateWells, identifiersToRemove] = plateFiller.getWells(@wells, addContentModel.get("batchConcentration"), addContentModel.get("amount"))

    @addContent1 @plateWells

  applyDilution: (dilutionModel) =>
    dilutionStrategy = @serialDilutionFactory.getSerialDilutionStrategy(dilutionModel, @selectedRegionBoundries)
    @plateWells = dilutionStrategy.getWells(@wells)

    @addContent1 @plateWells

  addContent: (data) =>
    console.log "addContent"
    console.log data
    @handsOnTable.setDataAtCell data, 'programaticEdit'
    #window.FOOHANDSONTABLE = @handsOnTable
    @handsOnTable.init() # force re-render so tooltip content is updated

  addContent1: (data) =>
    console.log "addContent1"
    console.log data
    hotData = []
    _.each(data, (d) =>
      hotData.push([d[0], d[1], d[2][@dataFieldToDisplay]])
    )
    @handsOnTable.setDataAtCell hotData
    @handsOnTable.init() # force re-render so tooltip content is updated

  handleRegionSelected: (rowStart, colStart, rowStop, colStop) =>
    @selectedRegionBoundries =
      rowStart: rowStart
      colStart: colStart
      rowStop:  rowStop
      colStop: colStop

    @trigger PLATE_TABLE_CONTROLLER_EVENTS.REGION_SELECTED, @selectedRegionBoundries

  validatePasteContentRowRange: (changes, numberOfRows) =>
    rowsExceedingRowRange = _.filter(changes, (change) ->
      return change[0] >= numberOfRows
    )
    rowsExceedingRowRange

  validatePasteContentColumnRange: (changes, numberOfCols) =>
    colsExceedingRowRange = _.filter(changes, (change) ->
      return change[1] >= numberOfCols
    )
    colsExceedingRowRange

  handleTableChangeRangeValidation: (changes, source) =>
    if source is HANDS_ON_TABLE_EVENTS.PASTE
      @pendingChanges = []
      pastingMoreRowsThanAvailable = false
      lowestRowNumber = Infinity
      highestRowNumber = -Infinity
      rowIdx = 0
      counter = 0
      numberOfInvalidRows = @validatePasteContentRowRange changes, @plateMetaData.numberOfRows
      numberOfInvalidCols = @validatePasteContentColumnRange changes, @plateMetaData.numberOfCols
#      for change in changes
#        console.log "change"
#        console.log change
#        @pendingChanges.push change
#        if change[0] < lowestRowNumber
#          lowestRowNumber = change[0]
#        if change[0] > highestRowNumber
#          highestRowNumber = change[0]
#        if change[0] >= @plateMetaData.numberOfRows and pastingMoreRowsThanAvailable is false
#          pastingMoreRowsThanAvailable = true
#          counter = rowIdx
#        rowIdx++

      if _.size(numberOfInvalidRows) > 0
        console.log "counter"
        console.log counter
        @pendingChanges = @pendingChanges.slice(0, _.size(numberOfInvalidRows))
        numberOfExtraRowsNeeded = highestRowNumber - @plateMetaData.numberOfRows
        numberOfAvailableRows = @plateMetaData.numberOfRows - lowestRowNumber
        totalNumbrOfRowsBeingPasted = highestRowNumber - lowestRowNumber
        $("div[name='handsontablePasteError']").modal('show')
        $("span[name='numberOfRowsBeingPasted']").html _.size(changes)
        $("span[name='numberOfRowsAvailable']").html numberOfAvailableRows
        $("span[name='numberOfColumnsAvailable']").html numberOfAvailableRows

        return false

  handleContentUpdated: (changes, source) =>
    if source in ["edit", "autofill", "paste"]
      console.log "changes"
      console.log changes
      listOfIdentifiers = []
      wellsToUpdate = @reformatUpdatedValues changes
      _.each(changes, (change) ->
        listOfIdentifiers.push change[3]

      )
      addContentModel = new AddContentModel()
      addContentModel.set ADD_CONTENT_MODEL_FIELDS.IDENTIFIERS, listOfIdentifiers
      addContentModel.set ADD_CONTENT_MODEL_FIELDS.WELLS_TO_UPDATE, wellsToUpdate
      unless @dataFieldToDisplay is "batchCode"
        updatedValues = @reformatUpdatedValues changes
        @wellsToUpdate.resetWells()
        _.each(updatedValues, (updatedValue) =>
          well = @wellsToUpdate.getWellAtRowIdxColIdx(updatedValue.rowIdx, updatedValue.colIdx)
          well[@dataFieldToDisplay] = updatedValue.value
          @wellsToUpdate.fillWellWithWellObject(updatedValue.rowIdx, updatedValue.colIdx, well)
        )
        @wellsToUpdate.save()
      else
        @trigger PLATE_TABLE_CONTROLLER_EVENTS.PLATE_CONTENT_UPADATED, addContentModel

  handleAcceptTruncatedPaste: =>
    console.log "handleAcceptTruncatedPaste"
    _.each(@pendingChanges, (pc) ->
      pc[2] = pc[3]
      #delete pc[3]
    )
    @addContent @pendingChanges
    @handleContentUpdated @pendingChanges, "paste"
    #$("div[name='handsontablePasteError']").modal('hide')

  identifiersValidated: (addContentModel) =>
    console.log "identifiersValidated"
    console.log "addContentModel"
    console.log addContentModel
    aliasedIdentifiers = _.map(addContentModel.get(ADD_CONTENT_MODEL_FIELDS.ALIASED_IDENTIFIERS), 'requestName')
    invalidIdentifiers = _.map(addContentModel.get(ADD_CONTENT_MODEL_FIELDS.INVALID_IDENTIFIERS), 'requestName')
    validIdentifiers = addContentModel.get(ADD_CONTENT_MODEL_FIELDS.VALIDATED_IDENTIFIERS)

    aliasedWells = _.filter(addContentModel.get(ADD_CONTENT_MODEL_FIELDS.WELLS_TO_UPDATE), (well)->
      return well.value in aliasedIdentifiers
    )

    invalidWells = _.filter(addContentModel.get(ADD_CONTENT_MODEL_FIELDS.WELLS_TO_UPDATE), (well)->
      return well.value in invalidIdentifiers
    )

    validWells =  _.filter(addContentModel.get(ADD_CONTENT_MODEL_FIELDS.WELLS_TO_UPDATE), (well)->
      return well.value in validIdentifiers
    )
    @wellsToUpdate.resetWells()
    _.each(aliasedWells, (aw) =>
      console.log "aw"
      console.log aw
      console.log "aliasedIdentifiers"
      console.log aliasedIdentifiers
      aliasedValue = _.each(addContentModel.get(ADD_CONTENT_MODEL_FIELDS.ALIASED_IDENTIFIERS), (ai) ->
        if ai.requestName is aw.value
          return true
        else
          return false
      )
      console.log "aliasedValue"
      console.log aliasedValue[0].preferredName
      cell = @handsOnTable.getCell(aw.rowIdx, aw.colIdx)
      well = @wellsToUpdate.getWellAtRowIdxColIdx(aw.rowIdx, aw.colIdx)
      well.status = "aliased"
      well[@dataFieldToDisplay] = aliasedValue[0].preferredName
      @wellsToUpdate.fillWellWithWellObject(aw.rowIdx, aw.colIdx, well)
      $(cell).addClass "aliasedIdentifierCell"
      $(cell).html aliasedValue[0].preferredName
    )
    console.log "invalidIdentifiers"
    console.log invalidIdentifiers
    _.each(invalidWells, (aw) =>
      cell = @handsOnTable.getCell(aw.rowIdx, aw.colIdx)
      well = @wellsToUpdate.getWellAtRowIdxColIdx(aw.rowIdx, aw.colIdx)
      well.status = "invalid"
      #@wellsToUpdate.fillWellWithWellObject(aw.rowIdx, aw.colIdx, well)
      $(cell).addClass "invalidIdentifierCell"
    )

    _.each(validWells, (aw) =>
      cell = @handsOnTable.getCell(aw.rowIdx, aw.colIdx)
      well = @wellsToUpdate.getWellAtRowIdxColIdx(aw.rowIdx, aw.colIdx)
      if well?
        well.status = "valid"
        well[@dataFieldToDisplay] = aw.value
        @wellsToUpdate.fillWellWithWellObject(aw.rowIdx, aw.colIdx, well)
        $(cell).removeClass "invalidIdentifierCell"
        $(cell).removeClass "aliasedIdentifierCell"
        console.log "removing higlighting for cell", aw.rowIdx, aw.colIdx
    )

#    @wellsToUpdate.resetWells()
#    _.each(updatedValues, (updatedValue) =>
#      well = @wellsToUpdate.getWellAtRowIdxColIdx(updatedValue.rowIdx, updatedValue.colIdx)
#      well[@dataFieldToDisplay] = updatedValue.value
#      @wellsToUpdate.fillWellWithWellObject(updatedValue.rowIdx, updatedValue.colIdx, well)
#    )
    @wellsToUpdate.save()

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

  toolTipCellRenderer: (instance, td, row, col, prop, value, cellProperties) =>
    console.log "toolTipCellRenderer"
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
      template: t
    })
    if well?
      if well.status?
        console.log "well with status"
        console.log well

        if well.status is "valid"
          $(td).removeClass "invalidIdentifierCell"
          $(td).removeClass "aliasedIdentifierCell"
        else if well.status is "invalid"
          $(td).addClass "invalidIdentifierCell"
        else if well.status is "aliased"
          $(td).addClass "aliasedIdentifierCell"

      unless @dataFieldToColorBy is "noColor"
        td = @applyBackgroundColorToCell(td, well)

    return td

  defaultCellRenderer: (instance, td, row, col, prop, value, cellProperties) =>
    console.log "defaultCellRenderer"
    Handsontable.renderers.TextRenderer.apply(@, arguments)
    wellData = @getWellDataAtRowCol(row, col)
    well = _.find(@wells, (w) ->
      if w.columnIndex is col and w.rowIndex is row
        return true
      else
        return false
    )
    if well?
      if well.status?
        console.log "well with status"
        console.log well

        if well.status is "valid"
          $(td).removeClass "invalidIdentifierCell"
          $(td).removeClass "aliasedIdentifierCell"
        else if well.status is "invalid"
          $(td).addClass "invalidIdentifierCell"
        else if well.status is "aliased"
          $(td).addClass "aliasedIdentifierCell"
      unless @dataFieldToColorBy is "noColor"
        td = @applyBackgroundColorToCell(td, well)

    return td

  applyBackgroundColorToCell: (td, well) =>
    if @dataFieldToColorBy is "batchCode"
      unless well.batchCode is ""
        td.style.background = @listOfBatchCodes[well.batchCode]
    else
      minRange = 1
      maxRange = 255
      unless isNaN(parseFloat(well[@dataFieldToColorBy]))
        conc = parseFloat(well[@dataFieldToColorBy])
        normVal = maxRange - parseInt(minRange + (Math.log(well[@dataFieldToColorBy]) - @minValue) * (maxRange - minRange) / (@maxValue - @minValue))

        td.style.background = "rgb(#{normVal},#{normVal},#{normVal})"

    td

module.exports =
  PlateTableController: PlateTableController
  PLATE_TABLE_CONTROLLER_EVENTS: PLATE_TABLE_CONTROLLER_EVENTS


