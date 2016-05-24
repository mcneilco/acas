(function() {
  var _, assert, codeTablePostTestJSON, codeTablePutTestJSON, config, fs, parseResponse, request;

  assert = require('assert');

  request = require('request');

  _ = require('underscore');

  codeTablePostTestJSON = require('../testFixtures/codeTablePostTestJSON.js');

  codeTablePutTestJSON = require('../testFixtures/codeTablePutTestJSON.js');

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

  describe("CodeTable Service testing", function() {
    return describe("CodeTable CRUD testing", function() {
      describe("when fetching all codeTables", function() {
        before(function(done) {
          return request("http://localhost:" + config.all.server.nodeapi.port + "/api/codetables", (function(_this) {
            return function(error, response, body) {
              _this.responseJSON = body;
              _this.response = response;
              return done();
            };
          })(this));
        });
        return it("should return all codeTables", function() {
          var responseJSON;
          responseJSON = parseResponse(this.response.body);
          assert.equal(responseJSON[0].code, "fluorescence");
          assert.equal(responseJSON[0].name, "Fluorescence");
          assert.equal(responseJSON[1].code, "biochemical");
          return assert.equal(responseJSON[2].code, "ko");
        });
      });
      describe("when fetching a single set of codeTables", function() {
        before(function(done) {
          return request("http://localhost:" + config.all.server.nodeapi.port + "/api/codetables/algorithm well flags/flag observation", (function(_this) {
            return function(error, response, body) {
              _this.responseJSON = body;
              _this.response = response;
              return done();
            };
          })(this));
        });
        return it("should return a single set of codeTables", function() {
          var responseJSON;
          responseJSON = parseResponse(this.response.body);
          assert.equal(responseJSON[0].code, "outlier");
          assert.equal(responseJSON[0].name, "Outlier");
          assert.equal(responseJSON[1].code, "high");
          assert.equal(responseJSON[1].name, "Value too high");
          return assert.equal(responseJSON[1].ignored, true);
        });
      });
      describe("when saving a new code value", function() {
        before(function(done) {
          this.timeout(20000);
          return request.post({
            url: "http://localhost:" + config.all.server.nodeapi.port + "/api/codetables",
            json: true,
            body: codeTablePostTestJSON.codeEntry
          }, (function(_this) {
            return function(error, response, body) {
              _this.serverError = error;
              _this.responseJSON = body;
              _this.response = response;
              return done();
            };
          })(this));
        });
        return it("should return a code value", function() {
          var results;
          assert.equal(this.response === null, false);
          results = this.response.body;
          assert.equal(results.code, "fluorescence test 2");
          return assert.equal(results.name, "Fluorescence TEST 2");
        });
      });
      return describe("when updating an existing code value", function() {
        before(function(done) {
          this.timeout(20000);
          return request.put({
            url: "http://localhost:" + config.all.server.nodeapi.port + "/api/codetables/186",
            json: true,
            body: codeTablePutTestJSON.codeEntry
          }, (function(_this) {
            return function(error, response, body) {
              _this.serverError = error;
              _this.responseJSON = body;
              _this.response = response;
              return done();
            };
          })(this));
        });
        return it("should return a code value", function() {
          var results;
          assert.equal(this.response === null, false);
          results = this.response.body;
          assert.equal(results.code, "fluorescence test modified code");
          return assert.equal(results.name, "Fluorescence TEST Modified");
        });
      });
    });
  });

}).call(this);
