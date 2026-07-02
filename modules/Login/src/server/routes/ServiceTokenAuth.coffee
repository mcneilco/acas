# modules/Login/src/server/ServiceTokenAuth.coffee
jwt = require 'jsonwebtoken'
jwksClient = require 'jwks-rsa'

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
	client = jwksClient jwksUri: config.jwksUrl, cache: true, rateLimit: true
	client.getSigningKey decoded.header.kid, (err, key) ->
		return cb(err) if err
		pem = key.getPublicKey()
		opts =
			issuers: config.trustedIssuers
			audience: config.audience
			clockSkewSec: config.clockSkewSec
		exports.verifyWithKey token, pem, opts, cb
