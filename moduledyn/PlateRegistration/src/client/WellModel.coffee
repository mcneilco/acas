_ = require('lodash')
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

  getNumberOfInvalidWells: ->
    numberOfEmptyWells = _.reduce(@allWells, (memo, w) ->
      well = new WellModel(w)
      unless well.isWellValid()
        memo++
      return memo
    , 0)


module.exports =
  WellModel: WellModel
  WellsModel: WellsModel
  WELL_MODEL_FIELDS: WELL_MODEL_FIELDS