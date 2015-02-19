assert = require 'assert'
request = require 'request'
_ = require 'underscore'
codeTablePostTestJSON = require '../testFixtures/codeTablePostTestJSON.js'
codeTablePutTestJSON = require '../testFixtures/codeTablePutTestJSON.js'
fs = require 'fs'
config = require '../../../../conf/compiled/conf.js'


parseResponse = (jsonStr) ->
	try
		return JSON.parse jsonStr
	catch error
		console.log "response unparsable: " + error
		return null


describe.only "CodeTable Service testing", ->
	describe "CodeTable CRUD testing", ->
		describe "when fetching all codeTables", ->
			before (done) ->
				request "http://localhost:"+config.all.server.nodeapi.port+"/api/codetables", (error, response, body) =>
					@responseJSON = body
					@response = response
					done()
			it "should return all codeTables", ->
				responseJSON = parseResponse(@response.body)
				console.log responseJSON
				assert.equal responseJSON[0].code, "fluorescence"
				assert.equal responseJSON[0].name, "Fluorescence"
				assert.equal responseJSON[1].code, "biochemical"
				assert.equal responseJSON[2].code, "ko"

		describe "when fetching a single set of codeTables", ->
			before (done) ->
				request "http://localhost:"+config.all.server.nodeapi.port+"/api/codetables/algorithm well flags/flag observation", (error, response, body) =>
					@responseJSON = body
					@response = response
					done()
			it "should return a single set of codeTables", ->
				responseJSON = parseResponse(@response.body)
				console.log responseJSON
				assert.equal responseJSON[0].code, "outlier"
				assert.equal responseJSON[0].name, "Outlier"
				assert.equal responseJSON[1].code, "high"
				assert.equal responseJSON[1].name, "Value too high"
				assert.equal responseJSON[1].ignored, true

		describe "when saving a new code value", ->
			before (done) ->
				@.timeout(20000)
				request.post
					url: "http://localhost:"+config.all.server.nodeapi.port+"/api/codetables"
					json: true
					body: codeTablePostTestJSON.codeEntry
				, (error, response, body) =>
					@serverError = error
					@responseJSON = body
					@response = response
					done()
			it "should return a code value", ->
				assert.equal @response == null, false
				results = @response.body
				console.log results
				assert.equal results.code, "fluorescence test 2"
				assert.equal results.name, "Fluorescence TEST 2"

		describe "when updating an existing code value", ->
			before (done) ->
				@.timeout(20000)
				request.put
					url: "http://localhost:"+config.all.server.nodeapi.port+"/api/codetables/186"
					json: true
					body: codeTablePutTestJSON.codeEntry
				, (error, response, body) =>
					@serverError = error
					@responseJSON = body
					@response = response
					done()
			it "should return a code value", ->
				assert.equal @response == null, false
				results = @response.body
				console.log results
				assert.equal results.code, "fluorescence test modified code"
				assert.equal results.name, "Fluorescence TEST Modified"
