(function() {
  describe('Project list Service testing', function() {
    beforeEach(function() {
      return this.waitForServiceReturn = function() {
        return typeof this.serviceReturn !== 'undefined';
      };
    });
    return describe('when project service called', function() {
      beforeEach(function() {
        return runs(function() {
          var _this = this;
          return $.ajax({
            type: 'GET',
            url: "api/projects",
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
      it('should return an array of projects', function() {
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

}).call(this);
