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
          return request("http://localhost:" + config.all.server.nodeapi.port + "/api/experiments/codeName/EXPT-00000018", (function(_this) {
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
          return assert.equal(responseJSON.codeName === "EXPT-00000001" || responseJSON.codeName === "EXPT-00000018", true);
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
          responseJSON = parseResponse(this.responseJSON)[0];
          return assert.equal(responseJSON.codeName === "EXPT-00000001" || responseJSON.codeName === "EXPT-00000018", true);
        });
      });
      describe("when fetching full Experiment by id", function() {
        before(function(done) {
          return request("http://localhost:" + config.all.server.nodeapi.port + "/api/experiments/2183", (function(_this) {
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
          return assert.equal(responseJSON.codeName === "EXPT-00000001" || responseJSON.codeName === "EXPT-00000018", true);
        });
      });
      return describe("when saving a new experiment", function() {
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
              _this.codeName = _this.responseJSON.codeName;
              _this.id = _this.responseJSON.id;
              return done();
            };
          })(this));
        });
        after(function() {
          fs.unlink(this.testFile1Path);
          return fs.unlink(this.testFile2Path);
        });
        describe("basic saving", function() {
          it("should return a experiment", function() {
            return assert.equal(this.responseJSON.codeName === null, false);
          });
          it("should have a trans at the top level", function() {
            return assert.equal(isNaN(parseInt(this.responseJSON.lsTransaction)), false);
          });
          it("should have a trans in the labels", function() {
            return assert.equal(isNaN(parseInt(this.responseJSON.lsLabels[0].lsTransaction)), false);
          });
          it("should have a trans in the states", function() {
            return assert.equal(isNaN(parseInt(this.responseJSON.lsStates[0].lsTransaction)), false);
          });
          return it("should have a trans in the values", function() {
            return assert.equal(isNaN(parseInt(this.responseJSON.lsStates[0].lsValues[0].lsTransaction)), false);
          });
        });
        describe("file handling", function() {
          it("should return the first fileValue moved to the correct location", function() {
            var correctVal, fileVals;
            correctVal = "experiments/" + this.codeName + "/TestFile.mol";
            fileVals = this.responseJSON.lsStates[0].lsValues.filter(function(value) {
              return (value.fileValue != null) && value.fileValue === correctVal;
            });
            return assert.equal(fileVals.length > 0, true);
          });
          it("should return the first fileValue with the comment filled with the file name", function() {
            var fileVals;
            fileVals = this.responseJSON.lsStates[0].lsValues.filter(function(value) {
              return (value.fileValue != null) && value.comments === "TestFile.mol";
            });
            return assert.equal(fileVals.length > 0, true);
          });
          it("should return the second fileValue moved to the correct location", function() {
            var correctVal, fileVals;
            correctVal = "experiments/" + this.codeName + "/Test.csv";
            fileVals = this.responseJSON.lsStates[0].lsValues.filter(function(value) {
              return (value.fileValue != null) && value.fileValue === correctVal;
            });
            return assert.equal(fileVals.length > 0, true);
          });
          it("should return the second fileValue with the comment filled with the file name", function() {
            var fileVals;
            fileVals = this.responseJSON.lsStates[0].lsValues.filter(function(value) {
              return (value.fileValue != null) && value.comments === "Test.csv";
            });
            return assert.equal(fileVals.length > 0, true);
          });
          it("should move the first file to the correct location", function() {
            var correctVal;
            correctVal = "/experiments/" + this.codeName + "/TestFile.mol";
            return fs.unlink(config.all.server.datafiles.relative_path + correctVal, (function(_this) {
              return function(err) {
                return assert.equal(err, null);
              };
            })(this));
          });
          return it("should move the second file to the correct location", function() {
            var correctVal;
            correctVal = "/experiments/" + this.codeName + "/Test.csv";
            return fs.unlink(config.all.server.datafiles.relative_path + correctVal, (function(_this) {
              return function(err) {
                return assert.equal(err, null);
              };
            })(this));
          });
        });
        describe("when updating a experiment", function() {
          before(function(done) {
            var fileVals, val, _i, _len;
            this.timeout(20000);
            this.testFile1Path = config.all.server.datafiles.relative_path + "/TestFile.mol";
            this.testFile2Path = config.all.server.datafiles.relative_path + "/Test.csv";
            fs.writeFileSync(this.testFile1Path, "key,value\nflavor,sweet");
            fs.writeFileSync(this.testFile2Path, "key,value\nmolecule,CCC");
            fileVals = this.responseJSON.lsStates[0].lsValues.filter(function(value) {
              return value.fileValue != null;
            });
            for (_i = 0, _len = fileVals.length; _i < _len; _i++) {
              val = fileVals[_i];
              val.fileValue = val.comments;
              val.comments = null;
              val.id = null;
              val.version = null;
            }
            this.responseJSON.lsTransaction = 1;
            this.originalTransatcionId = this.responseJSON.lsTransaction;
            return request.put({
              url: "http://localhost:" + config.all.server.nodeapi.port + "/api/experiments/" + this.responseJSON.id,
              json: true,
              body: this.responseJSON
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
          describe("basic saving", function() {
            it("should return a experiment", function() {
              return assert.equal(this.responseJSON.codeName === null, false);
            });
            it("should have a new trans at the top level", function() {
              console.log(this.responseJSON);
              return assert.equal(this.responseJSON.lsTransaction === this.originalTransatcionId, false);
            });
            it("should have a trans in the labels", function() {
              return assert.equal(isNaN(parseInt(this.responseJSON.lsLabels[0].lsTransaction)), false);
            });
            it("should have a trans in the states", function() {
              return assert.equal(isNaN(parseInt(this.responseJSON.lsStates[0].lsTransaction)), false);
            });
            return it("should have a trans in the values", function() {
              return assert.equal(isNaN(parseInt(this.responseJSON.lsStates[0].lsValues[0].lsTransaction)), false);
            });
          });
          return describe("file handling", function() {
            it("should return the first fileValue moved to the correct location", function() {
              var correctVal, fileVals;
              correctVal = "experiments/" + this.codeName + "/TestFile.mol";
              fileVals = this.responseJSON.lsStates[0].lsValues.filter(function(value) {
                return (value.fileValue != null) && value.fileValue === correctVal;
              });
              return assert.equal(fileVals.length > 0, true);
            });
            it("should return the first fileValue with the comment filled with the file name", function() {
              var fileVals;
              fileVals = this.responseJSON.lsStates[0].lsValues.filter(function(value) {
                return (value.fileValue != null) && value.comments === "TestFile.mol";
              });
              return assert.equal(fileVals.length > 0, true);
            });
            it("should return the second fileValue moved to the correct location", function() {
              var correctVal, fileVals;
              correctVal = "experiments/" + this.codeName + "/Test.csv";
              fileVals = this.responseJSON.lsStates[0].lsValues.filter(function(value) {
                return (value.fileValue != null) && value.fileValue === correctVal;
              });
              return assert.equal(fileVals.length > 0, true);
            });
            it("should return the second fileValue with the comment filled with the file name", function() {
              var fileVals;
              fileVals = this.responseJSON.lsStates[0].lsValues.filter(function(value) {
                return (value.fileValue != null) && value.comments === "Test.csv";
              });
              return assert.equal(fileVals.length > 0, true);
            });
            it("should move the first file to the correct location", function() {
              var correctVal;
              correctVal = "/experiments/" + this.codeName + "/TestFile.mol";
              return fs.unlink(config.all.server.datafiles.relative_path + correctVal, (function(_this) {
                return function(err) {
                  return assert.equal(err, null);
                };
              })(this));
            });
            return it("should move the second file to the correct location", function() {
              var correctVal;
              correctVal = "/experiments/" + this.codeName + "/Test.csv";
              return fs.unlink(config.all.server.datafiles.relative_path + correctVal, (function(_this) {
                return function(err) {
                  return assert.equal(err, null);
                };
              })(this));
            });
          });
        });
        return describe("when deleting a protocol", function() {
          before(function(done) {
            return request.del({
              url: "http://localhost:" + config.all.server.nodeapi.port + "/api/experiments/" + this.id,
              json: true
            }, (function(_this) {
              return function(error, response, body) {
                _this.serverError = error;
                _this.response = response;
                _this.responseJSON = body;
                return done();
              };
            })(this));
          });
          return it("should delete the experiment", function() {
            var responseJSON;
            responseJSON = parseResponse(this.responseJSON);
            return assert.equal(this.responseJSON.codeValue === 'deleted' || this.responseJSON.ignored === true, true);
          });
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
