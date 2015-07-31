assert = require 'assert'
request = require 'request'
_ = require 'underscore'
fs = require 'fs'
config = require '../../../../conf/compiled/conf.js'
csUtilities = require '../../../../public/src/conf/CustomerSpecificServerFunctions.js'


parseResponse = (jsonStr) ->
	try
		return JSON.parse jsonStr
	catch error
		console.log "response unparsable: " + error
		return null


describe "Base ACAS Customer Specific Function Tests", ->
	describe "User information testing", ->
		describe "Get user", ->
			before (done) ->
				@.timeout(20000)
				csUtilities.getUser "bob", (expectnull, user) =>
					@user = user
					done()
			it "should return a user", ->
				assert.equal @user.username, "bob"
				assert.equal @user.email, "bob@mcneilco.com"
			it "should return an array of roles", ->
				assert.equal @user.roles.length > 0, true
			it "should user bob shoud have role admin", ->
				roleFound = false
				_.each @user.roles, (role) ->
					if role.roleEntry.roleName == "admin" then roleFound = true
				assert.equal roleFound, true

	describe "entity file handling", ->

		inputFileValue =
			'clobValue': null
			'codeKind': null
			'codeOrigin': null
			'codeType': null
			'codeTypeAndKind': 'null_null'
			'codeValue': null
			'comments': null
			'concUnit': null
			'concentration': null
			'dateValue': null
			'deleted': false
			'fileValue': 'test Work List (1).csv'
			'id': 4535944
			'ignored': false
			'lsKind': 'source file'
			'lsTransaction': 3463
			'lsType': 'fileValue'
			'lsTypeAndKind': 'fileValue_source file'
			'modifiedBy': null
			'modifiedDate': null
			'numberOfReplicates': null
			'numericValue': null
			'operatorKind': null
			'operatorType': null
			'operatorTypeAndKind': 'null_null'
			'publicData': true
			'recordedBy': 'bob'
			'recordedDate': 1420572665000
			'sigFigs': null
			'stringValue': null
			'uncertainty': null
			'uncertaintyType': null
			'unitKind': null
			'unitType': null
			'unitTypeAndKind': 'null_null'
			'urlValue': null
			'version': 0


		describe "async call to move a file to the correct destination given a fileValue and entity type", ->
			describe "when called for protocols", ->
				before (done) ->
					@testFilePath = config.all.server.datafiles.relative_path + "/test Work List (1).csv"
					fs.writeFileSync @testFilePath, "key,value\nflavor,sweet"
					fv = JSON.parse(JSON.stringify(inputFileValue))
					csUtilities.relocateEntityFile fv, "PROT", "PROT12345", (passed) =>
						@outputFileValue = fv
						@passed = passed
						done()
#				after ->
#					fs.unlink @testFilePath
				it "should return passed", ->
					assert.equal @passed, true
				it "should return a fileValue with the correct relative path for Protocol", ->
					assert.equal @outputFileValue.fileValue, "protocols/PROT12345/test Work List (1).csv"
				it "should return a fileValue with base file name in comments", ->
					assert.equal @outputFileValue.comments, "test Work List (1).csv"
				it "should remove the file from the old path", ->
					fs.unlink @testFilePath, (err) =>
						assert.equal err.errno, 34 #it should not be there to unlink
				it "should add the file to the new path", ->
					fs.unlink config.all.server.datafiles.relative_path + "/protocols/PROT12345/test Work List (1).csv", (err) =>
						assert.equal err, null #it should be there to unlink, and we've cleaned up
			describe "when called for experiments", ->
				before (done) ->
					@testFilePath = config.all.server.datafiles.relative_path + "/test Work List (1).csv"
					fs.writeFileSync @testFilePath, "key,value\nflavor,sweet"
					fv = JSON.parse(JSON.stringify(inputFileValue))
					csUtilities.relocateEntityFile fv, "EXPT", "EXPT12345", (passed) =>
						@outputFileValue = fv
						@passed = passed
						done()
