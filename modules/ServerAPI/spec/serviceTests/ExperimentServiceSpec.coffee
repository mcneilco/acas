assert = require 'assert'
request = require 'request'
_ = require 'underscore'
acasHome = '../../../..'
inventoryServiceTestJSON = require "#{acasHome}/public/javascripts/spec/ServerAPI/testFixtures/ExperimentServiceTestJSON.js"

fs = require 'fs'
config = require "#{acasHome}/conf/compiled/conf.js"


parseResponse = (jsonStr) ->
	try
		return JSON.parse jsonStr
	catch error
		console.log "response unparsable: " + error
		return null


describe "Experiment Service testing", ->
	describe "Experiment CRUD testing", ->
		describe "when fetching Experiment stub by codename", ->
			before (done) ->
				request "http://localhost:"+config.all.server.nodeapi.port+"/api/experiments/codeName/EXPT-00000018", (error, response, body) =>
					@responseJSON = body
					@response = response
					done()
			it "should return a experiment", ->
				responseJSON = parseResponse(@response.body)
				assert.equal responseJSON.codeName == "EXPT-00000001" or responseJSON.codeName == "EXPT-00000018", true

		describe "when fetching Experiment stub by name", ->
			before (done) ->
				request "http://localhost:"+config.all.server.nodeapi.port+"/api/experiments/experimentName/Test Experiment 1", (error, response, body) =>
					@responseJSON = body
					@response = response
					done()
			it "should return a experiment", ->
				responseJSON = parseResponse(@responseJSON)[0]
				assert.equal responseJSON.codeName == "EXPT-00000001" or responseJSON.codeName == "EXPT-00000018", true

		#		describe.only "when fetching Experiment stub by protocol code", ->
		#			before (done) ->
		#				request "http://localhost:"+config.all.server.nodeapi.port+"/api/experiments/protocolCodename/PROT-00000007", (error, response, body) =>
		#					@responseJSON = body
		#					@response = response
		#					done()
		#			it "should return a experiment", ->
		#				console.log @responseJSON
		#				console.log @response
		#				responseJSON = parseResponse(@response.body)
		#				assert.equal responseJSON.codeName == "EXPT-00000001" or responseJSON.codeName == "EXPT-00000018", true

		describe "when fetching full Experiment by id", ->
			before (done) ->
				request "http://localhost:"+config.all.server.nodeapi.port+"/api/experiments/2183", (error, response, body) =>
					@responseJSON = body
					@response = response
					done()
			it "should return a experiment", ->
				responseJSON = parseResponse(@response.body)
				assert.equal responseJSON.codeName == "EXPT-00000001" or responseJSON.codeName == "EXPT-00000018", true

		describe "when saving a new experiment", ->
			before (done) ->
				@.timeout(20000)
				@testFile1Path = config.all.server.datafiles.relative_path + "/TestFile.mol"
				@testFile2Path = config.all.server.datafiles.relative_path + "/Test.csv"
				fs.writeFileSync @testFile1Path, "key,value\nflavor,sweet"
				fs.writeFileSync @testFile2Path, "key,value\nmolecule,CCC"
				request.post
					url: "http://localhost:"+config.all.server.nodeapi.port+"/api/experiments"
					json: true
					body: experimentServiceTestJSON.experimentToSave
				, (error, response, body) =>
					@serverError = error
					@responseJSON = body
					@codeName = @responseJSON.codeName
					@id = @responseJSON.id
					done()
			after ->
				fs.unlink @testFile1Path #in case it fails, don't leave a mess
				fs.unlink @testFile2Path
			describe "basic saving", ->
				it "should return a experiment", ->
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
					correctVal = "experiments/"+@codeName+"/TestFile.mol"
					fileVals = @responseJSON.lsStates[0].lsValues.filter (value) ->
						value.fileValue? and value.fileValue == correctVal
					assert.equal fileVals.length>0, true
				it "should return the first fileValue with the comment filled with the file name", ->
					fileVals = @responseJSON.lsStates[0].lsValues.filter (value) ->
						value.fileValue? and value.comments == "TestFile.mol"
					assert.equal fileVals.length>0, true
				it "should return the second fileValue moved to the correct location", ->
					correctVal = "experiments/"+@codeName+"/Test.csv"
					fileVals = @responseJSON.lsStates[0].lsValues.filter (value) ->
						value.fileValue? and value.fileValue == correctVal
					assert.equal fileVals.length>0, true
				it "should return the second fileValue with the comment filled with the file name", ->
					fileVals = @responseJSON.lsStates[0].lsValues.filter (value) ->
						value.fileValue? and value.comments == "Test.csv"
					assert.equal fileVals.length>0, true
				it "should move the first file to the correct location", ->
					correctVal = "/experiments/"+@codeName+"/TestFile.mol"
					fs.unlink config.all.server.datafiles.relative_path + correctVal, (err) =>
						assert.equal err, null #it should be there to unlink, and we've cleaned up
				it "should move the second file to the correct location", ->
					correctVal = "/experiments/"+@codeName+"/Test.csv"
					fs.unlink config.all.server.datafiles.relative_path + correctVal, (err) =>
						assert.equal err, null #it should be there to unlink, and we've cleaned up

			describe "when updating a experiment", -> #this is put under saving an experiment so that the experiment that was just saved can be updated
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
					@responseJSON.lsTransaction = 1
					@originalTransatcionId = @responseJSON.lsTransaction
					request.put
						url: "http://localhost:"+config.all.server.nodeapi.port+"/api/experiments/"+@responseJSON.id
						json: true
						body: @responseJSON
					, (error, response, body) =>
						@serverError = error
						@responseJSON = body
						done()
				after ->
					fs.unlink @testFile1Path #in case it fails, don't leave a mess
					fs.unlink @testFile2Path
				describe "basic saving", ->
					it "should return a experiment", ->
						assert.equal @responseJSON.codeName == null, false
					it "should have a new trans at the top level", ->
						console.log @responseJSON
						assert.equal @responseJSON.lsTransaction==@originalTransatcionId, false
					it "should have a trans in the labels", ->
						assert.equal isNaN(parseInt(@responseJSON.lsLabels[0].lsTransaction)), false
					it "should have a trans in the states", ->
						assert.equal isNaN(parseInt(@responseJSON.lsStates[0].lsTransaction)), false
					it "should have a trans in the values", ->
						assert.equal isNaN(parseInt(@responseJSON.lsStates[0].lsValues[0].lsTransaction)), false
				describe "file handling", ->
					it "should return the first fileValue moved to the correct location", ->
						correctVal = "experiments/"+@codeName+"/TestFile.mol"
						fileVals = @responseJSON.lsStates[0].lsValues.filter (value) ->
							value.fileValue? and value.fileValue == correctVal
						assert.equal fileVals.length>0, true
					it "should return the first fileValue with the comment filled with the file name", ->
						fileVals = @responseJSON.lsStates[0].lsValues.filter (value) ->
							value.fileValue? and value.comments == "TestFile.mol"
						assert.equal fileVals.length>0, true
					it "should return the second fileValue moved to the correct location", ->
						correctVal = "experiments/"+@codeName+"/Test.csv"
						fileVals = @responseJSON.lsStates[0].lsValues.filter (value) ->
							value.fileValue? and value.fileValue == correctVal
						assert.equal fileVals.length>0, true
					it "should return the second fileValue with the comment filled with the file name", ->
						fileVals = @responseJSON.lsStates[0].lsValues.filter (value) ->
							value.fileValue? and value.comments == "Test.csv"
						assert.equal fileVals.length>0, true
					it "should move the first file to the correct location", ->
						correctVal = "/experiments/"+@codeName+"/TestFile.mol"
						fs.unlink config.all.server.datafiles.relative_path + correctVal, (err) =>
							assert.equal err, null #it should be there to unlink, and we've cleaned up
					it "should move the second file to the correct location", ->
						correctVal = "/experiments/"+@codeName+"/Test.csv"
						fs.unlink config.all.server.datafiles.relative_path + correctVal, (err) =>
							assert.equal err, null #it should be there to unlink, and we've cleaned up

			describe "when deleting a protocol", ->
				before (done) ->
					request.del
						url: "http://localhost:"+config.all.server.nodeapi.port+"/api/experiments/"+@id
						json: true
					, (error, response, body) =>
						@serverError = error
						@response = response
						@responseJSON = body
						done()
				it "should delete the experiment", ->
					responseJSON = parseResponse(@responseJSON)
					assert.equal @responseJSON.codeValue == 'deleted' or @responseJSON.ignored == true, true

	describe "Experiment status code", ->
		describe 'when experiment status code service called', ->
			before (done) ->
				request "http://localhost:"+config.all.server.nodeapi.port+"/api/codetables/experiment/status", (error, response, body) =>
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

	describe "Experiment result viewer url", ->
		describe 'when experiment result viewer url service called', ->
			before (done) ->
				request "http://localhost:"+config.all.server.nodeapi.port+"/api/experiments/resultViewerURL/test", (error, response, body) =>
					@responseJSON = body
					@response = response
					done()
			it 'should return a result viewer url', ->
				responseJSON = parseResponse(@response.body)
				assert.equal responseJSON.resultViewerURL.indexOf("runseurat") > -1, true
