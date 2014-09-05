(function() {
  beforeEach(function() {
    return this.fixture = $.clone($("#fixture").get(0));
  });

  afterEach(function() {
    $("#fixture").remove();
    return $("body").append($(this.fixture));
  });

  describe("Protocol module testing", function() {
    describe("AbstractProtocolParameter", function() {
      return it("should have defaults", function() {
        this.app = new AbstractProtocolParameter();
        return expect(this.app.get('parameter')).toEqual("abstractParameter");
      });
    });
    describe("Assay Activity Model testing", function() {
      describe("When loaded from new", function() {
        beforeEach(function() {
          return this.aa = new AssayActivity();
        });
        return describe("Existence and Defaults", function() {
          it("should be defined", function() {
            return expect(this.aa).toBeDefined();
          });
          return it("should have defaults", function() {
            return expect(this.aa.get('assayActivity')).toEqual("unassigned");
          });
        });
      });
      return describe("model validation tests", function() {
        beforeEach(function() {
          return this.aa = new AssayActivity(window.protocolServiceTestJSON.assayActivities[0]);
        });
        return it("should be valid as initialized", function() {
          return expect(this.aa.isValid()).toBeTruthy();
        });
      });
    });
    describe("Target Origin Model testing", function() {
      describe("When loaded from new", function() {
        beforeEach(function() {
          return this.tori = new TargetOrigin();
        });
        return describe("Existence and Defaults", function() {
          it("should be defined", function() {
            return expect(this.tori).toBeDefined();
          });
          return it("should have defaults", function() {
            return expect(this.tori.get('targetOrigin')).toEqual("unassigned");
          });
        });
      });
      return describe("model validation tests", function() {
        beforeEach(function() {
          return this.tori = new AssayActivity(window.protocolServiceTestJSON.targetOrigins[0]);
        });
        return it("should be valid as initialized", function() {
          return expect(this.tori.isValid()).toBeTruthy();
        });
      });
    });
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
          it('Should have an empty short description with a space as an oracle work-around', function() {
            return expect(this.prot.get('shortDescription')).toEqual(" ");
          });
          it('Should have an empty assay tree rule', function() {
            return expect(this.prot.get('assayTreeRule')).toEqual(null);
          });
          it('Should have the select DNS target list be checked', function() {
            return expect(this.prot.get('dnsTargetList')).toEqual(true);
          });
          it('Should have the assayStage default to unassigned', function() {
            return expect(this.prot.get('assayStage')).toEqual("unassigned");
          });
          it('Should have an default maxY curve display of 100', function() {
            return expect(this.prot.get('maxY')).toEqual(100);
          });
          it('Should have an default minY curve display of 0', function() {
            return expect(this.prot.get('minY')).toEqual(0);
          });
          it('Should have an assay activity list', function() {
            return expect(this.prot.get('assayActivityList') instanceof AssayActivityList).toBeTruthy();
          });
          return it('Should have a targetOrigin list', function() {
            return expect(this.prot.get('targetOriginList') instanceof TargetOriginList).toBeTruthy();
          });
        });
        describe("required states and values", function() {
          it('Should have a description value', function() {
            expect(this.prot.getDescription() instanceof Value).toBeTruthy();
            return expect(this.prot.getDescription().get('clobValue')).toEqual("");
          });
          it('Should have a notebook value', function() {
            return expect(this.prot.getNotebook() instanceof Value).toBeTruthy();
          });
          return it('Protocol status should default to created ', function() {
            return expect(this.prot.getStatus().get('stringValue')).toEqual("created");
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
            return expect(this.prot.get('lsStates').at(0).get('lsKind')).toEqual("protocol controls");
          });
          it("states should have values", function() {
            return expect(this.prot.get('lsStates').at(0).get('lsValues').at(0).get('lsKind')).toEqual("data analysis parameters");
          });
          it('Should have a description value', function() {
            return expect(this.prot.getDescription().get('clobValue')).toEqual("long description goes here");
          });
          it('Should have a notebook value', function() {
            return expect(this.prot.getNotebook().get('stringValue')).toEqual("912");
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
        it("should convert tags has to collection of Tags", function() {
          return runs(function() {
            return expect(this.prot.get('lsTags') instanceof TagList).toBeTruthy();
          });
        });
        it('should convert assayActivityList to AssayActivityList', function() {
          return runs(function() {
            return expect(this.prot.get('assayActivityList') instanceof AssayActivityList).toBeTruthy();
          });
        });
        return it('should convert targetOriginList to TargetOriginList', function() {
          return runs(function() {
            console.log(this.prot.get('targetOriginList'));
            return expect(this.prot.get('targetOriginList') instanceof TargetOriginList).toBeTruthy();
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
        it("should be invalid when maxY is NaN", function() {
          var filtErrors;
          this.prot.set({
            maxY: NaN
          });
          expect(this.prot.isValid()).toBeFalsy();
          filtErrors = _.filter(this.prot.validationError, function(err) {
            return err.attribute === 'maxY';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        return it("should be invalid when minY is NaN", function() {
          var filtErrors;
          this.prot.set({
            minY: NaN
          });
          expect(this.prot.isValid()).toBeFalsy();
          filtErrors = _.filter(this.prot.validationError, function(err) {
            return err.attribute === 'minY';
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
    describe("Assay Activity List testing", function() {
      describe("When loaded from new", function() {
        beforeEach(function() {
          return this.aal = new AssayActivityList();
        });
        return describe("Existence", function() {
          return it("should be defined", function() {
            return expect(this.aal).toBeDefined();
          });
        });
      });
      describe("When loaded form existing", function() {
        beforeEach(function() {
          return this.aal = new AssayActivityList(window.protocolServiceTestJSON.assayActivities);
        });
        it("should have two assay activities", function() {
          return expect(this.aal.length).toEqual(2);
        });
        it("should have the correct info for the first assay activity", function() {
          var assayOne;
          assayOne = this.aal.at(0);
          return expect(assayOne.get('assayActivity')).toEqual("luminescence");
        });
        return it("should have the correct info for the second assay activity", function() {
          var assayTwo;
          assayTwo = this.aal.at(1);
          return expect(assayTwo.get('assayActivity')).toEqual("fluorescence");
        });
      });
      return describe("collection validation", function() {
        beforeEach(function() {
          return this.aal = new AssayActivityList(window.protocolServiceTestJSON.assayActivities);
        });
        return it("should be invalid if a assay activity is selected more than once", function() {
          this.aal.at(0).set({
            assayActivity: "luminescence"
          });
          this.aal.at(1).set({
            assayActivity: "luminescence"
          });
          return expect((this.aal.validateCollection()).length).toBeGreaterThan(0);
        });
      });
    });
    describe("Target Origin List testing", function() {
      describe("When loaded from new", function() {
        beforeEach(function() {
          return this.tol = new TargetOriginList();
        });
        return describe("Existence", function() {
          return it("should be defined", function() {
            return expect(this.tol).toBeDefined();
          });
        });
      });
      describe("When loaded form existing", function() {
        beforeEach(function() {
          return this.tol = new TargetOriginList(window.protocolServiceTestJSON.targetOrigins);
        });
        it("should have two target origins", function() {
          return expect(this.tol.length).toEqual(2);
        });
        it("should have the correct info for the first target origin", function() {
          var targetOne;
          targetOne = this.tol.at(0);
          return expect(targetOne.get('targetOrigin')).toEqual("human");
        });
        return it("should have the correct info for the second target origin", function() {
          var targetTwo;
          targetTwo = this.tol.at(1);
          return expect(targetTwo.get('targetOrigin')).toEqual("chimpanzee");
        });
      });
      return describe("collection validation", function() {
        beforeEach(function() {
          return this.tol = new TargetOriginList(window.protocolServiceTestJSON.targetOrigins);
        });
        return it("should be invalid if a assay activity is selected more than once", function() {
          this.tol.at(0).set({
            targetOrigin: "human"
          });
          this.tol.at(1).set({
            targetOrigin: "human"
          });
          return expect((this.tol.validateCollection()).length).toBeGreaterThan(0);
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
    describe("AssayActivityController", function() {
      return describe("when instantiated", function() {
        beforeEach(function() {
          this.aac = new AssayActivityController({
            model: new AssayActivity(window.protocolServiceTestJSON.assayActivities[0]),
            el: $('#fixture')
          });
          return this.aac.render();
        });
        describe("basic existance tests", function() {
          it("should exist", function() {
            return expect(this.aac).toBeDefined();
          });
          return it("should load a template", function() {
            return expect(this.aac.$('.bv_assayActivity').length).toEqual(1);
          });
        });
        describe("render existing parameters", function() {
          return it("should show assay activity", function() {
            waitsFor(function() {
              return this.aac.$('.bv_assayActivity option').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.aac.$('.bv_assayActivity').val()).toEqual("luminescence");
            });
          });
        });
        return describe("model updates", function() {
          return it("should update the assay activity", function() {
            waitsFor(function() {
              return this.aac.$('.bv_assayActivity option').length > 0;
            }, 1000);
            return runs(function() {
              this.aac.$('.bv_assayActivity').val("fluorescence");
              this.aac.$('.bv_assayActivity').change();
              return expect(this.aac.model.get('assayActivity')).toEqual("fluorescence");
            });
          });
        });
      });
    });
    describe("TargetOriginController", function() {
      return describe("when instantiated", function() {
        beforeEach(function() {
          this.toc = new TargetOriginController({
            model: new TargetOrigin(window.protocolServiceTestJSON.targetOrigins[0]),
            el: $('#fixture')
          });
          return this.toc.render();
        });
        describe("basic existance tests", function() {
          it("should exist", function() {
            return expect(this.toc).toBeDefined();
          });
          return it("should load a template", function() {
            return expect(this.toc.$('.bv_targetOrigin').length).toEqual(1);
          });
        });
        describe("render existing parameters", function() {
          return it("should show target origin", function() {
            waitsFor(function() {
              return this.toc.$('.bv_targetOrigin option').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.toc.$('.bv_targetOrigin').val()).toEqual("human");
            });
          });
        });
        return describe("model updates", function() {
          return it("should update the target origin ", function() {
            waitsFor(function() {
              return this.toc.$('.bv_targetOrigin option').length > 0;
            }, 1000);
            return runs(function() {
              this.toc.$('.bv_targetOrigin').val("chimpanzee");
              this.toc.$('.bv_targetOrigin').change();
              return expect(this.toc.model.get('targetOrigin')).toEqual("chimpanzee");
            });
          });
        });
      });
    });
    describe("Assay Activity List Controller testing", function() {
      describe("when instantiated with no data", function() {
        beforeEach(function() {
          this.aalc = new AssayActivityListController({
            el: $('#fixture'),
            collection: new AssayActivityList()
          });
          return this.aalc.render();
        });
        describe("basic existence tests", function() {
          it("should exist", function() {
            return expect(this.aalc).toBeDefined();
          });
          return it("should load a template", function() {
            return expect(this.aalc.$('.bv_addActivityButton').length).toEqual(1);
          });
        });
        describe("rendering", function() {
          return it("should show one activity", function() {
            expect(this.aalc.$('.bv_assayActivityInfo .bv_assayActivity').length).toEqual(1);
            return expect(this.aalc.collection.length).toEqual(1);
          });
        });
        return describe("adding and removing", function() {
          it("should have two activities when add button is clicked", function() {
            this.aalc.$('.bv_addActivityButton').click();
            expect(this.aalc.$('.bv_assayActivityInfo .bv_assayActivity').length).toEqual(2);
            return expect(this.aalc.collection.length).toEqual(2);
          });
          it("should have one activity when there are two activities and remove is clicked", function() {
            this.aalc.$('.bv_addActivityButton').click();
            expect(this.aalc.$('.bv_assayActivityInfo .bv_assayActivity').length).toEqual(2);
            this.aalc.$('.bv_deleteActivity:eq(0)').click();
            expect(this.aalc.$('.bv_assayActivityInfo .bv_assayActivity').length).toEqual(1);
            return expect(this.aalc.collection.length).toEqual(1);
          });
          return it("should always have one activity", function() {
            expect(this.aalc.collection.length).toEqual(1);
            this.aalc.$('.bv_deleteActivity').click();
            expect(this.aalc.$('.bv_assayActivityInfo .bv_assayActivity').length).toEqual(1);
            return expect(this.aalc.collection.length).toEqual(1);
          });
        });
      });
      return describe("when instantiated with data", function() {
        beforeEach(function() {
          this.aalc = new AssayActivityListController({
            el: $('#fixture'),
            collection: new AssayActivityList(window.protocolServiceTestJSON.assayActivities)
          });
          return this.aalc.render();
        });
        it("should have two activities", function() {
          expect(this.aalc.$('.bv_assayActivityInfo .bv_assayActivity').length).toEqual(2);
          return expect(this.aalc.collection.length).toEqual(2);
        });
        it("should have the correct info for the first activity", function() {
          waitsFor(function() {
            return this.aalc.$('.bv_assayActivity option').length > 0;
          }, 1000);
          return runs(function() {
            return expect(this.aalc.$('.bv_assayActivityInfo .bv_assayActivity:eq(0)').val()).toEqual("luminescence");
          });
        });
        return it("should have the correct info for the second activity", function() {
          waitsFor(function() {
            return this.aalc.$('.bv_assayActivity option').length > 0;
          }, 1000);
          return runs(function() {
            return expect(this.aalc.$('.bv_assayActivityInfo .bv_assayActivity:eq(1)').val()).toEqual("fluorescence");
          });
        });
      });
    });
    describe("Target Origin List Controller testing", function() {
      describe("when instantiated with no data", function() {
        beforeEach(function() {
          this.tolc = new TargetOriginListController({
            el: $('#fixture'),
            collection: new TargetOriginList()
          });
          return this.tolc.render();
        });
        describe("basic existence tests", function() {
          it("should exist", function() {
            return expect(this.tolc).toBeDefined();
          });
          return it("should load a template", function() {
            return expect(this.tolc.$('.bv_addTargetOriginButton').length).toEqual(1);
          });
        });
        describe("rendering", function() {
          return it("should show one target origin", function() {
            expect(this.tolc.$('.bv_targetOriginInfo .bv_targetOrigin').length).toEqual(1);
            return expect(this.tolc.collection.length).toEqual(1);
          });
        });
        return describe("adding and removing", function() {
          it("should have two target origins when add button is clicked", function() {
            this.tolc.$('.bv_addTargetOriginButton').click();
            expect(this.tolc.$('.bv_targetOriginInfo .bv_targetOrigin').length).toEqual(2);
            return expect(this.tolc.collection.length).toEqual(2);
          });
          it("should have one target origin when there are two target origins and remove is clicked", function() {
            this.tolc.$('.bv_addTargetOriginButton').click();
            expect(this.tolc.$('.bv_targetOriginInfo .bv_targetOrigin').length).toEqual(2);
            this.tolc.$('.bv_deleteTargetOrigin:eq(0)').click();
            expect(this.tolc.$('.bv_targetOriginInfo .bv_targetOrigin').length).toEqual(1);
            return expect(this.tolc.collection.length).toEqual(1);
          });
          return it("should always have one target origin", function() {
            expect(this.tolc.collection.length).toEqual(1);
            this.tolc.$('.bv_deleteTargetOrigin').click();
            expect(this.tolc.$('.bv_targetOriginInfo .bv_targetOrigin').length).toEqual(1);
            return expect(this.tolc.collection.length).toEqual(1);
          });
        });
      });
      return describe("when instantiated with data", function() {
        beforeEach(function() {
          this.tolc = new TargetOriginListController({
            el: $('#fixture'),
            collection: new TargetOriginList(window.protocolServiceTestJSON.targetOrigins)
          });
          return this.tolc.render();
        });
        it("should have two target origin", function() {
          expect(this.tolc.$('.bv_targetOriginInfo .bv_targetOrigin').length).toEqual(2);
          return expect(this.tolc.collection.length).toEqual(2);
        });
        it("should have the correct info for the first target origin", function() {
          waitsFor(function() {
            return this.tolc.$('.bv_targetOrigin option').length > 0;
          }, 1000);
          return runs(function() {
            return expect(this.tolc.$('.bv_targetOriginInfo .bv_targetOrigin:eq(0)').val()).toEqual("human");
          });
        });
        return it("should have the correct info for the second target origin", function() {
          waitsFor(function() {
            return this.tolc.$('.bv_targetOrigin option').length > 0;
          }, 1000);
          return runs(function() {
            return expect(this.tolc.$('.bv_targetOriginInfo .bv_targetOrigin:eq(1)').val()).toEqual("chimpanzee");
          });
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
          it("should fill the long description field", function() {
            return expect(this.pbc.$('.bv_description').html()).toEqual("long description goes here");
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
          it("should show the status select enabled", function() {
            return expect(this.pbc.$('.bv_status').attr('disabled')).toBeUndefined();
          });
          it("should fill the assay tree rule", function() {
            return expect(this.pbc.$('.bv_assayTreeRule').val()).toEqual("example assay tree rule");
          });
          it("should have the select dns target list checkbox checked", function() {
            return expect(this.pbc.$('.bv_dnsTargetList').attr("checked")).toEqual("checked");
          });
          it("should show the assay stage", function() {
            waitsFor(function() {
              return this.pbc.$('.bv_assayStage option').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.pbc.$('.bv_assayStage').val()).toEqual("assay development");
            });
          });
          it("should fill the max Y value", function() {
            return expect(this.pbc.$('.bv_maxY').val()).toEqual("200");
          });
          return it("should fill the min Y value", function() {
            return expect(this.pbc.$('.bv_minY').val()).toEqual("2");
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
          it("should update model when protocol name is changed", function() {
            this.pbc.$('.bv_protocolName').val(" Updated protocol name   ");
            this.pbc.$('.bv_protocolName').change();
            return expect(this.pbc.model.get('lsLabels').pickBestLabel().get('labelText')).toEqual("Updated protocol name");
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
          it("should update model when protocol status changed", function() {
            waitsFor(function() {
              return this.pbc.$('.bv_status option').length > 0;
            }, 1000);
            return runs(function() {
              this.pbc.$('.bv_status').val('complete');
              this.pbc.$('.bv_status').change();
              return expect(this.pbc.model.getStatus().get('stringValue')).toEqual('complete');
            });
          });
          it("should update model when assay tree rule changed", function() {
            this.pbc.$('.bv_assayTreeRule').val(" Updated assay tree rule  ");
            this.pbc.$('.bv_assayTreeRule').change();
            return expect(this.pbc.model.get('assayTreeRule')).toEqual("Updated assay tree rule");
          });
          it("should update the select DNS target list", function() {
            this.pbc.$('.bv_dnsTargetList').click();
            this.pbc.$('.bv_dnsTargetList').click();
            return expect(this.pbc.model.get('dnsTargetList')).toBeFalsy();
          });
          it("should update model when assay stage changed", function() {
            waitsFor(function() {
              return this.pbc.$('.bv_assayStage option').length > 0;
            }, 1000);
            return runs(function() {
              this.pbc.$('.bv_assayStage').val('unassigned');
              this.pbc.$('.bv_assayStage').change();
              return expect(this.pbc.model.get('assayStage')).toEqual('unassigned');
            });
          });
          it("should update model when maxY changed", function() {
            this.pbc.$('.bv_maxY').val(" 50  ");
            this.pbc.$('.bv_maxY').change();
            return expect(this.pbc.model.get('maxY')).toEqual(50);
          });
          return it("should update model when minY changed", function() {
            this.pbc.$('.bv_minY').val(" 5  ");
            this.pbc.$('.bv_minY').change();
            return expect(this.pbc.model.get('minY')).toEqual(5);
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
          it("should have the assay tree rule be empty", function() {
            return expect(this.pbc.$('.bv_assayTreeRule').val()).toEqual("");
          });
          it("should have the select dns target list be checked", function() {
            return expect(this.pbc.$('.bv_dnsTargetList').attr("checked")).toEqual("checked");
          });
          it("should show assay stage select value as unassigned", function() {
            waitsFor(function() {
              return this.pbc.$('.bv_assayStage option').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.pbc.$('.bv_assayStage').val()).toEqual('unassigned');
            });
          });
          it("should have the maxY value be 100", function() {
            return expect(this.pbc.$('.bv_maxY').val()).toEqual('100');
          });
          return it("should have the minY value be 100", function() {
            return expect(this.pbc.$('.bv_minY').val()).toEqual('0');
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
          describe("when maxY is NaN", function() {
            beforeEach(function() {
              return runs(function() {
                this.pbc.$('.bv_maxY').val("b");
                return this.pbc.$('.bv_maxY').change();
              });
            });
            return it("should show error on maxY field", function() {
              return runs(function() {
                return expect(this.pbc.$('.bv_group_maxY').hasClass('error')).toBeTruthy();
              });
            });
          });
          describe("when minY is NaN", function() {
            beforeEach(function() {
              return runs(function() {
                this.pbc.$('.bv_minY').val("b");
                return this.pbc.$('.bv_minY').change();
              });
            });
            return it("should show error on minY field", function() {
              return runs(function() {
                return expect(this.pbc.$('.bv_group_minY').hasClass('error')).toBeTruthy();
              });
            });
          });
          describe("when assay activity is selected more than once", function() {
            return it("should show error for each of the duplicated activities", function() {
              this.pbc.$('.bv_addActivityButton').click();
              waitsFor(function() {
                return this.pbc.$('.bv_assayActivityInfo .bv_assayActivity option').length > 0;
              }, 1000);
              return runs(function() {
                this.pbc.$('.bv_assayActivity:eq(0)').val("fluorescence");
                this.pbc.$('.bv_assayActivity:eq(0)').change();
                this.pbc.$('.bv_assayActivity:eq(1)').val("fluorescence");
                this.pbc.$('.bv_assayActivity:eq(1)').change();
                expect(this.pbc.$('.bv_group_assayActivity:eq(0)').hasClass('error')).toBeTruthy();
                return expect(this.pbc.$('.bv_group_assayActivity:eq(1)').hasClass('error')).toBeTruthy();
              });
            });
          });
          describe("when target origin is selected more than once", function() {
            return it("should show error for each of the duplicated target origins", function() {
              this.pbc.$('.bv_addTargetOriginButton').click();
              waitsFor(function() {
                return this.pbc.$('.bv_targetOriginInfo .bv_targetOrigin option').length > 0;
              }, 1000);
              return runs(function() {
                this.pbc.$('.bv_targetOrigin:eq(0)').val("human");
                this.pbc.$('.bv_targetOrigin:eq(0)').change();
                this.pbc.$('.bv_targetOrigin:eq(1)').val("human");
                this.pbc.$('.bv_targetOrigin:eq(1)').change();
                expect(this.pbc.$('.bv_group_targetOrigin:eq(0)').hasClass('error')).toBeTruthy();
                return expect(this.pbc.$('.bv_group_targetOrigin:eq(1)').hasClass('error')).toBeTruthy();
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
