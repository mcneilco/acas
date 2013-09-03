/*
Protocol Service specs

Just implenting GET for now

See ProtocolServiceTestJSON.coffee for examples
*/


(function() {
  describe('Protocol CRUD testing', function() {
    beforeEach(function() {
      return this.waitForServiceReturn = function() {
        return typeof this.serviceReturn !== 'undefined';
      };
    });
    describe('when fetching Protocol stub by code', function() {
      beforeEach(function() {
        var self;

        self = this;
        return $.ajax({
          type: 'GET',
          url: "api/protocols/codename/PROT-00000002",
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
      return it('should return a protocol stub', function() {
        waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
        return runs(function() {
          return expect(this.serviceReturn[0].codeName).toContain("PROT-");
        });
      });
    });
    describe('when fetching full Protocol by id', function() {
      beforeEach(function() {
        var self;

        if (!window.AppLaunchParams.liveServiceTest) {
          self = this;
          return $.ajax({
            type: 'GET',
            url: "api/protocols/8716",
            success: function(json) {
              return self.serviceReturn = json;
            },
            error: function(err) {
              console.log('got ajax error');
              return self.serviceReturn = null;
            },
            dataType: 'json'
          });
        }
      });
      return it('should return a full protocol', function() {
        if (!window.AppLaunchParams.liveServiceTest) {
          waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
          return runs(function() {
            return expect(this.serviceReturn.codeName).toEqual("PROT-00000033");
          });
        }
      });
    });
    describe('when saving new protocol', function() {
      beforeEach(function() {
        var self;

        if (!window.AppLaunchParams.liveServiceTest) {
          self = this;
          return $.ajax({
            type: 'POST',
            url: "api/protocols",
            data: window.protocolServiceTestJSON.protocolToSave,
            success: function(json) {
              return self.serviceReturn = json;
            },
            error: function(err) {
              console.log('got ajax error');
              return self.serviceReturn = null;
            },
            dataType: 'json'
          });
        }
      });
      return it('should return aa protocol', function() {
        if (!window.AppLaunchParams.liveServiceTest) {
          waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
          return runs(function() {
            return expect(this.serviceReturn.id).not.toBeNull();
          });
        }
      });
    });
    describe('when updating existing protocol', function() {
      beforeEach(function() {
        var self;

        if (!window.AppLaunchParams.liveServiceTest) {
          self = this;
          return $.ajax({
            type: 'PUT',
            url: "api/protocols",
            data: window.protocolServiceTestJSON.fullSavedProtocol,
            success: function(json) {
              return self.serviceReturn = json;
            },
            error: function(err) {
              console.log('got ajax error');
              return self.serviceReturn = null;
            },
            dataType: 'json'
          });
        }
      });
      return it('should return a protocol', function() {
        if (!window.AppLaunchParams.liveServiceTest) {
          waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
          return runs(function() {
            return expect(this.serviceReturn.id).not.toBeNull();
          });
        }
      });
    });
    return describe("Protocol related services", function() {
      describe('when protocol labels service called', function() {
        beforeEach(function() {
          return runs(function() {
            var _this = this;

            return $.ajax({
              type: 'GET',
              url: "api/protocolLabels",
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
        it('should return an array of protocolLabels', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
          return runs(function() {
            return expect(this.serviceReturn.length).toBeGreaterThan(0);
          });
        });
        return it('labels should include a protocol code', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
          return runs(function() {
            return expect(this.serviceReturn[0].protocol.codeName).toContain("PROT-");
          });
        });
      });
      describe('when protocol code list service called', function() {
        beforeEach(function() {
          return runs(function() {
            var _this = this;

            return $.ajax({
              type: 'GET',
              url: "api/protocolCodes",
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
        it('should return an array of protocols', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
          return runs(function() {
            return expect(this.serviceReturn.length).toBeGreaterThan(0);
          });
        });
        it('should a hash with code defined', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
          return runs(function() {
            return expect(this.serviceReturn[0].code).toContain("PROT-");
          });
        });
        it('should a hash with name defined', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
          return runs(function() {
            return expect(this.serviceReturn[0].name).toBeDefined();
          });
        });
        it('should a hash with ignore defined', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
          return runs(function() {
            return expect(this.serviceReturn[0].ignored).toBeDefined();
          });
        });
        it('should return some names without PK', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
          return runs(function() {
            return expect(this.serviceReturn[this.serviceReturn.length - 1].name).toNotContain("PK");
          });
        });
        return it('should not return protocols where protocol itself is set to ignore', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
          return runs(function() {
            var matches;

            console.log(this.serviceReturn);
            matches = _.filter(this.serviceReturn, function(label) {
              return label.name === "Ignore this protocol";
            });
            return expect(matches.length).toEqual(0);
          });
        });
      });
      return describe('when protocol code list service called with filtering option', function() {
        describe("With matching case", function() {
          beforeEach(function() {
            return runs(function() {
              var _this = this;

              return $.ajax({
                type: 'GET',
                url: "api/protocolCodes/filter/PK",
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
          return it('should only return names with PK', function() {
            waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
            return runs(function() {
              return expect(this.serviceReturn[this.serviceReturn.length - 1].name).toContain("PK");
            });
          });
        });
        return describe("With non-matching case", function() {
          beforeEach(function() {
            return runs(function() {
              var _this = this;

              return $.ajax({
                type: 'GET',
                url: "api/protocolCodes/filter/pk",
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
          return it('should only return names with PK', function() {
            waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
            return runs(function() {
              return expect(this.serviceReturn[this.serviceReturn.length - 1].name).toContain("PK");
            });
          });
        });
      });
    });
  });

}).call(this);
