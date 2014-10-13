(function() {
  var assert, parseResponse, request;

  assert = require('assert');

  request = require('request');

  parseResponse = function(jsonStr) {
    var error;
    console.log(jsonStr);
    try {
      return JSON.parse(jsonStr);
    } catch (_error) {
      error = _error;
      console.log("response unparsable: " + error);
      return null;
    }
  };

  describe("Primary Screen Protocol Routes testing", function() {
    return describe("Using customer code tables", function() {
      before(function(done) {
        return request("http://imapp01-d:8080/DNS/codes/v1/Codes/SB_Variant_Construct", (function(_this) {
          return function(error, response, body) {
            _this.responseJSON = parseResponse(body);
            return done();
          };
        })(this));
      });
      return it("should return an array of dns codes", function() {
        return assert.equal(this.responseJSON instanceof Array, true);
      });
    });
  });

}).call(this);
