(function() {
  describe('User authentication Service testing', function() {
    beforeEach(function() {
      return this.waitForServiceReturn = function() {
        return typeof this.serviceReturn !== 'undefined';
      };
    });
    describe('when auth service called', function() {
      beforeEach(function() {
        return runs(function() {
          return $.ajax({
            type: 'POST',
            url: "api/userAuthentication",
            data: {
              user: "bob",
              password: "secret"
            },
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
      return it('should return succesfull credentials (expect to fail without valid creds in this spec file)', function() {
        waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
        return runs(function() {
          return expect(this.serviceReturn.status).toContain("Success");
        });
      });
    });
    describe('when user lookup called with valid username', function() {
      beforeEach(function() {
        return runs(function() {
          return $.ajax({
            type: 'GET',
            url: "api/users/bob",
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
      it('should return user', function() {
        waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
        return runs(function() {
          return expect(this.serviceReturn.username).toEqual("bob");
        });
      });
      it('should return firstName', function() {
        waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
        return runs(function() {
          if (window.conf.require.login) {
            return expect(this.serviceReturn.firstName).toEqual("bob");
          } else {
            return expect(this.serviceReturn.firstName).toEqual("");
          }
        });
      });
      it('should return lastName', function() {
        waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
        return runs(function() {
          if (window.conf.require.login) {
            return expect(this.serviceReturn.lastName).toEqual("bob");
          } else {
            return expect(this.serviceReturn.lastName).toEqual("bob");
          }
        });
      });
      it('should return email', function() {
        waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
        return runs(function() {
          return expect(this.serviceReturn.email).toContain("bob");
        });
      });
      return it('should not return password', function() {
        waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
        return runs(function() {
          return expect(this.serviceReturn.password).toBeUndefined();
        });
      });
    });
    return describe('when user lookup called with invalid username', function() {
      beforeEach(function() {
        return runs(function() {
          return $.ajax({
            type: 'GET',
            url: "api/users/starksofwesteros",
            success: (function(_this) {
              return function(json) {
                return _this.serviceReturn = "got 200";
              };
            })(this),
            error: (function(_this) {
              return function(err) {
                console.log('got ajax error');
                return _this.serviceReturn = null;
              };
            })(this),
            statusCode: {
              204: (function(_this) {
                return function() {
                  return _this.serviceReturn = "got 204";
                };
              })(this)
            },
            dataType: 'json'
          });
        });
      });
      return it('should return 204', function() {
        waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
        return runs(function() {
          if (window.conf.require.login) {
            return expect(this.serviceReturn).toEqual("got 204");
          } else {
            return expect(this.serviceReturn).toEqual("got 200");
          }
        });
      });
    });
  });

}).call(this);
