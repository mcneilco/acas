(function() {
  describe("Reagent Registration Services tests", function() {
    describe('Project list Service testing', function() {
      beforeEach(function() {
        return this.waitForServiceReturn = function() {
          return typeof this.serviceReturn !== 'undefined';
        };
      });
      return describe('when get reagent by code service called', function() {
        beforeEach(function() {
          return runs(function() {
            return $.ajax({
              type: 'GET',
              url: "api/reagentReg/reagents/codename",
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
        return it('should return a reagent with a barcode', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
          return runs(function() {
            return expect(this.serviceReturn.barcode).toBeDefined();
          });
        });
      });
    });
    return describe('Hazard category list testing', function() {
      beforeEach(function() {
        return this.waitForServiceReturn = function() {
          return typeof this.serviceReturn !== 'undefined';
        };
      });
      return describe('when hazard category service called', function() {
        beforeEach(function() {
          return runs(function() {
            return $.ajax({
              type: 'GET',
              url: "api/reagentReg/hazardCatagories",
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
        it('should return an array of hazard categories', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
          return runs(function() {
            return expect(this.serviceReturn.length).toBeGreaterThan(0);
          });
        });
        it('should be a hash with code defined', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
          return runs(function() {
            return expect(this.serviceReturn[0].code).toBeDefined();
          });
        });
        it('should be a hash with name defined', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
          return runs(function() {
            return expect(this.serviceReturn[0].name).toBeDefined();
          });
        });
        return it('should be a hash with ignore defined', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
          return runs(function() {
            return expect(this.serviceReturn[0].ignored).toBeDefined();
          });
        });
      });
    });
  });

}).call(this);
