class window.DeviceCollection extends PickListList

class window.DeviceModel extends Container
	urlRoot: "/api/containers"

	initialize: ->
		@.set
			lsType: "instrument"
			lsKind: "balance"
		super()

	lsProperties:
		defaultLabels: [
			key: 'common'
			type: 'name'
			kind: 'common'
			preferred: true
		,
			key: 'corpName'
			type: 'corpName'
			kind: 'ACAS LsContainer'
			preferred: false
		]
		defaultValues: [
			key: 'description'
			stateType: 'metadata'
			stateKind: 'information'
			type: 'stringValue'
			kind: 'description'
		,
			key: 'url'
			stateType: 'metadata'
			stateKind: 'information'
			type: 'stringValue'
			kind: 'url'
		,
			key: 'createdUser'
			stateType: 'metadata'
			stateKind: 'information'
			type: 'codeValue'
			kind: 'created user'
		,
			key: 'person responsible'
			stateType: 'metadata'
			stateKind: 'information'
			type: 'codeValue'
			kind: 'person responsible'
		]

class window.DeviceCollection extends Backbone.Collection
	url: 'api/containers/instrument/balance'
	model: DeviceModel

class window.RealtimeDeviceConnectionController extends Backbone.View
	template: _.template($("#RealtimeDeviceConnectionView").html())

	events:
		"click .bv_disconnect": "handleDisconnectClicked"
		"click .bv_bootCurrentUserOffDevice": "handleBootCurrentUserOffDevice"
		"click .bv_disconnectedByAnotherUserDismiss": "hideDisconnectedModal"
		"click .bv_kickUserOff": "displayInUseModal"
		"click .bv_deviceInUseDismiss": "dismissDeviceInUse"
		"change .bv_deviceSelectContainer": "handleDeviceSelectChange"
		"click .bv_dismissDisconnectMessage": "handleDismissDisconnectMessage"
		"click .bv_zeroBalance": "handleZeroBalanceClick"

	initialize: ->
		@isConnectedToDevice = false
		@testMode = @options.testMode
		if @options.socket?
			@socket = @options.socket

		@deviceCollection = new DeviceCollection()
		@deviceCollection.comparator = (instrument) =>
			return instrument.get("lsLabels").pickBestName().get("labelText").toLowerCase()

		@listenTo @deviceCollection, "sync", @renderSelectListOfExistingInstruments
		@connected = false
		unless @testMode
			@setupSocketEventHandlers()

	renderSelectListOfExistingInstruments: =>
		@$(".bv_loadingMessage").addClass "hide"
		@$(".bv_formContainer").removeClass "hide"
		deviceSelectList = ''
		@$(".bv_deviceSelectContainer").empty()
		@deviceCollection.sort()
		_.each(@deviceCollection.models, (instrument) =>
			deviceSelectList += "<option value='" + instrument.get("codeName") + "'>" + instrument.get("lsLabels").pickBestName().get("labelText") + "</option>"
		)
		@$(".bv_deviceSelectContainer").append deviceSelectList
		@$(".bv_loadingMessage").addClass "hide"
		@$(".bv_formContainer").removeClass "hide"

		@handleDeviceSelectChange()

	setupSocketEventHandlers: =>
		@socket = io('/deviceChannel')
		#@socket.on('connect', @handleDeviceSelectChange)
		@socket.on('connect_error', @handleConnectError)
		@socket.on('youShouldTryConnecting', @connectToDevice)
		@socket.on('disconnectedFromDevice', @disconnectedFromDevice)
		@socket.on('alertAllDisconnectedFromDevice', @alertAllDisconnectedFromDevice)
		@socket.on('disconnectedByAnotherUser', @disconnectedByAnotherUser)
		@socket.on('in_use', @displayUnavailableMessage)
		@socket.on('zeroingComplete', =>
			console.log "zeroingComplete"
			if @connected
				console.log "zeroingComplete"
				@resetForm()
				@enableElement(".bv_disconnect")
				@enableElement(".bv_zeroBalance")
				@$(".bv_zeroBalance").html "Zero Balance"
			else
				@displayInUseMessage()
		)


	handleZeroBalanceClick: =>
		if @connected
			@disableAllFields()
			@disableElement(".bv_disconnect")
			@disableElement(".bv_zeroBalance")
			@$(".bv_zeroBalance").html "Zeroing..."
			@socket.emit('zeroBalance', {deviceName: @selectedDevice.get('description').get('value'), deviceUrl: @selectedDevice.get('url').get('value'), userName: AppLaunchParams.loginUserName}, @zeroBalanceCallback)

	zeroBalanceCallback: (err, data) =>


	connectToDevice: =>
		unless @connected
			#@selectedDevice = @devicePickList.getSelectedModel()
			@selectedInstrumentCode = @$('.bv_deviceSelectContainer').val()
			@selectedDevice = @deviceCollection.findWhere({"codeName": @selectedInstrumentCode})
			console.log "@selectedDevice.get('url').get('value')"
			console.log @selectedDevice.get('url').get('value')
			@$(".bv_connecting").removeClass "hide"
			@$(".bv_deviceServerOffline").addClass "hide"
			@socket.emit('connectToDevice', {deviceName: @selectedDevice.get('description').get('value'), deviceUrl: @selectedDevice.get('url').get('value'), userName: AppLaunchParams.loginUserName}, @connectToDeviceCallback)
			@focusOnDefaultElement()

	focusOnDefaultElement: =>
		console.info "overide if needed"

	connectToDeviceCallback: (err, data) =>
		console.log "err", err
		console.log "data", data
		if err
			@connected = false
			@setStateToDisconnected()
			switch err.status
				when "not_available"
					@clientIdOfConnectedUser = err.clientId
					@userNameOfConnectedUser = err.userName
					@displayInUseMessage()
				when "device_not_connected"
					@displayStatusMessage(".bv_deviceNotConnected")
				when "device_server_offline"
					@displayStatusMessage(".bv_deviceServerOffline")
				when "in_use"
					@displayStatusMessage(".bv_deviceServerInUse")

		else
			@connected = true
			@setStateToConnected()
		@enableElement(".bv_deviceSelectContainer")
		@$(".bv_connectionStatusAlert").addClass "hide"

	displayUnavailableMessage: =>
		unless @connected
			@displayStatusMessage(".bv_deviceServerInUse")

	displayStatusMessage: (messageSelector) =>
		@resetStatusMessages()
		@$(messageSelector).removeClass "hide"

	resetStatusMessages: =>
		@$(".bv_connecting").addClass "hide"
		@$(".bv_connected").addClass "hide"
		@$(".bv_disconnected").addClass "hide"
		@$(".bv_deviceNotConnected").addClass "hide"
		@$(".bv_deviceServerInUse").addClass "hide"
		@$(".bv_deviceServerOffline").addClass "hide"
		@$(".bv_deviceServerInUseButIdle").addClass "hide"
		@$(".bv_disconnect").addClass "hide"
		@$(".bv_zeroBalance").addClass "hide"
		@handleDismissDisconnectMessage()

	displayInUseMessage: =>
		@resetStatusMessages()
		@displayStatusMessage(".bv_deviceServerInUseButIdle")
		@$(".bv_deviceUsedBy").html @userNameOfConnectedUser

	handleDeviceSelectChange: =>
		@disableElement(".bv_deviceSelectContainer")
		@selectedInstrumentCode = @$('.bv_deviceSelectContainer').val()
		selectedInstrument = @deviceCollection.findWhere({"codeName": @selectedInstrumentCode})
		@connected = false
		@resetStatusMessages()
		@socket.emit('disconnected')
		unless selectedInstrument is ""
			@connectToDevice()

	handleBootCurrentUserOffDevice: =>
		@socket.emit('bootUser', {userToBootClientId: @clientIdOfConnectedUser, userNameToAdd: AppLaunchParams.loginUserName}, @handleBootCurrentUserOffDeviceCallback)

	handleBootCurrentUserOffDeviceCallback: (err, data) =>
		@setStateToConnected()
		@$(".bv_deviceInUse").modal "hide"

	handleDismissDisconnectMessage: =>
		@$(".bv_disconnectedByAUserMessage").hide()

	displayInUseModal: =>
		@$(".bv_alreadyConnectedUserName").html @userNameOfConnectedUser
		@$(".bv_deviceInUse").modal "show"

	handleConnectError: =>
		@$(".bv_connectionStatusAlert").removeClass "hide"

	getDeviceName: =>
		return @$(".bv_deviceSelect").val()

	disableDisconnectButton: =>
		@$(".bv_disconnect").addClass "hide"

	enableDisconnectButton: =>
		@$(".bv_disconnect").removeClass "hide"

	disableElement: (cssSelector) =>
		@$(cssSelector).prop "disabled", true
		@$(cssSelector).addClass "disabled"

	enableElement: (cssSelector) =>
		@$(cssSelector).prop "disabled", false
		@$(cssSelector).removeClass "disabled"

	handleDisconnectClicked: (e) =>
		e.preventDefault()
		@socket.emit('disconnected')

	setStateToDisconnected: =>
		@disableDisconnectButton()
		@isConnectedToDevice = false
		@$(".bv_connecting").addClass "hide"
		@$(".bv_connected").addClass "hide"
		@$(".bv_zeroBalance").addClass "hide"
		@$(".bv_disconnected").removeClass "hide"

	setStateToConnected: =>
		@enableDisconnectButton()
		@isConnectedToDevice = true
		@displayStatusMessage ".bv_connected"
		@$(".bv_zeroBalance").removeClass "hide"
		@$(".bv_disconnect").removeClass "hide"

	disconnectedFromDevice: =>
		@setStateToDisconnected()

	alertAllDisconnectedFromDevice: =>
		unless @isConnectedToDevice
			@connectToDevice()

	disconnectedByAnotherUser: (disconnectingUserName) =>
		@displayDisconnectedModal(disconnectingUserName)
		@setStateToDisconnected()

	displayDisconnectedModal: (disconnectingUserName) =>
		@$(".bv_disconnectingUserName").html disconnectingUserName
		@$(".bv_disconnectedByAUserMessage").show "slide", {direction: "right"}

	dismissDeviceInUse: =>
		@$(".bv_deviceInUse").modal "hide"

	hideDisconnectedModal: =>
		@$(".bv_disconnectedByAnotherUser").modal "hide"

	render: =>
		$(@el).empty()
		$(@el).html @template()
		@deviceCollection.fetch()
		@renderSubform()

		@

	renderSubform: =>
		@$(".bv_subformContainer").html @subFormTemplate()
		@completeInitialization()

		@

	disableAllFields: =>
		@disableElement(".bv_deviceSelectContainer")
		@disableElement(".bv_disconnect")
		@disableElement(".bv_zeroBalance")

	enableFields: =>
		@enableElement(".bv_deviceSelectContainer")
		@enableElement(".bv_disconnect")
		@enableElement(".bv_zeroBalance")

	completeInitialization: =>
		console.info "override in concrete instance of controller"