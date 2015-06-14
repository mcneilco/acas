###
  This subsystem runs processes, most likely an R script, on a periodic basis to check the status of an external system or process.
  Examples of uses:
- Check the status of external data analysis jobs running on a grid system
- Check for files that need to be processed newly added to a directory
- Check to see if ACAS should send a user a reminder to do something, for example that a term in a contract document is about to occur
- Kick off ping-pong table generator

Basic requirements:
- Programmatically add and remove periodic jobs
- Call R script (in future other languages)
- When called, there will be no context, so function names and arguments need to be strings or numbers, not live functions.
- Queue has to survive system ACAS and server reboots, so should be stored permanently in the database or a file
- Need to be able to configure jobs as well as launch them programmatically.
  A module like doc manager should be able to specify jobs to run in a config file in its source, or maybe a global config.
  I guess we could make the module have to add it if doesn’t exist when it is first run
  (maybe in the setup routes function?) We would need to add a module for ping-pong
###



assert = require 'assert'
request = require 'request'


config = require '../../../../conf/compiled/conf.js'
describe "Tested Entity Properties Services", ->
	describe "get calculated compound properties", ->
		describe "when valid compounds sent with valid properties ONLY PASSES IN STUBS MODE", ->
			body =
				properties: ["HEAVY_ATOM_COUNT", "MONOISOTOPIC_MASS"]
				entityIdStringLines: "FRD76\nFRD2\nFRD78\n"
			console.log body
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
