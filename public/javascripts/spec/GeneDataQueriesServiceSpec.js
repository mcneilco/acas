/*
This service takes a list of geneids and returns related experimental data,
*/


(function() {
  var advancedReturnExampleSuccess, advnacedReturnExampleSuccess, badDataRequest, basicReturnExampleError, basicReturnExampleSuccess, goodAdvancedRequest, goodDataRequest;

  goodDataRequest = {
    geneIDs: "1234, 2345, 4444",
    maxRowsToReturn: 10000,
    user: 'jmcneil'
  };

  badDataRequest = {
    geneIDs: "1234, 2345, 4444",
    maxRowsToReturn: -1,
    user: 'jmcneil'
  };

  goodAdvancedRequest = {
    queryParams: {
      batchCodes: "gene1, gene2",
      experimentCodeList: ["EXPT-00000397", "EXPT-00000398"],
      searchFilters: {
        booleanFilter: "advanced",
        advancedFilter: "Q1 AND Q2",
        filters: [
          {
            termName: "Q1",
            experimentCode: "EXPT-00000396",
            lsKind: "EC50",
            lsType: "numericValue",
            operator: "<",
            filterValue: ".05"
          }, {
            termName: "Q2",
            experimentCode: "EXPT-00000398",
            lsKind: "KD",
            lsType: "numericValue",
            operator: ">",
            filterValue: "1"
          }
        ]
      }
    },
    maxRowsToReturn: 10000,
    user: "jmcneil"
  };

  basicReturnExampleSuccess = {
    results: window.geneDataQueriesTestJSON.geneIDQueryResults,
    hasError: false,
    hasWarning: true,
    errorMessages: []
  };

  goodDataRequest = {
    geneIDs: "1234, 2345, 4444"
  };

  advnacedReturnExampleSuccess = {
    results: window.geneDataQueriesTestJSON.getGeneExperimentsReturn,
    hasError: false,
    hasWarning: false,
    errorMessages: []
  };

  advnacedReturnExampleSuccess = {
    results: window.geneDataQueriesTestJSON.getGeneExperimentsNoResultsReturn,
    hasError: false,
    hasWarning: false,
    errorMessages: []
  };

  advancedReturnExampleSuccess = {
    results: window.geneDataQueriesTestJSON.experimentSearchOptions,
    hasError: false,
    hasWarning: false,
    errorMessages: []
  };

  advnacedReturnExampleSuccess = {
    results: window.geneDataQueriesTestJSON.experimentSearchOptionsNoMatches,
    hasError: false,
    hasWarning: false,
    errorMessages: []
  };

  basicReturnExampleError = {
    results: {
      htmlSummary: "Error: There is a problem in this request...",
      data: null
    },
    hasError: true,
    hasWarning: true,
    errorMessages: [
      {
        errorLevel: "warning",
        message: "some genes not found"
      }, {
        errorLevel: "error",
        message: "start offset outside allowed range, please speak to an administrator"
      }
    ]
  };

  describe('Gene Data Queries Service testing', function() {
    beforeEach(function() {
      return this.waitForServiceReturn = function() {
        return typeof this.serviceReturn !== 'undefined';
      };
    });
    describe("basic gene data query", function() {
      describe('when run with valid input data', function() {
        beforeEach(function() {
          return runs(function() {
            var _this = this;
            return $.ajax({
              type: 'POST',
              url: "api/geneDataQuery",
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
            expect(this.serviceReturn.results.data.aaData.length).toEqual(4);
            expect(this.serviceReturn.hasWarning).toBeDefined();
            return expect(this.serviceReturn.results.htmlSummary).toBeDefined();
          });
        });
      });
      describe('when run with no results expected', function() {
        beforeEach(function() {
          return runs(function() {
            var _this = this;
            return $.ajax({
              type: 'POST',
              url: "api/geneDataQuery",
              data: {
                geneIDs: "fiona"
              },
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
            expect(this.serviceReturn.results.data.iTotalRecords).toEqual(0);
            expect(this.serviceReturn.hasWarning).toBeDefined();
            return expect(this.serviceReturn.results.htmlSummary).toBeDefined();
          });
        });
      });
      describe('when run with invalid input', function() {
        beforeEach(function() {
          return runs(function() {
            var _this = this;
            return $.ajax({
              type: 'POST',
              url: "api/geneDataQuery",
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
        return it('should return error=true, and at least one message', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 20000);
          return runs(function() {
            expect(this.serviceReturn.results.htmlSummary).toBeDefined();
            expect(this.serviceReturn.hasError).toBeTruthy();
            expect(this.serviceReturn.errorMessages.length).toBeGreaterThan(0);
            return expect(this.serviceReturn.errorMessages[1].errorLevel).toEqual('error');
          });
        });
      });
      return describe('when run with valid input data and format is CSV', function() {
        beforeEach(function() {
          return runs(function() {
            return $.ajax({
              type: 'POST',
              url: "api/geneDataQuery?format=csv",
              data: {
                geneIDs: "fiona"
              },
              success: (function(_this) {
                return function(res) {
                  console.log(res);
                  return _this.serviceReturn = res;
                };
              })(this)
            });
          });
        });
        return it('should return no errors, dry run mode, hasWarning, and an html summary', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 300);
          return runs(function() {
            return expect(this.serviceReturn.fileURL).toContain("http");
          });
        });
      });
    });
    describe("advanced experiments for genes query", function() {
      describe('when run with valid input data', function() {
        beforeEach(function() {
          return runs(function() {
            var _this = this;
            return $.ajax({
              type: 'POST',
              url: "api/getGeneExperiments",
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
            expect(this.serviceReturn.results.experimentData[0].parent).toEqual("Root Node");
            expect(this.serviceReturn.hasWarning).toBeDefined();
            return expect(this.serviceReturn.results.htmlSummary).toBeDefined();
          });
        });
      });
      describe('when run with no results expected', function() {
        beforeEach(function() {
          return runs(function() {
            var _this = this;
            return $.ajax({
              type: 'POST',
              url: "api/getGeneExperiments",
              data: {
                geneIDs: "fiona"
              },
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
            expect(this.serviceReturn.results.experimentData.length).toEqual(0);
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
              url: "api/getGeneExperiments",
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
        return it('should return error=true, and at least one message', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 20000);
          return runs(function() {
            expect(this.serviceReturn.results.htmlSummary).toBeDefined();
            expect(this.serviceReturn.hasError).toBeTruthy();
            expect(this.serviceReturn.errorMessages.length).toBeGreaterThan(0);
            return expect(this.serviceReturn.errorMessages[1].errorLevel).toEqual('error');
          });
        });
      });
    });
    describe("advanced experiment attributes for experiments", function() {
      describe('when run with valid input data', function() {
        beforeEach(function() {
          return runs(function() {
            var _this = this;
            return $.ajax({
              type: 'POST',
              url: "api/getExperimentSearchAttributes",
              data: {
                experimentCodes: ["EXPT-00000398", "EXPT-00000396", "EXPT-00000398"]
              },
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
            expect(this.serviceReturn.results.experiments[0].experimentCode).toEqual("EXPT-00000396");
            expect(this.serviceReturn.hasWarning).toBeDefined();
            return expect(this.serviceReturn.results.htmlSummary).toBeDefined();
          });
        });
      });
      describe('when run with no results expected', function() {
        beforeEach(function() {
          return runs(function() {
            var _this = this;
            return $.ajax({
              type: 'POST',
              url: "api/getExperimentSearchAttributes",
              data: {
                experimentCodes: ["fiona"]
              },
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
            expect(this.serviceReturn.results.experiments.length).toEqual(0);
            expect(this.serviceReturn.hasWarning).toBeDefined();
            return expect(this.serviceReturn.results.htmlSummary).toBeDefined();
          });
        });
      });
      return describe('when run with invalid input data', function() {
        beforeEach(function() {
          return runs(function() {
            var _this = this;
            return $.ajax({
              type: 'POST',
              url: "api/getExperimentSearchAttributes",
              data: {
                experimentCodes: ["error"]
              },
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
        return it('should return error=true, and at least one message', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 20000);
          return runs(function() {
            expect(this.serviceReturn.results.htmlSummary).toBeDefined();
            expect(this.serviceReturn.hasError).toBeTruthy();
            expect(this.serviceReturn.errorMessages.length).toBeGreaterThan(0);
            return expect(this.serviceReturn.errorMessages[1].errorLevel).toEqual('error');
          });
        });
      });
    });
    return describe("advanced data search", function() {
      describe('when run with valid input data', function() {
        beforeEach(function() {
          return runs(function() {
            var _this = this;
            return $.ajax({
              type: 'POST',
              url: "api/geneDataQueryAdvanced",
              data: goodAdvancedRequest,
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
            expect(this.serviceReturn.results.data.aaData.length).toEqual(4);
            expect(this.serviceReturn.hasWarning).toBeDefined();
            return expect(this.serviceReturn.results.htmlSummary).toBeDefined();
          });
        });
      });
      describe('when run with no results expected', function() {
        beforeEach(function() {
          return runs(function() {
            var _this = this;
            goodAdvancedRequest.queryParams.batchCodes = "fiona";
            return $.ajax({
              type: 'POST',
              url: "api/geneDataQueryAdvanced",
              data: goodAdvancedRequest,
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
            expect(this.serviceReturn.results.data.iTotalRecords).toEqual(0);
            expect(this.serviceReturn.hasWarning).toBeDefined();
            return expect(this.serviceReturn.results.htmlSummary).toBeDefined();
          });
        });
      });
      describe('when run with invalid input file', function() {
        beforeEach(function() {
          return runs(function() {
            var _this = this;
            goodAdvancedRequest.maxRowsToReturn = -1;
            return $.ajax({
              type: 'POST',
              url: "api/geneDataQueryAdvanced",
              data: goodAdvancedRequest,
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
        return it('should return error=true, and at least one message', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 20000);
          return runs(function() {
            expect(this.serviceReturn.results.htmlSummary).toBeDefined();
            expect(this.serviceReturn.hasError).toBeTruthy();
            expect(this.serviceReturn.errorMessages.length).toBeGreaterThan(0);
            return expect(this.serviceReturn.errorMessages[1].errorLevel).toEqual('error');
          });
        });
      });
      return describe('when run with valid input data and format is CSV', function() {
        beforeEach(function() {
          return runs(function() {
            return $.ajax({
              type: 'POST',
              url: "api/geneDataQueryAdvanced?format=csv",
              data: goodAdvancedRequest,
              success: (function(_this) {
                return function(res) {
                  console.log(res);
                  return _this.serviceReturn = res;
                };
              })(this)
            });
          });
        });
        return it('should return no errors, dry run mode, hasWarning, and an html summary', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 500);
          return runs(function() {
            return expect(this.serviceReturn.fileURL).toContain("http");
          });
        });
      });
    });
  });

}).call(this);
