(function() {
  describe('Curve Curator service testing', function() {
    beforeEach(function() {
      return this.waitForServiceReturn = function() {
        return typeof this.serviceReturn !== 'undefined';
      };
    });
    describe('Get curve stubs from experiment code', function() {
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
    return describe('Get curve details from curve id', function() {
      beforeEach(function() {
        var self;
        self = this;
        return $.ajax({
          type: 'GET',
          url: "api/curve/detail/AG-00068922_522",
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
      it('should return curve detail with fitSummary', function() {
        waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
        return runs(function() {
          return expect(this.serviceReturn.fitSummary).tobeDefined;
        });
      });
      it('should return curve detail with curveErrors', function() {
        waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
        return runs(function() {
          return expect(this.serviceReturn.curveErrors).tobeDefined;
        });
      });
      it('should return curve detail with category', function() {
        waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
        return runs(function() {
          return expect(this.serviceReturn.category).tobeDefined;
        });
      });
      it('should return detail with approved', function() {
        waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
        return runs(function() {
          return expect(this.serviceReturn.approved).tobeDefined;
        });
      });
      it('should return curve detail with sessionID', function() {
        waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
        return runs(function() {
          return expect(this.serviceReturn.sessionID).tobeDefined;
        });
      });
      it('should return curve detail with curveAttributes', function() {
        waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
        return runs(function() {
          expect(this.serviceReturn.curveAttributes).tobeDefined;
          expect(this.serviceReturn.curveAttributes.compoundCode).toEqual("CMPD-0000001-01");
          return expect(this.serviceReturn.curveAttributes.EC50).toEqual(0.70170549529582);
        });
      });
      it('should return curve detail with plotData', function() {
        waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
        return runs(function() {
          expect(this.serviceReturn.plotData).toBeDefined();
          expect(this.serviceReturn.plotData.plotWindow).toBeDefined();
          expect(this.serviceReturn.plotData.points.dose).toBeDefined();
          expect(this.serviceReturn.plotData.points.response).toBeDefined();
          expect(this.serviceReturn.plotData.curve.dose).toBeDefined();
          return expect(this.serviceReturn.plotData.curve.response).toBeDefined();
        });
      });
      return it('should return curve detail with fitSettings', function() {
        waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
        return runs(function() {
          return expect(this.serviceReturn.fitSettings).toBeDefined();
        });
      });
    });
  });

}).call(this);
