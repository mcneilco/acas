(function() {
  describe('User authentication Service testing', function() {
    beforeEach(function() {
      this.waitForServiceReturn = function() {
        return typeof this.serviceReturn !== 'undefined';
      };
      return console.log("got to new spec");
    });
    return describe('when auth service called', function() {
      beforeEach(function() {
        return runs(function() {
          var _this = this;
          return $.ajax({
            type: 'POST',
            url: "api/userAuthentication",
            data: {
              user: "ldap-query",
              password: "Est@P7uRi5SyR+"
            },
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
      return it('should return succesfull credentials', function() {
        waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
        return runs(function() {
          return expect(this.serviceReturn.status).toContain("Success");
        });
      });
    });
  });

}).call(this);
