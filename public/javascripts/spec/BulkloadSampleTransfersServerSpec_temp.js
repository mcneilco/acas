/*
This service bulk laods sample transfer information provided in a CSV file.
The server takes a server-relative file path as input.
The service returns success status or an error summary
The service should save all the infomration with an associated load event id which it returns to support undo

Sample transfer file format. There is a required header row whose column heading much match exactly.
The file should not contain special characters, use u for mu

All columns are required
Column Header			Example				Note
Source Barcode			C00000001
Source Well				A1, A01 or A001		If a vial, this is always A1
Destination Barcode		C00000002
Allow Plate Creation	true				Create new plate if true and destination does not exist
Plate Size				384					Vials are plate size 1. May be left blank if plate exists = true
Destination Well		A1, A01 or A001		If a vial, this is always A1
Final Physical State	liquid				or solid
Final Concentration		10					Blank if physical state = solid
Concentration Units		mM					Blank if physical state = solid
Amount Transferred		100
Amount Units			uL					micro liter should use u, not mu
Transfer Date
*/


(function() {
  var badDataRequest, goodDataRequest, returnExampleError, returnExampleSuccess;

  goodDataRequest = {
    fileToParse: "public/src/modules/BulkLoadSampleTransfers/spec/specFiles/SampleTransfers_good.csv",
    dryRun: true,
    user: 'jmcneil'
  };

  badDataRequest = {
    fileToParse: "public/src/modules/BulkLoadSampleTransfers/spec/specFiles/SampleTransfers_with_error.csv",
    dryRun: true,
    user: 'jmcneil'
  };

  returnExampleSuccess = {
    transactionId: null,
    results: {
      path: "path/to/file",
      fileToParse: "filename.xls",
      htmlSummary: "transfers to save: 3",
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
      path: "path/to/file",
      fileToParse: "filename.xls",
      htmlSummary: "Error: Barcode C00000001 already loaded...",
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
        message: "Barcode C00000001 already loaded"
      }, {
        errorLevel: {
          "error": 27,
          message: "Barcode C00000001, well X128 does not exist on a 384 well plate"
        }
      }
    ]
  };

  describe('Bulk Load Sample Transfers testing', function() {
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
          url: "api/bulkLoadSampleTransfers",
          data: goodDataRequest,
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
    return describe('when run with flawed input file', function() {
      beforeEach(function() {
        var self;

        self = this;
        return $.ajax({
          type: 'POST',
          url: "api/bulkLoadSampleTransfers",
          data: badDataRequest,
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
      return it('should not return a dry run transactionId, but retuen error=true, and at least one message', function() {
        waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
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
