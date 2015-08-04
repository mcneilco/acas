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
			key = "Corporate Parent ID"
			it "should return entity type descriptions with required attributes", ->
				assert.equal @responseJSON[key].type?, true
				assert.equal @responseJSON[key].kind?, true
				assert.equal @responseJSON[key].displayName?, true
				assert.equal @responseJSON[key].codeOrigin?, true
				assert.equal @responseJSON[key].sourceExternal?, true
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
		describe "when valid compounds sent with valid type info ONLY PASSES IN STUBS MODE [CSV FORMAT]", ->
			body =
				displayName: "Protein Parent"
				entityIdStringLines: "PROT1\nPROT2\nPROT3\n"
			before (done) ->
				@.timeout(20000)
				request.post
					url: "http://localhost:"+config.all.server.nodeapi.port+"/api/entitymeta/referenceCodes/csv"
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
			it "should return 5 rows including a trailing newline", ->
				assert.equal @responseJSON.resultCSV.split('\n').length, 5
			it "should have 2 columns", ->
				res = @responseJSON.resultCSV.split('\n')
				assert.equal res[0].split(',').length, 2
			it "should have a header row", ->
				res = @responseJSON.resultCSV.split('\n')
				assert.equal res[0], "Requested Name,Reference Code"
			it "should have the query first result column", ->
				res = @responseJSON.resultCSV.split('\n')
				assert.equal res[1].split(',')[0], "PROT1"

		describe "when valid compounds sent with valid type info ONLY PASSES IN STUBS MODE [JSON FORMAT]", ->
			body =
				displayName: "Protein Parent"
				requests: [
					{requestName: "PROT1"},
					{requestName: "PROT2"},
					{requestName: "PROT3"}
				]
			before (done) ->
				@.timeout(20000)
				request.post
					url: "http://localhost:"+config.all.server.nodeapi.port+"/api/entitymeta/referenceCodes"
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
			it "should return the given displayName \n", ->
				assert.equal @responseJSON.displayName, "Protein Parent"
			it "should have 3 results", ->
				assert.equal @responseJSON.results.length, 3
			it "should return requestName", ->
				res = @responseJSON.results
				assert.equal res[0].requestName, "PROT1"
				assert.equal res[1].requestName, "PROT2"
				assert.equal res[2].requestName, "PROT3"

		describe "when valid compounds sent with invalid type info [CSV FORMAT]", ->
			body =
				displayName: "ERROR"
				entityIdStringLines: "PROT1\nPROT2\nPROT3\n"
			before (done) ->
				@.timeout(20000)
				request.post
					url: "http://localhost:"+config.all.server.nodeapi.port+"/api/entitymeta/referenceCodes/csv"
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

		describe "when valid compounds sent with invalid type info [JSON FORMAT]", ->
			body =
				displayName: "ERROR"
				requests: [
					{requestName: "PROT1"}
					{requestName: "PROT2"}
					{requestName: "PROT3"}
				]
			before (done) ->
				@.timeout(20000)
				request.post
					url: "http://localhost:"+config.all.server.nodeapi.port+"/api/entitymeta/referenceCodes"
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

		describe "when valid small molecule batch names are passed in ONLY PASSES IN STUBS MODE [CSV FORAMT]", ->
			body =
				displayName: "Corporate Batch ID"
				entityIdStringLines: "CMPD-0000001-01\nnone_2222:1\nCMPD-0000002-01\n"
			before (done) ->
				@.timeout(20000)
				request.post
					url: "http://localhost:"+config.all.server.nodeapi.port+"/api/entitymeta/referenceCodes/csv"
					json: true
					body: body
				, (error, response, body) =>
					@serverError = error
					@responseJSON = body
					console.log @responseJSON
					@serverResponse = response
					done()
			it "should return the requested displayName", ->
				assert.equal @responseJSON.displayName, "Corporate Batch ID"
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

		describe "when valid small molecule batch names are passed in ONLY PASSES IN STUBS MODE [JSON FORAMT]", ->
			body =
				displayName: "Corporate Batch ID"
				requests: [
					{requestName: "CMPD-0000001-01"}
					{requestName: "none_2222:1"}
					{requestName: "CMPD-0000002-01"}
				]
			before (done) ->
				@.timeout(20000)
				request.post
					url: "http://localhost:"+config.all.server.nodeapi.port+"/api/entitymeta/referenceCodes"
					json: true
					body: body
				, (error, response, body) =>
					@serverError = error
					@responseJSON = body
					console.log @responseJSON
					@serverResponse = response
					done()
			it "should return the requested displayName", ->
				assert.equal @responseJSON.displayName, "Corporate Batch ID"
			it "should return an array of results the same length as the array of requests", ->
				assert.equal @responseJSON.results.length, 3
			it "should have request in each results object", ->
				assert.equal @responseJSON.results[0].requestName, "CMPD-0000001-01"
				assert.equal @responseJSON.results[1].requestName, "none_2222:1"
				assert.equal @responseJSON.results[2].requestName, "CMPD-0000002-01"
			it "should have the correct result for each request", ->
				assert.equal @responseJSON.results[0].referenceCode, "CMPD-0000001-01"
				assert.equal @responseJSON.results[1].referenceCode, ""
				assert.equal @responseJSON.results[2].referenceCode, "CMPD-0000002-01"

		describe "when valid small molecule Parent names are passed in ONLY PASSES IN STUBS MODE [CSV FORMAT]", ->
			body =
				displayName: "Corporate Parent ID"
				entityIdStringLines: "CMPD-0000001\nCMPD-999999999\ncompoundName\n"
			before (done) ->
				@.timeout(20000)
				request.post
					url: "http://localhost:"+config.all.server.nodeapi.port+"/api/entitymeta/referenceCodes/csv"
					json: true
					body: body
				, (error, response, body) =>
					@serverError = error
					@responseJSON = body
					console.log @responseJSON
					@serverResponse = response
					done()
			it "should return the requested displayName", ->
				assert.equal @responseJSON.displayName, "Corporate Parent ID"
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

		describe "when valid small molecule Parent names are passed in ONLY PASSES IN STUBS MODE [JSON FORMAT]", ->
			body =
				displayName: "Corporate Parent ID"
				requests: [
					{requestName: "CMPD-0000001"}
					{requestName: "CMPD-999999999"}
					{requestName: "compoundName"}
				]
			before (done) ->
				@.timeout(20000)
				request.post
					url: "http://localhost:"+config.all.server.nodeapi.port+"/api/entitymeta/referenceCodes"
					json: true
					body: body
				, (error, response, body) =>
					@serverError = error
					@responseJSON = body
					console.log @responseJSON
					@serverResponse = response
					done()
			it "should return the requested displayName", ->
				assert.equal @responseJSON.displayName, "Corporate Parent ID"
			it "should return an array of results the same length as the array of requests", ->
				assert.equal @responseJSON.results.length, 3
			it "should have request in each results object", ->
				assert.equal @responseJSON.results[0].requestName, "CMPD-0000001"
				assert.equal @responseJSON.results[1].requestName, "CMPD-999999999"
				assert.equal @responseJSON.results[2].requestName, "compoundName"
			it "should have the correct result for each request", ->
				assert.equal @responseJSON.results[0].referenceCode, "CMPD-0000001"
				assert.equal @responseJSON.results[1].referenceCode, ""
				assert.equal @responseJSON.results[2].referenceCode.indexOf('CMPD')>-1, true

		describe "when valid lsthing parent names are passed in ONLY PASSES IN STUBS MODE [CSV FORMAT]", ->
			body =
				displayName: "Protein Parent"
				entityIdStringLines: "GENE1234\nsome Gene name\nambiguousName\n"
			before (done) ->
				@.timeout(20000)
				request.post
					url: "http://localhost:"+config.all.server.nodeapi.port+"/api/entitymeta/referenceCodes/csv"
					json: true
					body: body
				, (error, response, body) =>
					@serverError = error
					@responseJSON = body
					console.log @responseJSON
					@serverResponse = response
					done()
			it "should return the requested displayName", ->
				assert.equal @responseJSON.displayName, "Protein Parent"
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

		describe "when valid lsthing parent names are passed in ONLY PASSES IN STUBS MODE [JSON FORMAT]", ->
			body =
				displayName: "Protein Parent"
				requests: [
					{requestName: "GENE1234"}
					{requestName: "some Gene name"}
					{requestName: "ambiguousName"}
				]
			before (done) ->
				@.timeout(20000)
				request.post
					url: "http://localhost:"+config.all.server.nodeapi.port+"/api/entitymeta/referenceCodes"
					json: true
					body: body
				, (error, response, body) =>
					@serverError = error
					@responseJSON = body
					console.log @responseJSON
					@serverResponse = response
					done()
			it "should return the requested displayName", ->
				assert.equal @responseJSON.displayName, "Protein Parent"
			it "should return an array of results the same length as the array of requests", ->
				assert.equal @responseJSON.results.length, 3
			it "should have request in each results object", ->
				assert.equal @responseJSON.results[0].requestName, "GENE1234"
				assert.equal @responseJSON.results[1].requestName, "some Gene name"
				assert.equal @responseJSON.results[2].requestName, "ambiguousName"
			it "should have the correct result for each request", ->
				assert.equal @responseJSON.results[0].referenceCode, "GENE1234"
				assert.equal @responseJSON.results[1].referenceCode, "GENE1111"
				assert.equal @responseJSON.results[2].referenceCode, ""

		describe "when valid lsthing entrez gene names or codes are passed in ONLY PASSES IN LIVE MODE with genes loaded [CSV FORMAT]", ->
			body =
				displayName: "Gene ID"
				entityIdStringLines: "GENE-000002\nCPAMD5\nambiguousName\n"
			before (done) ->
				@.timeout(20000)
				request.post
					url: "http://localhost:"+config.all.server.nodeapi.port+"/api/entitymeta/referenceCodes/csv"
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
			it "should return the requested displayName", ->
				assert.equal @responseJSON.type, "Gene ID"
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

		describe "when valid lsthing entrez gene names or codes are passed in ONLY PASSES IN LIVE MODE with genes loaded [JSON FORMAT]", ->
			body =
				displayName: "Gene ID"
				requests: [
					{requestName: "GENE-000002"}
					{requestName: "CPAMD5"}
					{requestName: "ambiguousName"}
				]
			before (done) ->
				@.timeout(20000)
				request.post
					url: "http://localhost:"+config.all.server.nodeapi.port+"/api/entitymeta/referenceCodes"
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
			it "should return the requested displayName", ->
				assert.equal @responseJSON.displayName, "Gene ID"
			it "should return an array of results the same length as the array of requests", ->
				assert.equal @responseJSON.results.length, 3
			it "should have request in each results object", ->
				assert.equal @responseJSON.results[0].requestName, "GENE-000002"
				assert.equal @responseJSON.results[1].requestName, "CPAMD5"
				assert.equal @responseJSON.results[2].requestName, "ambiguousName"
			it "should have the correct result for each request", ->
				assert.equal @responseJSON.results[0].referenceCode, "GENE-000002"
				assert.equal @responseJSON.results[1].referenceCode, "GENE-000003"
				assert.equal @responseJSON.results[2].referenceCode, ""

	describe "direct function API tests", ->
		codeService = require '../../../../routes/PreferredEntityCodeService.js'

		describe "when valid lsthing entrez gene names or codes are passed in ONLY PASSES IN LIVE MODE with genes loaded [CSV FORMAT]", ->
			csv = true
			requestData =
				displayName: "Gene ID"
				entityIdStringLines: "GENE-000002\nCPAMD5\nambiguousName\n"
			before (done) ->
				@.timeout(20000)
				codeService.referenceCodes requestData, csv, (response) =>
					@responseJSON = response
					console.log response
					done()
			it "should return the requested displayName", ->
				assert.equal @responseJSON.displayName, "Gene ID"
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

		describe "when valid lsthing entrez gene names or codes are passed in ONLY PASSES IN LIVE MODE with genes loaded [JSON FORMAT]", ->
			csv = false
			requestData =
				displayName: "Gene ID"
				requests: [
					{requestName: "GENE-000002"}
					{requestName: "CPAMD5"}
					{requestName: "ambiguousName"}
				]
			before (done) ->
				@.timeout(20000)
				codeService.referenceCodes requestData, csv, (response) =>
					@responseJSON = response
					console.log response
					done()
			it "should return the requested displayName", ->
				assert.equal @responseJSON.type, "Gene ID"
			it "should return an array of results the same length as the array of requests", ->
				assert.equal @responseJSON.results.length, 3
			it "should have request in each results object", ->
				assert.equal @responseJSON.results[0].requestName, "GENE-000002"
				assert.equal @responseJSON.results[1].requestName, "CPAMD5"
				assert.equal @responseJSON.results[2].requestName, "ambiguousName"
			it "should have the correct result for each request", ->
				assert.equal @responseJSON.results[0].referenceCode, "GENE-000002"
				assert.equal @responseJSON.results[1].referenceCode, "GENE-000003"
				assert.equal @responseJSON.results[2].referenceCode, ""

		describe "available entity type list", ->
			describe "when requested as fully detailed object", ->
				before (done) ->
					codeService.getConfiguredEntityTypes false, (response) =>
						@responseJSON = response
						done()
				it "should return entity type descriptions with required attributes", ->
					key = "Corporate Parent ID"
					assert.equal @responseJSON[key].type?, true
					assert.equal @responseJSON[key].kind?, true
					assert.equal @responseJSON[key].displayName?, true
					assert.equal @responseJSON[key].codeOrigin?, true
					assert.equal @responseJSON[key].sourceExternal?, true
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
		describe "when requested as specific entity type details", ->
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

