DataTable = require('imports?this=>window!../../../../public/lib/dataTables/js/jquery.dataTables.js') #Handsontable || () ->

require('expose?$!expose?jQuery!jquery');
require("bootstrap-webpack!./bootstrap.config.js");

PickListSelectController = require('./SelectList.coffee').PickListSelectController
PickList = require('./SelectList.coffee').PickList

LIST_OF_IDENTIFIER_DELIMITERS = [';', '\t', '\n']

class PlateSearchController extends Backbone.View
  template: _.template(require('html!./PlateSearchView.tmpl'))
  events:
    "click button[name='search']": "handleSearchClicked"
    "click button[name='clonePlate']": "handleClonePlateClicked"
    "click button[name='tryClonePlateAgain']": "handleTryCloneAgainClicked"

  initialize: (options) ->
    @plateDefinitions = options.plateDefinitions
    @plateTypes = options.plateTypes
    @plateStatuses = options.plateStatuses

    @selectLists = [
      containerSelector: "select[name='definition']"
      collection: @plateDefinitions
    ]

  completeInitialize: =>
    @initializeSelectLists()

  initializeSelectLists: =>

    @plateDefinitionsSelectList = new PickListSelectController
      el: $(@el).find("select[name='definition']")
      collection: @plateDefinitions
      insertFirstOption: new PickList
        code: "unassigned"
        name: ""
      selectedCode: "unassigned"
      className: "form-control"

    @plateTypesSelectList = new PickListSelectController
      el: $(@el).find("select[name='type']")
      collection: @plateTypes
      insertFirstOption: new PickList
        code: "unassigned"
        name: ""
      selectedCode: "unassigned"
      className: "form-control"

    @plateStatusesSelectList = new PickListSelectController
      el: $(@el).find("select[name='status']")
      collection: @plateStatuses
      insertFirstOption: new PickList
        code: "unassigned"
        name: ""
      selectedCode: "unassigned"
      className: "form-control"



  handleSearchClicked: =>
    searchTerms = {}
    barcode = $.trim(@$("input[name='barcodeSearchTerm']").val())
    if barcode isnt ""
      searchTerms.barcode = barcode
    description = $.trim(@$("input[name='descriptionSearchTerm']").val())
    if description isnt ""
      searchTerms.description = description
    if @plateDefinitionsSelectList.getSelectedCode() isnt "unassigned"
      searchTerms.definition = @plateDefinitionsSelectList.getSelectedCode()

    if @plateTypesSelectList.getSelectedCode() isnt "unassigned"
      searchTerms.type = @plateTypesSelectList.getSelectedCode()

    if @plateStatusesSelectList.getSelectedCode() isnt "unassigned"
      searchTerms.status = @plateStatusesSelectList.getSelectedCode()

    console.log "searchTerms"
    console.log searchTerms
    $.ajax(
      data: searchTerms
      dataType: "json"
      method: "POST"
      url: "api/searchContainers"
    )
    .done((data, textStatus, jqXHR) =>
      console.log "got search results?"
      console.log data
      @searchCallback(data)
    )
    .fail((jqXHR, textStatus, errorThrown) =>
      console.log "an error occured"
      console.log errorThrown
      #@plateCloneController.setControlToSavingError()
    )

  searchCallback: (searchResults) =>
    searchResultsCollection = new SearchResultCollection(searchResults)
    if @searchResultsTable?
      @searchResultsTable.remove()
    @searchResultsTable = new SearchResultTable({collection: searchResultsCollection})
    @listenTo @searchResultsTable, SEARCH_RESULT_ROW_EVENTS.CLONE_PLATE, @handleClonePlate
    $(".bv_searchResults").html @searchResultsTable.render().el
    @searchResultsTable.completeInitialization()

  handleClonePlate: (plateInfo) =>
    #@plateCloneController = new ClonePlateController()
    @$("textarea[name='clonedPlateBarcodes']").val("")
    @$("div[name='plateBarcodeEntry']").removeClass "hide"
    @$("table[name='plateCloningStatusTable']").addClass "hide"

    @$("button[name='cancelClonePlate']").removeClass "hide"
    @$("button[name='clonePlate']").removeClass "hide"
    @$("button[name='closeClonePlate']").addClass "hide"

    #@$(".bv_clonePlateBarcodeContainer").html @plateCloneController.render().el
    @$(".bv_linkToPlateToClone").prop('href', "#plateDesign/#{plateInfo.barcode}")
    @$(".bv_linkToPlateToClone").html plateInfo.barcode
    @plateToCloneCodeName = plateInfo.codeName
    @$("div[name='clonePlateDialogbox']").modal(
      keyboard: false
      backdrop: 'static'
    )

  handleClonePlateClicked: =>
    cloneBarcodes = @parseBarcodes(@$("textarea[name='clonedPlateBarcodes']").val())
    console.log "cloneBarcodes"
    console.log cloneBarcodes
    @$(".bv_clonePlateBarcodeContainer").empty()
    @$("div[name='plateBarcodeEntry']").addClass "hide"
    @$("table[name='plateCloningStatusTable']").removeClass "hide"
    @plateControllers = []
    _.each(cloneBarcodes, (barcode) =>
      plateCloneController = new ClonePlateController({sourcePlateBarcode: @plateToCloneCodeName, clonePlateBarcode: barcode})
      @plateControllers.push plateCloneController
      @$(".bv_clonePlateBarcodeContainer").append plateCloneController.render().el
    )
    @doSave()

  handleTryCloneAgainClicked: =>
    @doSave()

  doSave: =>
    promises = []
    _.each(@plateControllers, (pc) =>
      promises.push pc.saveClonedPlate()
    )
    @$("span[name='cloningStatus']").removeClass "hide"
    @$("span[name='dialogDismissButtons']").addClass "hide"
    console.log "promises"
    console.log promises
    $.when.apply($, promises).done( (callbacks...) =>
      hadErrors = _.find(callbacks, (cb) ->
        console.log "!cb"
        console.log !cb
        cb is false
      )
      console.log "hadErrors"
      console.log hadErrors
      @$("span[name='cloningStatus']").addClass "hide"
      @$("span[name='dialogDismissButtons']").removeClass "hide"
      if hadErrors?
        @$("button[name='closeClonePlate']").addClass "hide"
        @$("button[name='tryClonePlateAgain']").removeClass "hide"
        @$("button[name='clonePlate']").addClass "hide"
        @$("button[name='cancelClonePlate']").removeClass "hide"
      else
        @$("button[name='closeClonePlate']").removeClass "hide"
        @$("button[name='clonePlate']").addClass "hide"
        @$("button[name='cancelClonePlate']").addClass "hide"
        @$("button[name='tryClonePlateAgain']").addClass "hide"


    )

  parseBarcodes: (barcodes) =>
    listOfBarcodes = []
    _.each(LIST_OF_IDENTIFIER_DELIMITERS, (delimiter) ->
      ids = _.map(barcodes.split(delimiter), (barcode) ->
        $.trim(barcode)
      )
      unless _.size(ids) is 1
        listOfBarcodes = listOfBarcodes.concat ids
    )
    if _.size(listOfBarcodes) is 0 and listOfBarcodes isnt ""
      listOfBarcodes = [barcodes]

    listOfBarcodes

  render: =>
    $(@el).html @template()

    @

