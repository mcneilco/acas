/*
This service parses data from the Full PK aloonf format and saves it to the database
It also takes a series pf parameters that would normally be in a header block
*/


(function() {
  var badDataRequest, goodDataRequest, returnExampleError, returnExampleSuccess;

  goodDataRequest = {
    fileToParse: "public/src/modules/GenericDataParser/spec/specFiles/ExampleInputFormat_with_Curve_with_warnings.xls",
    reportFile: null,
    inputParameters: window.FullPKTestJSON.validFullPK,
    dryRun: true,
    user: 'jmcneil',
    testMode: true
  };

  badDataRequest = {
    fileToParse: "public/src/modules/GenericDataParser/spec/specFiles/ExampleInputFormat_with_error.xls",
    reportFile: null,
    inputParameters: window.FullPKTestJSON.validFullPK,
    dryRun: true,
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
      reportFile: null,
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

  describe('Full PK Parser Service testing', function() {
    beforeEach(function() {
      return this.waitForServiceReturn = function() {
        return typeof this.serviceReturn !== 'undefined';
      };
    });
    describe('when run with valid input file', function() {
      beforeEach(function() {
        return runs(function() {
          var _this = this;

          return $.ajax({
            type: 'POST',
            url: "api/fullPKParser",
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
    return describe('when run with invalid input file', function() {
      beforeEach(function() {
        return runs(function() {
          var _this = this;

          return $.ajax({
            type: 'POST',
            url: "api/fullPKParser",
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
  });

}).call(this);
