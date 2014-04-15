describe 'Utility function module testing', ->
	describe "basic plumbing", ->
		it "should be defined", ->
			expect(UtilityFunctions).toBeDefined()
		it "should return the path to the file server with correct prefix for mode", ->
			expect(UtilityFunctions::getFileServiceURL()).toContain "upload"
