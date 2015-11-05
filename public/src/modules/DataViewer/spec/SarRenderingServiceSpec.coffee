# preferredEntityCodeServiceSpec.coffee
#
#
# Kaitlyn Dwelle
# kaitlyn.dwelle@gmail.com
#
#
# Copyright 2015 John McNeil & Co. Inc.
#########################################################################
# Spec for a service which sar uses to render information about a tested
# entity.
#
# each service should be a get route which has the referenceCode as the
# last portion of the route: e.g. /api/sarRender/geneId/{referenceCode}
#
# the service should return html which will be rendered as the leftmost
# column in the report.
#########################################################################
assert = require 'assert'
request = require 'request'
_ = require 'underscore'

parseResponse = (jsonStr) ->
	try
		return JSON.parse jsonStr
	catch error
		console.log "response unparsable: " + error
		console.log "response: "+ jsonStr
		return null

config = require '../../../conf/compiled/conf.js'

####################################################################
#   Gene ID
#
# To be consistent with geneIDQuery, this simply returns the gene ID
# (bestLabel) centered in a paragraph tag.
####################################################################
describe "SAR rendering service for Gene ID's", ->
	describe "when called with a valid ID", ->
		before (done) ->
			validCode = "GENE-000003"
			request "http://192.168.99.100:"+config.all.server.nodeapi.port+"/api/sarRender/geneId/"+validCode, (error, response, body) =>
				console.log "body is "+ body
				console.log "response is "+ response
				@responseJSON = parseResponse(body)
				done()
		it "should return entity type descriptions with required attributes", ->
			assert.equal @responseJSON.html, '<p align="center">2</p>'

####################################################################
#   Corporate Batch ID
#
# Since compound reg has an image of the structure, returns the image
# in image tags and the batch code centered in paragraph tags
####################################################################
describe "SAR rendering service for Corporate Batch ID's", ->
	describe "when called with a valid ID", ->
		before (done) ->
			validCode = "CMPD-0000011-01A"
			request "http://192.168.99.100:"+config.all.server.nodeapi.port+"/api/sarRender/cmpdRegBatch/"+validCode, (error, response, body) =>
				console.log "body is "+ body
				console.log "response is "+ response
				@responseJSON = parseResponse(body)
				done()
		it "should return entity type descriptions with required attributes", ->
			assert.equal @responseJSON.html, "<img src=\"http://host4.labsynch.com:8080/cmpdreg/structureimage/lot/CMPD-0000011-01A\"> <p align=\"center\">CMPD-0000011-01A</p>"

####################################################################
#   Get Title
####################################################################
describe "SAR service to fetch column title", ->
	describe "when called with Gene ID", ->
		before (done) ->
			request "http://192.168.99.100:"+config.all.server.nodeapi.port+"/api/sarRender/title/Gene%20ID", (error, response, body) =>
				@responseJSON = parseResponse(body)
				done()
		it "should return 'Gene ID' ", ->
			assert.equal @responseJSON.title, "Gene ID"
	describe "when called with Corporate Batch ID", ->
		before (done) ->
			request "http://192.168.99.100:"+config.all.server.nodeapi.port+"/api/sarRender/title/Corporate%20Batch%20ID", (error, response, body) =>
				@responseJSON = parseResponse(body)
				done()
		it "should return 'Compound Information'", ->
			assert.equal @responseJSON.title, "Compound Information"


####################################################################
#   Generic html Service
# input: {
#         displayName: (optional)
#         referenceCode:
#        }
#
# output: {
#         html:
#         }
#
# If a displayName is provided, simply calls the get route provided in
# the config (SarRenderConf) and gets the html
#
# If no displayName is provided, uses api/entityMeta/searchForEntities
# to find the displayName and then calls the appropriate route
# (takes longer because of searchForEntities call)
####################################################################
describe "SAR generic rendering service", ->
	describe "when provided the displayName", ->
		describe "for Gene ID", ->
			body =
				displayName: "Gene ID"
				referenceCode: "GENE-000003"
			console.log config.all.server.nodeapi.path + "/api/sarRender/render"
			console.log JSON.stringify(body)
			before (done) ->
				@.timeout(20000)
				request.post
					url: config.all.server.nodeapi.path + "/api/sarRender/render"
					json: true
					body: body
				, (error, response, body) =>
					@responseJSON = body
					console.log @responseJSON
					done()
			it "should return entity type descriptions with required attributes", ->
				assert.equal @responseJSON.html, '<p align="center">2</p>'
		describe "for Corporate Batch ID", ->
			body =
				displayName: "Corporate Batch ID"
				referenceCode: "CMPD-0000011-01A"
			before (done) ->
				@.timeout(20000)
				request.post
					url: config.all.server.nodeapi.path + "/api/sarRender/render"
					json: true
					body: body
				, (error, response, body) =>
					@responseJSON = body
					console.log @responseJSON
					done()
			it "should return entity type descriptions with required attributes", ->
				assert.equal @responseJSON.html, "<img src=\"http://host4.labsynch.com:8080/cmpdreg/structureimage/lot/CMPD-0000011-01A\"> <p align=\"center\">CMPD-0000011-01A</p>"
	describe "when not provided the displayName", ->
		describe "for Gene ID", ->
			body =
				referenceCode: "GENE-000003"
			before (done) ->
				@.timeout(20000)
				request.post
					url: config.all.server.nodeapi.path + "/api/sarRender/render"
					json: true
					body: body
				, (error, response, body) =>
					@responseJSON = body
					console.log @responseJSON
					done()
			it "should return entity type descriptions with required attributes", ->
				assert.equal @responseJSON.html, '<p align="center">2</p>'
		describe "for Corporate Batch ID", ->
			body =
				referenceCode: "CMPD-0000011-01A"
			before (done) ->
				@.timeout(20000)
				request.post
					url: config.all.server.nodeapi.path + "/api/sarRender/render"
					json: true
					body: body
				, (error, response, body) =>
					@responseJSON = body
					console.log @responseJSON
					done()
			it "should return entity type descriptions with required attributes", ->
				assert.equal @responseJSON.html, "<img src=\"http://host4.labsynch.com:8080/cmpdreg/structureimage/lot/CMPD-0000011-01A\"> <p align=\"center\">CMPD-0000011-01A</p>"
