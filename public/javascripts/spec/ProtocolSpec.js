(function() {
  beforeEach(function() {
    return this.fixture = $.clone($("#fixture").get(0));
  });

  afterEach(function() {
    $("#fixture").remove();
    return $("body").append($(this.fixture));
  });

  describe("Protocol module testing", function() {
    describe("Protocol model testing", function() {
      describe("When loaded from new", function() {
        beforeEach(function() {
          return this.prot = new Protocol();
        });
        describe("Defaults", function() {
          it('Should have subclass set to protocol', function() {
            return expect(this.prot.get("subclass")).toEqual("protocol");
          });
          it('Should have default type and kind', function() {
            expect(this.prot.get('lsType')).toEqual("default");
            return expect(this.prot.get('lsKind')).toEqual("default");
          });
          it('Should have an empty label list', function() {
            expect(this.prot.get('lsLabels').length).toEqual(0);
            return expect(this.prot.get('lsLabels') instanceof LabelList).toBeTruthy();
          });
          it('Should have an empty tags list', function() {
            expect(this.prot.get('lsTags').length).toEqual(0);
            return expect(this.prot.get('lsTags') instanceof Backbone.Collection).toBeTruthy();
          });
          it('Should have an empty state list', function() {
            expect(this.prot.get('lsStates').length).toEqual(0);
            return expect(this.prot.get('lsStates') instanceof StateList).toBeTruthy();
          });
          it('Should have an empty scientist', function() {
            return expect(this.prot.get('recordedBy')).toEqual("");
          });
          it('Should have an recordedDate set to now', function() {
            return expect(new Date(this.prot.get('recordedDate')).getHours()).toEqual(new Date().getHours());
          });
          return it('Should have an empty short description with a space as an oracle work-around', function() {
            return expect(this.prot.get('shortDescription')).toEqual(" ");
          });
        });
        describe("required states and values", function() {
          it('Should have an assay tree rule value', function() {
            expect(this.prot.getAssayTreeRule() instanceof Value).toBeTruthy();
            return expect(this.prot.getAssayTreeRule().get('stringValue')).toEqual("");
          });
          it('Should have an assay principle value', function() {
            expect(this.prot.getAssayPrinciple() instanceof Value).toBeTruthy();
            return expect(this.prot.getAssayPrinciple().get('clobValue')).toEqual("");
          });
          it('Should have a description value', function() {
            expect(this.prot.getDescription() instanceof Value).toBeTruthy();
            return expect(this.prot.getDescription().get('clobValue')).toEqual("");
          });
          it('Should have a comments value', function() {
            expect(this.prot.getComments() instanceof Value).toBeTruthy();
            return expect(this.prot.getComments().get('clobValue')).toEqual("");
          });
          it('Should have a notebook value', function() {
            return expect(this.prot.getNotebook() instanceof Value).toBeTruthy();
          });
          it('Protocol status should default to created ', function() {
            return expect(this.prot.getStatus().get('stringValue')).toEqual("created");
          });
          return it('completionDate should be null ', function() {
            return expect(this.prot.getCompletionDate().get('dateValue')).toEqual(null);
          });
        });
        return describe("other features", function() {
          return describe("should tell you if it is editable based on status", function() {
            it("should be locked if status is created", function() {
              this.prot.getStatus().set({
                stringValue: "created"
              });
              return expect(this.prot.isEditable()).toBeTruthy();
            });
            it("should be locked if status is started", function() {
              this.prot.getStatus().set({
                stringValue: "started"
              });
              return expect(this.prot.isEditable()).toBeTruthy();
            });
            it("should be locked if status is complete", function() {
              this.prot.getStatus().set({
                stringValue: "complete"
              });
              return expect(this.prot.isEditable()).toBeTruthy();
            });
            it("should be locked if status is finalized", function() {
              this.prot.getStatus().set({
                stringValue: "finalized"
              });
              return expect(this.prot.isEditable()).toBeFalsy();
            });
            return it("should be locked if status is rejected", function() {
              this.prot.getStatus().set({
                stringValue: "rejected"
              });
              return expect(this.prot.isEditable()).toBeFalsy();
            });
          });
        });
      });
      describe("when loaded from existing", function() {
        beforeEach(function() {
          return this.prot = new Protocol(window.protocolServiceTestJSON.fullSavedProtocol);
        });
        return describe("after initial load", function() {
          it("should have a kind", function() {
            return expect(this.prot.get('lsKind')).toEqual("default");
          });
          it("should have a code ", function() {
            return expect(this.prot.get('codeName')).toEqual("PROT-00000001");
          });
          it("should have the shortDescription set", function() {
            return expect(this.prot.get('shortDescription')).toEqual(window.protocolServiceTestJSON.fullSavedProtocol.shortDescription);
          });
          it("should have labels", function() {
            return expect(this.prot.get('lsLabels').length).toEqual(window.protocolServiceTestJSON.fullSavedProtocol.lsLabels.length);
          });
          it("should have labels", function() {
            return expect(this.prot.get('lsLabels').at(0).get('lsKind')).toEqual("protocol name");
          });
          it("should have states ", function() {
            return expect(this.prot.get('lsStates').length).toEqual(window.protocolServiceTestJSON.fullSavedProtocol.lsStates.length);
          });
          it("should have states with kind ", function() {
            return expect(this.prot.get('lsStates').at(0).get('lsKind')).toEqual("protocol metadata");
          });
          it("states should have values", function() {
            return expect(this.prot.get('lsStates').at(0).get('lsValues').at(0).get('lsKind')).toEqual("assay tree rule");
          });
          it('Should have an assay principle value', function() {
            return expect(this.prot.getAssayPrinciple().get('clobValue')).toEqual("assay principle goes here");
          });
          it('Should have a description value', function() {
            return expect(this.prot.getDescription().get('clobValue')).toEqual("protocol details go here");
          });
          it('Should have a comments value', function() {
            return expect(this.prot.getComments().get('clobValue')).toEqual("protocol comments go here");
          });
          it('Should have a notebook value', function() {
            return expect(this.prot.getNotebook().get('stringValue')).toEqual("912");
          });
          it('Should have a completionDate value', function() {
            return expect(this.prot.getCompletionDate().get('dateValue')).toEqual(1342080000000);
          });
          return it('Should have a status value', function() {
            return expect(this.prot.getStatus().get('stringValue')).toEqual("created");
          });
        });
      });
      describe("when loaded from stub", function() {
        beforeEach(function() {
          this.prot = new Protocol(window.protocolServiceTestJSON.stubSavedProtocol[0]);
          return runs(function() {
            this.fetchReturned = false;
            return this.prot.fetch({
              success: (function(_this) {
                return function() {
                  return _this.fetchReturned = true;
                };
              })(this)
            });
          });
        });
        describe("utility functions", function() {
          return it("should know it's a stub", function() {
            return expect(this.prot.isStub()).toBeTruthy();
          });
        });
        return describe("get full object", function() {
          it("should have raw labels when fetched", function() {
            waitsFor(function() {
              return this.fetchReturned;
            });
            return runs(function() {
              return expect(this.prot.has('lsLabels')).toBeTruthy();
            });
          });
          return it("should have raw labels converted to LabelList when fetched", function() {
            waitsFor(function() {
              return this.fetchReturned;
            });
            return runs(function() {
              return expect(this.prot.get('lsLabels') instanceof LabelList).toBeTruthy();
            });
          });
        });
      });
      describe("model composite component conversion", function() {
        beforeEach(function() {
          runs(function() {
            this.saveSucessful = false;
            this.saveComplete = false;
            this.prot = new Protocol({
              id: 1
            });
            this.prot.on('sync', (function(_this) {
              return function() {
                _this.saveSucessful = true;
                return _this.saveComplete = true;
              };
            })(this));
            this.prot.on('invalid', (function(_this) {
              return function() {
                return _this.saveComplete = true;
              };
            })(this));
            return this.prot.fetch();
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
            expect(this.prot.get('lsLabels') instanceof LabelList).toBeTruthy();
            return expect(this.prot.get('lsLabels').length).toBeGreaterThan(0);
          });
        });
        it("should convert state array to state list", function() {
          return runs(function() {
            expect(this.prot.get('lsStates') instanceof StateList).toBeTruthy();
            return expect(this.prot.get('lsStates').length).toBeGreaterThan(0);
          });
        });
        return it("should convert tags has to collection of Tags", function() {
          return runs(function() {
            return expect(this.prot.get('lsTags') instanceof TagList).toBeTruthy();
          });
        });
      });
      describe("model change propogation", function() {
        it("should trigger change when label changed", function() {
          runs(function() {
            this.prot = new Protocol();
            this.protocolChanged = false;
            this.prot.get('lsLabels').setBestName(new Label({
              labelKind: "protocol name",
              labelText: "test label",
              recordedBy: this.prot.get('recordedBy'),
              recordedDate: this.prot.get('recordedDate')
            }));
            this.prot.on('change', (function(_this) {
              return function() {
                return _this.protocolChanged = true;
              };
            })(this));
            this.protocolChanged = false;
            return this.prot.get('lsLabels').setBestName(new Label({
              labelKind: "protocol name",
              labelText: "new label",
              recordedBy: this.prot.get('recordedBy'),
              recordedDate: this.prot.get('recordedDate')
            }));
          });
          waitsFor(function() {
            return this.protocolChanged;
          }, 500);
          return runs(function() {
            return expect(this.protocolChanged).toBeTruthy();
          });
        });
        return it("should trigger change when value changed in state", function() {
          runs(function() {
            this.prot = new Protocol(window.protocolServiceTestJSON.fullSavedProtocol);
            this.protocolChanged = false;
            this.prot.on('change', (function(_this) {
              return function() {
                return _this.protocolChanged = true;
              };
            })(this));
            return this.prot.get('lsStates').at(0).get('lsValues').at(0).set({
              lsKind: 'fred'
            });
          });
          waitsFor(function() {
            return this.protocolChanged;
          }, 500);
          return runs(function() {
            return expect(this.protocolChanged).toBeTruthy();
          });
        });
      });
      describe("model validation", function() {
        beforeEach(function() {
          return this.prot = new Protocol(window.protocolServiceTestJSON.fullSavedProtocol);
        });
        it("should be valid when loaded from saved", function() {
          return expect(this.prot.isValid()).toBeTruthy();
        });
        it("should be invalid when name is empty", function() {
          var filtErrors;
          this.prot.get('lsLabels').setBestName(new Label({
            labelKind: "protocol name",
            labelText: "",
            recordedBy: this.prot.get('recordedBy'),
            recordedDate: this.prot.get('recordedDate')
          }));
          expect(this.prot.isValid()).toBeFalsy();
          filtErrors = _.filter(this.prot.validationError, function(err) {
            return err.attribute === 'protocolName';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it("should be invalid when date is empty", function() {
          var filtErrors;
          this.prot.set({
            recordedDate: new Date("").getTime()
          });
          expect(this.prot.isValid()).toBeFalsy();
          filtErrors = _.filter(this.prot.validationError, function(err) {
            return err.attribute === 'recordedDate';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it("should be invalid when scientist not selected", function() {
          var filtErrors;
          this.prot.set({
            recordedBy: ""
          });
          expect(this.prot.isValid()).toBeFalsy();
          return filtErrors = _.filter(this.prot.validationError, function(err) {
            return err.attribute === 'recordedBy';
          });
        });
        it("should be invalid when notebook is empty", function() {
          var filtErrors;
          this.prot.getNotebook().set({
            stringValue: "",
            recordedBy: this.prot.get('recordedBy')
          });
          expect(this.prot.isValid()).toBeFalsy();
          filtErrors = _.filter(this.prot.validationError, function(err) {
            return err.attribute === 'notebook';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        return it('should require that completionDate not be ""', function() {
          var filtErrors;
          this.prot.getCompletionDate().set({
            dateValue: new Date("").getTime()
          });
          expect(this.prot.isValid()).toBeFalsy();
          filtErrors = _.filter(this.prot.validationError, function(err) {
            return err.attribute === 'completionDate';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
      });
      return describe("prepare to save", function() {
        beforeEach(function() {
          this.prot = new Protocol();
          this.prot.set({
            recordedBy: "jmcneil"
          });
          return this.prot.set({
            recordedDate: -1
          });
        });
        afterEach(function() {
          this.prot.get('lsLabels').reset();
          return this.prot.get('lsStates').reset();
        });
        it("should set experiment's set to now", function() {
          this.prot.prepareToSave();
          return expect(new Date(this.prot.get('recordedDate')).getHours()).toEqual(new Date().getHours());
        });
        it("should have function to add recorded* to all labels", function() {
          this.prot.get('lsLabels').setBestName(new Label({
            labelKind: "experiment name",
            labelText: "new name"
          }));
          this.prot.prepareToSave();
          expect(this.prot.get('lsLabels').pickBestLabel().get('recordedBy')).toEqual("jmcneil");
          return expect(this.prot.get('lsLabels').pickBestLabel().get('recordedDate')).toBeGreaterThan(1);
        });
        it("should have function to add recorded * to values", function() {
          var status;
          status = this.prot.getStatus();
          this.prot.prepareToSave();
          expect(status.get('recordedBy')).toEqual("jmcneil");
          return expect(status.get('recordedDate')).toBeGreaterThan(1);
        });
        return it("should have function to add recorded * to states", function() {
          var state;
          state = this.prot.get('lsStates').getOrCreateStateByTypeAndKind("metadata", "experiment metadata");
          this.prot.prepareToSave();
          expect(state.get('recordedBy')).toEqual("jmcneil");
          return expect(state.get('recordedDate')).toBeGreaterThan(1);
        });
      });
    });
    describe("Protocol List testing", function() {
      beforeEach(function() {
        return this.el = new ProtocolList();
      });
      return describe("existance tests", function() {
        return it("should be defined", function() {
          return expect(ProtocolList).toBeDefined();
        });
      });
    });
    return describe("ProtocolBaseController testing", function() {
      describe("When created from a saved protocol", function() {
        beforeEach(function() {
          this.prot = new Protocol(window.protocolServiceTestJSON.fullSavedProtocol);
          this.pbc = new ProtocolBaseController({
            model: this.prot,
            el: $('#fixture')
          });
          return this.pbc.render();
        });
        describe("property display", function() {
          it("should show the save button text as Update", function() {
            return expect(this.pbc.$('.bv_save').html()).toEqual("Update");
          });
          it("should fill the short description field", function() {
            return expect(this.pbc.$('.bv_shortDescription').html()).toEqual("primary analysis");
          });
          it("should fill the assay tree rule field", function() {
            return expect(this.pbc.$('.bv_assayTreeRule').val()).toEqual("assay tree rule goes here");
          });
          it("should fill the assay principle field", function() {
            return expect(this.pbc.$('.bv_assayPrinciple').val()).toEqual("assay principle goes here");
          });
          it("should fill the long description field", function() {
            return expect(this.pbc.$('.bv_description').html()).toEqual("protocol details go here");
          });
          it("should fill the comments field", function() {
            return expect(this.pbc.$('.bv_comments').html()).toEqual("protocol comments go here");
          });
          xit("should fill the protocol name field", function() {
            return expect(this.pbc.$('.bv_protocolName').val()).toEqual("FLIPR target A biochemical");
          });
          it("should fill the user field", function() {
            return expect(this.pbc.$('.bv_recordedBy').val()).toEqual("nxm7557");
          });
          it("should fill the protocol code field", function() {
            return expect(this.pbc.$('.bv_protocolCode').html()).toEqual("PROT-00000001");
          });
          it("should fill the protocol kind field", function() {
            return expect(this.pbc.$('.bv_protocolKind').html()).toEqual("default");
          });
          it("should fill the notebook field", function() {
            return expect(this.pbc.$('.bv_notebook').val()).toEqual("912");
          });
          it("should show the tags", function() {
            return expect(this.pbc.$('.bv_tags').tagsinput('items')[0]).toEqual("stuff");
          });
          it("show the status", function() {
            waitsFor(function() {
              return this.pbc.$('.bv_status option').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.pbc.$('.bv_status').val()).toEqual("created");
            });
          });
          return it("should show the status select enabled", function() {
            return expect(this.pbc.$('.bv_status').attr('disabled')).toBeUndefined();
          });
        });
        describe("Protocol status behavior", function() {
          it("should disable all fields if protocol is finalized", function() {
            waitsFor(function() {
              return this.pbc.$('.bv_status option').length > 0;
            }, 1000);
            return runs(function() {
              this.pbc.$('.bv_status').val('finalized');
              this.pbc.$('.bv_status').change();
              expect(this.pbc.$('.bv_notebook').attr('disabled')).toEqual('disabled');
              return expect(this.pbc.$('.bv_status').attr('disabled')).toBeUndefined();
            });
          });
          it("should enable all fields if entity is started", function() {
            this.pbc.$('.bv_status').val('finalized');
            this.pbc.$('.bv_status').change();
            this.pbc.$('.bv_status').val('started');
            this.pbc.$('.bv_status').change();
            return expect(this.pbc.$('.bv_notebook').attr('disabled')).toBeUndefined();
          });
          it("should hide lock icon if protocol is created", function() {
            this.pbc.$('.bv_status').val('created');
            this.pbc.$('.bv_status').change();
            return expect(this.pbc.$('.bv_lock')).toBeHidden();
          });
          return it("should show lock icon if protocol is finalized", function() {
            waitsFor(function() {
              return this.pbc.$('.bv_status option').length > 0;
            }, 1000);
            return runs(function() {
              this.pbc.$('.bv_status').val('finalized');
              this.pbc.$('.bv_status').change();
              return expect(this.pbc.$('.bv_lock')).toBeVisible();
            });
          });
        });
        return describe("User edits fields", function() {
          it("should update model when scientist is changed", function() {
            expect(this.pbc.model.get('recordedBy')).toEqual("nxm7557");
            this.pbc.$('.bv_recordedBy').val("xxl7932");
            this.pbc.$('.bv_recordedBy').change();
            return expect(this.pbc.model.get('recordedBy')).toEqual("xxl7932");
          });
          it("should update model when shortDescription is changed", function() {
            this.pbc.$('.bv_shortDescription').val(" New short description   ");
            this.pbc.$('.bv_shortDescription').change();
            return expect(this.pbc.model.get('shortDescription')).toEqual("New short description");
          });
          it("should set model shortDescription to a space when shortDescription is set to empty", function() {
            this.pbc.$('.bv_shortDescription').val("");
            this.pbc.$('.bv_shortDescription').change();
            return expect(this.pbc.model.get('shortDescription')).toEqual(" ");
          });
          it("should update model when assay tree rule changed", function() {
            var desc, states, values;
            this.pbc.$('.bv_assayTreeRule').val(" Updated assay tree rule  ");
            this.pbc.$('.bv_assayTreeRule').change();
            states = this.pbc.model.get('lsStates').getStatesByTypeAndKind("metadata", "protocol metadata");
            expect(states.length).toEqual(1);
            values = states[0].getValuesByTypeAndKind("stringValue", "assay tree rule");
            desc = values[0].get('stringValue');
            expect(desc).toEqual("Updated assay tree rule");
            return expect(this.pbc.model.getAssayTreeRule().get('stringValue')).toEqual("Updated assay tree rule");
          });
          it("should update model when assay principle is changed", function() {
            var desc, states, values;
            this.pbc.$('.bv_assayPrinciple').val(" New assay principle   ");
            this.pbc.$('.bv_assayPrinciple').change();
            states = this.pbc.model.get('lsStates').getStatesByTypeAndKind("metadata", "protocol metadata");
            expect(states.length).toEqual(1);
            values = states[0].getValuesByTypeAndKind("clobValue", "assay principle");
            desc = values[0].get('clobValue');
            expect(desc).toEqual("New assay principle");
            return expect(this.pbc.model.getAssayPrinciple().get('clobValue')).toEqual("New assay principle");
          });
          it("should update model when description is changed", function() {
            var desc, states, values;
            this.pbc.$('.bv_description').val(" New long description   ");
            this.pbc.$('.bv_description').change();
            states = this.pbc.model.get('lsStates').getStatesByTypeAndKind("metadata", "protocol metadata");
            expect(states.length).toEqual(1);
            values = states[0].getValuesByTypeAndKind("clobValue", "description");
            desc = values[0].get('clobValue');
            expect(desc).toEqual("New long description");
            return expect(this.pbc.model.getDescription().get('clobValue')).toEqual("New long description");
          });
          it("should update model when comments is changed", function() {
            var desc, states, values;
            this.pbc.$('.bv_comments').val(" New comments   ");
            this.pbc.$('.bv_comments').change();
            states = this.pbc.model.get('lsStates').getStatesByTypeAndKind("metadata", "protocol metadata");
            expect(states.length).toEqual(1);
            values = states[0].getValuesByTypeAndKind("clobValue", "comments");
            desc = values[0].get('clobValue');
            expect(desc).toEqual("New comments");
            return expect(this.pbc.model.getComments().get('clobValue')).toEqual("New comments");
          });
          it("should update model when protocol name is changed", function() {
            this.pbc.$('.bv_protocolName').val(" Updated protocol name   ");
            this.pbc.$('.bv_protocolName').change();
            return expect(this.pbc.model.get('lsLabels').pickBestLabel().get('labelText')).toEqual("Updated protocol name");
          });
          it("should update model when completion date is changed", function() {
            this.pbc.$('.bv_completionDate').val(" 2013-3-16   ");
            this.pbc.$('.bv_completionDate').change();
            return expect(this.pbc.model.getCompletionDate().get('dateValue')).toEqual(new Date(2013, 2, 16).getTime());
          });
          it("should update model when notebook is changed", function() {
            this.pbc.$('.bv_notebook').val(" Updated notebook  ");
            this.pbc.$('.bv_notebook').change();
            return expect(this.pbc.model.getNotebook().get('stringValue')).toEqual("Updated notebook");
          });
          it("should update model when tag added", function() {
            this.pbc.$('.bv_tags').tagsinput('add', "lucy");
            this.pbc.tagListController.handleTagsChanged();
            return expect(this.pbc.model.get('lsTags').at(2).get('tagText')).toEqual("lucy");
          });
          return it("should update model when protocol status changed", function() {
            waitsFor(function() {
              return this.pbc.$('.bv_status option').length > 0;
            }, 1000);
            return runs(function() {
              this.pbc.$('.bv_status').val('complete');
              this.pbc.$('.bv_status').change();
              return expect(this.pbc.model.getStatus().get('stringValue')).toEqual('complete');
            });
          });
        });
      });
      return describe("When created from a new protocol", function() {
        beforeEach(function() {
          this.prot = new Protocol();
          this.prot.getStatus().set({
            stringValue: "created"
          });
          this.pbc = new ProtocolBaseController({
            model: this.prot,
            el: $('#fixture')
          });
          return this.pbc.render();
        });
        describe("basic startup conditions", function() {
          it("should have protocol code not set", function() {
            return expect(this.pbc.$('.bv_protocolCode').val()).toEqual("");
          });
          it("should have protocol name not set", function() {
            return expect(this.pbc.$('.bv_protocolName').val()).toEqual("");
          });
          it("should not fill the date field", function() {
            return expect(this.pbc.$('.bv_completionDate').val()).toEqual("");
          });
          it("should show the save button text as Save", function() {
            return expect(this.pbc.$('.bv_save').html()).toEqual("Save");
          });
          it("should show the save button disabled", function() {
            return expect(this.pbc.$('.bv_save').attr('disabled')).toEqual('disabled');
          });
          it("should show the status select disabled", function() {
            return expect(this.pbc.$('.bv_status').attr('disabled')).toEqual('disabled');
          });
          it("should show status select value as created", function() {
            waitsFor(function() {
              return this.pbc.$('.bv_status option').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.pbc.$('.bv_status').val()).toEqual('created');
            });
          });
          return it("should have the assay tree rule be empty", function() {
            return expect(this.pbc.$('.bv_assayTreeRule').val()).toEqual("");
          });
        });
        return describe("controller validation rules", function() {
          beforeEach(function() {
            this.pbc.$('.bv_recordedBy').val("nxm7557");
            this.pbc.$('.bv_recordedBy').change();
            this.pbc.$('.bv_shortDescription').val(" New short description   ");
            this.pbc.$('.bv_shortDescription').change();
            this.pbc.$('.bv_protocolName').val(" Updated entity name   ");
            this.pbc.$('.bv_protocolName').change();
            this.pbc.$('.bv_completionDate').val(" 2013-3-16   ");
            this.pbc.$('.bv_completionDate').change();
            this.pbc.$('.bv_notebook').val("my notebook");
            return this.pbc.$('.bv_notebook').change();
          });
          describe("form validation setup", function() {
            it("should be valid if form fully filled out", function() {
              return runs(function() {
                return expect(this.pbc.isValid()).toBeTruthy();
              });
            });
            return it("save button should be enabled", function() {
              return runs(function() {
                return expect(this.pbc.$('.bv_save').attr('disabled')).toBeUndefined();
              });
            });
          });
          describe("when protocol name field not filled in", function() {
            beforeEach(function() {
              return runs(function() {
                this.pbc.$('.bv_protocolName').val("");
                return this.pbc.$('.bv_protocolName').change();
              });
            });
            it("should be invalid if protocol name not filled in", function() {
              return runs(function() {
                return expect(this.pbc.isValid()).toBeFalsy();
              });
            });
            it("should show error in name field", function() {
              return runs(function() {
                return expect(this.pbc.$('.bv_group_protocolName').hasClass('error')).toBeTruthy();
              });
            });
            return it("should show the save button disabled", function() {
              return runs(function() {
                return expect(this.pbc.$('.bv_save').attr('disabled')).toEqual('disabled');
              });
            });
          });
          describe("when scientist not selected", function() {
            beforeEach(function() {
              return runs(function() {
                this.pbc.$('.bv_recordedBy').val("");
                return this.pbc.$('.bv_recordedBy').change();
              });
            });
            return it("should show error on scientist dropdown", function() {
              return runs(function() {
                return expect(this.pbc.$('.bv_group_recordedBy').hasClass('error')).toBeTruthy();
              });
            });
          });
          describe("when date field not filled in", function() {
            beforeEach(function() {
              return runs(function() {
                this.pbc.$('.bv_completionDate').val("");
                return this.pbc.$('.bv_completionDate').change();
              });
            });
            return it("should show error in date field", function() {
              return runs(function() {
                return expect(this.pbc.$('.bv_group_completionDate').hasClass('error')).toBeTruthy();
              });
            });
          });
          describe("when notebook not filled", function() {
            beforeEach(function() {
              return runs(function() {
                this.pbc.$('.bv_notebook').val("");
                return this.pbc.$('.bv_notebook').change();
              });
            });
            return it("should show error on notebook dropdown", function() {
              return runs(function() {
                return expect(this.pbc.$('.bv_group_notebook').hasClass('error')).toBeTruthy();
              });
            });
          });
          return describe("expect save to work", function() {
            it("model should be valid and ready to save", function() {
              return runs(function() {
                return expect(this.pbc.model.isValid()).toBeTruthy();
              });
            });
            it("should update protocol code", function() {
              runs(function() {
                return this.pbc.$('.bv_save').click();
              });
              waits(1000);
              return runs(function() {
                return expect(this.pbc.$('.bv_protocolCode').html()).toEqual("PROT-00000001");
              });
            });
            return it("should show the save button text as Update", function() {
              runs(function() {
                return this.pbc.$('.bv_save').click();
              });
              waits(1000);
              return runs(function() {
                return expect(this.pbc.$('.bv_save').html()).toEqual("Update");
              });
            });
          });
        });
      });
    });
  });

}).call(this);
