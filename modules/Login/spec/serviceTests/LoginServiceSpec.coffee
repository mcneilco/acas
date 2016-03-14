assert = require 'assert'
request = require 'request'
_ = require 'underscore'
fs = require 'fs'
config = require '../../../../conf/compiled/conf.js'


parseResponse = (jsonStr) ->
	try
		return JSON.parse jsonStr
	catch error
		console.log "response unparsable: " + error
		return null

describe "Login Service Routes testing", ->
	describe 'when get author route called', ->
		before (done) ->
			request "http://localhost:"+config.all.server.nodeapi.port+"/api/authors", (error, response, body) =>
				@responseJSON = body
				@response = response
				done()
		it 'should return an array of authors', ->
			console.log "running test"
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