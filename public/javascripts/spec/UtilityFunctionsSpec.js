(function() {
  describe('Utility function module testing', function() {
    return describe("basic plumbing", function() {
      it("should be defined", function() {
        return expect(UtilityFunctions).toBeDefined();
      });
      return it("should return the path to the file server with correct prefix for mode", function() {
        return expect(UtilityFunctions.prototype.getFileServiceURL()).toContain("upload");
      });
    });
  });

}).call(this);
