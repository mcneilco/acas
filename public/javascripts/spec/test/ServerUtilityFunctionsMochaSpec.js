(function() {
  var assert, config, fs, parseResponse, request, servUtilities, thingServiceTestJSON, _;

  assert = require('assert');

  request = require('request');

  _ = require('underscore');

  fs = require('fs');

  config = require('../../../../conf/compiled/conf.js');

  servUtilities = require('../../../../routes/ServerUtilityFunctions.js');

  thingServiceTestJSON = require('../../../../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js');

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

  describe("Server Utiilty Function Tests", function() {
    describe("File Value filtering", function() {
      return describe("get fileValues from thing", function() {
        before(function(done) {
          this.fileVals = servUtilities.getFileValesFromThing(thingServiceTestJSON.thingParent);
          return done();
        });
        it("should return an array", function() {
          return assert.equal(this.fileVals.length > 0, true);
        });
        return it("all the values should be type fileValue and not ignored", function() {
          return assert.equal(this.fileVals.length, 2);
        });
      });
    });
    return describe("Entity attribute from ControllerRedirect.conf functions", function() {
      describe("get file path for entity prefix", function() {
        it("should return the relative path for PROT", function() {
          return assert.equal(servUtilities.getRelativeFolderPathForPrefix("PROT"), "protocols/");
        });
        it("should return the relative path for PT", function() {
          return assert.equal(servUtilities.getRelativeFolderPathForPrefix("PT"), "entities/parentThings/");
        });
        return it("should return null with bad prefix", function() {
          return assert.equal(servUtilities.getRelativeFolderPathForPrefix("fred"), null);
        });
      });
      return describe("get prefix from code", function() {
        it("should return the prot prefix from a prot code", function() {
          return assert.equal(servUtilities.getPrefixFromThingCode("PROT00000123"), "PROT");
        });
        it("should return the pt prefix from a parent thing code", function() {
          return assert.equal(servUtilities.getPrefixFromThingCode("PT00000123"), "PT");
        });
        it("should return the expt prefix from an experiment code", function() {
          return assert.equal(servUtilities.getPrefixFromThingCode("EXPT00000123"), "EXPT");
        });
        return it("should return null with bad code", function() {
          return assert.equal(servUtilities.getPrefixFromThingCode("FRED0001343"), null);
        });
      });
    });
  });

}).call(this);
