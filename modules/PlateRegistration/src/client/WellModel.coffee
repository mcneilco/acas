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




module.exports =
  WellModel: WellModel
  WELL_MODEL_FIELDS: WELL_MODEL_FIELDS