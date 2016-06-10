assert = require 'assert'
request = require 'request'
_ = require 'underscore'
inventoryServiceTestJSON = require '../../../../public/javascripts/spec/ServerAPI/testFixtures/InventoryServiceTestJSON.js'
fs = require 'fs'
config = require '../../../../conf/compiled/conf.js'

describe "Inventory Service testing", ->
	describe "Post Container (load_definition_containers)", ->
		before (done) ->
			i = 0
			@responses = []
			@definitionContainers = _.flatten inventoryServiceTestJSON.definitionContainers
			for container in @definitionContainers
				request.post
					url: "http://localhost:"+config.all.server.nodeapi.port+"/api/containers"
					json: true
					body: container
				, (error, response, body) =>
					i = i+1
					@responses.push body
					if i == @definitionContainers.length
						done()
		it "should return a container", ->
			assert.equal @responses.length == @definitionContainers.length, true
			_.map @responses, (response) ->
				if response.codeName?
					console.log "      ✓ successfully registered container lsType:'#{response.lsType}' lsKind:'#{response.lsKind}' labelText:'#{response.lsLabels[0].labelText}'"
				assert.equal true, response.codeName?
	describe "Container_Logs", ->
		before (done) ->
			@postToLogService = (containerCode, callback) =>
				containerLogExample = inventoryServiceTestJSON.containerLog
				containerLog = _.map containerLogExample, (logEntry) ->
					logEntry.codeName = containerCode
					logEntry
				@containerLog = containerLog
				request.post
					url: "http://localhost:"+config.all.server.nodeapi.port+"/api/containerLogs"
					json: true
					body: containerLog
				, (error, response, body) =>
					callback response.statusCode, body
			container = inventoryServiceTestJSON.vial
			request.post
				url: "http://localhost:"+config.all.server.nodeapi.port+"/api/containers"
				json: true
				body: container
			, (error, response, body) =>
					if body.codeName?
						@body = body
						console.log "      ✓ successfully registered container lsType:'#{@body.lsType}' lsKind:'#{@body.lsKind}' labelText:'#{@body.lsLabels[0].labelText}'"
						@postToLogService body.codeName, (statusCode, response) =>
							@statusCode = statusCode
							@response = response
							done()
					else
						console.error "error saving vial, service did not return a code name, got:"
						console.error @body
						done()
		it "should return correct status code when posting good log json", ->
			assert.equal 200, @statusCode
		it "should return the containers specified in the log json", ->
			codeNames = _.pluck @response, "codeName"
			assert.equal codeNames, @body.codeName
		it "should return with log states", ->
			logStates = _.where @response[0].lsStates, {lsType:'metadata',lsKind:'log'}
			assert.equal logStates.length, @containerLog.length
		it "should return log states with values that one value of kind entry type and one value of kind entry", ->
			logStates = _.where @response[0].lsStates, {lsType:'metadata',lsKind:'log'}
			_.map logStates, (logState) ->
				entryType = _.where logState.lsValues, {lsType:'codeValue',lsKind:'entry type'}
				assert.equal entryType.length, 1
				entry = _.where logState.lsValues, {lsType:'clobValue',lsKind:'entry'}
				assert.equal entry.length, 1















#describe "Inventory Service testing", ->
#	describe "Get containers in location", ->
#		before (done) ->
#			@.timeout(20000)
#			request.post
#				url: "http://localhost:"+config.all.server.nodeapi.port+"/api/getContainersInLocation"
#				json: true
#				body: ['CONT-00001']
#			, (error, response, body) =>
#				@serverError = error
#				@responseJSON = body
#				done()
#		it "should return a list of containers", ->
#			assert.equal @responseJSON.length > 2, true
#			assert.equal @responseJSON[0].containerBarcode, 'C1100304'
#			assert.equal @responseJSON[1].containerBarcode, 'C1100304'
#	describe "Get containers by code name", ->
#		before (done) ->
#			@.timeout(20000)
#			request.post
#				url: "http://localhost:"+config.all.server.nodeapi.port+"/api/getContainersByCodeName"
#				json: true
#				body: ['CONT-00001']
#			, (error, response, body) =>
#				@serverError = error
#				@responseJSON = body
#				done()
#		it "should return a list of containers", ->
#			assert.equal @responseJSON.test
