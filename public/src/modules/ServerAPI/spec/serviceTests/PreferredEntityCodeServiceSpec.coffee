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
		console.log "response: "+ jsonStr
		return null

config = require '../../../../conf/compiled/conf.js'
describe  "Preferred Entity code service tests", ->
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
				request "http://localhost:"+config.all.server.nodeapi.port+"/api/entitymeta/configuredEntityTypes/asCodes", (error, response, body) =>
					@responseJSON = parseResponse(body)
					done()
			it "should return an array of entity types", ->
				assert.equal @responseJSON.length > 0, true
			it "should return entity type descriptions with required attributes", ->
				assert.equal @responseJSON[0].code?, true
				assert.equal @responseJSON[0].name?, true
				assert.equal @responseJSON[0].ignored?, true
		describe "when a specific entity type is requested by displayName", ->
			entityType = encodeURIComponent("Corporate Parent ID")
			before (done) ->
				request "http://"+config.all.client.host+":"+config.all.server.nodeapi.port+"/api/entitymeta/configuredEntityTypes/displayName/"+entityType, (error, response, body) =>
					@responseJSON = parseResponse(body)
					done()
			it "should return an object with all the required attributes", ->
				assert @responseJSON.type?
				assert @responseJSON.kind?
				assert @responseJSON.displayName?
				assert @responseJSON.codeOrigin?
				assert @responseJSON.sourceExternal?

	describe "get preferred entity codeName for supplied name or codeName", ->
		describe "when valid compounds sent with valid type info ONLY PASSES IN STUBS MODE", ->
			body =
				type: "parent"
				kind: "protein"
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

		describe "when valid small molecule batch names are passed in ONLY PASSES IN STUBS MODE", ->
			body =
				type: "compound"
				kind: "batch name"
				entityIdStringLines: "CMPD-0000001-01\nnone_2222:1\nCMPD-0000002-01\n"
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
			it "should return the requested Type", ->
				assert.equal @responseJSON.type, "compound"
			it "should return the requested Kind", ->
				assert.equal @responseJSON.kind, "batch name"
			it "should have the first line query in first result column", ->
				res = @responseJSON.resultCSV.split('\n')
				assert.equal res[1].split(',')[0], "CMPD-0000001-01"
			it "should have the first line result second result column", ->
				res = @responseJSON.resultCSV.split('\n')
				assert.equal res[1].split(',')[1], "CMPD-0000001-01"
			it "should have the second line query in first result column", ->
				res = @responseJSON.resultCSV.split('\n')
				assert.equal res[2].split(',')[0], "none_2222:1"
			it "should have the second line result second result column with no result", ->
				res = @responseJSON.resultCSV.split('\n')
				assert.equal res[2].split(',')[1], ""

		describe "when valid small molecule Parent names are passed in ONLY PASSES IN STUBS MODE", ->
			body =
				type: "compound"
				kind: "parent name"
				entityIdStringLines: "CMPD-0000001\nCMPD-999999999\ncompoundName\n"
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
			it "should return the requested Type", ->
				assert.equal @responseJSON.type, "compound"
			it "should return the requested Kind", ->
				assert.equal @responseJSON.kind, "parent name"
			it "should have the first line query in first result column", ->
				res = @responseJSON.resultCSV.split('\n')
				assert.equal res[1].split(',')[0], "CMPD-0000001"
			it "should have the first line result second result column", ->
				res = @responseJSON.resultCSV.split('\n')
				assert.equal res[1].split(',')[1], "CMPD-0000001"
			it "should have the second line query in first result column", ->
				res = @responseJSON.resultCSV.split('\n')
				assert.equal res[2].split(',')[0], "CMPD-999999999"
			it "should have the second line result second result column with no result", ->
				res = @responseJSON.resultCSV.split('\n')
				assert.equal res[2].split(',')[1], ""
			it "should have the third line result second result column with alias result", ->
				res = @responseJSON.resultCSV.split('\n')
				assert.equal res[3].split(',')[1].indexOf('CMPD')>-1, true

		describe "when valid lsthing parent names are passed in ONLY PASSES IN STUBS MODE", ->
			body =
				type: "parent"
				kind: "protein"
				entityIdStringLines: "GENE1234\nsome Gene name\nambiguousName\n"
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
			it "should return the requested Type", ->
				assert.equal @responseJSON.type, "parent"
			it "should return the requested Kind", ->
				assert.equal @responseJSON.kind, "protein"
			it "should have the first line query in first result column", ->
				res = @responseJSON.resultCSV.split('\n')
				assert.equal res[1].split(',')[0], "GENE1234"
			it "should have the first line result second result column", ->
				res = @responseJSON.resultCSV.split('\n')
				assert.equal res[1].split(',')[1], "GENE1234"
			it "should have the second line query in first result column", ->
				res = @responseJSON.resultCSV.split('\n')
				assert.equal res[2].split(',')[0], "some Gene name"
			it "should have the second line result second result column with the code", ->
				res = @responseJSON.resultCSV.split('\n')
				assert.equal res[2].split(',')[1], "GENE1111"
			it "should have the third line query in first result column", ->
				res = @responseJSON.resultCSV.split('\n')
				assert.equal res[3].split(',')[0], "ambiguousName"
			it "should have the third line result second result column with no result", ->
				res = @responseJSON.resultCSV.split('\n')
				assert.equal res[3].split(',')[1], ""

		describe "when valid lsthing entrez gene names or codes are passed in ONLY PASSES IN LIVE MODE with genes loaded", ->
			body =
				type: "gene"
				kind: "entrez gene"
				entityIdStringLines: "GENE-000002\nCPAMD5\nambiguousName\n"
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
					console.log @serverResponse.statusCode
					done()
			it "should return a success status code if in stubsMode, otherwise, this will fail", ->
				assert.equal @serverResponse.statusCode,200
			it "should return the requested Type", ->
				assert.equal @responseJSON.type, "gene"
			it "should return the requested Kind", ->
				assert.equal @responseJSON.kind, "entrez gene"
			it "should have the first line query in first result column", ->
				res = @responseJSON.resultCSV.split('\n')
				assert.equal res[1].split(',')[0], "GENE-000002"
			it "should have the first line result second result column", ->
				res = @responseJSON.resultCSV.split('\n')
				assert.equal res[1].split(',')[1], "GENE-000002"
			it "should have the second line query in first result column", ->
				res = @responseJSON.resultCSV.split('\n')
				assert.equal res[2].split(',')[0], "CPAMD5"
			it "should have the second line result second result column with the code", ->
				res = @responseJSON.resultCSV.split('\n')
				assert.equal res[2].split(',')[1], "GENE-000003"
			it "should have the third line query in first result column", ->
				res = @responseJSON.resultCSV.split('\n')
				assert.equal res[3].split(',')[0], "ambiguousName"
			it "should have the third line result second result column with no result", ->
				res = @responseJSON.resultCSV.split('\n')
				assert.equal res[3].split(',')[1], ""

	describe "direct function API tests", ->
		codeService = require '../../../../routes/PreferredEntityCodeService.js'

		describe "when valid lsthing entrez gene names or codes are passed in ONLY PASSES IN LIVE MODE with genes loaded", ->
			requestData =
				type: "gene"
				kind: "entrez gene"
				entityIdStringLines: "GENE-000002\nCPAMD5\nambiguousName\n"
			before (done) ->
				@.timeout(20000)
				codeService.preferredCodes requestData, (response) =>
					@responseJSON = response
					console.log response
					done()
			it "should return the requested Type", ->
				assert.equal @responseJSON.type, "gene"
			it "should return the requested Kind", ->
				assert.equal @responseJSON.kind, "entrez gene"
			it "should have the first line query in first result column", ->
				res = @responseJSON.resultCSV.split('\n')
				assert.equal res[1].split(',')[0], "GENE-000002"
			it "should have the first line result second result column", ->
				res = @responseJSON.resultCSV.split('\n')
				assert.equal res[1].split(',')[1], "GENE-000002"
			it "should have the second line query in first result column", ->
				res = @responseJSON.resultCSV.split('\n')
				assert.equal res[2].split(',')[0], "CPAMD5"
			it "should have the second line result second result column with the code", ->
				res = @responseJSON.resultCSV.split('\n')
				assert.equal res[2].split(',')[1], "GENE-000003"
			it "should have the third line query in first result column", ->
				res = @responseJSON.resultCSV.split('\n')
				assert.equal res[3].split(',')[0], "ambiguousName"
			it "should have the third line result second result column with no result", ->
				res = @responseJSON.resultCSV.split('\n')
				assert.equal res[3].split(',')[1], ""

		describe "available entity type list", ->
			describe "when requested as fully detailed list", ->
				before (done) ->
					codeService.getConfiguredEntityTypes false, (response) =>
						@responseJSON = response
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
					codeService.getConfiguredEntityTypes true, (response) =>
						@responseJSON = response
						done()
				it "should return an array of entity types", ->
					assert.equal @responseJSON.length > 0, true
				it "should return entity type descriptions with required attributes", ->
					assert.equal @responseJSON[0].code?, true
					assert.equal @responseJSON[0].name?, true
					assert.equal @responseJSON[0].ignored?, true
		describe.only "specific entity type details", ->
			before (done) ->
				codeService.getSpecificEntityType "Corporate Parent ID", (response) =>
					@responseJSON = response
					done()
			it "should return entity type descriptions with required attributes", ->
				assert.equal @responseJSON.type?, true
				assert.equal @responseJSON.kind?, true
				assert.equal @responseJSON.displayName?, true
				assert.equal @responseJSON.codeOrigin?, true
				assert.equal @responseJSON.sourceExternal?, true

describe "pickBestLabels service test", ->
	describe "for lsThings"
		before (done) ->



#TODO real implementation of getThingCodesFormNamesOrCodes
#TODO test in live mode for compounds batch, compound parent, and lsthing protein
