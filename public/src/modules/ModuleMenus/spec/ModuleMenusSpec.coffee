beforeEach ->
	@fixture = $.clone($("#fixture").get(0))
	@testMenuItems = [
		{isHeader: true, menuName: "Test Header" }
		{isHeader: false, menuName: "Test Launcher 1", mainControllerClassName: "controllerClassName1"}
		{isHeader: false, menuName: "Test Launcher 2", mainControllerClassName: "controllerClassName2"}
		{isHeader: false, menuName: "Test Launcher 3", mainControllerClassName: "controllerClassName3"}
	]

afterEach ->
	$("#fixture").remove()
	$("body").append $(@fixture)

describe "Module Menus Controller testing", ->
	beforeEach ->
		@mmc = new ModuleMenusController
			el: $('#fixture')
			menuListJSON: @testMenuItems # should be in a global config file
		@mmc.render()

	describe "Basic loading", ->
		it "Class should exist", ->
			expect(@mmc).toBeDefined()
		it "Should load the template", ->
			expect($('.bv_modLaunchMenuWrapper')).not.toBeNull()
			expect($('.bv_mainModuleWrapper')).not.toBeNull()
		it "should show the user first name", ->
			if window.configurationNode.serverConfigurationParams.configuration.requireLogin
				expect(@mmc.$('.bv_loginUserFirstName').html()).toContain 'John'
		it "should show the user last name", ->
			if window.configurationNode.serverConfigurationParams.configuration.requireLogin
				expect(@mmc.$('.bv_loginUserLastName').html()).toContain 'McNeil'
		it "should show a logout link", ->
			expect(@mmc.$('.bv_logout').attr('href')).toContain 'logout'

	describe "Sub Controllers load after rendering", ->
		it "Should have 4 menu items", ->
			expect(@mmc.$('.bv_modLaunchMenuWrapper li').length).toEqual 4
		it "Should create and make divs for all the non header ModuleLauncherControllers", ->
			expect(@mmc.$('.bv_mainModuleWrapper div.bv_moduleContent').length).toEqual 3
