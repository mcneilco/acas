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
