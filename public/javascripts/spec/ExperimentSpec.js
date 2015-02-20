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
            console.log(this.exp.get('lsLabels'));
            expect(this.exp.get('lsLabels').length).toEqual(0);
            return expect(this.exp.get('lsLabels') instanceof LabelList).toBeTruthy();
          });
          it('Should have an empty tags list', function() {
            expect(this.exp.get('lsTags').length).toEqual(0);
            return expect(this.exp.get('lsTags') instanceof Backbone.Collection).toBeTruthy();
          });
          it('Should have an empty state list', function() {
            expect(this.exp.get('lsStates').length).toEqual(0);
            return expect(this.exp.get('lsStates') instanceof StateList).toBeTruthy();
          });
          it('Should have an empty scientist', function() {
            return expect(this.exp.getScientist().get('codeValue')).toEqual("unassigned");
          });
          it('Should have the recordedBy set to the loginUser username', function() {
            return expect(this.exp.get('recordedBy')).toEqual("jmcneil");
          });
          it('Should have an recordedDate set to now', function() {
            return expect(new Date(this.exp.get('recordedDate')).getHours()).toEqual(new Date().getHours());
          });
          it('Should have an empty short description with a space as an oracle work-around', function() {
            return expect(this.exp.get('shortDescription')).toEqual(" ");
          });
          it('Should have no protocol', function() {
            return expect(this.exp.get('protocol')).toBeNull();
          });
          return it('Should have an empty analysisGroups', function() {
            return expect(this.exp.get('analysisGroups') instanceof AnalysisGroupList).toBeTruthy();
          });
        });
        describe("required states and values", function() {
          it('Should have a experimentDetails value', function() {
            expect(this.exp.getDetails() instanceof Value).toBeTruthy();
            return expect(this.exp.getDetails().get('clobValue')).toEqual("");
          });
          it('Should have a comments value', function() {
            expect(this.exp.getComments() instanceof Value).toBeTruthy();
            return expect(this.exp.getComments().get('clobValue')).toEqual("");
          });
          it('Should have a notebook value', function() {
            return expect(this.exp.getNotebook() instanceof Value).toBeTruthy();
          });
          it('Should have a project value', function() {
            return expect(this.exp.getProjectCode() instanceof Value).toBeTruthy();
          });
          it('Project code should default to unassigned and have a default code type, kind, and origin', function() {
            expect(this.exp.getProjectCode().get('codeValue')).toEqual("unassigned");
            expect(this.exp.getProjectCode().get('codeType')).toEqual("project");
            expect(this.exp.getProjectCode().get('codeKind')).toEqual("biology");
            return expect(this.exp.getProjectCode().get('codeOrigin')).toEqual("ACAS DDICT");
          });
          it('Experiment status should default to created and have default code type, kind, and origin ', function() {
            expect(this.exp.getStatus().get('codeValue')).toEqual("created");
            expect(this.exp.getStatus().get('codeType')).toEqual("experiment");
            expect(this.exp.getStatus().get('codeKind')).toEqual("status");
            return expect(this.exp.getStatus().get('codeOrigin')).toEqual("ACAS DDICT");
          });
          return it('completionDate should be null ', function() {
            return expect(this.exp.getCompletionDate().get('dateValue')).toEqual(null);
          });
        });
        return describe("other features", function() {
          return describe("should tell you if it is editable based on status", function() {
            it("should be locked if status is New", function() {
              this.exp.getStatus().set({
                codeValue: "New"
              });
              return expect(this.exp.isEditable()).toBeTruthy();
            });
            it("should be locked if status is started", function() {
              this.exp.getStatus().set({
                codeValue: "started"
              });
              return expect(this.exp.isEditable()).toBeTruthy();
            });
            it("should be locked if status is complete", function() {
              this.exp.getStatus().set({
                codeValue: "complete"
              });
              return expect(this.exp.isEditable()).toBeTruthy();
            });
            it("should be locked if status is finalized", function() {
              this.exp.getStatus().set({
                codeValue: "finalized"
              });
              return expect(this.exp.isEditable()).toBeFalsy();
            });
            return it("should be locked if status is rejected", function() {
              this.exp.getStatus().set({
                codeValue: "rejected"
              });
              return expect(this.exp.isEditable()).toBeFalsy();
            });
          });
        });
      });
      describe("when loaded from existing", function() {
        beforeEach(function() {
          return this.exp = new Experiment(window.experimentServiceTestJSON.savedExperimentWithAnalysisGroups);
        });
        return describe("after initial load", function() {
          it("should have a kind", function() {
            return expect(this.exp.get('lsKind')).toEqual("ACAS doc for batches");
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
          it('Should have an experimentDetails value', function() {
            return expect(this.exp.getDetails().get('clobValue')).toEqual("experiment details go here");
          });
          it('Should have a comments value', function() {
            return expect(this.exp.getComments().get('clobValue')).toEqual("comments go here");
          });
          it('Should have a notebook value', function() {
            return expect(this.exp.getNotebook().get('stringValue')).toEqual("911");
          });
          it('Should have a project value', function() {
            return expect(this.exp.getProjectCode().get('codeValue')).toEqual("project1");
          });
          it('Should have a scientist value', function() {
            return expect(this.exp.getScientist().get('codeValue')).toEqual("jane");
          });
          it('Should have a completionDate value', function() {
            return expect(this.exp.getCompletionDate().get('dateValue')).toEqual(1342080000000);
          });
          return it('Should have a status value', function() {
            return expect(this.exp.getStatus().get('codeValue')).toEqual("started");
          });
        });
      });
      describe("when created from template protocol", function() {
        beforeEach(function() {
          this.exp = new Experiment();
          this.exp.getNotebook().set({
            stringValue: "spec test NB"
          });
          this.exp.getCompletionDate().set({
            dateValue: 2000000000000
          });
          this.exp.getProjectCode().set({
            codeValue: "project45"
          });
          return this.exp.copyProtocolAttributes(new Protocol(window.protocolServiceTestJSON.fullSavedProtocol));
        });
        return describe("after initial load", function() {
          it("Class should exist", function() {
            return expect(this.exp).toBeDefined();
          });
          it("should have same kind as protocol", function() {
            return expect(this.exp.get('lsKind')).toEqual(window.protocolServiceTestJSON.fullSavedProtocol.lsKind);
          });
          it("should have the protocol set ", function() {
            return expect(this.exp.get('protocol').get('codeName')).toEqual("PROT-00000001");
          });
          it("should have the shortDescription be an empty string", function() {
            return expect(this.exp.get('shortDescription')).toEqual(" ");
          });
          it("should have the description be an empty string", function() {
            return expect(this.exp.getDetails().get('clobValue')).toEqual("");
          });
          it("should have the comments be an empty string", function() {
            return expect(this.exp.getComments().get('clobValue')).toEqual("");
          });
          it("should not have the labels copied", function() {
            return expect(this.exp.get('lsLabels').length).toEqual(0);
          });
          it("should have the experiment metadata state", function() {
            var filtState;
            filtState = this.exp.get('lsStates').filter(function(state) {
              return state.get('lsKind') === 'experiment metadata';
            });
            return expect(filtState.length).toBeGreaterThan(0);
          });
          it("should not have the protocol metadata state nor the screening assay state", function() {
            var filtState;
            filtState = this.exp.get('lsStates').filter(function(state) {
              return state.get('lsKind') === 'protocol metadata';
            });
            return expect(filtState.length).toEqual(0);
          });
          it("should not have the screening assay state", function() {
            var filtState;
            filtState = this.exp.get('lsStates').filter(function(state) {
              return state.get('lsKind') === 'screening assay';
            });
            return expect(filtState.length).toEqual(0);
          });
          it('Should not override set notebook value', function() {
            return expect(this.exp.getNotebook().get('stringValue')).toEqual("spec test NB");
          });
          it('Should not override completionDate value', function() {
            return expect(this.exp.getCompletionDate().get('dateValue')).toEqual(2000000000000);
          });
          it('Should not override projectCode value', function() {
            return expect(this.exp.getProjectCode().get('codeValue')).toEqual("project45");
          });
          it('Should not have a tags', function() {
            return expect(this.exp.get('lsTags').length).toEqual(0);
          });
          return it('Should have a status value of created', function() {
            return expect(this.exp.getStatus().get('codeValue')).toEqual("created");
          });
        });
      });
      describe("model change propogation", function() {
        it("should trigger change when label changed", function() {
          runs(function() {
            this.exp = new Experiment();
            this.experimentChanged = false;
            this.exp.get('lsLabels').setBestName(new Label({
              labelKind: "experiment name",
              labelText: "test label",
              recordedBy: this.exp.get('recordedBy'),
              recordedDate: this.exp.get('recordedDate')
            }));
            this.exp.on('change', (function(_this) {
              return function() {
                return _this.experimentChanged = true;
              };
            })(this));
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
            this.exp = new Experiment(window.experimentServiceTestJSON.fullExperimentFromServer);
            this.experimentChanged = false;
            this.exp.on('change', (function(_this) {
              return function() {
                return _this.experimentChanged = true;
              };
            })(this));
            return this.exp.get('lsStates').at(0).get('lsValues').at(0).set({
              codeValue: 'fred'
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
          this.exp.getScientist().set({
            codeValue: "unassigned"
          });
          expect(this.exp.isValid()).toBeFalsy();
          return filtErrors = _.filter(this.exp.validationError, function(err) {
            return err.attribute === 'scientist';
          });
        });
        it("should be invalid when protocol not selected", function() {
          var filtErrors;
          this.exp.set({
            protocol: null
          });
          expect(this.exp.isValid()).toBeFalsy();
          filtErrors = _.filter(this.exp.validationError, function(err) {
            return err.attribute === 'protocolCode';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it("should be invalid when notebook is empty", function() {
          var filtErrors;
          this.exp.getNotebook().set({
            stringValue: ""
          });
          expect(this.exp.isValid()).toBeFalsy();
          filtErrors = _.filter(this.exp.validationError, function(err) {
            return err.attribute === 'notebook';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it("should be invalid when projectCode is unassigned", function() {
          var filtErrors;
          this.exp.getProjectCode().set({
            codeValue: "unassigned"
          });
          expect(this.exp.isValid()).toBeFalsy();
          filtErrors = _.filter(this.exp.validationError, function(err) {
            return err.attribute === 'projectCode';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        return it('should require that completionDate not be ""', function() {
          var filtErrors;
          this.exp.getCompletionDate().set({
            dateValue: new Date("").getTime()
          });
          expect(this.exp.isValid()).toBeFalsy();
          filtErrors = _.filter(this.exp.validationError, function(err) {
            return err.attribute === 'completionDate';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
      });
      describe("prepare to save", function() {
        beforeEach(function() {
          this.exp = new Experiment();
          this.exp.set({
            recordedBy: "jmcneil"
          });
          return this.exp.set({
            recordedDate: -1
          });
        });
        afterEach(function() {
          this.exp.get('lsLabels').reset();
          return this.exp.get('lsStates').reset();
        });
        it("should set experiment's set to now", function() {
          this.exp.prepareToSave();
          return expect(new Date(this.exp.get('recordedDate')).getHours()).toEqual(new Date().getHours());
        });
        it("should have function to add recorded* to all labels", function() {
          this.exp.get('lsLabels').setBestName(new Label({
            labelKind: "experiment name",
            labelText: "new name"
          }));
          this.exp.prepareToSave();
          expect(this.exp.get('lsLabels').pickBestLabel().get('recordedBy')).toEqual("jmcneil");
          return expect(this.exp.get('lsLabels').pickBestLabel().get('recordedDate')).toBeGreaterThan(1);
        });
        it("should have function to add recorded * to values", function() {
          var status;
          status = this.exp.getStatus();
          this.exp.prepareToSave();
          expect(status.get('recordedBy')).toEqual("jmcneil");
          return expect(status.get('recordedDate')).toBeGreaterThan(1);
        });
        return it("should have function to add recorded * to states", function() {
          var state;
          state = this.exp.get('lsStates').getOrCreateStateByTypeAndKind("metadata", "experiment metadata");
          this.exp.prepareToSave();
          expect(state.get('recordedBy')).toEqual("jmcneil");
          return expect(state.get('recordedDate')).toBeGreaterThan(1);
        });
      });
      return describe("model composite component conversion", function() {
        beforeEach(function() {
          runs(function() {
            this.saveSucessful = false;
            this.saveComplete = false;
            this.exp = new Experiment({
              id: 1
            });
            this.exp.on('sync', (function(_this) {
              return function() {
                _this.saveSucessful = true;
                return _this.saveComplete = true;
              };
            })(this));
            this.exp.on('invalid', (function(_this) {
              return function() {
                return _this.saveComplete = true;
              };
            })(this));
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
        it("should convert protocol  to Protocol", function() {
          return runs(function() {
            return expect(this.exp.get('protocol') instanceof Protocol).toBeTruthy();
          });
        });
        return it("should convert tags has to collection of Tags", function() {
          return runs(function() {
            return expect(this.exp.get('lsTags') instanceof TagList).toBeTruthy();
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
            this.copied = false;
            this.exp0 = new Experiment();
            this.exp0.getNotebook().set({
              stringValue: null
            });
            this.exp0.getCompletionDate().set({
              dateValue: null
            });
            this.exp0.getProjectCode().set({
              codeValue: null
            });
            this.exp0.on("protocol_attributes_copied", (function(_this) {
              return function() {
                return _this.copied = true;
              };
            })(this));
            this.exp0.copyProtocolAttributes(new Protocol(window.protocolServiceTestJSON.fullSavedProtocol));
            this.ebc = new ExperimentBaseController({
              model: this.exp0,
              el: $('#fixture'),
              protocolFilter: "?protocolKind=default"
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
        describe("it should show a picklist for protocols", function() {
          beforeEach(function() {
            waitsFor(function() {
              return this.ebc.$('.bv_protocolCode option').length > 0;
            }, 1000);
            return runs(function() {});
          });
          return it("should show protocol options after loading them from server", function() {
            return expect(this.ebc.$('.bv_protocolCode option').length).toBeGreaterThan(0);
          });
        });
        describe("it should show a picklist for projects", function() {
          beforeEach(function() {
            waitsFor(function() {
              return this.ebc.$('.bv_projectCode option').length > 0;
            }, 1000);
            return runs(function() {});
          });
          it("should show project options after loading them from server", function() {
            return expect(this.ebc.$('.bv_projectCode option').length).toBeGreaterThan(0);
          });
          return it("should default to unassigned", function() {
            return expect(this.ebc.$('.bv_projectCode').val()).toEqual("unassigned");
          });
        });
        describe("it should show a picklist for experiment statuses", function() {
          beforeEach(function() {
            waitsFor(function() {
              return this.ebc.$('.bv_status option').length > 0;
            }, 1000);
            return runs(function() {});
          });
          it("should show status options after loading them from server", function() {
            return expect(this.ebc.$('.bv_status option').length).toBeGreaterThan(0);
          });
          return it("should default to created", function() {
            return expect(this.ebc.$('.bv_status').val()).toEqual("created");
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
          it("should not fill the short description field", function() {
            return expect(this.ebc.$('.bv_shortDescription').html()).toEqual("");
          });
          it("should not fill the experimentDetails field", function() {
            return expect(this.ebc.$('.bv_details').html()).toEqual("");
          });
          it("should not fill the comments field", function() {
            return expect(this.ebc.$('.bv_comments').html()).toEqual("");
          });
          return it("should not fill the notebook field", function() {
            return expect(this.ebc.$('.bv_notebook').val()).toEqual("");
          });
        });
        return describe("User edits fields", function() {
          it("should update model when scientist is changed", function() {
            expect(this.ebc.model.getScientist().get('codeValue')).toEqual("unassigned");
            waitsFor(function() {
              return this.ebc.$('.bv_scientist option').length > 0;
            }, 1000);
            return runs(function() {
              this.ebc.$('.bv_scientist').val('bob');
              this.ebc.$('.bv_scientist').change();
              return expect(this.ebc.model.getScientist().get('codeValue')).toEqual("bob");
            });
          });
          it("should update model when shortDescription is changed", function() {
            this.ebc.$('.bv_shortDescription').val(" New short description   ");
            this.ebc.$('.bv_shortDescription').change();
            return expect(this.ebc.model.get('shortDescription')).toEqual("New short description");
          });
          it("should set model shortDescription to a space when shortDescription is set to empty", function() {
            this.ebc.$('.bv_shortDescription').val("");
            this.ebc.$('.bv_shortDescription').change();
            return expect(this.ebc.model.get('shortDescription')).toEqual(" ");
          });
          it("should update model when experimentDetails is changed", function() {
            var desc, states, values;
            this.ebc.$('.bv_details').val(" New experiment details   ");
            this.ebc.$('.bv_details').change();
            states = this.ebc.model.get('lsStates').getStatesByTypeAndKind("metadata", "experiment metadata");
            expect(states.length).toEqual(1);
            values = states[0].getValuesByTypeAndKind("clobValue", "experiment details");
            desc = values[0].get('clobValue');
            expect(desc).toEqual("New experiment details");
            return expect(this.ebc.model.getDetails().get('clobValue')).toEqual("New experiment details");
          });
          it("should update model when comments is changed", function() {
            var desc, states, values;
            this.ebc.$('.bv_comments').val(" New comments   ");
            this.ebc.$('.bv_comments').change();
            states = this.ebc.model.get('lsStates').getStatesByTypeAndKind("metadata", "experiment metadata");
            expect(states.length).toEqual(1);
            values = states[0].getValuesByTypeAndKind("clobValue", "comments");
            desc = values[0].get('clobValue');
            expect(desc).toEqual("New comments");
            return expect(this.ebc.model.getComments().get('clobValue')).toEqual("New comments");
          });
          it("should update model when name is changed", function() {
            this.ebc.$('.bv_experimentName').val(" Updated experiment name   ");
            this.ebc.$('.bv_experimentName').change();
            return expect(this.ebc.model.get('lsLabels').pickBestLabel().get('labelText')).toEqual("Updated experiment name");
          });
          it("should update model when completion date is changed", function() {
            this.ebc.$('.bv_completionDate').val(" 2013-3-16   ");
            this.ebc.$('.bv_completionDate').change();
            return expect(this.ebc.model.getCompletionDate().get('dateValue')).toEqual(new Date(2013, 2, 16).getTime());
          });
          it("should update model when notebook is changed", function() {
            this.ebc.$('.bv_notebook').val(" Updated notebook  ");
            this.ebc.$('.bv_notebook').change();
            return expect(this.ebc.model.getNotebook().get('stringValue')).toEqual("Updated notebook");
          });
          it("should update model when protocol is changed", function() {
            waitsFor(function() {
              return this.ebc.$('.bv_protocolCode option').length > 0;
            }, 1000);
            runs(function() {
              this.ebc.model.set({
                protocol: {}
              });
              this.ebc.$('.bv_protocolCode').val("PROT-00000001");
              return this.ebc.$('.bv_protocolCode').change();
            });
            waits(1000);
            return runs(function() {
              return expect(this.ebc.model.get('protocol').get('codeName')).toEqual("PROT-00000001");
            });
          });
          it("should update model when project is changed", function() {
            waitsFor(function() {
              return this.ebc.$('.bv_projectCode option').length > 0;
            }, 1000);
            return runs(function() {
              this.ebc.$('.bv_projectCode').val("project2");
              this.ebc.$('.bv_projectCode').change();
              return expect(this.ebc.model.getProjectCode().get('codeValue')).toEqual("project2");
            });
          });
          it("should update model when tag added", function() {
            this.ebc.$('.bv_tags').tagsinput('add', "lucy");
            this.ebc.tagListController.handleTagsChanged();
            return expect(this.ebc.model.get('lsTags').at(0).get('tagText')).toEqual("lucy");
          });
          return it("should update model when experiment status changed", function() {
            waitsFor(function() {
              return this.ebc.$('.bv_status option').length > 0;
            }, 1000);
            return runs(function() {
              this.ebc.$('.bv_status').val('complete');
              this.ebc.$('.bv_status').change();
              return expect(this.ebc.model.getStatus().get('codeValue')).toEqual('complete');
            });
          });
        });
      });
      describe("When created from a saved experiment", function() {
        beforeEach(function() {
          this.exp2 = new Experiment(window.experimentServiceTestJSON.fullExperimentFromServer);
          this.ebc = new ExperimentBaseController({
            model: this.exp2,
            el: $('#fixture'),
            protocolFilter: "?protocolKind=default"
          });
          return this.ebc.render();
        });
        describe("property display", function() {
          it("should show the protocol code", function() {
            waitsFor(function() {
              return this.ebc.$('.bv_protocolCode option').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.ebc.$('.bv_protocolCode').val()).toEqual("PROT-00000001");
            });
          });
          it("should show the project code", function() {
            waitsFor(function() {
              return this.ebc.$('.bv_scientist option').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.ebc.$('.bv_projectCode').val()).toEqual("project1");
            });
          });
          it("should show the save button text as Update", function() {
            return expect(this.ebc.$('.bv_save').html()).toEqual("Update");
          });
          it("should hide the protocol parameters button because we are chaning the behaviopr and may eliminate it", function() {
            return expect(this.ebc.$('.bv_useProtocolParameters')).toBeHidden();
          });
          xit("should have use protocol parameters disabled", function() {
            return expect(this.ebc.$('.bv_useProtocolParameters').attr("disabled")).toEqual("disabled");
          });
          it("should have protocol select disabled", function() {
            return expect(this.ebc.$('.bv_protocolCode').attr("disabled")).toEqual("disabled");
          });
          it("should fill the short description field", function() {
            return expect(this.ebc.$('.bv_shortDescription').html()).toEqual("experiment created by generic data parser");
          });
          it("should fill the experiment details field", function() {
            return expect(this.ebc.$('.bv_details').val()).toEqual("experiment details go here");
          });
          it("should fill the comments field", function() {
            return expect(this.ebc.$('.bv_comments').val()).toEqual("comments go here");
          });
          xit("should fill the name field", function() {
            return expect(this.ebc.$('.bv_experimentName').val()).toEqual("FLIPR target A biochemical");
          });
          it("should fill the date field in the same format is the date picker", function() {
            return expect(this.ebc.$('.bv_completionDate').val()).toEqual("2012-07-12");
          });
          it("should fill the scientist field", function() {
            waitsFor(function() {
              return this.ebc.$('.bv_scientist option').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.ebc.$('.bv_scientist').val()).toEqual("jane");
            });
          });
          it("should fill the code field", function() {
            return expect(this.ebc.$('.bv_experimentCode').html()).toEqual("EXPT-00000001");
          });
          it("should fill the notebook field", function() {
            return expect(this.ebc.$('.bv_notebook').val()).toEqual("911");
          });
          it("should show the tags", function() {
            return expect(this.ebc.$('.bv_tags').tagsinput('items')[0]).toEqual("stuff");
          });
          it("show the status", function() {
            waitsFor(function() {
              return this.ebc.$('.bv_status option').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.ebc.$('.bv_status').val()).toEqual("started");
            });
          });
          return it("should show the status select enabled", function() {
            return expect(this.ebc.$('.bv_status').attr('disabled')).toBeUndefined();
          });
        });
        describe("Experiment status behavior", function() {
          it("should disable all fields if experiment is finalized", function() {
            waitsFor(function() {
              return this.ebc.$('.bv_status option').length > 0;
            }, 1000);
            return runs(function() {
              this.ebc.$('.bv_status').val('finalized');
              this.ebc.$('.bv_status').change();
              expect(this.ebc.$('.bv_notebook').attr('disabled')).toEqual('disabled');
              return expect(this.ebc.$('.bv_status').attr('disabled')).toBeUndefined();
            });
          });
          it("should enable all fields if experiment is started", function() {
            this.ebc.$('.bv_status').val('finalized');
            this.ebc.$('.bv_status').change();
            this.ebc.$('.bv_status').val('started');
            this.ebc.$('.bv_status').change();
            return expect(this.ebc.$('.bv_notebook').attr('disabled')).toBeUndefined();
          });
          it("should hide lock icon if experiment is new", function() {
            this.ebc.$('.bv_status').val('new');
            this.ebc.$('.bv_status').change();
            return expect(this.ebc.$('.bv_lock')).toBeHidden();
          });
          return it("should show lock icon if experiment is finalized", function() {
            waitsFor(function() {
              return this.ebc.$('.bv_status option').length > 0;
            }, 1000);
            return runs(function() {
              this.ebc.$('.bv_status').val('finalized');
              this.ebc.$('.bv_status').change();
              return expect(this.ebc.$('.bv_lock')).toBeVisible();
            });
          });
        });
        describe("cancel button behavior testing", function() {
          return it("should call a fetch on the model when cancel is clicked", function() {
            runs(function() {
              this.ebc.$('.bv_experimentName').val("new experiment name");
              this.ebc.$('.bv_experimentName').change();
              expect(this.ebc.$('.bv_experimentName').val()).toEqual("new experiment name");
              return this.ebc.$('.bv_cancel').click();
            });
            waits(1000);
            return runs(function() {
              return expect(this.ebc.$('.bv_experimentName').val()).toEqual("Test Experiment 1");
            });
          });
        });
        return describe("new experiment button behavior testing", function() {
          return it("should create a new experiment when New Experiment is clicked", function() {
            runs(function() {
              return this.ebc.$('.bv_newEntity').click();
            });
            waits(1000);
            return runs(function() {
              return expect(this.ebc.$('.bv_experimentCode').html()).toEqual("autofill when saved");
            });
          });
        });
      });
      return describe("When created from a new experiment", function() {
        beforeEach(function() {
          this.exp0 = new Experiment();
          this.exp0.getStatus().set({
            codeValue: "created"
          });
          this.ebc = new ExperimentBaseController({
            model: this.exp0,
            el: $('#fixture'),
            protocolFilter: "?protocolKind=default"
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
          it("should have project code not set", function() {
            waitsFor(function() {
              return this.ebc.$('.bv_projectCode option').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.ebc.$('.bv_projectCode').val()).toEqual("unassigned");
            });
          });
          xit("should have use protocol parameters disabled", function() {
            return expect(this.ebc.$('.bv_useProtocolParameters').attr("disabled")).toEqual("disabled");
          });
          it("should have protocol select enabled", function() {
            return expect(this.ebc.$('.bv_protocolCode').attr("disabled")).toBeUndefined();
          });
          it("should not fill the date field", function() {
            return expect(this.ebc.$('.bv_completionDate').val()).toEqual("");
          });
          it("should show the save button text as Save", function() {
            return expect(this.ebc.$('.bv_save').html()).toEqual("Save");
          });
          it("should show the save button disabled", function() {
            return expect(this.ebc.$('.bv_save').attr('disabled')).toEqual('disabled');
          });
          it("should show status select value as created", function() {
            waitsFor(function() {
              return this.ebc.$('.bv_protocolCode option').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.ebc.$('.bv_status').val()).toEqual('created');
            });
          });
          return it("should show the status select disabled", function() {
            return expect(this.ebc.$('.bv_status').attr('disabled')).toEqual('disabled');
          });
        });
        describe("when user picks protocol ", function() {
          beforeEach(function() {
            waitsFor(function() {
              return this.ebc.$('.bv_protocolCode option').length > 0;
            }, 1000);
            return runs(function() {
              this.ebc.$('.bv_protocolCode').val("PROT-00000001");
              this.ebc.$('.bv_protocolCode').change();
              return waits(1000);
            });
          });
          describe("When user picks protocol", function() {
            it("should update model", function() {
              return runs(function() {
                console.log(this.ebc.model.get('protocol'));
                return expect(this.ebc.model.get('protocol').get('codeName')).toEqual("PROT-00000001");
              });
            });
            it("should fill the short description field because the protocol attributes are automatically copied", function() {
              return runs(function() {
                return expect(this.ebc.$('.bv_shortDescription').html()).toEqual("");
              });
            });
            return it("should enable use protocol params", function() {
              return runs(function() {
                return expect(this.ebc.$('.bv_useProtocolParameters').attr("disabled")).toBeUndefined();
              });
            });
          });
          return xdescribe("When user and asks to clone attributes should populate fields", function() {
            beforeEach(function() {
              return runs(function() {
                return this.ebc.$('.bv_useProtocolParameters').click();
              });
            });
            return it("should fill the short description field", function() {
              return runs(function() {
                return expect(this.ebc.$('.bv_shortDescription').html()).toEqual("primary analysis");
              });
            });
          });
        });
        return describe("controller validation rules", function() {
          beforeEach(function() {
            waitsFor(function() {
              return this.ebc.$('.bv_protocolCode option').length > 0 && this.ebc.$('.bv_projectCode option').length > 0 && this.ebc.$('.bv_scientist option').length > 0;
            }, 1000);
            runs(function() {
              this.ebc.$('.bv_shortDescription').val(" New short description   ");
              this.ebc.$('.bv_shortDescription').change();
              this.ebc.$('.bv_protocolCode').val("PROT-00000001");
              this.ebc.$('.bv_protocolCode').change();
              this.ebc.$('.bv_experimentName').val(" Updated experiment name   ");
              return this.ebc.$('.bv_experimentName').change();
            });
            waits(1000);
            runs(function() {
              this.ebc.$('.bv_projectCode').val("project1");
              this.ebc.$('.bv_projectCode').change();
              this.ebc.$('.bv_notebook').val("my notebook");
              this.ebc.$('.bv_notebook').change();
              this.ebc.$('.bv_completionDate').val(" 2013-3-16   ");
              this.ebc.$('.bv_completionDate').change();
              this.ebc.$('.bv_scientist').val("john");
              return this.ebc.$('.bv_scientist').change();
            });
            return waits(1000);
          });
          describe("form validation setup", function() {
            it("should be valid if form fully filled out", function() {
              return runs(function() {
                return expect(this.ebc.isValid()).toBeTruthy();
              });
            });
            return it("save button should be enabled", function() {
              waitsFor(function() {
                return this.ebc.$('.bv_scientist option').length > 0;
              }, 1000);
              return runs(function() {
                this.ebc.$('.bv_scientist').val("bob");
                this.ebc.$('.bv_scientist').change();
                console.log(this.ebc.model.validationError);
                return expect(this.ebc.$('.bv_save').attr('disabled')).toBeUndefined();
              });
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
            it("should show error in name field", function() {
              return runs(function() {
                return expect(this.ebc.$('.bv_group_experimentName').hasClass('error')).toBeTruthy();
              });
            });
            return it("should show the save button disabled", function() {
              return runs(function() {
                return expect(this.ebc.$('.bv_save').attr('disabled')).toEqual('disabled');
              });
            });
          });
          describe("when date field not filled in", function() {
            beforeEach(function() {
              return runs(function() {
                this.ebc.$('.bv_completionDate').val("");
                return this.ebc.$('.bv_completionDate').change();
              });
            });
            return it("should show error in date field", function() {
              return runs(function() {
                return expect(this.ebc.$('.bv_group_completionDate').hasClass('error')).toBeTruthy();
              });
            });
          });
          describe("when scientist not selected", function() {
            beforeEach(function() {
              return runs(function() {
                this.ebc.$('.bv_scientist').val("unassigned");
                return this.ebc.$('.bv_scientist').change();
              });
            });
            return it("should show error on scientist dropdown", function() {
              return runs(function() {
                console.log(this.ebc.model.validationError);
                return expect(this.ebc.$('.bv_group_scientist').hasClass('error')).toBeTruthy();
              });
            });
          });
          describe("when protocol not selected", function() {
            beforeEach(function() {
              return runs(function() {
                this.ebc.$('.bv_protocolCode').val("unassigned");
                return this.ebc.$('.bv_protocolCode').change();
              });
            });
            return it("should show error on protocol dropdown", function() {
              return runs(function() {
                return expect(this.ebc.$('.bv_group_protocolCode').hasClass('error')).toBeTruthy();
              });
            });
          });
          describe("when project not selected", function() {
            beforeEach(function() {
              return runs(function() {
                this.ebc.$('.bv_projectCode').val("unassigned");
                return this.ebc.$('.bv_projectCode').change();
              });
            });
            return it("should show error on project dropdown", function() {
              return runs(function() {
                return expect(this.ebc.$('.bv_group_projectCode').hasClass('error')).toBeTruthy();
              });
            });
          });
          describe("when notebook not filled", function() {
            beforeEach(function() {
              return runs(function() {
                this.ebc.$('.bv_notebook').val("");
                return this.ebc.$('.bv_notebook').change();
              });
            });
            return it("should show error on notebook dropdown", function() {
              return runs(function() {
                return expect(this.ebc.$('.bv_group_notebook').hasClass('error')).toBeTruthy();
              });
            });
          });
          describe("expect save to work", function() {
            it("model should be valid and ready to save", function() {
              return runs(function() {
                return expect(this.ebc.model.isValid()).toBeTruthy();
              });
            });
            it("should update experiment code", function() {
              runs(function() {
                return this.ebc.$('.bv_save').click();
              });
              waits(1000);
              return runs(function() {
                return expect(this.ebc.$('.bv_experimentCode').html()).toEqual("EXPT-00000001");
              });
            });
            return it("should show the save button text as Update", function() {
              runs(function() {
                return this.ebc.$('.bv_save').click();
              });
              waits(1000);
              return runs(function() {
                return expect(this.ebc.$('.bv_save').html()).toEqual("Update");
              });
            });
          });
          describe("cancel button behavior testing", function() {
            return it("should call a fetch on the model when cancel is clicked", function() {
              runs(function() {
                return this.ebc.$('.bv_cancel').click();
              });
              waits(1000);
              return runs(function() {
                return expect(this.ebc.$('.bv_experimentName').val()).toEqual("");
              });
            });
          });
          return describe("new experiment button behavior testing", function() {
            return it("should create a new experiment when New Experiment is clicked", function() {
              runs(function() {
                return this.ebc.$('.bv_newEntity').click();
              });
              waits(1000);
              return runs(function() {
                return expect(this.ebc.$('.bv_experimentName').val()).toEqual("");
              });
            });
          });
        });
      });
    });
  });

}).call(this);
