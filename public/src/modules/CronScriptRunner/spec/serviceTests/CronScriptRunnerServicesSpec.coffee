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
- API should be usable from within node or from outside processes like R scripts, so need REST API
- Must call through services. Direct function calls won't work because we have to keep global cron hash
- When called, there will be no context, so function names and arguments need to be strings or numbers, not live functions.
- R script call should be formatted like every other wrapped R script in ACAS,
  the caller supplies the script, the function name, and the arguments as a JSON formatted string
###

assert = require 'assert'
request = require 'request'

config = require '../../../../conf/compiled/conf.js'
cronScriptRunnerTestJSON = require '../testFixtures/CronScriptRunnerTestJSON.js'
cronFunctions = require '../../../../routes/CronScriptRunnerRoutes.js'

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
		delete unsavedReq.codeName
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
					url: baseURL+"/api/cronScriptRunner/"+body.codeName
					json: true
					body:
						active: false
						ignored: true
				, (error, response, body) =>
					done()
		it "should return a success status code of 200", ->
			assert.equal @serverResponse.statusCode, 200
		it "should supply a new code", ->
			assert.equal @responseJSON.codeName?, true

	describe "updating jobs", ->
		describe "disable current cron and delete", ->
			#save a job to stop
			unsavedReq = copyJSON cronScriptRunnerTestJSON.savedCronEntry
			delete unsavedReq.codeName
			before (done) ->
				request.post
					url: baseURL+"/api/cronScriptRunner"
					json: true
					body: unsavedReq
				, (error, response, body) =>
					request.put
						url: baseURL+"/api/cronScriptRunner/"+body.codeName
						json: true
						body:
							active: false
							ignored: true # if you just want to disable, then leave this false
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
						ignored: true # if you just want to disable, then leave this false
				, (error, response, body) =>
					@responseJSON = body
					@serverResponse = response
					done()
			it "should return a success error code of 404", ->
				assert.equal @serverResponse.statusCode, 404


	describe "create and run cron and get run status", ->
		#save a job to run
		unsavedReq = copyJSON cronScriptRunnerTestJSON.savedCronEntry
		delete unsavedReq.codeName
		before (done) ->
			@.timeout(25000)
			request.post
				url: baseURL+"/api/cronScriptRunner"
				json: true
				body: unsavedReq
			, (error, response, body) =>
				setTimeout =>
					request.get
						url: baseURL+"/api/cronScriptRunner/"+body.codeName
						json: true
					, (error, response, body) =>
						@responseJSON = body
						@serverResponse = response
						#cleanup
						request.put
							url: baseURL+"/api/cronScriptRunner/"+body.codeName
							json: true
							body:
								active: false
								ignored: true
						, (error, response, body) =>
							done()
				, 3000
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

	describe.only "create and run cron then stop", ->
		#save a job to run
		unsavedReq = copyJSON cronScriptRunnerTestJSON.savedCronEntry
		delete unsavedReq.codeName
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
					, (error, response, body1) =>
						@numRuns1 = body1.numberOfExcutions
						#cleanup
						request.put
							url: baseURL+"/api/cronScriptRunner/"+body.cronCode
							json: true
							body:
								active: false
								ignored: false
						, (error, response, body) =>
							setTimeout =>
								request.get
									url: baseURL+"/api/cronScriptRunner/"+body.cronCode
									json: true
								, (error, response, body2) =>
									@numRuns2 = body2.numberOfExcutions
									done()
							, 2500
				, 2500
		it "should run once", ->
			assert.equal @numRuns1, @numRuns2


	describe "create active job then change it", ->
		#save a job to run
		unsavedReq = copyJSON cronScriptRunnerTestJSON.savedCronEntry
		delete unsavedReq.codeName
		before (done) ->
			@.timeout(25000)
			request.post
				url: baseURL+"/api/cronScriptRunner"
				json: true
				body: unsavedReq
			, (error, response, body) =>
				setTimeout =>
					request.get
						url: baseURL+"/api/cronScriptRunner/"+body.codeName
						json: true
					, (error, response, body1) =>
						@numRuns1 = body1.numberOfExcutions
						request.put
							url: baseURL+"/api/cronScriptRunner/"+body.codeName
							json: true
							body:
								active: true
								ignored: false
								scriptJSONData: '{"fileToParse": "public/src/modules/BulkLoadSampleTransfers/spec/specFiles/KilroyWasHere_good.csv", "dryRun": "true", "user": "jmcneil" }'
						, (error, response, body) =>
							setTimeout =>
								request.get
									url: baseURL+"/api/cronScriptRunner/"+body.codeName
									json: true
								, (error, response, body2) =>
									@numRuns2 = body2.numberOfExcutions
									@lastResultJSON = body2.lastResultJSON
									#cleanup
									request.put
										url: baseURL+"/api/cronScriptRunner/"+body.codeName
										json: true
										body:
											active: false
											ignored: false
									, (error, response, body) =>
										done()
							, 4500
				, 2500
		it "should run at first", ->
			assert.equal @numRuns1>0, true
		it "should run later", ->
			assert.equal @numRuns2>@numRuns1, true
		it "should return an error the second run", ->
			assert.equal @lastResultJSON.indexOf("KilroyWasHere")>-1, true



	describe "create inactive job then set active", ->
		#save a job to run
		unsavedReq = copyJSON cronScriptRunnerTestJSON.savedCronEntry
		delete unsavedReq.codeName
		unsavedReq.active = false
		before (done) ->
			@.timeout(25000)
			request.post
				url: baseURL+"/api/cronScriptRunner"
				json: true
				body: unsavedReq
			, (error, response, body) =>
				setTimeout =>
					request.get
						url: baseURL+"/api/cronScriptRunner/"+body.codeName
						json: true
					, (error, response, body1) =>
						@numRuns1 = body1.numberOfExcutions
						request.put
							url: baseURL+"/api/cronScriptRunner/"+body.codeName
							json: true
							body:
								active: true
								ignored: false
						, (error, response, body) =>
							setTimeout =>
								request.get
									url: baseURL+"/api/cronScriptRunner/"+body.codeName
									json: true
								, (error, response, body2) =>
									@numRuns2 = body2.numberOfExcutions
									#cleanup
									request.put
										url: baseURL+"/api/cronScriptRunner/"+body.codeName
										json: true
										body:
											active: false
											ignored: false
									, (error, response, body) =>
											done()
							, 2500
				, 2500
		it "should not run at first", ->
			assert.equal @numRuns1, 0
		it "should run later", ->
			assert.equal @numRuns2>0, true


	describe "create active job then set inactive, then active", ->
		#save a job to run
		unsavedReq = copyJSON cronScriptRunnerTestJSON.savedCronEntry
		delete unsavedReq.codeName
		before (done) ->
			@.timeout(25000)
			request.post
				url: baseURL+"/api/cronScriptRunner"
				json: true
				body: unsavedReq
			, (error, response, body) =>
				setTimeout =>
					request.get
						url: baseURL+"/api/cronScriptRunner/"+body.codeName
						json: true
					, (error, response, body1) =>
						@numRuns1 = body1.numberOfExcutions
						request.put
							url: baseURL+"/api/cronScriptRunner/"+body.codeName
							json: true
							body:
								active: false
								ignored: false
						, (error, response, body) =>
							setTimeout =>
								request.get
									url: baseURL+"/api/cronScriptRunner/"+body.codeName
									json: true
								, (error, response, body2) =>
									@numRuns2 = body2.numberOfExcutions
									request.put
										url: baseURL+"/api/cronScriptRunner/"+body.codeName
										json: true
										body:
											active: true
											ignored: false
									, (error, response, body3) =>
										setTimeout =>
											request.get
												url: baseURL+"/api/cronScriptRunner/"+body.codeName
												json: true
											, (error, response, body3) =>
												@numRuns3 = body3.numberOfExcutions
												#cleanup
												request.put
													url: baseURL+"/api/cronScriptRunner/"+body.codeName
													json: true
													body:
														active: false
														ignored: false
												, (error, response, body) =>
													done()
										, 2500
							, 2500
				, 2500
		it "should  run at first", ->
			assert.equal @numRuns1> 0, true
		it "should stop later", ->
			assert.equal @numRuns1, @numRuns2
		it "should start after that", ->
			assert.equal @numRuns3>@numRuns2, true



	describe "Post bogus or missing cron spec", ->
		describe "missing schedule", ->
			unsavedReq = copyJSON cronScriptRunnerTestJSON.savedCronEntry
			delete unsavedReq.codeName
			delete unsavedReq.schedule
			before (done) ->
				request.post
					url: baseURL+"/api/cronScriptRunner"
					json: true
					body: unsavedReq
				, (error, response, body) =>
					@serverError = error
					@responseJSON = body
					@serverResponse = response
					done()
			it "should return a success status code of 500", ->
				assert.equal @serverResponse.statusCode, 500
		describe "missing scriptType", ->
			unsavedReq = copyJSON cronScriptRunnerTestJSON.savedCronEntry
			delete unsavedReq.codeName
			delete unsavedReq.scriptType
			before (done) ->
				request.post
					url: baseURL+"/api/cronScriptRunner"
					json: true
					body: unsavedReq
				, (error, response, body) =>
					@serverError = error
					@responseJSON = body
					@serverResponse = response
					done()
			it "should return a success status code of 500", ->
				assert.equal @serverResponse.statusCode, 500
		describe "missing scriptFile", ->
			unsavedReq = copyJSON cronScriptRunnerTestJSON.savedCronEntry
			delete unsavedReq.codeName
			delete unsavedReq.scriptFile
			before (done) ->
				request.post
					url: baseURL+"/api/cronScriptRunner"
					json: true
					body: unsavedReq
				, (error, response, body) =>
					@serverError = error
					@responseJSON = body
					@serverResponse = response
					done()
			it "should return a success status code of 500", ->
				assert.equal @serverResponse.statusCode, 500
		describe "missing functionName", ->
			unsavedReq = copyJSON cronScriptRunnerTestJSON.savedCronEntry
			delete unsavedReq.codeName
			delete unsavedReq.functionName
			before (done) ->
				request.post
					url: baseURL+"/api/cronScriptRunner"
					json: true
					body: unsavedReq
				, (error, response, body) =>
					@serverError = error
					@responseJSON = body
					@serverResponse = response
					done()
			it "should return a success status code of 500", ->
				assert.equal @serverResponse.statusCode, 500
		describe "missing scriptJSONData", ->
			unsavedReq = copyJSON cronScriptRunnerTestJSON.savedCronEntry
			delete unsavedReq.codeName
			delete unsavedReq.scriptJSONData
			before (done) ->
				request.post
					url: baseURL+"/api/cronScriptRunner"
					json: true
					body: unsavedReq
				, (error, response, body) =>
					@serverError = error
					@responseJSON = body
					@serverResponse = response
					done()
			it "should return a success status code of 500", ->
				assert.equal @serverResponse.statusCode, 500
		describe "missing active", ->
			unsavedReq = copyJSON cronScriptRunnerTestJSON.savedCronEntry
			delete unsavedReq.codeName
			delete unsavedReq.active
			before (done) ->
				request.post
					url: baseURL+"/api/cronScriptRunner"
					json: true
					body: unsavedReq
				, (error, response, body) =>
					@serverError = error
					@responseJSON = body
					@serverResponse = response
					done()
			it "should return a success status code of 500", ->
				assert.equal @serverResponse.statusCode, 500

#TODO Persist in Roo
#TODO see todos in implementation
#TODO Read all active jobs in Roo persistance and add to live queue during startup






