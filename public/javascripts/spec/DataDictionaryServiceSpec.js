(function() {
  describe('Data Dictinary Service testing', function() {
    beforeEach(function() {
      return this.waitForServiceReturn = function() {
        return typeof this.serviceReturn !== 'undefined';
      };
    });
    return describe('when data dictionary service called', function() {
      beforeEach(function() {
        return runs(function() {
          return $.ajax({
            type: 'GET',
            url: "api/dataDict/well flags",
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
      it('should return an array of data dictionary values', function() {
        waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
        return runs(function() {
          return expect(this.serviceReturn.length).toBeGreaterThan(0);
        });
      });
      it('should return a hash with code defined', function() {
        waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
        return runs(function() {
          return expect(this.serviceReturn[0].code).toBeDefined();
        });
      });
      it('should return a hash with name defined', function() {
        waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
        return runs(function() {
          return expect(this.serviceReturn[0].name).toBeDefined();
        });
      });
      return it('should return a hash with ignore defined', function() {
        waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
        return runs(function() {
          return expect(this.serviceReturn[0].ignored).toBeDefined();
        });
      });
    });
  });

}).call(this);
