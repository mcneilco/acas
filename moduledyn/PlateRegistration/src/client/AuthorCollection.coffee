Backbone = require('backbone')
_ = require('lodash')

PickListList = require('./SelectList.coffee').PickListList

AUTHOR_COLLECTION_CONST =
  URL: "api/authors"

class AuthorCollection extends Backbone.Collection
  url: ->
    AUTHOR_COLLECTION_CONST.URL

module.exports =
  AuthorCollection: AuthorCollection