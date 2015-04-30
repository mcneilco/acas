(function() {
  var assert, config, fs, labelServiceTestJSON, parseResponse, request, _;

  assert = require('assert');

  request = require('request');

  _ = require('underscore');

  labelServiceTestJSON = require('../testFixtures/LabelServiceTestJSON.js');

  fs = require('fs');

  config = require('../../../../conf/compiled/conf.js');

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

  describe("Label Service testing", function() {
    return describe("Get next label sequence", function() {
      before(function(done) {
        this.timeout(20000);
        return request.post({
          url: "http://localhost:" + config.all.server.nodeapi.port + "/api/getNextLabelSequence",
          json: true,
          body: labelServiceTestJSON.nextLabelSequenceRequest
        }, (function(_this) {
          return function(error, response, body) {
            _this.serverError = error;
            _this.responseJSON = body;
            return done();
          };
        })(this));
      });
      return it("should have the latest number for the label sequence", function() {
        return assert.equal(this.responseJSON.latestNumber === 1163, true);
      });
    });
  });

}).call(this);
