(function() {
  var _, assert, config, parseResponse, request;

  assert = require('assert');

  request = require('request');

  _ = require('underscore');

  parseResponse = function(jsonStr) {
    var error;
    try {
      return JSON.parse(jsonStr);
    } catch (_error) {
      error = _error;
      console.log("response unparsable: " + error);
      console.log("response: " + jsonStr);
      return null;
    }
  };

  config = require('../../../../conf/compiled/conf.js');

  describe("SAR rendering service for Gene ID's", function() {
    return describe("when called with a valid ID", function() {
      before(function(done) {
        var validCode;
        validCode = "GENE-000003";
        return request("http://192.168.99.100:" + config.all.server.nodeapi.port + "/api/sarRender/geneId/" + validCode, (function(_this) {
          return function(error, response, body) {
            console.log("body is " + body);
            console.log("response is " + response);
            _this.responseJSON = parseResponse(body);
            return done();
          };
        })(this));
      });
      return it("should return entity type descriptions with required attributes", function() {
        return assert.equal(this.responseJSON.html, '<p align="center">2</p>');
      });
    });
  });

  describe("SAR rendering service for Corporate Batch ID's", function() {
    return describe("when called with a valid ID", function() {
      before(function(done) {
        var validCode;
        validCode = "CMPD-0000011-01A";
        return request("http://192.168.99.100:" + config.all.server.nodeapi.port + "/api/sarRender/cmpdRegBatch/" + validCode, (function(_this) {
          return function(error, response, body) {
            console.log("body is " + body);
            console.log("response is " + response);
            _this.responseJSON = parseResponse(body);
            return done();
          };
        })(this));
      });
      return it("should return entity type descriptions with required attributes", function() {
        return assert.equal(this.responseJSON.html, "<img src=\"http://host4.labsynch.com:8080/cmpdreg/structureimage/lot/CMPD-0000011-01A\"> <p align=\"center\">CMPD-0000011-01A</p>");
      });
    });
  });

}).call(this);
