/*
This service parses data from the generic format and saves it to the database
*/


(function() {
  var badDataRequest, goodDataRequest, returnExampleError, returnExampleSuccess;

  goodDataRequest = {
    fileToParse: "public/src/modules/GenericDataParser/spec/specFiles/ExampleInputFormat_with_Curve_with_warnings.xls",
    dryRun: true,
    user: 'jmcneil',
    testMode: true
  };

  badDataRequest = {
    fileToParse: "public/src/modules/GenericDataParser/spec/specFiles/ExampleInputFormat_with_error.xls",
    dryRun: true,
    user: 'jmcneil',
    testMode: true
  };

  returnExampleSuccess = {
    transactionId: -1,
    results: {
      path: "path/to/file",
      fileToParse: "filename.xls",
      htmlSummary: "HTML from service",
      dryRun: true
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
      htmlSummary: "Error: There is a problem in this file...",
      dryRun: true
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
    describe('get existing entity from genericDataParser', function() {
      return describe('when run with valid input file', function() {
        beforeEach(function() {
          return runs(function() {
            var _this = this;

            return $.ajax({
              type: 'POST',
              url: "api/genericDataParser",
              data: goodDataRequest,
              success: function(json) {
                return _this.serviceReturn = json;
              },
              error: function(err) {
                console.log('got ajax error');
                return _this.serviceReturn = null;
              },
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
    return describe('get existing entity from genericDataParser', function() {
      return describe('when run with invalid input file', function() {
        beforeEach(function() {
          return runs(function() {
            var _this = this;

            return $.ajax({
              type: 'POST',
              url: "api/genericDataParser",
              data: badDataRequest,
              success: function(json) {
                return _this.serviceReturn = json;
              },
              error: function(err) {
                console.log('got ajax error');
                return _this.serviceReturn = null;
              },
              dataType: 'json'
            });
          });
        });
        return it('should not return a dry run transactionId, but retuen error=true, and at least one message', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 20000);
          return runs(function() {
            console.log(this.serviceReturn);
            expect(this.serviceReturn.transactionId).toBeNull();
            expect(this.serviceReturn.hasError).toBeTruthy();
            expect(this.serviceReturn.errorMessages.length).toBeGreaterThan(0);
            return expect(this.serviceReturn.errorMessages[0].errorLevel).toEqual('error');
          });
        });
      });
    });
  });

}).call(this);
