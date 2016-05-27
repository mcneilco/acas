_ = require('lodash')
$ = require('jquery')
Backbone = require('backbone')
BackboneValidation = require('backbone-validation')

_.extend(Backbone.Model.prototype, BackboneValidation.mixin);


WELL_MODEL_FIELDS =
  AMOUNT: 'amount'
  AMOUNT_UNITS: 'amountUnits'
  BATCH_CODE: 'batchCode'
  BATCH_CONC_UNITS: 'batchConcUnits'
  BATCH_CONCENTRATION: 'batchConcentration'
  COLUMN_INDEX: 'columnIndex'
  CONTAINER_CODE_NAME: 'containerCodeName'
  LEVEL: 'level'
  MESSAGE: 'message'
  PHYSICAL_STATE: 'physicalState'
  RECORDED_BY: 'recordedBy'
  RECORDED_DATE: 'recordedDate'
  ROW_INDEX: 'rowIndex'
  SOLVENT_CODE: 'solventCode'
  WELL_NAME: 'wellName'


class WellModel extends Backbone.Model
  defaults:
    "amount": ""
    "amountUnits": ""
    "batchCode": ""
    "batchConcUnits": "mM"
    "batchConcentration": ""
    "columnIndex": ""
    "containerCodeName": ""
    "level": ""
    "message": ""
    "physicalState": "liquid"
    "containerCodeName": ""
    "recordedBy": ""
    "recordedDate": ""
    "rowIndex": ""
    "solventCode": ""
    "wellName": ""

  validation:
    barcode:
      required: true
      msg: "Please the Plate ID"
    definition:
      required: true
      msg: "Please select the plate size"

  isWellEmpty: ->
    if ($.trim(@get(WELL_MODEL_FIELDS.BATCH_CODE)) is "") and ($.trim(@get(WELL_MODEL_FIELDS.AMOUNT)) is "") and ($.trim(@get(WELL_MODEL_FIELDS.BATCH_CONCENTRATION)) is "")
      return true
    else if (@get(WELL_MODEL_FIELDS.BATCH_CODE) is null) and (@get(WELL_MODEL_FIELDS.AMOUNT) is null) and (@get(WELL_MODEL_FIELDS.BATCH_CONCENTRATION) is null)
      return true
    else
      return false

  isWellEmptyZeroVolumeZeroConcentration: ->
    wellIsEmpty = true
    if ($.trim(@get(WELL_MODEL_FIELDS.BATCH_CODE)) is "") or (@get(WELL_MODEL_FIELDS.BATCH_CODE) is null)
      true
    else
      wellIsEmpty = false

    if ($.trim(@get(WELL_MODEL_FIELDS.AMOUNT)) is "") or (@get(WELL_MODEL_FIELDS.AMOUNT) is null) or (@get(WELL_MODEL_FIELDS.AMOUNT) is 0)
      true
    else
      wellIsEmpty = false

    if ($.trim(@get(WELL_MODEL_FIELDS.BATCH_CONCENTRATION)) is "") or (@get(WELL_MODEL_FIELDS.BATCH_CONCENTRATION) is null) or (@get(WELL_MODEL_FIELDS.BATCH_CONCENTRATION) is 0)
      true
    else
      wellIsEmpty = false

    wellIsEmpty


  isWellValid: ->
    if @isWellEmpty()
      return true
    else
      if isNaN(parseFloat(@get(WELL_MODEL_FIELDS.AMOUNT))) or isNaN(parseFloat(@get(WELL_MODEL_FIELDS.BATCH_CONCENTRATION)))
        return false
      else
        if ($.trim(@get(WELL_MODEL_FIELDS.BATCH_CODE)) isnt "") and ($.trim(@get(WELL_MODEL_FIELDS.AMOUNT)) isnt "") and ($.trim(@get(WELL_MODEL_FIELDS.BATCH_CONCENTRATION)) isnt "")
          return true
        else
          return false

