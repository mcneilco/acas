(function() {
  var _, assert, config, fs, parseResponse, protocolServiceTestJSON, request;

  assert = require('assert');

  request = require('request');

  _ = require('underscore');

  protocolServiceTestJSON = require('../testFixtures/ProtocolServiceTestJSON.js');

  fs = require('fs');

  config = require('../.././compiled/conf.js');

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

  describe("Protocol Service testing", function() {
    describe("Protocol CRUD testing", function() {
      describe("when fetching Protocol stub by codename", function() {
        before(function(done) {
          return request("http://localhost:" + config.all.server.nodeapi.port + "/api/protocols/codeName/PROT-00000001", (function(_this) {
            return function(error, response, body) {
              _this.responseJSON = body;
              _this.response = response;
              return done();
            };
          })(this));
        });
        return it("should return a protocol", function() {
          var responseJSON;
          responseJSON = parseResponse(this.response.body);
          return assert.equal(responseJSON.codeName, "PROT-00000001");
        });
      });
      describe("when fetching full Protocol by id", function() {
        before(function(done) {
          return request("http://localhost:" + config.all.server.nodeapi.port + "/api/protocols/723631", (function(_this) {
            return function(error, response, body) {
              _this.responseJSON = body;
              _this.response = response;
              return done();
            };
          })(this));
        });
        return it("should return a protocol", function() {
          var responseJSON;
          responseJSON = parseResponse(this.response.body);
          return assert.equal(responseJSON.codeName === "PROT-00000001" || responseJSON.codeName === "PROT-00000014", true);
        });
      });
      return describe("when saving a new protocol", function() {
        before(function(done) {
          this.timeout(20000);
          this.testFile1Path = config.all.server.datafiles.relative_path + "/TestFile.mol";
          this.testFile2Path = config.all.server.datafiles.relative_path + "/Test.csv";
          fs.writeFileSync(this.testFile1Path, "key,value\nflavor,sweet");
          fs.writeFileSync(this.testFile2Path, "key,value\nmolecule,CCC");
          return request.post({
            url: "http://localhost:" + config.all.server.nodeapi.port + "/api/protocols",
            json: true,
            body: protocolServiceTestJSON.protocolToSave
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
          it("should return a protocol", function() {
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
            correctVal = "protocols/" + this.codeName + "/TestFile.mol";
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
            correctVal = "protocols/" + this.codeName + "/Test.csv";
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
            correctVal = "/protocols/" + this.codeName + "/TestFile.mol";
            return fs.unlink(config.all.server.datafiles.relative_path + correctVal, (function(_this) {
              return function(err) {
                return assert.equal(err, null);
              };
            })(this));
          });
          return it("should move the second file to the correct location", function() {
            var correctVal;
            correctVal = "/protocols/" + this.codeName + "/Test.csv";
            return fs.unlink(config.all.server.datafiles.relative_path + correctVal, (function(_this) {
              return function(err) {
                return assert.equal(err, null);
              };
            })(this));
          });
        });
        return describe("when updating a protocol", function() {
          before(function(done) {
            var fileVals, i, len, val;
            this.timeout(20000);
            this.testFile1Path = config.all.server.datafiles.relative_path + "/TestFile.mol";
            this.testFile2Path = config.all.server.datafiles.relative_path + "/Test.csv";
            fs.writeFileSync(this.testFile1Path, "key,value\nflavor,sweet");
            fs.writeFileSync(this.testFile2Path, "key,value\nmolecule,CCC");
            fileVals = this.responseJSON.lsStates[0].lsValues.filter(function(value) {
              return value.fileValue != null;
            });
            for (i = 0, len = fileVals.length; i < len; i++) {
              val = fileVals[i];
              val.fileValue = val.comments;
              val.comments = null;
              val.id = null;
              val.version = null;
            }
            this.responseJSON.lsTransaction = 1;
            this.originalTransatcionId = this.responseJSON.lsTransaction;
            return request.put({
              url: "http://localhost:" + config.all.server.nodeapi.port + "/api/protocols/" + this.responseJSON.id,
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
            it("should return a protocol", function() {
              return assert.equal(this.responseJSON.codeName === null, false);
            });
            it("should have a new trans at the top level", function() {
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
          describe("file handling", function() {
            it("should return the first fileValue moved to the correct location", function() {
              var correctVal, fileVals;
              correctVal = "protocols/" + this.codeName + "/TestFile.mol";
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
              correctVal = "protocols/" + this.codeName + "/Test.csv";
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
              correctVal = "/protocols/" + this.codeName + "/TestFile.mol";
              return fs.unlink(config.all.server.datafiles.relative_path + correctVal, (function(_this) {
                return function(err) {
                  return assert.equal(err, null);
                };
              })(this));
            });
            return it("should move the second file to the correct location", function() {
              var correctVal;
              correctVal = "/protocols/" + this.codeName + "/Test.csv";
              return fs.unlink(config.all.server.datafiles.relative_path + correctVal, (function(_this) {
                return function(err) {
                  return assert.equal(err, null);
                };
              })(this));
            });
          });
          return describe("when deleting a protocol", function() {
            before(function(done) {
              return request.del({
                url: "http://localhost:" + config.all.server.nodeapi.port + "/api/protocols/browser/" + this.id,
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
            return it("should delete the protocol", function() {
              console.log(this.responseJSON);
              console.log(this.response);
              return assert.equal(this.responseJSON.codeValue === 'deleted' || this.responseJSON.ignored === true, true);
            });
          });
        });
      });
    });
    return describe("Protocol related services", function() {
      describe('when protocol labels service called', function() {
        before(function(done) {
          return request("http://localhost:" + config.all.server.nodeapi.port + "/api/protocolLabels", (function(_this) {
            return function(error, response, body) {
              _this.responseJSON = body;
              _this.response = response;
              return done();
            };
          })(this));
        });
        it('should return an array of lsLabels', function() {
          var responseJSON;
          responseJSON = parseResponse(this.response.body);
          return assert.equal(responseJSON.length > 0, true);
        });
        return it('labels should include a protocol code', function() {
          var responseJSON;
          responseJSON = parseResponse(this.response.body);
          return assert.equal(responseJSON[0].protocol.codeName.indexOf("PROT-") > -1, true);
        });
      });
      describe("Protocol status code", function() {
        return describe('when protocol code service called', function() {
          before(function(done) {
            return request("http://localhost:" + config.all.server.nodeapi.port + "/api/protocolCodes", (function(_this) {
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
          it('should a hash with ignore defined', function() {
            var responseJSON;
            responseJSON = parseResponse(this.response.body);
            return assert.equal(responseJSON[0].ignored !== void 0, true);
          });
          it('should return some names without PK', function() {
            var responseJSON;
            responseJSON = parseResponse(this.response.body);
            return assert.equal(responseJSON[responseJSON.length - 1].name.indexOf("PK") === -1, true);
          });
          return it('should not return protocols where protocol itself is set to ignore', function() {
            var matches, responseJSON;
            responseJSON = parseResponse(this.response.body);
            matches = _.filter(responseJSON, function(label) {
              return label.name === "Ignore this protocol";
            });
            return assert.equal(matches.length === 0, true);
          });
        });
      });
      describe('when protocol code list service called with label filtering option', function() {
        describe("With matching case", function() {
          return before(function(done) {
            var responseJSON;
            request("http://localhost:" + config.all.server.nodeapi.port + "/api/protocolCodes/?protocolName=PK", (function(_this) {
              return function(error, response, body) {
                _this.responseJSON = body;
                _this.response = response;
                return done();
              };
            })(this));
            it('should only return names with PK', function() {});
            responseJSON = parseResponse(this.response.body);
            return assert.equal(responseJSON[responseJSON.length - 1].name.indexOf("PK") > -1, true);
          });
        });
        return describe("With non-matching case", function() {
          return before(function(done) {
            var responseJSON;
            request("http://localhost:" + config.all.server.nodeapi.port + "/api/protocolCodes/?protocolName=pk", (function(_this) {
              return function(error, response, body) {
                _this.responseJSON = body;
                _this.response = response;
                return done();
              };
            })(this));
            it('should only return names with PK', function() {});
            responseJSON = parseResponse(this.response.body);
            return assert.equal(responseJSON[responseJSON.length - 1].name.indexOf("PK") > -1, true);
          });
        });
      });
      describe('when protocol code list service called with protocol lsKind filtering option', function() {
        return describe("With non-matching case", function() {
          before(function(done) {
            return request("http://localhost:" + config.all.server.nodeapi.port + "/api/protocolCodes/?protocolKind=KD", (function(_this) {
              return function(error, response, body) {
                _this.responseJSON = body;
                _this.response = response;
                return done();
              };
            })(this));
          });
          return it('should only return names with KD', function() {
            var responseJSON;
            responseJSON = parseResponse(this.response.body);
            return assert.equal(responseJSON[responseJSON.length - 1].name.indexOf("KD") > -1, true);
          });
        });
      });
      return describe('when protocol kind list service called', function() {
        return describe("With non-matching case", function() {
          before(function(done) {
            return request("http://localhost:" + config.all.server.nodeapi.port + "/api/protocolKindCodes", (function(_this) {
              return function(error, response, body) {
                _this.responseJSON = body;
                _this.response = response;
                return done();
              };
            })(this));
          });
          it('should return an array of protocolKinds', function() {
            var responseJSON;
            responseJSON = parseResponse(this.response.body);
            return assert.equal(responseJSON.length > 0, true);
          });
          return it('should array of protocolKinds', function() {
            var responseJSON;
            responseJSON = parseResponse(this.response.body);
            assert.equal(responseJSON[0].code !== void 0, true);
            assert.equal(responseJSON[0].name !== void 0, true);
            return assert.equal(responseJSON[0].ignored !== void 0, true);
          });
        });
      });
    });
  });

}).call(this);
