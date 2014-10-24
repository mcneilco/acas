class window.ProtocolSearch extends Backbone.Model
	defaults:
		protocolCode: null

class window.ProtocolSimpleSearchController extends AbstractFormController
	template: _.template($("#ProtocolSimpleSearchView").html())

	render: =>
		$(@el).empty()
		$(@el).html @template()

		@
