(function() {
  var assert, config, fs, parseResponse, request, thingServiceTestJSON, _;

  assert = require('assert');

  request = require('request');

  _ = require('underscore');

  thingServiceTestJSON = require('../testFixtures/thingServiceTestJSON.js');

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

  describe("Thing Service testing", function() {
    describe("Thing CRUD testing", function() {
      describe("when fetching Thing by codename", function() {
        before(function(done) {
          return request("http://localhost:" + config.all.server.nodeapi.port + "/api/things/parent/thing/PT00001", (function(_this) {
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
          return assert.equal(responseJSON.codeName, "PT00001");
        });
      });
      describe("when saving a new thing parent", function() {
        before(function(done) {
          this.timeout(20000);
          this.testFile1Path = config.all.server.datafiles.relative_path + "/TestFile.mol";
          this.testFile2Path = config.all.server.datafiles.relative_path + "/Test.csv";
          fs.writeFileSync(this.testFile1Path, "key,value\nflavor,sweet");
          fs.writeFileSync(this.testFile2Path, "key,value\nmolecule,CCC");
          return request.post({
            url: "http://localhost:" + config.all.server.nodeapi.port + "/api/things/parent/thing",
            json: true,
            body: thingServiceTestJSON.thingParent
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
          it("should return a thing", function() {
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
            return assert.equal(this.responseJSON.lsStates[0].lsValues[3].fileValue, "entities/parentThings/PT00001/TestFile.mol");
          });
          it("should return the first fileValue with the comment filled with the file name", function() {
            return assert.equal(this.responseJSON.lsStates[0].lsValues[3].comments, "TestFile.mol");
          });
          it("should return the second fileValue moved to the correct location", function() {
            return assert.equal(this.responseJSON.lsStates[0].lsValues[4].fileValue, "entities/parentThings/PT00001/Test.csv");
          });
          it("should return the second fileValue with the comment filled with the file name", function() {
            return assert.equal(this.responseJSON.lsStates[0].lsValues[4].comments, "Test.csv");
          });
          it("should move the first file to the correct location", function() {
            return fs.unlink(config.all.server.datafiles.relative_path + "/entities/parentThings/PT00001/TestFile.mol", (function(_this) {
              return function(err) {
                return assert.equal(err, null);
              };
            })(this));
          });
          return it("should move the second file to the correct location", function() {
            return fs.unlink(config.all.server.datafiles.relative_path + "/entities/parentThings/PT00001/Test.csv", (function(_this) {
              return function(err) {
                return assert.equal(err, null);
              };
            })(this));
          });
        });
      });
      describe("when saving a new thing batch", function() {
        before(function(done) {
          this.timeout(20000);
          this.testFile1Path = config.all.server.datafiles.relative_path + "/TestFile.mol";
          this.testFile2Path = config.all.server.datafiles.relative_path + "/Test.csv";
          fs.writeFileSync(this.testFile1Path, "key,value\nflavor,sweet");
          fs.writeFileSync(this.testFile2Path, "key,value\nmolecule,CCC");
          return request.post({
            url: "http://localhost:" + config.all.server.nodeapi.port + "/api/things/batch/thing/PT00001",
            json: true,
            body: thingServiceTestJSON.thingBatch
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
          it("should return a thing", function() {
            return assert.equal(this.responseJSON.codeName === null, false);
          });
          it("should have a trans at the top level", function() {
            console.log(this.responseJSON);
            return assert.equal(isNaN(parseInt(this.responseJSON.lsTransaction)), false);
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
            return assert.equal(this.responseJSON.lsStates[0].lsValues[7].fileValue, "entities/parentThings/PT00001-1/TestFile.mol");
          });
          it("should return the first fileValue with the comment filled with the file name", function() {
            return assert.equal(this.responseJSON.lsStates[0].lsValues[7].comments, "TestFile.mol");
          });
          it("should return the second fileValue moved to the correct location", function() {
            return assert.equal(this.responseJSON.lsStates[0].lsValues[8].fileValue, "entities/parentThings/PT00001-1/Test.csv");
          });
          it("should return the second fileValue with the comment filled with the file name", function() {
            return assert.equal(this.responseJSON.lsStates[0].lsValues[8].comments, "Test.csv");
          });
          it("should move the first file to the correct location", function() {
            return fs.unlink(config.all.server.datafiles.relative_path + "/entities/parentThings/PT00001-1/TestFile.mol", (function(_this) {
              return function(err) {
                return assert.equal(err, null);
              };
            })(this));
          });
          return it("should move the second file to the correct location", function() {
            return fs.unlink(config.all.server.datafiles.relative_path + "/entities/parentThings/PT00001-1/Test.csv", (function(_this) {
              return function(err) {
                return assert.equal(err, null);
              };
            })(this));
          });
        });
      });
      describe("when updating a thing parent", function() {
        before(function(done) {
          var updatedData;
          this.timeout(20000);
          this.testFile1Path = config.all.server.datafiles.relative_path + "/TestFile.mol";
          this.testFile2Path = config.all.server.datafiles.relative_path + "/Test.csv";
          fs.writeFileSync(this.testFile1Path, "key,value\nflavor,sweet");
          fs.writeFileSync(this.testFile2Path, "key,value\nmolecule,CCC");
          updatedData = thingServiceTestJSON.thingParent;
          updatedData.lsStates[0].lsValues[3].id = null;
          updatedData.lsStates[0].lsValues[4].id = null;
          return request.put({
            url: "http://localhost:" + config.all.server.nodeapi.port + "/api/things/parent/thing/PT00001",
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
        it("should return a thing", function() {
          return assert.equal(this.responseJSON.codeName === null, false);
        });
        it("should return the first fileValue moved to the correct location", function() {
          return assert.equal(this.responseJSON.lsStates[0].lsValues[3].fileValue, "entities/parentThings/PT00001/TestFile.mol");
        });
        it("should return the first fileValue with the comment filled with the file name", function() {
          return assert.equal(this.responseJSON.lsStates[0].lsValues[3].comments, "TestFile.mol");
        });
        it("should return the second fileValue moved to the correct location", function() {
          return assert.equal(this.responseJSON.lsStates[0].lsValues[4].fileValue, "entities/parentThings/PT00001/Test.csv");
        });
        it("should return the second fileValue with the comment filled with the file name", function() {
          return assert.equal(this.responseJSON.lsStates[0].lsValues[4].comments, "Test.csv");
        });
        it("should move the first file to the correct location", function() {
          return fs.unlink(config.all.server.datafiles.relative_path + "/entities/parentThings/PT00001/TestFile.mol", (function(_this) {
            return function(err) {
              return assert.equal(err, null);
            };
          })(this));
        });
        return it("should move the second file to the correct location", function() {
          return fs.unlink(config.all.server.datafiles.relative_path + "/entities/parentThings/PT00001/Test.csv", (function(_this) {
            return function(err) {
              return assert.equal(err, null);
            };
          })(this));
        });
      });
      describe("when getting batches by parent codeName", function() {
        before(function(done) {
          return request("http://localhost:" + config.all.server.nodeapi.port + "/api/batches/thing/parentCodeName/PT00001", (function(_this) {
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
          return assert.equal(responseJSON[0].codeName, "PT000001-1");
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
    return describe("Lookup codeNames by names or codeNames", function() {
      var preferredThingService;
      preferredThingService = require("../../../../routes/ThingServiceRoutes.js");
      return before(function() {});
    });
  });

}).call(this);
