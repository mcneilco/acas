Backbone = require('backbone')
$ = require('jquery')
_ = require('lodash')

class ClonePlateController extends Backbone.View
  tagName: 'tr'
  template: """
    <td>
      <input type="text" class="form-control" name="clonedPlateBarcode" value="<%= clonePlateBarcode %>"/>
    </td>
    <td>
      <p class='bv_cloningMessage hide'>Cloning...</p>
      <a href="" class='btn btn-primary bv_linkToNewPlate hide' target="_blank">Edit</a>
      <p class='bv_barcodeAlreadyUsedError hide'>Error: duplicate barcode</p>
    </td>
"""
  events:
    "change input[name='clonedPlateBarcode']":"handleClonePlateBarcodeChange"

  initialize: (options) ->
    @clonePlateBarcode = options.clonePlateBarcode
    @sourcePlateBarcode = options.sourcePlateBarcode
    @saved = false

  setControlToSaving: =>
    @$(".bv_barcodeAlreadyUsedError").addClass "hide"
    @$("input[name='clonedPlateBarcode']").addClass "disabled"
    @$("input[name='clonedPlateBarcode']").prop("disabled", true)
    @$(".bv_cloningMessage").removeClass "hide"


  setControlToSavingSuccess: =>
    @$(".bv_cloningMessage").addClass "hide"
    @$(".bv_linkToNewPlate").prop("href","#plateDesign/#{@getBarcode()}")
    @$(".bv_linkToNewPlate").removeClass "hide"

  setControlToSavingError: =>
    @$(".bv_barcodeAlreadyUsedError").removeClass "hide"
    @$(".bv_cloningMessage").addClass "hide"
    @$("input[name='clonedPlateBarcode']").removeClass "disabled"
    @$("input[name='clonedPlateBarcode']").prop("disabled", false)

  getBarcode: =>
    @$("input[name='clonedPlateBarcode']").val()

  handleClonePlateBarcodeChange: =>
    if AppLaunchParams.enforceUppercaseBarcodes
      cloneBarcodes = _.toUpper(@$("input[name='clonedPlateBarcode']").val())
      @$("input[name='clonedPlateBarcode']").val(cloneBarcodes)

  saveClonedPlate: =>
    deferred = $.Deferred()
    unless @saved
      clonePlateBarcode = @getBarcode()
      @setControlToSaving()
      data = {
        codeName: @sourcePlateBarcode
        barcode: clonePlateBarcode
      }

      $.ajax(
        data: data
        dataType: "json"
        method: "POST"
        url: "api/cloneContainer"
      )
      .done((data, textStatus, jqXHR) =>
        @setControlToSavingSuccess()
        @saved = true
        deferred.resolve(true)
      )
      .fail((jqXHR, textStatus, errorThrown) =>
        @setControlToSavingError()
        @saved = false
        deferred.resolve(false)
      )
    else
      deferred.resolve(true)
    deferred

  render: =>
    compiledTemplate = _.template(@template)
    $(@el).html compiledTemplate({clonePlateBarcode: @clonePlateBarcode})

    @


module.exports =
  ClonePlateController: ClonePlateController