#TODO implement pickBestLabels
# describe "pickBestLabels service test", ->
# 	describe "for lsThings", ->
# 		body =
# 			displayName: "Gene ID"
# 			referenceCodes: "GENE-000002\nGENE-000003"
# 		before (done) ->
# 			@.timeout(20000)
# 			request.post
# 				url: "http://localhost:"+config.all.server.nodeapi.port+"/api/entitymeta/pickBestLabels"
# 				json: true
# 				body: body
# 			, (error, response, body) =>
# 				@serverError = error
# 				@responseJSON = body
# 				console.log @responseJSON
# 				@serverResponse = response
# 				done()
# 		it "should return an object with the correct fields", ->
# 			assert @responseJSON.displayName?
# 			assert @responseJSON.resultCSV?
# 		it "should have the first line query in second row, first column", ->
# 			res = @responseJSON.resultCSV.split('\n')
# 			assert.equal res[1].split(',')[0], "GENE-000002"
# 		it "should have the first line result in second row, second column", ->
# 			res = @responseJSON.resultCSV.split('\n')
# 			assert.equal res[1].split(',')[1], "1"
# 		it "should have the second line query in third row, first column", ->
# 			res = @responseJSON.resultCSV.split('\n')
# 			assert.equal res[2].split(',')[0], "GENE-000003"
# 		it "should have the second line result in third row, second column", ->
# 			res = @responseJSON.resultCSV.split('\n')
# 			assert.equal res[2].split(',')[1], "2"

# describe "searchForEntities service test", ->
# 	decribe "for lsThings", ->
# 		body =
# 			searchText: "A1BG"
# 		before (done) ->
# 			@.timeout(20000)
# 			request.post
# 				url: "http://localhost:"+config.all.server.nodeapi.port+"/api/entitymeta/searchForEntities"
# 				json: true
# 				body: body
# 			, (error, response, body) =>
# 				@serverError = error
# 				@responseJSON = body
# 				console.log @responseJSON
# 				@serverResponse = response
# 				done()
# 		it "should return an object with the correct fields", ->
# 			assert @responseJSON.resultCSV?



#TODO real implementation of getThingCodesFormNamesOrCodes
#TODO test in live mode for compounds batch, compound parent, and lsthing protein
