assert = require 'assert'
request = require 'request'
_ = require 'underscore'
protocolServiceTestJSON = require '../testFixtures/ProtocolServiceTestJSON.js'
fs = require 'fs'
config = require '../../../../conf/compiled/conf.js'

parseResponse = (jsonStr) ->
	try
		return JSON.parse jsonStr
	catch error
		console.log "response unparsable: " + error
		return null


describe "Protocol Service testing", ->
	describe.only "Protocol CRUD testing", ->
		describe "when fetching Protocol stub by codename", ->
			before (done) ->
				request "http://localhost:"+config.all.server.nodeapi.port+"/api/protocols/codeName/PROT-00000001", (error, response, body) =>
					@responseJSON = body
					@response = response
					done()
			it "should return a protocol", ->
				responseJSON = parseResponse(@response.body)
				assert.equal responseJSON.codeName, "PROT-00000001"

		describe "when fetching full Protocol by id", ->
			before (done) ->
				request "http://localhost:"+config.all.server.nodeapi.port+"/api/protocols/723631", (error, response, body) =>
					@responseJSON = body
					@response = response
					done()
			it "should return a protocol", ->
				responseJSON = parseResponse(@response.body)
				assert.equal responseJSON.codeName == "PROT-00000001" or responseJSON.codeName == "PROT-00000014", true
		#should equal PROT-00000001 in stubsMode and PROT-00000014 in non-stubsMode

		describe "when saving a new protocol", ->
			before (done) ->
				@.timeout(20000)
				@testFile1Path = config.all.server.datafiles.relative_path + "/TestFile.mol"
				@testFile2Path = config.all.server.datafiles.relative_path + "/Test.csv"
				fs.writeFileSync @testFile1Path, "key,value\nflavor,sweet"
				fs.writeFileSync @testFile2Path, "key,value\nmolecule,CCC"
				request.post
					url: "http://localhost:"+config.all.server.nodeapi.port+"/api/protocols"
					json: true
					body: protocolServiceTestJSON.protocolToSave
				, (error, response, body) =>
					@serverError = error
					@responseJSON = body
					@codeName = @responseJSON.codeName
					@id = @responseJSON.id
					done()
			after ->
				fs.unlink @testFile1Path #in case it fails, don't leave a mess
				fs.unlink @testFile2Path
			it "should return a protocol", ->
				assert.equal @responseJSON.codeName == null, false
			it "should return the first fileValue moved to the correct location", ->
				correctVal = "protocols/"+@codeName+"/TestFile.mol"
				fileVals = @responseJSON.lsStates[0].lsValues.filter (value) ->
					value.fileValue? and value.fileValue == correctVal
				assert.equal fileVals.length>0, true
			it "should return the first fileValue with the comment filled with the file name", ->
				fileVals = @responseJSON.lsStates[0].lsValues.filter (value) ->
					value.fileValue? and value.comments == "TestFile.mol"
				assert.equal fileVals.length>0, true
			it "should return the second fileValue moved to the correct location", ->
				correctVal = "protocols/"+@codeName+"/Test.csv"
				fileVals = @responseJSON.lsStates[0].lsValues.filter (value) ->
					value.fileValue? and value.fileValue == correctVal
				assert.equal fileVals.length>0, true
			it "should return the second fileValue with the comment filled with the file name", ->
				fileVals = @responseJSON.lsStates[0].lsValues.filter (value) ->
					value.fileValue? and value.comments == "Test.csv"
				assert.equal fileVals.length>0, true
			it "should move the first file to the correct location", ->
				correctVal = "/protocols/"+@codeName+"/TestFile.mol"
				fs.unlink config.all.server.datafiles.relative_path + correctVal, (err) =>
					assert.equal err, null #it should be there to unlink, and we've cleaned up
			it "should move the second file to the correct location", ->
				correctVal = "/protocols/"+@codeName+"/Test.csv"
				fs.unlink config.all.server.datafiles.relative_path + correctVal, (err) =>
					assert.equal err, null #it should be there to unlink, and we've cleaned up

			describe "when updating a protocol", -> #this is put under saving a protocol so that the protocol that was just saved can be updated
				before (done) ->
					@.timeout(20000)
					@testFile1Path = config.all.server.datafiles.relative_path + "/TestFile.mol"
					@testFile2Path = config.all.server.datafiles.relative_path + "/Test.csv"
					fs.writeFileSync @testFile1Path, "key,value\nflavor,sweet"
					fs.writeFileSync @testFile2Path, "key,value\nmolecule,CCC"
					fileVals = @responseJSON.lsStates[0].lsValues.filter (value) ->
						value.fileValue?
					for val in fileVals
						val.fileValue = val.comments
						val.comments = null
						val.id = null
						val.version = null
					request.put
						url: "http://localhost:"+config.all.server.nodeapi.port+"/api/protocols/"+@responseJSON.id
						json: true
						body: @responseJSON
					, (error, response, body) =>
						@serverError = error
						@responseJSON = body
						done()

				after ->
					fs.unlink @testFile1Path #in case it fails, don't leave a mess
					fs.unlink @testFile2Path
				it "should return a protocol", ->
					assert.equal @responseJSON.codeName == null, false
				it "should return the first fileValue moved to the correct location", ->
					correctVal = "protocols/"+@codeName+"/TestFile.mol"
					fileVals = @responseJSON.lsStates[0].lsValues.filter (value) ->
						value.fileValue? and value.fileValue == correctVal
					assert.equal fileVals.length>0, true
				it "should return the first fileValue with the comment filled with the file name", ->
					fileVals = @responseJSON.lsStates[0].lsValues.filter (value) ->
						value.fileValue? and value.comments == "TestFile.mol"
					assert.equal fileVals.length>0, true
				it "should return the second fileValue moved to the correct location", ->
					correctVal = "protocols/"+@codeName+"/Test.csv"
					fileVals = @responseJSON.lsStates[0].lsValues.filter (value) ->
						value.fileValue? and value.fileValue == correctVal
					assert.equal fileVals.length>0, true
				it "should return the second fileValue with the comment filled with the file name", ->
					fileVals = @responseJSON.lsStates[0].lsValues.filter (value) ->
						value.fileValue? and value.comments == "Test.csv"
					assert.equal fileVals.length>0, true
				it "should move the first file to the correct location", ->
					correctVal = "/protocols/"+@codeName+"/TestFile.mol"
					fs.unlink config.all.server.datafiles.relative_path + correctVal, (err) =>
						assert.equal err, null #it should be there to unlink, and we've cleaned up
				it "should move the second file to the correct location", ->
					correctVal = "/protocols/"+@codeName+"/Test.csv"
					fs.unlink config.all.server.datafiles.relative_path + correctVal, (err) =>
						assert.equal err, null #it should be there to unlink, and we've cleaned up
			describe "when deleting a protocol", ->
				before (done) ->
					request.del
						url: "http://localhost:"+config.all.server.nodeapi.port+"/api/protocols/browser/"+@id
						json: true
					, (error, response, body) =>
						@serverError = error
						@response = response
						@responseJSON = body
						done()
				it "should delete the protocol", ->
					console.log @responseJSON
					console.log @response
					assert.equal @responseJSON.codeValue == 'deleted' or @responseJSON.ignored == true, true
	describe "Protocol related services", ->
		describe 'when protocol labels service called', ->
			before (done) ->
				request "http://localhost:"+config.all.server.nodeapi.port+"/api/protocolLabels", (error, response, body) =>
