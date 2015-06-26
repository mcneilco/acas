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
    describe("entity file handling", function() {
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
    describe("get calculated compound properties", function() {
      describe("when valid compounds sent with valid properties", function() {
        var entityList, propertyList;
        propertyList = ["HEAVY_ATOM_COUNT", "MONOISOTOPIC_MASS"];
        entityList = "CMPD76\nCMPD2\nCMPD78\n";
        before(function(done) {
          this.timeout(20000);
          return csUtilities.getTestedEntityProperties(propertyList, entityList, (function(_this) {
            return function(properties) {
              _this.propertyList = properties;
              return done();
            };
          })(this));
        });
        it("should return 5 rows including a trailing \n", function() {
          return assert.equal(this.propertyList.split('\n').length, 5);
        });
        it("should have 3 columns", function() {
          var res;
          res = this.propertyList.split('\n');
          return assert.equal(res[0].split(',').length, 3);
        });
        it("should have a header row", function() {
          var res;
          res = this.propertyList.split('\n');
          return assert.equal(res[0], "id,HEAVY_ATOM_COUNT,MONOISOTOPIC_MASS");
        });
        return it("should have a number in the first result row", function() {
          var res;
          res = this.propertyList.split('\n');
          return assert.equal(isNaN(parseFloat(res[1].split(',')[1])), false);
        });
      });
      describe("when valid compounds sent with invalid property", function() {
        var entityList, propertyList;
        propertyList = ["ERROR", "deep_fred"];
        entityList = "CMPD76\nCMPD2\nCMPD78\n";
        before(function(done) {
          this.timeout(20000);
          return csUtilities.getTestedEntityProperties(propertyList, entityList, (function(_this) {
            return function(properties) {
              _this.propertyList = properties;
              return done();
            };
          })(this));
        });
        return it("should return null \n", function() {
          return assert.equal(this.propertyList, null);
        });
      });
      return describe("when invalid compounds sent with valid properties", function() {
        var entityList, propertyList;
        propertyList = ["HEAVY_ATOM_COUNT", "MONOISOTOPIC_MASS"];
        entityList = "ERROR1\nERROR2\nERROR3\n";
        before(function(done) {
          this.timeout(20000);
          return csUtilities.getTestedEntityProperties(propertyList, entityList, (function(_this) {
            return function(properties) {
              _this.propertyList = properties;
              return done();
            };
          })(this));
        });
        it("should return 5 rows including a trailing \n", function() {
          return assert.equal(this.propertyList.split('\n').length, 5);
        });
        it("should have 3 columns", function() {
          var res;
          res = this.propertyList.split('\n');
          return assert.equal(res[0].split(',').length, 3);
        });
        it("should have a header row", function() {
          var res;
          res = this.propertyList.split('\n');
          return assert.equal(res[0], "id,HEAVY_ATOM_COUNT,MONOISOTOPIC_MASS");
        });
        return it("should have no number in the first result row", function() {
          var res;
          res = this.propertyList.split('\n');
          return assert.equal(res[1].split(',')[1], "");
        });
      });
    });
    describe("get preferred batchids", function() {
      global.specRunnerTestmode = true;
      describe("when valid, alias, and invalid batches sent", function() {
        var requestData;
        requestData = {
          requests: [
            {
              requestName: "CMPD-0000001-01A"
            }, {
              requestName: "CMPD-0000002-01A"
            }, {
              requestName: "CMPD-999999999::9999"
            }
          ]
        };
        before(function(done) {
          this.timeout(20000);
          return csUtilities.getPreferredBatchIds(requestData.requests, (function(_this) {
            return function(response) {
              _this.response = response;
              console.log(response);
              return done();
            };
          })(this));
        });
        it("should return 3 results", function() {
          return assert.equal(this.response.length, 3);
        });
        it("should have the batch if not an alias", function() {
          return assert.equal(this.response[0].requestName, this.response[0].preferredName);
        });
        it("should have the batch an alias", function() {
          return assert.equal(this.response[1].preferredName, "CMPD-0000002-01A");
        });
        return it("should not return an alias if the batch is not valid", function() {
          return assert.equal(this.response[2].preferredName, "");
        });
      });
      if (global.specRunnerTestmode) {
        return describe("when 1000 batches sent", function() {
          var i, num, requests;
          requests = (function() {
            var _i, _results;
            _results = [];
            for (i = _i = 1; _i <= 1000; i = ++_i) {
              num = "000000000" + i;
              num = num.substr(num.length - 9);
              _results.push({
                requestName: "DNS" + num + "::1"
              });
            }
            return _results;
          })();
          before(function(done) {
            this.timeout(20000);
            return csUtilities.getPreferredBatchIds(requests, (function(_this) {
              return function(response) {
                _this.response = response;
                return done();
              };
            })(this));
          });
          it("should return 1000 results", function() {
            return assert.equal(this.response.length, 1000);
          });
          return it("should have the batch if not an alias", function() {
            return assert.equal(this.response[999].requestName, this.response[999].preferredName);
          });
        });
      }
    });
    return describe("get preferred parent ids", function() {
      return describe("when valid, alias, and invalid batches sent", function() {
        var requestData;
        requestData = {
          requests: [
            {
              requestName: "DNS000000001"
            }, {
              requestName: "DNS000673874"
            }, {
              requestName: "DNS999999999"
            }
          ]
        };
        before(function(done) {
          this.timeout(20000);
          global.specRunnerTestmode = true;
          return csUtilities.getPreferredParentIds(requestData.requests, (function(_this) {
            return function(response) {
              _this.response = response;
              console.log(response);
              return done();
            };
          })(this));
        });
        it("should return 3 results", function() {
          return assert.equal(this.response.length, 3);
        });
        it("should have the batch if not an alias", function() {
          return assert.equal(this.response[0].requestName, this.response[0].preferredName);
        });
        it("should have the batch an alias", function() {
          return assert.equal(this.response[1].preferredName, "DNS000001234");
        });
        return it("should not return an alias if the batch is not valid", function() {
          return assert.equal(this.response[2].preferredName, "");
        });
      });
    });
  });

}).call(this);
