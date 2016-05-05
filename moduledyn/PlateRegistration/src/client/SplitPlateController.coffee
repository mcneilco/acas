MINIMUM_PLATE_SIZE = 384

class SplitPlatesController extends Backbone.View
  template: _.template(require('html!./SplitPlate.tmpl'))

  initialize: ->
    @inputPlateSizes = null
    @sourcePlate = {
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
    "click button[name='splitPlate']": "handleSplitPlateClick"
    "change input[name='plateQuadrant1']": "handlePlateQuadrantBarcodeChange"
    "change input[name='plateQuadrant2']": "handlePlateQuadrantBarcodeChange"
    "change input[name='plateQuadrant3']": "handlePlateQuadrantBarcodeChange"
    "change input[name='plateQuadrant4']": "handlePlateQuadrantBarcodeChange"
    "change input[name='sourcePlateBarcode']": "handleSourcePlateBarcodeChange"

  handlePlateQuadrantBarcodeChange: (evt) =>
    plateFoundErrorSelector = evt.currentTarget.name + "_barcodeFound"
    existingPlateLinkSelector = evt.currentTarget.name + "_existingPlateLink"
    target = $(evt.currentTarget)
    if AppLaunchParams.enforceUppercaseBarcodes
      barcode = _.toUpper(target.val())
      target.val barcode
    else
      barcode = target.val()
    @plateQuadrants[evt.currentTarget.name].barcode = barcode
    if @destinationPlatesAreUnique()
      @$("div[name='duplicateBarcodeErrorMessage']").addClass "hide"
      $.ajax(
        dataType: "json"
        method: 'get'
        url: "/api/getContainerAndDefinitionContainerByContainerLabel/#{barcode}"
      )
      .done((data, textStatus, jqXHR) =>
        @plateQuadrants[evt.currentTarget.name].isValid = false

        $("a[name='#{existingPlateLinkSelector}']").prop("href", "#plateDesign/#{barcode}")
        $("a[name='#{existingPlateLinkSelector}']").html barcode
        $("span[name='#{plateFoundErrorSelector}']").removeClass("hide")
        $(evt.currentTarget).parent().removeClass("has-success")
        $(evt.currentTarget).parent().addClass("has-error")
        $(evt.currentTarget).parent().find(".glyphicon-ok").addClass("hide")
        $(evt.currentTarget).parent().find(".glyphicon-warning-sign").removeClass("hide")

        @setStateOfSubmitButton()
      )
      .fail((jqXHR, textStatus, errorThrown) =>
        $("span[name='#{plateFoundErrorSelector}']").addClass("hide")


        @plateQuadrants[evt.currentTarget.name].isValid = true
        $("span[name='#{plateFoundErrorSelector}']").addClass("hide")
        $(evt.currentTarget).parent().addClass("has-success")
        $(evt.currentTarget).parent().removeClass("has-error")

        $(evt.currentTarget).parent().find(".glyphicon-ok").removeClass("hide")
        $(evt.currentTarget).parent().find(".glyphicon-warning-sign").addClass("hide")

        @setStateOfSubmitButton()
      )
    else
      @setStateOfSubmitButton()
      @$("div[name='duplicateBarcodeErrorMessage']").removeClass "hide"

  isValid: =>
    if @sourcePlate.isValid
      if @destinationPlatesAreValid()
        if @destinationPlatesAreUnique()
          return true
        else
          return false
      else
        return false
    else
      return false

  destinationPlatesAreValid: =>
    isValid = true
    _.each(@plateQuadrants, (plate) =>
      if plate.barcode is ""
        isValid = false
    )

    return isValid

  destinationPlatesAreUnique: =>
    plateBarcodes = {}
    isValid = true
    _.each(@plateQuadrants, (plate) =>
      unless plate.barcode is ""
        if plateBarcodes[plate.barcode]?
          plateBarcodes[plate.barcode]++
          isValid = false
        else
          plateBarcodes[plate.barcode] = 1
    )

    return isValid

  setStateOfSubmitButton: =>
    if @isValid()
      @$("button[name='splitPlate']").prop('disabled', false)
      @$("button[name='splitPlate']").removeClass('disabled')
    else
      @$("button[name='splitPlate']").prop('disabled', true)
      @$("button[name='splitPlate']").addClass('disabled')

  handleSourcePlateBarcodeChange: (evt) =>
    target = $(evt.currentTarget)
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
      $(evt.currentTarget).parent().removeClass("has-error")
      $(evt.currentTarget).parent().addClass("has-success")
      @$("span[name='sourcePlateNotFound']").addClass "hide"

      @sourcePlate.codeName = data.codeName
      @sourcePlate.plateSize = data.plateSize
      if @sourcePlate.plateSize < MINIMUM_PLATE_SIZE
        @$("span[name='sourcePlateTooSmall']").removeClass "hide"
        @sourcePlate.isValid = false
      else
        @$("span[name='sourcePlateTooSmall']").addClass "hide"
        $(evt.currentTarget).parent().find(".glyphicon-ok").removeClass("hide")
        $(evt.currentTarget).parent().find(".glyphicon-warning-sign").addClass("hide")
        @sourcePlate.isValid = true

      @setStateOfSubmitButton()
    )
    .fail((jqXHR, textStatus, errorThrown) =>
      $(evt.currentTarget).parent().removeClass("has-success")
      $(evt.currentTarget).parent().addClass("has-error")
      @$("span[name='sourcePlateNotFound']").removeClass "hide"
      $(evt.currentTarget).parent().find(".glyphicon-ok").addClass("hide")
      $(evt.currentTarget).parent().find(".glyphicon-warning-sign").removeClass("hide")
      @sourcePlate.isValid = false
      @setStateOfSubmitButton()
    )

  handleSplitPlateClick: =>

    @setupAndDisplaySplitingDialogBox()
    sourcePlateBarcode = @sourcePlate.codeName
    splitPlates = {
      "codeName": @sourcePlate.codeName,
      "quadrants": []
    }

    unless @plateQuadrants["plateQuadrant1"].barcode is ""
      splitPlates.quadrants.push({
        "quadrant": 1,
        "barcode": @plateQuadrants["plateQuadrant1"].barcode
      })

    unless @plateQuadrants["plateQuadrant2"].barcode is ""
      splitPlates.quadrants.push({
        "quadrant": 2,
        "barcode": @plateQuadrants["plateQuadrant2"].barcode
      })

    unless @plateQuadrants["plateQuadrant3"].barcode is ""
      splitPlates.quadrants.push({
        "quadrant": 3,
        "barcode": @plateQuadrants["plateQuadrant3"].barcode
      })

    unless @plateQuadrants["plateQuadrant4"].barcode is ""
      splitPlates.quadrants.push({
        "quadrant": 4,
        "barcode": @plateQuadrants["plateQuadrant4"].barcode
      })

    $.ajax(
      data: splitPlates
      dataType: "json"
      method: 'post'
      url: "/api/splitContainer"
    )
    .done((data, textStatus, jqXHR) =>
      @displayMergeSuccessMessages data
      @resetForm()
    )
    .fail((jqXHR, textStatus, errorThrown) =>
      errors = JSON.parse jqXHR.responseText
      if _.isArray errors
        @displayErrorMessagesFromServer(errors)
      #@displayMergeErrorMessages(sourcePlateBarcode)
    )

  displayMergeErrorMessages: (sourcePlateBarcode) =>
    @$("a[name='barcode']").prop("href", "#plateDesign/#{sourcePlateBarcode}")
    @$("a[name='barcode']").html sourcePlateBarcode
    @$("div[name='existingBarcodeErrorMessage']").removeClass "hide"
    @$("span[name='dialogDismissButtons']").removeClass "hide"
    @$("span[name='splitingStatus']").addClass "hide"

  displayErrorMessagesFromServer: (errorMessages) =>
    @$("ul[name='duplicateBarcodes']").empty()
    _.each(errorMessages, (errorMessage) =>
      @$("ul[name='duplicateBarcodes']").append("<li>#{errorMessage}</li>")
    )
    @$("div[name='existingBarcodeErrorMessage']").removeClass "hide"
    @$("span[name='splitingStatus']").addClass "hide"
    @$("span[name='dialogDismissButtons']").removeClass "hide"

  displayMergeSuccessMessages: (data) =>
    @$("a[name='linkToQuad1Plate']").prop("href", "#plateDesign/#{@plateQuadrants['plateQuadrant1'].barcode}")
    @$("span[name='barcodeQuad1Plate']").html @plateQuadrants['plateQuadrant1'].barcode
    @$("a[name='linkToQuad2Plate']").prop("href", "#plateDesign/#{@plateQuadrants['plateQuadrant2'].barcode}")
    @$("span[name='barcodeQuad2Plate']").html @plateQuadrants['plateQuadrant2'].barcode
    @$("a[name='linkToQuad3Plate']").prop("href", "#plateDesign/#{@plateQuadrants['plateQuadrant3'].barcode}")
    @$("span[name='barcodeQuad3Plate']").html @plateQuadrants['plateQuadrant3'].barcode
    @$("a[name='linkToQuad4Plate']").prop("href", "#plateDesign/#{@plateQuadrants['plateQuadrant4'].barcode}")
    @$("span[name='barcodeQuad4Plate']").html @plateQuadrants['plateQuadrant4'].barcode
    @$("div[name='splitPlateLinks']").removeClass "hide"
    @$("span[name='splitingStatus']").addClass "hide"
    @$("span[name='dialogDismissButtons']").removeClass "hide"

  setupAndDisplaySplitingDialogBox: =>
    @$("div[name='splitPlateLinks']").addClass "hide"
    @$("div[name='existingBarcodeErrorMessage']").addClass "hide"
    @$("a[name='barcode']").prop("href", "#plateDesign/")
    @$("a[name='barcode']").html ""

    @$("a[name='linkToNewPlate']").prop("href", "#plateDesign/")
    @$("div[name='mergedPlateLink']").addClass "hide"
    @$("span[name='splitingStatus']").removeClass "hide"
    @$("span[name='dialogDismissButtons']").addClass "hide"

    @$("div[name='splitPlateDialogBox']").modal(
      keyboard: false
      backdrop: 'static'
    )

  resetForm: =>
    @plateQuadrants["plateQuadrant1"].barcode = ""
    @plateQuadrants["plateQuadrant1"].isValid = false

    @plateQuadrants["plateQuadrant2"].barcode = ""
    @plateQuadrants["plateQuadrant2"].isValid = false

    @plateQuadrants["plateQuadrant3"].barcode = ""
    @plateQuadrants["plateQuadrant3"].isValid = false

    @plateQuadrants["plateQuadrant4"].barcode = ""
    @plateQuadrants["plateQuadrant4"].isValid = false

    @sourcePlate = {
      codeName: ""
      isValid: false
    }

    @$("input[name='sourcePlateBarcode']").val("")
    @$("input[name='plateQuadrant1']").val("")
    @$("input[name='plateQuadrant2']").val("")
    @$("input[name='plateQuadrant3']").val("")
    @$("input[name='plateQuadrant4']").val("")

    @$("input[name='sourcePlateBarcode']").parent().removeClass("has-error")
    @$("input[name='sourcePlateBarcode']").parent().removeClass("has-success")

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


  render: =>
    $(@el).html @template()

    @setStateOfSubmitButton()

    @


exports.SplitPlatesController = SplitPlatesController