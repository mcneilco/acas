class window.ModuleMenusController extends Backbone.View

	template: _.template($("#ModuleMenusView").html())

	window.onbeforeunload = () ->
		if window.conf.leaveACASMessage == "WARNING: There are unsaved changes."
			return window.conf.leaveACASMessage
		else
			return null

	initialize: ->

		$(@el).html @template()

		@moduleLauncherList = new ModuleLauncherList(@options.menuListJSON)
		@moduleLauncherMenuListController = new ModuleLauncherMenuListController
			el: @$('.bv_modLaunchMenuWrapper')
			collection: @moduleLauncherList
		@moduleLauncherListController = new ModuleLauncherListController
			el: @$('.bv_mainModuleWrapper')
			collection: @moduleLauncherList

		if window.conf.require.login
			@$('.bv_loginUserFirstName').html window.AppLaunchParams.loginUser.firstName
			@$('.bv_loginUserLastName').html window.AppLaunchParams.loginUser.lastName
		else
			@$('.bv_userInfo').hide()

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
		else
			@$('.bv_homePageWrapper').show()

		if window.conf.moduleMenus.headerName?
			@$('.bv_headerName').html(window.conf.moduleMenus.headerName)
		if window.conf.moduleMenus.homePageMessage?
			@$('.bv_homePageMessage').html(window.conf.moduleMenus.homePageMessage)
		if window.conf.moduleMenus.copyrightMessage?
			@$('.bv_copyrightMessage').html(window.conf.moduleMenus.copyrightMessage)
		if window.conf.moduleMenus.modules?.external?
			for module in $.parseJSON window.conf.moduleMenus.modules.external
				modLink = '<li><a href="'+module.href+'"target="_blank">'+module.displayName+'</a></li>'
				@$('.bv_externalACASModules').append modLink

	render: =>
		if window.AppLaunchParams.deployMode?
			unless window.AppLaunchParams.deployMode.toUpperCase() =="PROD"
				@$('.bv_deployMode h1').html(window.AppLaunchParams.deployMode.toUpperCase())

		@

	events: ->
		'click .bv_headerName': "handleHome"

	handleHome: =>
		$('.bv_mainModuleWrapper').hide()
		$('.bv_homePageWrapper').show()
