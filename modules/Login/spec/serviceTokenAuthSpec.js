const assert = require('chai').assert;
const crypto = require('crypto');
const jwt = require('jsonwebtoken');
const sta = require('../src/server/routes/ServiceTokenAuth.js');

const { privateKey, publicKey } = crypto.generateKeyPairSync('rsa', {
  modulusLength: 2048,
  publicKeyEncoding: { type: 'spki', format: 'pem' },
  privateKeyEncoding: { type: 'pkcs8', format: 'pem' },
});
const OPTS = { issuers: ['trusted-issuer'], audience: 'acas', clockSkewSec: 30 };

function sign(claims, over) {
  return jwt.sign(claims, privateKey, Object.assign(
    { algorithm: 'RS256', issuer: 'trusted-issuer', audience: 'acas', expiresIn: '60s' }, over));
}

describe('ServiceTokenAuth.verifyWithKey', function () {
  it('accepts a valid token and returns claims', function (done) {
    sta.verifyWithKey(sign({ user_email: 'u@example.com' }), publicKey, OPTS, (err, claims) => {
      assert.isNull(err); assert.equal(claims.user_email, 'u@example.com'); done();
    });
  });
  it('rejects a wrong audience', function (done) {
    sta.verifyWithKey(sign({}, { audience: 'other' }), publicKey, OPTS, (err) => { assert.isNotNull(err); done(); });
  });
  it('rejects an untrusted issuer', function (done) {
    sta.verifyWithKey(sign({}, { issuer: 'evil' }), publicKey, OPTS, (err) => { assert.isNotNull(err); done(); });
  });
  it('rejects an expired token', function (done) {
    sta.verifyWithKey(sign({}, { expiresIn: '-60s' }), publicKey, OPTS, (err) => { assert.isNotNull(err); done(); });
  });
  it('rejects a bad signature', function (done) {
    const other = crypto.generateKeyPairSync('rsa', {
      modulusLength: 2048,
      privateKeyEncoding: { type: 'pkcs8', format: 'pem' },
      publicKeyEncoding: { type: 'spki', format: 'pem' },
    });
    const bad = jwt.sign({}, other.privateKey,
      { algorithm: 'RS256', issuer: 'trusted-issuer', audience: 'acas', expiresIn: '60s' });
    sta.verifyWithKey(bad, publicKey, OPTS, (err) => { assert.isNotNull(err); done(); });
  });
});