class SearchResultModel extends Backbone.Model
  defaults:
    "barcode": ""
    "plateSize": ""
    "recordedBy": ""
    "description": ""
    "status": ""
    "type": ""

class SearchResultCollection extends Backbone.Collection
  model: SearchResultModel

class SearchResultTable extends Backbone.View
  tagName: "table"
  className: "display"
  template: """
    <thead>
      <tr>
          <th>Barcode</th>
          <th>Wells</th>
          <th>User</th>
          <th>Description</th>
          <th>Request ID</th>
          <th>Status</th>
          <th>Type</th>
          <th>Clone</th>
          <th>Edit</th>
      </tr>
    </thead>
    <tbody class="bv_searchResultsBody">
    </tbody>
  """
  initialize: (options) ->
    @collection = options.collection

  completeInitialization: =>
    $(@el).DataTable()

  handleClonePlate: (plateInfo) =>
    console.log "propagating event with codename: ", plateInfo
    @trigger SEARCH_RESULT_ROW_EVENTS.CLONE_PLATE, plateInfo

  render: =>
    $(@el).html @template
    $(@el).prop('width', '100%')
    _.each(@collection.models, (model) =>
      searchResultRow = new SearchResultRow({model: model})
      @listenTo searchResultRow, SEARCH_RESULT_ROW_EVENTS.CLONE_PLATE, @handleClonePlate
      @$(".bv_searchResultsBody").append searchResultRow.render().el
    )

    @


SEARCH_RESULT_ROW_EVENTS =
  CLONE_PLATE: "clonePlate"

class SearchResultRow extends Backbone.View
  tagName: "tr"
  template: """
      <td><%= barcode %></td>
      <td><%= plateSize %></td>
      <td><%= recordedBy %></td>
      <td><%= description %></td>
      <td><!-- requestId --></td>
      <td><%= status %></td>
      <td><%= type %></td>
      <td><button class="btn btn-xs btn-primary" name="clonePlateRow">Clone</button></td>
      <td><a class="btn btn-primary btn-xs" href="#plateDesign/<%= barcode %>" target="_blank" >Edit</a></td>
  """
  events:
    "click button[name='clonePlateRow']": "handleClonePlateClicked"

  initialize: (options) ->
    @model = options.model

  handleClonePlateClicked: =>
    console.log "handleClonePlateClicked"
    @trigger SEARCH_RESULT_ROW_EVENTS.CLONE_PLATE, {codeName: @model.get('codeName'), barcode: @model.get('barcode')}

  render: =>
    compiledTemplate = _.template(@template)
    console.log "@model.toJSON()"
    console.log @model.toJSON()
    $(@el).html compiledTemplate(@model.toJSON())

    @


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
  PlateSearchController: PlateSearchController

