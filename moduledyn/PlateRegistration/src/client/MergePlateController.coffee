Backbone = require('backbone')

MAX_PLATE_SIZE = 384

class MergePlatesController extends Backbone.View
  template: _.template(require('html!./MergePlate.tmpl'))

  initialize: ->
    @inputPlateSizes = null
    @destinationPlate = {
      barcode: ""
      isValid: false
    }
    @plateQuadrants = {
      plateQuadrant1: {
        codeName: ""
        barcode: ""
        isValid: false
        plateSize: ""
      }
      plateQuadrant2: {
        codeName: ""
        barcode: ""
        isValid: false
        plateSize: ""
      }
      plateQuadrant3: {
        codeName: ""
        barcode: ""
        isValid: false
        plateSize: ""
      }
      plateQuadrant4: {
        codeName: ""
        barcode: ""
        isValid: false
        plateSize: ""
      }
    }

  events:
    "click button[name='mergePlate']": "handleMergePlateClick"
    "change input[name='plateQuadrant1']": "handlePlateQuadrantBarcodeChange"
    "change input[name='plateQuadrant2']": "handlePlateQuadrantBarcodeChange"
    "change input[name='plateQuadrant3']": "handlePlateQuadrantBarcodeChange"
    "change input[name='plateQuadrant4']": "handlePlateQuadrantBarcodeChange"
    "change input[name='destinationPlateBarcode']": "handleDestinationPlateBarcodeChange"

  render: =>
    $(@el).html @template()
    @setStateOfSubmitButton()

    @

  handlePlateQuadrantBarcodeChange: (evt) =>
    target = $(evt.currentTarget)
    plateNotFoundErrorSelector = evt.currentTarget.name + "_barcodeNodeFound"

    @$("div[name='sourcePlateTooBig']").addClass("hide")
    $("span[name='#{plateNotFoundErrorSelector}']").addClass("hide")
    @$("div[name='errorMessages']").addClass "hide"
    $(evt.currentTarget).parent().removeClass("has-error")
    $(evt.currentTarget).parent().removeClass("has-success")
    $(evt.currentTarget).parent().find(".glyphicon-warning-sign").addClass("hide")
    $(evt.currentTarget).parent().find(".glyphicon-ok").addClass("hide")

    if AppLaunchParams.enforceUppercaseBarcodes
      barcode = _.toUpper(target.val())
      target.val barcode
    else
      barcode = target.val()
    $.ajax(
      dataType: "json"
      method: 'get'
      url: "/api/getContainerAndDefinitionContainerByContainerLabel/#{barcode}"
    )
    .done((data, textStatus, jqXHR) =>
      if data.plateSize > MAX_PLATE_SIZE
        @$("div[name='sourcePlateTooBig']").removeClass("hide")
        $(evt.currentTarget).parent().addClass("has-error")
        $(evt.currentTarget).parent().find(".glyphicon-warning-sign").removeClass("hide")
        @plateQuadrants[evt.currentTarget.name].isValid = false
      else
        @plateQuadrants[evt.currentTarget.name].barcode = barcode
        @plateQuadrants[evt.currentTarget.name].codeName = data.codeName
        @plateQuadrants[evt.currentTarget.name].plateSize = data.plateSize
        plateSizeIsValid = @validatePlateSizes()
        if plateSizeIsValid
          $(evt.currentTarget).parent().addClass("has-success")
          $(evt.currentTarget).parent().find(".glyphicon-ok").removeClass("hide")
          @plateQuadrants[evt.currentTarget.name].isValid = true
        else
          $(evt.currentTarget).parent().addClass("has-error")
          $(evt.currentTarget).parent().find(".glyphicon-warning-sign").removeClass("hide")
          @$("div[name='errorMessages']").removeClass("hide")
          @plateQuadrants[evt.currentTarget.name].isValid = false

      @setStateOfSubmitButton()
    )
    .fail((jqXHR, textStatus, errorThrown) =>
      @plateQuadrants[evt.currentTarget.name].barcode = ""
      @plateQuadrants[evt.currentTarget.name].codeName = ""
      @plateQuadrants[evt.currentTarget.name].isValid = false
      $("span[name='#{plateNotFoundErrorSelector}']").removeClass("hide")
      $(evt.currentTarget).parent().addClass("has-error")
      $(evt.currentTarget).parent().find(".glyphicon-warning-sign").removeClass("hide")
      @setStateOfSubmitButton()
    )

  isValid: =>
    if @destinationPlate.isValid
      if @sourcePlatesAreValid()
        return true
      else
        return false
    else
      return false

  sourcePlatesAreValid: =>
    isValid = true
    _.each(@plateQuadrants, (plate) =>
      unless plate.codeName is ""
        unless plate.isValid
          isValid = false
    )
    if isValid
      isValid = false
      _.each(@plateQuadrants, (plate) =>
        unless plate.barcode is ""
          isValid = true
      )

      if isValid
        isValid = @validatePlateSizes()

    return isValid

  setStateOfSubmitButton: =>
    if @isValid()
      console.log "valid -- enable submit button"
      @$("button[name='mergePlate']").prop('disabled', false)
      @$("button[name='mergePlate']").removeClass('disabled')
    else
      console.log "invalid -- disable submit button"
      @$("button[name='mergePlate']").prop('disabled', true)
      @$("button[name='mergePlate']").addClass('disabled')

  validatePlateSizes: =>
    platesAreSameSize = true
    plateSize = null
    _.each(@plateQuadrants, (plate) =>
      unless plate.plateSize is ""
        if plateSize?
          unless plate.plateSize is plateSize
            platesAreSameSize = false
        else
          plateSize = plate.plateSize
    )
    return platesAreSameSize

  handleDestinationPlateBarcodeChange: (evt) =>
    target = $(evt.currentTarget)
    $(evt.currentTarget).parent().removeClass("has-success")
    $(evt.currentTarget).parent().removeClass("has-error")
    $(evt.currentTarget).parent().find(".glyphicon-ok").addClass("hide")
    $(evt.currentTarget).parent().find(".glyphicon-warning-sign").addClass("hide")
    @$("span[name='destinationPlateBarcodeAlreadyInUse']").addClass("hide")
    if AppLaunchParams.enforceUppercaseBarcodes
      barcode = _.toUpper(target.val())
      target.val barcode
    else
      barcode = target.val()
    $.ajax(
      dataType: "json"
      method: 'get'
      url: "/api/getContainerAndDefinitionContainerByContainerLabel/#{barcode}"
    )
    .done((data, textStatus, jqXHR) =>
      @destinationPlate.isValid = false
      $(evt.currentTarget).parent().addClass("has-error")
      @$("span[name='destinationPlateBarcodeAlreadyInUse']").removeClass "hide"
      $(evt.currentTarget).parent().find(".glyphicon-warning-sign").removeClass("hide")
      @setStateOfSubmitButton()
    )
    .fail((jqXHR, textStatus, errorThrown) =>
      $(evt.currentTarget).parent().addClass("has-success")
      $(evt.currentTarget).parent().find(".glyphicon-ok").removeClass("hide")
      @destinationPlate.isValid = true
      @setStateOfSubmitButton()
    )

  handleMergePlateClick: =>

    @setupAndDisplayMergingDialogBox()
    destinationBarcode = @$("input[name='destinationPlateBarcode']").val()
    mergedPlate =
      "barcode": destinationBarcode
      "recordedBy": "acas",
      "description": "test merge plate",
      "quadrants": []

    unless @plateQuadrants["plateQuadrant1"].codeName is ""
      mergedPlate.quadrants.push({
        "quadrant": 1,
        "codeName": @plateQuadrants["plateQuadrant1"].codeName
      })

    unless @plateQuadrants["plateQuadrant2"].codeName is ""
      mergedPlate.quadrants.push({
        "quadrant": 2,
        "codeName": @plateQuadrants["plateQuadrant2"].codeName
      })

    unless @plateQuadrants["plateQuadrant3"].codeName is ""
      mergedPlate.quadrants.push({
        "quadrant": 3,
        "codeName": @plateQuadrants["plateQuadrant3"].codeName
      })

    unless @plateQuadrants["plateQuadrant4"].codeName is ""
      mergedPlate.quadrants.push({
        "quadrant": 4,
        "codeName": @plateQuadrants["plateQuadrant4"].codeName
      })

    $.ajax(
      data: mergedPlate
      dataType: "json"
      method: 'post'
      url: "/api/mergeContainers"
    )
    .done((data, textStatus, jqXHR) =>
      @displayMergeSuccessMessages data
      @resetForm()
    )
    .fail((jqXHR, textStatus, errorThrown) =>
      @displayMergeErrorMessages(destinationBarcode)
    )

  displayMergeErrorMessages: (destinationBarcode) =>
    @$("a[name='barcode']").prop("href", "#plateDesign/#{destinationBarcode}")
    @$("a[name='barcode']").html destinationBarcode
    @$("div[name='duplicateBarcodeErrorMessage']").removeClass "hide"
    @$("span[name='dialogDismissButtons']").removeClass "hide"
    @$("span[name='mergingStatus']").addClass "hide"

  displayMergeSuccessMessages: (data) =>
    @$("a[name='linkToNewPlate']").prop("href", "#plateDesign/#{data.barcode}")
    @$("span[name='mergedPlateName']").html data.barcode

    @$("div[name='mergedPlateLink']").removeClass "hide"
    @$("span[name='mergingStatus']").addClass "hide"
    @$("span[name='dialogDismissButtons']").removeClass "hide"

  setupAndDisplayMergingDialogBox: =>
    @$("div[name='duplicateBarcodeErrorMessage']").addClass "hide"
    @$("a[name='barcode']").prop("href", "#plateDesign/")
    @$("a[name='barcode']").html ""

    @$("a[name='linkToNewPlate']").prop("href", "#plateDesign/")
    @$("div[name='mergedPlateLink']").addClass "hide"
    @$("span[name='mergingStatus']").removeClass "hide"
    @$("span[name='dialogDismissButtons']").addClass "hide"

    @$("div[name='mergePlateDialogBox']").modal(
      keyboard: false
      backdrop: 'static'
    )

  resetForm: =>
    @plateQuadrants["plateQuadrant1"].codeName = ""
    @plateQuadrants["plateQuadrant1"].isValid = false
    #@plateQuadrants["plateQuadrant1"].plateSize = ""

    @plateQuadrants["plateQuadrant2"].codeName = ""
    @plateQuadrants["plateQuadrant2"].isValid = false
    #@plateQuadrants["plateQuadrant2"].plateSize = ""

    @plateQuadrants["plateQuadrant3"].codeName = ""
    @plateQuadrants["plateQuadrant3"].isValid = false
    #@plateQuadrants["plateQuadrant3"].plateSize = ""

    @plateQuadrants["plateQuadrant4"].codeName = ""
    @plateQuadrants["plateQuadrant4"].isValid = false
    #@plateQuadrants["plateQuadrant4"].plateSize = ""

    @destinationPlate = {
      barcode: ""
      isValid: false
    }

    @$("input[name='destinationPlateBarcode']").val("")
    @$("input[name='plateQuadrant1']").val("")
    @$("input[name='plateQuadrant2']").val("")
    @$("input[name='plateQuadrant3']").val("")
    @$("input[name='plateQuadrant4']").val("")

    @$("input[name='destinationPlateBarcode']").parent().removeClass("has-error")
    @$("input[name='destinationPlateBarcode']").parent().removeClass("has-success")

    @$("input[name='plateQuadrant1']").parent().removeClass("has-error")
    @$("input[name='plateQuadrant1']").parent().removeClass("has-success")
    @$("input[name='plateQuadrant2']").parent().removeClass("has-error")
    @$("input[name='plateQuadrant2']").parent().removeClass("has-success")
    @$("input[name='plateQuadrant3']").parent().removeClass("has-error")
    @$("input[name='plateQuadrant3']").parent().removeClass("has-success")
    @$("input[name='plateQuadrant4']").parent().removeClass("has-error")
    @$("input[name='plateQuadrant4']").parent().removeClass("has-success")
    $(".glyphicon-ok").addClass("hide")
    $(".glyphicon-warning-sign").addClass("hide")

    @setStateOfSubmitButton()


exports.MergePlatesController = MergePlatesController