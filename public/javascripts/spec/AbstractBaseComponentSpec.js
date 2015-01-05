(function() {
  beforeEach(function() {
    return this.fixture = $.clone($("#fixture").get(0));
  });

  afterEach(function() {
    $("#fixture").remove();
    return $("body").append($(this.fixture));
  });

  describe('Abstract Base Component testing', function() {
    describe("Abstract Base Component Batch model testing", function() {
      return it("Class should exist", function() {
        return expect(window.AbstractBaseComponentBatch).toBeDefined();
      });
    });
    return describe("Base Component Batch Controller testing", function() {
      return describe("basic existence tests", function() {
        return it("Class should exist", function() {
          return expect(window.AbstractBaseComponentBatchController).toBeDefined();
        });
      });
    });
  });

}).call(this);
