_ = require('lodash')
Backbone = require('backbone')
SelectListCollection = require('./SelectList.coffee').SelectListCollection

PLATE_TYPE_COLLECTION_CONST =
  #URL: "/api/containers/codetable?lsType=definition%20container&lsKind=plate"
  URL: "/api/containers/definition%20container/plate"


class PlateTypeCollection extends SelectListCollection
  url: ->
    PLATE_TYPE_COLLECTION_CONST.URL

module.exports =
  PlateTypeCollection: PlateTypeCollection
  PLATE_TYPE_COLLECTION_CONST: PLATE_TYPE_COLLECTION_CONST