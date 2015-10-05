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


describe "DNS Customer Specific Function Tests", ->
	describe "User information testing", ->
		describe "Get user", ->
			before (done) ->
				@.timeout(20000)
				csUtilities.getUser "jquiroz", (expectnull, user) =>
					@user = user
					console.log user
					done()
			it "should return a user", ->
				assert.equal @user.username, "jquiroz"
				assert.equal @user.email, "jquiroz@dartneuroscience.com"
			it "should return an array of roles", ->
				assert.equal @user.roles.length > 0, true
			it "should user jquiroz shoud have role DL_CMG", ->
				roleFound = false
				_.each @user.roles, (role) ->
					if role.roleEntry.roleName == "DL_CMG" then roleFound = true
				assert.equal roleFound, true

	describe "file service upload", ->
		describe "post file success", ->
			# 1) needs to run from acas directory
			# 2) requires acas/privateUploads/test.csv to pass.
			#    touch test.csv works just fine
			before (done) ->
				@.timeout(20000)
				@testFilePath = config.all.server.datafiles.relative_path + "/test.csv"
				fs.writeFileSync @testFilePath, "key,value\nflavor,sweet"
				csUtilities.postToFileService @testFilePath, "jmcneil", "http://thisisatest", (corpFileName) =>
					@corpFileName = corpFileName
					console.log "corpFileName: "+corpFileName
					done()
			after ->
				fs.unlink @testFilePath
			it "should return a corpFileName", ->
				assert.equal @corpFileName.indexOf("FILE")>-1, true
		describe "post non existent file", ->
			before (done) ->
				@.timeout(20000)
				@testFilePath = config.all.server.datafiles.relative_path + "/test.csv"
				csUtilities.postToFileService @testFilePath, "jmcneil", "http://thisisatest", (corpFileName) =>
					@corpFileName = corpFileName
					console.log corpFileName
					done()
			it "should return null", ->
				assert.equal @corpFileName, null


	describe "get calculated compound properties", ->
		describe "when valid compounds sent with valid properties", ->
			before (done) ->
				propertyList = ["HEAVY_ATOM_COUNT", "MONOISOTOPIC_MASS"]
				entityList = "DNS76\nDNS2\nDNS78\n"
				@.timeout(20000)
				csUtilities.getTestedEntityProperties propertyList, entityList, (properties) =>
					@propertyList = properties
					done()
			it "should return 5 rows including a trailing newline", ->
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
		describe "when 1000 valid compounds sent with valid properties", ->
			before (done) ->
				propertyList = ["HEAVY_ATOM_COUNT"]
				testBatches = for i in [1..1000]
					num = "000000000"+i
					num = num.substr(num.length-9)
					"DNS"+num+"::1"
				entityList = testBatches.join('\n')
				@.timeout(2000000) # way over estimate, but matches timeout parm sent to service
				console.log new Date()
				csUtilities.getTestedEntityProperties propertyList, entityList, (properties) =>
					@propertyList = properties
					console.log @propertyList
					console.log new Date()
					done()
			it "should return a defined answer", ->
				assert.notEqual "undefined", typeof @propertyList
			it "should return a non-null answer", ->
				assert.notEqual null, @propertyList
			it "should return 1000 rows including a trailing newline", ->
				assert.equal @propertyList.split('\n').length, 1002
			it "should have 2 columns", ->
				res = @propertyList.split('\n')
				assert.equal res[0].split(',').length, 2
			it "should have a header row", ->
				res = @propertyList.split('\n')
				assert.equal res[0], "id,HEAVY_ATOM_COUNT"
			it "should have a number in the first result row", ->
				res = @propertyList.split('\n')
				assert.equal isNaN(parseFloat(res[1].split(',')[1])),false
		describe "when valid compounds sent with invalid property", ->
			propertyList = ["fred", "fred2"]
			entityList = "DNS76\nDNS2\nDNS78\n"
			before (done) ->
				@.timeout(20000)
				csUtilities.getTestedEntityProperties propertyList, entityList, (properties) =>
					@propertyList = properties
					done()
			it "should return null \n", ->
				assert.equal @propertyList, null
		describe "when invalid compounds sent with valid properties", ->
			propertyList = ["HEAVY_ATOM_COUNT", "MONOISOTOPIC_MASS"]
			entityList = "FRD99\nFRD98\nFRD96\n"
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

	describe "DNS get preferred batchids via getExternalReferenceCode", ->
		describe "when valid, alias, and invalid batches sent", ->
			requestData =
				requests: [
					{requestName: "DNS000000001::1"} #normal
					{requestName: "DNS000673874::1"} #alias
					{requestName: "DNS000000001::000"} #none
				]
			before (done) ->
				@.timeout(20000)
				csUtilities.getExternalReferenceCode 'DNS Batch ID', requestData.requests, (response) =>
					@response = response
					done()
			it "should return 3 results", ->
				assert.equal @response.length, 3
			it "should have the batch if not an alias", ->
				assert.equal @response[0].requestName, @response[0].preferredName
			it "should have the batch an alias", ->
				assert.equal @response[1].preferredName, "DNS000001234::7"
			it "should not return an alias if the batch is not valid", ->
				assert.equal @response[2].preferredName, ""
		describe "when 1000 batches sent", ->
			requests = for i in [1..1000]
					num = "000000000"+i
					num = num.substr(num.length-9)
					requestName: "DNS"+num+"::1"
			before (done) ->
				@.timeout(20000)
				csUtilities.getExternalReferenceCode 'DNS Batch ID', requests, (response) =>
					@response = response
					done()
			it "should return 1000 results", ->
				assert.equal @response.length, 1000
			it "should have the batch if not an alias", ->
				assert.equal @response[999].requestName, @response[999].preferredName


	describe "DNS get preferred compound ids via getExternalReferenceCode", ->
		describe "when valid, alias, and invalid compounds sent", ->
			requestData =
				requests: [
					{requestName: "DNS000000001"} #normal
					{requestName: "DNS000673874"} #alias
					{requestName: "DNS000000000"} #none
				]
			before (done) ->
				@.timeout(20000)
				csUtilities.getExternalReferenceCode 'DNS Compound ID', requestData.requests, (response) =>
					@response = response
					done()
			it "should return 3 results", ->
				assert.equal @response.length, 3
			it "should have the compound if not an alias", ->
				assert.equal @response[0].requestName, @response[0].preferredName
			it "should have the compound alias", ->
				assert.equal @response[1].preferredName, "DNS000001234"
			it "should not return an alias if the batch is not valid", ->
				assert.equal @response[2].preferredName, ""
		describe "when 1000 compounds sent", ->
			requests = for i in [1..1000]
				num = "000000000"+i
				requestName: "DNS"+num.substr(num.length-9)
			before (done) ->
				@.timeout(20000)
				csUtilities.getExternalReferenceCode 'DNS Compound ID', requests, (response) =>
					@response = response
					done()
			it "should return 1000 results", ->
				assert.equal @response.length, 1000
			it "should have the compound if not an alias", ->
				# aka DNS000001000 pref'd id is DNS000001000
				assert.equal @response[999].requestName, @response[999].preferredName

		describe "DNS get preferred batchids via getExternalBestLabel", ->
		describe "when valid, alias, and invalid batches sent", ->
			requestData =
				requests: [
					{requestName: "DNS000000001::1"} #normal
					{requestName: "DNS000673874::1"} #alias
					{requestName: "DNS000000001::000"} #none
				]
			before (done) ->
				@.timeout(20000)
				csUtilities.getExternalBestLabel 'DNS Batch ID', requestData.requests, (response) =>
					@response = response
					done()
			it "should return 3 results", ->
				assert.equal @response.length, 3
			it "should have the batch if not an alias", ->
				assert.equal @response[0].requestName, @response[0].preferredName
			it "should have the batch an alias", ->
				assert.equal @response[1].preferredName, "DNS000001234::7"
			it "should not return an alias if the batch is not valid", ->
				assert.equal @response[2].preferredName, ""
		describe "when 1000 batches sent", ->
			requests = for i in [1..1000]
				num = "000000000"+i
				num = num.substr(num.length-9)
				requestName: "DNS"+num+"::1"
			before (done) ->
				@.timeout(20000)
				csUtilities.getExternalBestLabel 'DNS Batch ID', requests, (response) =>
					@response = response
					done()
			it "should return 1000 results", ->
				assert.equal @response.length, 1000
			it "should have the batch if not an alias", ->
				assert.equal @response[999].requestName, @response[999].preferredName


	describe "DNS get preferred compound ids via getExternalBestLabel", ->
		describe "when valid, alias, and invalid compounds sent", ->
			requestData =
				requests: [
					{requestName: "DNS000000001"} #normal
					{requestName: "DNS000673874"} #alias
					{requestName: "DNS000000000"} #none
				]
			before (done) ->
				@.timeout(20000)
				csUtilities.getExternalBestLabel 'DNS Compound ID', requestData.requests, (response) =>
					@response = response
					done()
			it "should return 3 results", ->
				assert.equal @response.length, 3
			it "should have the compound if not an alias", ->
				assert.equal @response[0].requestName, @response[0].preferredName
			it "should have the compound alias", ->
				assert.equal @response[1].preferredName, "DNS000001234"
			it "should not return an alias if the batch is not valid", ->
				assert.equal @response[2].preferredName, ""
		describe "when 1000 compounds sent", ->
			requests = for i in [1..1000]
				num = "000000000"+i
				requestName: "DNS"+num.substr(num.length-9)
			before (done) ->
				@.timeout(20000)
				csUtilities.getExternalBestLabel 'DNS Compound ID', requests, (response) =>
					@response = response
					done()
			it "should return 1000 results", ->
				assert.equal @response.length, 1000
			it "should have the compound if not an alias", ->
# aka DNS000001000 pref'd id is DNS000001000
				assert.equal @response[999].requestName, @response[999].preferredName