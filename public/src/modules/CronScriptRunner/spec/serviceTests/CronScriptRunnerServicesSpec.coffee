###
  This subsystem runs scripts on a periodic basis. Examples of uses:
- Check the status of external data analysis jobs running on a grid system
- Check for files added to a directory that need to be processed
- Check to see if ACAS should send a user a reminder to do something
- Kick off the ping-pong table generator

Basic requirements:
- Programmatically add and remove periodic jobs
- Call R script (other languages in the future)
- Queue has to survive system ACAS and server reboots, so should be stored permanently in the database or a file
- API should be usable from within node or from outside processes like R scripts, so need REST API and access to functions
- When called, there will be no context, so function names and arguments need to be strings or numbers, not live functions.
- R script call should be formatted like every other wrapped R script in ACAS,
  the caller supplies the script, the function name, and the arguments as a JSON formatted string
###

assert = require 'assert'
request = require 'request'

config = require '../../../../conf/compiled/conf.js'
cronScriptRunnerTestJSON = require '../testFixtures/CronScriptRunnerTestJSON.js'

baseURL = "http://"+config.all.client.host+":"+config.all.server.nodeapi.port

parseResponse = (jsonStr) ->
	try
		return JSON.parse jsonStr
	catch error
		console.log "response unparsable: " + error
		return null

copyJSON = (json) ->
	JSON.parse(JSON.stringify(json))

describe "Cron Script Runner Services Spec", ->
	describe "Create new cron script runner, saves to databases and schedules the job, unless active = false", ->
		unsavedReq = copyJSON cronScriptRunnerTestJSON.savedCronEntry
		delete unsavedReq.cronCode
		before (done) ->
			request.post
				url: baseURL+"/api/cronScriptRunner"
				json: true
				body: unsavedReq
			, (error, response, body) =>
				@serverError = error
				@responseJSON = body
				@serverResponse = response
				#cleanup
				request.put
					url: baseURL+"/api/cronScriptRunner/"+body.cronCode
					json: true
					body:
						active: false
						ignored: true
				, (error, response, body) =>
					done()
		it "should return a success status code of 200", ->
			assert.equal @serverResponse.statusCode, 200
		it "should supply a new code", ->
			assert.equal @responseJSON.cronCode?, true

	describe "updating jobs", ->
		describe "disable current cron and delete", ->
			#save a job to stop
			unsavedReq = copyJSON cronScriptRunnerTestJSON.savedCronEntry
			delete unsavedReq.cronCode
			before (done) ->
				request.post
					url: baseURL+"/api/cronScriptRunner"
					json: true
					body: unsavedReq
				, (error, response, body) =>
					request.put
						url: baseURL+"/api/cronScriptRunner/"+body.cronCode
						json: true
						body:
							active: false
							ignored: true # if you just want to disable, then leave this falsea
					, (error, response, body) =>
						@responseJSON = body
						@serverResponse = response
						done()
			it "should return a success status code of 200", ->
				assert.equal @serverResponse.statusCode, 200
			it "should return the updated active value", ->
				assert.equal @responseJSON.active, false
			it "should return the updated ignored value", ->
				assert.equal @responseJSON.ignored, true

		describe "try to update non-existant job", ->
			before (done) ->
				request.put
					url: baseURL+"/api/cronScriptRunner/"+"errorNonExistant"
					json: true
					body:
						active: false
						ignored: true # if you just want to disable, then leave this falsea
				, (error, response, body) =>
					@responseJSON = body
					@serverResponse = response
					done()
			it "should return a success error code of 404", ->
				assert.equal @serverResponse.statusCode, 404


	describe "create and run cron and get run status", ->
		#save a job to run
		unsavedReq = copyJSON cronScriptRunnerTestJSON.savedCronEntry
		delete unsavedReq.cronCode
		before (done) ->
			@.timeout(25000)
			request.post
				url: baseURL+"/api/cronScriptRunner"
				json: true
				body: unsavedReq
			, (error, response, body) =>
				setTimeout =>
					request.get
						url: baseURL+"/api/cronScriptRunner/"+body.cronCode
						json: true
					, (error, response, body) =>
						@responseJSON = body
						console.log body
						@serverResponse = response
						#cleanup
						request.put
							url: baseURL+"/api/cronScriptRunner/"+body.cronCode
							json: true
							body:
								active: false
								ignored: true
						, (error, response, body) =>
							done()
				, 15000
		it "should return the cron object with the last start time", ->
			assert.equal @responseJSON.lastStartTime>0, true
		it "should return the cron object with the last duration", ->
			assert.equal @responseJSON.lastDuration>0, true
		it "should return the cron object result JSON", ->
			assert.equal @responseJSON.lastResultJSON.indexOf('}')>0, true
		it "should return success of the R script run", ->
			assert.equal parseResponse(@responseJSON.lastResultJSON).hasError, false
		it "should increment the run count", ->
			assert.equal @responseJSON.numberOfExcutions > 0 , true

#TODO specs for all failure routes
#TODO move service implementation out of route functions so they can be called from within node
#TODO write specs for PUT to test job stop and restart
#TODO check to make sure json arguments are parsable on post or put
#TODO server should validate that required fields are supplied and give useful error messages if not