class WellsModel extends Backbone.Model
  url: '/api/updateWellContentWithObject?copyPreviousValues=0'
  initialize: (options) ->
    @allWells = options.allWells

  defaults:
    'wells': []
    'wellsToSave': []

  getWellAtRowIdxColIdx: (rowIdx, colIdx) ->
    # 1-based index offset
    rowIdx++
    colIdx++
    well = _.find(@allWells, (w) ->
      if w.columnIndex is colIdx and w.rowIndex is rowIdx
        return true
      else
        return false
    )
    return well

  fillWell: (rowIndex, columnIndex, amount, batchCode, batchConcentration) ->
    well = @getWellAtRowIdxColIdx rowIndex, columnIndex
    canSave = true
    if amount?
      if isNaN(parseFloat(amount))
        well.amount = amount
        canSave = false
      else
        well.amount = parseFloat(amount)
    else
      well.amount = null

    well.amountUnits = "uL"

    if batchCode is ""
      well.batchCode = null
    else
      well.batchCode = batchCode

    if batchConcentration?
      if isNaN(parseFloat(batchConcentration))
        well.batchConcentration = batchConcentration
        canSave = false
      else
        well.batchConcentration = parseFloat(batchConcentration)
    else
      well.batchConcentration = null

    recordedDate = new Date()
    well.recordedDate = recordedDate.getTime()
    @get("wells").push well
    if canSave
      delete well['status']
      @get("wellsToSave").push well

  fillWellWithWellObject: (rowIndex, columnIndex, wellObject) ->
    well = @getWellAtRowIdxColIdx rowIndex, columnIndex
    canSave = true
    if wellObject.amount is ""
      well.amount = null
    else
      if wellObject.amount?
        if isNaN(parseFloat(wellObject.amount))
          well.amount = wellObject.amount
          canSave = false
        else
          well.amount = parseFloat(wellObject.amount)
      else
        well.amount = null
    well.amountUnits = "uL"
    well.batchConcUnits = "mM"
    well.physicalState = "liquid"

    if wellObject.batchCode is ""
      well.batchCode = null
    else
      well.batchCode = wellObject.batchCode

    if wellObject.batchConcentration is ""
      well.batchConcentration = null
    else
      if wellObject.batchConcentration?
        if isNaN(parseFloat(wellObject.batchConcentration))
          well.batchConcentration = wellObject.batchConcentration
          canSave = false
        else
          well.batchConcentration = parseFloat(wellObject.batchConcentration)

      else
        well.batchConcentration = null
    #well.batchConcentration = parseFloat(wellObject.batchConcentration)
    recordedDate = new Date()
    well.recordedDate = recordedDate.getTime()
    @get("wells").push well
    if canSave
      delete well['status']
      @get("wellsToSave").push well

  resetWells: =>
    @set("wells", [])
    @set("wellsToSave", [])

  getNumberOfEmptyWells: ->
    numberOfEmptyWells = _.reduce(@allWells, (memo, w) ->
      well = new WellModel(w)
      if well.isWellEmpty()
        memo++
      return memo
    , 0)

  isWellAtRowIdxColIdxEmpty: (rowIdx, colIdx) =>
    well = new WellModel(@getWellAtRowIdxColIdx(rowIdx, colIdx))
    return well.isWellEmptyZeroVolumeZeroConcentration()

  getNumberOfInvalidWells: ->
    numberOfEmptyWells = _.reduce(@allWells, (memo, w) ->
      well = new WellModel(w)
      unless well.isWellValid()
        memo++
      return memo
    , 0)

  getLowestVolumeForRegion: (region) ->
    colRange = [region.colStart..region.colStop]
    rowRange = [region.rowStart..region.rowStop]

    lowestVolume = Infinity
    _.each(colRange, (colIdx) =>
      _.each(rowRange, (rowIdx) =>
        well = @getWellAtRowIdxColIdx rowIdx, colIdx
        if well.amount < lowestVolume
          lowestVolume = well.amount
      )
    )

    lowestVolume

  allWellsInRegionHaveVolume: (region) ->
    colRange = [region.colStart..region.colStop]
    rowRange = [region.rowStart..region.rowStop]
    allWellsHaveVolume = true
    _.each(colRange, (colIdx) =>
      _.each(rowRange, (rowIdx) =>
        well = @getWellAtRowIdxColIdx rowIdx, colIdx
        if well.amount?
          if well.amount is ""
            allWellsHaveVolume = false
        else
          allWellsHaveVolume = false
      )
    )

    allWellsHaveVolume

  allWellsInRegionHaveConcentration: (region) ->
    colRange = [region.colStart..region.colStop]
    rowRange = [region.rowStart..region.rowStop]
    allWellsHaveConcentration = true
    _.each(colRange, (colIdx) =>
      _.each(rowRange, (rowIdx) =>
        well = @getWellAtRowIdxColIdx rowIdx, colIdx
        if well.batchConcentration?
          if well.batchConcentration is ""
            allWellsHaveConcentration = false
        else
          allWellsHaveConcentration = false
      )
    )

    allWellsHaveConcentration

  getLongestStringByFieldName: (fieldName) ->
    longestString = ""
    _.each(@allWells, (well) ->
      if well[fieldName]?
        if well[fieldName].length?
          if well[fieldName].length > longestString.length
            longestString = well[fieldName]
        else
          if well[fieldName].toString().length > longestString.length
            longestString = well[fieldName].toString()
    )

    longestString


module.exports =
  WellModel: WellModel
  WellsModel: WellsModel
  WELL_MODEL_FIELDS: WELL_MODEL_FIELDS