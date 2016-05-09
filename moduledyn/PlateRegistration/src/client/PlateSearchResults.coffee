class SearchResultModel extends Backbone.Model
  defaults:
    "barcode": ""
    "plateSize": ""
    "recordedBy": ""
    "createdUser": ""
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
      <td><%= createdUser %></td>
      <td><%= description %></td>
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
    @trigger SEARCH_RESULT_ROW_EVENTS.CLONE_PLATE, {codeName: @model.get('codeName'), barcode: @model.get('barcode')}

  render: =>
    compiledTemplate = _.template(@template)
    $(@el).html compiledTemplate(@model.toJSON())

    @


module.exports =
  SearchResultCollection: SearchResultCollection
  SearchResultTable: SearchResultTable
  SEARCH_RESULT_ROW_EVENTS: SEARCH_RESULT_ROW_EVENTS