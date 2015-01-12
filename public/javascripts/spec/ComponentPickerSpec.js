(function() {
  beforeEach(function() {
    return this.fixture = $.clone($("#fixture").get(0));
  });

  afterEach(function() {
    $("#fixture").remove();
    return $("body").append($(this.fixture));
  });

  describe("Component Builder testing", function() {
    return describe("AddComponent model testing", function() {
      return describe("When loaded from new", function() {
        beforeEach(function() {
          return this.ac = new AddComponent();
        });
        return describe("Existence and Defaults", function() {
          it("should be defined", function() {
            return expect(this.ac).toBeDefined();
          });
          return it("should have defaults", function() {
            return expect(this.ac.get('componentType')).toEqual("unassigned");
          });
        });
      });
    });
  });

}).call(this);
