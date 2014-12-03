(function() {
  describe('Internalization Agent testing', function() {
    return describe("When created from existing", function() {
      beforeEach(function() {
        return this.iaParent = new InternalizationAgentParent(JSON.parse(JSON.stringify(window.internalizationAgentTestJSON.internalizationAgentParent)));
      });
      return describe("Existence and Defaults", function() {
        return it("should be defined", function() {
          console.log(this.iaParent);
          return expect(this.iaParent).toBeDefined();
        });
      });
    });
  });

}).call(this);
