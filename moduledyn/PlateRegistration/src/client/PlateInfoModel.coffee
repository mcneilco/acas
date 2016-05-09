_ = require('lodash')
Backbone = require('backbone')
BackboneValidation = require('backbone-validation')

_.extend(Backbone.Model.prototype, BackboneValidation.mixin);


PLATE_INFO_MODEL_FIELDS =
  BARCODE: 'barcode'
  DESCRIPTION: 'description'
  PLATE_SIZE: 'plateSize'
  TYPE: 'type'
  STATUS: 'status'
  CREATED_DATE: 'createdDate'
  SUPPLIER: 'supplier'
  NUMBER_OF_COLUMNS: "numberOfColumns"
  NUMBER_OF_ROWS: "numberOfRows"
  PLATE_SIZE: "plateSize"


class PlateInfoModel extends Backbone.Model
  url: "/api/containerByContainerCode"

  defaults:
    barcode: ""
    description: ""
    plateSize: ""
    type: ""
    status: ""
    createdDate: ""
    supplier: ""
    numberOfColumns: ""
    numberOfRows: ""

  validation:
    plateSize: [
      required: true
      msg: "Please enter the plate size"
      ,
      pattern: 'number'
      msg: "Plate Size must be numeric"
    ]


module.exports =
  PlateInfoModel: PlateInfoModel
  PLATE_INFO_MODEL_FIELDS: PLATE_INFO_MODEL_FIELDS