Backbone = require('backbone')
PlateTableController = require('./PlateTableController.coffee').PlateTableController
PLATE_TABLE_CONTROLLER_EVENTS = require('./PlateTableController.coffee').PLATE_TABLE_CONTROLLER_EVENTS

_ = require('lodash')
$ = require('jquery')


PLATE_VIEW_CONTROLLER_EVENTS = []


class PlateViewController extends Backbone.View
  template: _.template(require('html!./PlateViewView.tmpl'))

  initialize: ->
    @plateTableController = new PlateTableController()
    @plateTableController.on PLATE_TABLE_CONTROLLER_EVENTS.REGION_SELECTED, @handleRegionSelected

  completeInitialization: =>
    @plateTableController.completeInitialization()

  render: =>
    $(@el).html @template()
    @$("div[name='plateTableContainer']").html @plateTableController.render().el

    @

  handleRegionSelected: (selectedRegionBoundries) =>
    @trigger PLATE_TABLE_CONTROLLER_EVENTS.REGION_SELECTED, selectedRegionBoundries

  handleContentUpdated: (updatedValues) =>
    @trigger PLATE_TABLE_CONTROLLER_EVENTS.PLATE_CONTENT_UPADATED, updatedValues

  addContent: (data) =>
    @plateTableController.handleContentAdded data


module.exports =
  PlateViewController: PlateViewController