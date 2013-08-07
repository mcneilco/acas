(function() {
  beforeEach(function() {
    return this.fixture = $.clone($("#fixture").get(0));
  });

  afterEach(function() {
    $("#fixture").remove();
    return $("body").append($(this.fixture));
  });

  describe("Primary Screen Experiment module testing", function() {
    describe("Primary Screen Experiment Controller testing", function() {
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
            return expect(this.psec.$('.bv_primaryScreenDataAnalysis .bv_positiveControlBatch').length).toNotEqual(0);
          });
          return it("Should load a dose response controller", function() {
            return expect(this.psec.$('.bv_doseResponseAnalysis .bv_fixCurveMin').length).toNotEqual(0);
          });
        });
        return describe("saving to server", function() {
          beforeEach(function() {
            return runs(function() {
              this.psec.$('.bv_recordedBy').val("jmcneil");
              this.psec.$('.bv_recordedBy').change();
              this.psec.$('.bv_shortDescription').val(" New short description   ");
              this.psec.$('.bv_shortDescription').change();
              this.psec.$('.bv_description').val(" New long description   ");
              this.psec.$('.bv_description').change();
              this.psec.$('.bv_experimentName').val(" Updated experiment name   ");
              this.psec.$('.bv_experimentName').change();
              this.psec.$('.bv_recordedDate').val(" 2013-3-16   ");
              this.psec.$('.bv_recordedDate').change();
              this.psec.$('.bv_protocolCode').val("PROT-00000001");
              return this.psec.$('.bv_protocolCode').change();
            });
          });
          return describe("expect save to work", function() {
            it("model should be valid and ready to save", function() {
              return expect(this.psec.model.isValid()).toBeTruthy();
            });
            return it("should update experiment code", function() {
              runs(function() {
                return this.psec.$('.bv_save').click();
              });
              waits(100);
              return runs(function() {
                return expect(this.psec.$('.bv_experimentCode').html()).toEqual("EXPT-00000046");
              });
            });
          });
        });
      });
    });
    describe("Primary Screen Analysis Controller testing", function() {
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
            return expect(this.psac).toBeDefined();
          });
          it("Should load the template", function() {
            return expect(this.psac.$('.bv_positiveControlBatch').length).toNotEqual(0);
          });
          return it("Should load a data loader", function() {
            return expect(this.psac.$('.bv_fileUploadWrapper').length).toNotEqual(0);
          });
        });
        describe("should populate fields", function() {
          return it("should show the threshold", function() {
            console.log(this.psac.$('.bv_hitThreshold'));
            return expect(this.psac.$('.bv_hitThreshold').val()).toEqual('0.7');
          });
        });
        return describe("parameter editing", function() {
          return it("should update the model with when the threshold is changed", function() {
            var value;
            this.psac.$('.bv_hitThreshold').val('0.8');
            this.psac.$('.bv_hitThreshold').change();
            value = this.psac.model.get('experimentStates').getStateValueByTypeAndKind("metadata", "experiment analysis parameters", "numericValue", "active efficacy threshold");
            return expect(value.get('numericValue')).toEqual(0.8);
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
