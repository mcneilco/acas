assert = require 'assert'
request = require 'request'
_ = require 'underscore'
inventoryServiceTestJSON = require '../testFixtures/InventoryServiceTestJSON.js'
fs = require 'fs'
config = require '../../../../conf/compiled/conf.js'

describe "Inventory Service testing", ->
	describe "Get containers in location", ->
		before (done) ->
			@.timeout(20000)
			request.post
				url: "http://localhost:"+config.all.server.nodeapi.port+"/api/getContainersInLocation"
				json: true
				body: ['CONT-00001']
			, (error, response, body) =>
				@serverError = error
				@responseJSON = body
				done()
		it "should return a list of containers", ->
			assert.equal @responseJSON.length > 2, true
			assert.equal @responseJSON[0].containerBarcode, 'C1143030'
			assert.equal @responseJSON[1].containerBarcode, 'C1142830'
	describe "Get containers by code name", ->
		before (done) ->
			@.timeout(20000)
			request.post
				url: "http://localhost:"+config.all.server.nodeapi.port+"/api/getContainersByCodeName"
				json: true
				body: ['CONT-00001']
			, (error, response, body) =>
				@serverError = error
				@responseJSON = body
				done()
		it "should return a list of containers", ->
			assert.equal @responseJSON.test
