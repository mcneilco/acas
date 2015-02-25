(function() {
  beforeEach(function() {
    return this.fixture = $.clone($("#fixture").get(0));
  });

  afterEach(function() {
    $("#fixture").remove();
    return $("body").append($(this.fixture));
  });

  describe("Base Entity testing", function() {
    describe("Base entity model testing", function() {
      describe("when loaded from new", function() {
        beforeEach(function() {
          return this.bem = new BaseEntity();
        });
        describe("Defaults", function() {
          it('Should have a subclass default to entity', function() {
            return expect(this.bem.get("subclass")).toEqual("entity");
          });
          it('Should have default type and kind', function() {
            expect(this.bem.get('lsType')).toEqual("default");
            return expect(this.bem.get('lsKind')).toEqual("default");
          });
          it('Should have an empty label list', function() {
            expect(this.bem.get('lsLabels').length).toEqual(0);
            return expect(this.bem.get('lsLabels') instanceof LabelList).toBeTruthy();
          });
          it('Should have an empty tags list', function() {
            expect(this.bem.get('lsTags').length).toEqual(0);
            return expect(this.bem.get('lsTags') instanceof Backbone.Collection).toBeTruthy();
          });
          it('Should have an empty state list', function() {
            expect(this.bem.get('lsStates').length).toEqual(0);
            return expect(this.bem.get('lsStates') instanceof StateList).toBeTruthy();
          });
          it('Should have an empty scientist', function() {
            expect(this.bem.getScientist().get('codeValue')).toEqual("unassigned");
            expect(this.bem.getScientist().get('codeType')).toEqual("assay");
            expect(this.bem.getScientist().get('codeKind')).toEqual("scientist");
            return expect(this.bem.getScientist().get('codeOrigin')).toEqual("ACAS authors");
          });
          it('Should have the recordedBy set to the loginUser username', function() {
            return expect(this.bem.get('recordedBy')).toEqual("jmcneil");
          });
          it('Should have an recordedDate set to now', function() {
            return expect(new Date(this.bem.get('recordedDate')).getHours()).toEqual(new Date().getHours());
          });
          return it('Should have an empty short description with a space as an oracle work-around', function() {
            return expect(this.bem.get('shortDescription')).toEqual(" ");
          });
        });
        describe("required states and values", function() {
          it('Should have a entity details value', function() {
            expect(this.bem.getDetails() instanceof Value).toBeTruthy();
            return expect(this.bem.getDetails().get('clobValue')).toEqual("");
          });
          it('Should have a comments value', function() {
            expect(this.bem.getComments() instanceof Value).toBeTruthy();
            return expect(this.bem.getComments().get('clobValue')).toEqual("");
          });
          it('Should have a notebook value', function() {
            return expect(this.bem.getNotebook() instanceof Value).toBeTruthy();
          });
          return it('Entity status should default to created and should have default code type, kind, and origin', function() {
            expect(this.bem.getStatus().get('codeValue')).toEqual("created");
            expect(this.bem.getStatus().get('codeType')).toEqual("entity");
            expect(this.bem.getStatus().get('codeKind')).toEqual("status");
            return expect(this.bem.getStatus().get('codeOrigin')).toEqual("ACAS DDICT");
          });
        });
        return describe("other features", function() {
          return describe("should tell you if it is editable based on status", function() {
            it("should be locked if status is created", function() {
              this.bem.getStatus().set({
                codeValue: "created"
              });
              return expect(this.bem.isEditable()).toBeTruthy();
            });
            it("should be locked if status is started", function() {
              this.bem.getStatus().set({
                codeValue: "started"
              });
              return expect(this.bem.isEditable()).toBeTruthy();
            });
            it("should be locked if status is complete", function() {
              this.bem.getStatus().set({
                codeValue: "complete"
              });
              return expect(this.bem.isEditable()).toBeTruthy();
            });
            it("should be locked if status is finalized", function() {
              this.bem.getStatus().set({
                codeValue: "finalized"
              });
              return expect(this.bem.isEditable()).toBeFalsy();
            });
            return it("should be locked if status is rejected", function() {
              this.bem.getStatus().set({
                codeValue: "rejected"
              });
              return expect(this.bem.isEditable()).toBeFalsy();
            });
          });
        });
      });
      describe("when loaded from existing", function() {
        beforeEach(function() {
          this.bem = new BaseEntity(window.baseEntityServiceTestJSON.savedExperimentWithAnalysisGroups);
          return this.bem.set({
            subclass: "experiment"
          });
        });
        return describe("after initial load", function() {
          it("should have a kind", function() {
            return expect(this.bem.get('lsKind')).toEqual("ACAS doc for batches");
          });
          it("should have a code ", function() {
            return expect(this.bem.get('codeName')).toEqual("EXPT-00000222");
          });
          it("should have the shortDescription set", function() {
            return expect(this.bem.get('shortDescription')).toEqual(window.baseEntityServiceTestJSON.savedExperimentWithAnalysisGroups.shortDescription);
          });
          it("should have labels", function() {
            return expect(this.bem.get('lsLabels').length).toEqual(window.baseEntityServiceTestJSON.savedExperimentWithAnalysisGroups.lsLabels.length);
          });
          it("should have labels", function() {
            return expect(this.bem.get('lsLabels').at(0).get('lsKind')).toEqual("experiment name");
          });
          it('Should have a entity details value', function() {
            return expect(this.bem.getDetails().get('clobValue')).toEqual("experiment details go here");
          });
          it('Should have a notebook value', function() {
            return expect(this.bem.getNotebook().get('stringValue')).toEqual("911");
          });
          return it('Should have a status value', function() {
            return expect(this.bem.getStatus().get('codeValue')).toEqual("started");
          });
        });
      });
      describe("model change propogation", function() {
        it("should trigger change when label changed", function() {
          runs(function() {
            this.bem = new BaseEntity();
            this.baseEntityChanged = false;
            this.bem.get('lsLabels').setBestName(new Label({
              labelKind: "experiment name",
              labelText: "test label",
              recordedBy: this.bem.get('recordedBy'),
              recordedDate: this.bem.get('recordedDate')
            }));
            this.bem.on('change', (function(_this) {
              return function() {
                return _this.baseEntityChanged = true;
              };
            })(this));
            this.baseEntityChanged = false;
            return this.bem.get('lsLabels').setBestName(new Label({
              labelKind: "experiment name",
              labelText: "new label",
              recordedBy: this.bem.get('recordedBy'),
              recordedDate: this.bem.get('recordedDate')
            }));
          });
          waitsFor(function() {
            return this.baseEntityChanged;
          }, 500);
          return runs(function() {
            return expect(this.baseEntityChanged).toBeTruthy();
          });
        });
        return it("should trigger change when value changed in state", function() {
          runs(function() {
            this.bem = new BaseEntity(window.baseEntityServiceTestJSON.fullExperimentFromServer);
            this.bemerimentChanged = false;
            this.bem.on('change', (function(_this) {
              return function() {
                return _this.baseEntityChanged = true;
              };
            })(this));
            return this.bem.get('lsStates').at(0).get('lsValues').at(0).set({
              codeValue: 'fred'
            });
          });
          waitsFor(function() {
            return this.baseEntityChanged;
          }, 500);
          return runs(function() {
            return expect(this.baseEntityChanged).toBeTruthy();
          });
        });
      });
      describe("model validation", function() {
        beforeEach(function() {
          this.bem = new BaseEntity(window.baseEntityServiceTestJSON.fullExperimentFromServer);
          return this.bem.set({
            subclass: "experiment"
          });
        });
        it("should be valid when loaded from saved", function() {
          return expect(this.bem.isValid()).toBeTruthy();
        });
        it("should be invalid when name is empty", function() {
          var filtErrors;
          this.bem.get('lsLabels').setBestName(new Label({
            labelKind: "experiment name",
            labelText: "",
            recordedBy: this.bem.get('recordedBy'),
            recordedDate: this.bem.get('recordedDate')
          }));
          expect(this.bem.isValid()).toBeFalsy();
          filtErrors = _.filter(this.bem.validationError, function(err) {
            return err.attribute === 'experimentName';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it("should be invalid when date is empty", function() {
          var filtErrors;
          this.bem.set({
            recordedDate: new Date("").getTime()
          });
          expect(this.bem.isValid()).toBeFalsy();
          filtErrors = _.filter(this.bem.validationError, function(err) {
            return err.attribute === 'recordedDate';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it("should be invalid when scientist not selected", function() {
          var filtErrors;
          this.bem.getScientist().set({
            codeValue: "unassigned"
          });
          expect(this.bem.isValid()).toBeFalsy();
          return filtErrors = _.filter(this.bem.validationError, function(err) {
            return err.attribute === 'scientist';
          });
        });
        return it("should be invalid when notebook is empty", function() {
          var filtErrors;
          this.bem.getNotebook().set({
            stringValue: ""
          });
          expect(this.bem.isValid()).toBeFalsy();
          filtErrors = _.filter(this.bem.validationError, function(err) {
            return err.attribute === 'notebook';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
      });
      describe("prepare to save", function() {
        beforeEach(function() {
          this.bem = new BaseEntity();
          this.bem.set({
            subclass: "experiment"
          });
          this.bem.set({
            recordedBy: "jmcneil"
          });
          return this.bem.set({
            recordedDate: -1
          });
        });
        afterEach(function() {
          this.bem.get('lsLabels').reset();
          return this.bem.get('lsStates').reset();
        });
        it("should set experiment's set to now", function() {
          this.bem.prepareToSave();
          return expect(new Date(this.bem.get('recordedDate')).getHours()).toEqual(new Date().getHours());
        });
        it("should have function to add recorded* to all labels", function() {
          this.bem.get('lsLabels').setBestName(new Label({
            labelKind: "experiment name",
            labelText: "new name"
          }));
          this.bem.prepareToSave();
          expect(this.bem.get('lsLabels').pickBestLabel().get('recordedBy')).toEqual("jmcneil");
          return expect(this.bem.get('lsLabels').pickBestLabel().get('recordedDate')).toBeGreaterThan(1);
        });
        it("should have function to add recorded * to values", function() {
          var status;
          status = this.bem.getStatus();
          this.bem.prepareToSave();
          expect(status.get('recordedBy')).toEqual("jmcneil");
          return expect(status.get('recordedDate')).toBeGreaterThan(1);
        });
        return it("should have function to add recorded * to states", function() {
          var state;
          state = this.bem.get('lsStates').getOrCreateStateByTypeAndKind("metadata", "experiment metadata");
          this.bem.prepareToSave();
          expect(state.get('recordedBy')).toEqual("jmcneil");
          return expect(state.get('recordedDate')).toBeGreaterThan(1);
        });
      });
      describe("model composite component conversion", function() {
        beforeEach(function() {
          runs(function() {
            this.saveSucessful = false;
            this.saveComplete = false;
            this.bem = new BaseEntity({
              id: 1
            });
            this.bem.on('sync', (function(_this) {
              return function() {
                _this.saveSucessful = true;
                return _this.saveComplete = true;
              };
            })(this));
            this.bem.on('invalid', (function(_this) {
              return function() {
                return _this.saveComplete = true;
              };
            })(this));
            return this.bem.fetch();
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
            return expect(this.bem.get('lsLabels') instanceof LabelList).toBeTruthy();
          });
        });
        it("should convert state array to state list", function() {
          return runs(function() {
            expect(this.bem.get('lsStates') instanceof StateList).toBeTruthy();
            return expect(this.bem.get('lsStates').length).toBeGreaterThan(0);
          });
        });
        return it("should convert tags has to collection of Tags", function() {
          return runs(function() {
            return expect(this.bem.get('lsTags') instanceof TagList).toBeTruthy();
          });
        });
      });
      return describe("duplicated entity", function() {
        beforeEach(function() {
          this.bem = new BaseEntity(window.baseEntityServiceTestJSON.fullExperimentFromServer);
          this.bem.set({
            subclass: "experiment"
          });
          return this.copiedEntity = this.bem.duplicateEntity(this.bem);
        });
        it("should have the same lsType as the original entity", function() {
          return expect(this.copiedEntity.get('lsType')).toEqual(this.bem.get('lsType'));
        });
        it("should have the same lsKind as the original entity", function() {
          return expect(this.copiedEntity.get('lsType')).toEqual(this.bem.get('lsKind'));
        });
        it("should have the status set to created", function() {
          return expect(this.copiedEntity.getStatus().get('codeValue')).toEqual("created");
        });
        it("should have the code name be undefined", function() {
          return expect(this.copiedEntity.get('codeName')).toBeUndefined();
        });
        it("should have the entity name be empty", function() {
          expect(this.copiedEntity.get('lsLabels').length).toEqual(0);
          return expect(this.copiedEntity.get('lsLabels') instanceof LabelList).toBeTruthy();
        });
        it("should have the scientist be unassigned", function() {
          return expect(this.copiedEntity.getScientist().get('codeValue')).toEqual("unassigned");
        });
        it("should have the recordedBy be jmcneil", function() {
          return expect(this.copiedEntity.get('recordedBy')).toEqual("jmcneil");
        });
        it("should have the recorded date be set to now", function() {
          return expect(new Date(this.copiedEntity.get('recordedDate')).getHours()).toEqual(new Date().getHours());
        });
        it("should have the protocol be duplicated when the entity is an experiment", function() {
          return expect(this.copiedEntity.get('protocol')).toEqual(this.bem.get('protocol'));
        });
        xit("should have the same project as the original entity", function() {
          return expect(this.copiedEntity.getProjectCode()).toEqual(this.bem.getProjectCode());
        });
        it("should have the notebook be empty", function() {
          return expect(this.copiedEntity.getNotebook().get('stringValue')).toEqual("");
        });
        it("should have the same lsTags", function() {
          return expect(this.copiedEntity.get('lsTags')).toEqual(this.bem.get('lsTags'));
        });
        it("should have the same short description", function() {
          return expect(this.copiedEntity.get('shortDescription')).toEqual(this.bem.get('shortDescription'));
        });
        it("should have the same description", function() {
          return expect(this.copiedEntity.getDetails().get('clobValue')).toEqual(this.bem.getDetails().get('clobValue'));
        });
        return it("should have the same comments", function() {
          return expect(this.copiedEntity.getComments().get('clobValue')).toEqual(this.bem.getComments().get('clobValue'));
        });
      });
    });
    describe("Base Entity List testing", function() {
      beforeEach(function() {
        return this.el = new BaseEntityList();
      });
      return describe("existance tests", function() {
        return it("should be defined", function() {
          return expect(BaseEntityList).toBeDefined();
        });
      });
    });
    return describe("BaseEntityController testing", function() {
      describe("When created from a saved entity", function() {
        beforeEach(function() {
          this.bem = new BaseEntity(window.experimentServiceTestJSON.fullExperimentFromServer);
          this.bem.set({
            subclass: "experiment"
          });
          this.bec = new BaseEntityController({
            model: this.bem,
            el: $('#fixture')
          });
          return this.bec.render();
        });
        describe("property display", function() {
          it("should show the save button text as Update", function() {
            return expect(this.bec.$('.bv_save').html()).toEqual("Update");
          });
          it("should show the create new entity button", function() {
            return expect(this.bec.$('.bv_newEntity')).toBeVisible();
          });
          it("should have the cancel button be disabled", function() {
            return expect(this.bec.$('.bv_newEntity')).toBeVisible();
          });
          it("should fill the short description field", function() {
            return expect(this.bec.$('.bv_shortDescription').html()).toEqual("experiment created by generic data parser");
          });
          xit("should fill the entity details field", function() {
            return expect(this.bec.$('.bv_details').html()).toEqual("experiment details goes here");
          });
          it("should fill the comments field", function() {
            return expect(this.bec.$('.bv_comments').val()).toEqual("comments go here");
          });
          xit("should fill the entity name field", function() {
            return expect(this.bec.$('.bv_entityName').val()).toEqual("FLIPR target A biochemical");
          });
          it("should fill the scientist field", function() {
            waitsFor(function() {
              return this.bec.$('.bv_scientist option').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.bec.$('.bv_scientist').val()).toEqual("jane");
            });
          });
          it("should fill the entity code field", function() {
            this.bem.set({
              subclass: "entity"
            });
            this.bec.render();
            return expect(this.bec.$('.bv_entityCode').html()).toEqual("EXPT-00000001");
          });
          it("should fill the entity kind field", function() {
            this.bem.set({
              subclass: "entity"
            });
            this.bec.render();
            return expect(this.bec.$('.bv_entityKind').html()).toEqual("default");
          });
          it("should fill the notebook field", function() {
            return expect(this.bec.$('.bv_notebook').val()).toEqual("911");
          });
          it("should show the tags", function() {
            return expect(this.bec.$('.bv_tags').tagsinput('items')[0]).toEqual("stuff");
          });
          it("show the status", function() {
            waitsFor(function() {
              return this.bec.$('.bv_status option').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.bec.$('.bv_status').val()).toEqual("started");
            });
          });
          return it("should show the status select enabled", function() {
            return expect(this.bec.$('.bv_status').attr('disabled')).toBeUndefined();
          });
        });
        describe("Entity status behavior", function() {
          it("should disable all fields if entity is finalized", function() {
            waitsFor(function() {
              return this.bec.$('.bv_status option').length > 0;
            }, 1000);
            return runs(function() {
              this.bec.$('.bv_status').val('finalized');
              this.bec.$('.bv_status').change();
              expect(this.bec.$('.bv_notebook').attr('disabled')).toEqual('disabled');
              return expect(this.bec.$('.bv_status').attr('disabled')).toBeUndefined();
            });
          });
          it("should enable all fields if entity is started", function() {
            this.bec.$('.bv_status').val('finalized');
            this.bec.$('.bv_status').change();
            this.bec.$('.bv_status').val('started');
            this.bec.$('.bv_status').change();
            return expect(this.bec.$('.bv_notebook').attr('disabled')).toBeUndefined();
          });
          it("should hide lock icon if entity is created", function() {
            this.bec.$('.bv_status').val('created');
            this.bec.$('.bv_status').change();
            return expect(this.bec.$('.bv_lock')).toBeHidden();
          });
          return it("should show lock icon if entity is finalized", function() {
            waitsFor(function() {
              return this.bec.$('.bv_status option').length > 0;
            }, 1000);
            return runs(function() {
              this.bec.$('.bv_status').val('finalized');
              this.bec.$('.bv_status').change();
              return expect(this.bec.$('.bv_lock')).toBeVisible();
            });
          });
        });
        return describe("User edits fields", function() {
          it("should enable the cancel button", function() {
            this.bec.model.trigger('change');
            return expect(this.bec.$('.bv_cancel').attr('disabled')).toBeUndefined();
          });
          it("should update model when scientist is changed", function() {
            expect(this.bec.model.getScientist().get('codeValue')).toEqual("jane");
            waitsFor(function() {
              return this.bec.$('.bv_scientist option').length > 0;
            }, 1000);
            return runs(function() {
              this.bec.$('.bv_scientist').val('unassigned');
              this.bec.$('.bv_scientist').change();
              return expect(this.bec.model.getScientist().get('codeValue')).toEqual("unassigned");
            });
          });
          it("should update model when shortDescription is changed", function() {
            this.bec.$('.bv_shortDescription').val(" New short description   ");
            this.bec.$('.bv_shortDescription').change();
            return expect(this.bec.model.get('shortDescription')).toEqual("New short description");
          });
          it("should set model shortDescription to a space when shortDescription is set to empty", function() {
            this.bec.$('.bv_shortDescription').val("");
            this.bec.$('.bv_shortDescription').change();
            return expect(this.bec.model.get('shortDescription')).toEqual(" ");
          });
          xit("should update model when entity details is changed", function() {
            var desc, states, values;
            this.bec.$('.bv_details').val(" New experiment details   ");
            this.bec.$('.bv_details').change();
            states = this.bec.model.get('lsStates').getStatesByTypeAndKind("metadata", "experiment metadata");
            expect(states.length).toEqual(1);
            values = states[0].getValuesByTypeAndKind("clobValue", "experiment details");
            desc = values[0].get('clobValue');
            expect(desc).toEqual("New experiment details");
            return expect(this.bec.model.getDetails().get('clobValue')).toEqual("New experiment details");
          });
          it("should update model when comments is changed", function() {
            var desc, states, values;
            this.bec.$('.bv_comments').val(" New comments   ");
            this.bec.$('.bv_comments').change();
            states = this.bec.model.get('lsStates').getStatesByTypeAndKind("metadata", "experiment metadata");
            expect(states.length).toEqual(1);
            values = states[0].getValuesByTypeAndKind("clobValue", "comments");
            desc = values[0].get('clobValue');
            expect(desc).toEqual("New comments");
            return expect(this.bec.model.getComments().get('clobValue')).toEqual("New comments");
          });
          it("should update model when entity name is changed", function() {
            this.bem.set({
              subclass: "entity"
            });
            this.bec.render();
            this.bec.$('.bv_entityName').val(" Updated entity name   ");
            this.bec.$('.bv_entityName').change();
            return expect(this.bec.model.get('lsLabels').pickBestLabel().get('labelText')).toEqual("Updated entity name");
          });
          it("should update model when notebook is changed", function() {
            this.bec.$('.bv_notebook').val(" Updated notebook  ");
            this.bec.$('.bv_notebook').change();
            return expect(this.bec.model.getNotebook().get('stringValue')).toEqual("Updated notebook");
          });
          it("should update model when tag added", function() {
            this.bec.$('.bv_tags').tagsinput('add', "lucy");
            this.bec.tagListController.handleTagsChanged();
            return expect(this.bec.model.get('lsTags').at(2).get('tagText')).toEqual("lucy");
          });
          return it("should update model when entity status changed", function() {
            waitsFor(function() {
              return this.bec.$('.bv_status option').length > 0;
            }, 1000);
            return runs(function() {
              this.bec.$('.bv_status').val('complete');
              this.bec.$('.bv_status').change();
              return expect(this.bec.model.getStatus().get('codeValue')).toEqual('complete');
            });
          });
        });
      });
      return describe("When created from a new entity", function() {
        beforeEach(function() {
          this.bem = new BaseEntity();
          this.bem.getStatus().set({
            codeValue: "created"
          });
          this.bec = new BaseEntityController({
            model: this.bem,
            el: $('#fixture')
          });
          return this.bec.render();
        });
        describe("basic startup conditions", function() {
          it("should have entity code not set", function() {
            return expect(this.bec.$('.bv_entityCode').val()).toEqual("");
          });
          it("should have entity name not set", function() {
            return expect(this.bec.$('.bv_entityName').val()).toEqual("");
          });
          it("should show the save button text as Save", function() {
            return expect(this.bec.$('.bv_save').html()).toEqual("Save");
          });
          it("should show the save button disabled", function() {
            return expect(this.bec.$('.bv_save').attr('disabled')).toEqual('disabled');
          });
          it("should hide the create new entity button", function() {
            return expect(this.bec.$('.bv_newEntity')).toBeHidden();
          });
          it("should have the cancel button be disabled", function() {
            return expect(this.bec.$('.bv_cancel').attr('disabled')).toEqual('disabled');
          });
          it("should show the status select disabled", function() {
            return expect(this.bec.$('.bv_status').attr('disabled')).toEqual('disabled');
          });
          return it("should show status select value as created", function() {
            this.bem2 = new BaseEntity();
            this.bem2.set({
              subclass: 'experiment'
            });
            this.bem2.getStatus().set({
              codeValue: "created"
            });
            this.bec2 = new BaseEntityController({
              model: this.bem2,
              el: $('#fixture')
            });
            this.bec.render();
            waitsFor(function() {
              return this.bec2.$('.bv_status option').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.bec2.$('.bv_status').val()).toEqual('created');
            });
          });
        });
        return describe("controller validation rules", function() {
          beforeEach(function() {
            waitsFor(function() {
              return this.bec.$('.bv_scientist option').length > 0;
            }, 1000);
            return runs(function() {
              this.bec.$('.bv_scientist').val("bob");
              this.bec.$('.bv_scientist').change();
              this.bec.$('.bv_shortDescription').val(" New short description   ");
              this.bec.$('.bv_shortDescription').change();
              bec.$('.bv_entityName').val(" Updated entity name   ");
              this.bec.$('.bv_entityName').change();
              this.bec.$('.bv_notebook').val("my notebook");
              return this.bec.$('.bv_notebook').change();
            });
          });
          describe("form validation setup", function() {
            it("should be valid if form fully filled out", function() {
              return runs(function() {
                return expect(this.bec.isValid()).toBeTruthy();
              });
            });
            return it("save button should be enabled", function() {
              return runs(function() {
                console.log(this.bec.model.validationError);
                return expect(this.bec.$('.bv_save').attr('disabled')).toBeUndefined();
              });
            });
          });
          describe("when name field not filled in", function() {
            beforeEach(function() {
              return runs(function() {
                this.bec.$('.bv_entityName').val("");
                return this.bec.$('.bv_entityName').change();
              });
            });
            it("should be invalid if entity name not filled in", function() {
              return runs(function() {
                return expect(this.bec.isValid()).toBeFalsy();
              });
            });
            it("should show error in name field", function() {
              return runs(function() {
                return expect(this.bec.$('.bv_group_entityName').hasClass('error')).toBeTruthy();
              });
            });
            return it("should show the save button disabled", function() {
              return runs(function() {
                return expect(this.bec.$('.bv_save').attr('disabled')).toEqual('disabled');
              });
            });
          });
          describe("when scientist not selected", function() {
            beforeEach(function() {
              waitsFor(function() {
                return this.bec.$('.bv_scientist option').length > 0;
              }, 1000);
              return runs(function() {
                this.bec.$('.bv_scientist').val("unassigned");
                return this.bec.$('.bv_scientist').change();
              });
            });
            return it("should show error on scientist dropdown", function() {
              return runs(function() {
                return expect(this.bec.$('.bv_group_scientist').hasClass('error')).toBeTruthy();
              });
            });
          });
          describe("when notebook not filled", function() {
            beforeEach(function() {
              return runs(function() {
                this.bec.$('.bv_notebook').val("");
                return this.bec.$('.bv_notebook').change();
              });
            });
            return it("should show error on notebook dropdown", function() {
              return runs(function() {
                return expect(this.bec.$('.bv_group_notebook').hasClass('error')).toBeTruthy();
              });
            });
          });
          return describe("expect save to work", function() {
            it("model should be valid and ready to save", function() {
              return runs(function() {
                return expect(this.bec.model.isValid()).toBeTruthy();
              });
            });
            it("should update entity code", function() {
              runs(function() {
                return this.bec.$('.bv_save').click();
              });
              waits(1000);
              return runs(function() {
                return expect(this.bec.$('.bv_entityCode').html()).toEqual("EXPT-00000001");
              });
            });
            return it("should show the save button text as Update", function() {
              runs(function() {
                return this.bec.$('.bv_save').click();
              });
              waits(1000);
              return runs(function() {
                return expect(this.bec.$('.bv_save').html()).toEqual("Update");
              });
            });
          });
        });
      });
    });
  });

}).call(this);
