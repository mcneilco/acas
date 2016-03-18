beforeEach ->
	@fixture = $.clone($("#fixture").get(0))

afterEach ->
	$("#fixture").remove()
	$("body").append $(@fixture)

describe "Module Menus Controller testing", ->
	beforeEach ->
		@mmc = new ModuleMenusController
			el: $('#fixture')
			menuListJSON: window.moduleMenusTestJSON.testMenuItems # should be in a global config file
		@mmc.render()

	describe "Basic loading", ->
		it "Class should exist", ->
			expect(@mmc).toBeDefined()
		it "Should load the template", ->
			expect($('.bv_modLaunchMenuWrapper')).not.toBeNull()
			expect($('.bv_mainModuleWrapper')).not.toBeNull()
		it "should show the user first name", ->
			if window.conf.require.login
				expect(@mmc.$('.bv_loginUserFirstName').html()).toContain 'John'
		it "should show the user last name", ->
			if window.conf.require.login
				expect(@mmc.$('.bv_loginUserLastName').html()).toContain 'McNeil'
		it "should show a logout link", ->
			if window.conf.require.login
				expect(@mmc.$('.bv_logout').attr('href')).toContain 'logout'


	describe "Sub Controllers load after rendering", ->
		it "Should have 6 menu items", ->
			expect(@mmc.$('.bv_modLaunchMenuWrapper li').length).toEqual 6
		it "Should create and make divs for all the non header ModuleLauncherControllers", ->
			expect(@mmc.$('.bv_mainModuleWrapper div.bv_moduleContent').length).toEqual 5

	describe "Deploy mode display", ->
		beforeEach ->
			@mmc = new ModuleMenusController
				el: $('#fixture')
				menuListJSON: window.moduleMenusTestJSON.testMenuItems # should be in a global config file
		it "should show the deploy mode if set", ->
			window.AppLaunchParams.deployMode = "Stage"
			@mmc.render()
			expect(@mmc.$('.bv_deployMode h1').html()).toEqual "STAGE"
		it "should not show the deploy mode if set to Prod", ->
			window.AppLaunchParams.deployMode = "Prod"
			@mmc.render()
			expect(@mmc.$('.bv_deployMode h1').html()).toEqual ""

	describe "change password display", ->
		describe "show password change link mode", ->
			beforeEach ->
				@showPassMode = window.conf.roologin.showpasswordchange
				window.conf.roologin.showpasswordchange=true
				@mmc = new ModuleMenusController
					el: $('#fixture')
					menuListJSON: window.moduleMenusTestJSON.testMenuItems # should be in a global config file
			afterEach ->
				window.conf.roologin.showpasswordchange = @showPassMode
			it "should show the change password link", ->
				expect(@mmc.$('.bv_changePassword')).toBeVisible()
		describe "hide password change link mode", ->
			beforeEach ->
				@showPassMode = window.conf.roologin.showpasswordchange
				window.conf.roologin.showpasswordchange=false
				@mmc = new ModuleMenusController
					el: $('#fixture')
					menuListJSON: window.moduleMenusTestJSON.testMenuItems # should be in a global config file
			afterEach ->
				window.conf.roologin.showpasswordchange = @showPassMode
			it "should hide the change password link", ->
				expect(@mmc.$('.bv_changePassword')).not.toBeVisible()


