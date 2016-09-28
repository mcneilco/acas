class window.ModuleLauncher extends Backbone.Model

	defaults:
		isHeader: false
		menuName: "Menu Name Replace Me"
		mainControllerClassName: "controllerClassNameReplaceMe"
		isLoaded: false
		isActive: false
		isDirty: false
		autoLaunchName: null

	requestActivation: ->
		console.log "request activation"
		if @get('autoLaunchName') is "dataViewer"
			console.log @
			console.log window.AppLaunchParams.moduleLaunchParams
			window.open("/dataViewer",'_blank');
		else
			@trigger 'activationRequested', @
			@set isActive: true

	requestDeactivation: ->
		@trigger 'deactivationRequested', @
		@set isActive: false

class window.ModuleLauncherList extends Backbone.Collection
	model: ModuleLauncher


class window.ModuleLauncherMenuController extends Backbone.View
	template: _.template($("#ModuleLauncherMenuView").html())
	tagName: 'li'

	events:
		'click .bv_menuName': "handleSelect"

	initialize: ->
		@model.bind "change", @render

	render: =>
		$(@el).empty()
		$(@el).html(@template(@model.toJSON()))
		@$('.bv_menuName').addClass 'bv_launch_'+@model.get('autoLaunchName')
		if @model.get('isActive') then $(@el).addClass "active"
		else $(@el).removeClass "active"

		@$('.bv_isLoaded').hide()
		if @model.get('isDirty')
			@$('.bv_isDirty').show()
			window.conf.leaveACASMessage = "WARNING: There are unsaved changes."
		else
			@$('.bv_isDirty').hide()
			window.conf.leaveACASMessage = "There are no unsaved changes."

		if @model.has 'requireUserRoles'
			userRoles = []
			_.each @model.get('requireUserRoles'), (role) =>
				if role.indexOf(',')
					roles = role.split(',')
					_.each roles, (r) =>
						userRoles.push $.trim(r)
				else
					userRoles.push r
			if !UtilityFunctions::testUserHasRole window.AppLaunchParams.loginUser, userRoles
				$(@el).attr 'title', "User is not authorized to use this feature"
				@$('.bv_menuName').hide()
				@$('.bv_menuName_disabled').show()

		@

	handleSelect: =>
		@model.requestActivation()
		@trigger "selected", @

	clearSelected: (who) =>
		unless who?.model?.get("menuName") == @model.get("menuName")
			@model.requestDeactivation()

class window.ModuleLauncherMenuHeaderController extends Backbone.View
	tagName: 'li'
	className: "nav-header"

	initialize: ->
		@model.bind "change", @render

	render: =>
		$(@el).html(@model.get('menuName'))

		@

class window.ModuleLauncherMenuListController extends Backbone.View

	template: _.template($("#ModuleLauncherMenuListView").html())

	initialize: ->
		#@collection.bind 'reset', @render()

	render: =>
		# This render is not safe to run twice because
		# it instantiates new controllers and views but doesn't delete the old controllers
		$(@el).empty()
		$(@el).html @template()
		@collection.each @addOne

		@

	addOne: (menuItem) =>
		menuItemController = @makeMenuItemController(menuItem)
		@$('.bv_navList').append menuItemController.render().el

	makeMenuItemController: (menuItem) ->
		if menuItem.get('isHeader')
			menuItemCont = new ModuleLauncherMenuHeaderController
				model: menuItem
		else
			menuItemCont = new ModuleLauncherMenuController
				model: menuItem
			menuItemCont.bind 'selected', @selectionUpdated
			@bind 'clearSelected', menuItemCont.clearSelected

		return menuItemCont

	selectionUpdated: (who) =>
		@trigger 'clearSelected', who

	launchModule: (moduleName) ->
		console.log "launchModule"
		#Note that if the names don't match, this fails silently
		selector = '.bv_launch_'+moduleName
		@$(selector).click()

class window.ModuleLauncherController extends Backbone.View
	tagName: 'div'
	template: _.template($("#ModuleLauncherView").html())

	initialize: ->
		@model.bind 'activationRequested', @handleActivation
		@model.bind 'deactivationRequested', @handleDeactivation

	render: =>
		$(@el).empty()
		$(@el).html @template()
		$(@el).addClass('bv_'+@model.get('mainControllerClassName'))
		if @model.get('isActive')
			$(@el).show()
		else
			$(@el).hide()

		@

	handleActivation:  =>
		unless @model.get('isLoaded')
			unless window.AppLaunchParams.testMode
				@moduleController = new window[@model.get('mainControllerClassName')]({el: @$('.bv_moduleContent')})
				@moduleController.bind 'amDirty', =>
					@model.set isDirty: true
				@moduleController.bind 'amClean', =>
					@model.set isDirty: false
				@moduleController.render()
				@model.set isLoaded: true

		$(@el).show()
		$('.bv_mainModuleWrapper').show()
		$('.bv_homePageWrapper').hide()

	handleDeactivation:  =>
		$(@el).hide()

class window.ModuleLauncherListController extends Backbone.View

	template: _.template($("#ModuleLauncherListView").html())

	initialize: ->


	render: =>
		# This render is not safe to run twice because
		# it instantiates new controllers and views but doesn't delete the old controllers
		$(@el).empty()
		$(@el).html @template()
		@collection.each @addOne

	addOne: (moduleLauncher) =>
		unless moduleLauncher.get('isHeader')
			modLaunchCont = new ModuleLauncherController
				model: moduleLauncher
			@$('.bv_moduleWrapper').append modLaunchCont.render().el
