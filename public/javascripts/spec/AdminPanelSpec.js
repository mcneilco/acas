(function() {
  beforeEach(function() {
    return this.fixture = $.clone($("#fixture").get(0));
  });

  afterEach(function() {
    $("#fixture").remove();
    return $("body").append($(this.fixture));
  });

  describe("Admin Panel testing", function() {
    describe("Admin Panel model testing", function() {
      return describe("when loaded from new", function() {
        beforeEach(function() {
          return this.ap = new AdminPanel();
        });
        return describe("existence and defaults", function() {
          it("should be defined", function() {
            return expect(this.ap).toBeDefined();
          });
          return it("should have defaults", function() {});
        });
      });
    });
    return describe("Admin Panel controller", function() {
      return describe("when instantiated from new", function() {
        beforeEach(function() {
          this.apc = new AdminPanelController({
            model: new AdminPanel(),
            el: $('#fixture')
          });
          return this.apc.render();
        });
        return describe("basic existence tests", function() {
          it("should exist", function() {
            return expect(this.apc).toBeDefined();
          });
          return it("should load the template", function() {
            return expect(this.apc.$('.bv_adminPanelWrapper').length).toEqual(1);
          });
        });
      });
    });
  });

}).call(this);
