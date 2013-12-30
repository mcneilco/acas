class window.ExperimentSearch extends Backbone.Model
	defaults:
		protocolCode: null
		experimentCode: null

class window.ExperimentSearchController extends AbstractFormController
	template: _.template($("#ExperimentSearchView").html())

	events:
		'change .bv_protocolCode': 'updateModel'
		'change .bv_experimentCode': 'updateModel'
		'click .bv_find': 'handleFindClicked'

	render: =>
		$(@el).empty()
		$(@el).html @template()
		@setupProtocolSelect()

	updateModel: =>
		@model.set
			protocolCode: @$('.bv_protocolCode').val()
			experimentCode: @getTrimmedInput('.bv_experimentCode')

	handleFindClicked: =>
		@trigger 'find'

	setupProtocolSelect: ->
		@protocolList = new PickListList()
		@protocolList.url = "/api/protocolCodes/"
		@protocolListController = new PickListSelectController
			el: @$('.bv_protocolCode')
			collection: @protocolList
			insertFirstOption: new PickList
				code: "any"
				name: "any"
			selectedCode: null

class window.ExperimentRowSummaryController extends Backbone.View
	tagName: 'tr'

	initialize: ->
		@template = _.template($('#ExperimentRowSummaryView').html())

	render: =>
		toDisplay =
			experimentName:  @model.get('lsLabels').pickBestName().get('labelText')
			experimentCode: @model.get('codeName')
		$(@el).html(@template(toDisplay))



class window.ExperimentBrowserController extends Backbone.View
	template: _.template($("#ExperimentBrowserView").html())

	initialize: ->
		$(@el).empty()
		$(@el).html @template()
		@searchController = new ExperimentSearchController
			model: new ExperimentSearch()
			el: @$('.bv_experimentSearchController')
		@searchController.render()


	render: =>

		@

