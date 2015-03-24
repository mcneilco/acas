(function() {
  var assert, config, experimentServiceTestJSON, fs, parseResponse, request, _;

  assert = require('assert');

  request = require('request');

  _ = require('underscore');

  experimentServiceTestJSON = require('../testFixtures/ExperimentServiceTestJSON.js');

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

  describe("Experiment Service testing", function() {
    describe("Experiment CRUD testing", function() {
      describe("when fetching Experiment stub by codename", function() {
        before(function(done) {
          return request("http://localhost:" + config.all.server.nodeapi.port + "/api/experiments/codeName/EXPT-00000124", (function(_this) {
            return function(error, response, body) {
              _this.responseJSON = body;
              _this.response = response;
              return done();
            };
          })(this));
        });
        return it("should return a experiment", function() {
          var responseJSON;
          responseJSON = parseResponse(this.response.body);
          return assert.equal(responseJSON.codeName, "EXPT-00000001");
        });
      });
      describe("when fetching Experiment stub by name", function() {
        before(function(done) {
          return request("http://localhost:" + config.all.server.nodeapi.port + "/api/experiments/experimentName/Test Experiment 1", (function(_this) {
            return function(error, response, body) {
              _this.responseJSON = body;
              _this.response = response;
              return done();
            };
          })(this));
        });
        return it("should return a experiment", function() {
          var responseJSON;
          responseJSON = parseResponse(this.response.body);
          return assert.equal(responseJSON.codeName, "EXPT-00000001");
        });
      });
      describe("when fetching Experiment stub by protocol code", function() {
        before(function(done) {
          return request("http://localhost:" + config.all.server.nodeapi.port + "/api/experiments/protocolCodename/PROT-00000005", (function(_this) {
            return function(error, response, body) {
              _this.responseJSON = body;
              _this.response = response;
              return done();
            };
          })(this));
        });
        return it("should return a experiment", function() {
          var responseJSON;
          responseJSON = parseResponse(this.response.body);
          return assert.equal(responseJSON.codeName, "EXPT-00000001");
        });
      });
      describe("when fetching full Experiment by id", function() {
        before(function(done) {
          return request("http://localhost:" + config.all.server.nodeapi.port + "/api/experiments/1", (function(_this) {
            return function(error, response, body) {
              _this.responseJSON = body;
              _this.response = response;
              return done();
            };
          })(this));
        });
        return it("should return a experiment", function() {
          var responseJSON;
          responseJSON = parseResponse(this.response.body);
          return assert.equal(responseJSON.codeName, "EXPT-00000001");
        });
      });
      describe("when saving a new experiment", function() {
        before(function(done) {
          this.timeout(20000);
          this.testFile1Path = config.all.server.datafiles.relative_path + "/TestFile.mol";
          this.testFile2Path = config.all.server.datafiles.relative_path + "/Test.csv";
          fs.writeFileSync(this.testFile1Path, "key,value\nflavor,sweet");
          fs.writeFileSync(this.testFile2Path, "key,value\nmolecule,CCC");
          return request.post({
            url: "http://localhost:" + config.all.server.nodeapi.port + "/api/experiments",
            json: true,
            body: experimentServiceTestJSON.experimentToSave
          }, (function(_this) {
            return function(error, response, body) {
              _this.serverError = error;
              _this.responseJSON = body;
              return done();
            };
          })(this));
        });
        after(function() {
          fs.unlink(this.testFile1Path);
          return fs.unlink(this.testFile2Path);
        });
        it("should return a experiment", function() {
          return assert.equal(this.responseJSON.codeName === null, false);
        });
        it("should return the first fileValue moved to the correct location", function() {
          return assert.equal(this.responseJSON.lsStates[0].lsValues[0].fileValue, "experiments/EXPT-00000001/TestFile.mol");
        });
        it("should return the first fileValue with the comment filled with the file name", function() {
          return assert.equal(this.responseJSON.lsStates[0].lsValues[0].comments, "TestFile.mol");
        });
        it("should return the second fileValue moved to the correct location", function() {
          return assert.equal(this.responseJSON.lsStates[0].lsValues[1].fileValue, "experiments/EXPT-00000001/Test.csv");
        });
        it("should return the second fileValue with the comment filled with the file name", function() {
          return assert.equal(this.responseJSON.lsStates[0].lsValues[1].comments, "Test.csv");
        });
        it("should move the first file to the correct location", function() {
          return fs.unlink(config.all.server.datafiles.relative_path + "/experiments/EXPT-00000001/TestFile.mol", (function(_this) {
            return function(err) {
              return assert.equal(err, null);
            };
          })(this));
        });
        return it("should move the second file to the correct location", function() {
          return fs.unlink(config.all.server.datafiles.relative_path + "/experiments/EXPT-00000001/Test.csv", (function(_this) {
            return function(err) {
              return assert.equal(err, null);
            };
          })(this));
        });
      });
      return describe("when updating a experiment", function() {
        before(function(done) {
          var updatedData;
          this.timeout(20000);
          this.testFile1Path = config.all.server.datafiles.relative_path + "/TestFile.mol";
          this.testFile2Path = config.all.server.datafiles.relative_path + "/Test.csv";
          fs.writeFileSync(this.testFile1Path, "key,value\nflavor,sweet");
          fs.writeFileSync(this.testFile2Path, "key,value\nmolecule,CCC");
          updatedData = experimentServiceTestJSON.fullExperimentFromServer;
          updatedData.lsStates[1].lsValues[1].id = null;
          updatedData.lsStates[1].lsValues[2].id = null;
          return request.put({
            url: "http://localhost:" + config.all.server.nodeapi.port + "/api/experiments/1234",
            json: true,
            body: updatedData
          }, (function(_this) {
            return function(error, response, body) {
              _this.serverError = error;
              _this.responseJSON = body;
              return done();
            };
          })(this));
        });
        after(function() {
          fs.unlink(this.testFile1Path);
          return fs.unlink(this.testFile2Path);
        });
        it("should return a experiment", function() {
          return assert.equal(this.responseJSON.codeName === null, false);
        });
        it("should return the first fileValue moved to the correct location", function() {
          return assert.equal(this.responseJSON.lsStates[1].lsValues[1].fileValue, "experiments/EXPT-00000001/TestFile.mol");
        });
        it("should return the first fileValue with the comment filled with the file name", function() {
          return assert.equal(this.responseJSON.lsStates[1].lsValues[1].comments, "TestFile.mol");
        });
        it("should return the second fileValue moved to the correct location", function() {
          return assert.equal(this.responseJSON.lsStates[1].lsValues[2].fileValue, "experiments/EXPT-00000001/Test.csv");
        });
        it("should return the second fileValue with the comment filled with the file name", function() {
          return assert.equal(this.responseJSON.lsStates[1].lsValues[2].comments, "Test.csv");
        });
        it("should move the first file to the correct location", function() {
          return fs.unlink(config.all.server.datafiles.relative_path + "/experiments/EXPT-00000001/TestFile.mol", (function(_this) {
            return function(err) {
              return assert.equal(err, null);
            };
          })(this));
        });
        return it("should move the second file to the correct location", function() {
          return fs.unlink(config.all.server.datafiles.relative_path + "/experiments/EXPT-00000001/Test.csv", (function(_this) {
            return function(err) {
              return assert.equal(err, null);
            };
          })(this));
        });
      });
    });
    describe("Experiment status code", function() {
      return describe('when experiment status code service called', function() {
        before(function(done) {
          return request("http://localhost:" + config.all.server.nodeapi.port + "/api/codetables/experiment/status", (function(_this) {
            return function(error, response, body) {
              _this.responseJSON = body;
              _this.response = response;
              return done();
            };
          })(this));
        });
        it('should return an array of status codes', function() {
          var responseJSON;
          responseJSON = parseResponse(this.response.body);
          return assert.equal(responseJSON.length > 0, true);
        });
        it('should a hash with code defined', function() {
          var responseJSON;
          responseJSON = parseResponse(this.response.body);
          return assert.equal(responseJSON[0].code !== void 0, true);
        });
        it('should a hash with name defined', function() {
          var responseJSON;
          responseJSON = parseResponse(this.response.body);
          return assert.equal(responseJSON[0].name !== void 0, true);
        });
        return it('should a hash with ignore defined', function() {
          var responseJSON;
          responseJSON = parseResponse(this.response.body);
          return assert.equal(responseJSON[0].ignored !== void 0, true);
        });
      });
    });
    return describe("Experiment result viewer url", function() {
      return describe('when experiment result viewer url service called', function() {
        before(function(done) {
          return request("http://localhost:" + config.all.server.nodeapi.port + "/api/experiments/resultViewerURL/test", (function(_this) {
            return function(error, response, body) {
              _this.responseJSON = body;
              _this.response = response;
              return done();
            };
          })(this));
        });
        return it('should return a result viewer url', function() {
          var responseJSON;
          responseJSON = parseResponse(this.response.body);
          return assert.equal(responseJSON.resultViewerURL.indexOf("runseurat") > -1, true);
        });
      });
    });
  });

}).call(this);
