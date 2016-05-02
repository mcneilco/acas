Backbone = require('backbone')
BackboneValidation = require('backbone-validation')
_ = require('lodash')
$ = require('jquery')

PickListSelectController = require('./SelectList.coffee').PickListSelectController
PickList = require('./SelectList.coffee').PickList

PLATE_INFO_CONTROLLER_EVENTS =
  DELETE_PLATE: 'deletePlate'
  CREATE_QUAD_PINNED_PLATE: 'createQuadPinnedPlate'
  MODEL_UPDATE_VALID: 'model_update_valid'
  MODEL_UPDATE_INVALID: 'model_update_INvalid'


_.extend(Backbone.Validation.callbacks, {
  valid: (view, attr, selector) ->
    $el = view.$('[name=' + attr + ']')
    $group = $el.closest('.form-group');

    $group.removeClass('has-error');
    $group.find('.help-block').html('').addClass('hidden');

  invalid: (view, attr, error, selector) ->
    $el = view.$('[name=' + attr + ']')
    $group = $el.closest('.form-group');

    $group.addClass('has-error');
    $group.find('.help-block').html(error).removeClass('hidden');

})


class PlateInfoController extends Backbone.View
  template: _.template(require('html!./PlateInfoTemplate.tmpl'))

  initialize: (options) ->
    Backbone.Validation.bind(@)
    @model = options.model
    @plateTypes = options.plateTypes
    @plateStatuses = options.plateStatuses
    #@plateStatusSelectList = new SelectList({collection: @plateStatuses, selectedValue: @model.get('status')})
    @selectLists = [
      controller: @plateTypesSelectList
      containerSelector: "select[name='type']"
    ,
      controller: @plateStatusSelectList
      containerSelector: "select[name='status']"
    ]

  events:
    "change input": "handleFormFieldUpdate"
    "change select": "handleFormFieldUpdate"
    "click button[name='delete']": "handleDeleteClick"
    "click button[name='createQuadPinnedPlate']": "handleCreateQuadPinnedPlateClick"

  initializeSelectLists: =>
    @plateTypesSelectList = new PickListSelectController
      el: $(@el).find("select[name='type']")
      collection: @plateTypes
      insertFirstOption: new PickList
        code: "unassigned"
        name: "Select Plate Type"
      selectedCode: "unassigned"
      className: "form-control"

    if @model.get("type")?
      @plateTypesSelectList.setSelectedCode(@model.get("type"))

    @plateStatusSelectList = new PickListSelectController
      el: $(@el).find("select[name='status']")
      collection: @plateStatuses
      insertFirstOption: new PickList
        code: "unassigned"
        name: "Select Plate Status"
      selectedCode: "unassigned"
      className: "form-control"

    if @model.get("status")?
      @plateStatusSelectList.setSelectedCode(@model.get("status"))

  render: =>
    $(@el).html @template(@model.toJSON())
    @initializeSelectLists()

    @

  handleFormFieldUpdate: (evt) ->
    target = $(evt.currentTarget)
    data = {}
    data[target.attr('name')] = $.trim(target.val())
    @updateModel data

  handleDeleteClick: =>
    @trigger PLATE_INFO_CONTROLLER_EVENTS.DELETE_PLATE

  handleCreateQuadPinnedPlateClick: =>
    @trigger PLATE_INFO_CONTROLLER_EVENTS.CREATE_QUAD_PINNED_PLATE

  updateModel: (data) =>
    originalBarcode = @model.get("barcode")


    @model.set data
    #date = new Date()
    @model.set "recordedBy", AppLaunchParams.loginUserName
    @model.set "createdDate", null
    $.ajax(
      data: @model.toJSON()
      dataType: "json"
      method: "PUT"
      url: @model.url
    )
    .done((data, textStatus, jqXHR) =>
      console.log "data"
      console.log data
      if originalBarcode isnt @model.get("barcode")
        appRouter.navigate("/plateDesign/#{@model.get('barcode')}")
    )
    .fail((jqXHR, textStatus, errorThrown) =>
      console.error("something went wrong updating plate meta data")
      console.log errorThrown
      if errorThrown is "Conflict"
        $("div[name='barcodeConflictErrorMessage']").modal('show')
        @$("a[name='barcode']").prop("href", "#plateDesign/#{@model.get('barcode')}")
        @$("a[name='barcode']").html @model.get("barcode")
    )

    if @model.isValid(true)

      @trigger PLATE_INFO_CONTROLLER_EVENTS.MODEL_UPDATE_VALID
    else
      @trigger PLATE_INFO_CONTROLLER_EVENTS.MODEL_UPDATE_INVALID



  updatePlate: (plate) =>
    @model.set plate
    @render()



module.exports =
  PlateInfoController: PlateInfoController
  PLATE_INFO_CONTROLLER_EVENTS: PLATE_INFO_CONTROLLER_EVENTS