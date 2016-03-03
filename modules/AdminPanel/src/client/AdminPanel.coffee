class window.AdminPanel extends Backbone.Model


class window.AdminPanelController extends AbstractFormController
	template: _.template($("#AdminPanelView").html())

	initialize: ->
		@errorOwnerName = 'AdminPanelController'
		unless @model?
			@model = new AdminPanel()
		@setBindings()

	render: =>
		$(@el).empty()
		$(@el).html @template()

		@showConnectionStatus()
		setInterval(@showConnectionStatus,5000)
		@$('.bv_checkConnection').hide()
		recursivelyIterateAndDisplayValues(window.conf)

		@

	showConnectionStatus: =>
		$.ajax
			type: 'GET'
			timeout: 2000
			url: "/api/codetables/user well flags/flag observation"
			success: @handleConnectionSuccess
			error: @handleConnectionFailure

	handleConnectionSuccess: (data, status) =>
		@$('.bv_connectionStatus').addClass('bv_statusConnected')
		@$('.bv_connectionStatus').removeClass('bv_statusDisconnected')
		@$('.bv_connectionStatus').html "connected"
		@$('.bv_checkConnection').hide()

	handleConnectionFailure: =>
		@$('.bv_connectionStatus').addClass('bv_statusDisconnected')
		@$('.bv_connectionStatus').removeClass('bv_statusConnected')
		@$('.bv_connectionStatus').html "disconnected"
		@$('.bv_checkConnection').show()
		

recursivelyIterateAndDisplayValues = (dict) ->
	keys = Object.keys dict
	_.each(keys, (key) ->
  	if isObject dict[key]
  		recursivelyIterateAndDisplayValues dict[key]
  	else
			unless typeof dict[key] is "object"
				@$('.bv_configProperties').append("<b>" + key + ":</b> " + dict[key] + "<br />")
	)
	#TODO add full paths - Matt

isObject = (value) ->
	if value? and (typeof value is "object") and !(Array.isArray value)
		return true
	else
		return false
