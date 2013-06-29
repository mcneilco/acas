/*
This service saves and fetches DocForBatches items
*/


(function() {
  var goodExampleData, returnExampleError, returnExampleSuccess;

  goodExampleData = {
    docForBatches: window.testJSON.docForBatches,
    user: 'jmcneil'
  };

  returnExampleSuccess = {
    transactionId: 1234,
    results: {
      transactionId: 1234
    },
    hasError: false,
    hasWarning: true,
    errorMessages: []
  };

  returnExampleError = {
    transactionId: null,
    results: null,
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

  describe('DocForBatches Service testing', function() {
    beforeEach(function() {
      return this.waitForServiceReturn = function() {
        return typeof this.serviceReturn !== 'undefined';
      };
    });
    describe('get existing entity from docForBatches', function() {
      return describe('when run with valid input', function() {
        beforeEach(function() {
          return runs(function() {
            var _this = this;

            return $.ajax({
              type: 'GET',
              url: "api/docForBatches/1",
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
        it('should return a valide model', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 3000);
          return runs(function() {
            return expect(this.serviceReturn.id).toEqual(1235);
          });
        });
        return it('should return a fileName', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 3000);
          return runs(function() {
            return expect(this.serviceReturn.docUpload.currentFileName).toEqual("exampleUploadedFile.txt");
          });
        });
      });
    });
    return describe('post new entity to docForBatches', function() {
      describe('when run with valid input', function() {
        beforeEach(function() {
          return runs(function() {
            var _this = this;

            return $.ajax({
              type: 'POST',
              url: "api/docForBatches",
              data: goodExampleData,
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
        it('should return error=false', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 3000);
          return runs(function() {
            expect(this.serviceReturn.error).toBeFalsy();
            return expect(this.serviceReturn.errorMessages.length).toEqual(0);
          });
        });
        it('should return a transactionId', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 3000);
          return runs(function() {
            return expect(this.serviceReturn.transactionId).toBeDefined();
          });
        });
        return it('should return a docForBatchesID', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 3000);
          return runs(function() {
            return expect(this.serviceReturn.results.id).toBeDefined();
          });
        });
      });
      return describe('when run with bad data', function() {
        beforeEach(function() {
          var _this = this;

          goodExampleData.docForBatches.batchNameList[0].preferredName = "";
          return $.ajax({
            type: 'POST',
            url: "api/docForBatches",
            data: goodExampleData,
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
        it('should return error=true', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 3000);
          return runs(function() {
            return expect(this.serviceReturn.error).toBeTruthy();
          });
        });
        it('should not return a load event ID', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 3000);
          return runs(function() {
            return expect(this.serviceReturn.transactionId).toBeNull();
          });
        });
        return it('should return error messages', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 3000);
          return runs(function() {
            expect(this.serviceReturn.errorMessages.length).toEqual(1);
            return expect(this.serviceReturn.errorMessages[0].errorLevel).toEqual("error");
          });
        });
      });
    });
  });

}).call(this);
