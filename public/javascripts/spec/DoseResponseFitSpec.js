(function() {
  beforeEach(function() {
    return this.fixture = $("#fixture");
  });

  afterEach(function() {
    $("#fixture").remove();
    return $("body").append('<div id="fixture"></div>');
  });

  describe("Dose Response Fit Module Testing", function() {
    describe('DoseResponseDataParserController', function() {
      beforeEach(function() {
        this.drdpc = new DoseResponseDataParserController({
          el: $('#fixture')
        });
        return this.drdpc.render();
      });
      return describe("Basic existance", function() {
        it("should be defined", function() {
          return expect(this.drdpc).toBeDefined();
        });
        return it("should load", function() {
          return expect(this.drdpc.$('.bv_parseFile').length).toEqual(1);
        });
      });
    });
    describe('DoseResponseFitController', function() {
      beforeEach(function() {
        this.drfc = new DoseResponseFitController({
          experimentCode: "EXPT-0000012",
          el: $('#fixture')
        });
        return this.drfc.render();
      });
      return describe("Basic existance", function() {
        return it("should be defined", function() {
          return expect(this.drfc).toBeDefined();
        });
      });
    });
    return describe('DoseResponseFitWorkflowController', function() {
      beforeEach(function() {
        this.drfwc = new DoseResponseFitWorkflowController({
          el: $('#fixture')
        });
        return this.drfwc.render();
      });
      return describe("Basic existance", function() {
        it("should be defined", function() {
          return expect(this.drfwc).toBeDefined();
        });
        it("should load the template", function() {
          return expect(this.drfwc.$('.bv_dataParser').length).toEqual(1);
        });
        return it("should load the parser", function() {
          return expect(this.drfwc.$('.bv_parseFile').length).toEqual(1);
        });
      });
    });
  });

}).call(this);
