_ = require('lodash')
Backbone = require('backbone')
PickListList = require('./SelectList.coffee').PickListList

PLATE_TYPE_COLLECTION_CONST =
  #URL: "/api/containers/codetable?lsType=definition%20container&lsKind=plate"
  URL: "/api/containers/definition%20container/plate?format=codetable"


class PlateTypeCollection extends PickListList
  url: ->
    PLATE_TYPE_COLLECTION_CONST.URL

module.exports =
  PlateTypeCollection: PlateTypeCollection
  PLATE_TYPE_COLLECTION_CONST: PLATE_TYPE_COLLECTION_CONST