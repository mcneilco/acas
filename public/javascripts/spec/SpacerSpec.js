(function() {
  beforeEach(function() {
    return this.fixture = $.clone($("#fixture").get(0));
  });

  afterEach(function() {
    $("#fixture").remove();
    return $("body").append($(this.fixture));
  });

  describe('Spacer testing', function() {
    describe(" Parent model testing", function() {
      describe("when loaded from new", function() {
        beforeEach(function() {
          return this.sp = new SpacerParent();
        });
        describe("Existence and Defaults", function() {
          it("should be defined", function() {
            return expect(this.sp).toBeDefined();
          });
          it("should have a type", function() {
            return expect(this.sp.get('lsType')).toEqual("parent");
          });
          it("should have a kind", function() {
            return expect(this.sp.get('lsKind')).toEqual("spacer");
          });
          it("should have an empty scientist", function() {
            return expect(this.sp.get('recordedBy')).toEqual("");
          });
          it("should have a recordedDate set to now", function() {
            return expect(new Date(this.sp.get('recordedDate')).getHours()).toEqual(new Date().getHours());
          });
          it("Should have a lsLabels with one label", function() {
            expect(this.sp.get('lsLabels')).toBeDefined();
            expect(this.sp.get("lsLabels").length).toEqual(1);
            return expect(this.sp.get("lsLabels").getLabelByTypeAndKind("name", "spacer").length).toEqual(1);
          });
          it("Should have a model attribute for the label in defaultLabels", function() {
            return expect(this.sp.get("spacer name")).toBeDefined();
          });
          it("Should have a lsStates with the states in defaultStates", function() {
            expect(this.sp.get('lsStates')).toBeDefined();
            expect(this.sp.get("lsStates").length).toEqual(1);
            return expect(this.sp.get("lsStates").getStatesByTypeAndKind("metadata", "spacer parent").length).toEqual(1);
          });
          return describe("model attributes for each value in defaultValues", function() {
            it("Should have a model attribute for completion date", function() {
              return expect(this.sp.get("completion date")).toBeDefined();
            });
            it("Should have a model attribute for notebook", function() {
              return expect(this.sp.get("notebook")).toBeDefined();
            });
            return it("Should have a model attribute for molecular weight", function() {
              return expect(this.sp.get("molecular weight")).toBeDefined();
            });
          });
        });
        return describe("model validation", function() {
          it("should be invalid when name is empty", function() {
            var filtErrors;
            this.sp.get("spacer name").set("labelText", "");
            expect(this.sp.isValid()).toBeFalsy();
            filtErrors = _.filter(this.sp.validationError, function(err) {
              return err.attribute === 'parentName';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
          it("should invalid when recorded date is empty", function() {
            var filtErrors;
            this.sp.set({
              recordedDate: new Date("").getTime()
            });
            expect(this.sp.isValid()).toBeFalsy();
            filtErrors = _.filter(this.sp.validationError, function(err) {
              return err.attribute === 'recordedDate';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
          return it("should be invalid when molecular weight is NaN", function() {
            var filtErrors;
            this.sp.get("molecular weight").set("value", "fred");
            expect(this.sp.isValid()).toBeFalsy();
            filtErrors = _.filter(this.sp.validationError, function(err) {
              return err.attribute === 'molecularWeight';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
        });
      });
      return describe("When created from existing", function() {
        beforeEach(function() {
          return this.sp = new SpacerParent(JSON.parse(JSON.stringify(window.spacerTestJSON.spacerParent)));
        });
        describe("after initial load", function() {
          it("should be defined", function() {
            return expect(this.sp).toBeDefined();
          });
          it("should have a type", function() {
            return expect(this.sp.get('lsType')).toEqual("parent");
          });
          it("should have a kind", function() {
            return expect(this.sp.get('lsKind')).toEqual("spacer");
          });
          it("should have a scientist set", function() {
            return expect(this.sp.get('recordedBy')).toEqual("jane");
          });
          it("should have a recordedDate set", function() {
            return expect(this.sp.get('recordedDate')).toEqual(1375141508000);
          });
          it("Should have label set", function() {
            var label;
            console.log(this.sp);
            expect(this.sp.get("spacer name").get("labelText")).toEqual("PEG10");
            label = this.sp.get("lsLabels").getLabelByTypeAndKind("name", "spacer");
            console.log(label[0]);
            return expect(label[0].get('labelText')).toEqual("PEG10");
          });
          it("Should have a lsStates with the states in defaultStates", function() {
            expect(this.sp.get('lsStates')).toBeDefined();
            expect(this.sp.get("lsStates").length).toEqual(1);
            return expect(this.sp.get("lsStates").getStatesByTypeAndKind("metadata", "spacer parent").length).toEqual(1);
          });
          it("Should have a completion date value", function() {
            return expect(this.sp.get("completion date").get("value")).toEqual(1342080000000);
          });
          it("Should have a notebook value", function() {
            return expect(this.sp.get("notebook").get("value")).toEqual("Notebook 1");
          });
          return it("Should have a molecular weight value", function() {
            return expect(this.sp.get("molecular weight").get("value")).toEqual(231);
          });
        });
        return describe("model validation", function() {
          beforeEach(function() {
            return this.sp = new SpacerParent(window.spacerTestJSON.spacerParent);
          });
          it("should be valid when loaded from saved", function() {
            return expect(this.sp.isValid()).toBeTruthy();
          });
          it("should be invalid when name is empty", function() {
            var filtErrors;
            this.sp.get("spacer name").set("labelText", "");
            expect(this.sp.isValid()).toBeFalsy();
            filtErrors = _.filter(this.sp.validationError, function(err) {
              return err.attribute === 'parentName';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
          it("should be invalid when recorded date is empty", function() {
            var filtErrors;
            this.sp.set({
              recordedDate: new Date("").getTime()
            });
            expect(this.sp.isValid()).toBeFalsy();
            filtErrors = _.filter(this.sp.validationError, function(err) {
              return err.attribute === 'recordedDate';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
          it("should be invalid when scientist not selected", function() {
            var filtErrors;
            this.sp.set({
              recordedBy: ""
            });
            expect(this.sp.isValid()).toBeFalsy();
            filtErrors = _.filter(this.sp.validationError, function(err) {
              return err.attribute === 'recordedBy';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
          it("should be invalid when completion date is empty", function() {
            var filtErrors;
            this.sp.get("completion date").set("value", new Date("").getTime());
            expect(this.sp.isValid()).toBeFalsy();
            filtErrors = _.filter(this.sp.validationError, function(err) {
              return err.attribute === 'completionDate';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
          it("should be invalid when notebook is empty", function() {
            var filtErrors;
            this.sp.get("notebook").set("value", "");
            expect(this.sp.isValid()).toBeFalsy();
            filtErrors = _.filter(this.sp.validationError, function(err) {
              return err.attribute === 'notebook';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
          return it("should be invalid when molecular weight is NaN", function() {
            var filtErrors;
            this.sp.get("molecular weight").set("value", "fred");
            expect(this.sp.isValid()).toBeFalsy();
            filtErrors = _.filter(this.sp.validationError, function(err) {
              return err.attribute === 'molecularWeight';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
        });
      });
    });
    describe("Spacer Parent Controller testing", function() {
      describe("When instantiated from new", function() {
        beforeEach(function() {
          this.sp = new SpacerParent();
          this.spc = new SpacerParentController({
            model: this.sp,
            el: $('#fixture')
          });
          return this.spc.render();
        });
        return describe("basic existence tests", function() {
          it("should exist", function() {
            return expect(this.spc).toBeDefined();
          });
          it("should load the template", function() {
            return expect(this.spc.$('.bv_parentCode').html()).toEqual("autofill when saved");
          });
          return it("should load the additional parent attributes temlate", function() {
            return expect(this.spc.$('.bv_molecularWeight').length).toEqual(1);
          });
        });
      });
      return describe("When instantiated from existing", function() {
        beforeEach(function() {
          this.sp = new SpacerParent(JSON.parse(JSON.stringify(window.spacerTestJSON.spacerParent)));
          this.spc = new SpacerParentController({
            model: this.sp,
            el: $('#fixture')
          });
          return this.spc.render();
        });
        describe("render existing parameters", function() {
          it("should show the spacer parent id", function() {
            return expect(this.spc.$('.bv_parentCode').val()).toEqual("SP000001");
          });
          it("should fill the spacer parent name", function() {
            return expect(this.spc.$('.bv_parentName').val()).toEqual("PEG10");
          });
          it("should fill the scientist field", function() {
            waitsFor(function() {
              return this.spc.$('.bv_recordedBy option').length > 0;
            }, 1000);
            return runs(function() {
              console.log(this.spc.$('.bv_recordedBy').val());
              return expect(this.spc.$('.bv_recordedBy').val()).toEqual("jane");
            });
          });
          it("should fill the completion date field", function() {
            return expect(this.spc.$('.bv_completionDate').val()).toEqual("2012-07-12");
          });
          it("should fill the notebook field", function() {
            return expect(this.spc.$('.bv_notebook').val()).toEqual("Notebook 1");
          });
          return it("should fill the molecular weight field", function() {
            return expect(this.spc.$('.bv_molecularWeight').val()).toEqual("231");
          });
        });
        describe("model updates", function() {
          it("should update model when parent name is changed", function() {
            this.spc.$('.bv_parentName').val(" New name   ");
            this.spc.$('.bv_parentName').change();
            return expect(this.spc.model.get('spacer name').get('labelText')).toEqual("New name");
          });
          it("should update model when the scientist is changed", function() {
            waitsFor(function() {
              return this.spc.$('.bv_recordedBy option').length > 0;
            }, 1000);
            return runs(function() {
              this.spc.$('.bv_recordedBy').val('unassigned');
              this.spc.$('.bv_recordedBy').change();
              return expect(this.spc.model.get('recordedBy')).toEqual("unassigned");
            });
          });
          it("should update model when completion date is changed", function() {
            this.spc.$('.bv_completionDate').val(" 2013-3-16   ");
            this.spc.$('.bv_completionDate').change();
            return expect(this.spc.model.get('completion date').get('value')).toEqual(new Date(2013, 2, 16).getTime());
          });
          it("should update model when notebook is changed", function() {
            this.spc.$('.bv_notebook').val(" Updated notebook  ");
            this.spc.$('.bv_notebook').change();
            return expect(this.spc.model.get('notebook').get('value')).toEqual("Updated notebook");
          });
          return it("should update model when molecular weight is changed", function() {
            this.spc.$('.bv_molecularWeight').val(" 12  ");
            this.spc.$('.bv_molecularWeight').change();
            return expect(this.spc.model.get('molecular weight').get('value')).toEqual(12);
          });
        });
        return describe("controller validation rules", function() {
          beforeEach(function() {
            waitsFor(function() {
              return this.spc.$('.bv_recordedBy option').length > 0;
            }, 1000);
            return runs(function() {
              this.spc.$('.bv_parentName').val(" Updated entity name   ");
              this.spc.$('.bv_parentName').change();
              this.spc.$('.bv_recordedBy').val("bob");
              this.spc.$('.bv_recordedBy').change();
              this.spc.$('.bv_completionDate').val(" 2013-3-16   ");
              this.spc.$('.bv_completionDate').change();
              this.spc.$('.bv_notebook').val("my notebook");
              this.spc.$('.bv_notebook').change();
              this.spc.$('.bv_molecularWeight').val(" 24");
              return this.spc.$('.bv_molecularWeight').change();
            });
          });
          describe("form validation setup", function() {
            return it("should be valid if form fully filled out", function() {
              return runs(function() {
                return expect(this.spc.isValid()).toBeTruthy();
              });
            });
          });
          describe("when name field not filled in", function() {
            beforeEach(function() {
              return runs(function() {
                this.spc.$('.bv_parentName').val("");
                return this.spc.$('.bv_parentName').change();
              });
            });
            it("should be invalid if name not filled in", function() {
              return runs(function() {
                return expect(this.spc.isValid()).toBeFalsy();
              });
            });
            return it("should show error in name field", function() {
              return runs(function() {
                return expect(this.spc.$('.bv_group_parentName').hasClass('error')).toBeTruthy();
              });
            });
          });
          describe("when scientist not selected", function() {
            beforeEach(function() {
              return runs(function() {
                this.spc.$('.bv_recordedBy').val("");
                return this.spc.$('.bv_recordedBy').change();
              });
            });
            return it("should show error on scientist dropdown", function() {
              return runs(function() {
                return expect(this.spc.$('.bv_group_recordedBy').hasClass('error')).toBeTruthy();
              });
            });
          });
          describe("when date field not filled in", function() {
            beforeEach(function() {
              return runs(function() {
                this.spc.$('.bv_completionDate').val("");
                return this.spc.$('.bv_completionDate').change();
              });
            });
            return it("should show error in date field", function() {
              return runs(function() {
                return expect(this.spc.$('.bv_group_completionDate').hasClass('error')).toBeTruthy();
              });
            });
          });
          describe("when notebook not filled", function() {
            beforeEach(function() {
              return runs(function() {
                this.spc.$('.bv_notebook').val("");
                return this.spc.$('.bv_notebook').change();
              });
            });
            return it("should show error on notebook field", function() {
              return runs(function() {
                return expect(this.spc.$('.bv_group_notebook').hasClass('error')).toBeTruthy();
              });
            });
          });
          return describe("when molecular weight not filled", function() {
            beforeEach(function() {
              return runs(function() {
                this.spc.$('.bv_molecularWeight').val("");
                return this.spc.$('.bv_molecularWeight').change();
              });
            });
            return it("should show error on molecular weight field", function() {
              return runs(function() {
                return expect(this.spc.$('.bv_group_molecularWeight').hasClass('error')).toBeTruthy();
              });
            });
          });
        });
      });
    });
    describe("Spacer Batch model testing", function() {
      describe("when loaded from new", function() {
        beforeEach(function() {
          return this.cbb = new SpacerBatch();
        });
        return describe("Existence and Defaults", function() {
          it("should be defined", function() {
            return expect(this.cbb).toBeDefined();
          });
          it("should have a type", function() {
            return expect(this.cbb.get('lsType')).toEqual("batch");
          });
          it("should have a kind", function() {
            return expect(this.cbb.get('lsKind')).toEqual("spacer");
          });
          it("should have an empty scientist", function() {
            return expect(this.cbb.get('recordedBy')).toEqual("");
          });
          it("should have a recordedDate set to now", function() {
            return expect(new Date(this.cbb.get('recordedDate')).getHours()).toEqual(new Date().getHours());
          });
          return describe("model attributes for each value in defaultValues", function() {
            it("Should have a model attribute for completion date", function() {
              return expect(this.cbb.get("completion date")).toBeDefined();
            });
            it("Should have a model attribute for notebook", function() {
              return expect(this.cbb.get("notebook")).toBeDefined();
            });
            it("Should have a model attribute for amount", function() {
              return expect(this.cbb.get("amount")).toBeDefined();
            });
            return it("Should have a model attribute for location", function() {
              return expect(this.cbb.get("location")).toBeDefined();
            });
          });
        });
      });
      describe("When created from existing", function() {
        beforeEach(function() {
          return this.cbb = new SpacerBatch(JSON.parse(JSON.stringify(window.spacerTestJSON.spacerBatch)));
        });
        return describe("after initial load", function() {
          it("should be defined", function() {
            return expect(this.cbb).toBeDefined();
          });
          it("should have a type", function() {
            return expect(this.cbb.get('lsType')).toEqual("batch");
          });
          it("should have a kind", function() {
            return expect(this.cbb.get('lsKind')).toEqual("spacer");
          });
          it("should have a scientist set", function() {
            return expect(this.cbb.get('recordedBy')).toEqual("jane");
          });
          it("should have a recordedDate set", function() {
            return expect(this.cbb.get('recordedDate')).toEqual(1375141508000);
          });
          it("Should have a lsStates with the states in defaultStates", function() {
            expect(this.cbb.get('lsStates')).toBeDefined();
            expect(this.cbb.get("lsStates").length).toEqual(2);
            expect(this.cbb.get("lsStates").getStatesByTypeAndKind("metadata", "spacer batch").length).toEqual(1);
            return expect(this.cbb.get("lsStates").getStatesByTypeAndKind("metadata", "inventory").length).toEqual(1);
          });
          it("Should have a completion date value", function() {
            return expect(this.cbb.get("completion date").get("value")).toEqual(1342080000000);
          });
          it("Should have a notebook value", function() {
            return expect(this.cbb.get("notebook").get("value")).toEqual("Notebook 1");
          });
          it("Should have an amount value", function() {
            return expect(this.cbb.get("amount").get("value")).toEqual(2.3);
          });
          return it("Should have a location value", function() {
            return expect(this.cbb.get("location").get("value")).toEqual("Cabinet 1");
          });
        });
      });
      return describe("model validation", function() {
        beforeEach(function() {
          return this.cbb = new SpacerBatch(window.spacerTestJSON.spacerBatch);
        });
        it("should be valid when loaded from saved", function() {
          return expect(this.cbb.isValid()).toBeTruthy();
        });
        it("should be invalid when recorded date is empty", function() {
          var filtErrors;
          this.cbb.set({
            recordedDate: new Date("").getTime()
          });
          expect(this.cbb.isValid()).toBeFalsy();
          filtErrors = _.filter(this.cbb.validationError, function(err) {
            return err.attribute === 'recordedDate';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it("should be invalid when scientist not selected", function() {
          var filtErrors;
          this.cbb.set({
            recordedBy: ""
          });
          expect(this.cbb.isValid()).toBeFalsy();
          return filtErrors = _.filter(this.cbb.validationError, function(err) {
            return err.attribute === 'recordedBy';
          });
        });
        it("should be invalid when completion date is empty", function() {
          var filtErrors;
          this.cbb.get("completion date").set("value", new Date("").getTime());
          expect(this.cbb.isValid()).toBeFalsy();
          filtErrors = _.filter(this.cbb.validationError, function(err) {
            return err.attribute === 'completionDate';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it("should be invalid when notebook is empty", function() {
          var filtErrors;
          this.cbb.get("notebook").set("value", "");
          expect(this.cbb.isValid()).toBeFalsy();
          filtErrors = _.filter(this.cbb.validationError, function(err) {
            return err.attribute === 'notebook';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it("should be invalid when amount is NaN", function() {
          var filtErrors;
          this.cbb.get("amount").set("value", "fred");
          expect(this.cbb.isValid()).toBeFalsy();
          filtErrors = _.filter(this.cbb.validationError, function(err) {
            return err.attribute === 'amount';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        return it("should be invalid when location is empty", function() {
          var filtErrors;
          this.cbb.get("location").set("value", "");
          expect(this.cbb.isValid()).toBeFalsy();
          filtErrors = _.filter(this.cbb.validationError, function(err) {
            return err.attribute === 'location';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
      });
    });
    describe("Spacer Batch Controller testing", function() {
      describe("When instantiated from new", function() {
        beforeEach(function() {
          this.cbb = new SpacerBatch();
          this.cbbc = new SpacerBatchController({
            model: this.cbb,
            el: $('#fixture')
          });
          return this.cbbc.render();
        });
        return describe("basic existence tests", function() {
          it("should exist", function() {
            return expect(this.cbbc).toBeDefined();
          });
          return it("should load the template", function() {
            return expect(this.cbbc.$('.bv_batchCode').html()).toEqual("autofill when saved");
          });
        });
      });
      return describe("When instantiated from existing", function() {
        beforeEach(function() {
          this.cbb = new SpacerBatch(JSON.parse(JSON.stringify(window.spacerTestJSON.spacerBatch)));
          this.cbbc = new SpacerBatchController({
            model: this.cbb,
            el: $('#fixture')
          });
          return this.cbbc.render();
        });
        describe("render existing parameters", function() {
          it("should show the spacer batch id", function() {
            return expect(this.cbbc.$('.bv_batchCode').val()).toEqual("SP000001-1");
          });
          it("should fill the scientist field", function() {
            waitsFor(function() {
              return this.cbbc.$('.bv_recordedBy option').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.cbbc.$('.bv_recordedBy').val()).toEqual("jane");
            });
          });
          it("should fill the completion date field", function() {
            return expect(this.cbbc.$('.bv_completionDate').val()).toEqual("2012-07-12");
          });
          it("should fill the notebook field", function() {
            return expect(this.cbbc.$('.bv_notebook').val()).toEqual("Notebook 1");
          });
          it("should fill the amount field", function() {
            return expect(this.cbbc.$('.bv_amount').val()).toEqual("2.3");
          });
          return it("should fill the location field", function() {
            return expect(this.cbbc.$('.bv_location').val()).toEqual("Cabinet 1");
          });
        });
        describe("model updates", function() {
          it("should update model when the scientist is changed", function() {
            waitsFor(function() {
              return this.cbbc.$('.bv_recordedBy option').length > 0;
            }, 1000);
            return runs(function() {
              this.cbbc.$('.bv_recordedBy').val('unassigned');
              this.cbbc.$('.bv_recordedBy').change();
              return expect(this.cbbc.model.get('recordedBy')).toEqual("unassigned");
            });
          });
          it("should update model when completion date is changed", function() {
            this.cbbc.$('.bv_completionDate').val(" 2013-3-16   ");
            this.cbbc.$('.bv_completionDate').change();
            return expect(this.cbbc.model.get('completion date').get('value')).toEqual(new Date(2013, 2, 16).getTime());
          });
          it("should update model when notebook is changed", function() {
            this.cbbc.$('.bv_notebook').val(" Updated notebook  ");
            this.cbbc.$('.bv_notebook').change();
            return expect(this.cbbc.model.get('notebook').get('value')).toEqual("Updated notebook");
          });
          it("should update model when amount is changed", function() {
            this.cbbc.$('.bv_amount').val(" 12  ");
            this.cbbc.$('.bv_amount').change();
            return expect(this.cbbc.model.get('amount').get('value')).toEqual(12);
          });
          return it("should update model when location is changed", function() {
            this.cbbc.$('.bv_location').val(" Updated location  ");
            this.cbbc.$('.bv_location').change();
            return expect(this.cbbc.model.get('location').get('value')).toEqual("Updated location");
          });
        });
        return describe("controller validation rules", function() {
          beforeEach(function() {
            waitsFor(function() {
              return this.cbbc.$('.bv_recordedBy option').length > 0;
            }, 1000);
            return runs(function() {
              this.cbbc.$('.bv_recordedBy').val("bob");
              this.cbbc.$('.bv_recordedBy').change();
              this.cbbc.$('.bv_completionDate').val(" 2013-3-16   ");
              this.cbbc.$('.bv_completionDate').change();
              this.cbbc.$('.bv_notebook').val("my notebook");
              this.cbbc.$('.bv_notebook').change();
              this.cbbc.$('.bv_amount').val(" 24");
              this.cbbc.$('.bv_amount').change();
              this.cbbc.$('.bv_location').val(" Hood 4");
              return this.cbbc.$('.bv_location').change();
            });
          });
          describe("form validation setup", function() {
            return it("should be valid if form fully filled out", function() {
              return runs(function() {
                return expect(this.cbbc.isValid()).toBeTruthy();
              });
            });
          });
          describe("when scientist not selected", function() {
            beforeEach(function() {
              return runs(function() {
                this.cbbc.$('.bv_recordedBy').val("");
                return this.cbbc.$('.bv_recordedBy').change();
              });
            });
            return it("should show error on scientist dropdown", function() {
              return runs(function() {
                return expect(this.cbbc.$('.bv_group_recordedBy').hasClass('error')).toBeTruthy();
              });
            });
          });
          describe("when date field not filled in", function() {
            beforeEach(function() {
              return runs(function() {
                this.cbbc.$('.bv_completionDate').val("");
                return this.cbbc.$('.bv_completionDate').change();
              });
            });
            return it("should show error in date field", function() {
              return runs(function() {
                return expect(this.cbbc.$('.bv_group_completionDate').hasClass('error')).toBeTruthy();
              });
            });
          });
          describe("when notebook not filled", function() {
            beforeEach(function() {
              return runs(function() {
                this.cbbc.$('.bv_notebook').val("");
                return this.cbbc.$('.bv_notebook').change();
              });
            });
            return it("should show error on notebook field", function() {
              return runs(function() {
                return expect(this.cbbc.$('.bv_group_notebook').hasClass('error')).toBeTruthy();
              });
            });
          });
          describe("when amount not filled", function() {
            beforeEach(function() {
              return runs(function() {
                this.cbbc.$('.bv_amount').val("");
                return this.cbbc.$('.bv_amount').change();
              });
            });
            return it("should show error on amount field", function() {
              return runs(function() {
                return expect(this.cbbc.$('.bv_group_amount').hasClass('error')).toBeTruthy();
              });
            });
          });
          return describe("when location not filled", function() {
            beforeEach(function() {
              return runs(function() {
                this.cbbc.$('.bv_location').val("");
                return this.cbbc.$('.bv_location').change();
              });
            });
            return it("should show error on location field", function() {
              return runs(function() {
                return expect(this.cbbc.$('.bv_group_location').hasClass('error')).toBeTruthy();
              });
            });
          });
        });
      });
    });
    describe("Spacer Batch Select Controller testing", function() {
      beforeEach(function() {
        this.cbb = new SpacerBatch();
        this.cbbsc = new SpacerBatchSelectController({
          model: this.cbb,
          el: $('#fixture')
        });
        return this.cbbsc.render();
      });
      describe("When instantiated", function() {
        describe("basic existence tests", function() {
          it("should exist", function() {
            return expect(this.cbbsc).toBeDefined();
          });
          return it("should load the template", function() {
            return expect(this.cbbsc.$('.bv_batchList').length).toEqual(1);
          });
        });
        return describe("rendering", function() {
          it("should have the batch list default to register new batch", function() {
            waitsFor(function() {
              return this.cbbsc.$('.bv_batchList option').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.cbbsc.$('.bv_batchList').val()).toEqual("new batch");
            });
          });
          return it("should a new batch registration form", function() {
            console.log(this.cbbsc.$('.bv_batchCode'));
            expect(this.cbbsc.$('.bv_batchCode').val()).toEqual("");
            return expect(this.cbbsc.$('.bv_batchCode').html()).toEqual("autofill when saved");
          });
        });
      });
      return describe("behavior", function() {
        return it("should show the information for a selected batch", function() {
          waitsFor(function() {
            return this.cbbsc.$('.bv_batchList option').length > 0;
          }, 1000);
          runs(function() {
            console.log(this.cbbsc.$('.bv_batchList'));
            this.cbbsc.$('.bv_batchList').val("CB000001-1");
            return this.cbbsc.$('.bv_batchList').change();
          });
          waitsFor(function() {
            return this.cbbsc.$('.bv_recordedBy option').length > 0;
          }, 1000);
          runs(function() {
            return waits(1000);
          });
          return runs(function() {
            expect(this.cbbsc.$('.bv_batchCode').html()).toEqual("CB000001-1");
            return expect(this.cbbsc.$('.bv_recordedBy').val()).toEqual("jane");
          });
        });
      });
    });
    return describe("Spacer Controller", function() {
      beforeEach(function() {
        this.cbc = new SpacerController({
          model: new SpacerParent(),
          el: $('#fixture')
        });
        return this.cbc.render();
      });
      describe("Basic loading", function() {
        it("Class should exist", function() {
          return expect(this.cbc).toBeDefined();
        });
        it("Should load the template", function() {
          return expect(this.cbc.$('.bv_save').length).toEqual(1);
        });
        it("Should load a parent controller", function() {
          return expect(this.cbc.$('.bv_parent .bv_parentCode').length).toEqual(1);
        });
        return it("Should load a batch controller", function() {
          return expect(this.cbc.$('.bv_batch .bv_batchCode').length).toEqual(1);
        });
      });
      return describe("saving parent/batch for the first time", function() {
        describe("when form is initialized", function() {
          return it("should have the save button be disabled initially", function() {
            return expect(this.cbc.$('.bv_save').attr('disabled')).toEqual('disabled');
          });
        });
        return describe('when save is clicked', function() {
          beforeEach(function() {
            runs(function() {
              this.cbc.$('.bv_parentName').val(" Updated entity name   ");
              this.cbc.$('.bv_parentName').change();
              this.cbc.$('.bv_recordedBy').val("bob");
              this.cbc.$('.bv_recordedBy').change();
              this.cbc.$('.bv_completionDate').val(" 2013-3-16   ");
              this.cbc.$('.bv_completionDate').change();
              this.cbc.$('.bv_notebook').val("my notebook");
              this.cbc.$('.bv_notebook').change();
              this.cbc.$('.bv_molecularWeight').val(" 24");
              this.cbc.$('.bv_molecularWeight').change();
              this.cbc.$('.bv_amount').val(" 24");
              this.cbc.$('.bv_amount').change();
              this.cbc.$('.bv_location').val(" Hood 4");
              return this.cbc.$('.bv_location').change();
            });
            return waitsFor(function() {
              return this.cbc.$('.bv_recordedBy option').length > 0;
            }, 1000);
          });
          it("should have the save button be enabled", function() {
            return runs(function() {
              return expect(this.cbc.$('.bv_save').attr('disabled')).toBeUndefined();
            });
          });
          it("should update the parent code", function() {
            runs(function() {
              return this.cbc.$('.bv_save').click();
            });
            waits(1000);
            return runs(function() {
              return expect(this.cbc.$('.bv_parentCode').html()).toEqual("SP000001");
            });
          });
          it("should update the batch code", function() {
            runs(function() {
              return this.cbc.$('.bv_save').click();
            });
            waits(1000);
            return runs(function() {
              return expect(this.cbc.$('.bv_batchCode').html()).toEqual("SP000001-1");
            });
          });
          it("should show the update parent button", function() {
            runs(function() {
              return this.cbc.$('.bv_save').click();
            });
            waits(1000);
            return runs(function() {
              return expect(this.cbc.$('.bv_updateParent')).toBeVisible();
            });
          });
          return it("should show the update batch button", function() {
            runs(function() {
              return this.cbc.$('.bv_save').click();
            });
            waits(1000);
            return runs(function() {
              return expect(this.cbc.$('.bv_saveBatch')).toBeVisible();
            });
          });
        });
      });
    });
  });

}).call(this);
