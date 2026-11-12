assert = require 'assert'
express = require 'express'
http = require 'http'
passport = require 'passport'
session = require 'express-session'
config = require '../../../../conf/compiled/conf.js'
loginRoutes = require '../../../../routes/loginRoutes.js'
serviceTokenAuth = require '../../../../routes/ServiceTokenAuth.js'
csUtilities = require '../../../../src/javascripts/ServerAPI/CustomerSpecificServerFunctions.js'

request = (port, path, headers = {}) ->
	new Promise (resolve, reject) ->
		req = http.request {
			hostname: '127.0.0.1'
			port: port
			path: path
			method: 'POST'
			headers: headers
		}, (resp) ->
			body = ''
			resp.on 'data', (chunk) -> body += chunk
			resp.on 'end', -> resolve { statusCode: resp.statusCode, headers: resp.headers, body: body }
		req.on 'error', reject
		req.end()

describe 'Token login response', ->
	before ->
		@originalServiceTokenConfig = config.all.server.security.serviceToken
		@originalAuthenticate = serviceTokenAuth.authenticate
		@originalGetUser = csUtilities.getUser
		config.all.server.security.serviceToken =
			use: true
			jwksUrl: 'https://issuer.example/jwks.json'
			trustedIssuers: 'https://issuer.example'
			audience: 'acas'
			clockSkewSec: 30
		serviceTokenAuth.authenticate = (token, verifierConfig, callback) ->
			callback null, user_email: 'token-user@example.com'
		csUtilities.getUser = (email, callback) ->
			callback null,
				username: 'token-user'
				roles: [{ roleEntry: { roleName: 'ROLE_ACAS-USERS' } }]

		authenticator = new passport.Passport()
		authenticator.serializeUser (user, done) -> done null, user.username
		authenticator.deserializeUser (username, done) -> done null, username: username
		@app = express()
		@app.use session secret: 'test-session-secret', resave: false, saveUninitialized: false
		@app.use authenticator.initialize()
		@app.use authenticator.session()
		@app.post '/login/token', loginRoutes.tokenLogin
		@app.post '/authenticated', (req, resp) ->
			if req.isAuthenticated()
				resp.json authenticated: true
			else
				resp.status(401).json authenticated: false
		@server = @app.listen 0

	after (done) ->
		config.all.server.security.serviceToken = @originalServiceTokenConfig
		serviceTokenAuth.authenticate = @originalAuthenticate
		csUtilities.getUser = @originalGetUser
		@server.close done

	it 'does not expose the raw session id and keeps the signed session cookie usable', ->
		port = @server.address().port
		return request(port, '/login/token', authorization: 'Bearer verified-token').then (loginResponse) ->
			assert.equal loginResponse.statusCode, 200
			assert.deepEqual JSON.parse(loginResponse.body),
				expires: null
				user:
					username: 'token-user'
					email: 'token-user@example.com'
			cookie = loginResponse.headers['set-cookie'][0].split(';')[0]
			assert.match cookie, /^connect\.sid=s%3A.+\..+$/
			request(port, '/authenticated', cookie: cookie)
		.then (authenticatedResponse) ->
			assert.equal authenticatedResponse.statusCode, 200
			assert.deepEqual JSON.parse(authenticatedResponse.body), authenticated: true
