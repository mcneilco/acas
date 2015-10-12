(function() {
  var assert, config, parseResponse, request;

  assert = require('assert');

  request = require('request');

  config = require('../.././compiled/conf.js');

  parseResponse = function(jsonStr) {
    var error;
    try {
      return JSON.parse(jsonStr);
    } catch (_error) {
      error = _error;
      console.log("response unparsable: " + error);
      return null;
    }
  };

  describe("Primary Screen Protocol Routes testing", function() {
    describe("Using customer code tables", function() {
      before(function(done) {
        return request("http://localhost:" + config.all.server.nodeapi.port + "/api/customerMolecularTargetCodeTable", (function(_this) {
          return function(error, response, body) {
            console.log("after request sent");
            _this.responseJSON = parseResponse(body);
            return done();
          };
        })(this));
      });
      it("should return an array of codes", function() {
        return assert.equal(this.responseJSON instanceof Array, true);
      });
      it('should have elements that be a hash with code defined', function() {
        return assert.equal(this.responseJSON[0].code != null, true);
      });
      return it('should have elements that be a hash with name defined', function() {
        return assert.equal(this.responseJSON[0].name != null, true);
      });
    });
    return describe("Clone validation", function() {
      return describe("valid clone name", function() {
        before(function(done) {
          return request("http://localhost:" + config.all.server.nodeapi.port + "/api/cloneValidation/test", (function(_this) {
            return function(error, response, body) {
              console.log("after request sent");
              _this.responseJSON = parseResponse(body);
              return done();
            };
          })(this));
        });
        it("should return an array", function() {
          return assert.equal(this.responseJSON instanceof Array, true);
        });
        return it('should return a json with the crystal target code', function() {
          return assert.equal(this.responseJSON[0], "test1");
        });
      });
    });
  });

}).call(this);
