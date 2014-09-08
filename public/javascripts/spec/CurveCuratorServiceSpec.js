(function() {
  describe('Curve Curator service testing', function() {
    var goodDataRequest;
    beforeEach(function() {
      return this.waitForServiceReturn = function() {
        return typeof this.serviceReturn !== 'undefined';
      };
    });
    describe('Get curve stubs from experiment code', function() {
      describe("when experimentCode is valid", function() {
        beforeEach(function() {
          var self;
          self = this;
          return $.ajax({
            type: 'GET',
            url: "api/curves/stubs/EXPT-00000018",
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
        it('should return an array of curve stubs', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
          return runs(function() {
            return expect(this.serviceReturn.curves.length).toBeGreaterThan(0);
          });
        });
        return it('should curve stubs with an id', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
          return runs(function() {
            return expect(this.serviceReturn.curves[0].curveid).toEqual("90807_AG-00000026");
          });
        });
      });
      return describe("when experimentCode is invalid", function() {
        beforeEach(function() {
          var self;
          self = this;
          return $.ajax({
            type: 'GET',
            url: "api/curves/stubs/EXPT-ERROR",
            success: function(json) {
              return self.serviceReturn = json;
            },
            error: function(err) {
              console.log('got ajax error');
              return self.serviceReturn = err;
            },
            dataType: 'json'
          });
        });
        return it('should return status 404', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
          return runs(function() {
            console.log(this.serviceReturn);
            return expect(this.serviceReturn.status).toEqual(404);
          });
        });
      });
    });
    describe('Get curve details from curve id', function() {
      beforeEach(function() {
        var self;
        self = this;
        return runs(function() {
          this.syncEvent = false;
          this.testModel = new CurveDetail({
            id: "AG-00068922_522"
          });
          this.testModel.on('change', (function(_this) {
            return function() {
              console.log('sync event true');
              return _this.syncEvent = true;
            };
          })(this));
          return this.testModel.fetch();
        });
      });
      it('should return curve detail with reportedValues', function() {
        waitsFor(function() {
          return this.syncEvent;
        }, 'service did not return', 2000);
        return runs(function() {
          return expect(this.testModel.get('reportedValues')).toContain("max");
        });
      });
      it('should return curve detail with fitSummary', function() {
        waitsFor(function() {
          return this.syncEvent;
        }, 'service did not return', 2000);
        return runs(function() {
          return expect(this.testModel.get('fitSummary')).toContain('Model fitted');
        });
      });
      it('should return curve detail with curveErrors', function() {
        waitsFor(function() {
          return this.syncEvent;
        }, 'service did not return', 2000);
        return runs(function() {
          return expect(this.testModel.get('curveErrors')).toContain('SSE');
        });
      });
      it('should return curve detail with category', function() {
        waitsFor(function() {
          return this.syncEvent;
        }, 'service did not return', 2000);
        return runs(function() {
          return expect(this.testModel.get('category')).toContain('sigmoid');
        });
      });
      it('should return detail with approved', function() {
        waitsFor(function() {
          return this.syncEvent;
        }, 'service did not return', 2000);
        return runs(function() {
          return expect(this.testModel.get('approved')).toBeTruthy;
        });
      });
      it('should return curve detail with sessionID', function() {
        waitsFor(function() {
          return this.syncEvent;
        }, 'service did not return', 2000);
        return runs(function() {
          return expect(this.testModel.sessionID).tobeDefined;
        });
      });
      it('should return curve detail with curveAttributes', function() {
        waitsFor(function() {
          return this.syncEvent;
        }, 'service did not return', 2000);
        return runs(function() {
          expect(this.testModel.get('curveAttributes').compoundCode).toEqual("CMPD-0000001-01");
          return expect(this.testModel.get('curveAttributes').EC50).toEqual(0.700852529214898);
        });
      });
      it('should return curve detail with plotData', function() {
        waitsFor(function() {
          return this.syncEvent;
        }, 'service did not return', 2000);
        return runs(function() {
          expect(this.testModel.get('plotData').plotWindow.length).toEqual(4);
          expect(this.testModel.get('plotData').points.dose.length).toBeGreaterThan(5);
          expect(this.testModel.get('plotData').points.response.length).toBeGreaterThan(5);
          return expect(this.testModel.get('plotData').curve.ec50).toEqual(0.7008525);
        });
      });
      return it('should return curve detail with fitSettings', function() {
        waitsFor(function() {
          return this.syncEvent;
        }, 'service did not return', 2000);
        return runs(function() {
          return expect(this.testModel.get('fitSettings').max.limitType).toEqual('pin');
        });
      });
    });
    goodDataRequest = {
      sessionID: "/var/folders/5b/s62pqy655kx6929zhxrml5c80000gn/T//rSe-34a423d5ace7",
      save: false,
      fitSettings: {
        max: {
          limitType: "pin",
          value: 101
        },
        min: {
          limitType: "none",
          value: null
        },
        slope: {
          limitType: "limit",
          value: 1.5
        },
        inactiveThreshold: 20,
        inverseAgonistMode: true
      }
    };
    return describe('Post to fit service and get response', function() {
      beforeEach(function() {
        var self;
        self = this;
        return $.ajax({
          type: 'POST',
          url: "api/curve/fit",
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
      it('should return curve detail with reportedValues', function() {
        waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
        return runs(function() {
          return expect(this.serviceReturn.reportedValues).tobeDefined;
        });
      });
      return it('should return curve detail with fitSummary', function() {
        waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
        return runs(function() {
          return expect(this.serviceReturn.fitSummary).tobeDefined;
        });
      });
    });
  });

}).call(this);
