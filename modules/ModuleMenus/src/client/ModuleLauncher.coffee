class window.ModuleLauncher extends Backbone.Model

	defaults:
		isHeader: false
		menuName: "Menu Name Replace Me"
		mainControllerClassName: null
		isLoaded: false
		isActive: false
		isDirty: false
		isLocked: false
		autoLaunchName: null
		collapsible: false

	requestActivation: ->
		if @get('externalLink')?
			window.open(@get('externalLink'),'_blank');
		else if @get('autoLaunchName') is "dataViewer"
			if window.conf.moduleMenus?.dataViewerDeepLink?
				dataViewerDeepLink = window.conf.moduleMenus.dataViewerDeepLink
			else
				dataViewerDeepLink = '/dataViewer'
			window.open(dataViewerDeepLink,'_blank');
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
	className: 'bv_menuItem'

	events:
		'click .bv_menuName': "handleSelect"

	initialize: ->
		@model.bind "change", @render

	render: =>
		$(@el).empty()
		$(@el).html(@template(@model.toJSON()))
		if @model.get('mainControllerClassName')?
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
			if @model.get('isLocked')
				@$('.bv_isLocked').show()
			else
				@$('.bv_isLocked').hide()

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
			#				@$('.bv_menuName_disabled').show()

		else
			@$('.bv_menuName').hide()
			@$('.bv_menuName_disabled').show()
			@$('.bv_isLoaded').hide()
			@$('.bv_isDirty').hide()
			@$('.bv_isLocked').hide()

		@

	handleSelect: =>
		@model.requestActivation()
		@trigger "selected", @

	clearSelected: (who) =>
		unless who?.model?.get("menuName") == @model.get("menuName")
			@model.requestDeactivation()

class window.ModuleLauncherMenuHeaderController extends Backbone.View
	tagName: 'li'
	className: "nav-header bv_notTopHeader"

	initialize: ->
		@model.bind "change", @render

	render: =>
		if (@model.get('requireUserRoles')? and !UtilityFunctions::testUserHasRole window.AppLaunchParams.loginUser, @model.get('requireUserRoles'))
			$(@el).hide()
		else
			$(@el).html(@model.get('menuName'))

		@

class window.ModuleLauncherMenuCollapsibleHeaderController extends Backbone.View
	template: _.template($("#ModuleLauncherMenuCollapsibleHeaderView").html())
	tagName: 'div'
	className: 'bv_collapsibleHeaderController bv_notTopHeader'

	events:
		'click .bv_moduleCategory': "handleClick"

	render: =>
		if (@model.get('requireUserRoles')? and !UtilityFunctions::testUserHasRole window.AppLaunchParams.loginUser, @model.get('requireUserRoles'))
			$(@el).hide()
		else
			$(@el).empty()
			$(@el).html @template()
			@$('.bv_moduleCategory').prepend @model.get('menuName')

		@

	addSubMenu: (el) ->
		@$('.bv_modules').append el

	handleClick: =>
		@$('.bv_modules').slideToggle 200
		@$('.bv_caret').toggle()

	collapse: ->
		@$('.bv_modules').hide()
		@$('.bv_caret_collapse').hide()
		@$('.bv_caret_expand').show()

	expand: ->
		@$('.bv_modules').show()
		@$('.bv_caret_expand').hide()
		@$('.bv_caret_collapse').show()

class window.ModuleLauncherMenuListController extends Backbone.View
	events:
		'click .bv_expandAll': "handleExpandAll"
		'click .bv_collapseAll': "handleCollapseAll"

	template: _.template($("#ModuleLauncherMenuListView").html())

	initialize: ->
		@lastCollapsibleHeader = null
		@collapsibleHeaders = []
		#@collection.bind 'reset', @render()

	render: =>
		# This render is not safe to run twice because
		# it instantiates new controllers and views but doesn't delete the old controllers
		$(@el).empty()
		$(@el).html @template()
		@collection.each @addOne
		@$('.bv_notTopHeader:eq(0)').removeClass "bv_notTopHeader"

		@

	addOne: (menuItem) =>
		menuItemController = @makeMenuItemController(menuItem)
		if !menuItem.get('isHeader') and @lastCollapsibleHeader?
			@lastCollapsibleHeader.addSubMenu menuItemController.render().el
		else
			@$('.bv_navList').append menuItemController.render().el

	makeMenuItemController: (menuItem) ->
		if menuItem.get('isHeader')
			if menuItem.get('collapsible')
				menuItemCont = new ModuleLauncherMenuCollapsibleHeaderController
					model: menuItem
				@lastCollapsibleHeader = menuItemCont
				@collapsibleHeaders.push menuItemCont
			else
				menuItemCont = new ModuleLauncherMenuHeaderController
					model: menuItem
				@lastCollapsibleHeader = null
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

	handleExpandAll: =>
		for header in @collapsibleHeaders
			header.expand()
		@$('.bv_expandAll').hide()
		@$('.bv_collapseAll').show()

	handleCollapseAll: =>
		for header in @collapsibleHeaders
			header.collapse()
		@$('.bv_collapseAll').hide()
		@$('.bv_expandAll').show()

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
		$(@el).show()
		$('.bv_mainModuleWrapper').show()
		$('.bv_homePageWrapper').hide()
		unless @model.get('isLoaded')
			unless window.AppLaunchParams.testMode
				@moduleController = new window[@model.get('mainControllerClassName')]({el: @$('.bv_moduleContent')})
				@moduleController.bind 'amDirty', =>
					@model.set isDirty: true
				@moduleController.bind 'amClean', =>
					@model.set isDirty: false
				@moduleController.bind 'editLocked', =>
					@model.set isLocked: true
				@moduleController.bind 'editUnLocked', =>
					@model.set isLocked: false
				@moduleController.render()
				@model.set isLoaded: true

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
