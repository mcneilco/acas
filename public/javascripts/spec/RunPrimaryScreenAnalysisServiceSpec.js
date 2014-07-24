
/*
This service runs a primary data analysis.
  The data is provided in a directory containing one or more data files.
  There should be no extraneous files not required for data analysis in this source directory.
  For example, the FLIPR will make one file for the max values for each plate, and another file for the min values
  If multiple plates are to be analyzed, there would be multiple files.
  The way the files should be interpreted is determined by the dataSource parameter of the PrimaryAnalysisProtocol

  The raw data and results are stored in the database.
  Additionally, a PDF is generated summarizing the analysis in graphs and tables.
  There is also csv result file containing the raw data, batch number, transformed data, well types, and well flags
	Finally, analysis parameters need to be saved as a CLOB value
  state type: "metadata", state kind: "experiment metadata"
  value type: "clobValue", value kind:"data analysis parameters"
 */

(function() {
  var goodExampleData, returnExampleError, returnExampleSuccess;

  goodExampleData = {
    primaryAnalysisExperimentId: 332134,
    fileToParse: "/var/www/rScripts/specFiles/primaryAnalysis/GoodFLIPRMinMaxSet1/rawData.zip",
    analysisParameters: window.primaryScreenTestJSON.primaryScreenAnalysisParameters,
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
      htmlSummary: "Error: Can't read data file",
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
    describe('when run with flawed input file', function() {
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
    describe("Instrument reader code", function() {
      return describe('when instrumentReader code service called', function() {
        beforeEach(function() {
          return runs(function() {
            return $.ajax({
              type: 'GET',
              url: "api/primaryAnalysis/runPrimaryAnalysis/instrumentReaderCodes",
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
        it('should return an array of instrumentReader codes', function() {
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
    describe("Signal direction code", function() {
      return describe('when signal direction code service called', function() {
        beforeEach(function() {
          return runs(function() {
            return $.ajax({
              type: 'GET',
              url: "api/primaryAnalysis/runPrimaryAnalysis/signalDirectionCodes",
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
        it('should return an array of signal direction codes', function() {
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
    describe("aggregateBy1 code", function() {
      return describe('when aggregateBy1 code service called', function() {
        beforeEach(function() {
          return runs(function() {
            return $.ajax({
              type: 'GET',
              url: "api/primaryAnalysis/runPrimaryAnalysis/aggregateBy1Codes",
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
        it('should return an array of aggregateBy1  codes', function() {
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
    describe("aggregateBy2 code", function() {
      return describe('when aggregateBy2 code service called', function() {
        beforeEach(function() {
          return runs(function() {
            return $.ajax({
              type: 'GET',
              url: "api/primaryAnalysis/runPrimaryAnalysis/aggregateBy2Codes",
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
        it('should return an array of aggregateBy2  codes', function() {
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
    describe("Transformation code", function() {
      return describe('when transformation code service called', function() {
        beforeEach(function() {
          return runs(function() {
            return $.ajax({
              type: 'GET',
              url: "api/primaryAnalysis/runPrimaryAnalysis/transformationCodes",
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
        it('should return an array of transformation codes', function() {
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
    describe("Normalization code", function() {
      return describe('when normalization code service called', function() {
        beforeEach(function() {
          return runs(function() {
            return $.ajax({
              type: 'GET',
              url: "api/primaryAnalysis/runPrimaryAnalysis/normalizationCodes",
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
        it('should return an array of normalization codes', function() {
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
    return describe("Read name code", function() {
      return describe('when read name code service called', function() {
        beforeEach(function() {
          return runs(function() {
            return $.ajax({
              type: 'GET',
              url: "api/primaryAnalysis/runPrimaryAnalysis/readNameCodes",
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
        it('should return an array of readName codes', function() {
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
  });

}).call(this);
