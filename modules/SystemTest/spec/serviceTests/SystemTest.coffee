assert = require 'assert'
request = require 'request'
_ = require 'underscore'
acasHome = '../../../..'
systemTestRoutes = require "#{acasHome}/routes/SystemTestRoutes.js"
experimentServiceTestJSON = require "#{acasHome}/public/javascripts/spec/ServerAPI/testFixtures/ExperimentServiceTestJSON.js"
runRFunctionServiceTestJSON = require "#{acasHome}/public/javascripts/spec/ServerAPI/testFixtures/RunRFunctionServiceTestJSON.js"

fs = require 'fs'
exec = require('child_process').exec
config = require "#{acasHome}/conf/compiled/conf.js"

parseResponse = (jsonStr) ->
	try
		return JSON.parse jsonStr
	catch error
		console.log "response unparsable: " + error
		return null


#########################
# A. ACAS Communication #
#########################
prefix = "http"
if config.all.client.use.ssl? && config.all.client.use.ssl
	prefix = "https"

describe "A. Connecting to ACAS -nondestructive", ->
	describe "by requesting #{prefix}://client.host:client.port", ->
		before (done) ->
			request "#{prefix}://"+config.all.client.host+":"+config.all.client.port, (error, response, body) =>
				@responseJSON = body
				@response = response
				done()
		it "should return a status code of 200", ->
			assert.equal(@response==undefined,false, "communication error between node and acas. Check that client.host and client.port are set properly.")
			assert.equal(@response.statusCode==404,false,"unable to access acas. check that client.port is set properly")
			assert.equal(@response.statusCode, 200, "status code "+@response.statusCode+" returned instead. Possible communication error between node and acas.")



#############################
# B. Database Communication #
#############################

describe "B. Connecting to the database -nondestructive", ->
	describe "through tomcat", ->
		before (done) ->
			@timeout 600000
			request "http://"+config.all.client.service.persistence.host+":"+config.all.client.service.persistence.port, (error, response, body) =>
				@response = response
				done()
		it "should return a status code of 200", ->
			assert.equal(@response==undefined,false, "Node cannot connect to tomcat. Check that the property client.service.persistence.port and client.service.persistence.host are set properly.")
			assert.equal(@response.statusCode, 200, "status code "+@response.statusCode+" returned instead")

		describe "and fetching data from the database", ->
			it "should be able to contact the database before timeout", ->
				before (done) ->
					request "http://"+config.all.client.service.persistence.host+":"+config.all.client.service.persistence.port+"/acas/api/v1/containertypes", (error, response, body) =>
						done()

			describe "should return a JSON", ->
				before (done) ->
					request "http://"+config.all.client.service.persistence.host+":"+config.all.client.service.persistence.port+"/acas/api/v1/containertypes", (error, response, body) =>
						@responseJSON = body
						done()
				it "that can be parsed", ->
					try parseResponse(@responseJSON)
					catch
