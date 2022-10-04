class ModuleMenusController extends Backbone.View

	template: _.template($("#ModuleMenusView").html())

	events: ->
		window.onbeforeunload = @handleBeforeUnload.bind(@)

		'click .bv_headerName': "handleHome"
		'click .bv_toggleModuleMenuControl': "handleToggleMenus"
		'change .bv_fastUserSelect': 'handleLoginUserChange'

	initialize: (options) ->
		@options = options
		$(@el).html @template()

		# Use module menus exported variable by default and fall back to onf.moduleMenus.menuConfigurationSettings
		if @options.menuListJSON?
			menuListJSON = @options.menuListJSON
		else if window.conf.moduleMenus.menuConfigurationSettings?
			# Verify that the menu configuration settings is parsable and an array
			try
				menuListJSON = JSON.parse(window.conf.moduleMenus.menuConfigurationSettings)
			catch error
				alert "Could not parse Module Menus configuration.  Please contact your administrator."
				return
			if Array.isArray(menuListJSON) == false
				alert "Module Menus configuration is not an array of module configurations.  Please contact your administrator."
				return
		else
			alert "Module Menus configuration is missing.  Please contact your administrator."
			return

		@moduleLauncherList = new ModuleLauncherList(menuListJSON)
		@moduleLauncherMenuListController = new ModuleLauncherMenuListController
			el: @$('.bv_modLaunchMenuWrapper')
			collection: @moduleLauncherList
		@moduleLauncherListController = new ModuleLauncherListController
			el: @$('.bv_mainModuleWrapper')
			collection: @moduleLauncherList

		unless window.conf.roologin.showpasswordchange
			@$('.bv_changePassword').hide()

		@moduleLauncherMenuListController.render()
		@moduleLauncherListController.render()

		if window.conf.moduleMenus.summaryStats
			@$('.bv_summaryStats').load('/dataFiles/summaryStatistics/summaryStatistics.html')
		else
			@$('.bv_summaryStats').hide()

		if window.AppLaunchParams.moduleLaunchParams?
			@moduleLauncherMenuListController.launchModule window.AppLaunchParams.moduleLaunchParams.moduleName
		else if window.conf.moduleMenus?.moduleAutoLaunchName?
			@$(".bv_launch_#{window.conf.moduleMenus.moduleAutoLaunchName}").click()
		else
			@$('.bv_homePageWrapper').show()

		if window.conf.moduleMenus.logoText?
			logoInfo = window.conf.moduleMenus.logoText
			if window.conf.moduleMenus.logoImageFilePath?
				logoInfo = '<img src='+window.conf.moduleMenus.logoImageFilePath+' style="margin-right: 10px;">'+logoInfo
			@$('.bv_headerName').html logoInfo
		if window.conf.moduleMenus.logoTextLink?
			@$('.bv_headerName').attr('href', window.conf.moduleMenus.logoTextLink)
		if window.conf.moduleMenus.homePageMessage?
			@$('.bv_homePageMessage').html(window.conf.moduleMenus.homePageMessage)
		if window.conf.moduleMenus.copyrightMessage?
			@$('.bv_copyrightMessage').html(window.conf.moduleMenus.copyrightMessage)
		if window.conf.moduleMenus.modules?.external?
			for module in $.parseJSON window.conf.moduleMenus.modules.external
				modLink = '<li><a href="'+module.href+'"target="_blank">'+module.displayName+'</a></li>'
				@$('.bv_externalACASModules').append modLink

		if window.conf.require.login
			if @fastUserSwitchingAllowed()
				@$('.bv_loginUserFirstName').hide()
				@$('.bv_loginUserLastName').hide()
				@setupFastUserSwitching()
			else
				@$('.bv_fastUserSelect').hide()
				@$('.bv_loginUserFirstName').html _.escape(window.AppLaunchParams.loginUser.firstName)
				@$('.bv_loginUserLastName').html _.escape(window.AppLaunchParams.loginUser.lastName)
		else
			@$('.bv_userInfo').hide()

	render: =>
		if window.AppLaunchParams.deployMode?
			unless window.AppLaunchParams.deployMode.toUpperCase() =="PROD"
				@$('.bv_deployMode h1').html(_.escape(window.AppLaunchParams.deployMode.toUpperCase()))
		@heartbeat()
		@

	heartbeat: =>
		## Fetch /api/about endpoint, if 401, then notify user they have been logged out
		## If another error then try something else
		setInterval =>
				originalStatus = @status
				try
					response = await fetch("/api/about", method: 'GET')
					@status = response.status
					@statusText = response.statusText
				catch error
					@status = "error"
					@statusText = "Response error"
				

				# Check if the heartbeat notification exists and is active/visible
				active = @heartbeatToast? && @heartbeatToast.isActive()

				# If we aren't showing the heartbeat notification or the status has changed, then update/show the heartbeat notification
				if !active || originalStatus != @status
					if @heartbeatToast?
						@heartbeatToast.closeToast()
						@heartbeatToast.remove()
					
					if @status == 401
						@heartbeatToast = new ACASToast
							type: "error"
							title: "Logged out"
							text: "You have been logged out. Please login again."
							position: "bottom-right"
							duration: 50000
					else if @status != 200
						@heartbeatToast = new ACASToast
							type: "error"
							title: "Unable to communicate with ACAS: #{@statusText}"
							text: "You may have been disconnected. Please refresh."
							position: "bottom-right"
							duration: 50000
		, 10000		

	handleHome: =>
		$('.bv_mainModuleWrapper').hide()
		$('.bv_homePageWrapper').show()

	handleHideMenus: =>
		@$('.bv_moduleMenuWellWrapper').hide()
		@$('.bv_showModuleMenuControl').show()

	handleShowMenus: =>
		@$('.bv_showModuleMenuControl').hide()
		@$('.bv_moduleMenuWellWrapper').show()

	handleToggleMenus: =>
		if @$('.bv_moduleMenuWellWrapper').is ':hidden'
			@$('.bv_moduleMenuWellWrapper').show()
			@$('.bv_mainModuleWellWrapper').removeClass 'span11'
			@$('.bv_mainModuleWellWrapper').addClass 'span9'
		else
			@$('.bv_moduleMenuWellWrapper').hide()
			@$('.bv_mainModuleWellWrapper').removeClass 'span9'
			@$('.bv_mainModuleWellWrapper').addClass 'span11'