#				request "http://localhost:3000/api/protocolLabels", (error, response, body) =>
					@responseJSON = body
					@response = response
					done()
			it 'should return an array of lsLabels', ->
				responseJSON = parseResponse(@response.body)
				assert.equal responseJSON.length > 0, true
			it 'labels should include a protocol code', ->
				responseJSON = parseResponse(@response.body)
				assert.equal responseJSON[0].protocol.codeName.indexOf("PROT-") > -1, true

		describe "Protocol status code", ->
			describe 'when protocol code service called', ->
				before (done) ->
					request "http://localhost:"+config.all.server.nodeapi.port+"/api/protocolCodes", (error, response, body) =>
						@responseJSON = body
						@response = response
						done()
				it 'should return an array of status codes', ->
					responseJSON = parseResponse(@response.body)
					assert.equal responseJSON.length > 0, true
				it 'should a hash with code defined', ->
					responseJSON = parseResponse(@response.body)
					assert.equal responseJSON[0].code != undefined, true
				it 'should a hash with name defined', ->
					responseJSON = parseResponse(@response.body)
					assert.equal responseJSON[0].name != undefined, true
				it 'should a hash with ignore defined', ->
					responseJSON = parseResponse(@response.body)
					assert.equal responseJSON[0].ignored != undefined, true
				it 'should return some names without PK', ->
					responseJSON = parseResponse(@response.body)
					assert.equal responseJSON[responseJSON.length-1].name.indexOf("PK")==-1, true
				it 'should not return protocols where protocol itself is set to ignore', ->
					responseJSON = parseResponse(@response.body)
					matches = _.filter responseJSON, (label) ->
						label.name == "Ignore this protocol"
					assert.equal (matches.length)== 0, true

		describe 'when protocol code list service called with label filtering option', ->
			describe "With matching case", ->
				before (done) ->
					request "http://localhost:"+config.all.server.nodeapi.port+"/api/protocolCodes/?protocolName=PK", (error, response, body) =>
						@responseJSON = body
						@response = response
						done()
					it 'should only return names with PK', ->
					responseJSON = parseResponse(@response.body)
					assert.equal responseJSON[responseJSON.length-1].name.indexOf("PK") > -1, true

			describe "With non-matching case", ->
				before (done) ->
					request "http://localhost:"+config.all.server.nodeapi.port+"/api/protocolCodes/?protocolName=pk", (error, response, body) =>
						@responseJSON = body
						@response = response
						done()
					it 'should only return names with PK', ->
					responseJSON = parseResponse(@response.body)
					assert.equal responseJSON[responseJSON.length-1].name.indexOf("PK") > -1, true

		describe 'when protocol code list service called with protocol lsKind filtering option', ->
			describe "With non-matching case", ->
				before (done) ->
					request "http://localhost:"+config.all.server.nodeapi.port+"/api/protocolCodes/?protocolKind=KD", (error, response, body) =>
						@responseJSON = body
						@response = response
						done()
				it 'should only return names with KD', ->
					responseJSON = parseResponse(@response.body)
					assert.equal responseJSON[responseJSON.length-1].name.indexOf("KD") > -1, true

		describe 'when protocol kind list service called', ->
			describe "With non-matching case", ->
				before (done) ->
					request "http://localhost:"+config.all.server.nodeapi.port+"/api/protocolKindCodes", (error, response, body) =>
						@responseJSON = body
						@response = response
						done()
				it 'should return an array of protocolKinds', ->
					responseJSON = parseResponse(@response.body)
					assert.equal responseJSON.length > 0, true
				it 'should array of protocolKinds', ->
					responseJSON = parseResponse(@response.body)
					assert.equal responseJSON[0].code != undefined, true
					assert.equal responseJSON[0].name != undefined, true
					assert.equal responseJSON[0].ignored != undefined, true
