Backbone = require('backbone')

_ = require('lodash')
$ = require('jquery')
Handsontable = require('imports?this=>window!../../../../public/lib/handsontable/dist/handsontable.full.js')
require("bootstrap-webpack!./bootstrap.config.js")

PlateFillerFactory = require('./PlateFillerFactory.coffee').PlateFillerFactory
SerialDilutionFactory = require('./SerialDilutionFactory.coffee').SerialDilutionFactory
WellsModel = require('./WellModel.coffee').WellsModel
WellModel = require('./WellModel.coffee').WellModel
WELL_MODEL_FIELDS = require('./WellModel.coffee').WELL_MODEL_FIELDS

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
  EMPTY_INVALID_COUNT_UPDATED: "emptyInvalidCountUpdated"

INITIAL_FONT_SIZE = 14

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
    @fontSize = INITIAL_FONT_SIZE
    @shouldFitToScreen = false

  render: =>
    $(@el).html @template()
    $(window).resize(_.debounce(@calculateLayout, 50))

    @

  completeInitialization: (wells, plateMetaData) =>
    @wells = wells
    @plateMetaData = plateMetaData
    @wellsToUpdate = new WellsModel({allWells: @wells})
    @updateEmptyAndInvalidWellCount()
    @renderHandsOnTable()

  updateEmptyAndInvalidWellCount: =>
    numEmpty = @wellsToUpdate.getNumberOfEmptyWells()
    numInvalid = @wellsToUpdate.getNumberOfInvalidWells()

    @trigger PLATE_TABLE_CONTROLLER_EVENTS.EMPTY_INVALID_COUNT_UPDATED, {numEmpty: numEmpty, numInvalid: numInvalid}

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
        maxCols: @plateMetaData.numberOfColumns
        startRows: @plateMetaData.numberOfRows
        maxRows: @plateMetaData.numberOfRows
        renderer: @toolTipCellRenderer
        beforeChange: @handleTableChangeRangeValidation
        afterChange: @handleContentUpdated
        afterSelection: @handleRegionSelected
        autoWrapCol: true
        autoWrapRow: true
        allowInsertColumn: false
        allowInsertRow: false
        stretchH: 'all'
      })
    else
      @handsOnTable = new Handsontable(container, {
        rowHeaders: rowHeaders.slice(0, @plateMetaData.numberOfRows)
        colHeaders: columnHeaders
        outsideClickDeselects: false
        startCols: @plateMetaData.numberOfColumns
        maxCols: @plateMetaData.numberOfColumns
        startRows: @plateMetaData.numberOfRows
        maxRows: @plateMetaData.numberOfRows
        renderer: @defaultCellRenderer
        afterChange: @handleContentUpdated
        beforeChange: @handleTableChangeRangeValidation
        afterSelection: @handleRegionSelected
        autoWrapCol: true
        autoWrapRow: true
        allowInsertColumn: false
        allowInsertRow: false
        stretchH: 'all'
        #beforeAutofill: @handleBeforeAutofill
      })

    hotData = @convertWellsDataToHandsonTableData(@dataFieldToDisplay)
    @addContent(hotData)
    @fitToScreen()

