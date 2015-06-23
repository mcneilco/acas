(function() {
  var assert, config, request;

  assert = require('assert');

  request = require('request');

  config = require('../../../../conf/compiled/conf.js');

  describe("Tested Entity Properties Services", function() {
    return describe("get calculated compound properties", function() {
      describe("when valid compounds sent with valid properties ONLY PASSES IN STUBS MODE", function() {
        var body;
        body = {
          properties: ["HEAVY_ATOM_COUNT", "MONOISOTOPIC_MASS"],
          entityIdStringLines: "FRD76\nFRD2\nFRD78\n"
        };
        before(function(done) {
          this.timeout(20000);
          return request.post({
            url: "http://localhost:" + config.all.server.nodeapi.port + "/api/testedEntities/properties",
            json: true,
            body: body
          }, (function(_this) {
            return function(error, response, body) {
              _this.serverError = error;
              _this.responseJSON = body;
              console.log(_this.responseJSON);
              _this.serverResponse = response;
              return done();
            };
          })(this));
        });
        it("should return a success status code if in stubsMode, otherwise, this will fail", function() {
          return assert.equal(this.serverResponse.statusCode, 200);
        });
        it("should return 5 rows including a trailing \n", function() {
          return assert.equal(this.responseJSON.resultCSV.split('\n').length, 5);
        });
        it("should have 3 columns", function() {
          var res;
          res = this.responseJSON.resultCSV.split('\n');
          return assert.equal(res[0].split(',').length, 3);
        });
        it("should have a header row", function() {
          var res;
          res = this.responseJSON.resultCSV.split('\n');
          return assert.equal(res[0], "id,HEAVY_ATOM_COUNT,MONOISOTOPIC_MASS");
        });
        return it("should have a number in the first result row", function() {
          var res;
          res = this.responseJSON.resultCSV.split('\n');
          return assert.equal(isNaN(parseFloat(res[1].split(',')[1])), false);
        });
      });
      describe("when valid compounds sent with invalid properties", function() {
        var entityList, propertyList;
        propertyList = ["ERROR", "deep_fred"];
        entityList = "FRD76\nFRD2\nFRD78\n";
        before(function(done) {
          this.timeout(20000);
          return request.post({
            url: "http://localhost:" + config.all.server.nodeapi.port + "/api/testedEntities/properties",
            json: true,
            body: {
              properties: propertyList,
              entityIdStringLines: entityList
            }
          }, (function(_this) {
            return function(error, response, body) {
              _this.serverError = error;
              _this.responseJSON = body;
              console.log(_this.responseJSON);
              _this.serverResponse = response;
              return done();
            };
          })(this));
        });
        return it("should return a failure status code", function() {
          return assert.equal(this.serverResponse.statusCode, 500);
        });
      });
      return describe("when invalid compounds sent with valid properties", function() {
        var entityList, propertyList;
        propertyList = ["HEAVY_ATOM_COUNT", "MONOISOTOPIC_MASS"];
        entityList = "ERROR1\nERROR2\nERROR3\n";
        before(function(done) {
          this.timeout(20000);
          return request.post({
            url: "http://localhost:" + config.all.server.nodeapi.port + "/api/testedEntities/properties",
            json: true,
            body: {
              properties: propertyList,
              entityIdStringLines: entityList
            }
          }, (function(_this) {
            return function(error, response, body) {
              _this.serverError = error;
              _this.responseJSON = body;
              console.log(_this.responseJSON);
              _this.serverResponse = response;
              return done();
            };
          })(this));
        });
        it("should return an success status code", function() {
          return assert.equal(this.serverResponse.statusCode, 200);
        });
        it("should return 5 rows including a trailing \n", function() {
          return assert.equal(this.responseJSON.resultCSV.split('\n').length, 5);
        });
        it("should have 3 columns", function() {
          var res;
          res = this.responseJSON.resultCSV.split('\n');
          return assert.equal(res[0].split(',').length, 3);
        });
        it("should have a header row", function() {
          var res;
          res = this.responseJSON.resultCSV.split('\n');
          return assert.equal(res[0], "id,HEAVY_ATOM_COUNT,MONOISOTOPIC_MASS");
        });
        return it("should have an empty string in the first result", function() {
          var res;
          res = this.responseJSON.resultCSV.split('\n');
          return assert.equal(res[1].split(',')[1], "");
        });
      });
    });
  });

}).call(this);
