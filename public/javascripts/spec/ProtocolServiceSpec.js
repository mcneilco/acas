
/*
Protocol Service specs

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
          url: "api/protocols/codename/PROT-00000001",
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
          return expect(this.serviceReturn.codeName).toContain("PROT-");
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
            return expect(this.serviceReturn.codeName).toEqual("PROT-00000001");
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
            url: "api/protocols/1234",
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
            return $.ajax({
              type: 'GET',
              url: "api/protocolLabels",
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
        it('should return an array of lsLabels', function() {
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
            return $.ajax({
              type: 'GET',
              url: "api/protocolCodes",
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
        it('should return an array of protocols', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 5000);
          return runs(function() {
            return expect(this.serviceReturn.length).toBeGreaterThan(0);
          });
        });
        it('should a hash with code defined', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 5000);
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
            matches = _.filter(this.serviceReturn, function(label) {
              return label.name === "Ignore this protocol";
            });
            return expect(matches.length).toEqual(0);
          });
        });
      });
      describe('when protocol code list service called with label filtering option', function() {
        describe("With matching case", function() {
          beforeEach(function() {
            return runs(function() {
              return $.ajax({
                type: 'GET',
                url: "api/protocolCodes/?protocolName=PK",
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
              return $.ajax({
                type: 'GET',
                url: "api/protocolCodes/?protocolName=pk",
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
          return it('should only return names with PK', function() {
            waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
            return runs(function() {
              return expect(this.serviceReturn[this.serviceReturn.length - 1].name).toContain("PK");
            });
          });
        });
      });
      describe('when protocol code list service called with protocol lsKind filtering option', function() {
        beforeEach(function() {
          return runs(function() {
            return $.ajax({
              type: 'GET',
              url: "api/protocolCodes/?protocolKind=KD",
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
        return it('should only return names with PK', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
          return runs(function() {
            return expect(this.serviceReturn[this.serviceReturn.length - 1].name).toContain("KD");
          });
        });
      });
      return describe('when protocol kind list service called', function() {
        beforeEach(function() {
          return runs(function() {
            return $.ajax({
              type: 'GET',
              url: "api/protocolKindCodes",
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
        it('should array of protocolKinds', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
          return runs(function() {
            return expect(this.serviceReturn.length).toBeGreaterThan(0);
          });
        });
        return it('should array of protocolKinds', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
          return runs(function() {
            console.log(this.serviceReturn);
            expect(this.serviceReturn[0].code).toBeDefined();
            expect(this.serviceReturn[0].name).toBeDefined();
            return expect(this.serviceReturn[0].ignored).toBeDefined();
          });
        });
      });
    });
  });

}).call(this);
