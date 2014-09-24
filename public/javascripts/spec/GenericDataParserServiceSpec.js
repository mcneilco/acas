
/*
This service parses data from the generic format and saves it to the database
 */

(function() {
  var badDataRequest, goodDataRequest, goodDataRequestDryRunFalse, returnExampleError, returnExampleSuccess, returnExampleSuccessDryRunFalse;

  goodDataRequest = {
    fileToParse: "public/src/modules/GenericDataParser/spec/specFiles/ExampleInputFormat_with_Curve_with_warnings.xls",
    reportFile: null,
    dryRunMode: true,
    requireDoseResponse: true,
    user: 'jmcneil',
    testMode: true
  };

  goodDataRequestDryRunFalse = {
    fileToParse: "public/src/modules/GenericDataParser/spec/specFiles/ExampleInputFormat_with_Curve_with_warnings.xls",
    reportFile: null,
    dryRunMode: false,
    requireDoseResponse: true,
    user: 'jmcneil',
    testMode: true
  };

  badDataRequest = {
    fileToParse: "public/src/modules/GenericDataParser/spec/specFiles/ExampleInputFormat_with_error.xls",
    reportFile: null,
    dryRunMode: true,
    user: 'jmcneil',
    testMode: true
  };

  returnExampleSuccess = {
    transactionId: -1,
    results: {
      path: "path/to/file",
      fileToParse: "filename.xls",
      reportFile: null,
      htmlSummary: "HTML from service",
      dryRunMode: true
    },
    hasError: false,
    hasWarning: true,
    errorMessages: []
  };

  returnExampleSuccessDryRunFalse = {
    transactionId: -1,
    results: {
      path: "path/to/file",
      fileToParse: "filename.xls",
      reportFile: null,
      htmlSummary: "HTML from service",
      dryRunMode: false,
      experimentCode: "EXPT-000001"
    },
    hasError: false,
    hasWarning: true,
    errorMessages: []
  };

  returnExampleError = {
    transactionId: null,
    results: {
      path: "path/to/file",
      fileToParse: "filename.xls",
      reportFile: null,
      htmlSummary: "Error: There is a problem in this file...",
      dryRunMode: true
    },
    hasError: true,
    hasWarning: true,
    errorMessages: [
      {
        errorLevel: "warning",
        message: "some warning"
      }, {
        errorLevel: "error",
        message: "Cannot find file"
      }
    ]
  };

  describe('Generic data parser Service testing', function() {
    beforeEach(function() {
      return this.waitForServiceReturn = function() {
        return typeof this.serviceReturn !== 'undefined';
      };
    });
    describe('when run with valid input file', function() {
      beforeEach(function() {
        return runs(function() {
          return $.ajax({
            type: 'POST',
            url: "api/genericDataParser",
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
          expect(this.serviceReturn.results.dryRun).toBeTruthy();
          expect(this.serviceReturn.hasWarning).toBeDefined();
          return expect(this.serviceReturn.results.htmlSummary).toBeDefined();
        });
      });
    });
    describe('when run with invalid input file', function() {
      beforeEach(function() {
        return runs(function() {
          return $.ajax({
            type: 'POST',
            url: "api/genericDataParser",
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
          expect(this.serviceReturn.hasError).toBeTruthy();
          expect(this.serviceReturn.errorMessages.length).toBeGreaterThan(0);
          return expect(this.serviceReturn.errorMessages[0].errorLevel).toEqual('error');
        });
      });
    });
    return describe('when run with valid input  and dry-run false', function() {
      beforeEach(function() {
        return runs(function() {
          return $.ajax({
            type: 'POST',
            url: "api/genericDataParser",
            data: goodDataRequestDryRunFalse,
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
          expect(this.serviceReturn.results.dryRun).toBeTruthy();
          expect(this.serviceReturn.hasWarning).toBeDefined();
          return expect(this.serviceReturn.results.htmlSummary).toBeDefined();
        });
      });
    });
  });

}).call(this);
