class window.ModuleMenusController extends Backbone.View

	template: _.template($("#ModuleMenusView").html())

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

		@moduleLauncherMenuListController.render()
		@moduleLauncherListController.render()

		if window.AppLaunchParams.deployMode?
			unless window.AppLaunchParams.deployMode.toUpperCase() =="PROD"
				@$('.bv_deployMode h1').html(window.AppLaunchParams.deployMode.toUpperCase())

		if window.AppLaunchParams.moduleLaunchParams?
			@moduleLauncherMenuListController.launchModule window.AppLaunchParams.moduleLaunchParams.moduleName

	render: =>

		@

