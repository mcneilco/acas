(function() {
  describe('Cationic Block Service testing', function() {
    beforeEach(function() {
      return this.waitForServiceReturn = function() {
        return typeof this.serviceReturn !== 'undefined';
      };
    });
    describe('Cationic Block Parent CRUD Tests', function() {
      describe('when fetching parent by code', function() {
        beforeEach(function() {
          var self;
          self = this;
          return $.ajax({
            type: 'GET',
            url: "api/cationicBlockParents/codeName/CB000001",
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
        return it('should return a cationic block parent', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
          return runs(function() {
            return expect(this.serviceReturn.codeName).toEqual("CB000001");
          });
        });
      });
      describe('when saving new parent', function() {
        beforeEach(function() {
          var self;
          self = this;
          return $.ajax({
            type: 'POST',
            url: "api/cationicBlockParents",
            data: window.cationicBlockTestJSON.cationicBlockParent,
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
        return it('should return a parent', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
          return runs(function() {
            return expect(this.serviceReturn.id).not.toBeNull();
          });
        });
      });
      return describe('when updating existing parent', function() {
        beforeEach(function() {
          var self;
          self = this;
          return $.ajax({
            type: 'PUT',
            url: "api/cationicBlockParents/1234",
            data: window.cationicBlockTestJSON.cationicBlockParent,
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
        return it('should return a parent', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
          return runs(function() {
            return expect(this.serviceReturn.id).not.toBeNull();
          });
        });
      });
    });
    return describe('Cationic Block Batch CRUD Tests', function() {
      describe('when fetching Cationic Block batch codeNames by cationic block parent codeName', function() {
        beforeEach(function() {
          var self;
          self = this;
          return $.ajax({
            type: 'GET',
            url: "api/batches/parentCodeName/CB000001",
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
        return it('should return an array of cationic block batch codeNames', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
          return runs(function() {
            console.log("done");
            console.log(this.serviceReturn);
            return expect(this.serviceReturn[0].codeName).toEqual("CB000001-1");
          });
        });
      });
      describe('when fetching batch by codeName', function() {
        beforeEach(function() {
          var self;
          self = this;
          return $.ajax({
            type: 'GET',
            url: "api/batches/codeName/CB000001-1",
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
        return it('should return the batch model', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
          return runs(function() {
            console.log("done");
            console.log(this.serviceReturn);
            return expect(this.serviceReturn.codeName).toEqual("CB000001-1");
          });
        });
      });
      describe('when saving new batch', function() {
        beforeEach(function() {
          var self;
          self = this;
          return $.ajax({
            type: 'POST',
            url: "api/cationicBlockBatches",
            data: window.cationicBlockTestJSON.cationicBlockBatch,
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
        return it('should return a batch', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
          return runs(function() {
            return expect(this.serviceReturn.id).not.toBeNull();
          });
        });
      });
      return describe('when updating existing batch', function() {
        beforeEach(function() {
          var self;
          self = this;
          return $.ajax({
            type: 'PUT',
            url: "api/cationicBlockBatches/1234",
            data: window.cationicBlockTestJSON.cationicBlockBatch,
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
        return it('should return a parent', function() {
          waitsFor(this.waitForServiceReturn, 'service did not return', 2000);
          return runs(function() {
            return expect(this.serviceReturn.id).not.toBeNull();
          });
        });
      });
    });
  });

}).call(this);
