assert = require 'assert'
request = require 'request'
_ = require 'underscore'
labelServiceTestJSON = require '../testFixtures/LabelServiceTestJSON.js'
fs = require 'fs'
config = require '../../../../conf/compiled/conf.js'


parseResponse = (jsonStr) ->
	try
		return JSON.parse jsonStr
	catch error
		console.log "response unparsable: " + error
		return null


describe "Label Service testing", ->
	describe "Get next label sequence", ->
		before (done) ->
			@.timeout(20000)
			request.post
				url: "http://localhost:"+config.all.server.nodeapi.port+"/api/getNextLabelSequence"
				json: true
				body: labelServiceTestJSON.nextLabelSequenceRequest
			, (error, response, body) =>
				@serverError = error
				@responseJSON = body
				done()
		it "should have the latest number for the label sequence", ->
			assert.equal @responseJSON.latestNumber == 1163, true
