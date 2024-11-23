class DeviceCollection extends PickListList

class DeviceModel extends Container
	urlRoot: "/api/containers"

	initialize: (options) ->
		@options = options
		@.set
			lsType: "instrument"
			lsKind: "balance"
		super(options)

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

class DeviceCollection extends Backbone.Collection
	url: 'api/containers/instrument/balance'
	model: DeviceModel

class RealtimeDeviceConnectionController extends Backbone.View
	template: _.template($("#RealtimeDeviceConnectionView").html())

	events:
		"click .bv_disconnect": "handleDisconnectClicked"
		"click .bv_bootCurrentUserOffDevice": "handleBootCurrentUserOffDevice"
		"click .bv_disconnectedByAnotherUserDismiss": "hideDisconnectedModal"
		"click .bv_kickUserOff": "displayInUseModal"
		"click .bv_deviceInUseDismiss": "dismissDeviceInUse"
		"click .bv_reconnect": "handleReconnectClicked"
		"change .bv_deviceSelectContainer": "handleDeviceSelectChange"
		"click .bv_dismissDisconnectMessage": "handleDismissDisconnectMessage"
		"click .bv_zeroBalance": "handleZeroBalanceClick"

	initialize: (options) ->
		@options = options
		@isConnectedToDevice = false
		@isConnectingToDevice = false
		@testMode = @options.testMode
		if @options.socket?
			@socket = @options.socket

		@deviceCollection = new DeviceCollection()
		@deviceCollection.comparator = (instrument) =>
			return instrument.get("lsLabels").pickBestName().get("labelText").toLowerCase()

		@listenTo @deviceCollection, "sync", @renderSelectListOfExistingInstruments
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
		@socket.on('connect_error', @handleConnectError.bind(@))
		@socket.on('youShouldTryConnecting', @connectToDevice.bind(@))
		@socket.on('disconnectedFromDevice', @disconnectedFromDevice.bind(@))
		@socket.on('alertAllDisconnectedFromDevice', @alertAllDisconnectedFromDevice.bind(@))
		@socket.on('disconnectedByAnotherUser', @disconnectedByAnotherUser.bind(@))
		@socket.on('in_use', @displayUnavailableMessage.bind(@))
		@socket.on('balance_reserved', @balanceReserved.bind(@))
		@socket.on('device_server_offline', @displayServerOfflineMessage.bind(@))
		@socket.on('zeroingComplete', =>
			if @isConnectedToDevice
				@resetForm()
				@enableElement(".bv_disconnect")
				@enableElement(".bv_zeroBalance")
				@$(".bv_zeroBalance").html "Zero Balance"
			else
				@displayInUseMessage()
		.bind(@)
		)

	handleZeroBalanceClick: =>
		if @isConnectedToDevice
			@disableAllFields()
			@disableElement(".bv_disconnect")
			@disableElement(".bv_zeroBalance")
			@$(".bv_zeroBalance").html "Zeroing..."
			@socket.emit('zeroBalance', {deviceName: @selectedDevice.get('description').get('value'), deviceUrl: @selectedDevice.get('url').get('value'), userName: AppLaunchParams.loginUserName}, @zeroBalanceCallback)

	zeroBalanceCallback: (err, data) =>

	connectToDevice: =>
		unless @isConnectedToDevice or @isConnectingToDevice
			@isConnectingToDevice = true
			@selectedInstrumentCode = @$('.bv_deviceSelectContainer').val()
			@selectedDevice = @deviceCollection.findWhere({"codeName": @selectedInstrumentCode})
			@$(".bv_connecting").removeClass "hide"
			@$(".bv_deviceServerOffline").addClass "hide"
			@socket.emit('connectToDevice', {deviceName: @selectedDevice.get('description').get('value'), deviceUrl: @selectedDevice.get('url').get('value'), userName: AppLaunchParams.loginUserName}, @connectToDeviceCallback)
			@focusOnDefaultElement()

	focusOnDefaultElement: =>
		console.info "overide if needed"

	connectToDeviceCallback: (err, data) =>
		@isConnectingToDevice = false
		if err
			@isConnectedToDevice = false
			@setStateToDisconnected()
			switch err.status
				when "not_available"
					@clientIdOfConnectedUser = err.clientId
					@userNameOfConnectedUser = err.userName
					@displayInUseMessage()
				when "device_not_connected"
					@displayStatusMessage(".bv_deviceNotConnected")
				when "device_server_offline"
					@displayServerOfflineMessage()
				when "in_use"
					@displayStatusMessage(".bv_deviceServerInUse")

		else
			@isConnectedToDevice = true
			@setStateToConnected()
		@enableElement(".bv_deviceSelectContainer")
		@$(".bv_connectionStatusAlert").addClass "hide"

	displayUnavailableMessage: =>
		unless @isConnectedToDevice
			@displayStatusMessage(".bv_deviceServerInUse")

	displayServerOfflineMessage: =>
		@displayStatusMessage(".bv_deviceServerOffline")
		@isConnectedToDevice = false

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
		@$(".bv_deviceUsedBy").html _.escape(@userNameOfConnectedUser)

	handleDeviceSelectChange: =>
		@disableElement(".bv_deviceSelectContainer")
		@selectedInstrumentCode = @$('.bv_deviceSelectContainer').val()
		selectedInstrument = @deviceCollection.findWhere({"codeName": @selectedInstrumentCode})
		@resetStatusMessages()
		if @isConnectedToDevice
			@socket.emit('disconnectFromBalance', @disconnectCallback)
		else
			unless selectedInstrument is ""
				@connectToDevice()

	disconnectCallback: =>
		@isConnectedToDevice = false
		@connectToDevice()

	handleReconnectClicked: =>
		@$(".bv_disconnected").addClass "hide"
		@connectToDevice()

	handleBootCurrentUserOffDevice: =>
		@socket.emit('bootUser', {userToBootClientId: @clientIdOfConnectedUser, userNameToAdd: AppLaunchParams.loginUserName}, @handleBootCurrentUserOffDeviceCallback)

	handleBootCurrentUserOffDeviceCallback: (err, data) =>
		@setStateToConnected()
		@$(".bv_deviceInUse").modal "hide"

	handleDismissDisconnectMessage: =>
		@$(".bv_disconnectedByAUserMessage").hide()

	displayInUseModal: =>
		@$(".bv_alreadyConnectedUserName").html _.escape(@userNameOfConnectedUser)
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
		@connectToDevice()

	disconnectedByAnotherUser: (msg) =>
		@displayDisconnectedModal(msg.username)

	balanceReserved: (msg) =>
		if msg.balanceUrl is @selectedDevice.get('url').get('value')
			@connectToDeviceCallback(msg, null)

	displayDisconnectedModal: (disconnectingUserName) =>
		@$(".bv_disconnectingUserName").html _.escape(disconnectingUserName)
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