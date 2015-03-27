(function() {
  var assert, config, fs, parseResponse, protocolServiceTestJSON, request, _;

  assert = require('assert');

  request = require('request');

  _ = require('underscore');

  protocolServiceTestJSON = require('../testFixtures/ProtocolServiceTestJSON.js');

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

  describe("Protocol Service testing", function() {
    describe("Protocol CRUD testing", function() {
      describe("when fetching Protocol stub by codename", function() {
        before(function(done) {
          return request("http://localhost:" + config.all.server.nodeapi.port + "/api/protocols/codeName/PROT-00000124", (function(_this) {
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
          return request("http://localhost:" + config.all.server.nodeapi.port + "/api/protocols/1", (function(_this) {
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
      describe("when saving a new protocol", function() {
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
        return describe("file handling", function() {
          it("should return the first fileValue moved to the correct location", function() {
            return assert.equal(this.responseJSON.lsStates[0].lsValues[1].fileValue, "protocols/PROT-00000001/TestFile.mol");
          });
          it("should return the first fileValue with the comment filled with the file name", function() {
            return assert.equal(this.responseJSON.lsStates[0].lsValues[1].comments, "TestFile.mol");
          });
          it("should return the second fileValue moved to the correct location", function() {
            return assert.equal(this.responseJSON.lsStates[0].lsValues[2].fileValue, "protocols/PROT-00000001/Test.csv");
          });
          it("should return the second fileValue with the comment filled with the file name", function() {
            return assert.equal(this.responseJSON.lsStates[0].lsValues[2].comments, "Test.csv");
          });
          it("should move the first file to the correct location", function() {
            return fs.unlink(config.all.server.datafiles.relative_path + "/protocols/PROT-00000001/TestFile.mol", (function(_this) {
              return function(err) {
                return assert.equal(err, null);
              };
            })(this));
          });
          return it("should move the second file to the correct location", function() {
            return fs.unlink(config.all.server.datafiles.relative_path + "/protocols/PROT-00000001/Test.csv", (function(_this) {
              return function(err) {
                return assert.equal(err, null);
              };
            })(this));
          });
        });
      });
      return describe("when updating a protocol", function() {
        before(function(done) {
          var updatedData;
          this.timeout(20000);
          this.testFile1Path = config.all.server.datafiles.relative_path + "/TestFile.mol";
          this.testFile2Path = config.all.server.datafiles.relative_path + "/Test.csv";
          fs.writeFileSync(this.testFile1Path, "key,value\nflavor,sweet");
          fs.writeFileSync(this.testFile2Path, "key,value\nmolecule,CCC");
          updatedData = protocolServiceTestJSON.fullSavedProtocol;
          updatedData.lsStates[0].lsValues[1].id = null;
          updatedData.lsStates[0].lsValues[2].id = null;
          this.originalTransatcionId = updatedData.lsTransaction;
          return request.put({
            url: "http://localhost:" + config.all.server.nodeapi.port + "/api/protocols/1234",
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
        return describe("file handling", function() {
          it("should return the first fileValue moved to the correct location", function() {
            return assert.equal(this.responseJSON.lsStates[0].lsValues[1].fileValue, "protocols/PROT-00000001/TestFile.mol");
          });
          it("should return the first fileValue with the comment filled with the file name", function() {
            return assert.equal(this.responseJSON.lsStates[0].lsValues[1].comments, "TestFile.mol");
          });
          it("should return the second fileValue moved to the correct location", function() {
            return assert.equal(this.responseJSON.lsStates[0].lsValues[2].fileValue, "protocols/PROT-00000001/Test.csv");
          });
          it("should return the second fileValue with the comment filled with the file name", function() {
            return assert.equal(this.responseJSON.lsStates[0].lsValues[2].comments, "Test.csv");
          });
          it("should move the first file to the correct location", function() {
            return fs.unlink(config.all.server.datafiles.relative_path + "/protocols/PROT-00000001/TestFile.mol", (function(_this) {
              return function(err) {
                return assert.equal(err, null);
              };
            })(this));
          });
          return it("should move the second file to the correct location", function() {
            return fs.unlink(config.all.server.datafiles.relative_path + "/protocols/PROT-00000001/Test.csv", (function(_this) {
              return function(err) {
                return assert.equal(err, null);
              };
            })(this));
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
