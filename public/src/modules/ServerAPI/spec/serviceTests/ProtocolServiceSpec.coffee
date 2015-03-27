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
	describe "Protocol CRUD testing", ->
		describe "when fetching Protocol stub by codename", ->
			before (done) ->
				request "http://localhost:"+config.all.server.nodeapi.port+"/api/protocols/codeName/PROT-00000124", (error, response, body) =>
					@responseJSON = body
					@response = response
					done()
			it "should return a protocol", ->
				responseJSON = parseResponse(@response.body)
				assert.equal responseJSON.codeName, "PROT-00000001"

		describe "when fetching full Protocol by id", ->
			before (done) ->
				request "http://localhost:"+config.all.server.nodeapi.port+"/api/protocols/1", (error, response, body) =>
					@responseJSON = body
					@response = response
					done()
			it "should return a protocol", ->
				responseJSON = parseResponse(@response.body)
				assert.equal responseJSON.codeName, "PROT-00000001"

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
					done()
			after ->
				fs.unlink @testFile1Path #in case it fails, don't leave a mess
				fs.unlink @testFile2Path
			describe "basic saving", ->
				it "should return a protocol", ->
					assert.equal @responseJSON.codeName == null, false
				it "should have a trans at the top level", ->
					assert.equal isNaN(parseInt(@responseJSON.lsTransaction)), false
				it "should have a trans in the labels", ->
					assert.equal isNaN(parseInt(@responseJSON.lsLabels[0].lsTransaction)), false
				it "should have a trans in the states", ->
					assert.equal isNaN(parseInt(@responseJSON.lsStates[0].lsTransaction)), false
				it "should have a trans in the values", ->
					assert.equal isNaN(parseInt(@responseJSON.lsStates[0].lsValues[0].lsTransaction)), false
			describe "file handling", ->
				it "should return the first fileValue moved to the correct location", ->
					assert.equal @responseJSON.lsStates[0].lsValues[1].fileValue, "protocols/PROT-00000001/TestFile.mol"
				it "should return the first fileValue with the comment filled with the file name", ->
					assert.equal @responseJSON.lsStates[0].lsValues[1].comments, "TestFile.mol"
				it "should return the second fileValue moved to the correct location", ->
					assert.equal @responseJSON.lsStates[0].lsValues[2].fileValue, "protocols/PROT-00000001/Test.csv"
				it "should return the second fileValue with the comment filled with the file name", ->
					assert.equal @responseJSON.lsStates[0].lsValues[2].comments, "Test.csv"
				it "should move the first file to the correct location", ->
					fs.unlink config.all.server.datafiles.relative_path + "/protocols/PROT-00000001/TestFile.mol", (err) =>
						assert.equal err, null #it should be there to unlink, and we've cleaned up
				it "should move the second file to the correct location", ->
					fs.unlink config.all.server.datafiles.relative_path + "/protocols/PROT-00000001/Test.csv", (err) =>
						assert.equal err, null #it should be there to unlink, and we've cleaned up

		describe "when updating a protocol", ->
			before (done) ->
				@.timeout(20000)
				@testFile1Path = config.all.server.datafiles.relative_path + "/TestFile.mol"
				@testFile2Path = config.all.server.datafiles.relative_path + "/Test.csv"
				fs.writeFileSync @testFile1Path, "key,value\nflavor,sweet"
				fs.writeFileSync @testFile2Path, "key,value\nmolecule,CCC"
				updatedData = protocolServiceTestJSON.fullSavedProtocol
				updatedData.lsStates[0].lsValues[1].id = null
				updatedData.lsStates[0].lsValues[2].id = null
				@originalTransatcionId = updatedData.lsTransaction
				request.put
					url: "http://localhost:"+config.all.server.nodeapi.port+"/api/protocols/1234"
					json: true
					body: updatedData
				, (error, response, body) =>
					@serverError = error
					@responseJSON = body
					done()

			after ->
				fs.unlink @testFile1Path #in case it fails, don't leave a mess
				fs.unlink @testFile2Path
			describe "basic saving", ->
				it "should return a protocol", ->
					assert.equal @responseJSON.codeName == null, false
				it "should have a new trans at the top level", ->
					assert.equal @responseJSON.lsTransaction==@originalTransatcionId, false
				it "should have a trans in the labels", ->
					assert.equal isNaN(parseInt(@responseJSON.lsLabels[0].lsTransaction)), false
				it "should have a trans in the states", ->
					assert.equal isNaN(parseInt(@responseJSON.lsStates[0].lsTransaction)), false
				it "should have a trans in the values", ->
					assert.equal isNaN(parseInt(@responseJSON.lsStates[0].lsValues[0].lsTransaction)), false
			describe "file handling", ->
				it "should return the first fileValue moved to the correct location", ->
					assert.equal @responseJSON.lsStates[0].lsValues[1].fileValue, "protocols/PROT-00000001/TestFile.mol"
				it "should return the first fileValue with the comment filled with the file name", ->
					assert.equal @responseJSON.lsStates[0].lsValues[1].comments, "TestFile.mol"
				it "should return the second fileValue moved to the correct location", ->
					assert.equal @responseJSON.lsStates[0].lsValues[2].fileValue, "protocols/PROT-00000001/Test.csv"
				it "should return the second fileValue with the comment filled with the file name", ->
					assert.equal @responseJSON.lsStates[0].lsValues[2].comments, "Test.csv"
				it "should move the first file to the correct location", ->
					fs.unlink config.all.server.datafiles.relative_path + "/protocols/PROT-00000001/TestFile.mol", (err) =>
						assert.equal err, null #it should be there to unlink, and we've cleaned up
				it "should move the second file to the correct location", ->
					fs.unlink config.all.server.datafiles.relative_path + "/protocols/PROT-00000001/Test.csv", (err) =>
						assert.equal err, null #it should be there to unlink, and we've cleaned up

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
