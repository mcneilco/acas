class window.ExperimentSearch extends Backbone.Model
	defaults:
		protocolCode: null
		experimentCode: null

class window.ExperimentSearchController extends Backbone.View
	template: _.template($("#ExperimentSearchView").html())

	render: =>
		$(@el).empty()
		$(@el).html @template()
		@setupProtocolSelect()

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


class window.ExperimentBrowserController extends Backbone.View
	template: _.template($("#ExperimentBrowserView").html())

	render: =>
		$(@el).empty()
		$(@el).html @template()

