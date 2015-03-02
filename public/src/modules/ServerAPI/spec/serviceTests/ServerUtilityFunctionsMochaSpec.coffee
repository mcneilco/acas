assert = require 'assert'
request = require 'request'
_ = require 'underscore'
fs = require 'fs'
config = require '../../../../conf/compiled/conf.js'
servUtilities = require '../../../../routes/ServerUtilityFunctions.js'
thingServiceTestJSON = require '../../../../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js'

parseResponse = (jsonStr) ->
	try
		return JSON.parse jsonStr
	catch error
		console.log "response unparsable: " + error
		return null


describe "Server Utiilty Function Tests", ->
	describe "File Value filtering", ->
		describe "get fileValues from thing", ->
			before (done) ->
				@fileVals = servUtilities.getFileValesFromThing thingServiceTestJSON.thingParent
				done()
			it "should return an array", ->
				assert.equal (@fileVals.length > 0), true
			it "all the values should be type fileValue and not ignored", ->
				#require testJSON to have 3 fileValues, one ignored
				assert.equal @fileVals.length, 2
	describe "Entity attribute from ControllerRedirect.conf functions", ->
		describe "get file path for entity prefix", ->
			it "should return the relative path for PROT", ->
				assert.equal servUtilities.getRelativeFolderPathForPrefix("PROT"), "protocols/"
			it "should return the relative path for PT", ->
				assert.equal servUtilities.getRelativeFolderPathForPrefix("PT"), "entities/parentThings/"
			it "should return null with bad prefix", ->
				assert.equal servUtilities.getRelativeFolderPathForPrefix("fred"), null
		describe "get prefix from code", ->
			it "should return the prot prefix from a prot code", ->
				assert.equal servUtilities.getPrefixFromThingCode("PROT00000123"), "PROT"
			it "should return the pt prefix from a parent thing code", ->
				assert.equal servUtilities.getPrefixFromThingCode("PT00000123"), "PT"
			it "should return the expt prefix from an experiment code", ->
				assert.equal servUtilities.getPrefixFromThingCode("EXPT00000123"), "EXPT"
			it "should return null with bad code", ->
				assert.equal servUtilities.getPrefixFromThingCode("FRED0001343"), null
