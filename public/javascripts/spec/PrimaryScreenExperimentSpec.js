(function() {
  beforeEach(function() {
    return this.fixture = $.clone($("#fixture").get(0));
  });

  afterEach(function() {
    $("#fixture").remove();
    return $("body").append($(this.fixture));
  });

  describe("Primary Screen Experiment module testing", function() {
    describe("Analysis Parameter model testing", function() {
      describe("When loaded from new", function() {
        beforeEach(function() {
          return this.psap = new PrimaryScreenAnalysisParameters();
        });
        return describe("Existence and Defaults", function() {
          it("should be defined", function() {
            return expect(this.psap).toBeDefined();
          });
          return it("should have defaults", function() {
            expect(this.psap.get('transformationRule')).toEqual("unassigned");
            expect(this.psap.get('normalizationRule')).toEqual("unassigned");
            expect(this.psap.get('hitEfficacyThreshold')).toBeNull();
            expect(this.psap.get('hitSDThreshold')).toBeNull();
            expect(this.psap.get('positiveControl') instanceof Backbone.Model).toBeTruthy();
            expect(this.psap.get('negativeControl') instanceof Backbone.Model).toBeTruthy();
            expect(this.psap.get('vehicleControl') instanceof Backbone.Model).toBeTruthy();
            expect(this.psap.get('agonistControl') instanceof Backbone.Model).toBeTruthy();
            return expect(this.psap.get('thresholdType')).toEqual("sd");
          });
        });
      });
      return describe("model validation tests", function() {
        beforeEach(function() {
          return this.psap = new PrimaryScreenAnalysisParameters(window.primaryScreenTestJSON.primaryScreenAnalysisParameters);
        });
        it("should be valid as initialized", function() {
          return expect(this.psap.isValid()).toBeTruthy();
        });
        it("should be invalid when positive control batch is empty", function() {
          var filtErrors;
          this.psap.get('positiveControl').set({
            batchCode: ""
          });
          expect(this.psap.isValid()).toBeFalsy();
          filtErrors = _.filter(this.psap.validationError, function(err) {
            return err.attribute === 'positiveControlBatch';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it("should be invalid when positive control conc is NaN", function() {
          var filtErrors;
          this.psap.get('positiveControl').set({
            concentration: NaN
          });
          expect(this.psap.isValid()).toBeFalsy();
          filtErrors = _.filter(this.psap.validationError, function(err) {
            return err.attribute === 'positiveControlConc';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it("should be invalid when negative control batch is empty", function() {
          var filtErrors;
          this.psap.get('negativeControl').set({
            batchCode: ""
          });
          expect(this.psap.isValid()).toBeFalsy();
          filtErrors = _.filter(this.psap.validationError, function(err) {
            return err.attribute === 'negativeControlBatch';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it("should be invalid when negative control conc is NaN", function() {
          var filtErrors;
          this.psap.get('negativeControl').set({
            concentration: NaN
          });
          expect(this.psap.isValid()).toBeFalsy();
          filtErrors = _.filter(this.psap.validationError, function(err) {
            return err.attribute === 'negativeControlConc';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it("should be invalid when agonist control batch is empty", function() {
          var filtErrors;
          this.psap.get('agonistControl').set({
            batchCode: ""
          });
          expect(this.psap.isValid()).toBeFalsy();
          filtErrors = _.filter(this.psap.validationError, function(err) {
            return err.attribute === 'agonistControlBatch';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it("should be invalid when agonist control conc is NaN", function() {
          var filtErrors;
          this.psap.get('agonistControl').set({
            concentration: NaN
          });
          expect(this.psap.isValid()).toBeFalsy();
          filtErrors = _.filter(this.psap.validationError, function(err) {
            return err.attribute === 'agonistControlConc';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it("should be invalid when vehicle control is empty", function() {
          var filtErrors;
          this.psap.get('vehicleControl').set({
            batchCode: ""
          });
          expect(this.psap.isValid()).toBeFalsy();
          filtErrors = _.filter(this.psap.validationError, function(err) {
            return err.attribute === 'vehicleControlBatch';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it("should be invalid when transformation rule is unassigned", function() {
          var filtErrors;
          this.psap.set({
            transformationRule: "unassigned"
          });
          expect(this.psap.isValid()).toBeFalsy();
          filtErrors = _.filter(this.psap.validationError, function(err) {
            return err.attribute === 'transformationRule';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it("should be invalid when normalization rule is unassigned", function() {
          var filtErrors;
          this.psap.set({
            normalizationRule: "unassigned"
          });
          expect(this.psap.isValid()).toBeFalsy();
          filtErrors = _.filter(this.psap.validationError, function(err) {
            return err.attribute === 'normalizationRule';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it("should be invalid when thresholdType is sd and hitSDThreshold is not a number", function() {
          var filtErrors;
          this.psap.set({
            thresholdType: "sd"
          });
          this.psap.set({
            hitSDThreshold: NaN
          });
          expect(this.psap.isValid()).toBeFalsy();
          filtErrors = _.filter(this.psap.validationError, function(err) {
            return err.attribute === 'hitSDThreshold';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        return it("should be invalid when thresholdType is efficacy and hitEfficacyThreshold is not a number", function() {
          var filtErrors;
          this.psap.set({
            thresholdType: "efficacy"
          });
          this.psap.set({
            hitEfficacyThreshold: NaN
          });
          expect(this.psap.isValid()).toBeFalsy();
          filtErrors = _.filter(this.psap.validationError, function(err) {
            return err.attribute === 'hitEfficacyThreshold';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
      });
    });
    describe("Primary Screen Experiment model testing", function() {
      describe("When loaded from existing", function() {
        beforeEach(function() {
          return this.pse = new PrimaryScreenExperiment(window.experimentServiceTestJSON.fullExperimentFromServer);
        });
        describe("Existence and Defaults", function() {
          return it("should be defined", function() {
            return expect(this.pse).toBeDefined();
          });
        });
        return describe("special getters", function() {
          describe("analysis parameters", function() {
            it('Should be able to get analysis parameters', function() {
              return expect(this.pse.getAnalysisParameters() instanceof PrimaryScreenAnalysisParameters).toBeTruthy();
            });
            it('Should parse analysis parameters', function() {
              return expect(this.pse.getAnalysisParameters().get('hitSDThreshold')).toEqual(5);
            });
            it('Should parse pos control into backbone models', function() {
              return expect(this.pse.getAnalysisParameters().get('positiveControl').get('batchCode')).toEqual("CMPD-12345678-01");
            });
            it('Should parse neg control into backbone models', function() {
              return expect(this.pse.getAnalysisParameters().get('negativeControl').get('batchCode')).toEqual("CMPD-87654321-01");
            });
            it('Should parse veh control into backbone models', function() {
              return expect(this.pse.getAnalysisParameters().get('vehicleControl').get('batchCode')).toEqual("CMPD-00000001-01");
            });
            return it('Should parse agonist control into backbone models', function() {
              return expect(this.pse.getAnalysisParameters().get('agonistControl').get('batchCode')).toEqual("CMPD-87654399-01");
            });
          });
          return describe("special states", function() {
            it("should be able to get the analysis status", function() {
              return expect(this.pse.getAnalysisStatus().get('stringValue')).toEqual("not started");
            });
            return it("should be able to get the analysis result html", function() {
              return expect(this.pse.getAnalysisResultHTML().get('clobValue')).toEqual("<p>Analysis not yet completed</p>");
            });
          });
        });
      });
      return describe("When loaded from new", function() {
        beforeEach(function() {
          return this.pse2 = new PrimaryScreenExperiment();
        });
        return describe("special states", function() {
          it("should be able to get the analysis status", function() {
            return expect(this.pse2.getAnalysisStatus().get('stringValue')).toEqual("not started");
          });
          return it("should be able to get the analysis result html", function() {
            return expect(this.pse2.getAnalysisResultHTML().get('clobValue')).toEqual("");
          });
        });
      });
    });
    describe('PrimaryScreenAnalysisParameters Controller', function() {
      describe('when instantiated', function() {
        beforeEach(function() {
          this.psapc = new PrimaryScreenAnalysisParametersController({
            model: new PrimaryScreenAnalysisParameters(window.primaryScreenTestJSON.primaryScreenAnalysisParameters),
            el: $('#fixture')
          });
          return this.psapc.render();
        });
        describe("basic existance tests", function() {
          it('should exist', function() {
            return expect(this.psapc).toBeDefined();
          });
          it('should load a template', function() {
            return expect(this.psapc.$('.bv_autofillSection').length).toEqual(1);
          });
          return it('should load autofill template', function() {
            return expect(this.psapc.$('.bv_hitSDThreshold').length).toEqual(1);
          });
        });
        describe("render existing parameters", function() {
          it('should show the transformation rule', function() {
            return expect(this.psapc.$('.bv_transformationRule').val()).toEqual("(maximum-minimum)/minimum");
          });
          it('should show the normalization rule', function() {
            return expect(this.psapc.$('.bv_normalizationRule').val()).toEqual("plate order");
          });
          it('should show the hitSDThreshold', function() {
            return expect(this.psapc.$('.bv_hitSDThreshold').val()).toEqual('5');
          });
          it('should show the hitEfficacyThreshold', function() {
            return expect(this.psapc.$('.bv_hitEfficacyThreshold').val()).toEqual('42');
          });
          it('should start with thresholdType radio set', function() {
            return expect(this.psapc.$("input[name='bv_thresholdType']:checked").val()).toEqual('sd');
          });
          it('should show the positiveControlBatch', function() {
            return expect(this.psapc.$('.bv_positiveControlBatch').val()).toEqual('CMPD-12345678-01');
          });
          it('should show the positiveControlConc', function() {
            return expect(this.psapc.$('.bv_positiveControlConc').val()).toEqual('10');
          });
          it('should show the negativeControlBatch', function() {
            return expect(this.psapc.$('.bv_negativeControlBatch').val()).toEqual('CMPD-87654321-01');
          });
          it('should show the negativeControlConc', function() {
            return expect(this.psapc.$('.bv_negativeControlConc').val()).toEqual('1');
          });
          it('should show the vehControlBatch', function() {
            return expect(this.psapc.$('.bv_vehicleControlBatch').val()).toEqual('CMPD-00000001-01');
          });
          it('should show the agonistControlBatch', function() {
            return expect(this.psapc.$('.bv_agonistControlBatch').val()).toEqual('CMPD-87654399-01');
          });
          return it('should show the agonistControlConc', function() {
            return expect(this.psapc.$('.bv_agonistControlConc').val()).toEqual('2');
          });
        });
        describe("model updates", function() {
          it("should update the transformation rule", function() {
            this.psapc.$('.bv_transformationRule').val('unassigned');
            this.psapc.$('.bv_transformationRule').change();
            return expect(this.psapc.model.get('transformationRule')).toEqual("unassigned");
          });
          it("should update the normalizationRule rule", function() {
            this.psapc.$('.bv_normalizationRule').val('unassigned');
            this.psapc.$('.bv_normalizationRule').change();
            return expect(this.psapc.model.get('normalizationRule')).toEqual("unassigned");
          });
          it("should update the hitSDThreshold ", function() {
            this.psapc.$('.bv_hitSDThreshold').val(' 24 ');
            this.psapc.$('.bv_hitSDThreshold').change();
            return expect(this.psapc.model.get('hitSDThreshold')).toEqual(24);
          });
          it("should update the hitEfficacyThreshold ", function() {
            this.psapc.$('.bv_hitEfficacyThreshold').val(' 25 ');
            this.psapc.$('.bv_hitEfficacyThreshold').change();
            return expect(this.psapc.model.get('hitEfficacyThreshold')).toEqual(25);
          });
          it("should update the positiveControl ", function() {
            this.psapc.$('.bv_positiveControlBatch').val(' pos cont ');
            this.psapc.$('.bv_positiveControlBatch').change();
            return expect(this.psapc.model.get('positiveControl').get('batchCode')).toEqual("pos cont");
          });
          it("should update the positiveControl conc ", function() {
            this.psapc.$('.bv_positiveControlConc').val(' 61 ');
            this.psapc.$('.bv_positiveControlConc').change();
            return expect(this.psapc.model.get('positiveControl').get('concentration')).toEqual(61);
          });
          it("should update the negativeControl ", function() {
            this.psapc.$('.bv_negativeControlBatch').val(' neg cont ');
            this.psapc.$('.bv_negativeControlBatch').change();
            return expect(this.psapc.model.get('negativeControl').get('batchCode')).toEqual("neg cont");
          });
          it("should update the negativeControl conc ", function() {
            this.psapc.$('.bv_negativeControlConc').val(' 62 ');
            this.psapc.$('.bv_negativeControlConc').change();
            return expect(this.psapc.model.get('negativeControl').get('concentration')).toEqual(62);
          });
          it("should update the vehicleControl ", function() {
            this.psapc.$('.bv_vehicleControlBatch').val(' veh cont ');
            this.psapc.$('.bv_vehicleControlBatch').change();
            return expect(this.psapc.model.get('vehicleControl').get('batchCode')).toEqual("veh cont");
          });
          it("should update the agonistControl", function() {
            this.psapc.$('.bv_agonistControlBatch').val(' ag cont ');
            this.psapc.$('.bv_agonistControlBatch').change();
            return expect(this.psapc.model.get('agonistControl').get('batchCode')).toEqual("ag cont");
          });
          it("should update the agonistControl conc", function() {
            this.psapc.$('bv_agonistControlConc').val(' 2 ');
            this.psapc.$('.bv_agonistControlConc').change();
            return expect(this.psapc.model.get('agonistControl').get('concentration')).toEqual(2);
          });
          return it("should update the thresholdType ", function() {
            this.psapc.$('.bv_thresholdTypeEfficacy').click();
            return expect(this.psapc.model.get('thresholdType')).toEqual("efficacy");
          });
        });
        return describe("behavior and validation", function() {
          it("should disable sd threshold field if that radio not selected", function() {
            this.psapc.$('.bv_thresholdTypeEfficacy').click();
            expect(this.psapc.$('.bv_hitSDThreshold').attr("disabled")).toEqual("disabled");
            return expect(this.psapc.$('.bv_hitEfficacyThreshold').attr("disabled")).toBeUndefined();
          });
          return it("should disable efficacy threshold field if that radio not selected", function() {
            this.psapc.$('.bv_thresholdTypeEfficacy').click();
            this.psapc.$('.bv_thresholdTypeSD').click();
            expect(this.psapc.$('.bv_hitEfficacyThreshold').attr("disabled")).toEqual("disabled");
            return expect(this.psapc.$('.bv_hitSDThreshold').attr("disabled")).toBeUndefined();
          });
        });
      });
      return describe("valiation testing", function() {
        beforeEach(function() {
          this.psapc = new PrimaryScreenExperimentController({
            model: new PrimaryScreenExperiment(window.experimentServiceTestJSON.fullExperimentFromServer),
            el: $('#fixture')
          });
          return this.psapc.render();
        });
        return describe("error notification", function() {
          it("should show error if positiveControl batch is not set", function() {
            this.psapc.$('.bv_positiveControlBatch').val("");
            this.psapc.$('.bv_positiveControlBatch').change();
            return expect(this.psapc.$('.bv_group_positiveControlBatch').hasClass("error")).toBeTruthy();
          });
          it("should show error if positiveControl conc is not set", function() {
            this.psapc.$('.bv_positiveControlConc').val("");
            this.psapc.$('.bv_positiveControlConc').change();
            return expect(this.psapc.$('.bv_group_positiveControlConc').hasClass("error")).toBeTruthy();
          });
          it("should show error if negativeControl batch is not set", function() {
            this.psapc.$('.bv_negativeControlBatch').val("");
            this.psapc.$('.bv_negativeControlBatch').change();
            return expect(this.psapc.$('.bv_group_negativeControlBatch').hasClass("error")).toBeTruthy();
          });
          it("should show error if negativeControl conc is not set", function() {
            this.psapc.$('.bv_negativeControlConc').val("");
            this.psapc.$('.bv_negativeControlConc').change();
            return expect(this.psapc.$('.bv_group_negativeControlConc').hasClass("error")).toBeTruthy();
          });
          it("should show error if agonistControl batch is not set", function() {
            this.psapc.$('.bv_agonistControlBatch').val("");
            this.psapc.$('.bv_agonistControlBatch').change();
            return expect(this.psapc.$('.bv_group_agonistControlBatch').hasClass("error")).toBeTruthy();
          });
          it("should show error if agonistControl conc is not set", function() {
            this.psapc.$('.bv_agonistControlConc').val("");
            this.psapc.$('.bv_agonistControlConc').change();
            return expect(this.psapc.$('.bv_group_agonistControlConc').hasClass("error")).toBeTruthy();
          });
          it("should show error if vehicleControl is not set", function() {
            this.psapc.$('.bv_vehicleControlBatch').val("");
            this.psapc.$('.bv_vehicleControlBatch').change();
            return expect(this.psapc.$('.bv_group_vehicleControlBatch').hasClass("error")).toBeTruthy();
          });
          it("should show error if transformationRule is unassigned", function() {
            this.psapc.$('.bv_transformationRule').val("unassigned");
            this.psapc.$('.bv_transformationRule').change();
            return expect(this.psapc.$('.bv_group_transformationRule').hasClass("error")).toBeTruthy();
          });
          it("should show error if normalizationRule is unassigned", function() {
            this.psapc.$('.bv_normalizationRule').val("unassigned");
            this.psapc.$('.bv_normalizationRule').change();
            return expect(this.psapc.$('.bv_group_normalizationRule').hasClass("error")).toBeTruthy();
          });
          it("should show error if threshold type is efficacy and efficacy threshold not a number", function() {
            this.psapc.$('.bv_thresholdTypeEfficacy').click();
            this.psapc.$('.bv_hitEfficacyThreshold').val("");
            this.psapc.$('.bv_hitEfficacyThreshold').change();
            return expect(this.psapc.$('.bv_group_hitEfficacyThreshold').hasClass("error")).toBeTruthy();
          });
          return it("should show error if threshold type is sd and sd threshold not a number", function() {
            this.psapc.$('.bv_sdTypeEfficacy').click();
            this.psapc.$('.bv_hitSDThreshold').val("");
            this.psapc.$('.bv_hitSDThreshold').change();
            return expect(this.psapc.$('.bv_group_hitSDThreshold').hasClass("error")).toBeTruthy();
          });
        });
      });
    });
    describe("Upload and Run Primary Analysis Controller testing", function() {
      beforeEach(function() {
        this.exp = new PrimaryScreenExperiment();
        this.uarpac = new UploadAndRunPrimaryAnalsysisController({
          el: $('#fixture'),
          paramsFromExperiment: this.exp.getAnalysisParameters()
        });
        return this.uarpac.render();
      });
      return describe("Basic loading", function() {
        it("Class should exist", function() {
          return expect(this.uarpac).toBeDefined();
        });
        return it("Should load the template", function() {
          return expect(this.uarpac.$('.bv_parseFile').length).toNotEqual(0);
        });
      });
    });
    describe("Primary Screen Analysis Controller testing", function() {
      describe("basic plumbing checks with experiment copied from template", function() {
        beforeEach(function() {
          this.exp = new PrimaryScreenExperiment();
          this.exp.copyProtocolAttributes(new Protocol(window.protocolServiceTestJSON.fullSavedProtocol));
          this.psac = new PrimaryScreenAnalysisController({
            model: this.exp,
            el: $('#fixture')
          });
          return this.psac.render();
        });
        describe("Basic loading", function() {
          it("Class should exist", function() {
            return expect(this.psac).toBeDefined;
          });
          return it("Should load the template", function() {
            return expect(this.psac.$('.bv_analysisStatus').length).toNotEqual(0);
          });
        });
        return describe("display logic", function() {
          it("should show analysis status not started becuase this is a new experiment", function() {
            return expect(this.psac.$('.bv_analysisStatus').html()).toEqual("not started");
          });
          it("should not show analysis results becuase this is a new experiment", function() {
            expect(this.psac.$('.bv_analysisResultsHTML').html()).toEqual("");
            return expect(this.psac.$('.bv_resultsContainer')).toBeHidden();
          });
          it("should be able to hide data analysis controller", function() {
            this.psac.setExperimentNotSaved();
            expect(this.psac.$('.bv_fileUploadWrapper')).toBeHidden();
            return expect(this.psac.$('.bv_saveExperimentToAnalyze')).toBeVisible();
          });
          return it("should be able to show data analysis controller", function() {
            this.psac.setExperimentSaved();
            expect(this.psac.$('.bv_fileUploadWrapper')).toBeVisible();
            return expect(this.psac.$('.bv_saveExperimentToAnalyze')).toBeHidden();
          });
        });
      });
      describe("experiment status locks analysis", function() {
        beforeEach(function() {
          this.exp = new PrimaryScreenExperiment(window.experimentServiceTestJSON.fullExperimentFromServer);
          this.psac = new PrimaryScreenAnalysisController({
            model: this.exp,
            el: $('#fixture')
          });
          return this.psac.render();
        });
        it("Should disable analsyis parameter editing if status is Finalized", function() {
          this.psac.model.getStatus().set({
            stringValue: "Finalized"
          });
          return expect(this.psac.$('.bv_normalizationRule').attr('disabled')).toEqual('disabled');
        });
        it("Should enable analsyis parameter editing if status is Finalized", function() {
          this.psac.model.getStatus().set({
            stringValue: "Finalized"
          });
          this.psac.model.getStatus().set({
            stringValue: "Started"
          });
          return expect(this.psac.$('.bv_normalizationRule').attr('disabled')).toBeUndefined();
        });
        return it("should show upload button as upload data since status is 'not started'", function() {
          return expect(this.psac.$('.bv_save').html()).toEqual("Upload Data");
        });
      });
      return describe("handling re-analysis", function() {
        beforeEach(function() {
          this.exp = new PrimaryScreenExperiment(window.experimentServiceTestJSON.fullExperimentFromServer);
          this.exp.getAnalysisStatus().set({
            stringValue: "analsysis complete"
          });
          this.psac = new PrimaryScreenAnalysisController({
            model: this.exp,
            el: $('#fixture')
          });
          return this.psac.render();
        });
        return it("should show upload button as re-analyze since status is not 'not started'", function() {
          return expect(this.psac.$('.bv_save').html()).toEqual("Re-Analyze");
        });
      });
    });
    return describe("Primary Screen Experiment Controller testing", function() {
      return describe("basic plumbing checks with new experiment", function() {
        beforeEach(function() {
          this.psec = new PrimaryScreenExperimentController({
            model: new PrimaryScreenExperiment(),
            el: $('#fixture')
          });
          return this.psec.render();
        });
        return describe("Basic loading", function() {
          it("Class should exist", function() {
            return expect(this.psec).toBeDefined();
          });
          it("Should load the template", function() {
            return expect(this.psec.$('.bv_experimentBase').length).toNotEqual(0);
          });
          it("Should load a base experiment controller", function() {
            return expect(this.psec.$('.bv_experimentBase .bv_experimentName').length).toNotEqual(0);
          });
          it("Should load an analysis controller", function() {
            return expect(this.psec.$('.bv_primaryScreenDataAnalysis .bv_analysisStatus').length).toNotEqual(0);
          });
          return xit("Should load a dose response controller", function() {
            return expect(this.psec.$('.bv_doseResponseAnalysis .bv_fixCurveMin').length).toNotEqual(0);
          });
        });
      });
    });
  });

}).call(this);
