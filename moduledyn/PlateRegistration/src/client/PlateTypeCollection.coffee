_ = require('lodash')
Backbone = require('backbone')
PickListList = require('./SelectList.coffee').PickListList

PLATE_TYPE_COLLECTION_CONST =
  URL: "api/codetables/type/container%20plate"


class PlateTypeCollection extends PickListList
  url: ->
    PLATE_TYPE_COLLECTION_CONST.URL

module.exports =
  PlateTypeCollection: PlateTypeCollection
  PLATE_TYPE_COLLECTION_CONST: PLATE_TYPE_COLLECTION_CONST

