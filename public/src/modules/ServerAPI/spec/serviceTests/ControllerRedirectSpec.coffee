assert = require 'assert'
request = require 'request'
fs = require 'fs'


config = require '../../../../conf/compiled/conf.js'
describe "Controller Redirect service testing", ->
	describe "protocol redirect", ->
		describe "When user enters in generic protocol", ->
			before (done) ->
				request "http://localhost:"+config.all.server.nodeapi.port+"/entity/edit/codeName/PROT-generic", (error, response, body) =>
					@responseJSON = body
					@response = response
					done()
			it "should return redirect", ->
				assert.equal @response.request.uri.href.indexOf('protocol_base')>0, true
		describe "When user enters a screening protocol", ->
			before (done) ->
				request "http://localhost:"+config.all.server.nodeapi.port+"/entity/edit/codeName/PROT-screening", (error, response, body) =>
					@responseJSON = body
					@response = response
					done()
			it "should return redirect", ->
				assert.equal @response.request.uri.href.indexOf('primary_screen_protocol')>0, true
		describe "When user enters a not special protocol", ->
			before (done) ->
				request "http://localhost:"+config.all.server.nodeapi.port+"/entity/edit/codeName/PROT-random", (error, response, body) =>
					@responseJSON = body
					@response = response
					done()
			it "should return redirect", ->
				assert.equal @response.request.uri.href.indexOf('protocol_base')>0, true

	describe "experiment redirect", ->
		console.log "yay"
		describe "When user enters in generic experiment", ->
			before (done) ->
				request "http://localhost:"+config.all.server.nodeapi.port+"/entity/edit/codeName/EXPT-generic", (error, response, body) =>
					@responseJSON = body
					@response = response
					done()
			it "should return redirect", ->
				assert.equal @response.request.uri.href.indexOf('experiment_base')>0, true
		describe "When user enters a screening experiment", ->
			before (done) ->
				request "http://localhost:"+config.all.server.nodeapi.port+"/entity/edit/codeName/EXPT-screening", (error, response, body) =>
					@responseJSON = body
					@response = response
					done()
			it "should return redirect", ->
				assert.equal @response.request.uri.href.indexOf('primary_screen_experiment')>0, true
		describe "When user enters a not special protocol", ->
			before (done) ->
				request "http://localhost:"+config.all.server.nodeapi.port+"/entity/edit/codeName/EXPT-random", (error, response, body) =>
					@responseJSON = body
					@response = response
					done()
			it "should return redirect", ->
				assert.equal @response.request.uri.href.indexOf('experiment_base')>0, true

	describe "entity type redirect", ->
		describe "when entity is EXPT ", ->
			before (done) ->
#				@timeout(20000)
				request "http://localhost:"+config.all.server.nodeapi.port+"/entity/edit/codeName/EXPT-random", (error, response, body) =>
					@responseJSON = body
					@response = response
					done()
			it "should redirect to an experiment", ->
				assert.equal @response.request.uri.href.indexOf('experiment')>0, true

		describe "when entity is PROT", ->
			before (done) ->
				request "http://localhost:"+config.all.server.nodeapi.port+"/entity/edit/codeName/PROT-random", (error, response, body) =>
					@responseJSON = body
					@response = response
					done()
			it "should redirect to a  protocol", ->
				assert.equal @response.request.uri.href.indexOf('protocol')>0, true

		describe "when user enters entity that doesn't exist", ->
			before (done) ->
				request "http://localhost:"+config.all.server.nodeapi.port+"/entity/edit/codeName/XXX-random", (error, response, body) =>
					@responseJSON = body
					@response = response
					done()
			it "should redirect to the home page", ->
				assert.equal @response.request.uri.href.indexOf('protocol')<0, true
				assert.equal @response.request.uri.href.indexOf('experiment')<0, true
				assert.equal @response.request.uri.href, "http://localhost:"+config.all.server.nodeapi.port+"/#"
