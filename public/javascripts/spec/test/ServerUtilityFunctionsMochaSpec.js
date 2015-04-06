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
          this.fileVals = servUtilities.getFileValuesFromEntity(thingServiceTestJSON.thingParent);
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
    describe("Entity attribute from ControllerRedirect.conf functions", function() {
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
          return assert.equal(servUtilities.getPrefixFromEntityCode("PROT00000123"), "PROT");
        });
        it("should return the pt prefix from a parent thing code", function() {
          return assert.equal(servUtilities.getPrefixFromEntityCode("PT00000123"), "PT");
        });
        it("should return the expt prefix from an experiment code", function() {
          return assert.equal(servUtilities.getPrefixFromEntityCode("EXPT00000123"), "EXPT");
        });
        return it("should return null with bad code", function() {
          return assert.equal(servUtilities.getPrefixFromEntityCode("FRED0001343"), null);
        });
      });
    });
    describe("Create a new lsTransaction", function() {
      before(function(done) {
        var comments, date;
        comments = "test transaction";
        date = 1427414400000;
        return servUtilities.createLSTransaction(date, comments, (function(_this) {
          return function(transaction) {
            _this.newTransaction = transaction;
            console.log(_this.newTransaction);
            return done();
          };
        })(this));
      });
      return it("should return a transaction with an id", function() {
        return assert.equal(isNaN(parseInt(this.newTransaction.id)), false);
      });
    });
    return describe("add transaction to ls entity", function() {
      var protocolServiceTestJSON;
      protocolServiceTestJSON = require('../testFixtures/ProtocolServiceTestJSON.js');
      before(function(done) {
        var ent, trans;
        trans = {
          comments: 'test transaction',
          id: 8354,
          recordedDate: 1427414400000,
          version: 0
        };
        ent = JSON.parse(JSON.stringify(protocolServiceTestJSON.protocolToSave));
        this.modEnt = servUtilities.insertTransactionIntoEntity(trans.id, ent);
        return done();
      });
      it("should have a trans at the top level", function() {
        return assert.equal(this.modEnt.lsTransaction, 8354);
      });
      it("should have a trans in the labels", function() {
        return assert.equal(this.modEnt.lsLabels[0].lsTransaction, 8354);
      });
      it("should have a trans in the states", function() {
        return assert.equal(this.modEnt.lsStates[0].lsTransaction, 8354);
      });
      return it("should have a trans in the values", function() {
        return assert.equal(this.modEnt.lsStates[0].lsValues[0].lsTransaction, 8354);
      });
    });
  });

}).call(this);
