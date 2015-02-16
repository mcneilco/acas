(function() {
  var assert, config, fs, parseResponse, request, thingTestJSON, _;

  assert = require('assert');

  request = require('request');

  _ = require('underscore');

  thingTestJSON = require('../testFixtures/ThingTestJSON.js');

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

  describe.only("Thing Service testing", function() {
    return describe("Thing CRUD testing", function() {
      describe("when fetching Thing by codename", function() {
        before(function(done) {
          return request("http://localhost:" + config.all.server.nodeapi.port + "/api/things/parent/thing/CB000001", (function(_this) {
            return function(error, response, body) {
              _this.responseJSON = body;
              _this.response = response;
              return done();
            };
          })(this));
        });
        return it("should return a thing", function() {
          var responseJSON;
          responseJSON = parseResponse(this.response.body);
          return assert.equal(responseJSON.codeName, "CB000001");
        });
      });
      describe("when saving a new thing parent", function() {
        before(function(done) {
          this.timeout(20000);
          return request.post({
            url: "http://localhost:" + config.all.server.nodeapi.port + "/api/things/parent/thing",
            json: true,
            body: thingTestJSON.thingParent
          }, (function(_this) {
            return function(error, response, body) {
              _this.serverError = error;
              _this.responseJSON = body;
              return done();
            };
          })(this));
        });
        return it("should return a thing", function() {
          return assert.equal(this.responseJSON.codeName === null, false);
        });
      });
      describe("when saving a new thing batch", function() {
        before(function(done) {
          this.timeout(20000);
          return request.post({
            url: "http://localhost:" + config.all.server.nodeapi.port + "/api/things/batch/thing/CB000001",
            json: true,
            body: thingTestJSON.thingBatch
          }, (function(_this) {
            return function(error, response, body) {
              _this.serverError = error;
              _this.responseJSON = body;
              return done();
            };
          })(this));
        });
        return it("should return a thing", function() {
          return assert.equal(this.responseJSON.codeName === null, false);
        });
      });
      describe("when updating an thing parent", function() {
        before(function(done) {
          this.timeout(20000);
          return request.put({
            url: "http://localhost:" + config.all.server.nodeapi.port + "/api/things/parent/thing/CB00001",
            json: true,
            body: thingTestJSON.thingParent
          }, (function(_this) {
            return function(error, response, body) {
              _this.serverError = error;
              _this.responseJSON = body;
              return done();
            };
          })(this));
        });
        return it("should return a thing", function() {
          return assert.equal(this.responseJSON.codeName === null, false);
        });
      });
      describe("when getting batches by parent codeName", function() {
        before(function(done) {
          return request("http://localhost:" + config.all.server.nodeapi.port + "/api/batches/thing/parentCodeName/CB000001", (function(_this) {
            return function(error, response, body) {
              _this.responseJSON = body;
              _this.response = response;
              return done();
            };
          })(this));
        });
        return it("should return a thing", function() {
          var responseJSON;
          responseJSON = parseResponse(this.response.body);
          return assert.equal(responseJSON[0].codeName, "CB000001-1");
        });
      });
      return describe("when validating thing labelText", function() {
        before(function(done) {
          this.timeout(20000);
          return request.post({
            url: "http://localhost:" + config.all.server.nodeapi.port + "/api/validateName/thing",
            json: true,
            body: JSON.stringify("['exampleName']")
          }, (function(_this) {
            return function(error, response, body) {
              _this.serverError = error;
              _this.responseJSON = body;
              console.log(_this.responseJSON);
              return done();
            };
          })(this));
        });
        return it("should return a thing", function() {
          return assert.equal(this.responseJSON, true);
        });
      });
    });
  });

}).call(this);
