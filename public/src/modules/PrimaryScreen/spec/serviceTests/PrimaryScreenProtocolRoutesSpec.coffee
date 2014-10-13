assert = require 'assert'
request = require 'request'

parseResponse = (jsonStr) ->
	console.log jsonStr
	try
		return JSON.parse jsonStr
	catch error
		console.log "response unparsable: " + error
		return null



describe "Primary Screen Protocol Routes testing", ->
	describe "Using customer code tables", ->
		before (done) ->
			request "http://imapp01-d:8080/DNS/codes/v1/Codes/SB_Variant_Construct", (error, response, body) =>
				@responseJSON = parseResponse(body)
				done()
		it "should return an array of dns codes", ->
			assert.equal @responseJSON instanceof Array, true