assert = require 'assert'
EventEmitter = require('events').EventEmitter
fs = require 'fs'
Module = require 'module'
path = require 'path'

acasHome = '../../../..'

describe "Standardization Routes", ->
	originalLoad = null
	routePath = null
	fakeUpstream = null
	requestedOptions = null

	loadRoutesWithFakeRequest = ->
		routePath = path.resolve __dirname, "#{acasHome}/routes/StandardizationRoutes.js"
		unless fs.existsSync(routePath)
			routePath = path.resolve process.cwd(), 'modules/Standardization/src/server/routes/StandardizationRoutes.coffee'

		delete require.cache[require.resolve(routePath)] if require.cache[require.resolve(routePath)]?

		originalLoad = Module._load
		Module._load = (request, parent, isMain) ->
			if parent?.filename is routePath and request is './ServerUtilityFunctions.js'
				return {
					requestAdapter: (options) ->
						requestedOptions = options
						fakeUpstream = new FakeUpstream()
						fakeUpstream
				}
			if parent?.filename is routePath and request is '../conf/compiled/conf.js'
				return {
					all:
						client:
							service:
								cmpdReg:
									persistence:
										fullpath: 'http://persistence.example'
				}
			if request is 'underscore'
				return {}
			originalLoad.apply @, arguments

		require routePath

	afterEach ->
		Module._load = originalLoad if originalLoad?
		delete require.cache[require.resolve(routePath)] if routePath? and require.cache[require.resolve(routePath)]?
		originalLoad = null
		routePath = null
		fakeUpstream = null
		requestedOptions = null

	class FakeUpstream extends EventEmitter
		constructor: ->
			super()
			@ended = false
			@pipedDestination = null

		pipe: (destination) ->
			@pipedDestination = destination
			@

		end: ->
			@ended = true
			@emit 'response',
				statusCode: 200
				headers:
					'content-type': 'chemical/x-mdl-sdfile'
					'content-length': '8'
			@emit 'data', Buffer.from('SDF DATA')
			@emit 'end'

	class FakeResponse
		constructor: ->
			@headersSent = false
			@statusCode = null
			@headers = null
			@chunks = []
			@ended = false

		writeHead: (statusCode, headers) ->
			@headersSent = true
			@statusCode = statusCode
			@headers = headers

		write: (chunk) ->
			@chunks.push chunk

		end: (body) ->
			@ended = true
			@chunks.push Buffer.from(body) if body?

	describe "standardizationAutoDryRunReportFile", ->
		it "starts the upstream report stream and forwards the SDF response", ->
			routes = loadRoutesWithFakeRequest()
			req =
				query:
					historyId: '108'
				setTimeout: ->
			resp = new FakeResponse()

			routes.standardizationAutoDryRunReportFile req, resp

			assert fakeUpstream.ended, "upstream report stream should be started"
			assert.equal requestedOptions.method, 'GET'
			assert.equal requestedOptions.url, 'http://persistence.example/standardization/dryRunAutoReportFile?historyId=108'
			assert.equal resp.statusCode, 200
			assert.equal resp.headers['Content-Type'], 'chemical/x-mdl-sdfile'
			assert.equal resp.headers['Content-Disposition'], 'attachment; filename=standardization-dry-run-report-history-108.sdf'
			assert.equal Buffer.concat(resp.chunks).toString(), 'SDF DATA'
			assert resp.ended, "response should be ended when upstream stream ends"
