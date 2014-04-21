
/*
This tests the basic function and JSON validation features of the Server Utility functions
 */

(function() {
  var goodRunRRequest;

  goodRunRRequest = {
    fileToParse: "public/src/modules/BulkLoadSampleTransfers/spec/specFiles/SampleTransfers_good.csv",
    dryRun: true,
    user: 'jmcneil'
  };

  describe('runRFunction testing', function() {
    beforeEach(function() {
      return this.waitForServiceReturn = function() {
        return typeof this.serviceReturn !== 'undefined';
      };
    });
    describe('when run with good input file', function() {
      beforeEach(function() {
        var self;
        self = this;
        return $.ajax({
          type: 'POST',
          url: "api/runRFunctionTest",
          data: goodRunRRequest,
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
      return it('should return hasError=false', function() {
        waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
        return runs(function() {
          expect(this.serviceReturn.hasError).toBeFalsy();
          expect(this.serviceReturn.results.dryRun).toBeTruthy();
          expect(this.serviceReturn.hasWarning).toBeDefined();
          return expect(this.serviceReturn.results.htmlSummary).toBeDefined();
        });
      });
    });
    return describe('when run with missing username', function() {
      beforeEach(function() {
        var self;
        self = this;
        return $.ajax({
          type: 'POST',
          url: "api/runRFunctionTest",
          data: {
            fileToParse: "public/src/modules/BulkLoadSampleTransfers/spec/specFiles/SampleTransfers_good.csv",
            dryRun: true
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
      it('should return error=true, and at least one message', function() {
        waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
        return runs(function() {
          return expect(this.serviceReturn.hasError).toBeTruthy();
        });
      });
      return it('should return an error message saying username is required', function() {
        waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
        return runs(function() {
          expect(this.serviceReturn.errorMessages.length).toBeGreaterThan(0);
          expect(this.serviceReturn.errorMessages[0].errorLevel).toEqual('error');
          return expect(this.serviceReturn.errorMessages[0].message).toEqual('Username is required');
        });
      });
    });
  });

}).call(this);
