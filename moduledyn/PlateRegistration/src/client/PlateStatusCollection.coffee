Backbone = require('backbone')
_ = require('lodash')

PickListList = require('./SelectList.coffee').PickListList

PLATE_STATUS_COLLECTION_CONST =
  URL: "api/codetables/status/container"

class PlateStatusCollection extends Backbone.Collection
  url: ->
    PLATE_STATUS_COLLECTION_CONST.URL

module.exports =
  PlateStatusCollection: PlateStatusCollection