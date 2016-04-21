DataTable = require('imports?this=>window!../../../../public/lib/dataTables/js/jquery.dataTables.js') #Handsontable || () ->

require('expose?$!expose?jQuery!jquery');
require("bootstrap-webpack!./bootstrap.config.js");

PickListSelectController = require('./SelectList.coffee').PickListSelectController
PickList = require('./SelectList.coffee').PickList

class PlateSearchController extends Backbone.View
  template: _.template(require('html!./PlateSearchView.tmpl'))
  events:
    "click button[name='search']": "handleSearchClicked"
    "click button[name='clonePlate']": "handleClonePlateClicked"

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
    @plateCloneController = new ClonePlateController()

    @$("button[name='cancelClonePlate']").removeClass "hide"
    @$("button[name='clonePlate']").removeClass "hide"
    @$("button[name='closeClonePlate']").addClass "hide"


    @$(".bv_clonePlateBarcodeContainer").html @plateCloneController.render().el
    @$(".bv_linkToPlateToClone").prop('href', "#plateDesign/#{plateInfo.barcode}")
    @$(".bv_linkToPlateToClone").html plateInfo.barcode
    @plateToCloneCodeName = plateInfo.codeName
    @$("div[name='clonePlateDialogbox']").modal(
      keyboard: false
      backdrop: 'static'
    )

  handleClonePlateClicked: =>
    clonePlateBarcode = @plateCloneController.getBarcode()
    @plateCloneController.setControlToSaving()
    data = {
      codeName: @plateToCloneCodeName
      barcode: clonePlateBarcode
    }

    $.ajax(
      data: data
      dataType: "json"
      method: "POST"
      url: "api/cloneContainer"
    )
    .done((data, textStatus, jqXHR) =>
      console.log "got a new plate?"
      console.log data
      @plateCloneController.setControlToSavingSuccess()
      @$("button[name='cancelClonePlate']").addClass "hide"
      @$("button[name='clonePlate']").addClass "hide"
      @$("button[name='closeClonePlate']").removeClass "hide"
    )
    .fail((jqXHR, textStatus, errorThrown) =>
      console.log "an error occured"
      console.log errorThrown
      @plateCloneController.setControlToSavingError()
    )


  render: =>
    $(@el).html @template()

    @

class SearchResultModel extends Backbone.Model
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
          <th>Launch</th>
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
      <td><a href="#plateDesign/<%= barcode %>" target="_blank" >launch</a></td>
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
      <input type="text" class="form-control" name="clonedPlateBarcode"/>
    </td>
    <td>
      <p class='bv_cloningMessage hide'>Cloning...</p>
      <a href="" class='bv_linkToNewPlate hide' target="_blank">complete</a>
      <p class='bv_barcodeAlreadyUsedError hide'>Error: duplicate barcode</p>
    </td>
"""

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

  render: =>
    $(@el).html @template

    @

module.exports =
  PlateSearchController: PlateSearchController

