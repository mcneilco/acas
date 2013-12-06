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
      return describe("When loaded from new", function() {
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
            return expect(this.psap.get('thresholdType')).toEqual("sd");
          });
        });
      });
    });
    describe("Primary Screen Experiment model testing", function() {
      return describe("When loaded from existing", function() {
        beforeEach(function() {
          return this.pse = new PrimaryScreenExperiment(window.experimentServiceTestJSON.fullExperimentFromServer);
        });
        return describe("Existence and Defaults", function() {
          it("should be defined", function() {
            return expect(this.pse).toBeDefined();
          });
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
          return it('Should parse veh control into backbone models', function() {
            return expect(this.pse.getAnalysisParameters().get('vehicleControl').get('batchCode')).toEqual("CMPD-00000001-01");
          });
        });
      });
    });
    describe('PrimaryScreenAnalysisParameters Controller', function() {
      return describe('when instantiated', function() {
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
          it('should show the posControlBatch', function() {
            return expect(this.psapc.$('.bv_posControlBatch').val()).toEqual('CMPD-12345678-01');
          });
          it('should show the posControlConc', function() {
            return expect(this.psapc.$('.bv_posControlConc').val()).toEqual('10');
          });
          it('should show the negControlBatch', function() {
            return expect(this.psapc.$('.bv_negControlBatch').val()).toEqual('CMPD-87654321-01');
          });
          it('should show the negControlConc', function() {
            return expect(this.psapc.$('.bv_negControlConc').val()).toEqual('1');
          });
          return it('should show the vehControlBatch', function() {
            return expect(this.psapc.$('.bv_vehControlBatch').val()).toEqual('CMPD-00000001-01');
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
            return expect(this.psapc.model.get('hitSDThreshold')).toEqual("24");
          });
          it("should update the hitEfficacyThreshold ", function() {
            this.psapc.$('.bv_hitEfficacyThreshold').val(' 25 ');
            this.psapc.$('.bv_hitEfficacyThreshold').change();
            return expect(this.psapc.model.get('hitEfficacyThreshold')).toEqual("25");
          });
          it("should update the positiveControl ", function() {
            this.psapc.$('.bv_posControlBatch').val(' pos cont ');
            this.psapc.$('.bv_posControlBatch').change();
            return expect(this.psapc.model.get('positiveControl').get('batchCode')).toEqual("pos cont");
          });
          it("should update the positiveControl conc ", function() {
            this.psapc.$('.bv_posControlConc').val(' 61 ');
            this.psapc.$('.bv_posControlConc').change();
            return expect(this.psapc.model.get('positiveControl').get('concentration')).toEqual("61");
          });
          it("should update the negativeControl ", function() {
            this.psapc.$('.bv_negControlBatch').val(' neg cont ');
            this.psapc.$('.bv_negControlBatch').change();
            return expect(this.psapc.model.get('negativeControl').get('batchCode')).toEqual("neg cont");
          });
          it("should update the negativeControl conc ", function() {
            this.psapc.$('.bv_negControlConc').val(' 62 ');
            this.psapc.$('.bv_negControlConc').change();
            return expect(this.psapc.model.get('negativeControl').get('concentration')).toEqual("62");
          });
          it("should update the vehicleControl ", function() {
            this.psapc.$('.bv_vehControlBatch').val(' veh cont ');
            this.psapc.$('.bv_vehControlBatch').change();
            return expect(this.psapc.model.get('vehicleControl').get('batchCode')).toEqual("veh cont");
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
    });
    xdescribe("Primary Screen Experiment Controller testing", function() {
      return describe("basic plumbing checks with new experiment", function() {
        beforeEach(function() {
          this.psec = new PrimaryScreenExperimentController({
            model: new Experiment(),
            el: $('#fixture')
          });
          return this.psec.render();
        });
        describe("Basic loading", function() {
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
            return expect(this.psec.$('.bv_primaryScreenDataAnalysis .bv_posControlBatch').length).toNotEqual(0);
          });
          return it("Should load a dose response controller", function() {
            return expect(this.psec.$('.bv_doseResponseAnalysis .bv_fixCurveMin').length).toNotEqual(0);
          });
        });
        return describe("saving to server", function() {
          beforeEach(function() {
            var _this = this;
            waitsFor(function() {
              return _this.psec.$('.bv_protocolCode option').length > 0 && _this.psec.$('.bv_projectCode option').length > 0;
            }, 1000);
            runs(function() {
              _this.psec.$('.bv_recordedBy').val("jmcneil");
              _this.psec.$('.bv_recordedBy').change();
              _this.psec.$('.bv_shortDescription').val(" New short description   ");
              _this.psec.$('.bv_shortDescription').change();
              _this.psec.$('.bv_description').val(" New long description   ");
              _this.psec.$('.bv_description').change();
              _this.psec.$('.bv_experimentName').val(" Updated experiment name   ");
              _this.psec.$('.bv_experimentName').change();
              _this.psec.$('.bv_recordedDate').val(" 2013-3-16   ");
              _this.psec.$('.bv_recordedDate').change();
              _this.psec.$('.bv_protocolCode').val("PROT-00000001");
              return _this.psec.$('.bv_protocolCode').change();
            });
            waits(500);
            runs(function() {
              _this.psec.$('.bv_useProtocolParameters').click();
              _this.psec.$('.bv_projectCode').val("project1");
              _this.psec.$('.bv_projectCode').change();
              _this.psec.$('.bv_notebook').val("my notebook");
              _this.psec.$('.bv_notebook').change();
              _this.psec.$('.bv_completionDate').val(" 2013-3-16   ");
              return _this.psec.$('.bv_completionDate').change();
            });
            return waits(200);
          });
          return describe("expect save to work", function() {
            it("model should be valid and ready to save", function() {
              return runs(function() {
                return expect(this.psec.model.isValid()).toBeTruthy();
              });
            });
            return it("should update experiment code", function() {
              runs(function() {
                return this.psec.$('.bv_save').click();
              });
              waits(100);
              return runs(function() {
                return expect(this.psec.$('.bv_experimentCode').html()).toEqual("EXPT-00000001");
              });
            });
          });
        });
      });
    });
    xdescribe("Primary Screen Analysis Controller testing", function() {
      return describe("basic plumbing checks with experiment copied from template", function() {
        beforeEach(function() {
          this.exp = new Experiment();
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
          it("Should load the template", function() {
            return expect(this.psac.$('.bv_posControlBatch').length).toNotEqual(0);
          });
          return it("Should load a data loader", function() {
            return expect(this.psac.$('.bv_fileUploadWrapper').length).toNotEqual(0);
          });
        });
        describe("should populate fields", function() {
          return it("should show the threshold", function() {
            return expect(this.psac.$('.bv_hitThreshold').val()).toEqual('0.7');
          });
        });
        describe("parameter editing", function() {
          return it("should update the model with when the threshold is changed", function() {
            var value;
            this.psac.$('.bv_hitThreshold').val('0.8');
            this.psac.$('.bv_hitThreshold').change();
            value = this.psac.model.get('lsStates').getStateValueByTypeAndKind("metadata", "experiment analysis parameters", "numericValue", "active efficacy threshold");
            return expect(value.get('numericValue')).toEqual(0.8);
          });
        });
        describe("should populate fields", function() {
          return it("should show the transformation", function() {
            return expect(this.psac.$('.bv_transformationRule').val()).toEqual('(maximum-minimum)/minimum');
          });
        });
        describe("parameter editing", function() {
          return it("should update the model with when the transformation is changed", function() {
            var value;
            this.psac.$('.bv_transformationRule').val('fiona');
            this.psac.$('.bv_transformationRule').change();
            value = this.psac.model.get('lsStates').getStateValueByTypeAndKind("metadata", "experiment analysis parameters", "stringValue", "data transformation rule");
            return expect(value.get('stringValue')).toEqual("fiona");
          });
        });
        describe("should populate fields", function() {
          it("should show the normalization", function() {
            return expect(this.psac.$('.bv_normalizationRule').val()).toEqual('none');
          });
          it("should show the negative control batch", function() {
            return expect(this.psac.$('.bv_negControlBatch').val()).toEqual("CRA-000396:1");
          });
          return it("should show the negative control concentration", function() {
            return expect(this.psac.$('.bv_negControlConc').val()).toEqual(1.0);
          });
        });
        return describe("parameter editing", function() {
          return it("should update the model with when the normalization is changed", function() {
            var value;
            this.psac.$('.bv_normalizationRule').val('plate order');
            this.psac.$('.bv_normalizationRule').change();
            value = this.psac.model.get('lsStates').getStateValueByTypeAndKind("metadata", "experiment analysis parameters", "stringValue", "normalization rule");
            return expect(value.get('stringValue')).toEqual("plate order");
          });
        });
      });
    });
    return describe("Upload and Run Primary Analysis Controller testing", function() {
      beforeEach(function() {
        this.uarpac = new UploadAndRunPrimaryAnalsysisController({
          el: $('#fixture')
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
  });

}).call(this);
