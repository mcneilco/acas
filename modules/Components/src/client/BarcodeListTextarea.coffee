LIST_OF_IDENTIFIER_DELIMITERS = [';', '\t', '\n']


class window.BarcodeListTextarea extends Backbone.View
  template: _.template($("#BarcodeListTextareaView").html())

  events: {
    "keyup .bv_barcodeListTextarea": "updateModel"
    "cut .bv_barcodes": "updateModelDeferred"
    "paste .bv_barcodes": "updateModelDeferred"
  }

  initialize: ->
    @rawBarcodeText = ""
    @barcodeList = []

  updateModelDeferred: =>
    _.defer(() =>
      @updateModel()
    )

  updateModel: =>
    @rawBarcodeText = @$('.bv_barcodeListTextarea').val()
    @barcodeList = @parseBarcodes(@rawBarcodeText)
    @trigger 'updated'

  parseBarcodes: (barcodes) ->
    listOfBarcodes = []
    _.each(LIST_OF_IDENTIFIER_DELIMITERS, (delimiter) ->
      ids = _.map(barcodes.split(delimiter), (barcode) ->
        $.trim(barcode)
      )
      unless _.size(ids) is 1
        listOfBarcodes = listOfBarcodes.concat ids
    )
    if _.size(listOfBarcodes) is 0 and barcodes isnt ""
      listOfBarcodes = [$.trim(barcodes)]
    listOfBarcodes = @removeWhiteSpaceEntries(listOfBarcodes)
    listOfBarcodes = @removeLeadingZerosFromBarcodes(listOfBarcodes)
    listOfBarcodes = @removeDuplicateBarcodes(listOfBarcodes)
    listOfBarcodes

  removeWhiteSpaceEntries: (listOfBarcodes) =>
    cleanListOfBarcodes = _.reject(listOfBarcodes, (barcode) ->
      barcode is ""
    )
    return cleanListOfBarcodes

  removeDuplicateBarcodes: (listOfBarcodes) =>
    return _.unique(listOfBarcodes)

  removeLeadingZerosFromBarcodes: (listOfBarcodes) =>
    listOfBarcodes = _.map(listOfBarcodes, @removeLeadingZeros)
    listOfBarcodes

  removeLeadingZeros: (barcode) =>
    removedAllLeadingZeros = false
    until removedAllLeadingZeros
      if barcode.lastIndexOf("0", 0) is 0
        barcode = barcode.substring(1, barcode.length)
      else
        removedAllLeadingZeros = true

    barcode

  getBarcodeList: =>
    @barcodeList

  reset: =>
    @rawBarcodeText = ""
    @barcodeList = []
    @$('.bv_barcodeListTextarea').val("")

  render: =>
    $(@el).empty()
    $(@el).html @template()

    @