(function() {
  beforeEach(function() {
    return this.fixture = $.clone($("#fixture").get(0));
  });

  afterEach(function() {
    $("#fixture").remove();
    return $("body").append($(this.fixture));
  });

  describe("Experiment Browser module testing", function() {
    describe("Experiment Search Model controller", function() {
      beforeEach(function() {
        return this.esm = new ExperimentSearch();
      });
      return describe("Basic existence tests", function() {
        it("should be defined", function() {
          return expect(ExperimentSearch).toBeDefined();
        });
        return it("should have defaults", function() {
          expect(this.esm.get('protocolCode')).toBeNull();
          return expect(this.esm.get('experimentCode')).toBeNull();
        });
      });
    });
    describe("Experiment Search Controller tests", function() {
      beforeEach(function() {
        return runs(function() {
          this.esc = new ExperimentSearchController({
            el: this.fixture
          });
          return this.esc.render();
        });
      });
      describe("Basic existence and rendering tests", function() {
        it("should be defined", function() {
          return expect(ExperimentSearchController).toBeDefined();
        });
        return it("should have a protocol code select", function() {
          return expect(this.esc.$('.bv_protocolCode').length).toEqual(1);
        });
      });
      return describe("After render", function() {
        return it("should populate the protocol select", function() {
          waitsFor(function() {
            return this.esc.$('.bv_protocolCode option').length > 0;
          }, 1000);
          return runs(function() {
            return expect(this.esc.$('.bv_protocolCode').val()).toEqual("any");
          });
        });
      });
    });
    return describe("ExperimentBrowserController tests", function() {
      beforeEach(function() {
        this.ebc = new ExperimentBrowserController({
          el: this.fixture
        });
        return this.ebc.render();
      });
      return describe("Basic existence and rendering tests", function() {
        it("should be defined", function() {
          return expect(ExperimentBrowserController).toBeDefined();
        });
        return it("should have a search controller div", function() {
          return expect(this.ebc.$('.bv_experimentSearchController').length).toEqual(1);
        });
      });
    });
  });

}).call(this);
