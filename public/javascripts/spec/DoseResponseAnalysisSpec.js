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
        this.exp = new Experiment();
        this.exp.copyProtocolAttributes(new Protocol(window.protocolServiceTestJSON.fullSavedProtocol));
        this.drac = new DoseResponseAnalysisController({
          model: this.exp,
          el: $('#fixture')
        });
        return this.drac.render();
      });
      describe("Basic loading", function() {
        it("Class should exist", function() {
          return expect(this.drac).toBeDefined();
        });
        return it("Should load the template", function() {
          expect(this.drac.$('.bv_fixCurveMin').length).toNotEqual(0);
          return expect(this.drac.$('.bv_fixCurveMax').length).toNotEqual(0);
        });
      });
      describe("should populate fields", function() {
        it("should show the curve min", function() {
          return expect(this.drac.$('.bv_curveMin').val()).toEqual('0');
        });
        return it("should show the curve max", function() {
          return expect(this.drac.$('.bv_curveMax').val()).toEqual('100');
        });
      });
      describe("parameter editing", function() {
        return it("should update the model when the curve min is changed", function() {
          var value;
          this.drac.$('.bv_curveMin').val('7.0');
          this.drac.$('.bv_curveMin').change();
          value = this.drac.model.get('lsStates').getStateValueByTypeAndKind("metadata", "experiment analysis parameters", "numericValue", "curve min");
          return expect(value.get('numericValue')).toEqual(7.0);
        });
      });
      return describe("parameter editing", function() {
        return it("should update the model when the curve max is changed", function() {
          var value;
          this.drac.$('.bv_curveMax').val('100.0');
          this.drac.$('.bv_curveMax').change();
          value = this.drac.model.get('lsStates').getStateValueByTypeAndKind("metadata", "experiment analysis parameters", "numericValue", "curve max");
          return expect(value.get('numericValue')).toEqual(100.0);
        });
      });
    });
  });

}).call(this);
