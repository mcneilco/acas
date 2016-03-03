_ = require('lodash')
Backbone = require('backbone')
BackboneValidation = require('backbone-validation')

_.extend(Backbone.Model.prototype, BackboneValidation.mixin);


PLATE_INFO_MODEL_FIELDS =
  PLATE_BARCODE: 'plateBarcode'
  DESCRIPTION: 'description'
  PLATE_SIZE: 'plateSize'
  TYPE: 'type'
  STATUS: 'status'
  CREATED_DATE: 'createdDate'
  SUPPLIER: 'supplier'


class PlateInfoModel extends Backbone.Model
  defaults:
    plateBarcode: ""
    description: ""
    plateSize: ""
    type: ""
    status: ""
    createdDate: ""
    supplier: ""

  validation:
    plateBarcode:
      required: true
      msg: "Please enter a valid Plate Barcode"
    plateSize: [
      required: true
      msg: "Please enter the plate size"
      ,
      pattern: 'number'
      msg: "Plate Size must be numeric"
    ]
    status:
      required: true
      msg: "Please select a status"


module.exports =
  PlateInfoModel: PlateInfoModel
  PLATE_INFO_MODEL_FIELDS: PLATE_INFO_MODEL_FIELDS