#				after ->
#					fs.unlink @testFilePath
				it "should return a fileValue with the correct relative path for Experiment", ->
					assert.equal @outputFileValue.fileValue, "experiments/EXPT12345/test Work List (1).csv"
				it "should add the file to the new path", ->
					fs.unlink @testFilePath, (err) =>
						assert.equal err.errno, 34 #it should not be there to unlink
				it "should remove the file from the old path", ->
					fs.unlink config.all.server.datafiles.relative_path + "/experiments/EXPT12345/test Work List (1).csv", (err) =>
						assert.equal err, null #it should be there to unlink, and we've cleaned up
			describe "when called for another kind of entity", ->
				before (done) ->
					@testFilePath = config.all.server.datafiles.relative_path + "/test Work List (1).csv"
					fs.writeFileSync @testFilePath, "key,value\nflavor,sweet"
					fv = JSON.parse(JSON.stringify(inputFileValue))
					csUtilities.relocateEntityFile fv, "PT", "PT12345", (passed) =>
						@outputFileValue = fv
						@passed = passed
						done()
#				after ->
#					fs.unlink @testFilePath
				it "should return a fileValue with the correct relative path for Experiment", ->
					assert.equal @outputFileValue.fileValue, "entities/parentThings/PT12345/test Work List (1).csv"
				it "should add the file to the new path", ->
					fs.unlink @testFilePath, (err) =>
						assert.equal err.errno, 34 #it should not be there to unlink
				it "should remove the file from the old path", ->
					fs.unlink config.all.server.datafiles.relative_path + "/entities/parentThings/PT12345/test Work List (1).csv", (err) =>
						assert.equal err, null #it should be there to unlink, and we've cleaned up
			describe "when called with nonexistant file", ->
				before (done) ->
					@testFilePath = config.all.server.datafiles.relative_path + "/test Work List (1).csv"
					fv = JSON.parse(JSON.stringify(inputFileValue))
					csUtilities.relocateEntityFile fv, "EXPT", "EXPT12345", (passed) =>
						@outputFileValue = fv
						@passed = passed
						done()
				it "should return a passed = false", ->
					assert.equal @passed, false
			describe "when entity prefix does not exist", ->
				before (done) ->
					@testFilePath = config.all.server.datafiles.relative_path + "/test Work List (1).csv"
					fs.writeFileSync @testFilePath, "key,value\nflavor,sweet"
					fv = JSON.parse(JSON.stringify(inputFileValue))
					csUtilities.relocateEntityFile fv, "NOTHING", "EXPT12345", (passed) =>
						@outputFileValue = fv
						@passed = passed
						done()
				after ->
					fs.unlink @testFilePath
				it "should return a passed = false", ->
					assert.equal @passed, false