#Note, will fail if containertypes is empty
						assert(false,"Unable to parse the JSON response, check connection between roo and the database and that
                        client.service.persistence.port and client.service.persistence.host")

	describe "through the nodeapi port", ->
		describe "and pulling the codetables", ->
			before (done) ->
				request "http://"+config.all.client.host+":"+config.all.server.nodeapi.port+"/api/codetables", (error, response, body) =>
					@responseJSON = body
					done()
			it "should return something that can be parsed", ->
				try parseResponse(@responseJSON)[0]
				catch
					assert(false,"Unable to parse the JSON response, check connection between tomcat and the database and that
                        server.nodeapi.port is set correctly.")

#################################
# C. File Storage Communication #
#################################

# todo make this test more robust
# Note, this is not a very robust test. It simply checks to see if the directory assigned to be the uploads and temp file system exists
# This does not check write permissions since fs.access can only check permissions of files, not directories
describe "C. Writing a file to", ->
	describe "the uploads path", ->
		before (done) ->
			fs.writeFile config.all.server.datafiles.relative_path+'/test.txt', 'this is a test', (error) =>
				@errors = error
				done()
		it "should not throw an error", ->
			assert(@errors == null || @errors == undefined, "Check the connection between node and the file uploads
                                                       including server.datafiles.relative_path.")
		describe "then accessing the file", ->
			describe  "directly", ->
				before (done) ->
					fs.readdir config.all.server.datafiles.relative_path, (err,files) =>
						@errors = err
						@files = files
						done()
				it "should not throw an error", ->
					assert(@errors==null, "Unable to read the directory. Check the connection between node and the file uploads
                                including server.datafiles.relative_path.")
				it "should find file", ->
					assert(@files.indexOf("test.txt")!= -1, "test file was not added to the uploads directory. Check that
                                                    server.datafiles.relative_path points to a directory that can be written to.")
			describe "through the server", ->
				before (done) ->
					request config.all.server.service.persistence.fileUrl, (error, response, body) =>
						@errors = error
						@responseJSON = body
						done()
				it "should not throw an error", ->
					assert(@errors==null, "unable to access the test file through the nodeapi port.
                                Ensure that server.service.persistence.fileUrl=#{config.all.server.service.persistence.fileUrl} is set correctly.")
				it "should find file", ->
					parsedResponse = JSON.stringify(parseResponse(@responseJSON))
					assert(parsedResponse.indexOf("test.txt") != -1, "unable to access the test file through the nodeapi port.
                                                            Ensure that server.service.persistence.fileUrl=#{config.all.server.service.persistence.fileUrl} is set correctly.")

		describe "then deleting the file", ->
			before (done) ->
				fs.unlink config.all.server.datafiles.relative_path+'/test.txt', (err) =>
					@errors = err
					done()
			it "should not throw an error", ->
				assert(@errors==null, "unable to delete file from uploads path: "+@errors)

			describe "and checking for existence", ->
				before (done) ->
					fs.readdir config.all.server.datafiles.relative_path, (err,files) =>
						@errors = err
						@files = files
						done()
				it "should not throw an error", ->
					assert(@errors==null, "Unable to read the directory. Check the connection between node and the file uploads
                                including server.datafiles.relative_path.")
				it "should not find file", ->
					assert(@files.indexOf("test.txt")== -1, "test file was not deleted from the uploads directory. Check that
                                                    server.datafiles.relative_path points to a directory that can be written to.")

	describe "the temp path", ->
		before (done) ->
			fs.writeFile config.all.server.tempfiles.relative_path+'/test.txt', 'this is a test', (error) =>
				@errors = error
				done()
		it "should not throw an error", ->
			assert(@errors == null || @errors == undefined, "Check the connection between node and the temp files
                                                       including server.tempfiles.relative_path.")
		describe "then accessing the file", ->
			before (done) ->
				fs.readdir config.all.server.tempfiles.relative_path, (err,files) =>
					@errors = err
					@files = files
					done()
			it "should not throw an error", ->
				assert(@errors==null, "Unable to read the directory. Check the connection between node and the temp files
                                including server.tempfiles.relative_path.")
			it "should find file", ->
				assert(@files.indexOf("test.txt")!= -1, "test file was not added to the temp files directory. Check that
                                                    server.tempfiles.relative_path points to a directory that can be written to.")

		describe "then deleting the file", ->
			before (done) ->
				fs.unlink config.all.server.tempfiles.relative_path+'/test.txt', (err) =>
					@errors = err
					done()
			it "should not throw an error", ->
				assert(@errors==null, "unable to delete file from uploads path: "+@errors)

			describe "and checking for existence", ->
				before (done) ->
					fs.readdir config.all.server.tempfiles.relative_path, (err,files) =>
						@errors = err
						@files = files
						done()
				it "should not throw an error", ->
					assert(@errors==null, "Unable to read the directory. Check the connection between node and the file uploads
                                including server.tempfiles.relative_path.")
				it "should not find file", ->
					assert(@files.indexOf("test.txt")== -1, "test file was not deleted from the uploads directory. Check that
                                                    server.datafiles.relative_path points to a directory that can be written to.")


#################################
# D. Communication with rApache #
#################################

describe "D. Access to rApache -nondestructive", ->
	@timeout 10000
	before (done) ->
		request config.all.client.service.rapache.fullpath + "hello", (error, response, body) =>
			@responseJSON = body
			@response = response
			done()
	it "Should return an status code of 200", ->
		assert.equal(@response==undefined,false, "communication error between node and rApache. Check that client.service.rapache.host and client.service.rapache.port are set properly.")
		assert.equal(@response.statusCode==404,false,"unable to access rApache. Check that client.service.rapache.port is set properly")
		assert.equal(@response.statusCode, 200, "status code "+@response.statusCode+" returned instead. Possible communication error between node and rApache.")

	describe "and then to racas hello()", ->
		before (done) ->
			request config.all.client.service.rapache.fullpath + "hello", (error, response, body) =>
				@responseJSON = body
				@response = response
				done()
		it "should return 'Hello from racas'", ->
#Todo figure out what properties could be broken in this case
			assert(@response!=undefined,false, "communication error between rApache and racas.")
			assert(@response.body == 'Hello from racas', "communication error between rApache and racas,"+@response.body+" returned instead.")

	describe "and then to racas runfunction", ->
		before (done) ->
			@.timeout(20000)
			request.post
				url: config.all.client.service.rapache.fullpath + "runfunction"
				json: true
				body: runRFunctionServiceTestJSON.runRFunctionRequest
			, (error, response, body) =>
				@serverError = error
				@responseJSON = body
				done()
		it "should return the response", ->
			assert @responseJSON.result == 'Success', "communication error when running rApache runfunction route, returned "+JSON.stringify(@responseJSON)+" instead."

	describe "and then to the database", ->
		describe "through tomcat", ->
			before (done) ->
				request config.all.client.service.rapache.fullpath + "test/getAllValueKinds", (error, response, body) =>
					@responseJSON = body
					done()
			it "should return a stringified list", ->
# split the output into an array using ( delimiter, only return the first split.

				split = @responseJSON.split "(", 1
				assert.equal(split[0], "list", "rApache unable to access the database through tomcat.
                                        Check that all environment variables are set correctly. ")

		describe "directly", ->
			before (done) ->
				request config.all.client.service.rapache.fullpath + "test/getDatabaseConnection", (error, response, body) =>
					@responseJSON = body
					done()
			it "should not return an error", ->
				assert.equal(@responseJSON,"",@responseJSON)

#############################
# E. System Tests           #
#############################

global.cleanup = {}
describe "E. System Tests", =>
	describe "get or create acas bob", =>
		before (done) ->
			@timeout 600000
			systemTestRoutes.getOrCreateACASBobInternal (status, output) =>
				@status = status
				@output = output
				global.cleanup.acasBob = output.created
				@createdBob = output.created
				done()
		it "should not return an error", ->
			assert(!@output.hasError)
		it "should return bob", ->
			assert(@output.messages.userName == "bob" | @output.messages.username == "bob")

	describe "get or create global project", =>
		before (done) ->
			@timeout 600000
			systemTestRoutes.getOrCreateGlobalProjectInternal (status, output) =>
				@status = status
				@output = output
				global.cleanup.globalProject = output.created
				done()
		it "should not return an error", ->
			assert(!@output.hasError)
		it "should return global project", ->
			assert(@output.messages.name == "Global" | @output.messages.lsType == "project")

	describe "get or create global project role", =>
		before (done) ->
			@timeout 600000
			systemTestRoutes.getOrCreateGlobalProjectRoleInternal (status, output) =>
				@status = status
				@output = output
				global.cleanup.globalProjectRole = output.created
				done()
		it "should not return an error", ->
			assert(!@output.hasError)
		it "should return global project role", ->
			exists = _.findWhere @output.messages, (role) ->
				role.roleEntry.lsType == "Project" && role.roleEntry.roleName "User"
			assert(exists?)

	describe "give bob roles", =>
		before (done) ->
			@timeout 600000
			systemTestRoutes.giveBobRolesInternal (status, output) =>
				@status = status
				@output = output
				done()
		it "should not return an error", ->
			assert(!@output.hasError)
		it "should return a status of 201", ->
			assert.equal(@status, 201)

	describe "get or create cmpdreg bob", =>
		before (done) ->
			@timeout 600000
			systemTestRoutes.getOrCreateCmpdRegBobInternal (status, output) =>
				@status = status
				@output = output
				global.cleanup.cmpdRegBob = output.created
				done()
		it "should not return an error", ->
			assert(!@output.hasError)
#		it "should return bob", ->
#			assert.equal(@output.messages.code,"bob")

	describe "should sync roles", =>
		before (done) ->
			@timeout 600000
			systemTestRoutes.syncRolesInternal (status, output) =>
				@status = status
				@output = output
				done()
		it "should not return an error", ->
			assert(!@output.hasError)
		it "should sync roles", ->
			assert(@output.messages.indexOf("Successfully") == 0)

	describe "get or create cmpdsreg", =>
		before (done) ->
			@timeout 600000
			systemTestRoutes.getOrCreateCmpdsInternal (status, output) =>
				@status = status
				@output = output
				done()
		it "should not return an error", ->
			assert(!@output.hasError)
		it "should return 50 cmpds registered", ->
			assert(@output.messages.indexOf("50 new compounds registered") != -1)
			if @output.messages.indexOf("50 new compounds registered") != -1
				global.cleanup.cmpds = true

	describe "loadsel file", =>
		before (done) ->
			@timeout 600000
			systemTestRoutes.loadSELFileInternal "bob", (status, output) =>
				@status = status
				@output = output
				done()
		it "should not return an error", ->
			assert(!@output.hasError)
		it "should return Upload completed", ->
			assert(@output.results.htmlSummary.indexOf("Upload completed.") != -1)
			if @output.results.htmlSummary.indexOf("Upload completed.") != -1
				global.cleanup.sel = true

	describe "check result viewers", =>
		describe "check live design", =>
			if "LiveDesign" not in config.all.client.service.result.viewer.configuredViewers.split(',')
				@.pending = true
			describe "install live design python client", ->
				before (done) ->
					@timeout 600000
					systemTestRoutes.installLiveDesignPythonClientInternal (status, output) =>
						@status = status
						@output = output
						done()
				it "should not return an error", ->
					assert(!@output.hasError)
				it "Successfully installed ldclient", ->
					assert(@output.messages.indexOf("Successfully installed") != -1)
			describe "check live design sel report", =>
				before (done) ->
					waitToStart = 60000
					repeat = 10
					timeBeforeAttempts = 20000
					timeout = waitToStart+(repeat*timeBeforeAttempts)
					console.log "waiting #{waitToStart} milliseconds before test, to give DI enough time to run"
					@timeout timeout
					i=1
					myLoop = =>
						console.log "attempting test #{i} of #{repeat}"
						clearTimeout timer
						console.log timer
						systemTestRoutes.checkDataViewerInternal (status, output) =>
							console.log "returned from check with #{JSON.stringify(output)}"
							@status = status
							@output = output
							if output.messages? && _.isEmpty output.messages
								clearTimeout timer
								done()
							else
								i++
								if i < repeat
									setTimeout myLoop, timeBeforeAttempts
								else
									clearTimeout timer
									done()
								return
					timer = setTimeout myLoop, waitToStart
				it "should not return an error", ->
					assert(!@output.hasError)
				it "should return no diffs", ->
#					fs.writeFile "/home/runner/acas/modules/SystemTest/src/server/assets/misc/SystemTestLiveReportContentNew.csv", @newLiveReportContent, (erro) ->
#						console.log erro
#					fs.writeFile "/home/runner/acas/modules/SystemTest/src/server/assets/misc/SystemTestLiveReportContentOld.csv", @oldLiveReportContent, (erro) ->
#						console.log erro
					assert(_.isEmpty(@output.messages))

	describe "delete sel file", =>
		before (done) ->
			@timeout 600000
			@timeout 600000
			if !global.cleanup.sel
				@.skip()
			else
				systemTestRoutes.deleteSELFileInternal (status, output) =>
					@status = status
					@output = output
					done()
		it "should not return an error", ->
			assert(!@output.hasError)
		it "should return a protocol", ->
			assert(@output.messages.protocol?)
		it "should return an experiment", ->
			assert(@output.messages.experiment?)

	describe "purge cmpds", =>
		before (done) ->
			@timeout 600000
			if !global.cleanup.cmpds
				@.skip()
			else
				systemTestRoutes.purgeCmpdsInternal (status, output) =>
					@status = status
					@output = output
					done()
		it "should not return an error", ->
			assert(!@output.hasError)
		it "should return 50 parent compounds were deleted", ->
			assert(@output.messages.summary.indexOf("50 parent compounds were deleted") != -1)
		it "should return 50 compound lots were deleted", ->
			assert(@output.messages.summary.indexOf("50 compound lots were deleted") != -1)

	describe "delete global project", =>
		before (done) ->
			@timeout 600000
			if !global.cleanup.globalProject
				@.skip()
			else
				systemTestRoutes.deleteGlobalProject (status, output) =>
					@status = status
					@output = output
					done()
		it "should not return an error", ->
			assert(!@output.hasError)
		it "should return status 200", ->
			assert.equal(@status,200)
		it "should return no output", ->
			assert(!@output.messages?)

	describe "delete cmpd reg bob", =>
		before (done) ->
			@timeout 600000
			if !global.cleanup.cmpdRegBob
				@.skip()
			else
				systemTestRoutes.deleteCmpdRegBobInternal (status, output) =>
					@status = status
					@output = output
					done()
		it "should not return an error", ->
			assert(!@output.hasError)
		it "should return status 200", ->
			assert.equal(@status,200)
		it "should return no output", ->
			assert(!@output.messages?)

	describe "delete acas bob", =>
		before (done) ->
			@timeout 600000
			if !global.cleanup.acasBob
				@.skip()
			else
				systemTestRoutes.deleteACASBobInternal (status, output) =>
					@status = status
					@output = output
					done()
		it "should not return an error", ->
			assert(!@output.hasError)
		it "should return status 200", ->
			assert.equal(@status,200)
		it "should return no output", ->
			assert(!@output.messages?)

