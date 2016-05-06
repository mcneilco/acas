_ = require('lodash')
Backbone = require('backbone')
BackboneValidation = require('backbone-validation')

_.extend(Backbone.Model.prototype, BackboneValidation.mixin);


PLATE_MODEL_FIELDS =
  BARCODE: "barcode"
  DEFINITION: "definition"
  DESCRIPTION: "description"
  TEMPLATE: "template"
  RECORDED_BY: "recordedBy"
  SUPPLIER: "supplier"
  WELLS: "wells"
  NUMBER_OF_COLUMNS: "numberOfColumns"
  NUMBER_OF_ROWS: "numberOfRows"
  PLATE_SIZE: "plateSize"

MAX_BARCODE_LENGTH = 40

class PlateModel extends Backbone.Model
  url: "/api/v1/containers/createPlate"

  defaults:
    "barcode": ""
    "definition": ""
    "description": ""
    "template": null
    "recordedBy": ""
    "supplier": ""
    "createdDate": ""
    "physicalState": "liquid"
    "batchConcentrationUnits": "mM"
    "wells": []

  validation:
    barcode:[
      required: true
      msg: "Please the Plate ID"
      ,
      maxLength: MAX_BARCODE_LENGTH
      msg: "Barcodes can only contain #{MAX_BARCODE_LENGTH} characters"
    ]
    definition: (value) ->
      if value is "unassigned"
        return "Please select the plate size"

  reset: ->
    @.set
      "barcode": ""
      "definition": ""
      "description": ""
      "template": null
      "recordedBy": "acas"
      "supplier": ""
      "wells": []




module.exports =
  PlateModel: PlateModel
  PLATE_MODEL_FIELDS: PLATE_MODEL_FIELDS