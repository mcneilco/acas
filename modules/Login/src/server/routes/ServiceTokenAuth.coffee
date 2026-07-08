# modules/Login/src/server/routes/ServiceTokenAuth.coffee
jwt = require 'jsonwebtoken'
jwksClient = require 'jwks-rsa'

# One jwks-rsa client per JWKS URL, cached at module scope. jwks-rsa's key
# cache lives on the client instance, so building a fresh client per request
# would defeat it and re-fetch the JWKS on every call. The URL comes from
# static config, so a small per-URL map is sufficient (and rotation-safe).
_clients = {}

_getClient = (jwksUrl) ->
	_clients[jwksUrl] ?= jwksClient
		jwksUri: jwksUrl
		cache: true
		rateLimit: true
	_clients[jwksUrl]

# Pure verification given a PEM public key. No IO — unit testable.
exports.verifyWithKey = (token, publicKeyPem, opts, cb) ->
	options =
		algorithms: ['RS256']
		issuer: opts.issuers
		audience: opts.audience
		clockTolerance: opts.clockSkewSec or 30
	jwt.verify token, publicKeyPem, options, (err, claims) ->
		return cb(err) if err
		cb null, claims

# Full path: read kid from the token header, fetch the signing key, verify.
exports.authenticate = (token, config, cb) ->
	decoded = jwt.decode token, complete: true
	return cb(new Error('malformed token')) unless decoded?.header?.kid
	client = _getClient(config.jwksUrl)
	client.getSigningKey decoded.header.kid, (err, key) ->
		return cb(err) if err
		pem = key.getPublicKey()
		opts =
			issuers: config.trustedIssuers
			audience: config.audience
			clockSkewSec: config.clockSkewSec
		exports.verifyWithKey token, pem, opts, cb
