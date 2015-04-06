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

parseResponse = (jsonStr) ->
	try
		return JSON.parse jsonStr
	catch error
		console.log "response unparsable: " + error
		return null

config = require '../../../../conf/compiled/conf.js'
describe.only "Preferred Entity code service tests", ->
	describe "available entity type list", ->
		describe "when requested as fully detailed list", ->
			before (done) ->
				request "http://localhost:"+config.all.server.nodeapi.port+"/api/entitymeta/configuredEntityTypes", (error, response, body) =>
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
				request "http://localhost:"+config.all.server.nodeapi.port+"/api/entitymeta/configuredEntityTypes?asCodes=true", (error, response, body) =>
					@responseJSON = parseResponse(body)
					done()
			it "should return an array of entity types", ->
				assert.equal @responseJSON.length > 0, true
			it "should return entity type descriptions with required attributes", ->
				assert.equal @responseJSON[0].code?, true
				assert.equal @responseJSON[0].name?, true
				assert.equal @responseJSON[0].ignored?, true

	describe "get preferred entity codeName for supplied name or codeName", ->
		describe "when valid compounds sent with valid type info ONLY PASSES IN STUBS MODE", ->
			body =
				type: "parent"
				kind: "protein"
				codeOrigin: "ACAS LSThing"
				entityIdStringLines: "PROT1\nPROT2\nPROT3\n"
			before (done) ->
				@.timeout(20000)
				request.post
					url: "http://localhost:"+config.all.server.nodeapi.port+"/api/entitymeta/preferredCodes"
					json: true
					body: body
				, (error, response, body) =>
					@serverError = error
					@responseJSON = body
					console.log @responseJSON
					@serverResponse = response
					done()
			it "should return a success status code if in stubsMode, otherwise, this will fail", ->
				assert.equal @serverResponse.statusCode,200
			it "should return 5 rows including a trailing \n", ->
				assert.equal @responseJSON.resultCSV.split('\n').length, 5
			it "should have 2 columns", ->
				res = @responseJSON.resultCSV.split('\n')
				assert.equal res[0].split(',').length, 2
			it "should have a header row", ->
				res = @responseJSON.resultCSV.split('\n')
				assert.equal res[0], "Requested Name,Preferred Code"
			it "should have the query first result column", ->
				res = @responseJSON.resultCSV.split('\n')
				assert.equal res[1].split(',')[0], "PROT1"

		describe "when valid compounds sent with invalid type info", ->
			body =
				type: "ERROR"
				kind: "protein"
				codeOrigin: "ACAS LSThing"
				entityIdStringLines: "PROT1\nPROT2\nPROT3\n"
			before (done) ->
				@.timeout(20000)
				request.post
					url: "http://localhost:"+config.all.server.nodeapi.port+"/api/entitymeta/preferredCodes"
					json: true
					body: body
				, (error, response, body) =>
					@serverError = error
					@responseJSON = body
					console.log @responseJSON
					@serverResponse = response
					done()
			it "should return a failure status code", ->
				assert.equal @serverResponse.statusCode,500

		describe "when invalid compounds sent with valid type info", ->
			body =
				type: "parent"
				kind: "protein"
				codeOrigin: "ACAS LSThing"
				entityIdStringLines: "PROT1\nERROR\nPROT3\n"
			before (done) ->
				@.timeout(20000)
				request.post
					url: "http://localhost:"+config.all.server.nodeapi.port+"/api/entitymeta/preferredCodes"
					json: true
					body: body
				, (error, response, body) =>
					@serverError = error
					@responseJSON = body
					console.log @responseJSON
					@serverResponse = response
					done()
			it "should return a success status code if in stubsMode, otherwise, this will fail", ->
				assert.equal @serverResponse.statusCode,200
			it "should return 5 rows including a trailing \n", ->
				assert.equal @responseJSON.resultCSV.split('\n').length, 5
			it "should have 2 columns", ->
				res = @responseJSON.resultCSV.split('\n')
				assert.equal res[0].split(',').length, 2
			it "should have a header row", ->
				res = @responseJSON.resultCSV.split('\n')
				assert.equal res[0], "Requested Name,Preferred Code"
			it "should have the query first result column", ->
				res = @responseJSON.resultCSV.split('\n')
				assert.equal res[2].split(',')[0], "ERROR"
			it "should have blank second result column", ->
				res = @responseJSON.resultCSV.split('\n')
				assert.equal res[2].split(',')[1], ""
