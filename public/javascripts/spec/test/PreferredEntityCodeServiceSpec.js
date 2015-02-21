(function() {
  var assert, config, fs, parseResponse, request;

  assert = require('assert');

  request = require('request');

  fs = require('fs');

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

  config = require('../../../../conf/compiled/conf.js');

  describe("Preferred Entity code service tests", function() {
    this.requestData = {
      requests: [
        {
          requestName: "norm_1234:1"
        }, {
          requestName: "alias_1111:1"
        }, {
          requestName: "none_2222:1"
        }
      ]
    };
    this.expectedResponse = {
      error: false,
      errorMessages: [],
      results: [
        {
          requestName: "norm_1234:1",
          preferredName: "norm_1234:1"
        }, {
          requestName: "alias_1111:1",
          preferredName: "norm_1111:1A"
        }, {
          requestName: "none_2222:1",
          preferredName: ""
        }
      ]
    };
    return describe.only("available entity list", function() {
      describe("when requested as fully detailed list", function() {
        before(function(done) {
          return request("http://localhost:" + config.all.server.nodeapi.port + "/api/configuredEntityTypes", (function(_this) {
            return function(error, response, body) {
              _this.responseJSON = parseResponse(body);
              return done();
            };
          })(this));
        });
        it("should return an array of entity types", function() {
          return assert.equal(this.responseJSON.length > 0, true);
        });
        return it("should return entity type descriptions with required attributes", function() {
          assert.equal(this.responseJSON[0].type != null, true);
          assert.equal(this.responseJSON[0].kind != null, true);
          assert.equal(this.responseJSON[0].displayName != null, true);
          assert.equal(this.responseJSON[0].codeOrigin != null, true);
          return assert.equal(this.responseJSON[0].sourceExternal != null, true);
        });
      });
      return describe("when requested as list of codes", function() {
        before(function(done) {
          return request("http://localhost:" + config.all.server.nodeapi.port + "/api/configuredEntityTypes?asCodes=true", (function(_this) {
            return function(error, response, body) {
              _this.responseJSON = parseResponse(body);
              return done();
            };
          })(this));
        });
        it("should return an array of entity types", function() {
          return assert.equal(this.responseJSON.length > 0, true);
        });
        return it("should return entity type descriptions with required attributes", function() {
          assert.equal(this.responseJSON[0].code != null, true);
          assert.equal(this.responseJSON[0].name != null, true);
          return assert.equal(this.responseJSON[0].ignored != null, true);
        });
      });
    });
  });

}).call(this);
