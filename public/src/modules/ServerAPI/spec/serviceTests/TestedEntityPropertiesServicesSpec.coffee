assert = require 'assert'
request = require 'request'


config = require '../../../../conf/compiled/conf.js'
describe "Tested Entity Properties Services", ->
	describe "get calculated compound properties", ->
		describe "when valid compounds sent with valid properties ONLY PASSES IN STUBS MODE", ->
			body =
				properties: ["HEAVY_ATOM_COUNT", "MONOISOTOPIC_MASS"]
				entityIdStringLines: "FRD76\nFRD2\nFRD78\n"
			before (done) ->
				@.timeout(20000)
				request.post
					url: "http://localhost:"+config.all.server.nodeapi.port+"/api/testedEntities/properties"
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
				assert.equal @responseJSON.split('\n').length, 5
			it "should have 3 columns", ->
				res = @responseJSON.split('\n')
				assert.equal res[0].split(',').length, 3
			it "should have a header row", ->
				res = @responseJSON.split('\n')
				assert.equal res[0], "id,HEAVY_ATOM_COUNT,MONOISOTOPIC_MASS"
			it "should have a number in the first result row", ->
				res = @responseJSON.split('\n')
				assert.equal isNaN(parseFloat(res[1].split(',')[1])),false
		describe "when valid compounds sent with invalid properties", ->
			propertyList = ["ERROR", "deep_fred"]
			entityList = "FRD76\nFRD2\nFRD78\n"
			before (done) ->
				@.timeout(20000)
				request.post
					url: "http://localhost:"+config.all.server.nodeapi.port+"/api/testedEntities/properties"
					json: true
					body:
						properties: propertyList
						entityIdStringLines: entityList
				, (error, response, body) =>
					@serverError = error
					@responseJSON = body
					console.log @responseJSON
					@serverResponse = response
					done()
			it "should return a failure status code", ->
				assert.equal @serverResponse.statusCode,500
		describe "when invalid compounds sent with valid properties", ->
			propertyList = ["HEAVY_ATOM_COUNT", "MONOISOTOPIC_MASS"]
			entityList = "ERROR1\nERROR2\nERROR3\n"
			before (done) ->
				@.timeout(20000)
				request.post
					url: "http://localhost:"+config.all.server.nodeapi.port+"/api/testedEntities/properties"
					json: true
					body:
						properties: propertyList
						entityIdStringLines: entityList
				, (error, response, body) =>
					@serverError = error
					@responseJSON = body
					console.log @responseJSON
					@serverResponse = response
					done()
			it "should return an success status code", ->
				assert.equal @serverResponse.statusCode,200
			it "should return 5 rows including a trailing \n", ->
				assert.equal @responseJSON.split('\n').length, 5
			it "should have 3 columns", ->
				res = @responseJSON.split('\n')
				assert.equal res[0].split(',').length, 3
			it "should have a header row", ->
				res = @responseJSON.split('\n')
				assert.equal res[0], "id,HEAVY_ATOM_COUNT,MONOISOTOPIC_MASS"
			it "should have an empty string in the first result", ->
				res = @responseJSON.split('\n')
				assert.equal res[1].split(',')[1],""
