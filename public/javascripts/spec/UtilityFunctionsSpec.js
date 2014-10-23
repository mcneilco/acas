(function() {
  describe('Utility function module testing', function() {
    describe("basic plumbing", function() {
      return it("should be defined", function() {
        return expect(UtilityFunctions).toBeDefined();
      });
    });
    describe("getFileServiceURL function", function() {
      return it("should return the path to the file server with correct prefix for mode", function() {
        return expect(UtilityFunctions.prototype.getFileServiceURL()).toContain("upload");
      });
    });
    return describe("test user roles", function() {
      it("should true if user has a role", function() {
        var hasRole;
        console.log(window.loginTestJSON);
        hasRole = UtilityFunctions.prototype.testUserHasRole(window.loginTestJSON.sampleLoginUser, ["admin"]);
        return expect(hasRole).toBeTruthy();
      });
      it("should false if user does not a role", function() {
        var hasRole;
        hasRole = UtilityFunctions.prototype.testUserHasRole(window.loginTestJSON.sampleLoginUser, ["king of all Indinia"]);
        return expect(hasRole).toBeFalsy();
      });
      return describe("input formatting features", function() {
        beforeEach(function() {
          this.testController = new Backbone.View({
            model: new Backbone.Model(),
            el: $('#fixture')
          });
          return this.testController.render();
        });
        it("get val from input and trim it", function() {
          this.testController.$el.append("<input type='text' class='bv_testInput' />");
          this.testController.$('.bv_testInput').val("  some input with spaces  ");
          return expect(UtilityFunctions.prototype.getTrimmedInput(this.testController.$('.bv_testInput'))).toEqual("some input with spaces");
        });
        it("should parse ACAS standard format yyyy-mm-dd correctly in IE8 and other browsers", function() {
          return expect(UtilityFunctions.prototype.convertYMDDateToMs("2013-6-6")).toEqual(new Date(2013, 5, 6).getTime());
        });
        return it("should convert date from MS to yyyy-mm-dd format", function() {
          return expect(UtilityFunctions.prototype.convertMSToYMDDate(new Date(2013, 5, 6).getTime())).toEqual("2013-06-06");
        });
      });
    });
  });

}).call(this);
