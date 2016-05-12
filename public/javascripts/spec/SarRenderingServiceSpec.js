(function() {
  var _, assert, config, parseResponse, request;

  assert = require('assert');

  request = require('request');

  _ = require('underscore');

  parseResponse = function(jsonStr) {
    var error, error1;
    try {
      return JSON.parse(jsonStr);
    } catch (error1) {
      error = error1;
      console.log("response unparsable: " + error);
      console.log("response: " + jsonStr);
      return null;
    }
  };

  config = require('../../../conf/compiled/conf.js');

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

  describe("SAR service to fetch column title", function() {
    describe("when called with Gene ID", function() {
      before(function(done) {
        return request("http://192.168.99.100:" + config.all.server.nodeapi.port + "/api/sarRender/title/Gene%20ID", (function(_this) {
          return function(error, response, body) {
            _this.responseJSON = parseResponse(body);
            return done();
          };
        })(this));
      });
      return it("should return 'Gene ID' ", function() {
        return assert.equal(this.responseJSON.title, "Gene ID");
      });
    });
    return describe("when called with Corporate Batch ID", function() {
      before(function(done) {
        return request("http://192.168.99.100:" + config.all.server.nodeapi.port + "/api/sarRender/title/Corporate%20Batch%20ID", (function(_this) {
          return function(error, response, body) {
            _this.responseJSON = parseResponse(body);
            return done();
          };
        })(this));
      });
      return it("should return 'Compound Information'", function() {
        return assert.equal(this.responseJSON.title, "Compound Information");
      });
    });
  });

  describe("SAR generic rendering service", function() {
    describe("when provided the displayName", function() {
      describe("for Gene ID", function() {
        var body;
        body = {
          displayName: "Gene ID",
          referenceCode: "GENE-000003"
        };
        console.log(config.all.server.nodeapi.path + "/api/sarRender/render");
        console.log(JSON.stringify(body));
        before(function(done) {
          this.timeout(20000);
          return request.post({
            url: config.all.server.nodeapi.path + "/api/sarRender/render",
            json: true,
            body: body
          }, (function(_this) {
            return function(error, response, body) {
              _this.responseJSON = body;
              console.log(_this.responseJSON);
              return done();
            };
          })(this));
        });
        return it("should return entity type descriptions with required attributes", function() {
          return assert.equal(this.responseJSON.html, '<p align="center">2</p>');
        });
      });
      return describe("for Corporate Batch ID", function() {
        var body;
        body = {
          displayName: "Corporate Batch ID",
          referenceCode: "CMPD-0000011-01A"
        };
        before(function(done) {
          this.timeout(20000);
          return request.post({
            url: config.all.server.nodeapi.path + "/api/sarRender/render",
            json: true,
            body: body
          }, (function(_this) {
            return function(error, response, body) {
              _this.responseJSON = body;
              console.log(_this.responseJSON);
              return done();
            };
          })(this));
        });
        return it("should return entity type descriptions with required attributes", function() {
          return assert.equal(this.responseJSON.html, "<img src=\"http://host4.labsynch.com:8080/cmpdreg/structureimage/lot/CMPD-0000011-01A\"> <p align=\"center\">CMPD-0000011-01A</p>");
        });
      });
    });
    return describe("when not provided the displayName", function() {
      describe("for Gene ID", function() {
        var body;
        body = {
          referenceCode: "GENE-000003"
        };
        before(function(done) {
          this.timeout(20000);
          return request.post({
            url: config.all.server.nodeapi.path + "/api/sarRender/render",
            json: true,
            body: body
          }, (function(_this) {
            return function(error, response, body) {
              _this.responseJSON = body;
              console.log(_this.responseJSON);
              return done();
            };
          })(this));
        });
        return it("should return entity type descriptions with required attributes", function() {
          return assert.equal(this.responseJSON.html, '<p align="center">2</p>');
        });
      });
      return describe("for Corporate Batch ID", function() {
        var body;
        body = {
          referenceCode: "CMPD-0000011-01A"
        };
        before(function(done) {
          this.timeout(20000);
          return request.post({
            url: config.all.server.nodeapi.path + "/api/sarRender/render",
            json: true,
            body: body
          }, (function(_this) {
            return function(error, response, body) {
              _this.responseJSON = body;
              console.log(_this.responseJSON);
              return done();
            };
          })(this));
        });
        return it("should return entity type descriptions with required attributes", function() {
          return assert.equal(this.responseJSON.html, "<img src=\"http://host4.labsynch.com:8080/cmpdreg/structureimage/lot/CMPD-0000011-01A\"> <p align=\"center\">CMPD-0000011-01A</p>");
        });
      });
    });
  });

}).call(this);
