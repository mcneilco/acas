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

  describe("Preferred Entity code service tests: available entity type list", function() {
    describe("when requested as fully detailed list", function() {
      var key;
      before(function(done) {
        return request("http://localhost:" + config.all.server.nodeapi.port + "/api/entitymeta/configuredEntityTypes", (function(_this) {
          return function(error, response, body) {
            _this.responseJSON = parseResponse(body);
            return done();
          };
        })(this));
      });
      key = "Corporate Parent ID";
      return it("should return entity type descriptions with required attributes", function() {
        assert.equal(this.responseJSON[key].type != null, true);
        assert.equal(this.responseJSON[key].kind != null, true);
        assert.equal(this.responseJSON[key].displayName != null, true);
        assert.equal(this.responseJSON[key].codeOrigin != null, true);
        return assert.equal(this.responseJSON[key].sourceExternal != null, true);
      });
    });
    describe("when requested as list of codes", function() {
      before(function(done) {
        return request("http://localhost:" + config.all.server.nodeapi.port + "/api/entitymeta/configuredEntityTypes/asCodes", (function(_this) {
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
        assert.equal(this.responseJSON[0].displayName != null, true);
        return assert.equal(this.responseJSON[0].ignored != null, true);
      });
    });
    return describe("when a specific entity type is requested by displayName", function() {
      var entityType;
      entityType = encodeURIComponent("Corporate Parent ID");
      before(function(done) {
        return request("http://" + config.all.client.host + ":" + config.all.server.nodeapi.port + "/api/entitymeta/configuredEntityTypes/displayName/" + entityType, (function(_this) {
          return function(error, response, body) {
            _this.responseJSON = parseResponse(body);
            return done();
          };
        })(this));
      });
      return it("should return an object with all the required attributes", function() {
        assert(this.responseJSON.type != null);
        assert(this.responseJSON.kind != null);
        assert(this.responseJSON.displayName != null);
        assert(this.responseJSON.codeOrigin != null);
        return assert(this.responseJSON.sourceExternal != null);
      });
    });
  });

  describe("get preferred entity codeName for supplied name or codeName", function() {
    describe("when valid compounds sent with valid type info ONLY PASSES IN STUBS MODE [CSV FORMAT]", function() {
      var body;
      body = {
        displayName: "Protein Parent",
        entityIdStringLines: "PROT1\nPROT2\nPROT3\n"
      };
      before(function(done) {
        this.timeout(20000);
        return request.post({
          url: "http://localhost:" + config.all.server.nodeapi.port + "/api/entitymeta/referenceCodes/csv",
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
      it("should return 5 rows including a trailing newline", function() {
        return assert.equal(this.responseJSON.resultCSV.split('\n').length, 5);
      });
      it("should have 2 columns", function() {
        var res;
        res = this.responseJSON.resultCSV.split('\n');
        return assert.equal(res[0].split(',').length, 2);
      });
      it("should have a header row", function() {
        var res;
        res = this.responseJSON.resultCSV.split('\n');
        return assert.equal(res[0], "Requested Name,Reference Code");
      });
      return it("should have the query first result column", function() {
        var res;
        res = this.responseJSON.resultCSV.split('\n');
        return assert.equal(res[1].split(',')[0], "PROT1");
      });
    });
    describe("when valid compounds sent with valid type info ONLY PASSES IN STUBS MODE [JSON FORMAT]", function() {
      var body;
      body = {
        displayName: "Protein Parent",
        requests: [
          {
            requestName: "PROT1"
          }, {
            requestName: "PROT2"
          }, {
            requestName: "PROT3"
          }
        ]
      };
      before(function(done) {
        this.timeout(20000);
        return request.post({
          url: "http://localhost:" + config.all.server.nodeapi.port + "/api/entitymeta/referenceCodes",
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
      it("should return the given displayName \n", function() {
        return assert.equal(this.responseJSON.displayName, "Protein Parent");
      });
      it("should have 3 results", function() {
        return assert.equal(this.responseJSON.results.length, 3);
      });
      return it("should return requestName", function() {
        var res;
        res = this.responseJSON.results;
        assert.equal(res[0].requestName, "PROT1");
        assert.equal(res[1].requestName, "PROT2");
        return assert.equal(res[2].requestName, "PROT3");
      });
    });
    describe("when valid compounds sent with invalid type info [CSV FORMAT]", function() {
      var body;
      body = {
        displayName: "ERROR",
        entityIdStringLines: "PROT1\nPROT2\nPROT3\n"
      };
      before(function(done) {
        this.timeout(20000);
        return request.post({
          url: "http://localhost:" + config.all.server.nodeapi.port + "/api/entitymeta/referenceCodes/csv",
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
      return it("should return a failure status code", function() {
        return assert.equal(this.serverResponse.statusCode, 500);
      });
    });
    describe("when valid compounds sent with invalid type info [JSON FORMAT]", function() {
      var body;
      body = {
        displayName: "ERROR",
        requests: [
          {
            requestName: "PROT1"
          }, {
            requestName: "PROT2"
          }, {
            requestName: "PROT3"
          }
        ]
      };
      before(function(done) {
        this.timeout(20000);
        return request.post({
          url: "http://localhost:" + config.all.server.nodeapi.port + "/api/entitymeta/referenceCodes",
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
      return it("should return a failure status code", function() {
        return assert.equal(this.serverResponse.statusCode, 500);
      });
    });
    describe("when valid small molecule batch names are passed in ONLY PASSES IN STUBS MODE [CSV FORAMT]", function() {
      var body;
      body = {
        displayName: "Corporate Batch ID",
        entityIdStringLines: "CMPD-0000001-01\nnone_2222:1\nCMPD-0000002-01\n"
      };
      before(function(done) {
        this.timeout(20000);
        return request.post({
          url: "http://localhost:" + config.all.server.nodeapi.port + "/api/entitymeta/referenceCodes/csv",
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
      it("should return the requested displayName", function() {
        return assert.equal(this.responseJSON.displayName, "Corporate Batch ID");
      });
      it("should have the first line query in first result column", function() {
        var res;
        res = this.responseJSON.resultCSV.split('\n');
        return assert.equal(res[1].split(',')[0], "CMPD-0000001-01");
      });
      it("should have the first line result second result column", function() {
        var res;
        res = this.responseJSON.resultCSV.split('\n');
        return assert.equal(res[1].split(',')[1], "CMPD-0000001-01");
      });
      it("should have the second line query in first result column", function() {
        var res;
        res = this.responseJSON.resultCSV.split('\n');
        return assert.equal(res[2].split(',')[0], "none_2222:1");
      });
      return it("should have the second line result second result column with no result", function() {
        var res;
        res = this.responseJSON.resultCSV.split('\n');
        return assert.equal(res[2].split(',')[1], "");
      });
    });
    describe("when valid small molecule batch names are passed in ONLY PASSES IN STUBS MODE [JSON FORAMT]", function() {
      var body;
      body = {
        displayName: "Corporate Batch ID",
        requests: [
          {
            requestName: "CMPD-0000001-01"
          }, {
            requestName: "none_2222:1"
          }, {
            requestName: "CMPD-0000002-01"
          }
        ]
      };
      before(function(done) {
        this.timeout(20000);
        return request.post({
          url: "http://localhost:" + config.all.server.nodeapi.port + "/api/entitymeta/referenceCodes",
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
      it("should return the requested displayName", function() {
        return assert.equal(this.responseJSON.displayName, "Corporate Batch ID");
      });
      it("should return an array of results the same length as the array of requests", function() {
        return assert.equal(this.responseJSON.results.length, 3);
      });
      it("should have request in each results object", function() {
        assert.equal(this.responseJSON.results[0].requestName, "CMPD-0000001-01");
        assert.equal(this.responseJSON.results[1].requestName, "none_2222:1");
        return assert.equal(this.responseJSON.results[2].requestName, "CMPD-0000002-01");
      });
      return it("should have the correct result for each request", function() {
        assert.equal(this.responseJSON.results[0].referenceCode, "CMPD-0000001-01");
        assert.equal(this.responseJSON.results[1].referenceCode, "");
        return assert.equal(this.responseJSON.results[2].referenceCode, "CMPD-0000002-01");
      });
    });
    describe("when valid small molecule Parent names are passed in ONLY PASSES IN STUBS MODE [CSV FORMAT]", function() {
      var body;
      body = {
        displayName: "Corporate Parent ID",
        entityIdStringLines: "CMPD-0000001\nCMPD-999999999\ncompoundName\n"
      };
      before(function(done) {
        this.timeout(20000);
        return request.post({
          url: "http://localhost:" + config.all.server.nodeapi.port + "/api/entitymeta/referenceCodes/csv",
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
      it("should return the requested displayName", function() {
        return assert.equal(this.responseJSON.displayName, "Corporate Parent ID");
      });
      it("should have the first line query in first result column", function() {
        var res;
        res = this.responseJSON.resultCSV.split('\n');
        return assert.equal(res[1].split(',')[0], "CMPD-0000001");
      });
      it("should have the first line result second result column", function() {
        var res;
        res = this.responseJSON.resultCSV.split('\n');
        return assert.equal(res[1].split(',')[1], "CMPD-0000001");
      });
      it("should have the second line query in first result column", function() {
        var res;
        res = this.responseJSON.resultCSV.split('\n');
        return assert.equal(res[2].split(',')[0], "CMPD-999999999");
      });
      it("should have the second line result second result column with no result", function() {
        var res;
        res = this.responseJSON.resultCSV.split('\n');
        return assert.equal(res[2].split(',')[1], "");
      });
      return it("should have the third line result second result column with alias result", function() {
        var res;
        res = this.responseJSON.resultCSV.split('\n');
        return assert.equal(res[3].split(',')[1].indexOf('CMPD') > -1, true);
      });
    });
    describe("when valid small molecule Parent names are passed in ONLY PASSES IN STUBS MODE [JSON FORMAT]", function() {
      var body;
      body = {
        displayName: "Corporate Parent ID",
        requests: [
          {
            requestName: "CMPD-0000001"
          }, {
            requestName: "CMPD-999999999"
          }, {
            requestName: "compoundName"
          }
        ]
      };
      before(function(done) {
        this.timeout(20000);
        return request.post({
          url: "http://localhost:" + config.all.server.nodeapi.port + "/api/entitymeta/referenceCodes",
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
      it("should return the requested displayName", function() {
        return assert.equal(this.responseJSON.displayName, "Corporate Parent ID");
      });
      it("should return an array of results the same length as the array of requests", function() {
        return assert.equal(this.responseJSON.results.length, 3);
      });
      it("should have request in each results object", function() {
        assert.equal(this.responseJSON.results[0].requestName, "CMPD-0000001");
        assert.equal(this.responseJSON.results[1].requestName, "CMPD-999999999");
        return assert.equal(this.responseJSON.results[2].requestName, "compoundName");
      });
      return it("should have the correct result for each request", function() {
        assert.equal(this.responseJSON.results[0].referenceCode, "CMPD-0000001");
        assert.equal(this.responseJSON.results[1].referenceCode, "");
        return assert.equal(this.responseJSON.results[2].referenceCode.indexOf('CMPD') > -1, true);
      });
    });
    describe("when valid lsthing parent names are passed in ONLY PASSES IN STUBS MODE [CSV FORMAT]", function() {
      var body;
      body = {
        displayName: "Protein Parent",
        entityIdStringLines: "GENE1234\nsome Gene name\nambiguousName\n"
      };
      before(function(done) {
        this.timeout(20000);
        return request.post({
          url: "http://localhost:" + config.all.server.nodeapi.port + "/api/entitymeta/referenceCodes/csv",
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
      it("should return the requested displayName", function() {
        return assert.equal(this.responseJSON.displayName, "Protein Parent");
      });
      it("should have the first line query in first result column", function() {
        var res;
        res = this.responseJSON.resultCSV.split('\n');
        return assert.equal(res[1].split(',')[0], "GENE1234");
      });
      it("should have the first line result second result column", function() {
        var res;
        res = this.responseJSON.resultCSV.split('\n');
        return assert.equal(res[1].split(',')[1], "GENE1234");
      });
      it("should have the second line query in first result column", function() {
        var res;
        res = this.responseJSON.resultCSV.split('\n');
        return assert.equal(res[2].split(',')[0], "some Gene name");
      });
      it("should have the second line result second result column with the code", function() {
        var res;
        res = this.responseJSON.resultCSV.split('\n');
        return assert.equal(res[2].split(',')[1], "GENE1111");
      });
      it("should have the third line query in first result column", function() {
        var res;
        res = this.responseJSON.resultCSV.split('\n');
        return assert.equal(res[3].split(',')[0], "ambiguousName");
      });
      return it("should have the third line result second result column with no result", function() {
        var res;
        res = this.responseJSON.resultCSV.split('\n');
        return assert.equal(res[3].split(',')[1], "");
      });
    });
    describe("when valid lsthing parent names are passed in ONLY PASSES IN STUBS MODE [JSON FORMAT]", function() {
      var body;
      body = {
        displayName: "Protein Parent",
        requests: [
          {
            requestName: "GENE1234"
          }, {
            requestName: "some Gene name"
          }, {
            requestName: "ambiguousName"
          }
        ]
      };
      before(function(done) {
        this.timeout(20000);
        return request.post({
          url: "http://localhost:" + config.all.server.nodeapi.port + "/api/entitymeta/referenceCodes",
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
      it("should return the requested displayName", function() {
        return assert.equal(this.responseJSON.displayName, "Protein Parent");
      });
      it("should return an array of results the same length as the array of requests", function() {
        return assert.equal(this.responseJSON.results.length, 3);
      });
      it("should have request in each results object", function() {
        assert.equal(this.responseJSON.results[0].requestName, "GENE1234");
        assert.equal(this.responseJSON.results[1].requestName, "some Gene name");
        return assert.equal(this.responseJSON.results[2].requestName, "ambiguousName");
      });
      return it("should have the correct result for each request", function() {
        assert.equal(this.responseJSON.results[0].referenceCode, "GENE1234");
        assert.equal(this.responseJSON.results[1].referenceCode, "GENE1111");
        return assert.equal(this.responseJSON.results[2].referenceCode, "");
      });
    });
    describe("when valid lsthing entrez gene names or codes are passed in ONLY PASSES IN LIVE MODE with genes loaded [CSV FORMAT]", function() {
      var body;
      body = {
        displayName: "Gene ID",
        entityIdStringLines: "GENE-000002\nCPAMD5\nambiguousName\n"
      };
      before(function(done) {
        this.timeout(20000);
        return request.post({
          url: "http://localhost:" + config.all.server.nodeapi.port + "/api/entitymeta/referenceCodes/csv",
          json: true,
          body: body
        }, (function(_this) {
          return function(error, response, body) {
            _this.serverError = error;
            _this.responseJSON = body;
            console.log(_this.responseJSON);
            _this.serverResponse = response;
            console.log(_this.serverResponse.statusCode);
            return done();
          };
        })(this));
      });
      it("should return a success status code if in stubsMode, otherwise, this will fail", function() {
        return assert.equal(this.serverResponse.statusCode, 200);
      });
      it("should return the requested displayName", function() {
        return assert.equal(this.responseJSON.displayName, "Gene ID");
      });
      it("should have the first line query in first result column", function() {
        var res;
        res = this.responseJSON.resultCSV.split('\n');
        return assert.equal(res[1].split(',')[0], "GENE-000002");
      });
      it("should have the first line result second result column", function() {
        var res;
        res = this.responseJSON.resultCSV.split('\n');
        return assert.equal(res[1].split(',')[1], "GENE-000002");
      });
      it("should have the second line query in first result column", function() {
        var res;
        res = this.responseJSON.resultCSV.split('\n');
        return assert.equal(res[2].split(',')[0], "CPAMD5");
      });
      it("should have the second line result second result column with the code", function() {
        var res;
        res = this.responseJSON.resultCSV.split('\n');
        return assert.equal(res[2].split(',')[1], "GENE-000003");
      });
      it("should have the third line query in first result column", function() {
        var res;
        res = this.responseJSON.resultCSV.split('\n');
        return assert.equal(res[3].split(',')[0], "ambiguousName");
      });
      return it("should have the third line result second result column with no result", function() {
        var res;
        res = this.responseJSON.resultCSV.split('\n');
        return assert.equal(res[3].split(',')[1], "");
      });
    });
    return describe("when valid lsthing entrez gene names or codes are passed in ONLY PASSES IN LIVE MODE with genes loaded [JSON FORMAT]", function() {
      var body;
      body = {
        displayName: "Gene ID",
        requests: [
          {
            requestName: "GENE-000002"
          }, {
            requestName: "CPAMD5"
          }, {
            requestName: "ambiguousName"
          }
        ]
      };
      before(function(done) {
        this.timeout(20000);
        return request.post({
          url: "http://localhost:" + config.all.server.nodeapi.port + "/api/entitymeta/referenceCodes",
          json: true,
          body: body
        }, (function(_this) {
          return function(error, response, body) {
            _this.serverError = error;
            _this.responseJSON = body;
            console.log(_this.responseJSON);
            _this.serverResponse = response;
            console.log(_this.serverResponse.statusCode);
            return done();
          };
        })(this));
      });
      it("should return a success status code if in stubsMode, otherwise, this will fail", function() {
        return assert.equal(this.serverResponse.statusCode, 200);
      });
      it("should return the requested displayName", function() {
        return assert.equal(this.responseJSON.displayName, "Gene ID");
      });
      it("should return an array of results the same length as the array of requests", function() {
        return assert.equal(this.responseJSON.results.length, 3);
      });
      it("should have request in each results object", function() {
        assert.equal(this.responseJSON.results[0].requestName, "GENE-000002");
        assert.equal(this.responseJSON.results[1].requestName, "CPAMD5");
        return assert.equal(this.responseJSON.results[2].requestName, "ambiguousName");
      });
      return it("should have the correct result for each request", function() {
        assert.equal(this.responseJSON.results[0].referenceCode, "GENE-000002");
        assert.equal(this.responseJSON.results[1].referenceCode, "GENE-000003");
        return assert.equal(this.responseJSON.results[2].referenceCode, "");
      });
    });
  });

  describe("direct function API tests", function() {
    var codeService;
    codeService = require('../../../../routes/PreferredEntityCodeService.js');
    describe("Reference Codes when valid lsthing entrez gene names or codes are passed in ONLY PASSES IN LIVE MODE with genes loaded [CSV FORMAT]", function() {
      var csv, requestData;
      csv = true;
      requestData = {
        displayName: "Gene ID",
        entityIdStringLines: "GENE-000002\nCPAMD5\nambiguousName\n"
      };
      before(function(done) {
        this.timeout(20000);
        return codeService.referenceCodes(requestData, csv, (function(_this) {
          return function(response) {
            _this.responseJSON = response;
            console.log(response);
            return done();
          };
        })(this));
      });
      it("should return the requested displayName", function() {
        return assert.equal(this.responseJSON.displayName, "Gene ID");
      });
      it("should have the first line query in first result column", function() {
        var res;
        res = this.responseJSON.resultCSV.split('\n');
        return assert.equal(res[1].split(',')[0], "GENE-000002");
      });
      it("should have the first line result second result column", function() {
        var res;
        res = this.responseJSON.resultCSV.split('\n');
        return assert.equal(res[1].split(',')[1], "GENE-000002");
      });
      it("should have the second line query in first result column", function() {
        var res;
        res = this.responseJSON.resultCSV.split('\n');
        return assert.equal(res[2].split(',')[0], "CPAMD5");
      });
      it("should have the second line result second result column with the code", function() {
        var res;
        res = this.responseJSON.resultCSV.split('\n');
        return assert.equal(res[2].split(',')[1], "GENE-000003");
      });
      it("should have the third line query in first result column", function() {
        var res;
        res = this.responseJSON.resultCSV.split('\n');
        return assert.equal(res[3].split(',')[0], "ambiguousName");
      });
      return it("should have the third line result second result column with no result", function() {
        var res;
        res = this.responseJSON.resultCSV.split('\n');
        return assert.equal(res[3].split(',')[1], "");
      });
    });
    describe("Reference Codes when valid lsthing entrez gene names or codes are passed in ONLY PASSES IN LIVE MODE with genes loaded [JSON FORMAT]", function() {
      var csv, requestData;
      csv = false;
      requestData = {
        displayName: "Gene ID",
        requests: [
          {
            requestName: "GENE-000002"
          }, {
            requestName: "CPAMD5"
          }, {
            requestName: "ambiguousName"
          }
        ]
      };
      before(function(done) {
        this.timeout(20000);
        return codeService.referenceCodes(requestData, csv, (function(_this) {
          return function(response) {
            _this.responseJSON = response;
            console.log(response);
            return done();
          };
        })(this));
      });
      it("should return the requested displayName", function() {
        return assert.equal(this.responseJSON.displayName, "Gene ID");
      });
      it("should return an array of results the same length as the array of requests", function() {
        return assert.equal(this.responseJSON.results.length, 3);
      });
      it("should have request in each results object", function() {
        assert.equal(this.responseJSON.results[0].requestName, "GENE-000002");
        assert.equal(this.responseJSON.results[1].requestName, "CPAMD5");
        return assert.equal(this.responseJSON.results[2].requestName, "ambiguousName");
      });
      return it("should have the correct result for each request", function() {
        assert.equal(this.responseJSON.results[0].referenceCode, "GENE-000002");
        assert.equal(this.responseJSON.results[1].referenceCode, "GENE-000003");
        return assert.equal(this.responseJSON.results[2].referenceCode, "");
      });
    });
    describe("Best Labels when valid lsthing entrez gene names or codes are passed in ONLY PASSES IN LIVE MODE with genes loaded [CSV FORMAT]", function() {
      var csv, requestData;
      csv = true;
      requestData = {
        displayName: "Gene ID",
        referenceCodes: "GENE-000002\nGENE-000003\n"
      };
      before(function(done) {
        this.timeout(20000);
        return codeService.pickBestLabels(requestData, csv, (function(_this) {
          return function(response) {
            _this.responseJSON = response;
            console.log(response);
            return done();
          };
        })(this));
      });
      it("should return the requested displayName", function() {
        return assert.equal(this.responseJSON.displayName, "Gene ID");
      });
      it("should have the first line query in first result column", function() {
        var res;
        res = this.responseJSON.resultCSV.split('\n');
        return assert.equal(res[1].split(',')[0], "GENE-000002");
      });
      it("should have the first line result second result column", function() {
        var res;
        res = this.responseJSON.resultCSV.split('\n');
        return assert.equal(res[1].split(',')[1], "1");
      });
      it("should have the second line query in first result column", function() {
        var res;
        res = this.responseJSON.resultCSV.split('\n');
        return assert.equal(res[2].split(',')[0], "GENE-000003");
      });
      return it("should have the second line result second result column with the code", function() {
        var res;
        res = this.responseJSON.resultCSV.split('\n');
        return assert.equal(res[2].split(',')[1], "2");
      });
    });
    describe("Best Lables when valid lsthing entrez gene names or codes are passed in ONLY PASSES IN LIVE MODE with genes loaded [JSON FORMAT]", function() {
      var csv, requestData;
      csv = false;
      requestData = {
        displayName: "Gene ID",
        requests: [
          {
            requestName: "GENE-000002"
          }, {
            requestName: "GENE-000003"
          }
        ]
      };
      before(function(done) {
        this.timeout(20000);
        return codeService.pickBestLabels(requestData, csv, (function(_this) {
          return function(response) {
            _this.responseJSON = response;
            console.log(response);
            return done();
          };
        })(this));
      });
      it("should return the requested displayName", function() {
        return assert.equal(this.responseJSON.displayName, "Gene ID");
      });
      it("should return an array of results the same length as the array of requests", function() {
        return assert.equal(this.responseJSON.results.length, 2);
      });
      it("should have request in each results object", function() {
        assert.equal(this.responseJSON.results[0].requestName, "GENE-000002");
        return assert.equal(this.responseJSON.results[1].requestName, "GENE-000003");
      });
      return it("should have the correct result for each request", function() {
        assert.equal(this.responseJSON.results[0].bestLabel, "1");
        return assert.equal(this.responseJSON.results[1].bestLabel, "2");
      });
    });
    describe("available entity type list", function() {
      describe("when requested as fully detailed object", function() {
        before(function(done) {
          return codeService.getConfiguredEntityTypes(false, (function(_this) {
            return function(response) {
              _this.responseJSON = response;
              return done();
            };
          })(this));
        });
        return it("should return entity type descriptions with required attributes", function() {
          var key;
          key = "Corporate Parent ID";
          assert.equal(this.responseJSON[key].type != null, true);
          assert.equal(this.responseJSON[key].kind != null, true);
          assert.equal(this.responseJSON[key].displayName != null, true);
          assert.equal(this.responseJSON[key].codeOrigin != null, true);
          return assert.equal(this.responseJSON[key].sourceExternal != null, true);
        });
      });
      return describe("when requested as list of codes", function() {
        before(function(done) {
          return codeService.getConfiguredEntityTypes(true, (function(_this) {
            return function(response) {
              _this.responseJSON = response;
              return done();
            };
          })(this));
        });
        it("should return an array of entity types", function() {
          return assert.equal(this.responseJSON.length > 0, true);
        });
        return it("should return entity type descriptions with required attributes", function() {
          assert.equal(this.responseJSON[0].code != null, true);
          assert.equal(this.responseJSON[0].displayName != null, true);
          return assert.equal(this.responseJSON[0].ignored != null, true);
        });
      });
    });
    return describe("when requested as specific entity type details", function() {
      before(function(done) {
        return codeService.getSpecificEntityType("Corporate Parent ID", (function(_this) {
          return function(response) {
            _this.responseJSON = response;
            return done();
          };
        })(this));
      });
      return it("should return entity type descriptions with required attributes", function() {
        assert.equal(this.responseJSON.type != null, true);
        assert.equal(this.responseJSON.kind != null, true);
        assert.equal(this.responseJSON.displayName != null, true);
        assert.equal(this.responseJSON.codeOrigin != null, true);
        return assert.equal(this.responseJSON.sourceExternal != null, true);
      });
    });
  });

  describe("pickBestLabels service test", function() {
    describe("for lsThings", function() {
      describe("for entrez genes ONLY PASSES IN LIVE MODE with genes loaded [CSV FORMAT]", function() {
        var body;
        body = {
          displayName: "Gene ID",
          referenceCodes: "GENE-000002\nGENE-000003"
        };
        before(function(done) {
          this.timeout(20000);
          return request.post({
            url: "http://localhost:" + config.all.server.nodeapi.port + "/api/entitymeta/pickBestLabels/csv",
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
        it("should return an object with the correct fields", function() {
          assert(this.responseJSON.displayName != null);
          return assert(this.responseJSON.resultCSV != null);
        });
        it("should have the first line query in second row, first column", function() {
          var res;
          res = this.responseJSON.resultCSV.split('\n');
          return assert.equal(res[1].split(',')[0], "GENE-000002");
        });
        it("should have the first line result in second row, second column", function() {
          var res;
          res = this.responseJSON.resultCSV.split('\n');
          return assert.equal(res[1].split(',')[1], "1");
        });
        it("should have the second line query in third row, first column", function() {
          var res;
          res = this.responseJSON.resultCSV.split('\n');
          return assert.equal(res[2].split(',')[0], "GENE-000003");
        });
        return it("should have the second line result in third row, second column", function() {
          var res;
          res = this.responseJSON.resultCSV.split('\n');
          return assert.equal(res[2].split(',')[1], "2");
        });
      });
      describe("for entrez genes ONLY PASSES IN LIVE MODE with genes loaded [JSON FORMAT]", function() {
        var body;
        body = {
          displayName: "Gene ID",
          requests: [
            {
              requestName: "GENE-000002"
            }, {
              requestName: "GENE-000003"
            }
          ]
        };
        before(function(done) {
          this.timeout(20000);
          return request.post({
            url: "http://localhost:" + config.all.server.nodeapi.port + "/api/entitymeta/pickBestLabels",
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
        it("should return an object with the correct fields", function() {
          assert(this.responseJSON.displayName != null);
          return assert(this.responseJSON.results != null);
        });
        it("should have the correct number of returned items", function() {
          return assert.equal(this.responseJSON.results.length, 2);
        });
        it("should return the requested names", function() {
          assert.equal(this.responseJSON.results[0].requestName, "GENE-000002");
          return assert.equal(this.responseJSON.results[1].requestName, "GENE-000003");
        });
        return it("should return the correct label names", function() {
          assert.equal(this.responseJSON.results[0].bestLabel, "1");
          return assert.equal(this.responseJSON.results[1].bestLabel, "2");
        });
      });
      describe("for protein parents ONLY PASSES IN STUBS MODE [CSV FORMAT]", function() {
        var body;
        body = {
          displayName: "Protein Parent",
          referenceCodes: "GENE1234\nGENE1111\n"
        };
        before(function(done) {
          this.timeout(20000);
          return request.post({
            url: "http://localhost:" + config.all.server.nodeapi.port + "/api/entitymeta/pickBestLabels/csv",
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
        it("should return the requested displayName", function() {
          return assert.equal(this.responseJSON.displayName, "Protein Parent");
        });
        it("should have the first line query in first result column", function() {
          var res;
          res = this.responseJSON.resultCSV.split('\n');
          return assert.equal(res[1].split(',')[0], "GENE1234");
        });
        it("should have the first line result second result column", function() {
          var res;
          res = this.responseJSON.resultCSV.split('\n');
          return assert.equal(res[1].split(',')[1], "GENE1234");
        });
        it("should have the second line query in first result column", function() {
          var res;
          res = this.responseJSON.resultCSV.split('\n');
          return assert.equal(res[2].split(',')[0], "GENE1111");
        });
        return it("should have the second line result second result column with the code", function() {
          var res;
          res = this.responseJSON.resultCSV.split('\n');
          return assert.equal(res[2].split(',')[1], "1111");
        });
      });
      return describe("for protein parents ONLY PASSES IN STUBS MODE [JSON FORMAT]", function() {
        var body;
        body = {
          displayName: "Protein Parent",
          requests: [
            {
              requestName: "GENE1234"
            }, {
              requestName: "GENE1111"
            }
          ]
        };
        before(function(done) {
          this.timeout(20000);
          return request.post({
            url: "http://localhost:" + config.all.server.nodeapi.port + "/api/entitymeta/pickBestLabels",
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
        it("should return the requested displayName", function() {
          return assert.equal(this.responseJSON.displayName, "Protein Parent");
        });
        it("should return an array of results the same length as the array of requests", function() {
          return assert.equal(this.responseJSON.results.length, 2);
        });
        it("should have request in each results object", function() {
          assert.equal(this.responseJSON.results[0].requestName, "GENE1234");
          return assert.equal(this.responseJSON.results[1].requestName, "GENE1111");
        });
        return it("should have the correct result for each request", function() {
          assert.equal(this.responseJSON.results[0].bestLabel, "GENE1234");
          return assert.equal(this.responseJSON.results[1].bestLabel, "1111");
        });
      });
    });
    return describe("for compound reg", function() {
      describe("when valid small molecule batch names are passed in ONLY PASSES IN STUBS MODE [CSV FORAMT]", function() {
        var body;
        body = {
          displayName: "Corporate Batch ID",
          referenceCodes: "CMPD-0000001-01\nCMPD-0000002-01\n"
        };
        before(function(done) {
          this.timeout(20000);
          return request.post({
            url: "http://localhost:" + config.all.server.nodeapi.port + "/api/entitymeta/pickBestLabels/csv",
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
        it("should return the requested displayName", function() {
          return assert.equal(this.responseJSON.displayName, "Corporate Batch ID");
        });
        it("should have the first line query in first result column", function() {
          var res;
          res = this.responseJSON.resultCSV.split('\n');
          return assert.equal(res[1].split(',')[0], "CMPD-0000001-01");
        });
        return it("should have the first line result second result column", function() {
          var res;
          res = this.responseJSON.resultCSV.split('\n');
          return assert.equal(res[1].split(',')[1], "CMPD-0000001-01");
        });
      });
      describe("when valid small molecule batch names are passed in ONLY PASSES IN STUBS MODE [JSON FORAMT]", function() {
        var body;
        body = {
          displayName: "Corporate Batch ID",
          requests: [
            {
              requestName: "CMPD-0000001-01"
            }, {
              requestName: "CMPD-0000002-01"
            }
          ]
        };
        before(function(done) {
          this.timeout(20000);
          return request.post({
            url: "http://localhost:" + config.all.server.nodeapi.port + "/api/entitymeta/pickBestLabels",
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
        it("should return the requested displayName", function() {
          return assert.equal(this.responseJSON.displayName, "Corporate Batch ID");
        });
        it("should return an array of results the same length as the array of requests", function() {
          return assert.equal(this.responseJSON.results.length, 2);
        });
        it("should have request in each results object", function() {
          assert.equal(this.responseJSON.results[0].requestName, "CMPD-0000001-01");
          return assert.equal(this.responseJSON.results[1].requestName, "CMPD-0000002-01");
        });
        return it("should have the correct result for each request", function() {
          assert.equal(this.responseJSON.results[0].bestLabel, "CMPD-0000001-01");
          return assert.equal(this.responseJSON.results[1].bestLabel, "CMPD-0000002-01");
        });
      });
      describe("when valid small molecule Parent names are passed in ONLY PASSES IN STUBS MODE [CSV FORMAT]", function() {
        var body;
        body = {
          displayName: "Corporate Parent ID",
          referenceCodes: "CMPD-0000001\nCMPD-001111"
        };
        before(function(done) {
          this.timeout(20000);
          return request.post({
            url: "http://localhost:" + config.all.server.nodeapi.port + "/api/entitymeta/pickBestLabels/csv",
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
        it("should return the requested displayName", function() {
          return assert.equal(this.responseJSON.displayName, "Corporate Parent ID");
        });
        it("should have the first line query in first result column", function() {
          var res;
          res = this.responseJSON.resultCSV.split('\n');
          return assert.equal(res[1].split(',')[0], "CMPD-0000001");
        });
        it("should have the first line result second result column", function() {
          var res;
          res = this.responseJSON.resultCSV.split('\n');
          return assert.equal(res[1].split(',')[1], "CMPD-0000001");
        });
        it("should have the second line query in first result column", function() {
          var res;
          res = this.responseJSON.resultCSV.split('\n');
          return assert.equal(res[2].split(',')[0], "CMPD-001111");
        });
        return it("should have the second line result second result column with no result", function() {
          var res;
          res = this.responseJSON.resultCSV.split('\n');
          return assert.equal(res[2].split(',')[1], "1111");
        });
      });
      return describe("when valid small molecule Parent names are passed in ONLY PASSES IN STUBS MODE [JSON FORMAT]", function() {
        var body;
        body = {
          displayName: "Corporate Parent ID",
          requests: [
            {
              requestName: "CMPD-0000001"
            }, {
              requestName: "CMPD-001111"
            }
          ]
        };
        before(function(done) {
          this.timeout(20000);
          return request.post({
            url: "http://localhost:" + config.all.server.nodeapi.port + "/api/entitymeta/pickBestLabels",
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
        it("should return the requested displayName", function() {
          return assert.equal(this.responseJSON.displayName, "Corporate Parent ID");
        });
        it("should return an array of results the same length as the array of requests", function() {
          return assert.equal(this.responseJSON.results.length, 2);
        });
        it("should have request in each results object", function() {
          assert.equal(this.responseJSON.results[0].requestName, "CMPD-0000001");
          return assert.equal(this.responseJSON.results[1].requestName, "CMPD-001111");
        });
        return it("should have the correct result for each request", function() {
          assert.equal(this.responseJSON.results[0].bestLabel, "CMPD-0000001");
          return assert.equal(this.responseJSON.results[1].bestLabel, "1111");
        });
      });
    });
  });

  describe("searchForEntities service test", function() {
    describe("for lsThings with a single match (entrez genes) ONLY PASSES IN LIVE MODE [JSON FORMAT]", function() {
      var body;
      body = {
        requestText: "A1BG"
      };
      before(function(done) {
        this.timeout(20000);
        return request.post({
          url: "http://localhost:" + config.all.server.nodeapi.port + "/api/entitymeta/searchForEntities",
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
      it("should return an object with the correct fields", function() {
        return assert(this.responseJSON.results != null);
      });
      it("should return the correct number of results", function() {
        return assert.equal(this.responseJSON.results.length, 1);
      });
      return it("should return information about possible matches", function() {
        assert.equal(this.responseJSON.results[0].displayName, "Gene ID");
        assert.equal(this.responseJSON.results[0].requestText, "A1BG");
        assert.equal(this.responseJSON.results[0].bestLabel, "1");
        return assert.equal(this.responseJSON.results[0].referenceCode, "GENE-000002");
      });
    });
    describe("for lsThings with multiple matches ONLY PASSES IN STUBS MODE [JSON FORMAT]", function() {
      var body;
      body = {
        requestText: "1111"
      };
      before(function(done) {
        this.timeout(20000);
        return request.post({
          url: "http://localhost:" + config.all.server.nodeapi.port + "/api/entitymeta/searchForEntities",
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
      it("should return an object with the correct fields", function() {
        return assert(this.responseJSON.results != null);
      });
      it("should return the correct number of results", function() {
        return assert.equal(this.responseJSON.results.length, 3);
      });
      it("should return correct information about the matches", function() {
        assert.equal(this.responseJSON.results[0].requestText, "1111");
        assert.equal(this.responseJSON.results[0].bestLabel, "1111");
        assert.equal(this.responseJSON.results[0].referenceCode, "GENE1111");
        assert.equal(this.responseJSON.results[1].requestText, "1111");
        assert.equal(this.responseJSON.results[1].bestLabel, "1111");
        assert.equal(this.responseJSON.results[1].referenceCode, "GENE1111");
        assert.equal(this.responseJSON.results[2].requestText, "1111");
        assert.equal(this.responseJSON.results[2].bestLabel, "1111");
        return assert.equal(this.responseJSON.results[2].referenceCode, "GENE1111");
      });
      return it("should find a match for each type of lsThing", function() {
        assert(_.isMatch(this.responseJSON.results, {
          "displayName": "Gene ID"
        }));
        assert(_.isMatch(this.responseJSON.results, {
          "displayName": "Protein Batch"
        }));
        return assert(_.isMatch(this.responseJSON.results, {
          "displayName": "Protein Parent "
        }));
      });
    });
    return describe("for compoundReg with multiple matches ONLY PASSES IN STUBS MODE [JSON FORMAT]", function() {
      var body;
      body = {
        requestText: "673874"
      };
      before(function(done) {
        this.timeout(20000);
        return request.post({
          url: "http://localhost:" + config.all.server.nodeapi.port + "/api/entitymeta/searchForEntities",
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
      it("should return an object with the correct fields", function() {
        return assert(this.responseJSON.results != null);
      });
      it("should return the correct number of results", function() {
        return assert.equal(this.responseJSON.results.length, 2);
      });
      it("should return correct information about the matches", function() {
        assert(_.isMatch(this.responseJSON.results, {
          requestText: "673874"
        }));
        assert(_.isMatch(this.responseJSON.results, {
          bestLabel: "1234::7"
        }));
        assert(_.isMatch(this.responseJSON.results, {
          referenceCode: "DNS000001234::7"
        }));
        assert(_.isMatch(this.responseJSON.results, {
          requestText: "673874"
        }));
        assert(_.isMatch(this.responseJSON.results, {
          bestLabel: "1234::7"
        }));
        return assert(_.isMatch(this.responseJSON.results, {
          referenceCode: "DNS000001234"
        }));
      });
      return it("should find a match for each type of compound Reg entity", function() {
        assert(_.isMatch(this.responseJSON.results, {
          "displayName": "Corporate Parent ID"
        }));
        return assert(_.isMatch(this.responseJSON.results, {
          "displayName": "Corporate Batch ID"
        }));
      });
    });
  });

}).call(this);
