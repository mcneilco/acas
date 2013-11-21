/*
This service runs a primary data analysis. The data is provided in a directory containing one or more data files. There should be no extraneous files not required for data analysis in this source directory. For example, the FLIPR will make one file for the max values for each plate, and another file for the min values. If multiple plates are to be analyzed, there would be multiple files. The way the files should be interpreted is determined by the dataSource parameter of the PrimaryAnalysisProtocol

The raw data and results are stored in the database. Additionally, a PDF is generated summarizing the analysis in graphs and tables. There is also csv result file containing the raw data, batch number, transformed data, well types, and well flags
*/


(function() {
  var goodExampleData, returnExampleError, returnExampleSuccess;

  goodExampleData = {
    primaryAnalysisExperimentId: 332134,
    fileToParse: "/var/www/rScripts/specFiles/primaryAnalysis/GoodFLIPRMinMaxSet1/rawData.zip",
    user: 'jmcneil',
    dryRun: true
  };

  returnExampleSuccess = {
    transactionId: null,
    results: {
      fileToParse: "path/to/directory",
      htmlSummary: "plates to analyze: 3 <br/> batches to associate: 123",
      primaryAnalysisExperimentId: 332134,
      dryRun: true
    },
    hasError: false,
    hasWarning: true,
    errorMessages: [
      {
        errorLevel: "warning",
        message: "some warning"
      }
    ]
  };

  returnExampleError = {
    transactionId: null,
    results: {
      fileToParse: "path/to/file",
      htmlSummary: "Error: Can't read dat file",
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
        message: "Can't read file"
      }, {
        errorLevel: "error",
        message: "Can't find positive control on plate"
      }
    ]
  };

  describe('Run primary analysis service testing', function() {
    beforeEach(function() {
      return this.waitForServiceReturn = function() {
        return typeof this.serviceReturn !== 'undefined';
      };
    });
    describe('when run with valid input', function() {
      beforeEach(function() {
        var self;
        self = this;
        return $.ajax({
          type: 'POST',
          url: "api/primaryAnalysis/runPrimaryAnalysis",
          data: goodExampleData,
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
      return it('should return error=false', function() {
        waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
        return runs(function() {
          return (expect(this.serviceReturn.error)).toBeFalsy;
        });
      });
    });
    return describe('when run with flawed input file', function() {
      beforeEach(function() {
        var self;
        goodExampleData.fileToParse += "_with_error";
        self = this;
        return $.ajax({
          type: 'POST',
          url: "api/primaryAnalysis/runPrimaryAnalysis",
          data: goodExampleData,
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
      it('should return error=true', function() {
        waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
        return runs(function() {
          return (expect(this.serviceReturn.error)).toBeTruthy;
        });
      });
      return it('should return error messages', function() {
        waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
        return runs(function() {
          return (expect(this.serviceReturn.errorMessages.length)).toBeGreaterThan(0);
        });
      });
    });
  });

}).call(this);
