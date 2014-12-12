assert = require 'assert'
request = require 'request'

config = require '../../../../conf/compiled/conf.js'

parseResponse = (jsonStr) ->
	try
		return JSON.parse jsonStr
	catch error
		console.log "response unparsable: " + error
		return null



describe "Primary Screen Protocol Routes testing", ->
	describe "Using customer code tables", ->
		before (done) ->
			request "http://localhost:"+config.all.server.nodeapi.port+"/api/customerMolecularTargetCodeTable", (error, response, body) =>
				console.log "after request sent"
				@responseJSON = parseResponse(body)
				done()
		it "should return an array of dns codes", ->
			assert.equal @responseJSON instanceof Array, true
		it 'should have elements that be a hash with code defined', ->
			assert.equal @responseJSON[0].code?, true
		it 'should have elements that be a hash with name defined', ->
			assert.equal @responseJSON[0].name?, true
