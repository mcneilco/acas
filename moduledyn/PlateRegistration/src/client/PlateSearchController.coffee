DataTable = require('imports?this=>window!../../../../public/lib/dataTables/js/jquery.dataTables.js')
require('expose?$!expose?jQuery!jquery')

require("bootstrap-webpack!./bootstrap.config.js")

PickListSelectController = require('./SelectList.coffee').PickListSelectController
PickList = require('./SelectList.coffee').PickList

ClonePlateController = require('./ClonePlateController.coffee').ClonePlateController
SearchResultCollection = require('./PlateSearchResults.coffee').SearchResultCollection
SearchResultTable = require('./PlateSearchResults.coffee').SearchResultTable
SEARCH_RESULT_ROW_EVENTS = require('./PlateSearchResults.coffee').SEARCH_RESULT_ROW_EVENTS

LIST_OF_IDENTIFIER_DELIMITERS = [';', '\t', '\n']

class PlateSearchController extends Backbone.View
  template: _.template(require('html!./PlateSearchView.tmpl'))
  events:
    "click button[name='search']": "handleSearchClicked"
    "click button[name='clonePlate']": "handleClonePlateClicked"
    "click button[name='tryClonePlateAgain']": "handleTryCloneAgainClicked"
    "change input": "handleInputChanged"
    "change select": "handleInputChanged"

  initialize: (options) ->
    @plateDefinitions = options.plateDefinitions
    @plateTypes = options.plateTypes
    @plateStatuses = options.plateStatuses
    @users = options.users

    @selectLists = [
      containerSelector: "select[name='definition']"
      collection: @plateDefinitions
    ]

  completeInitialize: =>
    @initializeSelectLists()
    @setStateOfSubmitButton()
    @delegateEvents()

  handleInputChanged: (evt) =>
    target = $(evt.currentTarget)
    if target.attr('name') is "barcodeSearchTerm"
      barcode = $.trim(target.val())
      if AppLaunchParams.enforceUppercaseBarcodes
        barcode = $.trim(_.toUpper(target.val()))
        target.val(barcode)
    @setStateOfSubmitButton()

  initializeSelectLists: =>

    @plateDefinitionsSelectList = new PickListSelectController
      el: $(@el).find("select[name='definition']")
      collection: @plateDefinitions
      insertFirstOption: new PickList
        code: "unassigned"
        name: ""
      selectedCode: "unassigned"
      className: "form-control"
      autoFetch: false

    @plateTypesSelectList = new PickListSelectController
      el: $(@el).find("select[name='type']")
      collection: @plateTypes
      insertFirstOption: new PickList
        code: "unassigned"
        name: ""
      selectedCode: "unassigned"
      className: "form-control"
      autoFetch: false

    @plateStatusesSelectList = new PickListSelectController
      el: $(@el).find("select[name='status']")
      collection: @plateStatuses
      insertFirstOption: new PickList
        code: "unassigned"
        name: ""
      selectedCode: "unassigned"
      className: "form-control"
      autoFetch: false

    @usersSelectList = new PickListSelectController
      el: $(@el).find("select[name='user']")
      collection: @users
      insertFirstOption: new PickList
        code: "unassigned"
        name: ""
      selectedCode: "unassigned"
      className: "form-control"
      autoFetch: false

  getFormValues: =>
    searchTerms = {
      "lsType":"container",
      "lsKind":"plate"
    }
    barcode = $.trim(@$("input[name='barcodeSearchTerm']").val())
    if barcode isnt ""
      if AppLaunchParams.enforceUppercaseBarcodes
        barcode = $.trim(_.toUpper(barcode))
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

    if @usersSelectList.getSelectedCode() isnt "unassigned"
      searchTerms.createdUser = @usersSelectList.getSelectedCode()
      #searchTerms.recordedBy = @usersSelectList.getSelectedCode()


    searchTerms

  isFormValid: (formValues) =>
    searchIsValid = false
    if formValues.barcode?
      if formValues.barcode isnt ""
        searchIsValid = true
    if formValues.description?
      if formValues.description isnt ""
        searchIsValid = true
    if formValues.definition?
      if formValues.definition isnt ""
        searchIsValid = true
    if formValues.type?
      if formValues.type isnt "unassigned"
        searchIsValid = true
    if formValues.status?
      if formValues.status isnt "unassigned"
        searchIsValid = true
    if formValues.createdUser?
      if formValues.createdUser isnt "unassigned"
        searchIsValid = true

    searchIsValid

  handleSearchClicked: =>
    @$(".bv_searchResults").addClass "hide"
    @$("div[name='noSearchResultsReturned']").addClass "hide"
    @$("div[name='maxNumberOfSearchResultsReturned']").addClass "hide"
    @$(".bv_searchInProgressMessage").removeClass "hide"
    searchTerms = @getFormValues()
    $.ajax(
      data: searchTerms
      dataType: "json"
      method: "POST"
      url: "api/searchContainers"
    )
    .done((data, textStatus, jqXHR) =>
      @searchCallback(data)
    )
    .fail((jqXHR, textStatus, errorThrown) =>
      console.log "an error occured"
      console.log errorThrown
      #@plateCloneController.setControlToSavingError()
    )

  searchCallback: (searchResults) =>
    searchResultsCollection = new SearchResultCollection(searchResults)
    if searchResultsCollection.size() is AppLaunchParams.maxSearchResults
      @$("div[name='maxNumberOfSearchResultsReturned']").removeClass "hide"
    else
      @$("div[name='maxNumberOfSearchResultsReturned']").addClass "hide"
    if searchResultsCollection.size() is 0
      @$("div[name='noSearchResultsReturned']").removeClass "hide"
    else
      @$("div[name='noSearchResultsReturned']").addClass "hide"

      if @searchResultsTable?
        @searchResultsTable.remove()
      @searchResultsTable = new SearchResultTable({collection: searchResultsCollection})
      @listenTo @searchResultsTable, SEARCH_RESULT_ROW_EVENTS.CLONE_PLATE, @handleClonePlate
      $(".bv_searchResults").html @searchResultsTable.render().el

      @$(".bv_searchResults").removeClass "hide"
      @searchResultsTable.completeInitialization()
    @$(".bv_searchInProgressMessage").addClass "hide"

  handleClonePlate: (plateInfo) =>
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
    if AppLaunchParams.enforceUppercaseBarcodes
      cloneBarcodes = @parseBarcodes(_.toUpper(@$("textarea[name='clonedPlateBarcodes']").val()))
    else
      cloneBarcodes = @parseBarcodes(@$("textarea[name='clonedPlateBarcodes']").val())
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
    $.when.apply($, promises).done( (callbacks...) =>
      hadErrors = _.find(callbacks, (cb) ->
        cb is false
      )
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

  setStateOfSubmitButton: =>
    formValues = @getFormValues()
    if @isFormValid(formValues)
      @$("button[name='search']").prop('disabled', false)
      @$("button[name='search']").removeClass('disabled')
    else
      @$("button[name='search']").prop('disabled', true)
      @$("button[name='search']").addClass('disabled')

  render: =>
    $(@el).html @template()

    @




module.exports =
  PlateSearchController: PlateSearchController