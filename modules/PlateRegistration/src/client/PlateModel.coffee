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


class PlateModel extends Backbone.Model
  url: "/api/v1/containers/createPlate"

  defaults:
    "barcode": ""
    "definition": ""
    "description": ""
    "template": null
    "recordedBy": ""
    "supplier": ""
    "wells": ""

  validation:
    template:
      required: true
      msg: "Please Plate or Barcode"
    barcode:
      required: true
      msg: "Please the Plate ID"
    definition:
      required: true
      msg: "Please select the plate size"




module.exports =
  PlateModel: PlateModel
  PLATE_MODEL_FIELDS: PLATE_MODEL_FIELDS