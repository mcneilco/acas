
/*
This suite of services provides CRUD operations on Thing Objects
 */

(function() {
  describe('Thing Service testing', function() {
    beforeEach(function() {
      return this.waitForServiceReturn = function() {
        return typeof this.serviceReturn !== 'undefined';
      };
    });
    return describe('Thing CRUD Tests', function() {
      describe('when fetching Thing by code', function() {
        beforeEach(function() {
          var self;
          self = this;
          return $.ajax({
            type: 'GET',
            url: "api/things/codeName/ExampleThing-00000021",
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
        return it('should return a thing', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
          return runs(function() {
            return expect(this.serviceReturn.codeName).toEqual("ExampleThing-00000001");
          });
        });
      });
      describe('when fetching full Thing by id', function() {
        beforeEach(function() {
          var self;
          self = this;
          return $.ajax({
            type: 'GET',
            url: "api/things/1",
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
        return it('should return a full thing object', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
          return runs(function() {
            return expect(this.serviceReturn.codeName).toEqual("ExampleThing-00000001");
          });
        });
      });
      describe('when saving new thing', function() {
        beforeEach(function() {
          var self;
          self = this;
          return $.ajax({
            type: 'POST',
            url: "api/things",
            data: window.thingTestJSON.siRNA,
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
        return it('should return a thing', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
          return runs(function() {
            return expect(this.serviceReturn.id).not.toBeNull();
          });
        });
      });
      return describe('when updating existing thing', function() {
        beforeEach(function() {
          var self;
          self = this;
          return $.ajax({
            type: 'PUT',
            url: "api/things/1234",
            data: window.thingTestJSON.siRNA,
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
        return it('should return the thing', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
          return runs(function() {
            return expect(this.serviceReturn.id).not.toBeNull();
          });
        });
      });
    });
  });

}).call(this);
