assert = require 'assert'
request = require 'request'
_ = require 'underscore'
fs = require 'fs'
acasHome = '../../../..'
config = require "#{acasHome}/conf/compiled/conf.js"
thingServiceTestJSON = require "#{acasHome}/public/javascripts/spec/ServerAPI/testFixtures/ThingServiceTestJSON.js"
servUtilities = require "#{acasHome}/routes/ServerUtilityFunctions.js"


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
				@fileVals = servUtilities.getFileValuesFromEntity thingServiceTestJSON.thingParent
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
				assert.equal servUtilities.getPrefixFromEntityCode("PROT00000123"), "PROT"
			it "should return the pt prefix from a parent thing code", ->
				assert.equal servUtilities.getPrefixFromEntityCode("PT00000123"), "PT"
			it "should return the expt prefix from an experiment code", ->
				assert.equal servUtilities.getPrefixFromEntityCode("EXPT00000123"), "EXPT"
			it "should return null with bad code", ->
				assert.equal servUtilities.getPrefixFromEntityCode("FRED0001343"), null

	describe "Create a new lsTransaction", ->
		before (done) ->
			comments = "test transaction"
			date = 1427414400000
			servUtilities.createLSTransaction date, comments, (transaction) =>
				@newTransaction = transaction
				console.log @newTransaction
				done()
		it "should return a transaction with an id", ->
			assert.equal isNaN(parseInt(@newTransaction.id)), false

	describe "add transaction to ls entity", ->
		protocolServiceTestJSON = require "#{acasHome}/public/javascripts/spec/ServerAPI/testFixtures/ProtocolServiceTestJSON.js"

		before (done) ->
			trans =
				comments: 'test transaction'
				id: 8354
				recordedDate: 1427414400000
				version: 0
			ent = JSON.parse(JSON.stringify(protocolServiceTestJSON.protocolToSave))
			@modEnt = servUtilities.insertTransactionIntoEntity trans.id, ent
			done()
		it "should have a trans at the top level", ->
			assert.equal @modEnt.lsTransaction, 8354
		it "should have a trans in the labels", ->
			assert.equal @modEnt.lsLabels[0].lsTransaction, 8354
		it "should have a trans in the states", ->
			assert.equal @modEnt.lsStates[0].lsTransaction, 8354
		it "should have a trans in the values", ->
			assert.equal @modEnt.lsStates[0].lsValues[0].lsTransaction, 8354


