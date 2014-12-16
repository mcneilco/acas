
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
    describe('Experiment CRUD Tests', function() {
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
      describe('when fetching Experiment stub by name', function() {
        beforeEach(function() {
          var self;
          self = this;
          return $.ajax({
            type: 'GET',
            url: "api/experiments/experimentName/Test Experiment 1",
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
            console.log("serviceREturn");
            console.log(this.serviceReturn);
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
      describe('when updating existing experiment', function() {
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
      return describe('when geting experiment state by id', function() {
        beforeEach(function() {
          var self;
          self = this;
          return $.ajax({
            type: 'GET',
            url: "api/experiments/state/11",
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
            return expect(this.serviceReturn.lsKind).toEqual("experiment metadata");
          });
        });
      });
    });
    describe("Experiment status code", function() {
      return describe('when experiment status code service called', function() {
        beforeEach(function() {
          return runs(function() {
            return $.ajax({
              type: 'GET',
              url: "api/codetables/experiment/status",
              success: (function(_this) {
                return function(json) {
                  return _this.serviceReturn = json;
                };
              })(this),
              error: (function(_this) {
                return function(err) {
                  console.log('got ajax error');
                  return _this.serviceReturn = null;
                };
              })(this),
              dataType: 'json'
            });
          });
        });
        it('should return an array of status codes', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
          return runs(function() {
            return expect(this.serviceReturn.length).toBeGreaterThan(0);
          });
        });
        it('should a hash with code defined', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
          return runs(function() {
            return expect(this.serviceReturn[0].code).toBeDefined();
          });
        });
        it('should a hash with name defined', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
          return runs(function() {
            return expect(this.serviceReturn[0].name).toBeDefined();
          });
        });
        return it('should a hash with ignore defined', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
          return runs(function() {
            return expect(this.serviceReturn[0].ignored).toBeDefined();
          });
        });
      });
    });
    return describe("Experiment result viewer url", function() {
      return describe('when experiment result viewer url service called', function() {
        beforeEach(function() {
          return runs(function() {
            return $.ajax({
              type: 'GET',
              url: "/api/experiments/resultViewerURL/test",
              success: (function(_this) {
                return function(json) {
                  return _this.serviceReturn = json;
                };
              })(this),
              error: (function(_this) {
                return function(err) {
                  console.log('got ajax error');
                  return _this.serviceReturn = null;
                };
              })(this),
              dataType: 'json'
            });
          });
        });
        return it('should return a result viewer url', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
          return runs(function() {
            return expect(this.serviceReturn.resultViewerURL).toContain("runseurat");
          });
        });
      });
    });
  });

}).call(this);
