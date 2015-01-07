(function() {
  beforeEach(function() {
    return this.fixture = $.clone($("#fixture").get(0));
  });

  afterEach(function() {
    $("#fixture").remove();
    return $("body").append($(this.fixture));
  });

  describe('Internalization Agent testing', function() {
    describe("Internalization Agent Parent model testing", function() {
      describe("when loaded from new", function() {
        beforeEach(function() {
          return this.iap = new InternalizationAgentParent();
        });
        describe("Existence and Defaults", function() {
          it("should be defined", function() {
            return expect(this.iap).toBeDefined();
          });
          it("should have a type", function() {
            return expect(this.iap.get('lsType')).toEqual("parent");
          });
          it("should have a kind", function() {
            return expect(this.iap.get('lsKind')).toEqual("internalization agent");
          });
          it("should have an empty scientist", function() {
            return expect(this.iap.get('recordedBy')).toEqual("");
          });
          it("should have a recordedDate set to now", function() {
            return expect(new Date(this.iap.get('recordedDate')).getHours()).toEqual(new Date().getHours());
          });
          it("Should have a lsLabels with one label", function() {
            expect(this.iap.get('lsLabels')).toBeDefined();
            expect(this.iap.get("lsLabels").length).toEqual(1);
            return expect(this.iap.get("lsLabels").getLabelByTypeAndKind("name", "internalization agent").length).toEqual(1);
          });
          it("Should have a model attribute for the label in defaultLabels", function() {
            return expect(this.iap.get("internalization agent name")).toBeDefined();
          });
          it("Should have a lsStates with the states in defaultStates", function() {
            expect(this.iap.get('lsStates')).toBeDefined();
            expect(this.iap.get("lsStates").length).toEqual(1);
            return expect(this.iap.get("lsStates").getStatesByTypeAndKind("metadata", "internalization agent parent").length).toEqual(1);
          });
          return describe("model attributes for each value in defaultValues", function() {
            it("Should have a model attribute for completion date", function() {
              return expect(this.iap.get("completion date")).toBeDefined();
            });
            it("Should have a model attribute for notebook", function() {
              return expect(this.iap.get("notebook")).toBeDefined();
            });
            it("Should have a model attribute for conjugation type", function() {
              return expect(this.iap.get("conjugation type")).toBeDefined();
            });
            return it("Should have a model attribute for conjugation site", function() {
              return expect(this.iap.get("conjugation site")).toBeDefined();
            });
          });
        });
        return describe("model validation", function() {
          it("should be invalid when name is empty", function() {
            var filtErrors;
            this.iap.get("internalization agent name").set("labelText", "");
            expect(this.iap.isValid()).toBeFalsy();
            filtErrors = _.filter(this.iap.validationError, function(err) {
              return err.attribute === 'parentName';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
          it("should invalid when recorded date is empty", function() {
            var filtErrors;
            this.iap.set({
              recordedDate: new Date("").getTime()
            });
            expect(this.iap.isValid()).toBeFalsy();
            filtErrors = _.filter(this.iap.validationError, function(err) {
              return err.attribute === 'recordedDate';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
          it("should be invalid when conjugation type is not selected", function() {
            var filtErrors;
            this.iap.get("conjugation type").set("value", "unassigned");
            expect(this.iap.isValid()).toBeFalsy();
            filtErrors = _.filter(this.iap.validationError, function(err) {
              return err.attribute === 'conjugationType';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
          return it("should be invalid when conjugation site is not selected", function() {
            var filtErrors;
            this.iap.get("conjugation site").set("value", "unassigned");
            expect(this.iap.isValid()).toBeFalsy();
            filtErrors = _.filter(this.iap.validationError, function(err) {
              return err.attribute === 'conjugationSite';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
        });
      });
      return describe("When created from existing", function() {
        beforeEach(function() {
          return this.iap = new InternalizationAgentParent(JSON.parse(JSON.stringify(window.internalizationAgentTestJSON.internalizationAgentParent)));
        });
        describe("after initial load", function() {
          it("should be defined", function() {
            return expect(this.iap).toBeDefined();
          });
          it("should have a type", function() {
            return expect(this.iap.get('lsType')).toEqual("parent");
          });
          it("should have a kind", function() {
            return expect(this.iap.get('lsKind')).toEqual("internalization agent");
          });
          it("should have a scientist set", function() {
            return expect(this.iap.get('recordedBy')).toEqual("jane");
          });
          it("should have a recordedDate set", function() {
            return expect(this.iap.get('recordedDate')).toEqual(1375141508000);
          });
          it("Should have label set", function() {
            var label;
            console.log(this.iap);
            expect(this.iap.get("internalization agent name").get("labelText")).toEqual("EGRF 31-PEG10-Ad");
            label = this.iap.get("lsLabels").getLabelByTypeAndKind("name", "internalization agent");
            console.log(label[0]);
            return expect(label[0].get('labelText')).toEqual("EGRF 31-PEG10-Ad");
          });
          it("Should have a lsStates with the states in defaultStates", function() {
            expect(this.iap.get('lsStates')).toBeDefined();
            expect(this.iap.get("lsStates").length).toEqual(1);
            return expect(this.iap.get("lsStates").getStatesByTypeAndKind("metadata", "internalization agent parent").length).toEqual(1);
          });
          it("Should have a completion date value", function() {
            return expect(this.iap.get("completion date").get("value")).toEqual(1342080000000);
          });
          it("Should have a notebook value", function() {
            return expect(this.iap.get("notebook").get("value")).toEqual("Notebook 1");
          });
          it("Should have a conjugation type value", function() {
            return expect(this.iap.get("conjugation type").get("value")).toEqual("conjugated");
          });
          return it("Should have a conjugation site value", function() {
            return expect(this.iap.get("conjugation site").get("value")).toEqual("cys");
          });
        });
        return describe("model validation", function() {
          beforeEach(function() {
            return this.iap = new InternalizationAgentParent(window.internalizationAgentTestJSON.internalizationAgentParent);
          });
          it("should be valid when loaded from saved", function() {
            return expect(this.iap.isValid()).toBeTruthy();
          });
          it("should be invalid when name is empty", function() {
            var filtErrors;
            this.iap.get("internalization agent name").set("labelText", "");
            expect(this.iap.isValid()).toBeFalsy();
            filtErrors = _.filter(this.iap.validationError, function(err) {
              return err.attribute === 'parentName';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
          it("should be invalid when recorded date is empty", function() {
            var filtErrors;
            this.iap.set({
              recordedDate: new Date("").getTime()
            });
            expect(this.iap.isValid()).toBeFalsy();
            filtErrors = _.filter(this.iap.validationError, function(err) {
              return err.attribute === 'recordedDate';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
          it("should be invalid when scientist not selected", function() {
            var filtErrors;
            this.iap.set({
              recordedBy: ""
            });
            expect(this.iap.isValid()).toBeFalsy();
            filtErrors = _.filter(this.iap.validationError, function(err) {
              return err.attribute === 'recordedBy';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
          it("should be invalid when completion date is empty", function() {
            var filtErrors;
            this.iap.get("completion date").set("value", new Date("").getTime());
            expect(this.iap.isValid()).toBeFalsy();
            filtErrors = _.filter(this.iap.validationError, function(err) {
              return err.attribute === 'completionDate';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
          it("should be invalid when notebook is empty", function() {
            var filtErrors;
            this.iap.get("notebook").set("value", "");
            expect(this.iap.isValid()).toBeFalsy();
            filtErrors = _.filter(this.iap.validationError, function(err) {
              return err.attribute === 'notebook';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
          it("should be invalid when conjugation type is not selected", function() {
            var filtErrors;
            this.iap.get("conjugation type").set("value", "unassigned");
            expect(this.iap.isValid()).toBeFalsy();
            filtErrors = _.filter(this.iap.validationError, function(err) {
              return err.attribute === 'conjugationType';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
          return it("should be invalid when conjugation site is not selected", function() {
            var filtErrors;
            this.iap.get("conjugation site").set("value", "unassigned");
            expect(this.iap.isValid()).toBeFalsy();
            filtErrors = _.filter(this.iap.validationError, function(err) {
              return err.attribute === 'conjugationSite';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
        });
      });
    });
    describe("InternalizationAgent Parent Controller testing", function() {
      describe("When instantiated from new", function() {
        beforeEach(function() {
          this.iap = new InternalizationAgentParent();
          this.iapc = new InternalizationAgentParentController({
            model: this.iap,
            el: $('#fixture')
          });
          return this.iapc.render();
        });
        return describe("basic existence tests", function() {
          it("should exist", function() {
            return expect(this.iapc).toBeDefined();
          });
          it("should load the template", function() {
            return expect(this.iapc.$('.bv_parentCode').html()).toEqual("Autofilled when saved");
          });
          return it("should load the additional parent attributes template", function() {
            return expect(this.iapc.$('.bv_conjugationType').length).toEqual(1);
          });
        });
      });
      return describe("When instantiated from existing", function() {
        beforeEach(function() {
          this.iap = new InternalizationAgentParent(JSON.parse(JSON.stringify(window.internalizationAgentTestJSON.internalizationAgentParent)));
          this.iapc = new InternalizationAgentParentController({
            model: this.iap,
            el: $('#fixture')
          });
          return this.iapc.render();
        });
        describe("render existing parameters", function() {
          it("should show the internalization agent parent id", function() {
            return expect(this.iapc.$('.bv_parentCode').val()).toEqual("I000001");
          });
          it("should fill the internalization agent parent name", function() {
            return expect(this.iapc.$('.bv_parentName').val()).toEqual("EGRF 31-PEG10-Ad");
          });
          it("should fill the scientist field", function() {
            waitsFor(function() {
              return this.iapc.$('.bv_recordedBy option').length > 0;
            }, 1000);
            return runs(function() {
              console.log(this.iapc.$('.bv_recordedBy').val());
              return expect(this.iapc.$('.bv_recordedBy').val()).toEqual("jane");
            });
          });
          it("should fill the completion date field", function() {
            return expect(this.iapc.$('.bv_completionDate').val()).toEqual("2012-07-12");
          });
          it("should fill the notebook field", function() {
            return expect(this.iapc.$('.bv_notebook').val()).toEqual("Notebook 1");
          });
          it("should fill the conjugation type field", function() {
            waitsFor(function() {
              return this.iapc.$('.bv_conjugationType option').length > 0;
            }, 1000);
            return runs(function() {
              console.log(this.iapc.$('.bv_conjugationType').val());
              console.log(this.iapc.model);
              return expect(this.iapc.$('.bv_conjugationType').val()).toEqual("conjugated");
            });
          });
          return it("should fill the conjugation site field", function() {
            waitsFor(function() {
              return this.iapc.$('.bv_conjugationSite option').length > 0;
            }, 1000);
            return runs(function() {
              console.log(this.iapc.$('.bv_conjugationSite').val());
              console.log(this.iapc.model);
              return expect(this.iapc.$('.bv_conjugationSite').val()).toEqual("cys");
            });
          });
        });
        describe("model updates", function() {
          it("should update model when parent name is changed", function() {
            this.iapc.$('.bv_parentName').val(" New name   ");
            this.iapc.$('.bv_parentName').change();
            return expect(this.iapc.model.get('internalization agent name').get('labelText')).toEqual("New name");
          });
          it("should update model when the scientist is changed", function() {
            waitsFor(function() {
              return this.iapc.$('.bv_recordedBy option').length > 0;
            }, 1000);
            return runs(function() {
              this.iapc.$('.bv_recordedBy').val('unassigned');
              this.iapc.$('.bv_recordedBy').change();
              return expect(this.iapc.model.get('recordedBy')).toEqual("unassigned");
            });
          });
          it("should update model when completion date is changed", function() {
            this.iapc.$('.bv_completionDate').val(" 2013-3-16   ");
            this.iapc.$('.bv_completionDate').change();
            return expect(this.iapc.model.get('completion date').get('value')).toEqual(new Date(2013, 2, 16).getTime());
          });
          it("should update model when notebook is changed", function() {
            this.iapc.$('.bv_notebook').val(" Updated notebook  ");
            this.iapc.$('.bv_notebook').change();
            return expect(this.iapc.model.get('notebook').get('value')).toEqual("Updated notebook");
          });
          it("should update model when the conjugation type is changed", function() {
            waitsFor(function() {
              return this.iapc.$('.bv_conjugationType option').length > 0;
            }, 1000);
            return runs(function() {
              this.iapc.$('.bv_conjugationType').val('unassigned');
              this.iapc.$('.bv_conjugationType').change();
              return expect(this.iapc.model.get('conjugation type').get('value')).toEqual("unassigned");
            });
          });
          return it("should update model when the conjugation site is changed", function() {
            waitsFor(function() {
              return this.iapc.$('.bv_conjugationSite option').length > 0;
            }, 1000);
            return runs(function() {
              this.iapc.$('.bv_conjugationSite').val('unassigned');
              this.iapc.$('.bv_conjugationSite').change();
              return expect(this.iapc.model.get('conjugation site').get('value')).toEqual("unassigned");
            });
          });
        });
        return describe("controller validation rules", function() {
          beforeEach(function() {
            waitsFor(function() {
              return this.iapc.$('.bv_recordedBy option').length > 0;
            }, 1000);
            return runs(function() {
              this.iapc.$('.bv_parentName').val(" Updated entity name   ");
              this.iapc.$('.bv_parentName').change();
              this.iapc.$('.bv_recordedBy').val("bob");
              this.iapc.$('.bv_recordedBy').change();
              this.iapc.$('.bv_completionDate').val(" 2013-3-16   ");
              this.iapc.$('.bv_completionDate').change();
              this.iapc.$('.bv_notebook').val("my notebook");
              this.iapc.$('.bv_notebook').change();
              this.iapc.$('.bv_conjugationType').val("unconjugated");
              this.iapc.$('.bv_conjugationType').change();
              this.iapc.$('.bv_conjugationSite').val("lys");
              return this.iapc.$('.bv_conjugationSite').change();
            });
          });
          describe("form validation setup", function() {
            it("should be valid if form fully filled out", function() {
              return runs(function() {
                return expect(this.iapc.isValid()).toBeTruthy();
              });
            });
            return it("should have the update button be enabled", function() {
              return runs(function() {
                return expect(this.iapc.$('.bv_updateParent').attr('disabled')).toBeUndefined();
              });
            });
          });
          describe("when name field not filled in", function() {
            beforeEach(function() {
              return runs(function() {
                this.iapc.$('.bv_parentName').val("");
                return this.iapc.$('.bv_parentName').change();
              });
            });
            it("should be invalid if name not filled in", function() {
              return runs(function() {
                return expect(this.iapc.isValid()).toBeFalsy();
              });
            });
            it("should show error in name field", function() {
              return runs(function() {
                return expect(this.iapc.$('.bv_group_parentName').hasClass('error')).toBeTruthy();
              });
            });
            return it("should have the update button be disabled", function() {
              return runs(function() {
                return expect(this.iapc.$('.bv_updateParent').attr('disabled')).toEqual('disabled');
              });
            });
          });
          describe("when scientist not selected", function() {
            beforeEach(function() {
              return runs(function() {
                this.iapc.$('.bv_recordedBy').val("");
                return this.iapc.$('.bv_recordedBy').change();
              });
            });
            return it("should show error on scientist dropdown", function() {
              return runs(function() {
                return expect(this.iapc.$('.bv_group_recordedBy').hasClass('error')).toBeTruthy();
              });
            });
          });
          describe("when date field not filled in", function() {
            beforeEach(function() {
              return runs(function() {
                this.iapc.$('.bv_completionDate').val("");
                return this.iapc.$('.bv_completionDate').change();
              });
            });
            return it("should show error in date field", function() {
              return runs(function() {
                return expect(this.iapc.$('.bv_group_completionDate').hasClass('error')).toBeTruthy();
              });
            });
          });
          describe("when notebook not filled", function() {
            beforeEach(function() {
              return runs(function() {
                this.iapc.$('.bv_notebook').val("");
                return this.iapc.$('.bv_notebook').change();
              });
            });
            return it("should show error on notebook field", function() {
              return runs(function() {
                return expect(this.iapc.$('.bv_group_notebook').hasClass('error')).toBeTruthy();
              });
            });
          });
          describe("when conjugation type not filled", function() {
            beforeEach(function() {
              return runs(function() {
                this.iapc.$('.bv_conjugationType').val("unassigned");
                return this.iapc.$('.bv_conjugationType').change();
              });
            });
            return it("should show error on conjugation type field", function() {
              return runs(function() {
                return expect(this.iapc.$('.bv_group_conjugationType').hasClass('error')).toBeTruthy();
              });
            });
          });
          return describe("when conjugation site not filled", function() {
            beforeEach(function() {
              return runs(function() {
                this.iapc.$('.bv_conjugationSite').val("unassigned");
                return this.iapc.$('.bv_conjugationSite').change();
              });
            });
            return it("should show error on conjugation site field", function() {
              return runs(function() {
                return expect(this.iapc.$('.bv_group_conjugationSite').hasClass('error')).toBeTruthy();
              });
            });
          });
        });
      });
    });
    describe("InternalizationAgent Batch model testing", function() {
      describe("when loaded from new", function() {
        beforeEach(function() {
          return this.iab = new InternalizationAgentBatch();
        });
        return describe("Existence and Defaults", function() {
          it("should be defined", function() {
            return expect(this.iab).toBeDefined();
          });
          it("should have a type", function() {
            return expect(this.iab.get('lsType')).toEqual("batch");
          });
          it("should have a kind", function() {
            return expect(this.iab.get('lsKind')).toEqual("internalization agent");
          });
          it("should have an empty scientist", function() {
            return expect(this.iab.get('recordedBy')).toEqual("");
          });
          it("should have a recordedDate set to now", function() {
            return expect(new Date(this.iab.get('recordedDate')).getHours()).toEqual(new Date().getHours());
          });
          return describe("model attributes for each value in defaultValues", function() {
            it("Should have a model attribute for completion date", function() {
              return expect(this.iab.get("completion date")).toBeDefined();
            });
            it("Should have a model attribute for notebook", function() {
              return expect(this.iab.get("notebook")).toBeDefined();
            });
            it("Should have a model attribute for molecular weight", function() {
              return expect(this.iab.get("molecular weight")).toBeDefined();
            });
            it("Should have a model attribute for purity", function() {
              return expect(this.iab.get("purity")).toBeDefined();
            });
            it("Should have a model attribute for amount", function() {
              return expect(this.iab.get("amount")).toBeDefined();
            });
            return it("Should have a model attribute for location", function() {
              return expect(this.iab.get("location")).toBeDefined();
            });
          });
        });
      });
      describe("When created from existing", function() {
        beforeEach(function() {
          return this.iab = new InternalizationAgentBatch(JSON.parse(JSON.stringify(window.internalizationAgentTestJSON.internalizationAgentBatch)));
        });
        return describe("after initial load", function() {
          it("should be defined", function() {
            return expect(this.iab).toBeDefined();
          });
          it("should have a type", function() {
            return expect(this.iab.get('lsType')).toEqual("batch");
          });
          it("should have a kind", function() {
            return expect(this.iab.get('lsKind')).toEqual("internalization agent");
          });
          it("should have a scientist set", function() {
            return expect(this.iab.get('recordedBy')).toEqual("jane");
          });
          it("should have a recordedDate set", function() {
            return expect(this.iab.get('recordedDate')).toEqual(1375141508000);
          });
          it("Should have a lsStates with the states in defaultStates", function() {
            expect(this.iab.get('lsStates')).toBeDefined();
            expect(this.iab.get("lsStates").length).toEqual(2);
            expect(this.iab.get("lsStates").getStatesByTypeAndKind("metadata", "internalization agent batch").length).toEqual(1);
            return expect(this.iab.get("lsStates").getStatesByTypeAndKind("metadata", "inventory").length).toEqual(1);
          });
          it("Should have a completion date value", function() {
            return expect(this.iab.get("completion date").get("value")).toEqual(1342080000000);
          });
          it("Should have a notebook value", function() {
            return expect(this.iab.get("notebook").get("value")).toEqual("Notebook 1");
          });
          it("Should have a molecular weight value", function() {
            return expect(this.iab.get("molecular weight").get("value")).toEqual(231);
          });
          it("Should have a purity value", function() {
            return expect(this.iab.get("purity").get("value")).toEqual(92);
          });
          it("Should have an amount value", function() {
            return expect(this.iab.get("amount").get("value")).toEqual(2.3);
          });
          return it("Should have a location value", function() {
            return expect(this.iab.get("location").get("value")).toEqual("Cabinet 1");
          });
        });
      });
      return describe("model validation", function() {
        beforeEach(function() {
          return this.iab = new InternalizationAgentBatch(window.internalizationAgentTestJSON.internalizationAgentBatch);
        });
        it("should be valid when loaded from saved", function() {
          console.log(this.iab.validationError);
          return expect(this.iab.isValid()).toBeTruthy();
        });
        it("should be invalid when recorded date is empty", function() {
          var filtErrors;
          this.iab.set({
            recordedDate: new Date("").getTime()
          });
          expect(this.iab.isValid()).toBeFalsy();
          filtErrors = _.filter(this.iab.validationError, function(err) {
            return err.attribute === 'recordedDate';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it("should be invalid when scientist not selected", function() {
          var filtErrors;
          this.iab.set({
            recordedBy: ""
          });
          expect(this.iab.isValid()).toBeFalsy();
          return filtErrors = _.filter(this.iab.validationError, function(err) {
            return err.attribute === 'recordedBy';
          });
        });
        it("should be invalid when completion date is empty", function() {
          var filtErrors;
          this.iab.get("completion date").set("value", new Date("").getTime());
          expect(this.iab.isValid()).toBeFalsy();
          filtErrors = _.filter(this.iab.validationError, function(err) {
            return err.attribute === 'completionDate';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it("should be invalid when notebook is empty", function() {
          var filtErrors;
          this.iab.get("notebook").set("value", "");
          expect(this.iab.isValid()).toBeFalsy();
          filtErrors = _.filter(this.iab.validationError, function(err) {
            return err.attribute === 'notebook';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it("should be invalid when molecular weight is NaN", function() {
          var filtErrors;
          this.iab.get("molecular weight").set("value", "fred");
          expect(this.iab.isValid()).toBeFalsy();
          filtErrors = _.filter(this.iab.validationError, function(err) {
            return err.attribute === 'molecularWeight';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it("should be invalid when purity is NaN", function() {
          var filtErrors;
          this.iab.get("purity").set("value", "fred");
          expect(this.iab.isValid()).toBeFalsy();
          filtErrors = _.filter(this.iab.validationError, function(err) {
            return err.attribute === 'purity';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it("should be invalid when amount is NaN", function() {
          var filtErrors;
          this.iab.get("amount").set("value", "fred");
          expect(this.iab.isValid()).toBeFalsy();
          filtErrors = _.filter(this.iab.validationError, function(err) {
            return err.attribute === 'amount';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        return it("should be invalid when location is empty", function() {
          var filtErrors;
          this.iab.get("location").set("value", "");
          expect(this.iab.isValid()).toBeFalsy();
          filtErrors = _.filter(this.iab.validationError, function(err) {
            return err.attribute === 'location';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
      });
    });
    describe("InternalizationAgent Batch Controller testing", function() {
      describe("When instantiated from new", function() {
        beforeEach(function() {
          this.iab = new InternalizationAgentBatch();
          this.iabc = new InternalizationAgentBatchController({
            model: this.iab,
            el: $('#fixture')
          });
          return this.iabc.render();
        });
        return describe("basic existence tests", function() {
          it("should exist", function() {
            return expect(this.iabc).toBeDefined();
          });
          it("should load the template", function() {
            return expect(this.iabc.$('.bv_batchCode').html()).toEqual("Autofilled when saved");
          });
          return it("should load the additional batch attributes template", function() {
            return expect(this.iabc.$('.bv_molecularWeight').length).toEqual(1);
          });
        });
      });
      return describe("When instantiated from existing", function() {
        beforeEach(function() {
          this.iab = new InternalizationAgentBatch(JSON.parse(JSON.stringify(window.internalizationAgentTestJSON.internalizationAgentBatch)));
          this.iabc = new InternalizationAgentBatchController({
            model: this.iab,
            el: $('#fixture')
          });
          return this.iabc.render();
        });
        describe("render existing parameters", function() {
          it("should show the internalization agent batch id", function() {
            return expect(this.iabc.$('.bv_batchCode').val()).toEqual("I000001-1");
          });
          it("should fill the scientist field", function() {
            waitsFor(function() {
              return this.iabc.$('.bv_recordedBy option').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.iabc.$('.bv_recordedBy').val()).toEqual("jane");
            });
          });
          it("should fill the completion date field", function() {
            return expect(this.iabc.$('.bv_completionDate').val()).toEqual("2012-07-12");
          });
          it("should fill the notebook field", function() {
            return expect(this.iabc.$('.bv_notebook').val()).toEqual("Notebook 1");
          });
          it("should fill the amount field", function() {
            return expect(this.iabc.$('.bv_amount').val()).toEqual("2.3");
          });
          it("should fill the molecular weight field", function() {
            return expect(this.iabc.$('.bv_molecularWeight').val()).toEqual("231");
          });
          it("should fill the purity field", function() {
            return expect(this.iabc.$('.bv_purity').val()).toEqual("92");
          });
          return it("should fill the location field", function() {
            return expect(this.iabc.$('.bv_location').val()).toEqual("Cabinet 1");
          });
        });
        describe("model updates", function() {
          it("should update model when the scientist is changed", function() {
            waitsFor(function() {
              return this.iabc.$('.bv_recordedBy option').length > 0;
            }, 1000);
            return runs(function() {
              this.iabc.$('.bv_recordedBy').val('unassigned');
              this.iabc.$('.bv_recordedBy').change();
              return expect(this.iabc.model.get('recordedBy')).toEqual("unassigned");
            });
          });
          it("should update model when completion date is changed", function() {
            this.iabc.$('.bv_completionDate').val(" 2013-3-16   ");
            this.iabc.$('.bv_completionDate').change();
            return expect(this.iabc.model.get('completion date').get('value')).toEqual(new Date(2013, 2, 16).getTime());
          });
          it("should update model when notebook is changed", function() {
            this.iabc.$('.bv_notebook').val(" Updated notebook  ");
            this.iabc.$('.bv_notebook').change();
            return expect(this.iabc.model.get('notebook').get('value')).toEqual("Updated notebook");
          });
          it("should update model when molecular weight is changed", function() {
            this.iabc.$('.bv_molecularWeight').val(" 12  ");
            this.iabc.$('.bv_molecularWeight').change();
            return expect(this.iabc.model.get('molecular weight').get('value')).toEqual(12);
          });
          it("should update model when purity is changed", function() {
            this.iabc.$('.bv_purity').val(" 22  ");
            this.iabc.$('.bv_purity').change();
            return expect(this.iabc.model.get('purity').get('value')).toEqual(22);
          });
          it("should update model when amount is changed", function() {
            this.iabc.$('.bv_amount').val(" 12  ");
            this.iabc.$('.bv_amount').change();
            return expect(this.iabc.model.get('amount').get('value')).toEqual(12);
          });
          return it("should update model when location is changed", function() {
            this.iabc.$('.bv_location').val(" Updated location  ");
            this.iabc.$('.bv_location').change();
            return expect(this.iabc.model.get('location').get('value')).toEqual("Updated location");
          });
        });
        return describe("controller validation rules", function() {
          beforeEach(function() {
            waitsFor(function() {
              return this.iabc.$('.bv_recordedBy option').length > 0;
            }, 1000);
            return runs(function() {
              this.iabc.$('.bv_recordedBy').val("bob");
              this.iabc.$('.bv_recordedBy').change();
              this.iabc.$('.bv_completionDate').val(" 2013-3-16   ");
              this.iabc.$('.bv_completionDate').change();
              this.iabc.$('.bv_notebook').val("my notebook");
              this.iabc.$('.bv_notebook').change();
              this.iabc.$('.bv_molecularWeight').val(" 24");
              this.iabc.$('.bv_molecularWeight').change();
              this.iabc.$('.bv_purity').val(" 85");
              this.iabc.$('.bv_purity').change();
              this.iabc.$('.bv_amount').val(" 24");
              this.iabc.$('.bv_amount').change();
              this.iabc.$('.bv_location').val(" Hood 4");
              return this.iabc.$('.bv_location').change();
            });
          });
          describe("form validation setup", function() {
            it("should be valid if form fully filled out", function() {
              return runs(function() {
                return expect(this.iabc.isValid()).toBeTruthy();
              });
            });
            return it("should have the save button be enabled", function() {
              return runs(function() {
                return expect(this.iabc.$('.bv_saveBatch').attr('disabled')).toBeUndefined();
              });
            });
          });
          describe("when scientist not selected", function() {
            beforeEach(function() {
              return runs(function() {
                this.iabc.$('.bv_recordedBy').val("");
                return this.iabc.$('.bv_recordedBy').change();
              });
            });
            it("should show error on scientist dropdown", function() {
              return runs(function() {
                return expect(this.iabc.$('.bv_group_recordedBy').hasClass('error')).toBeTruthy();
              });
            });
            return it("should have the save button be disabled", function() {
              return runs(function() {
                return expect(this.iabc.$('.bv_saveBatch').attr('disabled')).toEqual('disabled');
              });
            });
          });
          describe("when date field not filled in", function() {
            beforeEach(function() {
              return runs(function() {
                this.iabc.$('.bv_completionDate').val("");
                return this.iabc.$('.bv_completionDate').change();
              });
            });
            return it("should show error in date field", function() {
              return runs(function() {
                return expect(this.iabc.$('.bv_group_completionDate').hasClass('error')).toBeTruthy();
              });
            });
          });
          describe("when notebook not filled", function() {
            beforeEach(function() {
              return runs(function() {
                this.iabc.$('.bv_notebook').val("");
                return this.iabc.$('.bv_notebook').change();
              });
            });
            return it("should show error on notebook field", function() {
              return runs(function() {
                return expect(this.iabc.$('.bv_group_notebook').hasClass('error')).toBeTruthy();
              });
            });
          });
          describe("when molecular weight not filled", function() {
            beforeEach(function() {
              return runs(function() {
                this.iabc.$('.bv_molecularWeight').val("");
                return this.iabc.$('.bv_molecularWeight').change();
              });
            });
            return it("should show error on molecular weight field", function() {
              return runs(function() {
                return expect(this.iabc.$('.bv_group_molecularWeight').hasClass('error')).toBeTruthy();
              });
            });
          });
          describe("when purity not filled", function() {
            beforeEach(function() {
              return runs(function() {
                this.iabc.$('.bv_purity').val("");
                return this.iabc.$('.bv_purity').change();
              });
            });
            return it("should show error on purity field", function() {
              return runs(function() {
                return expect(this.iabc.$('.bv_group_purity').hasClass('error')).toBeTruthy();
              });
            });
          });
          describe("when amount not filled", function() {
            beforeEach(function() {
              return runs(function() {
                this.iabc.$('.bv_amount').val("");
                return this.iabc.$('.bv_amount').change();
              });
            });
            return it("should show error on amount field", function() {
              return runs(function() {
                return expect(this.iabc.$('.bv_group_amount').hasClass('error')).toBeTruthy();
              });
            });
          });
          return describe("when location not filled", function() {
            beforeEach(function() {
              return runs(function() {
                this.iabc.$('.bv_location').val("");
                return this.iabc.$('.bv_location').change();
              });
            });
            return it("should show error on location field", function() {
              return runs(function() {
                return expect(this.iabc.$('.bv_group_location').hasClass('error')).toBeTruthy();
              });
            });
          });
        });
      });
    });
    describe("InternalizationAgent Batch Select Controller testing", function() {
      beforeEach(function() {
        this.iab = new InternalizationAgentBatch();
        this.iabsc = new InternalizationAgentBatchSelectController({
          model: this.iab,
          el: $('#fixture')
        });
        return this.iabsc.render();
      });
      describe("When instantiated", function() {
        describe("basic existence tests", function() {
          it("should exist", function() {
            return expect(this.iabsc).toBeDefined();
          });
          return it("should load the template", function() {
            return expect(this.iabsc.$('.bv_batchList').length).toEqual(1);
          });
        });
        return describe("rendering", function() {
          it("should have the batch list default to register new batch", function() {
            waitsFor(function() {
              return this.iabsc.$('.bv_batchList option').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.iabsc.$('.bv_batchList').val()).toEqual("new batch");
            });
          });
          return it("should a new batch registration form", function() {
            console.log(this.iabsc.$('.bv_batchCode'));
            expect(this.iabsc.$('.bv_batchCode').val()).toEqual("");
            return expect(this.iabsc.$('.bv_batchCode').html()).toEqual("Autofilled when saved");
          });
        });
      });
      return describe("behavior", function() {
        return it("should show the information for a selected batch", function() {
          waitsFor(function() {
            return this.iabsc.$('.bv_batchList option').length > 0;
          }, 1000);
          runs(function() {
            console.log(this.iabsc.$('.bv_batchList'));
            this.iabsc.$('.bv_batchList').val("CB000001-1");
            return this.iabsc.$('.bv_batchList').change();
          });
          waitsFor(function() {
            return this.iabsc.$('.bv_recordedBy option').length > 0;
          }, 1000);
          runs(function() {
            return waits(1000);
          });
          return runs(function() {
            expect(this.iabsc.$('.bv_batchCode').html()).toEqual("CB000001-1");
            return expect(this.iabsc.$('.bv_recordedBy').val()).toEqual("jane");
          });
        });
      });
    });
    return describe("InternalizationAgent Controller", function() {
      beforeEach(function() {
        this.iac = new InternalizationAgentController({
          model: new InternalizationAgentParent(),
          el: $('#fixture')
        });
        return this.iac.render();
      });
      describe("Basic loading", function() {
        it("Class should exist", function() {
          return expect(this.iac).toBeDefined();
        });
        it("Should load the template", function() {
          return expect(this.iac.$('.bv_save').length).toEqual(1);
        });
        it("Should load a parent controller", function() {
          return expect(this.iac.$('.bv_parent .bv_parentCode').length).toEqual(1);
        });
        return it("Should load a batch controller", function() {
          return expect(this.iac.$('.bv_batch .bv_batchCode').length).toEqual(1);
        });
      });
      return describe("saving parent/batch for the first time", function() {
        describe("when form is initialized", function() {
          return it("should have the save button be disabled initially", function() {
            return expect(this.iac.$('.bv_save').attr('disabled')).toEqual('disabled');
          });
        });
        return describe('when save is clicked', function() {
          beforeEach(function() {
            runs(function() {
              this.iac.$('.bv_parentName').val(" Updated entity name   ");
              this.iac.$('.bv_parentName').change();
              this.iac.$('.bv_recordedBy').val("bob");
              this.iac.$('.bv_recordedBy').change();
              this.iac.$('.bv_completionDate').val(" 2013-3-16   ");
              this.iac.$('.bv_completionDate').change();
              this.iac.$('.bv_notebook').val("my notebook");
              this.iac.$('.bv_notebook').change();
              this.iac.$('.bv_conjugationType').val(" mab");
              this.iac.$('.bv_conjugationType').change();
              this.iac.$('.bv_conjugationSite').val(" AUC");
              this.iac.$('.bv_conjugationSite').change();
              this.iac.$('.bv_molecularWeight').val(" 14");
              this.iac.$('.bv_molecularWeight').change();
              this.iac.$('.bv_purity').val(" 74");
              this.iac.$('.bv_purity').change();
              this.iac.$('.bv_amount').val(" 24");
              this.iac.$('.bv_amount').change();
              this.iac.$('.bv_location').val(" Hood 4");
              return this.iac.$('.bv_location').change();
            });
            return waitsFor(function() {
              return this.iac.$('.bv_recordedBy option').length > 0;
            }, 1000);
          });
          it("should have the save button be enabled", function() {
            return runs(function() {
              return expect(this.iac.$('.bv_save').attr('disabled')).toBeUndefined();
            });
          });
          it("should update the parent code", function() {
            runs(function() {
              return this.iac.$('.bv_save').click();
            });
            waits(1000);
            return runs(function() {
              return expect(this.iac.$('.bv_parentCode').html()).toEqual("I000001");
            });
          });
          it("should update the batch code", function() {
            runs(function() {
              return this.iac.$('.bv_save').click();
            });
            waits(1000);
            return runs(function() {
              return expect(this.iac.$('.bv_batchCode').html()).toEqual("I000001-1");
            });
          });
          it("should show the update parent button", function() {
            runs(function() {
              return this.iac.$('.bv_save').click();
            });
            waits(1000);
            return runs(function() {
              return expect(this.iac.$('.bv_updateParent')).toBeVisible();
            });
          });
          return it("should show the update batch button", function() {
            runs(function() {
              return this.iac.$('.bv_save').click();
            });
            waits(1000);
            return runs(function() {
              return expect(this.iac.$('.bv_saveBatch')).toBeVisible();
            });
          });
        });
      });
    });
  });

}).call(this);
