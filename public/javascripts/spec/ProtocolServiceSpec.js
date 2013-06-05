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
          url: "api/protocols/codename/PROT-00000033",
          data: {
            testMode: true
          },
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
          return expect(this.serviceReturn[0].codeName).toEqual("PROT-00000033");
        });
      });
    });
    describe('when fetching full Protocol by id', function() {
      beforeEach(function() {
        var self;
        self = this;
        return $.ajax({
          type: 'GET',
          url: "api/protocols/8716",
          data: {
            testMode: true
          },
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
      return it('should return a full protocol', function() {
        waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
        return runs(function() {
          return expect(this.serviceReturn.codeName).toEqual("PROT-00000033");
        });
      });
    });
    describe('when saving new protocol', function() {
      beforeEach(function() {
        var self;
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
      });
      return it('should return aa protocol', function() {
        waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
        return runs(function() {
          return expect(this.serviceReturn.id).not.toBeNull();
        });
      });
    });
    return describe('when updating existing protocol', function() {
      beforeEach(function() {
        var self;
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
      });
      return it('should return a protocol', function() {
        waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
        return runs(function() {
          return expect(this.serviceReturn.id).not.toBeNull();
        });
      });
    });
  });

}).call(this);
