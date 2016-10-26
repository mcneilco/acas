if (!chai)
  var chai = require('../../index.js');

var expect = chai.expect;

chai.Assertion.includeStack = true;

suite('error display', function () {

  test('show error line', function () {
    expect(4).to.equal(2);
  });

});
