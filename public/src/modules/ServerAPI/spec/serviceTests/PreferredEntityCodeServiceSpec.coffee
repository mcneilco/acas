# preferredEntityCodeServiceSpec.coffee
#
#
# John McNeil
# john@mcneilco.com
#
#
# Copyright 2015 John McNeil & Co. Inc.
#########################################################################
# Spec for service that takes an array of entity names and
# attempts to find and return a codeName or corpName for each request
# the preferred id, or "" if there are none
#
# Theses entities may be registered as LSThings, or in external system if a
# customerSpecifcFunction is setup to look them up
#
# This is typically used to validate and de-alias batch names when
# registering assay data and associating the data with entities
#
# An auxiliary service returns the entity types the system knows how to validate
#
# It is not a service error if the entity doesn't exist. Rather,
# the individual entry returns no preferred id
#########################################################################assert = require 'assert'
assert = require 'assert'
request = require 'request'
fs = require 'fs'

parseResponse = (jsonStr) ->
	try
		return JSON.parse jsonStr
	catch error
		console.log "response unparsable: " + error
		return null


config = require '../../../../conf/compiled/conf.js'
describe "Preferred Entity code service tests", ->
	@requestData =
		requests: [
			{requestName: "norm_1234:1"} # easter egg prefix in test service that returns same value
			{requestName: "alias_1111:1"} # easter egg prefix in test service that returns alias
			{requestName: "none_2222:1"} # easter egg prefix in test service that returns none
		]
	@expectedResponse =
		error: false
		errorMessages: []
		results: [
			requestName: "norm_1234:1"
			preferredName: "norm_1234:1"
		,
			requestName: "alias_1111:1"
			preferredName: "norm_1111:1A"
		,
			requestName: "none_2222:1"
			preferredName: ""
		]
	describe.only "available entity list", ->
		describe "when requested as fully detailed list", ->
			before (done) ->
				request "http://localhost:"+config.all.server.nodeapi.port+"/api/configuredEntityTypes", (error, response, body) =>
					@responseJSON = parseResponse(body)
					done()
			it "should return an array of entity types", ->
				assert.equal @responseJSON.length > 0, true
			it "should return entity type descriptions with required attributes", ->
				assert.equal @responseJSON[0].type?, true
				assert.equal @responseJSON[0].kind?, true
				assert.equal @responseJSON[0].displayName?, true
				assert.equal @responseJSON[0].codeOrigin?, true
				assert.equal @responseJSON[0].sourceExternal?, true
		describe "when requested as list of codes", ->
			before (done) ->
				request "http://localhost:"+config.all.server.nodeapi.port+"/api/configuredEntityTypes?asCodes=true", (error, response, body) =>
					@responseJSON = parseResponse(body)
					done()
			it "should return an array of entity types", ->
				assert.equal @responseJSON.length > 0, true
			it "should return entity type descriptions with required attributes", ->
				assert.equal @responseJSON[0].code?, true
				assert.equal @responseJSON[0].name?, true
				assert.equal @responseJSON[0].ignored?, true


#	describe "testing Corporate Batch IDs", ->
#		describe "When run with valid input", ->
#			before (done) ->
#				request "http://localhost:"+config.all.server.nodeapi.port+"/entity/edit/codeName/PROT-generic", (error, response, body) =>
#					@responseJSON = body
#					@response = response
#					done()
#			it "should return redirect", ->
#				assert.equal @response.request.uri.href.indexOf('protocol_base')>0, true
