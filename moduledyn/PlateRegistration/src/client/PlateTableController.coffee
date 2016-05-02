Backbone = require('backbone')

_ = require('lodash')
$ = require('jquery')
Handsontable = require('imports?this=>window!../../../../public/lib/handsontable/dist/handsontable.full.js')
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
  ADD_IDENTIFIER_CONTENT_FROM_TABLE: "AddIdentifierContentFromTable"



class PlateTableController extends Backbone.View
  template: _.template(require('html!./PlateTableView.tmpl'))

  events:
    "click button[name='pasteTruncatedIdentifiersAnyway']": "handleAcceptTruncatedPaste"
    "click button[name='insertOverwrittenWellsAnyway']": "handleInsertOverwrittenWellsAnyway"

  initialize: ->
    @plateFillerFactory = new PlateFillerFactory()
    @serialDilutionFactory = new SerialDilutionFactory()
    @displayToolTips = false
    @dataFieldToDisplay = "batchCode"
    @dataFieldToColorBy = "noColor"
    @listOfBatchCodes = {}
    @fontSize = 14;
    window.FOOTABLECONTROLLER = @
    $(window).resize(_.debounce(@calculateLayout, 100))
    @shouldFitToScreen = false

  render: =>
    $(@el).html @template()

    @

  completeInitialization: (wells, plateMetaData) =>
    @wells = wells
    @plateMetaData = plateMetaData
    @wellsToUpdate = new WellsModel({allWells: @wells})
    @renderHandsOnTable()

  renderHandsOnTable: =>
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
        rowHeaders: rowHeaders.slice(0, @plateMetaData.numberOfRows)
        colHeaders: columnHeaders
        outsideClickDeselects: false
        startCols: @plateMetaData.numberOfColumns
        startRows: @plateMetaData.numberOfRows
        renderer: @defaultCellRenderer
        afterChange: @handleContentUpdated
        beforeChange: @handleTableChangeRangeValidation
        afterSelection: @handleRegionSelected
      })
    window.FOOHOT = @handsOnTable
    hotData = @convertWellsDataToHandsonTableData(@dataFieldToDisplay)
    @addContent(hotData)
    @fitToScreen()

  increaseFontSize: =>
    @fontSize = @fontSize + 2
    @handsOnTable.init()

  decreaseFontSize: =>
    if @fontSize > 2
      @fontSize = @fontSize - 2
    @handsOnTable.render()

  updateDataDisplayed: (dataFieldToDisplay) =>
    @dataFieldToDisplay = dataFieldToDisplay
    if @dataFieldToDisplay is "masterView"
      @displayToolTips = true
      @fitToScreen()
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
              fontColor = "black"
              if (rComponent + gComponent + bComponent) < 256
                fontColor = "white"
              @listOfBatchCodes[well["batchCode"]] = {backgroundColor: color, fontColor: fontColor}
              bComponent += 85
              if bComponent > 255
                bComponent = bComponent - 255
                gComponent += 85
                if gComponent > 255
                  gComponent = gComponent - 255
                  rComponent += 85
        )
      else
        minValue = Infinity
        maxValue = -Infinity
        _.each(@wells, (well) =>
          unless isNaN(parseFloat(well[@dataFieldToColorBy]))
            if well[@dataFieldToColorBy] < minValue
              if well[@dataFieldToColorBy] is 0
                minValue = 0.000001
              else
                minValue = well[@dataFieldToColorBy]
            if well[@dataFieldToColorBy] > maxValue
              maxValue = well[@dataFieldToColorBy]
        )

        if minValue is 0
          @minValue = minValue
        else
          if @dataFieldToColorBy is "batchConcentration"
            @minValue = Math.log(minValue)
          else
            @minValue = minValue
        if maxValue < 0
          maxValue = 0

        if maxValue is 0
          @maxValue = maxValue
        else
          if @dataFieldToColorBy is "batchConcentration"
            @maxValue = Math.log(maxValue)
          else
            @maxValue = maxValue

    @renderHandsOnTable()

  convertWellsDataToHandsonTableData: (dataField) =>
    hotData = []
    _.each(@wells, (well) ->
      wellData = ""
      unless dataField is "masterView"
        wellData = well[dataField]
      hotData.push [(well.rowIndex - 1), (well.columnIndex - 1), wellData]
    )
    return hotData

  handleContentAdded: (addContentModel) =>
    console.log "handleContentAdded"
    validatedIdentifiers = addContentModel.get(ADD_CONTENT_MODEL_FIELDS.VALIDATED_IDENTIFIERS)
    plateFiller = @plateFillerFactory.getPlateFiller(addContentModel.get(ADD_CONTENT_MODEL_FIELDS.FILL_STRATEGY), addContentModel.get(ADD_CONTENT_MODEL_FIELDS.FILL_DIRECTION),  validatedIdentifiers, @selectedRegionBoundries)
    wellContentOverwritten = []
    @identifiersToRemove = []
    [@plateWells, @identifiersToRemove, @wellsToUpdate, wellContentOverwritten] = plateFiller.getWells(@wells, addContentModel.get("batchConcentration"), addContentModel.get("amount"))
    if wellContentOverwritten
      $("div[name='overwrittingWellContentsWarning']").modal('show')
    else
      @saveUpdatedWellContent()

  handleInsertOverwrittenWellsAnyway: =>
    @saveUpdatedWellContent()

  saveUpdatedWellContent: =>
    console.log("@wellsToUpdate.get('wells')")
    console.log(@wellsToUpdate.get('wells'))

    @wellsToUpdate.save()
    @trigger PLATE_TABLE_CONTROLLER_EVENTS.PLATE_CONTENT_UPADATED, @identifiersToRemove
    @addContent1 @plateWells

  applyDilution: (dilutionModel) =>
    dilutionStrategy = @serialDilutionFactory.getSerialDilutionStrategy(dilutionModel, @selectedRegionBoundries)
    @plateWells = dilutionStrategy.getWells(@wells)

    @addContent1 @plateWells

  addContent: (data) =>
    @handsOnTable.setDataAtCell data, 'programaticEdit'
    @handsOnTable.init() # force re-render so tooltip content is updated

  addContent1: (data) =>
    hotData = []
    _.each(data, (d) =>
      hotData.push([d[0], d[1], d[2][@dataFieldToDisplay]])
    )
    @handsOnTable.setDataAtCell hotData, 'programaticEdit'
    #@handsOnTable.init() # force re-render so tooltip content is updated

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
      invalidRows = @validatePasteContentRowRange changes, @plateMetaData.numberOfRows
      invalidCols = @validatePasteContentColumnRange changes, @plateMetaData.numberOfColumns
      invalidEntries = _.union(invalidRows, invalidCols)
      validEntries = _.difference(changes, invalidEntries)
      if _.size(invalidEntries) > 0
        @pendingChanges = validEntries
        $("div[name='handsontablePasteError']").modal('show')

        return false

  handleContentUpdated: (changes, source) =>
    console.log "handleContentUpdated"
    console.log source
    if source in ["edit", "autofill", "paste"]
      listOfIdentifiers = []
      wellsToUpdate = @reformatUpdatedValues changes
      _.each(changes, (change) ->
        listOfIdentifiers.push change[3]

      )
      addContentModel = new AddContentModel()
      addContentModel.set ADD_CONTENT_MODEL_FIELDS.IDENTIFIERS, listOfIdentifiers
      addContentModel.set ADD_CONTENT_MODEL_FIELDS.WELLS_TO_UPDATE, wellsToUpdate
      hasIdentifiersToValidate = false
      _.each(addContentModel.get("identifiers"), (identifier, key) ->
        console.log "key"
        console.log key
        if _.size(identifier) > 0
          hasIdentifiersToValidate = true
        else
          addContentModel.get("identifiers").splice(key, 1)
      )
      if hasIdentifiersToValidate and @dataFieldToDisplay is "batchCode"
        @trigger PLATE_TABLE_CONTROLLER_EVENTS.ADD_IDENTIFIER_CONTENT_FROM_TABLE, addContentModel

      else
        updatedValues = @reformatUpdatedValues changes
        @wellsToUpdate.resetWells()
        _.each(updatedValues, (updatedValue) =>
          well = @wellsToUpdate.getWellAtRowIdxColIdx(updatedValue.rowIdx, updatedValue.colIdx)
          well[@dataFieldToDisplay] = updatedValue.value
          @wellsToUpdate.fillWellWithWellObject(updatedValue.rowIdx, updatedValue.colIdx, well)
        )

        @wellsToUpdate.save()
        @trigger PLATE_TABLE_CONTROLLER_EVENTS.PLATE_CONTENT_UPADATED, addContentModel

  handleAcceptTruncatedPaste: =>
    _.each(@pendingChanges, (pc) ->
      pc[2] = pc[3]
    )
    @addContent @pendingChanges
    @handleContentUpdated @pendingChanges, "paste"

  identifiersValidated: (addContentModel) =>
    aliasedIdentifiers = _.map(addContentModel.get(ADD_CONTENT_MODEL_FIELDS.ALIASED_IDENTIFIERS), 'requestName')
    invalidIdentifiers = _.map(addContentModel.get(ADD_CONTENT_MODEL_FIELDS.INVALID_IDENTIFIERS), 'requestName')
    validIdentifiers = addContentModel.get(ADD_CONTENT_MODEL_FIELDS.VALIDATED_IDENTIFIERS)
    console.log "addContentModel"
    console.log addContentModel
    aliasedWells = _.filter(addContentModel.get(ADD_CONTENT_MODEL_FIELDS.WELLS_TO_UPDATE), (well)->
      return well.value in aliasedIdentifiers
    )

    invalidWells = _.filter(addContentModel.get(ADD_CONTENT_MODEL_FIELDS.WELLS_TO_UPDATE), (well)->
      return well.value in invalidIdentifiers
    )
    if validIdentifiers?
      validWells =  _.filter(addContentModel.get(ADD_CONTENT_MODEL_FIELDS.WELLS_TO_UPDATE), (well)->
        return well.value in validIdentifiers
      )
    else
      validWells = []
    @wellsToUpdate.resetWells()
    _.each(aliasedWells, (aw) =>
      aliasedValue = _.each(addContentModel.get(ADD_CONTENT_MODEL_FIELDS.ALIASED_IDENTIFIERS), (ai) ->
        if ai.requestName is aw.value
          return true
        else
          return false
      )
      cell = @handsOnTable.getCell(aw.rowIdx, aw.colIdx)
      well = @wellsToUpdate.getWellAtRowIdxColIdx(aw.rowIdx, aw.colIdx)
      well.status = "aliased"
      well[@dataFieldToDisplay] = aliasedValue[0].preferredName
      @wellsToUpdate.fillWellWithWellObject(aw.rowIdx, aw.colIdx, well)
      $(cell).addClass "aliasedIdentifierCell"
      $(cell).html aliasedValue[0].preferredName
    )
    _.each(invalidWells, (aw) =>
      cell = @handsOnTable.getCell(aw.rowIdx, aw.colIdx)
      well = @wellsToUpdate.getWellAtRowIdxColIdx(aw.rowIdx, aw.colIdx)
      well.status = "invalid"
      $(cell).addClass "invalidIdentifierCell"
    )

    _.each(validWells, (aw) =>
      cell = @handsOnTable.getCell(aw.rowIdx, aw.colIdx)
      well = @wellsToUpdate.getWellAtRowIdxColIdx(aw.rowIdx, aw.colIdx)
      if well?
        well.status = "valid"
        console.log "aw.value"
        console.log aw.value
        well[@dataFieldToDisplay] = aw.value
        @wellsToUpdate.fillWellWithWellObject(aw.rowIdx, aw.colIdx, well)
        $(cell).removeClass "invalidIdentifierCell"
        $(cell).removeClass "aliasedIdentifierCell"
    )
    $("div[name='updatingWellContents']").modal("show")
    wellsToSaveTmp = new WellsModel({allWells: []})
    wellsToSaveTmp.set("wells", @wellsToUpdate.get('wells'))

    wellsToSaveTmp.save(null, {
      success: (result) =>
        $("div[name='updatingWellContents']").modal('hide')
      error: (result) =>
        console.log "save error..."
    })

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

  toolTipCellRenderer: (instance, td, row, col, prop, value, cellProperties) =>
    Handsontable.renderers.TextRenderer.apply(@, arguments)
    wellData = @getWellDataAtRowCol(row, col)
    well = _.find(@wells, (w) ->
      if w.columnIndex is (col + 1) and w.rowIndex is (row + 1)
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
        if well.status is "valid"
          $(td).removeClass "invalidIdentifierCell"
          $(td).removeClass "aliasedIdentifierCell"
        else if well.status is "invalid"
          $(td).addClass "invalidIdentifierCell"
        else if well.status is "aliased"
          $(td).addClass "aliasedIdentifierCell"

      unless @dataFieldToColorBy is "noColor"
        td = @applyBackgroundColorToCell(td, well)
    td.style.fontSize = "#{@fontSize}px"
    return td

  defaultCellRenderer: (instance, td, row, col, prop, value, cellProperties) =>
    Handsontable.renderers.TextRenderer.apply(@, arguments)
    wellData = @getWellDataAtRowCol(row, col)
    well = _.find(@wells, (w) ->
      if w.columnIndex is (col + 1) and w.rowIndex is (row + 1)
        return true
      else
        return false
    )
    if well?
      if well.status?
        if well.status is "valid"
          $(td).removeClass "invalidIdentifierCell"
          $(td).removeClass "aliasedIdentifierCell"
        else if well.status is "invalid"
          $(td).addClass "invalidIdentifierCell"
        else if well.status is "aliased"
          $(td).addClass "aliasedIdentifierCell"
      unless @dataFieldToColorBy is "noColor"
        td = @applyBackgroundColorToCell(td, well)

    td.style.fontSize = "#{@fontSize}px"

    return td

  applyBackgroundColorToCell: (td, well) =>
    if @dataFieldToColorBy is "batchCode"
      unless well.batchCode is ""
        if @listOfBatchCodes[well.batchCode]?
          td.style.background = @listOfBatchCodes[well.batchCode].backgroundColor
          td.style.color = @listOfBatchCodes[well.batchCode].fontColor
    else if @dataFieldToColorBy is "batchConcentration"
      backgroundColor = @calculateBackgroundColorForConcentration(well)
      td.style.background = backgroundColor
    else
      backgroundColor = @calculateBackgroundColorForVolume(well)
      td.style.background = backgroundColor

    td

  calculateBackgroundColorForConcentration: (well) =>
    minRange = 1
    maxRange = 255
    backgroundColor = ""
    unless isNaN(parseFloat(well[@dataFieldToColorBy]))
      conc = parseFloat(well[@dataFieldToColorBy])

      normVal = 255
      if Math.log(well[@dataFieldToColorBy]) is -Infinity
        backgroundColor = "rgb(0,255,0)"
      else if @minValue is @maxValue
        backgroundColor = "rgb(0,255,0)"
      else
        if @dataFieldToColorBy is "batchConcentration"
          logVal = Math.log(well[@dataFieldToColorBy])
        else
          logVal = well[@dataFieldToColorBy]
        midValue = (@minValue + @maxValue) / 2


        if logVal > midValue
          normVal = ((maxRange - parseInt(minRange + (logVal - midValue) * (maxRange - minRange) / (@maxValue - midValue))))
          backgroundColor = "rgb(255,#{normVal},0)"
        else
          normVal = 255 - ((parseInt(minRange + (midValue - logVal) * (maxRange - minRange) / (midValue - @minValue))))
          backgroundColor = "rgb(#{normVal},255,0)"
    backgroundColor

  calculateBackgroundColorForVolume: (well) =>
    minRange = 1
    maxRange = 255
    backgroundColor = ""
    unless isNaN(parseFloat(well[@dataFieldToColorBy]))
      conc = parseFloat(well[@dataFieldToColorBy])
      normVal = 255
      if Math.log(well[@dataFieldToColorBy]) is -Infinity
        backgroundColor = "rgb(255,0,0)"
      else if @minValue is @maxValue
        backgroundColor = "rgb(0,255,0)"
      else
        if @dataFieldToColorBy is "batchConcentration"
          logVal = Math.log(well[@dataFieldToColorBy])
        else
          logVal = well[@dataFieldToColorBy]
        midValue = (@minValue + @maxValue) / 2


        if logVal < midValue
          normVal = ((parseInt(minRange + (logVal - midValue) * (maxRange - minRange) / (@maxValue - midValue))))
          backgroundColor = "rgb(255,#{normVal},0)"
        else
          normVal = 255 - ((maxRange - parseInt(minRange + (midValue - logVal) * (maxRange - minRange) / (midValue - @minValue))))
          backgroundColor = "rgb(#{normVal},255,0)"
    backgroundColor

  showAll: =>
    @handsOnTable.updateSettings({
      colWidths: null,
      rowHeights: null
    })
    @handsOnTable.render()

  fitToContents: =>
    @shouldFitToScreen = false

    @handsOnTable.updateSettings({
      colWidths: null,
      rowHeights: null
    })
    @handsOnTable.init()
    #@handsOnTable.render()

  fitToScreen: =>
    @shouldFitToScreen = true
    @calculateLayout()

  calculateLayout: =>
    if @shouldFitToScreen
      width = $(".editorHandsontable").width()
      height = $(".editorHandsontable").height()
      columnWidth = (width - 60) / @plateMetaData.numberOfColumns
      rowHeight = (height - 50) / @plateMetaData.numberOfRows
      @handsOnTable.updateSettings({
        colWidths: columnWidth,
        rowHeights: rowHeight
      })
    else
      @handsOnTable.updateSettings({
        colWidths: null,
        rowHeights: null
      })

    @handsOnTable.render()


module.exports =
  PlateTableController: PlateTableController
  PLATE_TABLE_CONTROLLER_EVENTS: PLATE_TABLE_CONTROLLER_EVENTS


