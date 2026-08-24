const assert = require('chai').assert;
const loginRoutes = require('../../../build/routes/loginRoutes.js');

describe('service-token identity claims', function () {
  it('uses the standard JWT subject before legacy email claims', function () {
    assert.equal(
      loginRoutes.getServiceTokenEmail({
        sub: 'subject@example.com',
        user_email: 'legacy@example.com',
      }),
      'subject@example.com'
    );
  });

  it('retains legacy email claim fallbacks', function () {
    assert.equal(loginRoutes.getServiceTokenEmail({user_email: 'legacy@example.com'}), 'legacy@example.com');
    assert.equal(loginRoutes.getServiceTokenEmail({email: 'email@example.com'}), 'email@example.com');
  });
});
