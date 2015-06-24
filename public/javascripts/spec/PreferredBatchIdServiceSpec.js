(function() {
  describe('PreferredBatchId Service testing', function() {
    beforeEach(function() {
      var serviceType;
      this.waitForServiceReturn = function() {
        return typeof this.serviceReturn !== 'undefined';
      };
      serviceType = window.conf.service.external.preferred.batchid.type;
      if (!window.AppLaunchParams.liveServiceTest) {
        this.requestData = {
          requests: [
            {
              requestName: "norm_1234:1"
            }, {
              requestName: "alias_1111:1"
            }, {
              requestName: "none_2222:1"
            }
          ]
        };
        return this.expectedResponse = {
          error: false,
          errorMessages: [],
          results: [
            {
              requestName: "norm_1234:1",
              preferredName: "norm_1234:1"
            }, {
              requestName: "alias_1111:1",
              preferredName: "norm_1111:1A"
            }, {
              requestName: "none_2222:1",
              preferredName: ""
            }
          ]
        };
      } else if (serviceType === "LabSynchCmpdReg") {
        this.requestData = {
          requests: [
            {
              requestName: "CMPD-0000001-01"
            }, {
              requestName: "none_2222:1"
            }
          ]
        };
        return this.expectedResponse = {
          error: false,
          errorMessages: [],
          results: [
            {
              requestName: "CMPD-0000001-01",
              preferredName: "CMPD-0000001-01"
            }, {
              requestName: "none_2222:1",
              preferredName: ""
            }
          ]
        };
      } else if (serviceType === "SeuratCmpdReg") {
        this.requestData = {
          requests: [
            {
              requestName: "CRA-025995-1"
            }, {
              requestName: "CRA-025995-1"
            }, {
              requestName: "none_2222:1"
            }
          ]
        };
        return this.expectedResponse = {
          error: false,
          errorMessages: [],
          results: [
            {
              requestName: "CRA-025995-1",
              preferredName: "CRA-025995-1"
            }, {
              requestName: "CRA-025995-1",
              preferredName: "CRA-025995-1"
            }, {
              requestName: "none_2222:1",
              preferredName: ""
            }
          ]
        };
      } else if (serviceType === "SingleBatchNameQueryString" || serviceType === "NewLineSepBulkPost") {
        this.requestData = {
          requests: [
            {
              requestName: "CMPD-0000001-01A"
            }, {
              requestName: "CMPD-0000002-01A"
            }, {
              requestName: "none_2222:1"
            }
          ]
        };
        return this.expectedResponse = {
          error: false,
          errorMessages: [],
          results: [
            {
              requestName: "CMPD-0000001-01A",
              preferredName: "CMPD-0000001-01A"
            }, {
              requestName: "CMPD-0000002-01A",
              preferredName: "CMPD-0000002-01A"
            }, {
              requestName: "none_2222:1",
              preferredName: ""
            }
          ]
        };
      }
    });
    return describe('get preferred batch id service', function() {
      return describe('when run with valid input', function() {
        beforeEach(function() {
          return runs(function() {
            return $.ajax({
              type: 'POST',
              url: "api/preferredBatchId",
              data: this.requestData,
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
        it('should return no error', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 5000);
          return runs(function() {
            return expect(this.serviceReturn.error).toBeFalsy();
          });
        });
        return it('full response should match expectedResponse', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 5000);
          return runs(function() {
            return expect(this.serviceReturn).toEqual(this.expectedResponse);
          });
        });
      });
    });
  });

}).call(this);
