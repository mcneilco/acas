(function() {
  beforeEach(function() {
    return this.fixture = $.clone($("#fixture").get(0));
  });

  afterEach(function() {
    $("#fixture").remove();
    return $("body").append($(this.fixture));
  });

  describe("Primary Screen Protocol module testing", function() {
    describe("Primary Screen Protocol model testing", function() {
      describe("When loaded from new", function() {
        beforeEach(function() {
          return this.psp = new PrimaryScreenProtocol();
        });
        describe("Defaults", function() {
          it('Should have the select DNS target list be unchecked', function() {
            return expect(this.psp.get('dnsList')).toBeFalsy();
          });
          it('Should have an default maxY curve display of 100', function() {
            expect(this.psp.getCurveDisplayMax() instanceof Value).toBeTruthy();
            return expect(this.psp.getCurveDisplayMax().get('numericValue')).toEqual(100.0);
          });
          return it('Should have an default minY curve display of 0', function() {
            expect(this.psp.getCurveDisplayMin() instanceof Value).toBeTruthy();
            return expect(this.psp.getCurveDisplayMin().get('numericValue')).toEqual(0);
          });
        });
        return describe("required states and values", function() {
          it("should have an assay activity value", function() {
            expect(this.psp.getPrimaryScreenProtocolParameterCodeValue('assay activity') instanceof Value).toBeTruthy();
            expect(this.psp.getPrimaryScreenProtocolParameterCodeValue('assay activity').get('codeValue')).toEqual("unassigned");
            return expect(this.psp.getPrimaryScreenProtocolParameterCodeValue('assay activity').get('codeOrigin')).toEqual("acas ddict");
          });
          it("should have a molecular target value with code origin set to acas ddict", function() {
            expect(this.psp.getPrimaryScreenProtocolParameterCodeValue('molecular target') instanceof Value).toBeTruthy();
            expect(this.psp.getPrimaryScreenProtocolParameterCodeValue('molecular target').get('codeValue')).toEqual("unassigned");
            return expect(this.psp.getPrimaryScreenProtocolParameterCodeValue('molecular target').get('codeOrigin')).toEqual("acas ddict");
          });
          it("should have a target origin value", function() {
            expect(this.psp.getPrimaryScreenProtocolParameterCodeValue('target origin') instanceof Value).toBeTruthy();
            expect(this.psp.getPrimaryScreenProtocolParameterCodeValue('target origin').get('codeValue')).toEqual("unassigned");
            return expect(this.psp.getPrimaryScreenProtocolParameterCodeValue('target origin').get('codeOrigin')).toEqual("acas ddict");
          });
          it("should have an assay type value", function() {
            expect(this.psp.getPrimaryScreenProtocolParameterCodeValue('assay type') instanceof Value).toBeTruthy();
            expect(this.psp.getPrimaryScreenProtocolParameterCodeValue('assay type').get('codeValue')).toEqual("unassigned");
            return expect(this.psp.getPrimaryScreenProtocolParameterCodeValue('assay type').get('codeOrigin')).toEqual("acas ddict");
          });
          it("should have an assay technology value", function() {
            expect(this.psp.getPrimaryScreenProtocolParameterCodeValue('assay technology') instanceof Value).toBeTruthy();
            expect(this.psp.getPrimaryScreenProtocolParameterCodeValue('assay technology').get('codeValue')).toEqual("unassigned");
            return expect(this.psp.getPrimaryScreenProtocolParameterCodeValue('assay technology').get('codeOrigin')).toEqual("acas ddict");
          });
          it("should have a cell line value", function() {
            expect(this.psp.getPrimaryScreenProtocolParameterCodeValue('cell line') instanceof Value).toBeTruthy();
            expect(this.psp.getPrimaryScreenProtocolParameterCodeValue('cell line').get('codeValue')).toEqual("unassigned");
            return expect(this.psp.getPrimaryScreenProtocolParameterCodeValue('cell line').get('codeOrigin')).toEqual("acas ddict");
          });
          return it("should have an assay stage value", function() {
            expect(this.psp.getPrimaryScreenProtocolParameterCodeValue('assay stage') instanceof Value).toBeTruthy();
            expect(this.psp.getPrimaryScreenProtocolParameterCodeValue('assay stage').get('codeValue')).toEqual("unassigned");
            return expect(this.psp.getPrimaryScreenProtocolParameterCodeValue('assay stage').get('codeOrigin')).toEqual("acas ddict");
          });
        });
      });
      describe("When loaded from existing", function() {
        beforeEach(function() {
          return this.psp = new PrimaryScreenProtocol(window.primaryScreenProtocolTestJSON.fullSavedPrimaryScreenProtocol);
        });
        describe("Existence and Defaults", function() {
          return it("should be defined", function() {
            return expect(this.psp).toBeDefined();
          });
        });
        return describe("after initial load", function() {
          it("should have the Select DNS Target List be checked ", function() {
            return expect(this.psp.get('dnsList')).toBeTruthy();
          });
          it("should have a maxY curve display ", function() {
            return expect(this.psp.getCurveDisplayMax().get('numericValue')).toEqual(200);
          });
          it("should have a minY curve display ", function() {
            return expect(this.psp.getCurveDisplayMin().get('numericValue')).toEqual(10.0);
          });
          it('Should have an assay Activity value', function() {
            return expect(this.psp.getPrimaryScreenProtocolParameterCodeValue('assay activity').get('codeValue')).toEqual("luminescence");
          });
          it('Should have a molecularTarget value', function() {
            expect(this.psp.getPrimaryScreenProtocolParameterCodeValue('molecular target').get('codeValue')).toEqual("target x");
            return expect(this.psp.getPrimaryScreenProtocolParameterCodeValue('molecular target').get('codeOrigin')).toEqual("dns target list");
          });
          it('Should have an targetOrigin value', function() {
            return expect(this.psp.getPrimaryScreenProtocolParameterCodeValue('target origin').get('codeValue')).toEqual("human");
          });
          it('Should have an assay type value', function() {
            return expect(this.psp.getPrimaryScreenProtocolParameterCodeValue('assay type').get('codeValue')).toEqual("cellular assay");
          });
          it('Should have a molecularTarget value with code origin set to dns target list', function() {
            return expect(this.psp.getPrimaryScreenProtocolParameterCodeValue('assay technology').get('codeValue')).toEqual("wizard triple luminescence");
          });
          it('Should have an targetOrigin value', function() {
            return expect(this.psp.getPrimaryScreenProtocolParameterCodeValue('cell line').get('codeValue')).toEqual("cell line y");
          });
          return it('Should have an assay stage value', function() {
            return expect(this.psp.getPrimaryScreenProtocolParameterCodeValue('assay stage').get('codeValue')).toEqual("assay development");
          });
        });
      });
      return describe("model validation", function() {
        beforeEach(function() {
          return this.psp = new PrimaryScreenProtocol(window.primaryScreenProtocolTestJSON.fullSavedPrimaryScreenProtocol);
        });
        it("should be valid when loaded from saved", function() {
          return expect(this.psp.isValid()).toBeTruthy();
        });
        it("should be invalid when maxY is NaN", function() {
          var filtErrors;
          this.psp.getCurveDisplayMax().set({
            numericValue: NaN
          });
          expect(this.psp.isValid()).toBeFalsy();
          filtErrors = _.filter(this.psp.validationError, function(err) {
            return err.attribute === 'maxY';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        return it("should be invalid when minY is NaN", function() {
          var filtErrors;
          this.psp.getCurveDisplayMin().set({
            numericValue: NaN
          });
          expect(this.psp.isValid()).toBeFalsy();
          filtErrors = _.filter(this.psp.validationError, function(err) {
            return err.attribute === 'minY';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
      });
    });
    describe("AbstractPrimaryScreenProtocolParameterController testing", function() {
      return describe("Basic loading", function() {
        return it("class should exist", function() {
          return expect(window.AbstractPrimaryScreenProtocolParameterController).toBeDefined();
        });
      });
    });
    describe("AssayActivityController testing", function() {
      describe("when created from a new protocol", function() {
        beforeEach(function() {
          this.aac = new AssayActivityController({
            model: new PrimaryScreenProtocol()
          });
          return this.aac.render();
        });
        return describe("when instantiated", function() {
          it("should exist", function() {
            return expect(this.aac).toBeDefined();
          });
          it("should have the parameter variable set to assay activity", function() {
            return expect(this.aac.parameter).toEqual("assayActivity");
          });
          return it("should show the assayActivity as unassigned", function() {
            waitsFor(function() {
              return this.aac.$('.bv_assayActivity option').length > 0;
            }, 1000);
            return runs(function() {
              expect(this.aac.model.getPrimaryScreenProtocolParameterCodeValue('assay activity').get('codeValue')).toEqual("unassigned");
              return expect(this.aac.$('.bv_assayActivity').val()).toEqual("unassigned");
            });
          });
        });
      });
      return describe("when created from a saved primary screen protocol", function() {
        beforeEach(function() {
          this.aac = new AssayActivityController({
            model: new PrimaryScreenProtocol(window.primaryScreenProtocolTestJSON.fullSavedPrimaryScreenProtocol),
            el: $('#fixture')
          });
          return this.aac.render();
        });
        describe("when instantiated", function() {
          it("should exist", function() {
            return expect(this.aac).toBeDefined();
          });
          it("should have the parameter variable set to assay activity", function() {
            return expect(this.aac.parameter).toEqual("assayActivity");
          });
          return it("should show the assayActivity", function() {
            waitsFor(function() {
              return this.aac.$('.bv_assayActivity option').length > 0;
            }, 1000);
            return runs(function() {
              expect(this.aac.model.getPrimaryScreenProtocolParameterCodeValue('assay activity').get('codeValue')).toEqual("luminescence");
              return expect(this.aac.$('.bv_assayActivity').val()).toEqual("luminescence");
            });
          });
        });
        return describe("model updates", function() {
          it("should update the assay activity", function() {
            waitsFor(function() {
              return this.aac.$('.bv_assayActivity option').length > 0;
            }, 1000);
            return runs(function() {
              this.aac.$('.bv_assayActivity').val('fluorescence');
              this.aac.$('.bv_assayActivity').change();
              return expect(this.aac.model.getPrimaryScreenProtocolParameterCodeValue('assay activity').get('codeValue')).toEqual("fluorescence");
            });
          });
          return describe("pop modal testing", function() {
            it("should display a modal when add button is clicked", function() {
              this.aac.$('.bv_addAssayActivityBtn').click();
              return expect(this.aac.$('.bv_newAssayActivityLabel').length).toEqual(1);
            });
            it("should show confirmation message if new option is added", function() {
              this.aac.$('.bv_newAssayActivityLabel').val("new option");
              this.aac.$('.bv_newAssayActivityLabel').change();
              this.aac.$('.bv_addNewAssayActivityOption').click();
              expect(this.aac.$('.bv_optionAddedMessage')).toBeVisible();
              return expect(this.aac.$('.bv_errorMessage')).toBeHidden();
            });
            return it("should show error message if user tries to add existing option", function() {
              this.aac2 = new AssayActivityController({
                model: new PrimaryScreenProtocol(window.primaryScreenProtocolTestJSON.fullSavedPrimaryScreenProtocol),
                el: $('#fixture')
              });
              this.aac2.render();
              this.aac2.$('.bv_addAssayActivityBtn').click();
              this.aac2.$('.bv_newAssayActivityLabel').val("luminescence");
              this.aac2.$('.bv_newAssayActivityLabel').change();
              this.aac2.$('.bv_addNewAssayActivityOption').click();
              expect(this.aac2.$('.bv_optionAddedMessage')).toBeHidden();
              return expect(this.aac2.$('.bv_errorMessage')).toBeVisible();
            });
          });
        });
      });
    });
    describe("MolecularTargetController testing", function() {
      describe("when created from a new protocol", function() {
        beforeEach(function() {
          this.mtc = new MolecularTargetController({
            model: new PrimaryScreenProtocol()
          });
          return this.mtc.render();
        });
        return describe("when instantiated", function() {
          it("should exist", function() {
            return expect(this.mtc).toBeDefined();
          });
          it("should have the parameter variable set to molecular target ", function() {
            return expect(this.mtc.parameter).toEqual("molecularTarget");
          });
          return it("should show the molecularTarget as unassigned", function() {
            waitsFor(function() {
              return this.mtc.$('.bv_molecularTarget option').length > 0;
            }, 1000);
            return runs(function() {
              expect(this.mtc.model.getPrimaryScreenProtocolParameterCodeValue('molecular target').get('codeValue')).toEqual("unassigned");
              return expect(this.mtc.$('.bv_molecularTarget').val()).toEqual("unassigned");
            });
          });
        });
      });
      return describe("when created from a saved primary screen protocol", function() {
        beforeEach(function() {
          this.mtc = new MolecularTargetController({
            model: new PrimaryScreenProtocol(window.primaryScreenProtocolTestJSON.fullSavedPrimaryScreenProtocol),
            el: $('#fixture')
          });
          return this.mtc.render();
        });
        describe("when instantiated", function() {
          it("should exist", function() {
            return expect(this.mtc).toBeDefined();
          });
          it("should have the parameter variable set to molecular target ", function() {
            return expect(this.mtc.parameter).toEqual("molecularTarget");
          });
          return it("should show the molecularTarget", function() {
            waitsFor(function() {
              return this.mtc.$('.bv_molecularTarget option').length > 0;
            }, 1000);
            return runs(function() {
              expect(this.mtc.model.getPrimaryScreenProtocolParameterCodeValue('molecular target').get('codeValue')).toEqual("target x");
              return expect(this.mtc.$('.bv_molecularTarget').val()).toEqual("target x");
            });
          });
        });
        return describe("model updates", function() {
          return it("should update the molecular target", function() {
            waitsFor(function() {
              return this.mtc.$('.bv_molecularTarget option').length > 0;
            }, 1000);
            return runs(function() {
              this.mtc.$('.bv_molecularTarget').val('target y');
              this.mtc.$('.bv_molecularTarget').change();
              return expect(this.mtc.model.getPrimaryScreenProtocolParameterCodeValue('molecular target').get('codeValue')).toEqual("target y");
            });
          });
        });
      });
    });
    describe("TargetOriginController testing", function() {
      describe("when created from a new protocol", function() {
        beforeEach(function() {
          this.toc = new TargetOriginController({
            model: new PrimaryScreenProtocol()
          });
          return this.toc.render();
        });
        return describe("when instantiated", function() {
          it("should exist", function() {
            return expect(this.toc).toBeDefined();
          });
          it("should have the parameter variable set to target origin", function() {
            return expect(this.toc.parameter).toEqual("targetOrigin");
          });
          return it("should show the targetOrigin as unassigned", function() {
            waitsFor(function() {
              return this.toc.$('.bv_targetOrigin option').length > 0;
            }, 1000);
            return runs(function() {
              expect(this.toc.model.getPrimaryScreenProtocolParameterCodeValue('target origin').get('codeValue')).toEqual("unassigned");
              return expect(this.toc.$('.bv_targetOrigin').val()).toEqual("unassigned");
            });
          });
        });
      });
      return describe("when created from a saved primary screen protocol", function() {
        beforeEach(function() {
          this.toc = new TargetOriginController({
            model: new PrimaryScreenProtocol(window.primaryScreenProtocolTestJSON.fullSavedPrimaryScreenProtocol),
            el: $('#fixture')
          });
          return this.toc.render();
        });
        describe("when instantiated", function() {
          it("should exist", function() {
            return expect(this.toc).toBeDefined();
          });
          it("should have the parameter variable set to target origin", function() {
            return expect(this.toc.parameter).toEqual("targetOrigin");
          });
          return it("should show the targetOrigin", function() {
            waitsFor(function() {
              return this.toc.$('.bv_targetOrigin option').length > 0;
            }, 1000);
            return runs(function() {
              expect(this.toc.model.getPrimaryScreenProtocolParameterCodeValue('target origin').get('codeValue')).toEqual("human");
              return expect(this.toc.$('.bv_targetOrigin').val()).toEqual("human");
            });
          });
        });
        return describe("model updates", function() {
          return it("should update the target origin", function() {
            waitsFor(function() {
              return this.toc.$('.bv_targetOrigin option').length > 0;
            }, 1000);
            return runs(function() {
              this.toc.$('.bv_targetOrigin').val('chimpanzee');
              this.toc.$('.bv_targetOrigin').change();
              return expect(this.toc.model.getPrimaryScreenProtocolParameterCodeValue('target origin').get('codeValue')).toEqual("chimpanzee");
            });
          });
        });
      });
    });
    describe("AssayTypeController testing", function() {
      describe("when created from a new protocol", function() {
        beforeEach(function() {
          this.atc = new AssayTypeController({
            model: new PrimaryScreenProtocol()
          });
          return this.atc.render();
        });
        return describe("when instantiated", function() {
          it("should exist", function() {
            return expect(this.atc).toBeDefined();
          });
          it("should have the parameter variable set to assay type", function() {
            return expect(this.atc.parameter).toEqual("assayType");
          });
          return it("should show the assay type as unassigned", function() {
            waitsFor(function() {
              return this.atc.$('.bv_assayType option').length > 0;
            }, 1000);
            return runs(function() {
              expect(this.atc.model.getPrimaryScreenProtocolParameterCodeValue('assay type').get('codeValue')).toEqual("unassigned");
              return expect(this.atc.$('.bv_assayType').val()).toEqual("unassigned");
            });
          });
        });
      });
      return describe("when created from a saved primary screen protocol", function() {
        beforeEach(function() {
          this.atc = new AssayTypeController({
            model: new PrimaryScreenProtocol(window.primaryScreenProtocolTestJSON.fullSavedPrimaryScreenProtocol),
            el: $('#fixture')
          });
          return this.atc.render();
        });
        describe("when instantiated", function() {
          it("should exist", function() {
            return expect(this.atc).toBeDefined();
          });
          it("should have the parameter variable set to assay type", function() {
            return expect(this.atc.parameter).toEqual("assayType");
          });
          return it("should show the assayType", function() {
            waitsFor(function() {
              return this.atc.$('.bv_assayType option').length > 0;
            }, 1000);
            return runs(function() {
              expect(this.atc.model.getPrimaryScreenProtocolParameterCodeValue('assay type').get('codeValue')).toEqual("cellular assay");
              return expect(this.atc.$('.bv_assayType').val()).toEqual("cellular assay");
            });
          });
        });
        return describe("model updates", function() {
          return it("should update the assay type", function() {
            waitsFor(function() {
              return this.atc.$('.bv_assayType option').length > 0;
            }, 1000);
            return runs(function() {
              this.atc.$('.bv_assayType').val('unassigned');
              this.atc.$('.bv_assayType').change();
              return expect(this.atc.model.getPrimaryScreenProtocolParameterCodeValue('assay type').get('codeValue')).toEqual("unassigned");
            });
          });
        });
      });
    });
    describe("AssayTechnologyController testing", function() {
      describe("when created from a new protocol", function() {
        beforeEach(function() {
          this.atc2 = new AssayTechnologyController({
            model: new PrimaryScreenProtocol()
          });
          return this.atc2.render();
        });
        return describe("when instantiated", function() {
          it("should exist", function() {
            return expect(this.atc2).toBeDefined();
          });
          it("should have the parameter variable set to assay technology", function() {
            return expect(this.atc2.parameter).toEqual("assayTechnology");
          });
          return it("should show the assay technology as unassigned", function() {
            waitsFor(function() {
              return this.atc2.$('.bv_assayTechnology option').length > 0;
            }, 1000);
            return runs(function() {
              expect(this.atc2.model.getPrimaryScreenProtocolParameterCodeValue('assay technology').get('codeValue')).toEqual("unassigned");
              return expect(this.atc2.$('.bv_assayTechnology').val()).toEqual("unassigned");
            });
          });
        });
      });
      return describe("when created from a saved primary screen protocol", function() {
        beforeEach(function() {
          this.atc2 = new AssayTechnologyController({
            model: new PrimaryScreenProtocol(window.primaryScreenProtocolTestJSON.fullSavedPrimaryScreenProtocol),
            el: $('#fixture')
          });
          return this.atc2.render();
        });
        describe("when instantiated", function() {
          it("should exist", function() {
            return expect(this.atc2).toBeDefined();
          });
          it("should have the parameter variable set to assay technology", function() {
            return expect(this.atc2.parameter).toEqual("assayTechnology");
          });
          return it("should show the assayTechnology", function() {
            waitsFor(function() {
              return this.atc2.$('.bv_assayTechnology option').length > 0;
            }, 1000);
            return runs(function() {
              expect(this.atc2.model.getPrimaryScreenProtocolParameterCodeValue('assay technology').get('codeValue')).toEqual("wizard triple luminescence");
              return expect(this.atc2.$('.bv_assayTechnology').val()).toEqual("wizard triple luminescence");
            });
          });
        });
        return describe("model updates", function() {
          return it("should update the assay technology", function() {
            waitsFor(function() {
              return this.atc2.$('.bv_assayTechnology option').length > 0;
            }, 1000);
            return runs(function() {
              this.atc2.$('.bv_assayTechnology').val('unassigned');
              this.atc2.$('.bv_assayTechnology').change();
              return expect(this.atc2.model.getPrimaryScreenProtocolParameterCodeValue('assay technology').get('codeValue')).toEqual("unassigned");
            });
          });
        });
      });
    });
    describe("CellLineController testing", function() {
      describe("when created from a new protocol", function() {
        beforeEach(function() {
          this.clc = new CellLineController({
            model: new PrimaryScreenProtocol()
          });
          return this.clc.render();
        });
        return describe("when instantiated", function() {
          it("should exist", function() {
            return expect(this.clc).toBeDefined();
          });
          it("should have the parameter variable set to cell line", function() {
            return expect(this.clc.parameter).toEqual("cellLine");
          });
          return it("should show the cell line as unassigned", function() {
            waitsFor(function() {
              return this.clc.$('.bv_cellLine option').length > 0;
            }, 1000);
            return runs(function() {
              expect(this.clc.model.getPrimaryScreenProtocolParameterCodeValue('cell line').get('codeValue')).toEqual("unassigned");
              return expect(this.clc.$('.bv_cellLine').val()).toEqual("unassigned");
            });
          });
        });
      });
      return describe("when created from a saved primary screen protocol", function() {
        beforeEach(function() {
          this.clc = new CellLineController({
            model: new PrimaryScreenProtocol(window.primaryScreenProtocolTestJSON.fullSavedPrimaryScreenProtocol),
            el: $('#fixture')
          });
          return this.clc.render();
        });
        describe("when instantiated", function() {
          it("should exist", function() {
            return expect(this.clc).toBeDefined();
          });
          it("should have the parameter variable set to cell line", function() {
            return expect(this.clc.parameter).toEqual("cellLine");
          });
          return it("should show the cellLine", function() {
            waitsFor(function() {
              return this.clc.$('.bv_cellLine option').length > 0;
            }, 1000);
            return runs(function() {
              expect(this.clc.model.getPrimaryScreenProtocolParameterCodeValue('cell line').get('codeValue')).toEqual("cell line y");
              return expect(this.clc.$('.bv_cellLine').val()).toEqual("cell line y");
            });
          });
        });
        return describe("model updates", function() {
          return it("should update the cell line", function() {
            waitsFor(function() {
              return this.clc.$('.bv_cellLine option').length > 0;
            }, 1000);
            return runs(function() {
              this.clc.$('.bv_cellLine').val('unassigned');
              this.clc.$('.bv_cellLine').change();
              return expect(this.clc.model.getPrimaryScreenProtocolParameterCodeValue('cell line').get('codeValue')).toEqual("unassigned");
            });
          });
        });
      });
    });
    describe("Primary Screen Protocol Parameters Controller", function() {
      describe("when created from a new primary screen protocol", function() {
        beforeEach(function() {
          this.psppc = new PrimaryScreenProtocolParametersController({
            model: new PrimaryScreenProtocol(),
            el: $('#fixture')
          });
          return this.psppc.render();
        });
        describe("basic existence tests", function() {
          it("should exist", function() {
            return expect(this.psppc).toBeDefined();
          });
          return it("should load a template", function() {
            return expect(this.psppc.$('.bv_dnsTargetListChkbx').length).toEqual(1);
          });
        });
        describe("render parameters", function() {
          it("should have the select dns target list be unchecked", function() {
            return expect(this.psppc.$('.bv_dnsTargetListChkbx').attr("checked")).toBeUndefined();
          });
          it("should show the curve display max", function() {
            expect(this.psppc.model.getCurveDisplayMax().get('numericValue')).toEqual(100.0);
            return expect(this.psppc.$('.bv_maxY').val()).toEqual("100");
          });
          it("should show the curve display min", function() {
            expect(this.psppc.model.getCurveDisplayMin().get('numericValue')).toEqual(0.0);
            return expect(this.psppc.$('.bv_minY').val()).toEqual("0");
          });
          return it('should show the assayStage', function() {
            waitsFor(function() {
              return this.psppc.$('.bv_assayStage option').length > 0;
            }, 1000);
            return runs(function() {
              expect(this.psppc.model.getPrimaryScreenProtocolParameterCodeValue('assay stage').get('codeValue')).toEqual("unassigned");
              return expect(this.psppc.$('.bv_assayStage').val()).toEqual("unassigned");
            });
          });
        });
        describe("model updates", function() {
          it("should update the select DNS target list", function() {
            this.psppc.$('.bv_dnsTargetListChkbx').click();
            this.psppc.$('.bv_dnsTargetListChkbx').click();
            expect(this.psppc.model.get('dnsList')).toBeTruthy();
            return expect(this.psppc.model.getPrimaryScreenProtocolParameterCodeValue('molecular target').get('codeOrigin')).toEqual("dns target list");
          });
          it("should update the curve display max", function() {
            this.psppc.$('.bv_maxY').val("130");
            this.psppc.$('.bv_maxY').change();
            return expect(this.psppc.model.getCurveDisplayMax().get('numericValue')).toEqual("130");
          });
          it("should update the curve display min", function() {
            this.psppc.$('.bv_minY').val("13");
            this.psppc.$('.bv_minY').change();
            return expect(this.psppc.model.getCurveDisplayMin().get('numericValue')).toEqual("13");
          });
          return it("should update model when assay stage changed", function() {
            waitsFor(function() {
              return this.psppc.$('.bv_assayStage option').length > 0;
            }, 1000);
            return runs(function() {
              this.psppc.$('.bv_assayStage').val('unassigned');
              this.psppc.$('.bv_assayStage').change();
              return expect(this.psppc.model.getPrimaryScreenProtocolParameterCodeValue('assay stage').get('codeValue')).toEqual("unassigned");
            });
          });
        });
        describe("behavior", function() {
          return it("should hide the Molecular Target's add button when the Select dns target list checkbox is checked", function() {
            this.psppc.$('.bv_dnsTargetListChkbx').click();
            this.psppc.$('.bv_dnsTargetListChkbx').click();
            return expect(this.psppc.model.get('dnsList')).toBeTruthy();
          });
        });
        return describe("controller validation rules", function() {
          it("should show error when maxY is NaN", function() {
            this.psppc.$('.bv_maxY').val("b");
            this.psppc.$('.bv_maxY').change();
            return expect(this.psppc.$('.bv_group_maxY').hasClass('error')).toBeTruthy();
          });
          return it("should show error when minY is NaN", function() {
            this.psppc.$('.bv_minY').val("b");
            this.psppc.$('.bv_minY').change();
            return expect(this.psppc.$('.bv_group_minY').hasClass('error')).toBeTruthy();
          });
        });
      });
      return describe("when created from a saved primary screen protocol", function() {
        beforeEach(function() {
          this.psppc = new PrimaryScreenProtocolParametersController({
            model: new PrimaryScreenProtocol(window.primaryScreenProtocolTestJSON.fullSavedPrimaryScreenProtocol),
            el: $('#fixture')
          });
          return this.psppc.render();
        });
        return describe("when instantiated", function() {
          describe("basic existence tests", function() {
            it("should exist", function() {
              return expect(this.psppc).toBeDefined();
            });
            return it("should load a template", function() {
              return expect(this.psppc.$('.bv_dnsTargetListChkbx').length).toEqual(1);
            });
          });
          return describe("render existing parameters", function() {
            it("should have the select dns target list be checked", function() {
              return expect(this.psppc.$('.bv_dnsTargetListChkbx').attr("checked")).toEqual("checked");
            });
            it('should show the maxY', function() {
              return expect(this.psppc.$('.bv_maxY').val()).toEqual("200");
            });
            it('should show the minY', function() {
              return expect(this.psppc.$('.bv_minY').val()).toEqual("10");
            });
            return it('should show the assayStage', function() {
              waitsFor(function() {
                return this.psppc.$('.bv_assayStage option').length > 0;
              }, 1000);
              return runs(function() {
                return expect(this.psppc.$('.bv_assayStage').val()).toEqual("assay development");
              });
            });
          });
        });
      });
    });
    return describe("PrimaryScreenProtocolController", function() {
      beforeEach(function() {
        this.pspc = new PrimaryScreenProtocolController({
          model: new PrimaryScreenProtocol(window.primaryScreenProtocolTestJSON.fullSavedPrimaryScreenProtocol),
          el: $('#fixture')
        });
        return this.pspc.render();
      });
      return describe("when instantiated", function() {
        describe("basic existence tests", function() {
          it("should exist", function() {
            return expect(this.pspc).toBeDefined();
          });
          return it("should load a template", function() {
            expect(this.pspc.$('.bv_protocolBase').length).toEqual(1);
            return expect(this.pspc.$('.bv_assayActivity').length).toEqual(1);
          });
        });
        return describe("render existing parameters", function() {
          it('should show the assayActivity', function() {
            waitsFor(function() {
              return this.pspc.$('.bv_assayActivity option').length > 0;
            }, 1000);
            return runs(function() {
              expect(this.pspc.model.getPrimaryScreenProtocolParameterCodeValue('assay activity').get('codeValue')).toEqual("luminescence");
              return expect(this.pspc.$('.bv_assayActivity').val()).toEqual("luminescence");
            });
          });
          it('should show the molecularTarget', function() {
            waitsFor(function() {
              return this.pspc.$('.bv_molecularTarget option').length > 0;
            }, 1000);
            return runs(function() {
              expect(this.pspc.model.getPrimaryScreenProtocolParameterCodeValue('molecular target').get('codeValue')).toEqual("target x");
              return expect(this.pspc.$('.bv_molecularTarget').val()).toEqual("target x");
            });
          });
          it('should show the targetOrigin', function() {
            waitsFor(function() {
              return this.pspc.$('.bv_targetOrigin option').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.pspc.$('.bv_targetOrigin').val()).toEqual("human");
            });
          });
          it('should show the assayType', function() {
            waitsFor(function() {
              return this.pspc.$('.bv_assayType option').length > 0;
            }, 1000);
            return runs(function() {
              expect(this.pspc.model.getPrimaryScreenProtocolParameterCodeValue('assay type').get('codeValue')).toEqual("cellular assay");
              return expect(this.pspc.$('.bv_assayType').val()).toEqual("cellular assay");
            });
          });
          it('should show the assayTechnology', function() {
            waitsFor(function() {
              return this.pspc.$('.bv_assayTechnology option').length > 0;
            }, 1000);
            return runs(function() {
              expect(this.pspc.model.getPrimaryScreenProtocolParameterCodeValue('assay technology').get('codeValue')).toEqual("wizard triple luminescence");
              return expect(this.pspc.$('.bv_assayTechnology').val()).toEqual("wizard triple luminescence");
            });
          });
          it('should show the cellLine', function() {
            waitsFor(function() {
              return this.pspc.$('.bv_cellLine option').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.pspc.$('.bv_cellLine').val()).toEqual("cell line y");
            });
          });
          it('should show the assayStage', function() {
            waitsFor(function() {
              return this.pspc.$('.bv_assayStage option').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.pspc.$('.bv_assayStage').val()).toEqual("assay development");
            });
          });
          it("should update the curve display max", function() {
            this.pspc.$('.bv_maxY').val("130");
            this.pspc.$('.bv_maxY').change();
            return expect(this.pspc.model.getCurveDisplayMax().get('numericValue')).toEqual("130");
          });
          return it("should update the curve display min", function() {
            this.pspc.$('.bv_minY').val("13");
            this.pspc.$('.bv_minY').change();
            return expect(this.pspc.model.getCurveDisplayMin().get('numericValue')).toEqual("13");
          });
        });
      });
    });
  });

}).call(this);
