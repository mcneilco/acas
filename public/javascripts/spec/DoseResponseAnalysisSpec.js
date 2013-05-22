(function() {
  beforeEach(function() {
    return this.fixture = $.clone($("#fixture").get(0));
  });

  afterEach(function() {
    $("#fixture").remove();
    return $("body").append($(this.fixture));
  });

  describe("Dose Response Analysis Module Testing", function() {
    return describe("basic plumbing checks with new experiment", function() {
      beforeEach(function() {
        this.drac = new DoseResponseAnalysisController({
          model: new Experiment(),
          el: $('#fixture')
        });
        return this.drac.render();
      });
      return describe("Basic loading", function() {
        it("Class should exist", function() {
          return expect(this.drac).toBeDefined();
        });
        return it("Should load the template", function() {
          return expect(this.drac.$('.bv_fixCurveMin').length).toNotEqual(0);
        });
      });
    });
  });

  /* Design questions:
    - What do we save for the batch grouping option?
    - Where do we store curve status, and what are expected values?
  */


}).call(this);
