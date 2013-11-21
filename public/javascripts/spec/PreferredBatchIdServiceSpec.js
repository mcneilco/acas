(function() {
  describe('PreferredBatchId Service testing', function() {
    beforeEach(function() {
      var serviceType;
      this.waitForServiceReturn = function() {
        return typeof this.serviceReturn !== 'undefined';
      };
      serviceType = window.configurationNode.serverConfigurationParams.configuration.externalPreferredBatchIdServiceType;
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
      } else if (serviceType === "SingleBatchNameQueryString") {
        this.requestData = {
          requests: [
            {
              requestName: "CPD000000001::1"
            }, {
              requestName: "CPD000673874::1"
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
              requestName: "CPD000000001::1",
              preferredName: "CPD000000001::1"
            }, {
              requestName: "CPD000673874::1",
              preferredName: "CPD000001234::7"
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
            var _this = this;
            return $.ajax({
              type: 'POST',
              url: "api/preferredBatchId",
              data: this.requestData,
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
        it('should return no error', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
          return runs(function() {
            return expect(this.serviceReturn.error).toBeFalsy();
          });
        });
        return it('full response should match expectedResponse', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
          return runs(function() {
            return expect(this.serviceReturn).toEqual(this.expectedResponse);
          });
        });
      });
    });
  });

}).call(this);
