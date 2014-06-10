
/*
This service takes an experiment code,
  looks up efficacy data already saved there, and fits curves.
  It returns a summary in HTML. To see detailed result you have to open the curve curator
 */

(function() {
  var badDataRequest, goodDataRequest, returnExampleError, returnExampleSuccess;

  goodDataRequest = {
    inputParameters: window.CurveFitTestJSON.doseResponseSimpleBulkFitOptions,
    user: 'jmcneil',
    experimentCode: "EXPT-0000001",
    testMode: true
  };

  badDataRequest = {
    inputParameters: window.CurveFitTestJSON.doseResponseSimpleBulkFitOptions,
    user: 'jmcneil',
    experimentCode: "EXPT-fail",
    testMode: true
  };

  returnExampleSuccess = {
    transactionId: -1,
    results: {
      htmlSummary: "HTML from service",
      status: "complete"
    },
    hasError: false,
    hasWarning: true,
    errorMessages: []
  };

  returnExampleError = {
    transactionId: null,
    results: {
      htmlSummary: "Error: There is a problem in this file...",
      status: "error"
    },
    hasError: true,
    hasWarning: true,
    errorMessages: [
      1, {
        errorLevel: "warning",
        message: "some warning"
      }, {
        errorLevel: "error",
        message: "Cannot find file"
      }
    ]
  };

  describe('Dose Response Curve Fit Service testing', function() {
    beforeEach(function() {
      return this.waitForServiceReturn = function() {
        return typeof this.serviceReturn !== 'undefined';
      };
    });
    describe('when run with valid input data', function() {
      beforeEach(function() {
        return runs(function() {
          return $.ajax({
            type: 'POST',
            url: "api/doseResponseCurveFit",
            data: goodDataRequest,
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
      return it('should return no errors, dry run mode, hasWarning, and an html summary', function() {
        waitsFor(this.waitForServiceReturn, 'service did not return', 10000);
        return runs(function() {
          expect(this.serviceReturn.hasError).toBeFalsy();
          expect(this.serviceReturn.results.status).toEqual("complete");
          expect(this.serviceReturn.hasWarning).toBeDefined();
          return expect(this.serviceReturn.results.htmlSummary).toBeDefined();
        });
      });
    });
    return describe('when run with invalid input file', function() {
      beforeEach(function() {
        return runs(function() {
          return $.ajax({
            type: 'POST',
            url: "api/doseResponseCurveFit",
            data: badDataRequest,
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
      return it('should not return a dry run transactionId, but return error=true, and at least one message', function() {
        waitsFor(this.waitForServiceReturn, 'service did not return', 20000);
        return runs(function() {
          expect(this.serviceReturn.transactionId).toBeNull();
          expect(this.serviceReturn.results.status).toBeDefined();
          expect(this.serviceReturn.hasError).toBeTruthy();
          expect(this.serviceReturn.errorMessages.length).toBeGreaterThan(0);
          return expect(this.serviceReturn.errorMessages[0].errorLevel).toEqual('error');
        });
      });
    });
  });

}).call(this);
