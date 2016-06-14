assert = require 'assert'
request = require 'request'
_ = require 'underscore'
acasHome = '../../../..'
inventoryServiceTestJSON = require "#{acasHome}/public/javascripts/spec/ServerAPI/testFixtures/InventoryServiceTestJSON.js"

fs = require 'fs'
config = require "#{acasHome}/conf/compiled/conf.js"


getOrCreateContainer = (container, callback) ->
	label = container.lsLabels[0].labelText
	request.post
		url: "http://localhost:"+config.all.server.nodeapi.port+"/api/getContainersByLabels?containerType=#{container.lsType}&containerKind=#{container.lsKind}"
		json: true
		body: [label]
	, (error, response, body) =>
		if !body[0].codeName?
			request.post
				url: "http://localhost:"+config.all.server.nodeapi.port+"/api/containers"
				json: true
				body: container
			, (error, response, body) =>
				console.log "      ✓ registered container lsType:'#{body.lsType}' lsKind:'#{body.lsKind}' labelText:'#{body.lsLabels[0].labelText}'"
				callback body
		else
#			console.log "      ✓ alredy registered container lsType:'#{body[0].container.lsType}' lsKind:'#{body[0].container.lsKind}' labelText:'#{body[0].container.lsLabels[0].labelText}'"
			callback body[0].container
describe "Inventory Service testing", ->
	before (done) =>
		@definitionContainersRequest = _.flatten inventoryServiceTestJSON.definitionContainers
		@definitionContainers = []
		@definitionContainersRequest.forEach (definitionContainer) =>
			getOrCreateContainer definitionContainer, (response) =>
				@definitionContainers.push response
				if @definitionContainers.length == @definitionContainersRequest.length
					done()
	describe "Get or create definition containers (load_definition_containers)", =>
		it "should return definition containers", =>
			assert.equal @definitionContainers.length, @definitionContainersRequest.length
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
