Backbone = require('backbone')
_ = require('lodash')
$ = require('jquery')

PLATE_INFO_CONTROLLER_EVENTS =
  DELETE_PLATE: 'deletePlate'
  CREATE_QUAD_PINNED_PLATE: 'createQuadPinnedPlate'

class PlateInfoController extends Backbone.View
  template: _.template(require('html!./PlateInfoTemplate.html'))

  initialize: (options) ->
    @plateTypes = options.plateTypes
    @plateStatuses = options.plateStatuses
    @model = options.model

  events:
    "change input": "updateModel"
    "click button[name='delete']": "handleDeleteClick"
    "click button[name='createQuadPinnedPlate']": "handleCreateQuadPinnedPlateClick"

  render: =>
    $(@el).html @template()

    @

  updateModel: (evt) =>
    target = $(evt.currentTarget)
    data = {}
    data[target.attr('name')] = $.trim(target.val())
    @model.set(data)

  handleDeleteClick: =>
    @trigger PLATE_INFO_CONTROLLER_EVENTS.DELETE_PLATE

  handleCreateQuadPinnedPlateClick: =>
    @trigger PLATE_INFO_CONTROLLER_EVENTS.CREATE_QUAD_PINNED_PLATE


module.exports =
  PlateInfoController: PlateInfoController
  PLATE_INFO_CONTROLLER_EVENTS: PLATE_INFO_CONTROLLER_EVENTS