#  handleBeforeAutofill: (start, end, data) =>
##    console.log "handleBeforeAutofill"
##    rowIndexes = [start.row..end.row]
##    colIndexes = [start.col..end.col]
##    @wellsToUpdate.resetWells()
##    _.each(rowIndexes, (rowIdx) =>
##      _.each(colIndexes, (colIdx) =>
##        #cell = @handsOnTable.getCell(@wellToCopy.rowIndex - 1, @wellToCopy.columnIndex - 1)
##        autoFillAcrossColumns = false
##        wellsInSameRow = _.filter(@selectedWells, (well) =>
##          return (well.rowIndex - 1) is rowIdx
##        )
##
##        if _.size(wellsInSameRow) > 0
##          wellsInSameRow = _.sortBy(wellsInSameRow, "columnIndex")
##          lookUpColIdx = (colIdx - start.col) % _.size(wellsInSameRow)
##          @wellsToUpdate.fillWellWithWellObject(rowIdx, colIdx, wellsInSameRow[lookUpColIdx])
##        else
##          wellsInSameColumn = _.filter(@selectedWells, (well) =>
##            return (well.columnIndex - 1) is colIdx
##          )
##          wellsInSameColumn = _.sortBy(wellsInSameColumn, "rowIndex")
##
##          lookUpRowIdx = (rowIdx - start.row) % _.size(wellsInSameColumn)
##          @wellsToUpdate.fillWellWithWellObject(rowIdx, colIdx, wellsInSameColumn[lookUpRowIdx])
##
##        @updateColorByNoReRender()
##        if @displayToolTips
##          @updateTooltip(cell, @wellToCopy)
##        @handsOnTable.render()
##      )
##    )
#    @wellsToUpdate.save()
#    @updateEmptyAndInvalidWellCount()
#    #@trigger PLATE_TABLE_CONTROLLER_EVENTS.PLATE_CONTENT_UPADATED, addContentModel


  handleAfterDocumentKeyDown: (event) =>
    #console.log event.realTarget.hasClass "copyPaste"
    if $(event.realTarget).hasClass("copyPaste")
      @copiedSelectedRegion = true
    window.REALTARGET = event.realTarget

    event


  increaseFontSize: =>
    @fontSize = @fontSize + 2
    #@handsOnTable.init()
    @handsOnTable.render()
    @calculateLayout()

  decreaseFontSize: =>
    if @fontSize > 2
      @fontSize = @fontSize - 2
    #@handsOnTable.render()
    @calculateLayout()

  updateDataDisplayed: (dataFieldToDisplay) =>
    @dataFieldToDisplay = dataFieldToDisplay
    if @dataFieldToDisplay is "masterView"
      @displayToolTips = true
      @fitToScreen()
      @renderHandsOnTable()
      @updateColorBy("status")
      @handsOnTable.updateSettings({readOnly: true})
    else
      @handsOnTable.updateSettings({readOnly: false})
    hotData = @convertWellsDataToHandsonTableData(dataFieldToDisplay)
    @addContent(hotData)
    @calculateLayout()

  updateColorByNoReRender: =>
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
      else if @dataFieldToColorBy is "status"
        @listWellStatusColors = {}
        _.each(@wells, (well) =>
          w = new WellModel(well)
          color = '#00bb00'
          fontColor = 'black'
          if w.isWellEmpty()
            color = '#dddddd'
          else
            if w.isWellValid()
              color = '#00bb00'
            else
              color = '#a94442'
              fontColor = 'white'

          @listWellStatusColors[w.get(WELL_MODEL_FIELDS.CONTAINER_CODE_NAME)] = {backgroundColor: color, fontColor: fontColor}
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
      else if @dataFieldToColorBy is "status"
        @listWellStatusColors = {}
        _.each(@wells, (well) =>
          w = new WellModel(well)
          color = '#00bb00'
          fontColor = 'black'
          if w.isWellEmpty()
            color = '#dddddd'
          else
            if w.isWellValid()
              color = '#00bb00'
            else
              color = '#a94442'
              fontColor = 'white'

          @listWellStatusColors[w.get(WELL_MODEL_FIELDS.CONTAINER_CODE_NAME)] = {backgroundColor: color, fontColor: fontColor}
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
    validatedIdentifiers = addContentModel.get(ADD_CONTENT_MODEL_FIELDS.VALIDATED_IDENTIFIERS)
    plateFiller = @plateFillerFactory.getPlateFiller(addContentModel.get(ADD_CONTENT_MODEL_FIELDS.FILL_STRATEGY), addContentModel.get(ADD_CONTENT_MODEL_FIELDS.FILL_DIRECTION),  validatedIdentifiers, @selectedRegionBoundries, @plateMetaData)
    wellContentOverwritten = []
    @identifiersToRemove = []
    @wellsToUpdate.resetWells()
    [@plateWells, @identifiersToRemove, @wellsToUpdate, wellContentOverwritten] = plateFiller.getWells(@wells, addContentModel.get("batchConcentration"), addContentModel.get("amount"))
    if wellContentOverwritten
      $("div[name='overwrittingWellContentsWarning']").modal('show')
    else
      @saveUpdatedWellContent()

  handleInsertOverwrittenWellsAnyway: =>
    @saveUpdatedWellContent()

  saveUpdatedWellContent: =>
    @wellsToUpdate.save()
    @updateEmptyAndInvalidWellCount()
    @trigger PLATE_TABLE_CONTROLLER_EVENTS.PLATE_CONTENT_UPADATED, @identifiersToRemove
    @addContent1 @plateWells

  applyDilution: (dilutionModel) =>
    dilutionStrategy = @serialDilutionFactory.getSerialDilutionStrategy(dilutionModel, @selectedRegionBoundries)
    @plateWells = dilutionStrategy.getWells(@wells)

    @addContent1 @plateWells

  addContent: (data) =>
    @handsOnTable.setDataAtCell data, 'programaticEdit'
    @updateColorByNoReRender()
    @handsOnTable.render()

  addContent1: (data) =>
    hotData = []
    _.each(data, (d) =>
      hotData.push([d[0], d[1], d[2][@dataFieldToDisplay]])
    )
    @handsOnTable.setDataAtCell hotData, 'programaticEdit'
    @updateColorByNoReRender()
    @handsOnTable.render()

  handleRegionSelected: (rowStart, colStart, rowStop, colStop) =>
    @selectedRegionBoundries =
      rowStart: rowStart
      colStart: colStart
      rowStop:  rowStop
      colStop: colStop
    @selectedWells = []
    rowIndexes = [rowStart..rowStop]
    colIndexes = [colStart..colStop]
    _.each(rowIndexes, (rowIdx) =>
      _.each(colIndexes, (colIdx) =>
        @selectedWells.push(@wellsToUpdate.getWellAtRowIdxColIdx(rowIdx, colIdx))
      )
    )
    @trigger PLATE_TABLE_CONTROLLER_EVENTS.REGION_SELECTED, {selectedRegionBoundries: @selectedRegionBoundries, lowestVolumeWell: @wellsToUpdate.getLowestVolumeForRegion(@selectedRegionBoundries), allWellsHaveVolume: @wellsToUpdate.allWellsInRegionHaveVolume(@selectedRegionBoundries), allWellsHaveConcentration: @wellsToUpdate.allWellsInRegionHaveConcentration(@selectedRegionBoundries)}

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
    if @dataFieldToDisplay is "masterView"
      return false
    else
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
    if source in ["edit", "autofill", "paste"]
      listOfIdentifiers = []
      @resetCellColoring(changes)
      changes = @removeNonChangedValues(changes)
      unless _.size(changes) is 0
        wellsToUpdate = @reformatUpdatedValues changes
        _.each(changes, (change) ->
          if change?
            listOfIdentifiers.push change[3]
        )
        addContentModel = new AddContentModel()
        addContentModel.set ADD_CONTENT_MODEL_FIELDS.IDENTIFIERS, listOfIdentifiers
        addContentModel.set ADD_CONTENT_MODEL_FIELDS.WELLS_TO_UPDATE, wellsToUpdate
        hasIdentifiersToValidate = false
        _.each(addContentModel.get("identifiers"), (identifier, key) ->
          if _.size(identifier) > 0
            hasIdentifiersToValidate = true
          else
            addContentModel.get("identifiers").splice(key, 1)
        )
        if @dataFieldToDisplay is "batchCode"
          if hasIdentifiersToValidate
            @trigger PLATE_TABLE_CONTROLLER_EVENTS.ADD_IDENTIFIER_CONTENT_FROM_TABLE, addContentModel
          else
            updatedValues = @reformatUpdatedValues changes
            @wellsToUpdate.resetWells()
            _.each(updatedValues, (updatedValue) =>
              well = @wellsToUpdate.getWellAtRowIdxColIdx(updatedValue.rowIdx, updatedValue.colIdx)
              well[@dataFieldToDisplay] = updatedValue.value
              cell = @handsOnTable.getCell(well.rowIndex - 1, well.columnIndex - 1)
              if $.trim(updatedValue.value) is ""
                @wellsToUpdate.fillWellWithWellObject(updatedValue.rowIdx, updatedValue.colIdx, well)
                well.status = "valid"
                $(cell).removeClass "invalidIdentifierCell"
              else
                @wellsToUpdate.fillWellWithWellObject(updatedValue.rowIdx, updatedValue.colIdx, well)
                well.status = "valid"
                $(cell).removeClass "invalidIdentifierCell"
              @updateColorByNoReRender()
              if @displayToolTips
                @updateTooltip(cell, well)
              #@applyBackgroundColorToCell(cell, well)
              @handsOnTable.render()
            )
            @wellsToUpdate.save()
            @updateEmptyAndInvalidWellCount()
            @trigger PLATE_TABLE_CONTROLLER_EVENTS.PLATE_CONTENT_UPADATED, addContentModel

        else
          unless @dataFieldToDisplay is "batchCode"
            updatedValues = @reformatUpdatedValues changes
            @wellsToUpdate.resetWells()
            hasNonNumericValues = false
            _.each(updatedValues, (updatedValue) =>
              well = @wellsToUpdate.getWellAtRowIdxColIdx(updatedValue.rowIdx, updatedValue.colIdx)
              well[@dataFieldToDisplay] = updatedValue.value
              cell = @handsOnTable.getCell(well.rowIndex - 1, well.columnIndex - 1)
              if $.trim(updatedValue.value) is ""
                @wellsToUpdate.fillWellWithWellObject(updatedValue.rowIdx, updatedValue.colIdx, well)

                well.status = "valid"
                $(cell).removeClass "invalidIdentifierCell"
              else if isNaN(parseFloat(updatedValue.value))

                well.status = "invalid"
                @wellsToUpdate.fillWellWithWellObject(well.rowIndex - 1, well.columnIndex - 1, well)
                $(cell).addClass "invalidIdentifierCell"
                hasNonNumericValues = true
              else
                @wellsToUpdate.fillWellWithWellObject(updatedValue.rowIdx, updatedValue.colIdx, well)

                well.status = "valid"
                $(cell).removeClass "invalidIdentifierCell"
              @updateColorByNoReRender()
              if @displayToolTips
                @updateTooltip(cell, well)
              #@applyBackgroundColorToCell(cell, well)
              @handsOnTable.render()

            )
            if hasNonNumericValues
              $("div[name='enteringNonNumericConcentrationError']").modal("show")
            @wellsToUpdate.save()
            @updateEmptyAndInvalidWellCount()

            @trigger PLATE_TABLE_CONTROLLER_EVENTS.PLATE_CONTENT_UPADATED, addContentModel

  removeNonChangedValues: (changes) =>
    for change, idx in changes
      if ((change[2] is null) and (change[3] is "")) or (change[2] is change[3])
        delete changes[idx]

    changes

  resetCellColoring: (changes) =>
    for change, idx in changes
      if change[3] is ""
        cell = @handsOnTable.getCell(change[0], change[1])
        $(cell).removeClass "invalidIdentifierCell"

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
        well[@dataFieldToDisplay] = aw.value
        @wellsToUpdate.fillWellWithWellObject(aw.rowIdx, aw.colIdx, well)
        $(cell).removeClass "invalidIdentifierCell"
        $(cell).removeClass "aliasedIdentifierCell"
        @updateColorByNoReRender()
        if @displayToolTips
          @updateTooltip(cell, well)
        #@applyBackgroundColorToCell(cell, well)
        @handsOnTable.render()
    )

    wellsToSaveTmp = new WellsModel({allWells: []})
    unless _.size(@wellsToUpdate.get('wellsToSave')) is 0
      $("div[name='updatingWellContents']").modal("show")
      wellsToSaveTmp.set("wellsToSave", @wellsToUpdate.get('wellsToSave'))
      wellsToSaveTmp.save(null, {
        success: (result) =>
          $("div[name='updatingWellContents']").modal('hide')
          @updateEmptyAndInvalidWellCount()
        error: (result) =>
          console.log "save error..."
      })
    else
      @updateEmptyAndInvalidWellCount()

  reformatUpdatedValues: (changes) ->
    updateValue = []
    _.each(changes, (change) ->
      if change?
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
    @attachTooltip(td, well, col)

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

  attachTooltip: (td, well, colIdx) =>
    content = @generateTooltipContent(well)

    template = '<div class="popover" role="tooltip"><div class="arrow"></div><h3 class="popover-title"></h3><div class="popover-content"></div></div>'
    popupPlacement = "right"
    if colIdx > (@plateMetaData.numberOfColumns / 2)
      popupPlacement = "left"
    $(td).popover({
      animation: false
      trigger: 'hover active'
      title: "Well Details: #{well.wellName}"
      placement: popupPlacement
      container: 'body'
      html: true
      content: content
      template: template
    })

  updateTooltip: (td, well) =>
    content = @generateTooltipContent(well)
    popover = $(td).data('bs.popover')
    popover.options.content = content

  generateTooltipContent: (well) ->
    batchCode = ""
    amount = ""
    batchConcentration = ""

    if well.batchCode?
      batchCode = well.batchCode
    if well.amount?
      amount = well.amount
    if well.batchConcentration?
      batchConcentration = well.batchConcentration
    content = "Batch Code: " + batchCode + "<br />Volume: " + amount + "<br />Concentration: " + batchConcentration

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
    else if @dataFieldToColorBy is "status"
      td.style.background = @listWellStatusColors[well[WELL_MODEL_FIELDS.CONTAINER_CODE_NAME]].backgroundColor
      td.style.color = @listWellStatusColors[well[WELL_MODEL_FIELDS.CONTAINER_CODE_NAME]].fontColor
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
      if @minValue is @maxValue
        backgroundColor = "rgb(0,255,0)"
      else
        logVal = parseFloat(well[@dataFieldToColorBy])
        midValue = (@minValue + @maxValue) / 2

        if logVal > midValue
          #normVal = ((parseInt(minRange + (logVal - midValue) * (maxRange - minRange) / (@maxValue - midValue))))
          normVal = ((maxRange - parseInt(minRange + (logVal - midValue) * (maxRange - minRange) / (@maxValue - midValue))))
          backgroundColor = "rgb(#{normVal},255,0)"

        else
          #normVal = 255 - ((maxRange + parseInt(minRange + (midValue - logVal) * (maxRange - minRange) / (midValue - @minValue))))
          normVal = 255 - ((parseInt(minRange + (midValue - logVal) * (maxRange - minRange) / (midValue - @minValue))))
          backgroundColor = "rgb(255,#{normVal},0)"
    backgroundColor

  showAll: =>
    @handsOnTable.updateSettings({
      colWidths: null,
      rowHeights: null
    })
    @handsOnTable.render()

  fitToContents: =>
    @shouldFitToScreen = false
    columnWidth = @getContentWidth()
    height = $(".editorHandsontable").height()

    rowHeight = (height - 50) / @plateMetaData.numberOfRows

    if columnWidth < 60
      columnWidth = null
    @handsOnTable.updateSettings({
      colWidths: columnWidth,
      rowHeights: rowHeight
    })
    #@handsOnTable.init()
    @handsOnTable.render()

  fitToScreen: =>
    @shouldFitToScreen = true
    @calculateLayout()

  calculateLayout: =>
    width = ($(".editorHandsontable").width() - 20) # allow offset for vertical scroll bar
    height = $(".editorHandsontable").height()
    columnWidth = (width - 60) / @plateMetaData.numberOfColumns
    rowHeight = (height - 50) / @plateMetaData.numberOfRows
    if rowHeight < 23
      rowHeight = 23
    if @shouldFitToScreen
      @handsOnTable.updateSettings({
        colWidths: columnWidth,
        rowHeights: rowHeight
      })
    else
      columnWidth = @getContentWidth()
      if columnWidth < 60
        columnWidth = null
      @handsOnTable.updateSettings({
        colWidths: columnWidth,
        rowHeights: rowHeight
      })
    #@handsOnTable.init()
    @handsOnTable.render()

  getContentWidth: =>
    longestString = @wellsToUpdate.getLongestStringByFieldName(@dataFieldToDisplay) + "M"
    $(".bv_textWidthContainer").html(longestString)
    $(".bv_textWidthContainer")[0].style.fontSize = "#{@fontSize}px"
    columnWidth = $(".bv_textWidthContainer").width()

    columnWidth

  maximizeTable: =>
    @$(".editorHandsontable").css("left", "100px")
    @calculateLayout()

  minimizeTable: =>
    @$(".editorHandsontable").css("left", "350px")
    @calculateLayout()

module.exports =
  PlateTableController: PlateTableController
  PLATE_TABLE_CONTROLLER_EVENTS: PLATE_TABLE_CONTROLLER_EVENTS


