(function() {
  var assert, config, csUtilities, fs, parseResponse, request, _;

  assert = require('assert');

  request = require('request');

  _ = require('underscore');

  fs = require('fs');

  config = require('../../../../conf/compiled/conf.js');

  csUtilities = require('../../../../public/src/conf/CustomerSpecificServerFunctions.js');

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

  describe("Base ACAS Customer Specific Function Tests", function() {
    describe("User information testing", function() {
      return describe("Get user", function() {
        before(function(done) {
          this.timeout(20000);
          return csUtilities.getUser("bob", (function(_this) {
            return function(expectnull, user) {
              _this.user = user;
              return done();
            };
          })(this));
        });
        it("should return a user", function() {
          assert.equal(this.user.username, "bob");
          return assert.equal(this.user.email, "bob@mcneilco.com");
        });
        it("should return an array of roles", function() {
          return assert.equal(this.user.roles.length > 0, true);
        });
        return it("should user bob shoud have role admin", function() {
          var roleFound;
          roleFound = false;
          _.each(this.user.roles, function(role) {
            if (role.roleEntry.roleName === "admin") {
              return roleFound = true;
            }
          });
          return assert.equal(roleFound, true);
        });
      });
    });
    return describe("entity file handling", function() {
      var inputFileValue;
      inputFileValue = {
        'clobValue': null,
        'codeKind': null,
        'codeOrigin': null,
        'codeType': null,
        'codeTypeAndKind': 'null_null',
        'codeValue': null,
        'comments': null,
        'concUnit': null,
        'concentration': null,
        'dateValue': null,
        'deleted': false,
        'fileValue': 'test Work List (1).csv',
        'id': 4535944,
        'ignored': false,
        'lsKind': 'source file',
        'lsTransaction': 3463,
        'lsType': 'fileValue',
        'lsTypeAndKind': 'fileValue_source file',
        'modifiedBy': null,
        'modifiedDate': null,
        'numberOfReplicates': null,
        'numericValue': null,
        'operatorKind': null,
        'operatorType': null,
        'operatorTypeAndKind': 'null_null',
        'publicData': true,
        'recordedBy': 'bob',
        'recordedDate': 1420572665000,
        'sigFigs': null,
        'stringValue': null,
        'uncertainty': null,
        'uncertaintyType': null,
        'unitKind': null,
        'unitType': null,
        'unitTypeAndKind': 'null_null',
        'urlValue': null,
        'version': 0
      };
      describe("async call to move a file to the correct destination given a fileValue and entity type", function() {
        describe("when called for protocols", function() {
          before(function(done) {
            var fv;
            this.testFilePath = config.all.server.datafiles.relative_path + "/test Work List (1).csv";
            fs.writeFileSync(this.testFilePath, "key,value\nflavor,sweet");
            fv = JSON.parse(JSON.stringify(inputFileValue));
            return csUtilities.relocateEntityFile(fv, "PROT", "PROT12345", (function(_this) {
              return function(passed) {
                _this.outputFileValue = fv;
                _this.passed = passed;
                return done();
              };
            })(this));
          });
          after(function() {
            return fs.unlink(this.testFilePath);
          });
          it("should return passed", function() {
            return assert.equal(this.passed, true);
          });
          it("should return a fileValue with the correct relative path for Protocol", function() {
            return assert.equal(this.outputFileValue.fileValue, "protocols/PROT12345/test Work List (1).csv");
          });
          it("should return a fileValue with base file name in comments", function() {
            return assert.equal(this.outputFileValue.comments, "test Work List (1).csv");
          });
          it("should remove the file from the old path", function() {
            return fs.unlink(this.testFilePath, (function(_this) {
              return function(err) {
                return assert.equal(err.errno, 34);
              };
            })(this));
          });
          return it("should add the file to the new path", function() {
            return fs.unlink(config.all.server.datafiles.relative_path + "/protocols/PROT12345/test Work List (1).csv", (function(_this) {
              return function(err) {
                return assert.equal(err, null);
              };
            })(this));
          });
        });
        describe("when called for experiments", function() {
          before(function(done) {
            var fv;
            this.testFilePath = config.all.server.datafiles.relative_path + "/test Work List (1).csv";
            fs.writeFileSync(this.testFilePath, "key,value\nflavor,sweet");
            fv = JSON.parse(JSON.stringify(inputFileValue));
            return csUtilities.relocateEntityFile(fv, "EXPT", "EXPT12345", (function(_this) {
              return function(passed) {
                _this.outputFileValue = fv;
                _this.passed = passed;
                return done();
              };
            })(this));
          });
          after(function() {
            return fs.unlink(this.testFilePath);
          });
          it("should return a fileValue with the correct relative path for Experiment", function() {
            return assert.equal(this.outputFileValue.fileValue, "experiments/EXPT12345/test Work List (1).csv");
          });
          it("should add the file to the new path", function() {
            return fs.unlink(this.testFilePath, (function(_this) {
              return function(err) {
                return assert.equal(err.errno, 34);
              };
            })(this));
          });
          return it("should remove the file from the old path", function() {
            return fs.unlink(config.all.server.datafiles.relative_path + "/experiments/EXPT12345/test Work List (1).csv", (function(_this) {
              return function(err) {
                return assert.equal(err, null);
              };
            })(this));
          });
        });
        describe("when called for another kind of entity", function() {
          before(function(done) {
            var fv;
            this.testFilePath = config.all.server.datafiles.relative_path + "/test Work List (1).csv";
            fs.writeFileSync(this.testFilePath, "key,value\nflavor,sweet");
            fv = JSON.parse(JSON.stringify(inputFileValue));
            return csUtilities.relocateEntityFile(fv, "PT", "PT12345", (function(_this) {
              return function(passed) {
                _this.outputFileValue = fv;
                _this.passed = passed;
                return done();
              };
            })(this));
          });
          after(function() {
            return fs.unlink(this.testFilePath);
          });
          it("should return a fileValue with the correct relative path for Experiment", function() {
            return assert.equal(this.outputFileValue.fileValue, "entities/parentThings/PT12345/test Work List (1).csv");
          });
          it("should add the file to the new path", function() {
            return fs.unlink(this.testFilePath, (function(_this) {
              return function(err) {
                return assert.equal(err.errno, 34);
              };
            })(this));
          });
          return it("should remove the file from the old path", function() {
            return fs.unlink(config.all.server.datafiles.relative_path + "/entities/parentThings/PT12345/test Work List (1).csv", (function(_this) {
              return function(err) {
                return assert.equal(err, null);
              };
            })(this));
          });
        });
        describe("when called with nonexistant file", function() {
          before(function(done) {
            var fv;
            this.testFilePath = config.all.server.datafiles.relative_path + "/test Work List (1).csv";
            fv = JSON.parse(JSON.stringify(inputFileValue));
            return csUtilities.relocateEntityFile(fv, "EXPT", "EXPT12345", (function(_this) {
              return function(passed) {
                _this.outputFileValue = fv;
                _this.passed = passed;
                return done();
              };
            })(this));
          });
          return it("should return a passed = false", function() {
            return assert.equal(this.passed, false);
          });
        });
        return describe("when entity prefix does not exist", function() {
          before(function(done) {
            var fv;
            this.testFilePath = config.all.server.datafiles.relative_path + "/test Work List (1).csv";
            fs.writeFileSync(this.testFilePath, "key,value\nflavor,sweet");
            fv = JSON.parse(JSON.stringify(inputFileValue));
            return csUtilities.relocateEntityFile(fv, "NOTHING", "EXPT12345", (function(_this) {
              return function(passed) {
                _this.outputFileValue = fv;
                _this.passed = passed;
                return done();
              };
            })(this));
          });
          after(function() {
            return fs.unlink(this.testFilePath);
          });
          return it("should return a passed = false", function() {
            return assert.equal(this.passed, false);
          });
        });
      });
      return describe("get current download URL for a given file, give a fileValue", function() {});
    });
  });

}).call(this);
