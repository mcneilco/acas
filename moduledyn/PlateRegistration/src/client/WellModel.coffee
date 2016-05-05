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
    "batchConcUnits": ""
    "batchConcentration": ""
    "columnIndex": ""
    "containerCodeName": ""
    "level": ""
    "message": ""
    "physicalState": ""
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
      if ($.trim(@get(WELL_MODEL_FIELDS.BATCH_CODE)) isnt "") and ($.trim(@get(WELL_MODEL_FIELDS.AMOUNT)) isnt "") and ($.trim(@get(WELL_MODEL_FIELDS.BATCH_CONCENTRATION)) isnt "")
        return true
      else
        return false

class WellsModel extends Backbone.Model
  url: '/api/updateWellContentWithObject'
  initialize: (options) ->
    @allWells = options.allWells

  defaults:
    'wells': []

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
    well.amount = parseFloat(amount)
    well.amountUnits = "uL"
    well.batchCode = batchCode
    well.batchConcentration = parseFloat(batchConcentration)
    recordedDate = new Date()
    well.recordedDate = recordedDate.getTime()
    @get("wells").push well

  fillWellWithWellObject: (rowIndex, columnIndex, wellObject) ->
    well = @getWellAtRowIdxColIdx rowIndex, columnIndex
    well.amount = parseFloat(wellObject.amount)
    well.amountUnits = "uL"
    well.batchCode = wellObject.batchCode
    well.batchConcentration = parseFloat(wellObject.batchConcentration)
    recordedDate = new Date()
    well.recordedDate = recordedDate.getTime()
    @get("wells").push well

  resetWells: =>
    @set("wells", [])

  getNumberOfEmptyWells: ->
    numberOfEmptyWells = _.reduce(@allWells, (memo, w) ->
      well = new WellModel(w)
      if well.isWellEmpty()
        memo++
      else
        window.FOOWELL = well
      return memo
    , 0)

  getNumberOfInvalidWells: ->
    numberOfEmptyWells = _.reduce(@allWells, (memo, w) ->
      well = new WellModel(w)
      unless well.isWellValid()
        memo++
      else
        window.FOOWELL = well
      return memo
    , 0)


module.exports =
  WellModel: WellModel
  WellsModel: WellsModel
  WELL_MODEL_FIELDS: WELL_MODEL_FIELDS