#TODO
		describe "get current download URL for a given file, give a fileValue", ->


	describe "get calculated compound properties", ->
		describe "when valid compounds sent with valid properties", ->
			propertyList = ["HEAVY_ATOM_COUNT", "MONOISOTOPIC_MASS"]
			entityList = "CMPD76\nCMPD2\nCMPD78\n"
			before (done) ->
				@.timeout(20000)
				csUtilities.getTestedEntityProperties propertyList, entityList, (properties) =>
					@propertyList = properties
					done()
			it "should return 5 rows including a trailing \n", ->
				assert.equal @propertyList.split('\n').length, 5
			it "should have 3 columns", ->
				res = @propertyList.split('\n')
				assert.equal res[0].split(',').length, 3
			it "should have a header row", ->
				res = @propertyList.split('\n')
				assert.equal res[0], "id,HEAVY_ATOM_COUNT,MONOISOTOPIC_MASS"
			it "should have a number in the first result row", ->
				res = @propertyList.split('\n')
				assert.equal isNaN(parseFloat(res[1].split(',')[1])),false
		describe "when valid compounds sent with invalid property", ->
			propertyList = ["ERROR", "deep_fred"]
			entityList = "CMPD76\nCMPD2\nCMPD78\n"
			before (done) ->
				@.timeout(20000)
				csUtilities.getTestedEntityProperties propertyList, entityList, (properties) =>
					@propertyList = properties
					done()
			it "should return null \n", ->
				assert.equal @propertyList, null
		describe "when invalid compounds sent with valid properties", ->
			propertyList = ["HEAVY_ATOM_COUNT", "MONOISOTOPIC_MASS"]
			entityList = "ERROR1\nERROR2\nERROR3\n"
			before (done) ->
				@.timeout(20000)
				csUtilities.getTestedEntityProperties propertyList, entityList, (properties) =>
					@propertyList = properties
					done()
			it "should return 5 rows including a trailing \n", ->
				assert.equal @propertyList.split('\n').length, 5
			it "should have 3 columns", ->
				res = @propertyList.split('\n')
				assert.equal res[0].split(',').length, 3
			it "should have a header row", ->
				res = @propertyList.split('\n')
				assert.equal res[0], "id,HEAVY_ATOM_COUNT,MONOISOTOPIC_MASS"
			it "should have no number in the first result row", ->
				res = @propertyList.split('\n')
				assert.equal res[1].split(',')[1],""


	describe "get preferred batchids", ->
		#global.specRunnerTestmode = true #set to true to excercise stub
		describe "when valid, alias, and invalid batches sent", ->
			requestData =
				requests: [
					{requestName: "CMPD-0000001-01A"} #normal
					{requestName: "CMPD-0000002-01A"} #normal
					{requestName: "CMPD-999999999::9999"} #none
				]
			before (done) ->
				@.timeout(20000)
				csUtilities.getPreferredBatchIds requestData.requests, (response) =>
					@response = response
					console.log response
					done()
			it "should return 3 results", ->
				assert.equal @response.length, 3
			it "should have the batch if not an alias", ->
				assert.equal @response[0].requestName, @response[0].preferredName
			it "should have the batch an alias", ->
				assert.equal @response[1].preferredName, "CMPD-0000002-01A"
			it "should not return an alias if the batch is not valid", ->
				assert.equal @response[2].preferredName, ""
		if global.specRunnerTestmode
			describe "when 1000 batches sent", ->
				requests = for i in [1..1000]
					num = "000000000"+i
					num = num.substr(num.length-9)
					requestName: "DNS"+num+"::1"
				before (done) ->
					@.timeout(20000)
					csUtilities.getPreferredBatchIds requests, (response) =>
						@response = response
						done()
				it "should return 1000 results", ->
					assert.equal @response.length, 1000
				it "should have the batch if not an alias", ->
					assert.equal @response[999].requestName, @response[999].preferredName

	describe "get preferred parent ids", ->
		describe "when valid, alias, and invalid batches sent", ->
			requestData =
				requests: [
#					{requestName: "DNS000000001"} #normal
#					{requestName: "DNS000673874"} #alias
#					{requestName: "DNS999999999"} #none
					{requestName: "CMPD-0000001"} #normal
					{requestName: "CMPD-0000002"} #no aliases yet in our creg
					{requestName: "CMPD-999999999"} #none
				]
			before (done) ->
				@.timeout(20000)
				#comment the next line to test in live mode
				#global.specRunnerTestmode = true
				csUtilities.getPreferredParentIds requestData.requests, (response) =>
					@response = response
					console.log response
					done()
			it "should return 3 results", ->
				assert.equal @response.length, 3
			it "should have the batch if not an alias", ->
				assert.equal @response[0].requestName, @response[0].preferredName
			it "should have the batch an alias", ->
				assert.equal @response[1].preferredName, "CMPD-0000002"
			it "should not return an alias if the batch is not valid", ->
				assert.equal @response[2].preferredName, ""
