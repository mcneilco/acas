(function() {
  beforeEach(function() {
    return this.fixture = $.clone($("#fixture").get(0));
  });

  afterEach(function() {
    $("#fixture").remove();
    return $("body").append($(this.fixture));
  });

  describe("Primary Screen Experiment module testing", function() {
    describe("Primary Analysis Read model testing", function() {
      describe("When loaded from new", function() {
        beforeEach(function() {
          return this.par = new PrimaryAnalysisRead();
        });
        return describe("Existence and Defaults", function() {
          it("should be defined", function() {
            return expect(this.par).toBeDefined();
          });
          return it("should have defaults", function() {
            expect(this.par.get('readPosition')).toBeNull();
            expect(this.par.get('readName')).toEqual("unassigned");
            return expect(this.par.get('activity')).toBeFalsy();
          });
        });
      });
      return describe("model validation tests", function() {
        beforeEach(function() {
          return this.par = new PrimaryAnalysisRead(window.primaryScreenTestJSON.primaryAnalysisReads[0]);
        });
        it("should be valid as initialized", function() {
          return expect(this.par.isValid()).toBeTruthy();
        });
        it("should be invalid when read position is NaN", function() {
          var filtErrors;
          this.par.set({
            readPosition: NaN
          });
          expect(this.par.isValid()).toBeFalsy();
          filtErrors = _.filter(this.par.validationError, function(err) {
            return err.attribute === 'readPosition';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        return it("should be invalid when read name is unassigned", function() {
          var filtErrors;
          this.par.set({
            readName: "unassigned"
          });
          expect(this.par.isValid()).toBeFalsy();
          filtErrors = _.filter(this.par.validationError, function(err) {
            return err.attribute === 'readName';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
      });
    });
    describe("Transformation Rule Model testing", function() {
      describe("When loaded from new", function() {
        beforeEach(function() {
          return this.tr = new TransformationRule();
        });
        return describe("Existence and Defaults", function() {
          it("should be defined", function() {
            return expect(this.tr).toBeDefined();
          });
          return it("should have defaults", function() {
            return expect(this.tr.get('transformationRule')).toEqual("unassigned");
          });
        });
      });
      return describe("model validation tests", function() {
        beforeEach(function() {
          return this.tr = new TransformationRule(window.primaryScreenTestJSON.transformationRules[0]);
        });
        it("should be valid as initialized", function() {
          return expect(this.tr.isValid()).toBeTruthy();
        });
        return it("should be invalid when transformation rule is unassigned", function() {
          var filtErrors;
          this.tr.set({
            transformationRule: "unassigned"
          });
          expect(this.tr.isValid()).toBeFalsy();
          filtErrors = _.filter(this.tr.validationError, function(err) {
            return err.attribute === 'transformationRule';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
      });
    });
    describe("Primary Analysis Read List testing", function() {
      describe("When loaded from new", function() {
        beforeEach(function() {
          return this.parl = new PrimaryAnalysisReadList();
        });
        return describe("Existence", function() {
          return it("should be defined", function() {
            return expect(this.parl).toBeDefined();
          });
        });
      });
      return describe("When loaded form existing", function() {
        beforeEach(function() {
          return this.parl = new PrimaryAnalysisReadList(window.primaryScreenTestJSON.primaryAnalysisReads);
        });
        it("should have three reads", function() {
          return expect(this.parl.length).toEqual(3);
        });
        it("should have the correct read info for the first read", function() {
          var readtwo;
          readtwo = this.parl.at(0);
          expect(readtwo.get('readPosition')).toEqual(11);
          expect(readtwo.get('readName')).toEqual("none");
          return expect(readtwo.get('activity')).toBeTruthy();
        });
        it("should have the correct read info for the second read", function() {
          var readtwo;
          readtwo = this.parl.at(1);
          expect(readtwo.get('readPosition')).toEqual(12);
          expect(readtwo.get('readName')).toEqual("fluorescence");
          return expect(readtwo.get('activity')).toBeFalsy();
        });
        return it("should have the correct read info for the third read", function() {
          var readthree;
          readthree = this.parl.at(2);
          expect(readthree.get('readPosition')).toEqual(13);
          expect(readthree.get('readName')).toEqual("luminescence");
          return expect(readthree.get('activity')).toBeFalsy();
        });
      });
    });
    describe("Transformation Rule List testing", function() {
      describe("When loaded from new", function() {
        beforeEach(function() {
          return this.trl = new TransformationRuleList();
        });
        return describe("Existence", function() {
          return it("should be defined", function() {
            return expect(this.trl).toBeDefined();
          });
        });
      });
      describe("When loaded form existing", function() {
        beforeEach(function() {
          return this.trl = new TransformationRuleList(window.primaryScreenTestJSON.transformationRules);
        });
        it("should have three reads", function() {
          return expect(this.trl.length).toEqual(3);
        });
        it("should have the correct rule info for the first rule", function() {
          var ruleone;
          ruleone = this.trl.at(0);
          return expect(ruleone.get('transformationRule')).toEqual("% efficacy");
        });
        it("should have the correct read info for the second rule", function() {
          var ruletwo;
          ruletwo = this.trl.at(1);
          return expect(ruletwo.get('transformationRule')).toEqual("sd");
        });
        return it("should have the correct read info for the third read", function() {
          var rulethree;
          rulethree = this.trl.at(2);
          return expect(rulethree.get('transformationRule')).toEqual("null");
        });
      });
      return describe("collection validation", function() {
        beforeEach(function() {
          return this.trl = new TransformationRuleList(window.primaryScreenTestJSON.transformationRules);
        });
        return it("should be invalid if a transformation rule is selected more than once", function() {
          this.trl.at(0).set({
            transformationRule: "sd"
          });
          this.trl.at(1).set({
            transformationRule: "sd"
          });
          return expect((this.trl.validateCollection()).length).toBeGreaterThan(0);
        });
      });
    });
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
            expect(this.psap.get('assayVolume')).toBeNull();
            expect(this.psap.get('transferVolume')).toBeNull();
            expect(this.psap.get('dilutionFactor')).toBeNull();
            expect(this.psap.get('volumeType')).toEqual("dilution");
            expect(this.psap.get('instrumentReader')).toEqual("unassigned");
            expect(this.psap.get('signalDirectionRule')).toEqual("unassigned");
            expect(this.psap.get('aggregateBy1')).toEqual("unassigned");
            expect(this.psap.get('aggregateBy2')).toEqual("unassigned");
            expect(this.psap.get('normalizationRule')).toEqual("unassigned");
            expect(this.psap.get('hitEfficacyThreshold')).toBeNull();
            expect(this.psap.get('hitSDThreshold')).toBeNull();
            expect(this.psap.get('positiveControl') instanceof Backbone.Model).toBeTruthy();
            expect(this.psap.get('negativeControl') instanceof Backbone.Model).toBeTruthy();
            expect(this.psap.get('vehicleControl') instanceof Backbone.Model).toBeTruthy();
            expect(this.psap.get('agonistControl') instanceof Backbone.Model).toBeTruthy();
            expect(this.psap.get('thresholdType')).toEqual("sd");
            expect(this.psap.get('autoHitSelection')).toBeFalsy();
            expect(this.psap.get('htsFormat')).toBeFalsy();
            expect(this.psap.get('matchReadName')).toBeTruthy();
            expect(this.psap.get('primaryAnalysisReadList') instanceof PrimaryAnalysisReadList).toBeTruthy();
            return expect(this.psap.get('transformationRuleList') instanceof TransformationRuleList).toBeTruthy();
          });
        });
      });
      return describe("When loaded form existing", function() {
        beforeEach(function() {
          return this.psap = new PrimaryScreenAnalysisParameters(window.primaryScreenTestJSON.primaryScreenAnalysisParameters);
        });
        describe("composite object creation", function() {
          it("should convert readlist to PrimaryAnalysisReadList", function() {
            return expect(this.psap.get('primaryAnalysisReadList') instanceof PrimaryAnalysisReadList).toBeTruthy();
          });
          return it("should convert transformationRuleList to TransformationRuleList", function() {
            return expect(this.psap.get('transformationRuleList') instanceof TransformationRuleList).toBeTruthy();
          });
        });
        describe("model validation tests", function() {
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
          it("should be valid when agonist control batch and conc are both empty", function() {
            this.psap.get('agonistControl').set({
              batchCode: "",
              concentration: ""
            });
            return expect(this.psap.validate(this.psap.attributes)).toEqual(null);
          });
          it("should be valid when agonist control batch is entered and agonist control conc is a number ", function() {
            var filtErrors;
            this.psap.get('agonistControl').set({
              batchCode: "CMPD-87654399-01",
              concentration: 12
            });
            expect(this.psap.isValid()).toBeTruthy();
            filtErrors = _.filter(this.psap.validationError, function(err) {
              err.attribute === 'agonistControlConc';
              return err.attribute === 'agonistControlBatch';
            });
            return expect(filtErrors.length).toEqual(0);
          });
          it("should be invalid when agonist control batch is entered and agonist control conc is NaN", function() {
            var filtErrors;
            this.psap.get('agonistControl').set({
              batchCode: "CMPD-87654399-01",
              concentration: NaN
            });
            expect(this.psap.isValid()).toBeFalsy();
            filtErrors = _.filter(this.psap.validationError, function(err) {
              return err.attribute === 'agonistControlConc';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
          it("should be invalid when agonist control batch is empty and agonist control conc is a number ", function() {
            var filtErrors;
            this.psap.get('agonistControl').set({
              batchCode: "",
              concentration: 13
            });
            expect(this.psap.isValid()).toBeFalsy();
            filtErrors = _.filter(this.psap.validationError, function(err) {
              return err.attribute === 'agonistControlBatch';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
          it("should be valid when vehicle control is empty", function() {
            var filtErrors;
            this.psap.get('vehicleControl').set({
              batchCode: ""
            });
            expect(this.psap.isValid()).toBeTruthy();
            filtErrors = _.filter(this.psap.validationError, function(err) {
              return err.attribute === 'vehicleControlBatch';
            });
            return expect(filtErrors.length).toEqual(0);
          });
          it("should be invalid when assayVolume is NaN (but can be empty)", function() {
            var filtErrors;
            this.psap.set({
              assayVolume: NaN
            });
            expect(this.psap.isValid()).toBeFalsy();
            filtErrors = _.filter(this.psap.validationError, function(err) {
              return err.attribute === 'assayVolume';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
          it("should be invalid when assayVolume is not set but transfer volume is set", function() {
            var filtErrors;
            this.psap.set({
              assayVolume: ""
            });
            this.psap.set({
              dilutionFactor: ""
            });
            this.psap.set({
              transferVolume: 40
            });
            expect(this.psap.isValid()).toBeFalsy();
            filtErrors = _.filter(this.psap.validationError, function(err) {
              return err.attribute === 'assayVolume';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
          it("should be valid when assayVolume, transfer volume, and dilution factors are empty", function() {
            var filtErrors;
            this.psap.set({
              assayVolume: ""
            });
            this.psap.set({
              transferVolume: ""
            });
            this.psap.set({
              dilutionFactor: ""
            });
            expect(this.psap.isValid()).toBeTruthy();
            filtErrors = _.filter(this.psap.validationError, function(err) {
              return err.attribute === 'assayVolume';
            });
            return expect(filtErrors.length).toEqual(0);
          });
          it("should be valid when instrument reader is unassigned", function() {
            var filtErrors;
            this.psap.set({
              instrumentReader: "unassigned"
            });
            expect(this.psap.isValid()).toBeTruthy();
            filtErrors = _.filter(this.psap.validationError, function(err) {
              return err.attribute === 'instrumentReader';
            });
            return expect(filtErrors.length).toEqual(0);
          });
          it("should be invalid when aggregate by1 is unassigned", function() {
            var filtErrors;
            this.psap.set({
              aggregateBy1: "unassigned"
            });
            expect(this.psap.isValid()).toBeFalsy();
            filtErrors = _.filter(this.psap.validationError, function(err) {
              return err.attribute === 'aggregateBy1';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
          it("should be invalid when aggregate by2 is unassigned", function() {
            var filtErrors;
            this.psap.set({
              aggregateBy2: "unassigned"
            });
            expect(this.psap.isValid()).toBeFalsy();
            filtErrors = _.filter(this.psap.validationError, function(err) {
              return err.attribute === 'aggregateBy2';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
          it("should be invalid when signal direction rule is unassigned", function() {
            var filtErrors;
            this.psap.set({
              signalDirectionRule: "unassigned"
            });
            expect(this.psap.isValid()).toBeFalsy();
            filtErrors = _.filter(this.psap.validationError, function(err) {
              return err.attribute === 'signalDirectionRule';
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
          it("should be invalid when volumeType is dilution and dilutionFactor is not a number (but can be empty)", function() {
            var filtErrors;
            this.psap.set({
              volumeType: "dilution"
            });
            this.psap.set({
              dilutionFactor: NaN
            });
            expect(this.psap.isValid()).toBeFalsy();
            filtErrors = _.filter(this.psap.validationError, function(err) {
              return err.attribute === 'dilutionFactor';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
          it("should be valid when volumeType is dilution and dilutionFactor is empty", function() {
            var filtErrors;
            this.psap.set({
              volumeType: "dilution"
            });
            this.psap.set({
              dilutionFactor: ""
            });
            expect(this.psap.isValid()).toBeTruthy();
            filtErrors = _.filter(this.psap.validationError, function(err) {
              return err.attribute === 'dilutionFactor';
            });
            return expect(filtErrors.length).toEqual(0);
          });
          it("should be invalid when volumeType is transfer and transferVolume is not a number (but can be empty)", function() {
            var filtErrors;
            this.psap.set({
              volumeType: "transfer"
            });
            this.psap.set({
              transferVolume: NaN
            });
            expect(this.psap.isValid()).toBeFalsy();
            filtErrors = _.filter(this.psap.validationError, function(err) {
              return err.attribute === 'transferVolume';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
          it("should be valid when volumeType is transfer and transferVolume is empty", function() {
            var filtErrors;
            this.psap.set({
              volumeType: "transfer"
            });
            this.psap.set({
              transferVolume: ""
            });
            expect(this.psap.isValid()).toBeTruthy();
            filtErrors = _.filter(this.psap.validationError, function(err) {
              return err.attribute === 'transferVolume';
            });
            return expect(filtErrors.length).toEqual(0);
          });
          it("should be invalid when autoHitSelection is checked and thresholdType is sd and hitSDThreshold is not a number", function() {
            var filtErrors;
            this.psap.set({
              autoHitSelection: true
            });
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
          return it("should be invalid when autoHitSelection is checked and thresholdType is efficacy and hitEfficacyThreshold is not a number", function() {
            var filtErrors;
            this.psap.set({
              autoHitSelection: true
            });
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
        return describe("autocalculating volumes", function() {
          it("should autocalculate the dilution factor from the transfer volume and assay volume", function() {
            this.psap.set({
              volumeType: "transfer"
            });
            this.psap.set({
              transferVolume: 12
            });
            this.psap.set({
              assayVolume: 36
            });
            return expect(this.psap.autocalculateVolumes()).toEqual(36 / 12);
          });
          it("should autocalculate the transfer volume from the dilution factor and assay volume", function() {
            this.psap.set({
              volumeType: "dilution"
            });
            this.psap.set({
              dilutionFactor: 4
            });
            this.psap.set({
              assayVolume: 36
            });
            return expect(this.psap.autocalculateVolumes()).toEqual(36 / 4);
          });
          it("should not autocalculate the dilution factor if transfer volume is NaN", function() {
            this.psap.set({
              volumeType: "transfer"
            });
            this.psap.set({
              transferVolume: NaN
            });
            this.psap.set({
              assayVolume: 36
            });
            return expect(this.psap.autocalculateVolumes()).toEqual("");
          });
          it("should not autocalculate the dilution factor if assay volume is NaN", function() {
            this.psap.set({
              volumeType: "transfer"
            });
            this.psap.set({
              transferVolume: 14
            });
            this.psap.set({
              assayVolume: NaN
            });
            return expect(this.psap.autocalculateVolumes()).toEqual("");
          });
          it("should not autocalculate the transfer volume if the dilution factor is NaN", function() {
            this.psap.set({
              volumeType: "dilution"
            });
            this.psap.set({
              dilutionFactor: NaN
            });
            this.psap.set({
              assayVolume: 36
            });
            return expect(this.psap.autocalculateVolumes()).toEqual("");
          });
          it("should not autocalculate the dilution factor if the transfer volume is 0", function() {
            this.psap.set({
              volumeType: "transfer"
            });
            this.psap.set({
              transferVolume: 0
            });
            this.psap.set({
              assayVolume: 123
            });
            return expect(this.psap.autocalculateVolumes()).toEqual("");
          });
          return it("should not autocalculate the transfer volume if the dilution factor is 0", function() {
            this.psap.set({
              volumeType: "dilution"
            });
            this.psap.set({
              dilutionFactor: 0
            });
            this.psap.set({
              assayVolume: 123
            });
            return expect(this.psap.autocalculateVolumes()).toEqual("");
          });
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
              expect(this.pse.getAnalysisParameters().get('hitSDThreshold')).toEqual(5);
              return expect(this.pse.getAnalysisParameters().get('dilutionFactor')).toEqual(21);
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
          describe("model fit parameters", function() {
            return it('Should be able to get model parameters', function() {
              return expect(this.pse.getModelFitParameters().inverseAgonistMode).toBeTruthy();
            });
          });
          return describe("special states", function() {
            it("should be able to get the analysis status", function() {
              return expect(this.pse.getAnalysisStatus().get('stringValue')).toEqual("not started");
            });
            it("should be able to get the analysis result html", function() {
              return expect(this.pse.getAnalysisResultHTML().get('clobValue')).toEqual("<p>Analysis not yet completed</p>");
            });
            it("should be able to get the model fit status", function() {
              return expect(this.pse.getModelFitStatus().get('stringValue')).toEqual("not started");
            });
            return it("should be able to get the model result html", function() {
              return expect(this.pse.getModelFitResultHTML().get('clobValue')).toEqual("<p>Model fit not yet completed</p>");
            });
          });
        });
      });
      return describe("When loaded from new", function() {
        beforeEach(function() {
          return this.pse2 = new PrimaryScreenExperiment();
        });
        describe("defaults", function() {
          return it("should have lsKind set to flipr screening assay", function() {
            return expect(this.pse2.get('lsKind')).toEqual("flipr screening assay");
          });
        });
        return describe("special states", function() {
          it("should be able to get the analysis status", function() {
            return expect(this.pse2.getAnalysisStatus().get('stringValue')).toEqual("not started");
          });
          it("should be able to get the analysis result html", function() {
            return expect(this.pse2.getAnalysisResultHTML().get('clobValue')).toEqual("");
          });
          it("should be able to get the model fit status", function() {
            return expect(this.pse2.getModelFitStatus().get('stringValue')).toEqual("not started");
          });
          return it("should be able to get the model result html", function() {
            return expect(this.pse2.getModelFitResultHTML().get('clobValue')).toEqual("");
          });
        });
      });
    });
    describe("PrimaryAnalysisReadController", function() {
      describe("when instantiated", function() {
        beforeEach(function() {
          this.parc = new PrimaryAnalysisReadController({
            model: new PrimaryAnalysisRead(window.primaryScreenTestJSON.primaryAnalysisReads[0]),
            el: $('#fixture')
          });
          return this.parc.render();
        });
        describe("basic existance tests", function() {
          it("should exist", function() {
            return expect(this.parc).toBeDefined();
          });
          return it("should load a template", function() {
            return expect(this.parc.$('.bv_readName').length).toEqual(1);
          });
        });
        describe("render existing parameters", function() {
          it("should show read position", function() {
            return expect(this.parc.$('.bv_readPosition').val()).toEqual("11");
          });
          it("should show read name", function() {
            waitsFor(function() {
              return this.parc.$('.bv_readName option').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.parc.$('.bv_readName').val()).toEqual("none");
            });
          });
          return it("should have activity checked", function() {
            return expect(this.parc.$('.bv_activity').attr("checked")).toEqual("checked");
          });
        });
        return describe("model updates", function() {
          it("should update the readPosition ", function() {
            this.parc.$('.bv_readPosition').val('42');
            this.parc.$('.bv_readPosition').change();
            return expect(this.parc.model.get('readPosition')).toEqual(42);
          });
          return it("should update the read name", function() {
            waitsFor(function() {
              return this.parc.$('.bv_readName option').length > 0;
            }, 1000);
            return runs(function() {
              this.parc.$('.bv_readName').val('unassigned');
              this.parc.$('.bv_readName').change();
              return expect(this.parc.model.get('readName')).toEqual("unassigned");
            });
          });
        });
      });
      return describe("validation testing", function() {
        return beforeEach(function() {
          this.parc = new PrimaryAnalysisReadController({
            model: new PrimaryAnalysisRead(window.primaryScreenTestJSON.primaryAnalysisReads),
            el: $('#fixture')
          });
          return this.parc.render();
        });
      });
    });
    describe("TransformationRuleController", function() {
      return describe("when instantiated", function() {
        beforeEach(function() {
          this.trc = new TransformationRuleController({
            model: new TransformationRule(window.primaryScreenTestJSON.transformationRules[0]),
            el: $('#fixture')
          });
          return this.trc.render();
        });
        describe("basic existance tests", function() {
          it("should exist", function() {
            return expect(this.trc).toBeDefined();
          });
          return it("should load a template", function() {
            return expect(this.trc.$('.bv_transformationRule').length).toEqual(1);
          });
        });
        describe("render existing parameters", function() {
          return it("should show transformation rule", function() {
            waitsFor(function() {
              return this.trc.$('.bv_transformationRule option').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.trc.$('.bv_transformationRule').val()).toEqual("% efficacy");
            });
          });
        });
        return describe("model updates", function() {
          return it("should update the transformation rule", function() {
            waitsFor(function() {
              return this.trc.$('.bv_transformationRule option').length > 0;
            }, 1000);
            return runs(function() {
              this.trc.$('.bv_transformationRule').val('sd');
              this.trc.$('.bv_transformationRule').change();
              return expect(this.trc.model.get('transformationRule')).toEqual("sd");
            });
          });
        });
      });
    });
    describe("Primary Analysis Read List Controller testing", function() {
      describe("when instantiated with no data", function() {
        beforeEach(function() {
          this.parlc = new PrimaryAnalysisReadListController({
            el: $('#fixture'),
            collection: new PrimaryAnalysisReadList()
          });
          return this.parlc.render();
        });
        describe("basic existence tests", function() {
          it("should exist", function() {
            return expect(this.parlc).toBeDefined();
          });
          return it("should load a template", function() {
            return expect(this.parlc.$('.bv_addReadButton').length).toEqual(1);
          });
        });
        describe("rendering", function() {
          return it("should show one read with the activity selected", function() {
            expect(this.parlc.$('.bv_readInfo .bv_readName').length).toEqual(1);
            return expect(this.parlc.collection.length).toEqual(1);
          });
        });
        return describe("adding and removing", function() {
          it("should have two reads when add read is clicked", function() {
            this.parlc.$('.bv_addReadButton').click();
            expect(this.parlc.$('.bv_readInfo .bv_readName').length).toEqual(2);
            return expect(this.parlc.collection.length).toEqual(2);
          });
          it("should have no reads when there is one read and remove is clicked", function() {
            expect(this.parlc.collection.length).toEqual(1);
            this.parlc.$('.bv_delete').click();
            expect(this.parlc.$('.bv_readInfo .bv_readName').length).toEqual(0);
            return expect(this.parlc.collection.length).toEqual(0);
          });
          return it("should have one read when there are two reads and remove is clicked", function() {
            this.parlc.$('.bv_addReadButton').click();
            expect(this.parlc.$('.bv_readInfo .bv_readName').length).toEqual(2);
            this.parlc.$('.bv_delete:eq(0)').click();
            expect(this.parlc.$('.bv_readInfo .bv_readName').length).toEqual(1);
            return expect(this.parlc.collection.length).toEqual(1);
          });
        });
      });
      return describe("when instantiated with data", function() {
        beforeEach(function() {
          this.parlc = new PrimaryAnalysisReadListController({
            el: $('#fixture'),
            collection: new PrimaryAnalysisReadList(window.primaryScreenTestJSON.primaryAnalysisReads)
          });
          return this.parlc.render();
        });
        it("should have three reads", function() {
          return expect(this.parlc.collection.length).toEqual(3);
        });
        it("should have the correct read info for the first read", function() {
          waitsFor(function() {
            return this.parlc.$('.bv_readName option').length > 0;
          }, 1000);
          return runs(function() {
            expect(this.parlc.$('.bv_readPosition:eq(0)').val()).toEqual("11");
            expect(this.parlc.$('.bv_readName:eq(0)').val()).toEqual("none");
            return expect(this.parlc.$('.bv_activity:eq(0)').attr("checked")).toEqual("checked");
          });
        });
        it("should have the correct read info for the second read", function() {
          waitsFor(function() {
            return this.parlc.$('.bv_readName option').length > 0;
          }, 1000);
          return runs(function() {
            expect(this.parlc.$('.bv_readPosition:eq(1)').val()).toEqual("12");
            expect(this.parlc.$('.bv_readName:eq(1)').val()).toEqual("fluorescence");
            return expect(this.parlc.$('.bv_activity:eq(1)').attr("checked")).toBeUndefined();
          });
        });
        return it("should have the correct read info for the third read", function() {
          waitsFor(function() {
            return this.parlc.$('.bv_readName option').length > 0;
          }, 1000);
          return runs(function() {
            expect(this.parlc.$('.bv_readPosition:eq(2)').val()).toEqual("13");
            expect(this.parlc.$('.bv_readName:eq(2)').val()).toEqual("luminescence");
            return expect(this.parlc.$('.bv_activity:eq(2)').attr("checked")).toBeUndefined();
          });
        });
      });
    });
    describe("Transformation Rule List Controller testing", function() {
      describe("when instantiated with no data", function() {
        beforeEach(function() {
          this.trlc = new TransformationRuleListController({
            el: $('#fixture'),
            collection: new TransformationRuleList()
          });
          return this.trlc.render();
        });
        describe("basic existence tests", function() {
          it("should exist", function() {
            return expect(this.trlc).toBeDefined();
          });
          return it("should load a template", function() {
            return expect(this.trlc.$('.bv_addTransformationButton').length).toEqual(1);
          });
        });
        describe("rendering", function() {
          return it("should show one rule", function() {
            expect(this.trlc.$('.bv_transformationInfo .bv_transformationRule').length).toEqual(1);
            return expect(this.trlc.collection.length).toEqual(1);
          });
        });
        return describe("adding and removing", function() {
          it("should have two rules when add transformation button is clicked", function() {
            this.trlc.$('.bv_addTransformationButton').click();
            expect(this.trlc.$('.bv_transformationInfo .bv_transformationRule').length).toEqual(2);
            return expect(this.trlc.collection.length).toEqual(2);
          });
          it("should have one rule when there are two rules and remove is clicked", function() {
            this.trlc.$('.bv_addTransformationButton').click();
            expect(this.trlc.$('.bv_transformationInfo .bv_transformationRule').length).toEqual(2);
            this.trlc.$('.bv_deleteRule:eq(0)').click();
            expect(this.trlc.$('.bv_transformationInfo .bv_transformationRule').length).toEqual(1);
            return expect(this.trlc.collection.length).toEqual(1);
          });
          return it("should always have one read", function() {
            expect(this.trlc.collection.length).toEqual(1);
            this.trlc.$('.bv_deleteRule').click();
            expect(this.trlc.$('.bv_transformationInfo .bv_transformationRule').length).toEqual(1);
            return expect(this.trlc.collection.length).toEqual(1);
          });
        });
      });
      return describe("when instantiated with data", function() {
        beforeEach(function() {
          this.trlc = new TransformationRuleListController({
            el: $('#fixture'),
            collection: new TransformationRuleList(window.primaryScreenTestJSON.transformationRules)
          });
          return this.trlc.render();
        });
        it("should have three rules", function() {
          expect(this.trlc.$('.bv_transformationInfo .bv_transformationRule').length).toEqual(3);
          return expect(this.trlc.collection.length).toEqual(3);
        });
        it("should have the correct rule info for the first rule", function() {
          waitsFor(function() {
            return this.trlc.$('.bv_transformationRule option').length > 0;
          }, 1000);
          return runs(function() {
            return expect(this.trlc.$('.bv_transformationInfo .bv_transformationRule:eq(0)').val()).toEqual("% efficacy");
          });
        });
        it("should have the correct rule info for the second rule", function() {
          waitsFor(function() {
            return this.trlc.$('.bv_transformationRule option').length > 0;
          }, 1000);
          return runs(function() {
            return expect(this.trlc.$('.bv_transformationInfo .bv_transformationRule:eq(1)').val()).toEqual("sd");
          });
        });
        return it("should have the correct rule info for the third rule", function() {
          waitsFor(function() {
            return this.trlc.$('.bv_transformationRule option').length > 0;
          }, 1000);
          return runs(function() {
            return expect(this.trlc.$('.bv_transformationInfo .bv_transformationRule:eq(2)').val()).toEqual("null");
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
          it('should show the instrumentReader', function() {
            waitsFor(function() {
              return this.psapc.$('.bv_instrumentReader option').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.psapc.$('.bv_instrumentReader').val()).toEqual("flipr");
            });
          });
          it('should show the signal direction rule', function() {
            waitsFor(function() {
              return this.psapc.$('.bv_signalDirectionRule option').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.psapc.$('.bv_signalDirectionRule').val()).toEqual("increasing");
            });
          });
          it('should show the aggregateBy1', function() {
            waitsFor(function() {
              return this.psapc.$('.bv_aggregateBy1 option').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.psapc.$('.bv_aggregateBy1').val()).toEqual("compound batch concentration");
            });
          });
          it('should show the aggregateBy2', function() {
            waitsFor(function() {
              return this.psapc.$('.bv_aggregateBy2 option').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.psapc.$('.bv_aggregateBy2').val()).toEqual("median");
            });
          });
          it('should show the normalization rule', function() {
            waitsFor(function() {
              return this.psapc.$('.bv_normalizationRule option').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.psapc.$('.bv_normalizationRule').val()).toEqual("plate order only");
            });
          });
          it('should show the assayVolume', function() {
            return expect(this.psapc.$('.bv_assayVolume').val()).toEqual('24');
          });
          it('should show the transferVolume', function() {
            return expect(this.psapc.$('.bv_transferVolume').val()).toEqual('12');
          });
          it('should show the dilutionFactor', function() {
            return expect(this.psapc.$('.bv_dilutionFactor').val()).toEqual('21');
          });
          it('should start with volumeType radio set', function() {
            return expect(this.psapc.$("input[name='bv_volumeType']:checked").val()).toEqual('dilution');
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
          it('should show the agonistControlConc', function() {
            return expect(this.psapc.$('.bv_agonistControlConc').val()).toEqual('250753.77');
          });
          it('should start with autoHitSelection unchecked', function() {
            return expect(this.psapc.$('.bv_autoHitSelection').attr("checked")).toBeUndefined();
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
          it('should hide threshold controls if the model loads unchecked automaticHitSelection', function() {
            return expect(this.psapc.$('.bv_thresholdControls')).toBeHidden();
          });
          it('should start with htsFormat unchecked', function() {
            return expect(this.psapc.$('.bv_htsFormat').attr("checked")).toBeUndefined();
          });
          it('should start with matchReadName unchecked', function() {
            return expect(this.psapc.$('.bv_matchReadName').attr("checked")).toBeUndefined();
          });
          return it('should show a primary analysis read list', function() {
            return expect(this.psapc.$('.bv_readInfo .bv_readName').length).toEqual(3);
          });
        });
        describe("model updates", function() {
          it("should update the instrument reader", function() {
            waitsFor(function() {
              return this.psapc.$('.bv_instrumentReader option').length > 0;
            }, 1000);
            return runs(function() {
              this.psapc.$('.bv_instrumentReader').val('unassigned');
              this.psapc.$('.bv_instrumentReader').change();
              return expect(this.psapc.model.get('instrumentReader')).toEqual("unassigned");
            });
          });
          it("should update the signal direction rule", function() {
            waitsFor(function() {
              return this.psapc.$('.bv_signalDirectionRule option').length > 0;
            }, 1000);
            return runs(function() {
              this.psapc.$('.bv_signalDirectionRule').val('unassigned');
              this.psapc.$('.bv_signalDirectionRule').change();
              return expect(this.psapc.model.get('signalDirectionRule')).toEqual("unassigned");
            });
          });
          it("should update the aggregateBy1", function() {
            waitsFor(function() {
              return this.psapc.$('.bv_aggregateBy1 option').length > 0;
            }, 1000);
            return runs(function() {
              this.psapc.$('.bv_aggregateBy1').val('unassigned');
              this.psapc.$('.bv_aggregateBy1').change();
              return expect(this.psapc.model.get('aggregateBy1')).toEqual("unassigned");
            });
          });
          it("should update the bv_aggregateBy2", function() {
            waitsFor(function() {
              return this.psapc.$('.bv_aggregateBy2 option').length > 0;
            }, 1000);
            return runs(function() {
              this.psapc.$('.bv_aggregateBy2').val('unassigned');
              this.psapc.$('.bv_aggregateBy2').change();
              return expect(this.psapc.model.get('aggregateBy2')).toEqual("unassigned");
            });
          });
          it("should update the normalizationRule rule", function() {
            waitsFor(function() {
              return this.psapc.$('.bv_normalizationRule option').length > 0;
            }, 1000);
            return runs(function() {
              this.psapc.$('.bv_normalizationRule').val('unassigned');
              this.psapc.$('.bv_normalizationRule').change();
              return expect(this.psapc.model.get('normalizationRule')).toEqual("unassigned");
            });
          });
          it("should update the assayVolume and recalculate the transfer volume if the dilution factor is set ", function() {
            this.psapc.$('.bv_volumeTypeDilution').click();
            this.psapc.$('.bv_dilutionFactor').val(' 3 ');
            this.psapc.$('.bv_dilutionFactor').change();
            expect(this.psapc.model.get('dilutionFactor')).toEqual(3);
            this.psapc.$('.bv_assayVolume').val(' 27 ');
            this.psapc.$('.bv_assayVolume').change();
            expect(this.psapc.model.get('assayVolume')).toEqual(27);
            return expect(this.psapc.model.get('transferVolume')).toEqual(9);
          });
          it("should update the transferVolume and autocalculate the dilution factor based on assay and transfer volumes", function() {
            this.psapc.$('.bv_volumeTypeTransfer').click();
            this.psapc.$('.bv_transferVolume').val(' 12 ');
            this.psapc.$('.bv_transferVolume').change();
            expect(this.psapc.model.get('transferVolume')).toEqual(12);
            this.psapc.$('.bv_assayVolume').val(' 24 ');
            this.psapc.$('.bv_assayVolume').change();
            return expect(this.psapc.model.get('dilutionFactor')).toEqual(2);
          });
          it("should update the dilution factor and autocalculate the transfer volume based on assay volume and dilution factor ", function() {
            this.psapc.$('.bv_dilutionFactor').val(' 4 ');
            this.psapc.$('.bv_dilutionFactor').change();
            expect(this.psapc.model.get('dilutionFactor')).toEqual(4);
            this.psapc.$('.bv_assayVolume').val(' 24 ');
            this.psapc.$('.bv_assayVolume').change();
            return expect(this.psapc.model.get('transferVolume')).toEqual(6);
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
            this.psapc.$('.bv_positiveControlConc').val(' 250753.77 ');
            this.psapc.$('.bv_positiveControlConc').change();
            return expect(this.psapc.model.get('positiveControl').get('concentration')).toEqual(250753.77);
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
            return expect(this.psapc.model.get('agonistControl').get('concentration')).toEqual(250753.77);
          });
          it("should update the thresholdType ", function() {
            this.psapc.$('.bv_thresholdTypeEfficacy').click();
            return expect(this.psapc.model.get('thresholdType')).toEqual("efficacy");
          });
          it("should update the volumeType ", function() {
            this.psapc.$('.bv_volumeTypeTransfer').click();
            return expect(this.psapc.model.get('volumeType')).toEqual("transfer");
          });
          it("should update the autoHitSelection ", function() {
            this.psapc.$('.bv_autoHitSelection').click();
            return expect(this.psapc.model.get('autoHitSelection')).toBeTruthy();
          });
          it("should update the htsFormat checkbox ", function() {
            this.psapc.$('.bv_htsFormat').click();
            return expect(this.psapc.model.get('htsFormat')).toBeTruthy();
          });
          return it("should update the matchReadName checkbox ", function() {
            this.psapc.$('.bv_matchReadName').click();
            this.psapc.$('.bv_matchReadName').click();
            return expect(this.psapc.model.get('matchReadName')).toBeTruthy();
          });
        });
        return describe("behavior and validation", function() {
          it("should disable read position field if match read name is selected", function() {
            this.psapc.$('.bv_matchReadName').click();
            this.psapc.$('.bv_matchReadName').click();
            return expect(this.psapc.$('.bv_readPosition').attr("disabled")).toEqual("disabled");
          });
          it("should enable read position field if match read name is not selected", function() {
            return expect(this.psapc.$('.bv_readPosition').attr("disabled")).toBeUndefined();
          });
          it("should disable sd threshold field if that radio not selected", function() {
            this.psapc.$('.bv_thresholdTypeEfficacy').click();
            expect(this.psapc.$('.bv_hitSDThreshold').attr("disabled")).toEqual("disabled");
            return expect(this.psapc.$('.bv_hitEfficacyThreshold').attr("disabled")).toBeUndefined();
          });
          it("should disable efficacy threshold field if that radio not selected", function() {
            this.psapc.$('.bv_thresholdTypeEfficacy').click();
            this.psapc.$('.bv_thresholdTypeSD').click();
            expect(this.psapc.$('.bv_hitEfficacyThreshold').attr("disabled")).toEqual("disabled");
            return expect(this.psapc.$('.bv_hitSDThreshold').attr("disabled")).toBeUndefined();
          });
          it("should disable dilutionFactor field if that radio not selected", function() {
            this.psapc.$('.bv_volumeTypeTransfer').click();
            expect(this.psapc.$('.bv_dilutionFactor').attr("disabled")).toEqual("disabled");
            return expect(this.psapc.$('.bv_transferVolume').attr("disabled")).toBeUndefined();
          });
          return it("should disable transferVolume if that radio not selected", function() {
            this.psapc.$('.bv_volumeTypeTransfer').click();
            this.psapc.$('.bv_volumeTypeDilution').click();
            expect(this.psapc.$('.bv_transferVolume').attr("disabled")).toEqual("disabled");
            return expect(this.psapc.$('.bv_dilutionFactor').attr("disabled")).toBeUndefined();
          });
        });
      });
      return describe("validation testing", function() {
        beforeEach(function() {
          this.psapc = new PrimaryScreenAnalysisParametersController({
            model: new PrimaryScreenAnalysisParameters(window.primaryScreenTestJSON.primaryScreenAnalysisParameters),
            el: $('#fixture')
          });
          return this.psapc.render();
        });
        return describe("error notification", function() {
          it("should show error if positiveControl batch is not set", function() {
            this.psapc.$('.bv_positiveControlBatch').val("");
            this.psapc.$('.bv_positiveControlBatch').change();
            expect(this.psapc.$('.bv_group_positiveControlBatch').hasClass("error")).toBeTruthy();
            return expect(this.psapc.$('.bv_group_positiveControlBatch').attr('data-toggle')).toEqual("tooltip");
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
          it("should not show error if agonistControl batch and conc are not set", function() {
            this.psapc.$('.bv_agonistControlBatch').val("");
            this.psapc.$('.bv_agonistControlBatch').change();
            this.psapc.$('.bv_agonistControlConc').val("");
            this.psapc.$('.bv_agonistControlConc').change();
            expect(this.psapc.$('.bv_group_agonistControlBatch').hasClass("error")).toBeFalsy();
            return expect(this.psapc.$('.bv_group_agonistControlConc').hasClass("error")).toBeFalsy();
          });
          it("should not show error if agonistControl batch and conc are set correctly", function() {
            this.psapc.$('.bv_agonistControlBatch').val("CMPD-12345678-01");
            this.psapc.$('.bv_agonistControlBatch').change();
            this.psapc.$('.bv_agonistControlConc').val(12);
            this.psapc.$('.bv_agonistControlConc').change();
            expect(this.psapc.$('.bv_group_agonistControlBatch').hasClass("error")).toBeFalsy();
            return expect(this.psapc.$('.bv_group_agonistControlConc').hasClass("error")).toBeFalsy();
          });
          it("should show error if agonistControl batch is correct but conc is NaN or empty", function() {
            this.psapc.$('.bv_agonistControlBatch').val("CMPD-12345678-01");
            this.psapc.$('.bv_agonistControlBatch').change();
            this.psapc.$('.bv_agonistControlConc').val("");
            this.psapc.$('.bv_agonistControlConc').change();
            expect(this.psapc.$('.bv_group_agonistControlBatch').hasClass("error")).toBeFalsy();
            return expect(this.psapc.$('.bv_group_agonistControlConc').hasClass("error")).toBeTruthy();
          });
          it("should show error if agonistControl batch is empty but conc is a number", function() {
            this.psapc.$('.bv_agonistControlBatch').val("");
            this.psapc.$('.bv_agonistControlBatch').change();
            this.psapc.$('.bv_agonistControlConc').val(23);
            this.psapc.$('.bv_agonistControlConc').change();
            expect(this.psapc.$('.bv_group_agonistControlBatch').hasClass("error")).toBeTruthy();
            return expect(this.psapc.$('.bv_group_agonistControlConc').hasClass("error")).toBeFalsy();
          });
          it("should not show error if vehicleControl is not set", function() {
            this.psapc.$('.bv_vehicleControlBatch').val("");
            this.psapc.$('.bv_vehicleControlBatch').change();
            return expect(this.psapc.$('.bv_group_vehicleControlBatch').hasClass("error")).toBeFalsy();
          });
          it("should not show error if instrumentReader is unassigned", function() {
            waitsFor(function() {
              return this.psapc.$('.bv_instrumentReader option').length > 0;
            }, 1000);
            return runs(function() {
              this.psapc.$('.bv_instrumentReader').val("unassigned");
              this.psapc.$('.bv_instrumentReader').change();
              return expect(this.psapc.$('.bv_group_instrumentReader').hasClass("error")).toBeFalsy();
            });
          });
          it("should show error if signal direction rule is unassigned", function() {
            waitsFor(function() {
              return this.psapc.$('.bv_signalDirectionRule option').length > 0;
            }, 1000);
            return runs(function() {
              this.psapc.$('.bv_signalDirectionRule').val("unassigned");
              this.psapc.$('.bv_signalDirectionRule').change();
              return expect(this.psapc.$('.bv_group_signalDirectionRule').hasClass("error")).toBeTruthy();
            });
          });
          it("should show error if aggregateBy1 is unassigned", function() {
            waitsFor(function() {
              return this.psapc.$('.bv_aggregateBy1 option').length > 0;
            }, 1000);
            return runs(function() {
              this.psapc.$('.bv_aggregateBy1').val("unassigned");
              this.psapc.$('.bv_aggregateBy1').change();
              return expect(this.psapc.$('.bv_group_aggregateBy1').hasClass("error")).toBeTruthy();
            });
          });
          it("should show error if aggregateBy2 is unassigned", function() {
            waitsFor(function() {
              return this.psapc.$('.bv_aggregateBy2 option').length > 0;
            }, 1000);
            return runs(function() {
              this.psapc.$('.bv_aggregateBy2').val("unassigned");
              this.psapc.$('.bv_aggregateBy2').change();
              return expect(this.psapc.$('.bv_group_aggregateBy2').hasClass("error")).toBeTruthy();
            });
          });
          it("should show error if normalizationRule is unassigned", function() {
            waitsFor(function() {
              return this.psapc.$('.bv_normalizationRule option').length > 0;
            }, 1000);
            return runs(function() {
              this.psapc.$('.bv_normalizationRule').val("unassigned");
              this.psapc.$('.bv_normalizationRule').change();
              return expect(this.psapc.$('.bv_group_normalizationRule').hasClass("error")).toBeTruthy();
            });
          });
          it("should show error if threshold type is efficacy and efficacy threshold not a number", function() {
            this.psapc.$('.bv_thresholdTypeEfficacy').click();
            this.psapc.$('.bv_hitEfficacyThreshold').val("");
            this.psapc.$('.bv_hitEfficacyThreshold').change();
            return expect(this.psapc.$('.bv_group_hitEfficacyThreshold').hasClass("error")).toBeTruthy();
          });
          it("should show error if threshold type is sd and sd threshold not a number", function() {
            this.psapc.$('.bv_thresholdTypeSD').click();
            this.psapc.$('.bv_hitSDThreshold').val("");
            this.psapc.$('.bv_hitSDThreshold').change();
            return expect(this.psapc.$('.bv_group_hitSDThreshold').hasClass("error")).toBeTruthy();
          });
          it("should show error if volume type is transferVolume and transferVolume not a number (but can be empty)", function() {
            this.psapc.$('.bv_volumeTypeTransfer').click();
            this.psapc.$('.bv_transferVolume').val("hello");
            this.psapc.$('.bv_transferVolume').change();
            return expect(this.psapc.$('.bv_group_transferVolume').hasClass("error")).toBeTruthy();
          });
          it("should not show error if volume type is transferVolume and transferVolume is empty", function() {
            this.psapc.$('.bv_volumeTypeTransfer').click();
            this.psapc.$('.bv_transferVolume').val("");
            this.psapc.$('.bv_transferVolume').change();
            return expect(this.psapc.$('.bv_group_transferVolume').hasClass("error")).toBeFalsy();
          });
          it("should show error if volume type is dilutionFactor and dilutionFactor not a number (but can be empty)", function() {
            this.psapc.$('.bv_volumeTypeDilution').click();
            this.psapc.$('.bv_dilutionFactor').val("hello again");
            this.psapc.$('.bv_dilutionFactor').change();
            return expect(this.psapc.$('.bv_group_dilutionFactor').hasClass("error")).toBeTruthy();
          });
          it("should not show error if volume type is dilutionFactor and dilutionFactor is empty", function() {
            this.psapc.$('.bv_volumeTypeDilution').click();
            this.psapc.$('.bv_dilutionFactor').val("");
            this.psapc.$('.bv_dilutionFactor').change();
            return expect(this.psapc.$('.bv_group_dilutionFactor').hasClass("error")).toBeFalsy();
          });
          it("should show error if assayVolume is NaN", function() {
            this.psapc.$('.bv_assayVolume').val("b");
            this.psapc.$('.bv_assayVolume').change();
            return expect(this.psapc.$('.bv_group_assayVolume').hasClass("error")).toBeTruthy();
          });
          it("should not show error if assayVolume, dilutionFactor, and transferVolume are empty", function() {
            this.psapc.$('.bv_assayVolume').val("");
            this.psapc.$('.bv_assayVolume').change();
            this.psapc.$('.bv_dilutionFactor').val("");
            this.psapc.$('.bv_dilutionFactor').change();
            this.psapc.$('.bv_transferVolume').val("");
            this.psapc.$('.bv_transferVolume').change();
            return expect(this.psapc.$('.bv_group_assayVolume').hasClass("error")).toBeFalsy();
          });
          it("should not show error on read position if match read name is checked", function() {
            this.psapc.$('.bv_matchReadName').click();
            return expect(this.psapc.$('bv_group_readPosition').hasClass("error")).toBeFalsy();
          });
          it("should show error if readPosition is NaN", function() {
            this.psapc.$('.bv_readPosition:eq(0)').val("");
            this.psapc.$('.bv_readPosition:eq(0)').change();
            return expect(this.psapc.$('.bv_group_readPosition:eq(0)').hasClass("error")).toBeTruthy();
          });
          it("should show error if read name is unassigned", function() {
            waitsFor(function() {
              return this.psapc.$('.bv_readName option').length > 0;
            }, 1000);
            return runs(function() {
              this.psapc.$('.bv_readName:eq(0)').val("unassigned");
              this.psapc.$('.bv_readName:eq(0)').change();
              return expect(this.psapc.$('.bv_group_readName').hasClass("error")).toBeTruthy();
            });
          });
          it("should show error if transformation rule is unassigned", function() {
            waitsFor(function() {
              return this.psapc.$('.bv_transformationRule option').length > 0;
            }, 1000);
            return runs(function() {
              this.psapc.$('.bv_transformationRule:eq(0)').val("unassigned");
              this.psapc.$('.bv_transformationRule:eq(0)').change();
              return expect(this.psapc.$('.bv_group_transformationRule:eq(0)').hasClass("error")).toBeTruthy();
            });
          });
          return it("should show error if a transformation rule is selected more than once", function() {
            this.psapc.$('.bv_addTransformationButton').click();
            waitsFor(function() {
              return this.psapc.$('.bv_transformationInfo .bv_transformationRule option').length > 0;
            }, 1000);
            return runs(function() {
              this.psapc.$('.bv_transformationRule:eq(0)').val("sd");
              this.psapc.$('.bv_transformationRule:eq(0)').change();
              this.psapc.$('.bv_transformationRule:eq(1)').val("sd");
              this.psapc.$('.bv_transformationRule:eq(1)').change();
              expect(this.psapc.$('.bv_group_transformationRule:eq(0)').hasClass('error')).toBeTruthy();
              return expect(this.psapc.$('.bv_group_transformationRule:eq(1)').hasClass('error')).toBeTruthy();
            });
          });
        });
      });
    });
    describe("Abstract Upload and Run Primary Analysis Controller testing", function() {
      return describe("Basic loading", function() {
        return it("Class should exist", function() {
          return expect(window.AbstractUploadAndRunPrimaryAnalsysisController).toBeDefined();
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
          this.exp.copyProtocolAttributes(new Protocol(JSON.parse(JSON.stringify(window.protocolServiceTestJSON.fullSavedProtocol))));
          this.psac = new PrimaryScreenAnalysisController({
            model: this.exp,
            el: $('#fixture'),
            uploadAndRunControllerName: "UploadAndRunPrimaryAnalsysisController"
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
            el: $('#fixture'),
            uploadAndRunControllerName: "UploadAndRunPrimaryAnalsysisController"
          });
          return this.psac.render();
        });
        it("Should disable analsyis parameter editing if status is finalized", function() {
          this.psac.model.getStatus().set({
            stringValue: "finalized"
          });
          return expect(this.psac.$('.bv_normalizationRule').attr('disabled')).toEqual('disabled');
        });
        it("Should enable analsyis parameter editing if status is finalized", function() {
          this.psac.model.getStatus().set({
            stringValue: "finalized"
          });
          this.psac.model.getStatus().set({
            stringValue: "started"
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
            el: $('#fixture'),
            uploadAndRunControllerName: "UploadAndRunPrimaryAnalsysisController"
          });
          return this.psac.render();
        });
        return it("should show upload button as re-analyze since status is not 'not started'", function() {
          return expect(this.psac.$('.bv_save').html()).toEqual("Re-Analyze");
        });
      });
    });
    describe("Abstract Primary Screen Experiment Controller testing", function() {
      return describe("Basic loading", function() {
        return it("Class should exist", function() {
          return expect(window.AbstractPrimaryScreenExperimentController).toBeDefined();
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
            return expect(this.psec.$('.bv_doseResponseAnalysis .bv_fitModelButton').length).toNotEqual(0);
          });
        });
      });
    });
  });

}).call(this);