# Fast User Switching Methods

	setupFastUserSwitching: ->
		@socket = io('/user:loggedin')
		@socket.on('connect', @handleConnected.bind(@))
		@socket.on('connect_error', @handleConnectError.bind(@))
		@socket.on('loggedOn', @handleLoggedOn.bind(@))
		@socket.on('tabClosed', @handleOtherTabClosed.bind(@))
		@socket.on('loggedOff', @handleLoggedOff.bind(@))
		@socket.on('usernameUpdated', @handleUserChanged.bind(@))
		@disconnectedAfterLogin = false
		@setupUserSwitchingSelect()

	setupUserSwitchingSelect: ->
		@altUserList = new PickListList()
		@getAllAvailableUsers @altUserList, =>
			@altUserListController = new PickListSelect2Controller
				el: @$('.bv_fastUserSelect')
				collection: @altUserList
				autoFetch: false
				selectedCode: window.AppLaunchParams.loginUserName

	getAllAvailableUsers: (userList, callback) ->
		roles = @getMatchingFastUserSwitchingRoles()
		@getNextGroup roles, 0, userList, callback

	getNextGroup: (roles, index, userList, finalCallback) ->
		if index >= roles.length
			finalCallback()
		else
			role = roles[index++]
			tList = new PickListList()
			tList.url = "/api/authors?roleType=#{role.lsType}&roleKind=#{role.lsKind}&roleName=#{role.roleName}"
			tList.fetch success: =>
				userList.add tList.models
				@getNextGroup roles, index, userList, finalCallback

	handleConnected: =>
		console.log "handleConnected"

	handleConnectError: =>
		@disconnectedAfterLogin = true
		console.log "handleConnectError"

	handleLoggedOn: (numberOfLogins) ->
		console.log "you're logged in this many places: ", numberOfLogins

	handleOtherTabClosed: (numberOfLogins) ->
		console.log "Tab closed elsewhere, you're logged in this many places: ", numberOfLogins

	handleLoggedOff: (numberOfLogins) ->
		console.log "you're logged in this many places: ", numberOfLogins
		window.location = "/login";

	handleLoginUserChange: =>
		newUserName = @$('.bv_fastUserSelect').val()
		console.log "user change requested to: "+newUserName
		unless newUserName == window.AppLaunchParams.loginUserName
			@socket.emit('changeUserName', newUserName)

	handleUserChanged: (updatedUser) =>
		console.log "handleUserChanged"
		console.dir updatedUser
#		updatedUser = JSON.parse updatedUserStr
		console.log "got user change to: "+updatedUser.username
		AppLaunchParams.loginUserName = updatedUser.username
		AppLaunchParams.loginUser = updatedUser
		@setupUserSwitchingSelect()

	fastUserSwitchingAllowed: ->
		switchingRoles = JSON.parse(window.conf.moduleMenus.fastUserSwitchingRoles)
		allowed = false
		if switchingRoles.length > 0 && window.AppLaunchParams.loginUser.roles?
			allowed = UtilityFunctions::testUserHasRoleTypeKindName window.AppLaunchParams.loginUser, switchingRoles
		return allowed

	getMatchingFastUserSwitchingRoles: ->
		matches = []
		for role in JSON.parse(window.conf.moduleMenus.fastUserSwitchingRoles)
			for userRole in window.AppLaunchParams.loginUser.roles
				if userRole.roleEntry.lsType == role.lsType and userRole.roleEntry.lsKind == role.lsKind and userRole.roleEntry.roleName == role.roleName
					matches.push role
		matches

	handleBeforeUnload: =>
		console.log "handleBeforeUnload"
		anyDirty = @moduleLauncherList.some (mod) ->
			mod.get('isDirty')
		if anyDirty
			return "please show a warning"
		else
			return


#TODO config docs in readme.md file
#TODO should some code in mmroutes be rafactored to a general socket utility?
