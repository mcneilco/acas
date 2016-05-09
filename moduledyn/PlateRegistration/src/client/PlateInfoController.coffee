Backbone = require('backbone')
BackboneValidation = require('backbone-validation')

jQueryUI = require('imports?this=>window!../../../../public/lib/jquery-ui-1.10.2.custom/js/jquery-ui-1.10.2.custom.min.js')

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
    console.log "initializeSelectLists"
    selectedTypeCode = "unassigned"
    if @model.get("type")
      selectedTypeCode = @model.get("type")
    @plateTypesSelectList = new PickListSelectController
      el: $(@el).find("select[name='type']")
      collection: @plateTypes
      selectedCode: selectedTypeCode
      insertFirstOption: new PickList
        code: "unassigned"
        name: "Select Plate Type"
      className: "form-control"
      autoFetch: false

    selectedStatusCode = "unassigned"
    if @model.get("status")
      selectedStatusCode = @model.get("status")

    @plateStatusSelectList = new PickListSelectController
      el: $(@el).find("select[name='status']")
      collection: @plateStatuses
      selectedCode: selectedStatusCode
      insertFirstOption: new PickList
        code: "unassigned"
        name: "Select Plate Status"
      className: "form-control"
      autoFetch: false


  render: =>
    $(@el).html @template(@model.toJSON())

    @$("input[name='createdDate']").datepicker()
    if @model.get "createdDate"
      createdDate = new Date(@model.get "createdDate")
      @$("input[name='createdDate']").datepicker("setDate", createdDate)

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
    createdDate = @$("input[name='createdDate']").datepicker("getDate").getTime()

    @model.set "recordedBy", AppLaunchParams.loginUserName
    @model.set "createdDate", createdDate
    $.ajax(
      data: @model.toJSON()
      dataType: "json"
      method: "PUT"
      url: @model.url
    )
    .done((data, textStatus, jqXHR) =>
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
    # ensure the DOM has rendered before setting values
    nonImmediateSetSelect = _.debounce(() =>
      @initializeSelectLists()
    , 1)

    nonImmediateSetSelect()




module.exports =
  PlateInfoController: PlateInfoController
  PLATE_INFO_CONTROLLER_EVENTS: PLATE_INFO_CONTROLLER_EVENTS