class window.AppRouter extends Backbone.Router

	routes:
		"fred/:docid": "existingDoc"
		"fred": "newDoc"


	initialize: (options) ->
		@appController = options.appController

	existingDoc: (val) ->
		#console.log "got fred: "+val
	newDoc: (val) ->
		#console.log "got new doc req"


class window.ModuleMenusController extends Backbone.View

	template: _.template($("#ModuleMenusView").html())

	initialize: ->
#		@router = new AppRouter
#			appController: @
#		window.appRouter = @router #TODO is there a better way to give controllers 3 layers down have access to this?

		$(@el).html @template()

		@moduleLauncherList = new ModuleLauncherList(@options.menuListJSON)
		@moduleLauncherMenuListController = new ModuleLauncherMenuListController
			el: @$('.bv_modLaunchMenuWrapper')
			collection: @moduleLauncherList
		@moduleLauncherListController = new ModuleLauncherListController
			el: @$('.bv_mainModuleWrapper')
			collection: @moduleLauncherList


		# Start history after modules all get parsed so routes are added first
		#console.log @router
#		Backbone.history.start
#			pushState: true
#			root: "/acas"
#		return

	render: =>
		# This render is not safe to run twice because
		# it instantiates new controllers and views but doesn't delete the old controllers
		@moduleLauncherMenuListController.render()
		@moduleLauncherListController.render()
		@$('.bv_loginUserFirstName').html window.AppLaunchParams.loginUser.firstName
		@$('.bv_loginUserLastName').html window.AppLaunchParams.loginUser.lastName
		if window.AppLaunchParams.deployMode?
			unless window.AppLaunchParams.deployMode.toUpperCase() =="PROD"
				@$('.bv_deployMode h1').html(window.AppLaunchParams.deployMode.toUpperCase())
		@