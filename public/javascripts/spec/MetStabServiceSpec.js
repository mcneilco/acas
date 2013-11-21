/*
This service parses data from the MetStab format and saves it to the database
It also takes parameters that would normally be in a header block
It returns the usual error and warning info, but also a CSV preview of the data to load
*/


(function() {
  var badDataRequest, goodDataRequest, returnExampleError, returnExampleSuccess;

  goodDataRequest = {
    fileToParse: "public/src/modules/DNSMetstab/spec/specFiles/2013yyy_usol_xxxxx.xls",
    inputParameters: window.MetStabTestJSON.validMetStab,
    dryRun: true,
    user: 'jmcneil',
    testMode: true
  };

  badDataRequest = {
    fileToParse: "public/src/modules/DNSMetStab/spec/specFiles/2013yyy_usol_xxxxx_with_error.xls",
    inputParameters: window.MetStabTestJSON.validMetStab,
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
      csvDataPreview: "Corporate Batch ID,solubility (ug/mL),Assay Comment (-)\nDNS123456789::12,11.4,good\nDNS123456790::01,6.9,ok\n",
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
      csvDataPreview: "",
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

  describe('MetStab Parser Service testing', function() {
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
            url: "api/metStabParser",
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
          expect(this.serviceReturn.results.htmlSummary).toBeDefined();
          return expect(this.serviceReturn.results.csvDataPreview).toBeDefined();
        });
      });
    });
    return describe('when run with invalid input file', function() {
      beforeEach(function() {
        return runs(function() {
          var _this = this;
          return $.ajax({
            type: 'POST',
            url: "api/metStabParser",
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
