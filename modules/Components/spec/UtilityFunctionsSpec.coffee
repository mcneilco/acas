describe 'Utility function module testing', ->
	describe "basic plumbing", ->
		it "should be defined", ->
			expect(UtilityFunctions).toBeDefined()

	describe "getFileServiceURL function", ->
		it "should return the path to the file server with correct prefix for mode", ->
			expect(UtilityFunctions::getFileServiceURL()).toContain "upload"

	describe "test user roles", ->
		it "should true if user has a role", ->
			console.log window.loginTestJSON
			hasRole = UtilityFunctions::testUserHasRole window.loginTestJSON.sampleLoginUser, ["admin"]
			expect(hasRole).toBeTruthy()
		it "should false if user does not a role", ->
			hasRole = UtilityFunctions::testUserHasRole window.loginTestJSON.sampleLoginUser, ["king of all Indinia"]
			expect(hasRole).toBeFalsy()

		describe "input formatting features", ->
			beforeEach ->
				@testController = new Backbone.View
					model: new Backbone.Model()
					el: $('#fixture')
				@testController.render()
			it "get val from input and trim it", ->
				@testController.$el.append "<input type='text' class='bv_testInput' />"
				@testController.$('.bv_testInput').val("  some input with spaces  ")
				expect(UtilityFunctions::getTrimmedInput @testController.$('.bv_testInput')).toEqual "some input with spaces"
			it "should parse ACAS standard format yyyy-mm-dd correctly in IE8 and other browsers", ->
				expect(UtilityFunctions::convertYMDDateToMs("2013-6-6")).toEqual new Date(2013, 5, 6).getTime()
			it "should convert date from MS to yyyy-mm-dd format", ->
				expect(UtilityFunctions::convertMSToYMDDate(new Date(2013,5,6).getTime())).toEqual "2013-06-06"

