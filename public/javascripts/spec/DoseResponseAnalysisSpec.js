(function() {
  beforeEach(function() {
    return this.fixture = $.clone($("#fixture").get(0));
  });

  afterEach(function() {
    $("#fixture").remove();
    return $("body").append($(this.fixture));
  });

  describe("Dose Response Analysis Module Testing", function() {
    describe("Dose Response Analysis Parameter model testing", function() {
      describe("When loaded from new", function() {
        beforeEach(function() {
          return this.drap = new DoseResponseAnalysisParameters();
        });
        return describe("Existence and Defaults", function() {
          it("should be defined", function() {
            return expect(this.drap).toBeDefined();
          });
          return it("should have defaults", function() {
            expect(this.drap.get('smartMode')).toBeTruthy();
            expect(this.drap.get('inactiveThreshold')).toEqual(20);
            expect(this.drap.get('inactiveThresholdMode')).toBeTruthy();
            expect(this.drap.get('inverseAgonistMode')).toBeFalsy();
            expect(this.drap.get('max') instanceof Backbone.Model).toBeTruthy();
            expect(this.drap.get('min') instanceof Backbone.Model).toBeTruthy();
            expect(this.drap.get('slope') instanceof Backbone.Model).toBeTruthy();
            expect(this.drap.get('max').get('limitType')).toEqual("none");
            expect(this.drap.get('min').get('limitType')).toEqual("none");
            return expect(this.drap.get('slope').get('limitType')).toEqual("none");
          });
        });
      });
      describe("model composite class tests", function() {
        beforeEach(function() {
          return this.drap = new DoseResponseAnalysisParameters(window.CurveFitTestJSON.doseResponseSimpleBulkFitOptions);
        });
        return it("should set objects to backbone models after they have been loaded", function() {
          expect(this.drap.get('max') instanceof Backbone.Model).toBeTruthy();
          expect(this.drap.get('min') instanceof Backbone.Model).toBeTruthy();
          return expect(this.drap.get('slope') instanceof Backbone.Model).toBeTruthy();
        });
      });
      return describe("model validation tests", function() {
        beforeEach(function() {
          return this.drap = new DoseResponseAnalysisParameters(window.CurveFitTestJSON.doseResponseSimpleBulkFitOptions);
        });
        it("should be valid as initialized", function() {
          return expect(this.drap.isValid()).toBeTruthy();
        });
        it("should be invalid when min limitType is pin and the value is not a number", function() {
          var filtErrors;
          this.drap.get('min').set({
            limitType: "pin"
          });
          this.drap.get('min').set({
            value: NaN
          });
          expect(this.drap.isValid()).toBeFalsy();
          filtErrors = _.filter(this.drap.validationError, function(err) {
            return err.attribute === 'min_value';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it("should be invalid when min limitType is limit and the value is not a number", function() {
          var filtErrors;
          this.drap.get('min').set({
            limitType: "limit"
          });
          this.drap.get('min').set({
            value: NaN
          });
          expect(this.drap.isValid()).toBeFalsy();
          filtErrors = _.filter(this.drap.validationError, function(err) {
            return err.attribute === 'min_value';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it("should be invalid when max limitType is pin and the value is not a number", function() {
          var filtErrors;
          this.drap.get('max').set({
            limitType: "pin"
          });
          this.drap.get('max').set({
            value: NaN
          });
          expect(this.drap.isValid()).toBeFalsy();
          filtErrors = _.filter(this.drap.validationError, function(err) {
            return err.attribute === 'max_value';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it("should be invalid when max limitType is limit and the value is not a number", function() {
          var filtErrors;
          this.drap.get('max').set({
            limitType: "limit"
          });
          this.drap.get('max').set({
            value: NaN
          });
          expect(this.drap.isValid()).toBeFalsy();
          filtErrors = _.filter(this.drap.validationError, function(err) {
            return err.attribute === 'max_value';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it("should be invalid when slope limitType is pin and the value is not a number", function() {
          var filtErrors;
          this.drap.get('slope').set({
            limitType: "pin"
          });
          this.drap.get('slope').set({
            value: NaN
          });
          expect(this.drap.isValid()).toBeFalsy();
          filtErrors = _.filter(this.drap.validationError, function(err) {
            return err.attribute === 'slope_value';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it("should be invalid when slope limitType is limit and the value is not a number", function() {
          var filtErrors;
          this.drap.get('slope').set({
            limitType: "limit"
          });
          this.drap.get('slope').set({
            value: NaN
          });
          expect(this.drap.isValid()).toBeFalsy();
          filtErrors = _.filter(this.drap.validationError, function(err) {
            return err.attribute === 'slope_value';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        return it("should be invalid when inactiveThreshold is not a number", function() {
          var filtErrors;
          this.drap.set({
            inactiveThreshold: NaN
          });
          expect(this.drap.isValid()).toBeFalsy();
          filtErrors = _.filter(this.drap.validationError, function(err) {
            return err.attribute === 'inactiveThreshold';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
      });
    });
    describe('DoseResponseAnalysisParameters Controller', function() {
      describe('when instantiated from new parameters', function() {
        beforeEach(function() {
          this.drapc = new DoseResponseAnalysisParametersController({
            model: new DoseResponseAnalysisParameters(),
            el: $('#fixture')
          });
          return this.drapc.render();
        });
        describe("basic existance tests", function() {
          it('should exist', function() {
            return expect(this.drapc).toBeDefined();
          });
          it('should load autofill template', function() {
            return expect(this.drapc.$('.bv_autofillSection').length).toEqual(1);
          });
          it('should load a template', function() {
            return expect(this.drapc.$('.bv_inverseAgonistMode').length).toEqual(1);
          });
          it('should load a template', function() {
            return expect(this.drapc.$('.bv_inactiveThresholdMode').length).toEqual(1);
          });
          it('should show smart mode mode', function() {
            return expect(this.drapc.$('.bv_smartMode').attr('checked')).toBeTruthy();
          });
          it('should show the inverse agonist mode', function() {
            return expect(this.drapc.$('.bv_inverseAgonistMode').attr('checked')).toBeFalsy();
          });
          it('should show the inactive threshold mode', function() {
            return expect(this.drapc.$('.bv_inactiveThresholdMode').attr('checked')).toBeTruthy();
          });
          it('should start with max_limitType radio set', function() {
            return expect(this.drapc.$("input[name='bv_max_limitType']:checked").val()).toEqual('none');
          });
          it('should start with min_limitType radio set', function() {
            return expect(this.drapc.$("input[name='bv_min_limitType']:checked").val()).toEqual('none');
          });
          it('should start with slope_limitType radio set', function() {
            return expect(this.drapc.$("input[name='bv_slope_limitType']:checked").val()).toEqual('none');
          });
          return it('should show the default inactive threshold', function() {
            return expect(this.drapc.$(".bv_inactiveThresholdDisplay").html()).toEqual("20");
          });
        });
        return describe("form title change", function() {
          it("should allow the form title to be changed", function() {
            this.drapc.setFormTitle("kilroy fits curves");
            return expect(this.drapc.$(".bv_formTitle").html()).toEqual("kilroy fits curves");
          });
          return it("title should stay changed after render", function() {
            this.drapc.setFormTitle("kilroy fits curves");
            this.drapc.render();
            return expect(this.drapc.$(".bv_formTitle").html()).toEqual("kilroy fits curves");
          });
        });
      });
      return describe('when instantiated from existing parameters', function() {
        beforeEach(function() {
          this.drapc = new DoseResponseAnalysisParametersController({
            model: new DoseResponseAnalysisParameters(window.CurveFitTestJSON.doseResponseSimpleBulkFitOptions),
            el: $('#fixture')
          });
          return this.drapc.render();
        });
        describe("render existing parameters", function() {
          it('should show the smart mode', function() {
            return expect(this.drapc.$('.bv_smartMode').attr('checked')).toEqual('checked');
          });
          it('should show the inverse agonist mode', function() {
            return expect(this.drapc.$('.bv_inverseAgonistMode').attr('checked')).toEqual('checked');
          });
          it('should show the inactive threshold mode', function() {
            return expect(this.drapc.$('.bv_inactiveThresholdMode').attr('checked')).toEqual('checked');
          });
          it('should start with max_limitType radio set', function() {
            return expect(this.drapc.$("input[name='bv_max_limitType']:checked").val()).toEqual('pin');
          });
          it('should start with min_limitType radio set', function() {
            return expect(this.drapc.$("input[name='bv_min_limitType']:checked").val()).toEqual('none');
          });
          it('should start with slope_limitType radio set', function() {
            return expect(this.drapc.$("input[name='bv_slope_limitType']:checked").val()).toEqual('limit');
          });
          it('should set the max_value to the number', function() {
            return expect(this.drapc.$(".bv_max_value").val()).toEqual("100");
          });
          it('should start with max_value input enabled', function() {
            expect(this.drapc.$("input[name='bv_max_limitType']:checked").val()).toEqual('pin');
            return expect(this.drapc.$(".bv_max_value").attr("disabled")).toBeUndefined();
          });
          it('should set the min_value to the number', function() {
            return expect(this.drapc.$(".bv_min_value").val()).toEqual("");
          });
          it('should start with min_value input disabled', function() {
            expect(this.drapc.$("input[name='bv_min_limitType']:checked").val()).toEqual('none');
            return expect(this.drapc.$(".bv_min_value").attr("disabled")).toEqual("disabled");
          });
          it('should set the slope_value to the number', function() {
            return expect(this.drapc.$(".bv_slope_value").val()).toEqual("1.5");
          });
          it('should start with slope_value input enabled', function() {
            expect(this.drapc.$("input[name='bv_slope_limitType']:checked").val()).toEqual('limit');
            return expect(this.drapc.$(".bv_slope_value").attr("disabled")).toBeUndefined();
          });
          return it('should show the inactive threshold', function() {
            return expect(this.drapc.$(".bv_inactiveThresholdDisplay").html()).toEqual("20");
          });
        });
        describe("model update", function() {
          it('should update the inverse agonist mode', function() {
            expect(this.drapc.model.get('inverseAgonistMode')).toBeTruthy();
            this.drapc.$('.bv_inverseAgonistMode').click();
            expect(this.drapc.model.get('inverseAgonistMode')).toBeFalsy();
            this.drapc.$('.bv_inverseAgonistMode').click();
            return expect(this.drapc.model.get('inverseAgonistMode')).toBeTruthy();
          });
          it('should update the inactive threshold mode', function() {
            expect(this.drapc.model.get('inactiveThresholdMode')).toBeTruthy();
            this.drapc.$('.bv_inactiveThresholdMode').click();
            expect(this.drapc.model.get('inactiveThresholdMode')).toBeFalsy();
            this.drapc.$('.bv_inactiveThresholdMode').click();
            return expect(this.drapc.model.get('inactiveThresholdMode')).toBeTruthy();
          });
          it('should update the max_limitType radio to none', function() {
            this.drapc.$(".bv_max_limitType_pin").click();
            this.drapc.$(".bv_max_limitType_none").click();
            this.drapc.$(".bv_max_limitType_none").click();
            return expect(this.drapc.model.get('max').get('limitType')).toEqual('none');
          });
          it('should update the max_value input to disabled when none', function() {
            this.drapc.$(".bv_max_limitType_none").click();
            this.drapc.$(".bv_max_limitType_none").click();
            expect(this.drapc.$("input[name='bv_max_limitType']:checked").val()).toEqual('none');
            return expect(this.drapc.$(".bv_max_value").attr("disabled")).toEqual("disabled");
          });
          it('should update the max_limitType radio to pin', function() {
            this.drapc.$(".bv_max_limitType_pin").click();
            this.drapc.$(".bv_max_limitType_pin").click();
            return expect(this.drapc.model.get('max').get('limitType')).toEqual('pin');
          });
          it('should update the max_value input to enabled when pin', function() {
            this.drapc.$(".bv_max_limitType_none").click();
            this.drapc.$(".bv_max_limitType_none").click();
            expect(this.drapc.$("input[name='bv_max_limitType']:checked").val()).toEqual('none');
            this.drapc.$(".bv_max_limitType_pin").click();
            this.drapc.$(".bv_max_limitType_pin").click();
            expect(this.drapc.model.get('max').get('limitType')).toEqual('pin');
            return expect(this.drapc.$(".bv_max_value").attr("disabled")).toBeUndefined();
          });
          it('should update the max_limitType radio to limit', function() {
            this.drapc.$(".bv_max_limitType_limit").click();
            this.drapc.$(".bv_max_limitType_limit").click();
            return expect(this.drapc.model.get('max').get('limitType')).toEqual('limit');
          });
          it('should update the max_value input to enabled when limit', function() {
            this.drapc.$(".bv_max_limitType_none").click();
            this.drapc.$(".bv_max_limitType_none").click();
            expect(this.drapc.$("input[name='bv_max_limitType']:checked").val()).toEqual('none');
            this.drapc.$(".bv_max_limitType_limit").click();
            this.drapc.$(".bv_max_limitType_limit").click();
            expect(this.drapc.model.get('max').get('limitType')).toEqual('limit');
            return expect(this.drapc.$(".bv_max_value").attr("disabled")).toBeUndefined();
          });
          it('should update the min_limitType radio to none', function() {
            this.drapc.$(".bv_min_limitType_pin").click();
            this.drapc.$(".bv_min_limitType_none").click();
            this.drapc.$(".bv_min_limitType_none").click();
            return expect(this.drapc.model.get('min').get('limitType')).toEqual('none');
          });
          it('should update the min_value input to disabled when none', function() {
            this.drapc.$(".bv_min_limitType_pin").click();
            this.drapc.$(".bv_min_limitType_pin").click();
            expect(this.drapc.$("input[name='bv_min_limitType']:checked").val()).toEqual('pin');
            this.drapc.$(".bv_min_limitType_none").click();
            this.drapc.$(".bv_min_limitType_none").click();
            expect(this.drapc.$("input[name='bv_min_limitType']:checked").val()).toEqual('none');
            return expect(this.drapc.$(".bv_min_value").attr("disabled")).toEqual("disabled");
          });
          it('should update the min_limitType radio to pin', function() {
            this.drapc.$(".bv_min_limitType_pin").click();
            this.drapc.$(".bv_min_limitType_pin").click();
            return expect(this.drapc.model.get('min').get('limitType')).toEqual('pin');
          });
          it('should update the min_value input to enabled when pin', function() {
            this.drapc.$(".bv_min_limitType_none").click();
            this.drapc.$(".bv_min_limitType_none").click();
            expect(this.drapc.$("input[name='bv_min_limitType']:checked").val()).toEqual('none');
            this.drapc.$(".bv_min_limitType_pin").click();
            this.drapc.$(".bv_min_limitType_pin").click();
            expect(this.drapc.model.get('min').get('limitType')).toEqual('pin');
            return expect(this.drapc.$(".bv_min_value").attr("disabled")).toBeUndefined();
          });
          it('should update the min_limitType radio to limit', function() {
            this.drapc.$(".bv_min_limitType_limit").click();
            this.drapc.$(".bv_min_limitType_limit").click();
            return expect(this.drapc.model.get('min').get('limitType')).toEqual('limit');
          });
          it('should update the min_value input to enabled when limit', function() {
            this.drapc.$(".bv_min_limitType_none").click();
            this.drapc.$(".bv_min_limitType_none").click();
            expect(this.drapc.$("input[name='bv_min_limitType']:checked").val()).toEqual('none');
            this.drapc.$(".bv_min_limitType_limit").click();
            this.drapc.$(".bv_min_limitType_limit").click();
            expect(this.drapc.model.get('min').get('limitType')).toEqual('limit');
            return expect(this.drapc.$(".bv_min_value").attr("disabled")).toBeUndefined();
          });
          it('should update the slope_limitType radio to none', function() {
            this.drapc.$(".bv_slope_limitType_none").click();
            this.drapc.$(".bv_slope_limitType_none").click();
            return expect(this.drapc.model.get('slope').get('limitType')).toEqual('none');
          });
          it('should update the slope_value input to disabled when none', function() {
            this.drapc.$(".bv_slope_limitType_none").click();
            this.drapc.$(".bv_slope_limitType_none").click();
            expect(this.drapc.$("input[name='bv_slope_limitType']:checked").val()).toEqual('none');
            return expect(this.drapc.$(".bv_slope_value").attr("disabled")).toEqual("disabled");
          });
          it('should update the slope_limitType radio to pin', function() {
            this.drapc.$(".bv_slope_limitType_pin").click();
            this.drapc.$(".bv_slope_limitType_pin").click();
            return expect(this.drapc.model.get('slope').get('limitType')).toEqual('pin');
          });
          it('should update the slope_value input to enabled when pin', function() {
            this.drapc.$(".bv_slope_limitType_none").click();
            this.drapc.$(".bv_slope_limitType_none").click();
            expect(this.drapc.$("input[name='bv_slope_limitType']:checked").val()).toEqual('none');
            this.drapc.$(".bv_slope_limitType_pin").click();
            this.drapc.$(".bv_slope_limitType_pin").click();
            expect(this.drapc.model.get('slope').get('limitType')).toEqual('pin');
            return expect(this.drapc.$(".bv_slope_value").attr("disabled")).toBeUndefined();
          });
          it('should update the slope_limitType radio to limit', function() {
            this.drapc.$(".bv_slope_limitType_none").click();
            this.drapc.$(".bv_slope_limitType_limit").click();
            this.drapc.$(".bv_slope_limitType_limit").click();
            return expect(this.drapc.model.get('slope').get('limitType')).toEqual('limit');
          });
          it('should update the slope_value input to enabled when limit', function() {
            this.drapc.$(".bv_slope_limitType_none").click();
            this.drapc.$(".bv_slope_limitType_none").click();
            expect(this.drapc.$("input[name='bv_slope_limitType']:checked").val()).toEqual('none');
            this.drapc.$(".bv_slope_limitType_limit").click();
            this.drapc.$(".bv_slope_limitType_limit").click();
            expect(this.drapc.model.get('slope').get('limitType')).toEqual('limit');
            return expect(this.drapc.$(".bv_slope_value").attr("disabled")).toBeUndefined();
          });
          it('should update the max_value', function() {
            this.drapc.$('.bv_max_value').val(" 7.5 ");
            this.drapc.$('.bv_max_value').change();
            return expect(this.drapc.model.get('max').get('value')).toEqual(7.5);
          });
          it('should update the min_value', function() {
            this.drapc.$('.bv_min_value').val(" 22.3 ");
            this.drapc.$('.bv_min_value').change();
            return expect(this.drapc.model.get('min').get('value')).toEqual(22.3);
          });
          return it('should update the slope_value', function() {
            this.drapc.$('.bv_slope_value').val(" 16.5 ");
            this.drapc.$('.bv_slope_value').change();
            return expect(this.drapc.model.get('slope').get('value')).toEqual(16.5);
          });
        });
        describe("behavior and validation", function() {
          it("should enable inactive threshold if smart mode is selected", function() {
            this.drapc.$('.bv_smartMode').click();
            this.drapc.$('.bv_smartMode').trigger('change');
            waitsFor((function(_this) {
              return function() {
                return _this.drapc.$('.bv_inactiveThresholdMode').attr('disabled') != null;
              };
            })(this), 100);
            return runs(function() {
              expect(this.drapc.$('.bv_inactiveThresholdMode').attr('disabled')).toEqual('disabled');
              return expect(this.drapc.$('.bv_inactiveThreshold').slider("option", "disabled")).toBeTruthy();
            });
          });
          it("should disable inactive threshold if smart mode is not selected", function() {
            this.drapc.$('.bv_smartMode').click();
            this.drapc.$('.bv_smartMode').trigger('change');
            waitsFor((function(_this) {
              return function() {
                return expect(_this.drapc.$('.bv_inactiveThresholdMode').attr('disabled')) != null;
              };
            })(this), 100);
            return runs(function() {
              expect(this.drapc.$('.bv_inactiveThresholdMode').attr('disabled')).toBeDefined();
              return expect(this.drapc.$('.bv_inactiveThreshold').slider("option", "disabled")).toBeTruthy();
            });
          });
          return it("should disable the inactive threshold slider if inactive threshold is deselected", function() {
            expect(this.drapc.model.get('inactiveThresholdMode')).toBeTruthy();
            this.drapc.$('.bv_inactiveThresholdMode').click();
            expect(this.drapc.model.get('inactiveThresholdMode')).toBeFalsy();
            this.drapc.$('.bv_inactiveThresholdMode').click();
            expect(this.drapc.model.get('inactiveThresholdMode')).toBeTruthy();
            return expect(this.drapc.$('.bv_inactiveThreshold').slider("option", "disabled")).toBeTruthy();
          });
        });
        return describe("validation testing", function() {
          return describe("error notification", function() {
            it("should show error if max_limitType is set to pin and max_value is not set", function() {
              this.drapc.model.get('max').set({
                limitType: 'pin'
              });
              this.drapc.$('.bv_max_value').val("");
              this.drapc.$('.bv_max_value').change();
              return expect(this.drapc.$('.bv_group_max_value').hasClass("error")).toBeTruthy();
            });
            it("should show error if max_limitType is set to limit and max_value is not set", function() {
              this.drapc.model.get('max').set({
                limitType: 'limit'
              });
              this.drapc.$('.bv_max_value').val("");
              this.drapc.$('.bv_max_value').change();
              return expect(this.drapc.$('.bv_group_max_value').hasClass("error")).toBeTruthy();
            });
            it("should show error if min_limitType is set to pin and min_value is not set", function() {
              this.drapc.model.get('min').set({
                limitType: 'pin'
              });
              this.drapc.$('.bv_min_value').val("");
              this.drapc.$('.bv_min_value').change();
              return expect(this.drapc.$('.bv_group_min_value').hasClass("error")).toBeTruthy();
            });
            it("should show error if min_limitType is set to limit and min_value is not set", function() {
              this.drapc.model.get('min').set({
                limitType: 'limit'
              });
              this.drapc.$('.bv_min_value').val("");
              this.drapc.$('.bv_min_value').change();
              return expect(this.drapc.$('.bv_group_min_value').hasClass("error")).toBeTruthy();
            });
            it("should show error if slope_limitType is set to pin and slope_value is not set", function() {
              this.drapc.model.get('slope').set({
                limitType: 'pin'
              });
              this.drapc.$('.bv_slope_value').val("");
              this.drapc.$('.bv_slope_value').change();
              return expect(this.drapc.$('.bv_group_slope_value').hasClass("error")).toBeTruthy();
            });
            return it("should show error if slope_limitType is set to limit and slope_value is not set", function() {
              this.drapc.model.get('slope').set({
                limitType: 'limit'
              });
              this.drapc.$('.bv_slope_value').val("");
              this.drapc.$('.bv_slope_value').change();
              return expect(this.drapc.$('.bv_group_slope_value').hasClass("error")).toBeTruthy();
            });
          });
        });
      });
    });
    return describe("DoseResponseAnalysisController testing", function() {
      describe("basic plumbing checks with experiment copied from template", function() {
        beforeEach(function() {
          this.exp = new PrimaryScreenExperiment();
          this.exp.copyProtocolAttributes(new Protocol(window.protocolServiceTestJSON.fullSavedProtocol));
          this.drac = new DoseResponseAnalysisController({
            model: this.exp,
            el: $('#fixture')
          });
          return this.drac.render();
        });
        describe("Basic loading", function() {
          it("Class should exist", function() {
            return expect(this.drac).toBeDefined;
          });
          return it("Should load the template", function() {
            return expect(this.drac.$('.bv_modelFitStatus').length).toNotEqual(0);
          });
        });
        describe("display logic not ready to fit", function() {
          it("should show model fit status Curves not fit becuase this is a new experiment", function() {
            return expect(this.drac.$('.bv_modelFitStatus').html()).toEqual(" Curves not fit");
          });
          it("should not show model fit results becuase this is a new experiment", function() {
            expect(this.drac.$('.bv_modelFitResultsHTML').html()).toEqual("");
            return expect(this.drac.$('.bv_resultsContainer')).toBeHidden();
          });
          return it("should be able to hide model fit controller", function() {
            this.drac.setNotReadyForFit();
            expect(this.drac.$('.bv_fitOptionWrapper')).toBeHidden();
            return expect(this.drac.$('.bv_analyzeExperimentToFit')).toBeVisible();
          });
        });
        return describe("display logic after ready to fit", function() {
          beforeEach(function() {
            return this.drac.setReadyForFit();
          });
          it("Should load the fit parameter form", function() {
            return expect(this.drac.$('.bv_max_limitType_none').length).toNotEqual(0);
          });
          return it("should be able to show model controller", function() {
            expect(this.drac.$('.bv_fitOptionWrapper')).toBeVisible();
            return expect(this.drac.$('.bv_analyzeExperimentToFit')).toBeHidden();
          });
        });
      });
      describe("experiment status locks analysis", function() {
        beforeEach(function() {
          this.exp = new PrimaryScreenExperiment(window.experimentServiceTestJSON.fullExperimentFromServer);
          this.drac = new DoseResponseAnalysisController({
            model: this.exp,
            el: $('#fixture')
          });
          this.drac.model.getAnalysisStatus().set({
            codeValue: "analsysis complete"
          });
          this.drac.primaryAnalysisCompleted();
          return this.drac.render();
        });
        describe("experiment status change handling", function() {
          it("Should disable model fit parameter editing if status is Finalized", function() {
            this.drac.model.getStatus().set({
              codeValue: "finalized"
            });
            return expect(this.drac.$('.bv_max_limitType_none').attr('disabled')).toEqual('disabled');
          });
          it("Should enable analsyis parameter editing if status is Started", function() {
            this.drac.model.getStatus().set({
              codeValue: "finalized"
            });
            this.drac.model.getStatus().set({
              codeValue: "started"
            });
            return expect(this.drac.$('.bv_max_limitType').attr('disabled')).toBeUndefined();
          });
          return it("should show fit button as Re-Fit since status is ' Curves not fit'", function() {
            return expect(this.drac.$('.bv_fitModelButton').html()).toEqual("Re-Fit");
          });
        });
        return describe("Form valid change handling", function() {
          it("should show button enabled since form loaded with valid values from test fixture", function() {
            return expect(this.drac.$('.bv_fitModelButton').attr('disabled')).toBeUndefined();
          });
          return it("should show button disabled when form is invalid", function() {
            this.drac.$('.bv_max_value').val("");
            this.drac.$('.bv_max_value').change();
            return expect(this.drac.$('.bv_fitModelButton').attr('disabled')).toEqual('disabled');
          });
        });
      });
      return describe("handling re-fit", function() {
        beforeEach(function() {
          this.exp = new PrimaryScreenExperiment(window.experimentServiceTestJSON.fullExperimentFromServer);
          this.exp.getAnalysisStatus().set({
            codeValue: "analsysis complete"
          });
          this.exp.getModelFitStatus().set({
            codeValue: "model fit complete"
          });
          this.drac = new DoseResponseAnalysisController({
            model: this.exp,
            el: $('#fixture')
          });
          return this.drac.render();
        });
        return describe("upon render", function() {
          return it("should show fit button as re-analyze when fit status is not 'not started'", function() {
            return expect(this.drac.$('.bv_fitModelButton').html()).toEqual("Re-Fit");
          });
        });
      });
    });
  });

}).call(this);
