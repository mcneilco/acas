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
      return it("should false if user does not a role", function() {
        var hasRole;
        hasRole = UtilityFunctions.prototype.testUserHasRole(window.loginTestJSON.sampleLoginUser, ["king of all Indinia"]);
        return expect(hasRole).toBeFalsy();
      });
    });
  });

}).call(this);
