describe "Module Menu System Testing", ->
	beforeEach ->
		@fixture = $("#fixture")

	afterEach ->
		$("#fixture").remove()
		$("body").append '<div id="fixture"></div>'

  ##########################################
	describe "Module Launcher Model Testing", ->
		beforeEach ->
			@modLauncher = new ModuleLauncher()

		describe "Default testing", ->
			it "Should have defualt values", ->
				expect(@modLauncher.get('isHeader')).toBeFalsy()
				expect(@modLauncher.get('menuName')).toEqual "Menu Name Replace Me"
				expect(@modLauncher.get('isLoaded')).toBeFalsy()
				expect(@modLauncher.get('isActive')).toBeFalsy()
				expect(@modLauncher.get('isDirty')).toBeFalsy()
				expect(@modLauncher.get('mainControllerClassName')).toEqual "controllerClassNameReplaceMe"
		describe "activation", ->
			it "should trigger activation request", ->
				runs ->
					@modLauncher.bind 'activationRequested', =>
						@gotTrigger = true
					@modLauncher.requestActivation()
				waitsFor =>
					@gotTrigger
				runs ->
					expect(@gotTrigger).toBeTruthy()
		describe "de-activation", ->
			it "should trigger deactivation request", ->
				runs ->
					@modLauncher.bind 'deactivationRequested', =>
						@gotTrigger = true
					@modLauncher.requestDeactivation()
				waitsFor =>
					@gotTrigger
				runs ->
					expect(@gotTrigger).toBeTruthy()

	##########################################
 	describe "Module Launcher List Testing", ->
		beforeEach ->
			@modLauncherList = new ModuleLauncherList(window.moduleMenusTestJSON.testMenuItems)

		describe "Existence test", ->
			it "should instanitate with 6 entries", ->
				expect(@modLauncherList.length).toEqual 6

	##########################################
	describe "ModuleLauncherMenuController tests", ->
		beforeEach ->
			@modLauncher = new ModuleLauncher
				isHeader: false
				menuName: "test launcher"
				mainControllerClassName: "testLauncherClassName"
			@modLauncherMenuController = new ModuleLauncherMenuController
				model: @modLauncher
			$('#fixture').append @modLauncherMenuController.render().el

		describe "Upon render", ->
			it "should load the template", ->
				expect($('.bv_menuName')).toBeDefined()
			it "Should set its menu name", ->
				expect(@modLauncherMenuController.$('.bv_menuName').html()).toEqual "test launcher"
			it "should show that it is not running", ->
				expect(@modLauncherMenuController.$('.bv_isLoaded')).not.toBeVisible()
			it "should show that it is not dirty", ->
				expect(@modLauncherMenuController.$('.bv_isDirty')).not.toBeVisible()
			it "should should hide disabled mode", ->
				expect(@modLauncherMenuController.$('.bv_menuName_disabled')).not.toBeVisible()
			it "should should show enabled mode", ->
				expect(@modLauncherMenuController.$('.bv_menuName')).toBeVisible()

		describe "When clicked", ->
			beforeEach ->
				@modLauncherMenuController.bind "selected", =>
					@gotTrigger = true
				@modLauncherMenuController.$('.bv_menuName').click()
			it "should set style active", ->
				expect(@modLauncherMenuController.el).toHaveClass "active"
			it "should set the model to active", ->
				expect(@modLauncherMenuController.model.get('isActive')).toBeTruthy()
			it "should trigger a selected event", ->
				runs ->
				waitsFor =>
					@gotTrigger
				runs ->
					expect(@gotTrigger).toBeTruthy()

		describe "When module is running", ->
			it "should show that it is running", ->
				@modLauncher.set isLoaded: true
				expect(@modLauncherMenuController.$('.bv_isLoaded')).toBeVisible()

		describe "When module has been edited and not saved", ->
			it "should show that it is dirty", ->
				@modLauncher.set isDirty: true
				expect(@modLauncherMenuController.$('.bv_isDirty')).toBeVisible()

		describe "when deselected", ->
			it "should change style", ->
				@modLauncherMenuController.$('.bv_menuName').click()
				expect(@modLauncherMenuController.el).toHaveClass "active"
				@modLauncherMenuController.clearSelected(new ModuleLauncherMenuController({model: new ModuleLauncher()}))
				expect($(@modLauncherMenuController.el).hasClass("active")).toBeFalsy()
				expect(@modLauncherMenuController.model.get('isActive')).toBeFalsy()

		describe "when user not authorized to launch module", ->
			beforeEach ->
				@modLauncher2 = new ModuleLauncher
					isHeader: false
					menuName: "test launcher"
					mainControllerClassName: "testLauncherClassName"
					requireUserRoles: ["admin", "loadData"]
				@modLauncherMenuController2 = new ModuleLauncherMenuController
					model: @modLauncher2
			describe "with current user with no roles attribute", ->
				it "should enable menu item", ->
					$('#fixture').append @modLauncherMenuController2.render().el
					expect(@modLauncherMenuController.$('.bv_menuName_disabled')).not.toBeVisible()
					expect(@modLauncherMenuController.$('.bv_menuName')).toBeVisible()
			describe "with current user with roles specified but not required role", ->
				beforeEach ->
					window.AppLaunchParams.loginUser.roles =
						[
							{
								id: 3
								roleEntry:
									id: 2
									roleDescription: "what Mal is not"
									roleName: "king of all indinia"
									version: 0
								version: 0
							}
						]
					$('#fixture').append @modLauncherMenuController2.render().el
				it "should disable menu item", ->
					expect(@modLauncherMenuController2.$('.bv_menuName_disabled')).toBeVisible()
					expect(@modLauncherMenuController2.$('.bv_menuName')).not.toBeVisible()
				it "should have title set to support mouse over", ->
					expect($(@modLauncherMenuController2.el).attr("title")).toContain "not authorized"
			describe "with current user having allowed role specified", ->
				beforeEach ->
					window.AppLaunchParams.loginUser.roles =
						[
							{
								id: 3
								roleEntry:
									id: 2
									roleDescription: "data loader"
									roleName: "loadData"
									version: 0
								version: 0
							}
						]
					$('#fixture').append @modLauncherMenuController2.render().el
				it "should enable menu item", ->
					expect(@modLauncherMenuController.$('.bv_menuName_disabled')).not.toBeVisible()
					expect(@modLauncherMenuController.$('.bv_menuName')).toBeVisible()

	##########################################
	describe "ModuleLauncherMenuHeaderController tests", ->
		beforeEach ->
			@modLauncher = new ModuleLauncher
				isHeader: true
				menuName: "test header"
			@modLauncherMenuHeaderController = new ModuleLauncherMenuHeaderController
				model: @modLauncher
			$('#fixture').append @modLauncherMenuHeaderController.render().el

		describe "Upon render", ->
			it "Should set its menu name", ->
				expect($(@modLauncherMenuHeaderController.el).html()).toEqual "test header"
			it "should have the header class", ->
				expect(@modLauncherMenuHeaderController.el).toHaveClass "nav-header"

		describe "When clicked", ->
			it "should not set style active", ->
				$(@modLauncherMenuHeaderController.el).click()
				expect(@modLauncherMenuHeaderController.el).not.toHaveClass "active"

	##########################################
	describe "ModuleLauncherMenuListController tests", ->
		beforeEach ->
			@modLauncherList = new ModuleLauncherList(window.moduleMenusTestJSON.testMenuItems)

			@ModLauncherMenuListController = new ModuleLauncherMenuListController
				el: '#fixture'
				collection: @modLauncherList
			@ModLauncherMenuListController.render()

		describe "Upon render", ->
			it "should load the template", ->
				expect($('.bv_navList')).toBeDefined()
			it "should show 6 items", ->
				expect(@ModLauncherMenuListController.$('li').length).toEqual 6
			it "should show a header as specified in the test json", ->
				expect(@ModLauncherMenuListController.$('li :eq(0) ').html()).toEqual "Test Header"
			it "should show a header with correct class", ->
				expect(@ModLauncherMenuListController.$('li :eq(0) ')).toHaveClass "nav-header"
			it "should show the correct menu name in menu item 1", ->
				expect(@ModLauncherMenuListController.$('li :eq(1) .bv_menuName').html()).toEqual "Test Launcher 1"

		describe "Selection handling", ->
			describe "when loaded", ->
				it "should have none active", ->
					expect(@ModLauncherMenuListController.$('li .active').length).toEqual 0
			describe "when second activated", ->
				beforeEach ->
					@ModLauncherMenuListController.bind "selectionUpdated", =>
						@gotTrigger = true
					@ModLauncherMenuListController.$('.bv_menuName :eq(1) ').click()
				it "should activate the correct menu", ->
					expect(@ModLauncherMenuListController.$('li :eq(1)')).not.toHaveClass('active')
					expect(@ModLauncherMenuListController.$('li :eq(2)')).toHaveClass('active')

			describe "when second activated, then first activated", ->
				it "should activate the correct menu", ->
					@ModLauncherMenuListController.$('.bv_menuName :eq(1) ').click()
					expect(@ModLauncherMenuListController.$('li :eq(1)')).not.toHaveClass('active')
					expect(@ModLauncherMenuListController.$('li :eq(2)')).toHaveClass('active')
					@ModLauncherMenuListController.$('.bv_menuName :eq(0) ').click()
					expect(@ModLauncherMenuListController.$('li :eq(1)')).toHaveClass('active')
					expect(@ModLauncherMenuListController.$('li :eq(2)')).not.toHaveClass('active')

	##########################################
	describe "Module Launcher Controller Testing", ->
		beforeEach ->
			@modLauncher = new ModuleLauncher
				menuName: "test menu"
				mainControllerClassName: "testClassName"
			@modLauncherCont = new ModuleLauncherController
				el: '#fixture'
				model: @modLauncher
			@modLauncherCont.render()

		describe "Upon render", ->
			it "Should load its template", ->
				expect($('.bv_moduleContent').html()).toEqual ""
			it "Should be hidden", ->
				expect($('#fixture')).not.toBeVisible()
			it "Should set its element className to the bv_+the controller class", ->
				expect($('#fixture')).toHaveClass('bv_'+@modLauncher.get('mainControllerClassName'))
		describe "When activation requested", ->
			beforeEach ->
				@modLauncherCont.model.requestActivation()
			it "should be shown", ->
				expect($('#fixture')).toBeVisible()
			describe "When deactivation requested", ->
				beforeEach ->
					@modLauncherCont.model.requestDeactivation()
				it "should be hidden", ->
					expect($('#fixture')).not.toBeVisible()

	##########################################
	describe "ModuleLauncherListController tests", ->
		beforeEach ->
			@modLauncherList = new ModuleLauncherList(window.moduleMenusTestJSON.testMenuItems)

			@modLauncherListController = new ModuleLauncherListController
				el: '#fixture'
				collection: @modLauncherList
			@modLauncherListController.render()

		describe "Upon render", ->
			it "Should load its template", ->
				expect($('.bv_moduleWrapper')).toBeDefined()
			it "Should create and make divs for all the non-header ModuleLauncherControllers", ->
				expect(@modLauncherListController.$('.bv_moduleWrapper div.bv_moduleContent').length).toEqual 5

