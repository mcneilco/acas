/*
This suite of services provides CRUD operations on Experiment Objects
*/


(function() {
  describe('Experiment Service testing', function() {
    beforeEach(function() {
      return this.waitForServiceReturn = function() {
        return typeof this.serviceReturn !== 'undefined';
      };
    });
    describe('when fetching Experiment stub by code', function() {
      beforeEach(function() {
        var self;
        self = this;
        return $.ajax({
          type: 'GET',
          url: "api/experiments/codename/EXPT-00000124",
          data: {
            testMode: true
          },
          success: function(json) {
            return self.serviceReturn = json;
          },
          error: function(err) {
            console.log('got ajax error');
            return self.serviceReturn = null;
          },
          dataType: 'json'
        });
      });
      return it('should return a experiment stub', function() {
        waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
        return runs(function() {
          return expect(this.serviceReturn.codeName).toEqual("EXPT-00000001");
        });
      });
    });
    describe('when fetching Experiment stubs by protocol code', function() {
      beforeEach(function() {
        var self;
        self = this;
        return $.ajax({
          type: 'GET',
          url: "api/experiments/protocolCodename/PROT-00000005",
          data: {
            testMode: true
          },
          success: function(json) {
            return self.serviceReturn = json;
          },
          error: function(err) {
            console.log('got ajax error');
            return self.serviceReturn = null;
          },
          dataType: 'json'
        });
      });
      return it('should return an array of experiment stubs', function() {
        waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
        return runs(function() {
          return expect(this.serviceReturn.codeName).toEqual("EXPT-00000001");
        });
      });
    });
    describe('when fetching full Experiment by id', function() {
      beforeEach(function() {
        var self;
        self = this;
        return $.ajax({
          type: 'GET',
          url: "api/experiments/1",
          success: function(json) {
            return self.serviceReturn = json;
          },
          error: function(err) {
            console.log('got ajax error');
            return self.serviceReturn = null;
          },
          dataType: 'json'
        });
      });
      return it('should return a full experiment', function() {
        waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
        return runs(function() {
          return expect(this.serviceReturn.codeName).toEqual("EXPT-00000001");
        });
      });
    });
    describe('when saving new experiment', function() {
      beforeEach(function() {
        var self;
        self = this;
        return $.ajax({
          type: 'POST',
          url: "api/experiments",
          data: window.experimentServiceTestJSON.experimentToSave,
          success: function(json) {
            return self.serviceReturn = json;
          },
          error: function(err) {
            console.log('got ajax error');
            return self.serviceReturn = null;
          },
          dataType: 'json'
        });
      });
      return it('should return an experiment', function() {
        waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
        return runs(function() {
          return expect(this.serviceReturn.id).not.toBeNull();
        });
      });
    });
    return describe('when updating existing experiment', function() {
      beforeEach(function() {
        var self;
        self = this;
        return $.ajax({
          type: 'PUT',
          url: "api/experiments/1234",
          data: window.experimentServiceTestJSON.fullExperimentFromServer,
          success: function(json) {
            return self.serviceReturn = json;
          },
          error: function(err) {
            console.log('got ajax error');
            return self.serviceReturn = null;
          },
          dataType: 'json'
        });
      });
      return it('should return the experiment', function() {
        waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
        return runs(function() {
          return expect(this.serviceReturn.id).not.toBeNull();
        });
      });
    });
  });

}).call(this);
