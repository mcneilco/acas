(function() {
  beforeEach(function() {
    return this.fixture = $.clone($("#fixture").get(0));
  });

  afterEach(function() {
    $("#fixture").remove();
    return $("body").append($(this.fixture));
  });

  describe("Experiment module testing", function() {
    describe("Experiment State model testing", function() {
      describe("when created empty", function() {
        beforeEach(function() {
          return this.es = new ExperimentState();
        });
        it("Class should exist", function() {
          return expect(this.es).toBeDefined();
        });
        return it("should have defaults", function() {
          return expect(this.es.get('lsValues') instanceof Backbone.Collection).toBeTruthy();
        });
      });
      return describe("When loaded from state json", function() {
        beforeEach(function() {
          return this.es = new ExperimentState(window.experimentServiceTestJSON.fullExperimentFromServer.lsStates[0]);
        });
        return describe("after initial load", function() {
          it("state should have kind ", function() {
            return expect(this.es.get('lsKind')).toEqual(window.experimentServiceTestJSON.fullExperimentFromServer.lsStates[0].lsKind);
          });
          it("state should have values", function() {
            return expect(this.es.get('lsValues').length).toEqual(window.experimentServiceTestJSON.fullExperimentFromServer.lsStates[0].lsValues.length);
          });
          it("state should have populated value", function() {
            return expect(this.es.get('lsValues').at(0).get('lsKind')).toEqual("notebook page");
          });
          it("should return requested value", function() {
            var values;
            console.log(this.es);
            values = this.es.getValuesByTypeAndKind("stringValue", "notebook");
            expect(values.length).toEqual(1);
            return expect(values[0].get('stringValue')).toEqual("911");
          });
          return it("should trigger change when value changed in state", function() {
            runs(function() {
              var _this = this;
              this.stateChanged = false;
              this.es.on('change', function() {
                return _this.stateChanged = true;
              });
              return this.es.get('lsValues').at(0).set({
                valueKind: 'newkind'
              });
            });
            waitsFor(function() {
              return this.stateChanged;
            }, 500);
            return runs(function() {
              return expect(this.stateChanged).toBeTruthy();
            });
          });
        });
      });
    });
    describe("Experiment State List model testing", function() {
      beforeEach(function() {
        return this.esl = new ExperimentStateList(window.experimentServiceTestJSON.fullExperimentFromServer.lsStates);
      });
      describe("after initial load", function() {
        it("Class should exist", function() {
          return expect(this.esl).toBeDefined();
        });
        it("should have states ", function() {
          return expect(this.esl.length).toEqual(window.experimentServiceTestJSON.fullExperimentFromServer.lsStates.length);
        });
        it("first state should have kind ", function() {
          return expect(this.esl.at(0).get('lsKind')).toEqual(window.experimentServiceTestJSON.fullExperimentFromServer.lsStates[0].lsKind);
        });
        it("states should have values", function() {
          return expect(this.esl.at(0).get('lsValues').length).toEqual(window.experimentServiceTestJSON.fullExperimentFromServer.lsStates[0].lsValues.length);
        });
        return it("first state should have populated value", function() {
          return expect(this.esl.at(0).get('lsValues').at(0).get('lsKind')).toEqual("notebook page");
        });
      });
      describe("Get states by type and kind", function() {
        return it("should return requested state", function() {
          var values;
          values = this.esl.getStatesByTypeAndKind("metadata", "experiment metadata");
          expect(values.length).toEqual(1);
          return expect(values[0].get('lsTypeAndKind')).toEqual("metadata_experiment metadata");
        });
      });
      return describe("Get value by type and kind", function() {
        return it("should return requested value", function() {
          var value;
          value = this.esl.getStateValueByTypeAndKind("metadata", "experiment metadata", "stringValue", "notebook");
          return expect(value.get('stringValue')).toEqual("911");
        });
      });
    });
    describe("Experiment model testing", function() {
      describe("When loaded from new", function() {
        beforeEach(function() {
          return this.exp = new Experiment();
        });
        return describe("Defaults", function() {
          it('Should have an empty label list', function() {
            expect(this.exp.get('lsLabels').length).toEqual(0);
            return expect(this.exp.get('lsLabels') instanceof LabelList).toBeTruthy();
          });
          it('Should have an empty state list', function() {
            expect(this.exp.get('lsStates').length).toEqual(0);
            return expect(this.exp.get('lsStates') instanceof ExperimentStateList).toBeTruthy();
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
      });
      describe("when loaded from existing", function() {
        beforeEach(function() {
          return this.exp = new Experiment(window.experimentServiceTestJSON.savedExperimentWithTreatmentGroup);
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
          it("should have the analysisGroupStates ", function() {
            return expect(this.exp.get('analysisGroups').at(0).get('analysisGroupStates') instanceof AnalysisGroupStateList).toBeTruthy();
          });
          it("should have the analysisGroupStates stateKind ", function() {
            console.log(this.exp.get('analysisGroups').at(0).get('analysisGroupStates'));
            return expect(this.exp.get('analysisGroups').at(0).get('analysisGroupStates').at(0).get('stateKind')).toEqual('Document for Batch');
          });
          it("should have the analysisGroupStates stateType", function() {
            return expect(this.exp.get('analysisGroups').at(0).get('analysisGroupStates').at(0).get('stateType')).toEqual('results');
          });
          it("should have the analysisGroupStates recordedBy", function() {
            return expect(this.exp.get('analysisGroups').at(0).get('analysisGroupStates').at(0).get('recordedBy')).toEqual('jmcneil');
          });
          it("should have the AnalysisGroupValues ", function() {
            return expect(this.exp.get('analysisGroups').at(0).get('analysisGroupStates').at(0).get('analysisGroupValues') instanceof AnalysisGroupValueList).toBeTruthy();
          });
          it("should have the AnalysisGroupValues array", function() {
            return expect(this.exp.get('analysisGroups').at(0).get('analysisGroupStates').at(0).get('analysisGroupValues').length).toEqual(3);
          });
          it("should have the AnalysisGroupValue ", function() {
            return expect(this.exp.get('analysisGroups').at(0).get('analysisGroupStates').at(0).get('analysisGroupValues').at(0) instanceof AnalysisGroupValue).toBeTruthy();
          });
          it("should have the AnalysisGroupValue valueKind ", function() {
            return expect(this.exp.get('analysisGroups').at(0).get('analysisGroupStates').at(0).get('analysisGroupValues').at(0).get('valueKind')).toEqual("annotation");
          });
          it("should have the AnalysisGroupValue valueType", function() {
            return expect(this.exp.get('analysisGroups').at(0).get('analysisGroupStates').at(0).get('analysisGroupValues').at(0).get('valueType')).toEqual("fileValue");
          });
          it("should have the AnalysisGroupValue value", function() {
            return expect(this.exp.get('analysisGroups').at(0).get('analysisGroupStates').at(1).get('analysisGroupValues').at(0).get('value')).toEqual("");
          });
          it("should have the AnalysisGroupValue comment", function() {
            return expect(this.exp.get('analysisGroups').at(0).get('analysisGroupStates').at(0).get('analysisGroupValues').at(0).get('comments')).toEqual("ok");
          });
          it("should have the analysisGroup id ", function() {
            return expect(this.exp.get('analysisGroups').at(0).id).toEqual(64782);
          });
          it("should have a code ", function() {
            return expect(this.exp.get('codeName')).toEqual("EXPT-00000222");
          });
          it("should have the shortDescription set", function() {
            return expect(this.exp.get('shortDescription')).toEqual(window.experimentServiceTestJSON.savedExperimentWithTreatmentGroup.shortDescription);
          });
          it("should have labels", function() {
            return expect(this.exp.get('lsLabels').length).toEqual(window.experimentServiceTestJSON.savedExperimentWithTreatmentGroup.lsLabels.length);
          });
          return it("should have labels", function() {
            console.log(this.exp);
            return expect(this.exp.get('lsLabels').at(0).get('labelKind')).toEqual("experiment name");
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
          return it("should have the states copied", function() {
            console.log(this.exp);
            return expect(this.exp.get('lsStates').length).toEqual(window.protocolServiceTestJSON.fullSavedProtocol.lsStates.length);
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
        return it("should be invalid when scientist not selected", function() {
          var filtErrors;
          this.exp.set({
            recordedBy: ""
          });
          expect(this.exp.isValid()).toBeFalsy();
          return filtErrors = _.filter(this.exp.validationError, function(err) {
            return err.attribute === 'recordedBy';
          });
        });
      });
      /* hello		expect(filtErrors.length).toBeGreaterThan 0
      			it "should be invalid when protocol not selected", ->
      				@exp.set protocol: null
      				expect(@exp.isValid()).toBeFalsy()
      				filtErrors = _.filter(@exp.validationError, (err) ->
      					err.attribute=='protocol'
      				)
      				expect(filtErrors.length).toBeGreaterThan 0
      */

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
            expect(this.exp.get('lsStates') instanceof ExperimentStateList).toBeTruthy();
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
    return describe("ExperimentBaseController testing", function() {
      describe("When created with an unsaved experiment that has protocol attributes copied in", function() {
        beforeEach(function() {
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
            return expect(this.copied).toBeTruthy();
          });
        });
        describe("populated fields", function() {
          it("should show the protocol code", function() {
            return expect(this.ebc.$('.bv_protocolCode').val()).toEqual("PROT-00000001");
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
          return expect(this.ebc.$('.bv_protocolCode').val()).toEqual("PROT-00000001");
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
          return expect(this.ebc.$('.bv_description').html()).toEqual("");
        });
        xit("should fill the name field", function() {
          return expect(this.ebc.$('.bv_experimentName').val()).toEqual("FLIPR target A biochemical");
        });
        it("should fill the date field", function() {
          return expect(this.ebc.$('.bv_recordedDate').val()).toEqual("2013-7-7");
        });
        it("should fill the user field", function() {
          console.log(this.ebc);
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
            return expect(this.ebc.$('.bv_protocolCode').val()).toEqual("");
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
          return describe("when scientist not selected", function() {
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
        });
        /*
        					describe "when protocol not selected", -> #this is not working properly - Fiona
        					beforeEach ->
        						runs ->
        							@ebc.$('.bv_protocolCode').val(null)
        							@ebc.$('.bv_protocolCode').change()
        							console.log @ebc.model.isValid()
        					it "should show error on protocol dropdown", ->
        						runs ->
        							expect(@ebc.$('.bv_group_protocol').hasClass('error')).toBeTruthy()
        */

      });
    });
  });

}).call(this);
