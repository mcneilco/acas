(function() {
  beforeEach(function() {
    return this.fixture = $.clone($("#fixture").get(0));
  });

  afterEach(function() {
    $("#fixture").remove();
    return $("body").append($(this.fixture));
  });

  describe("Experiment module testing", function() {
    describe("Experiment model testing", function() {
      describe("When loaded from new", function() {
        beforeEach(function() {
          return this.exp = new Experiment();
        });
        describe("Defaults", function() {
          it('Should have default type and kind', function() {
            expect(this.exp.get('lsType')).toEqual("default");
            return expect(this.exp.get('lsKind')).toEqual("default");
          });
          it('Should have an empty label list', function() {
            expect(this.exp.get('lsLabels').length).toEqual(0);
            return expect(this.exp.get('lsLabels') instanceof LabelList).toBeTruthy();
          });
          it('Should have an empty state list', function() {
            expect(this.exp.get('lsStates').length).toEqual(0);
            return expect(this.exp.get('lsStates') instanceof StateList).toBeTruthy();
          });
          it('Should have an empty scientist', function() {
            return expect(this.exp.get('recordedBy')).toEqual("");
          });
          it('Should have an empty recordedDate', function() {
            return expect(this.exp.get('recordedDate')).toBeNull();
          });
          it('Should have an empty short description', function() {
            return expect(this.exp.get('shortDescription')).toEqual("");
          });
          it('Should have no protocol', function() {
            return expect(this.exp.get('protocol')).toBeNull();
          });
          return it('Should have an empty analysisGroups', function() {
            return expect(this.exp.get('analysisGroups') instanceof AnalysisGroupList).toBeTruthy();
          });
        });
        return describe("required states and values", function() {
          return it('Should have a description value', function() {
            return expect(this.exp.getDescription() instanceof Value).toBeTruthy();
          });
        });
      });
      describe("when loaded from existing", function() {
        beforeEach(function() {
          return this.exp = new Experiment(window.experimentServiceTestJSON.savedExperimentWithAnalysisGroups);
        });
        return describe("after initial load", function() {
          it("should have a kind", function() {
            return expect(this.exp.get('kind')).toEqual("ACAS doc for batches");
          });
          it("should have the protocol set ", function() {
            return expect(this.exp.get('protocol').id).toEqual(2403);
          });
          it("should have the analysisGroups set ", function() {
            return expect(this.exp.get('analysisGroups').length).toEqual(1);
          });
          it("should have the analysisGroup List", function() {
            return expect(this.exp.get('analysisGroups') instanceof AnalysisGroupList).toBeTruthy();
          });
          it("should have the analysisGroup ", function() {
            return expect(this.exp.get('analysisGroups').at(0) instanceof AnalysisGroup).toBeTruthy();
          });
          it("should have the states ", function() {
            return expect(this.exp.get('analysisGroups').at(0).get('lsStates') instanceof StateList).toBeTruthy();
          });
          it("should have the states lsKind ", function() {
            return expect(this.exp.get('analysisGroups').at(0).get('lsStates').at(0).get('lsKind')).toEqual('Document for Batch');
          });
          it("should have the states lsType", function() {
            return expect(this.exp.get('analysisGroups').at(0).get('lsStates').at(0).get('lsType')).toEqual('results');
          });
          it("should have the states recordedBy", function() {
            return expect(this.exp.get('analysisGroups').at(0).get('lsStates').at(0).get('recordedBy')).toEqual('jmcneil');
          });
          it("should have the AnalysisGroupValues ", function() {
            return expect(this.exp.get('analysisGroups').at(0).get('lsStates').at(0).get('lsValues') instanceof ValueList).toBeTruthy();
          });
          it("should have the AnalysisGroupValues array", function() {
            return expect(this.exp.get('analysisGroups').at(0).get('lsStates').at(0).get('lsValues').length).toEqual(3);
          });
          it("should have the AnalysisGroupValue ", function() {
            return expect(this.exp.get('analysisGroups').at(0).get('lsStates').at(0).get('lsValues').at(0) instanceof Value).toBeTruthy();
          });
          it("should have the AnalysisGroupValue valueKind ", function() {
            return expect(this.exp.get('analysisGroups').at(0).get('lsStates').at(0).get('lsValues').at(0).get('lsKind')).toEqual("annotation");
          });
          it("should have the AnalysisGroupValue valueType", function() {
            return expect(this.exp.get('analysisGroups').at(0).get('lsStates').at(0).get('lsValues').at(0).get('lsType')).toEqual("fileValue");
          });
          it("should have the AnalysisGroupValue value", function() {
            return expect(this.exp.get('analysisGroups').at(0).get('lsStates').at(0).get('lsValues').at(0).get('fileValue')).toEqual("exampleUploadedFile.txt");
          });
          it("should have the AnalysisGroupValue comment", function() {
            return expect(this.exp.get('analysisGroups').at(0).get('lsStates').at(0).get('lsValues').at(0).get('comments')).toEqual("ok");
          });
          it("should have the analysisGroup id ", function() {
            return expect(this.exp.get('analysisGroups').at(0).id).toEqual(64782);
          });
          it("should have a code ", function() {
            return expect(this.exp.get('codeName')).toEqual("EXPT-00000222");
          });
          it("should have the shortDescription set", function() {
            return expect(this.exp.get('shortDescription')).toEqual(window.experimentServiceTestJSON.savedExperimentWithAnalysisGroups.shortDescription);
          });
          it("should have labels", function() {
            return expect(this.exp.get('lsLabels').length).toEqual(window.experimentServiceTestJSON.savedExperimentWithAnalysisGroups.lsLabels.length);
          });
          it("should have labels", function() {
            return expect(this.exp.get('lsLabels').at(0).get('lsKind')).toEqual("experiment name");
          });
          return it('Should have a description value', function() {
            return expect(this.exp.getDescription().get('stringValue')).toEqual("long description goes here");
          });
        });
      });
      describe("when created from template protocol", function() {
        beforeEach(function() {
          this.exp = new Experiment();
          return this.exp.copyProtocolAttributes(new Protocol(window.protocolServiceTestJSON.fullSavedProtocol));
        });
        return describe("after initial load", function() {
          it("Class should exist", function() {
            return expect(this.exp).toBeDefined();
          });
          it("should have same kind as protocol", function() {
            return expect(this.exp.get('kind')).toEqual(window.protocolServiceTestJSON.fullSavedProtocol.lsKind);
          });
          it("should have the protocol set ", function() {
            return expect(this.exp.get('protocol').get('codeName')).toEqual("PROT-00000001");
          });
          it("should have the shortDescription set to the protocols short description", function() {
            return expect(this.exp.get('shortDescription')).toEqual(window.protocolServiceTestJSON.fullSavedProtocol.shortDescription);
          });
          it("should have the description set to the protocols description", function() {
            return expect(this.exp.get('description')).toEqual(window.protocolServiceTestJSON.fullSavedProtocol.description);
          });
          it("should not have the labels copied", function() {
            return expect(this.exp.get('lsLabels').length).toEqual(0);
          });
          it("should have the states copied", function() {
            return expect(this.exp.get('lsStates').length).toEqual(window.protocolServiceTestJSON.fullSavedProtocol.lsStates.length);
          });
          return it('Should have a description value', function() {
            return expect(this.exp.getDescription().get('stringValue')).toEqual("long description goes here");
          });
        });
      });
      describe("model change propogation", function() {
        it("should trigger change when label changed", function() {
          runs(function() {
            var _this = this;

            this.exp = new Experiment();
            this.experimentChanged = false;
            this.exp.get('lsLabels').setBestName(new Label({
              labelKind: "experiment name",
              labelText: "test label",
              recordedBy: this.exp.get('recordedBy'),
              recordedDate: this.exp.get('recordedDate')
            }));
            this.exp.on('change', function() {
              return _this.experimentChanged = true;
            });
            this.experimentChanged = false;
            return this.exp.get('lsLabels').setBestName(new Label({
              labelKind: "experiment name",
              labelText: "new label",
              recordedBy: this.exp.get('recordedBy'),
              recordedDate: this.exp.get('recordedDate')
            }));
          });
          waitsFor(function() {
            return this.experimentChanged;
          }, 500);
          return runs(function() {
            return expect(this.experimentChanged).toBeTruthy();
          });
        });
        return it("should trigger change when value changed in state", function() {
          runs(function() {
            var _this = this;

            this.exp = new Experiment(window.experimentServiceTestJSON.fullExperimentFromServer);
            this.experimentChanged = false;
            this.exp.on('change', function() {
              return _this.experimentChanged = true;
            });
            return this.exp.get('lsStates').at(0).get('lsValues').at(0).set({
              lsKind: 'fred'
            });
          });
          waitsFor(function() {
            return this.experimentChanged;
          }, 500);
          return runs(function() {
            return expect(this.experimentChanged).toBeTruthy();
          });
        });
      });
      describe("model validation", function() {
        beforeEach(function() {
          return this.exp = new Experiment(window.experimentServiceTestJSON.fullExperimentFromServer);
        });
        it("should be valid when loaded from saved", function() {
          return expect(this.exp.isValid()).toBeTruthy();
        });
        it("should be invalid when name is empty", function() {
          var filtErrors;

          this.exp.get('lsLabels').setBestName(new Label({
            labelKind: "experiment name",
            labelText: "",
            recordedBy: this.exp.get('recordedBy'),
            recordedDate: this.exp.get('recordedDate')
          }));
          expect(this.exp.isValid()).toBeFalsy();
          filtErrors = _.filter(this.exp.validationError, function(err) {
            return err.attribute === 'experimentName';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it("should be invalid when date is empty", function() {
          var filtErrors;

          this.exp.set({
            recordedDate: new Date("").getTime()
          });
          expect(this.exp.isValid()).toBeFalsy();
          filtErrors = _.filter(this.exp.validationError, function(err) {
            return err.attribute === 'recordedDate';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it("should be invalid when scientist not selected", function() {
          var filtErrors;

          this.exp.set({
            recordedBy: ""
          });
          expect(this.exp.isValid()).toBeFalsy();
          return filtErrors = _.filter(this.exp.validationError, function(err) {
            return err.attribute === 'recordedBy';
          });
        });
        return it("should be invalid when protocol not selected", function() {
          var filtErrors;

          this.exp.set({
            protocol: null
          });
          expect(this.exp.isValid()).toBeFalsy();
          filtErrors = _.filter(this.exp.validationError, function(err) {
            return err.attribute === 'protocol';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
      });
      return describe("model composite component conversion", function() {
        beforeEach(function() {
          runs(function() {
            var _this = this;

            this.saveSucessful = false;
            this.saveComplete = false;
            this.exp = new Experiment({
              id: 1
            });
            this.exp.on('sync', function() {
              _this.saveSucessful = true;
              return _this.saveComplete = true;
            });
            this.exp.on('invalid', function() {
              return _this.saveComplete = true;
            });
            return this.exp.fetch();
          });
          return waitsFor(function() {
            return this.saveComplete === true;
          }, 500);
        });
        it("should return from sync, not invalid", function() {
          return runs(function() {
            return expect(this.saveSucessful).toBeTruthy();
          });
        });
        it("should convert labels array to label list", function() {
          return runs(function() {
            expect(this.exp.get('lsLabels') instanceof LabelList).toBeTruthy();
            return expect(this.exp.get('lsLabels').length).toBeGreaterThan(0);
          });
        });
        it("should convert state array to state list", function() {
          return runs(function() {
            expect(this.exp.get('lsStates') instanceof StateList).toBeTruthy();
            return expect(this.exp.get('lsStates').length).toBeGreaterThan(0);
          });
        });
        return it("should convert protocol has to Protocol", function() {
          return runs(function() {
            return expect(this.exp.get('protocol') instanceof Protocol).toBeTruthy();
          });
        });
      });
    });
    describe("Experiment List testing", function() {
      beforeEach(function() {
        return this.el = new ExperimentList();
      });
      return describe("existance tests", function() {
        return it("should be defined", function() {
          return expect(ExperimentList).toBeDefined();
        });
      });
    });
    return describe("ExperimentBaseController testing", function() {
      describe("When created with an unsaved experiment that has protocol attributes copied in", function() {
        beforeEach(function() {
          return runs(function() {
            var _this = this;

            this.copied = false;
            this.exp = new Experiment();
            this.exp.on("protocol_attributes_copied", function() {
              return _this.copied = true;
            });
            this.exp.copyProtocolAttributes(new Protocol(window.protocolServiceTestJSON.fullSavedProtocol));
            this.ebc = new ExperimentBaseController({
              model: this.exp,
              el: $('#fixture')
            });
            return this.ebc.render();
          });
        });
        describe("Basic loading", function() {
          it("Class should exist", function() {
            return expect(this.ebc).toBeDefined();
          });
          it("Should load the template", function() {
            return expect(this.ebc.$('.bv_experimentCode').html()).toEqual("autofill when saved");
          });
          return it("should trigger copy complete", function() {
            waitsFor(function() {
              return this.copied;
            }, 500);
            return runs(function() {
              return expect(this.copied).toBeTruthy();
            });
          });
        });
        describe("populated fields", function() {
          it("should show the protocol code", function() {
            waitsFor(function() {
              return this.ebc.$('.bv_protocolCode option').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.ebc.$('.bv_protocolCode').val()).toEqual("PROT-00000001");
            });
          });
          it("should show the protocol name", function() {
            return expect(this.ebc.$('.bv_protocolName').html()).toEqual("FLIPR target A biochemical");
          });
          return it("should fill the short description field", function() {
            return expect(this.ebc.$('.bv_shortDescription').html()).toEqual("primary analysis");
          });
        });
        return describe("User edits fields", function() {
          it("should update model when scientist is changed", function() {
            expect(this.ebc.model.get('recordedBy')).toEqual("");
            this.ebc.$('.bv_recordedBy').val("jmcneil");
            this.ebc.$('.bv_recordedBy').change();
            return expect(this.ebc.model.get('recordedBy')).toEqual("jmcneil");
          });
          it("should update model when shortDescription is changed", function() {
            this.ebc.$('.bv_shortDescription').val(" New short description   ");
            this.ebc.$('.bv_shortDescription').change();
            return expect(this.ebc.model.get('shortDescription')).toEqual("New short description");
          });
          it("should update model when description is changed", function() {
            var desc, states, values;

            this.ebc.$('.bv_description').val(" New long description   ");
            this.ebc.$('.bv_description').change();
            states = this.ebc.model.get('lsStates').getStatesByTypeAndKind("metadata", "experiment metadata");
            expect(states.length).toEqual(1);
            values = states[0].getValuesByTypeAndKind("stringValue", "description");
            desc = values[0].get('stringValue');
            expect(desc).toEqual("New long description");
            return expect(this.ebc.model.getDescription().get('stringValue')).toEqual("New long description");
          });
          it("should update model when name is changed", function() {
            this.ebc.$('.bv_experimentName').val(" Updated experiment name   ");
            this.ebc.$('.bv_experimentName').change();
            return expect(this.ebc.model.get('lsLabels').pickBestLabel().get('labelText')).toEqual("Updated experiment name");
          });
          return it("should update model when recorded date is changed", function() {
            this.ebc.$('.bv_recordedDate').val(" 2013-3-16   ");
            this.ebc.$('.bv_recordedDate').change();
            return expect(this.ebc.model.get('recordedDate')).toEqual(new Date(2013, 2, 16).getTime());
          });
        });
      });
      describe("When created from a saved experiment", function() {
        beforeEach(function() {
          this.exp2 = new Experiment(window.experimentServiceTestJSON.fullExperimentFromServer);
          this.ebc = new ExperimentBaseController({
            model: this.exp2,
            el: $('#fixture')
          });
          return this.ebc.render();
        });
        it("should show the protocol code", function() {
          waitsFor(function() {
            return this.ebc.$('.bv_protocolCode option').length > 0;
          }, 1000);
          return runs(function() {
            return expect(this.ebc.$('.bv_protocolCode').val()).toEqual("PROT-00000001");
          });
        });
        it("should show the protocol name", function() {
          waits(200);
          return runs(function() {
            return expect(this.ebc.$('.bv_protocolName').html()).toEqual("FLIPR target A biochemical");
          });
        });
        it("should have use protocol parameters disabled", function() {
          return expect(this.ebc.$('.bv_useProtocolParameters').attr("disabled")).toEqual("disabled");
        });
        it("should fill the short description field", function() {
          return expect(this.ebc.$('.bv_shortDescription').html()).toEqual("experiment created by generic data parser");
        });
        it("should fill the long description field", function() {
          return expect(this.ebc.$('.bv_description').html()).toEqual("long description goes here");
        });
        xit("should fill the name field", function() {
          return expect(this.ebc.$('.bv_experimentName').val()).toEqual("FLIPR target A biochemical");
        });
        it("should fill the date field", function() {
          return expect(this.ebc.$('.bv_recordedDate').val()).toEqual("2013-7-7");
        });
        it("should fill the user field", function() {
          return expect(this.ebc.$('.bv_recordedBy').val()).toEqual("smeyer");
        });
        return it("should fill the code field", function() {
          return expect(this.ebc.$('.bv_experimentCode').html()).toEqual("EXPT-00000001");
        });
      });
      return describe("When created from a new experiment", function() {
        beforeEach(function() {
          this.exp0 = new Experiment();
          this.ebc = new ExperimentBaseController({
            model: this.exp0,
            el: $('#fixture')
          });
          return this.ebc.render();
        });
        describe("basic startup conditions", function() {
          it("should have protocol code not set", function() {
            waitsFor(function() {
              return this.ebc.$('.bv_protocolCode option').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.ebc.$('.bv_protocolCode').val()).toEqual("unassigned");
            });
          });
          it("should have use protocol parameters disabled", function() {
            return expect(this.ebc.$('.bv_useProtocolParameters').attr("disabled")).toEqual("disabled");
          });
          return it("should fill the date field", function() {
            return expect(this.ebc.$('.bv_recordedDate').val()).toEqual("");
          });
        });
        describe("when user picks protocol ", function() {
          beforeEach(function() {
            return runs(function() {
              this.ebc.$('.bv_protocolCode').val("PROT-00000001");
              return this.ebc.$('.bv_protocolCode').change();
            });
          });
          describe("When user picks protocol", function() {
            it("should update model", function() {
              waits(200);
              return runs(function() {
                return expect(this.ebc.model.get('protocol').get('codeName')).toEqual("PROT-00000001");
              });
            });
            it("should enable use protocol params", function() {
              waits(200);
              return runs(function() {
                return expect(this.ebc.$('.bv_useProtocolParameters').attr("disabled")).toBeUndefined();
              });
            });
            return it("should show the protocol name", function() {
              waits(200);
              return runs(function() {
                return expect(this.ebc.$('.bv_protocolName').html()).toEqual("FLIPR target A biochemical");
              });
            });
          });
          return describe("When user and asks to clone attributes should populate fields", function() {
            beforeEach(function() {
              waits(200);
              return runs(function() {
                return this.ebc.$('.bv_useProtocolParameters').click();
              });
            });
            return it("should fill the short description field", function() {
              waits(200);
              return runs(function() {
                return expect(this.ebc.$('.bv_shortDescription').html()).toEqual("primary analysis");
              });
            });
          });
        });
        return describe("controller validation rules", function() {
          beforeEach(function() {
            runs(function() {
              this.ebc.$('.bv_recordedBy').val("jmcneil");
              this.ebc.$('.bv_recordedBy').change();
              this.ebc.$('.bv_recordedDate').val(" 2013-3-16   ");
              this.ebc.$('.bv_recordedDate').change();
              this.ebc.$('.bv_shortDescription').val(" New short description   ");
              this.ebc.$('.bv_shortDescription').change();
              this.ebc.$('.bv_protocolCode').val("PROT-00000001");
              this.ebc.$('.bv_protocolCode').change();
              this.ebc.$('.bv_experimentName').val(" Updated experiment name   ");
              return this.ebc.$('.bv_experimentName').change();
            });
            waits(200);
            runs(function() {
              return this.ebc.$('.bv_useProtocolParameters').click();
            });
            return waits(200);
          });
          it("should be valid if form fully filled out", function() {
            return runs(function() {
              return expect(this.ebc.isValid()).toBeTruthy();
            });
          });
          describe("when name field not filled in", function() {
            beforeEach(function() {
              return runs(function() {
                this.ebc.$('.bv_experimentName').val("");
                return this.ebc.$('.bv_experimentName').change();
              });
            });
            it("should be invalid if experiment name not filled in", function() {
              return runs(function() {
                return expect(this.ebc.isValid()).toBeFalsy();
              });
            });
            return it("should show error in name field", function() {
              return runs(function() {
                return expect(this.ebc.$('.bv_group_experimentName').hasClass('error')).toBeTruthy();
              });
            });
          });
          describe("when date field not filled in", function() {
            beforeEach(function() {
              return runs(function() {
                this.ebc.$('.bv_recordedDate').val("");
                return this.ebc.$('.bv_recordedDate').change();
              });
            });
            return it("should show error in date field", function() {
              return runs(function() {
                return expect(this.ebc.$('.bv_group_recordedDate').hasClass('error')).toBeTruthy();
              });
            });
          });
          describe("when scientist not selected", function() {
            beforeEach(function() {
              return runs(function() {
                this.ebc.$('.bv_recordedBy').val("");
                return this.ebc.$('.bv_recordedBy').change();
              });
            });
            return it("should show error on scientist dropdown", function() {
              return runs(function() {
                return expect(this.ebc.$('.bv_group_recordedBy').hasClass('error')).toBeTruthy();
              });
            });
          });
          return describe("when protocol not selected", function() {
            beforeEach(function() {
              return runs(function() {
                this.ebc.$('.bv_protocolCode').val("unassigned");
                return this.ebc.$('.bv_protocolCode').change();
              });
            });
            return it("should show error on protocol dropdown", function() {
              return runs(function() {
                return expect(this.ebc.$('.bv_group_protocol').hasClass('error')).toBeTruthy();
              });
            });
          });
        });
      });
    });
  });

}).call(this);
