(function() {
  beforeEach(function() {
    return this.fixture = $.clone($("#fixture").get(0));
  });

  afterEach(function() {
    $("#fixture").remove();
    return $("body").append($(this.fixture));
  });

  describe('Cationic Block testing', function() {
    describe(" Parent model testing", function() {
      describe("when loaded from new", function() {
        beforeEach(function() {
          return this.cbp = new CationicBlockParent();
        });
        describe("Existence and Defaults", function() {
          it("should be defined", function() {
            return expect(this.cbp).toBeDefined();
          });
          it("should have a type", function() {
            return expect(this.cbp.get('lsType')).toEqual("parent");
          });
          it("should have a kind", function() {
            return expect(this.cbp.get('lsKind')).toEqual("cationic block");
          });
          it("should have an empty scientist", function() {
            return expect(this.cbp.get('recordedBy')).toEqual("");
          });
          it("should have a recordedDate set to now", function() {
            return expect(new Date(this.cbp.get('recordedDate')).getHours()).toEqual(new Date().getHours());
          });
          it("Should have a lsLabels with one label", function() {
            expect(this.cbp.get('lsLabels')).toBeDefined();
            expect(this.cbp.get("lsLabels").length).toEqual(1);
            return expect(this.cbp.get("lsLabels").getLabelByTypeAndKind("name", "cationic block").length).toEqual(1);
          });
          it("Should have a model attribute for the label in defaultLabels", function() {
            return expect(this.cbp.get("cationic block name")).toBeDefined();
          });
          it("Should have a lsStates with the states in defaultStates", function() {
            expect(this.cbp.get('lsStates')).toBeDefined();
            expect(this.cbp.get("lsStates").length).toEqual(1);
            return expect(this.cbp.get("lsStates").getStatesByTypeAndKind("metadata", "cationic block parent").length).toEqual(1);
          });
          return describe("model attributes for each value in defaultValues", function() {
            it("Should have a model attribute for completion date", function() {
              return expect(this.cbp.get("completion date")).toBeDefined();
            });
            it("Should have a model attribute for notebook", function() {
              return expect(this.cbp.get("notebook")).toBeDefined();
            });
            return it("Should have a model attribute for molecular weight", function() {
              return expect(this.cbp.get("molecular weight")).toBeDefined();
            });
          });
        });
        return describe("model validation", function() {
          it("should be invalid when name is empty", function() {
            var filtErrors;
            this.cbp.get("cationic block name").set("labelText", "");
            expect(this.cbp.isValid()).toBeFalsy();
            filtErrors = _.filter(this.cbp.validationError, function(err) {
              return err.attribute === 'parentName';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
          it("should invalid when recorded date is empty", function() {
            var filtErrors;
            this.cbp.set({
              recordedDate: new Date("").getTime()
            });
            expect(this.cbp.isValid()).toBeFalsy();
            filtErrors = _.filter(this.cbp.validationError, function(err) {
              return err.attribute === 'recordedDate';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
          return it("should be invalid when molecular weight is NaN", function() {
            var filtErrors;
            this.cbp.get("molecular weight").set("value", "fred");
            expect(this.cbp.isValid()).toBeFalsy();
            filtErrors = _.filter(this.cbp.validationError, function(err) {
              return err.attribute === 'molecularWeight';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
        });
      });
      return describe("When created from existing", function() {
        beforeEach(function() {
          return this.cbp = new CationicBlockParent(JSON.parse(JSON.stringify(window.cationicBlockTestJSON.cationicBlockParent)));
        });
        describe("after initial load", function() {
          it("should be defined", function() {
            return expect(this.cbp).toBeDefined();
          });
          it("should have a type", function() {
            return expect(this.cbp.get('lsType')).toEqual("parent");
          });
          it("should have a kind", function() {
            return expect(this.cbp.get('lsKind')).toEqual("cationic block");
          });
          it("should have a scientist set", function() {
            return expect(this.cbp.get('recordedBy')).toEqual("jane");
          });
          it("should have a recordedDate set", function() {
            return expect(this.cbp.get('recordedDate')).toEqual(1375141508000);
          });
          it("Should have label set", function() {
            var label;
            console.log(this.cbp);
            expect(this.cbp.get("cationic block name").get("labelText")).toEqual("cMAP10");
            label = this.cbp.get("lsLabels").getLabelByTypeAndKind("name", "cationic block");
            console.log(label[0]);
            return expect(label[0].get('labelText')).toEqual("cMAP10");
          });
          it("Should have a lsStates with the states in defaultStates", function() {
            expect(this.cbp.get('lsStates')).toBeDefined();
            expect(this.cbp.get("lsStates").length).toEqual(1);
            return expect(this.cbp.get("lsStates").getStatesByTypeAndKind("metadata", "cationic block parent").length).toEqual(1);
          });
          it("Should have a completion date value", function() {
            return expect(this.cbp.get("completion date").get("value")).toEqual(1342080000000);
          });
          it("Should have a notebook value", function() {
            return expect(this.cbp.get("notebook").get("value")).toEqual("Notebook 1");
          });
          return it("Should have a molecular weight value", function() {
            return expect(this.cbp.get("molecular weight").get("value")).toEqual(231);
          });
        });
        return describe("model validation", function() {
          beforeEach(function() {
            return this.cbp = new CationicBlockParent(window.cationicBlockTestJSON.cationicBlockParent);
          });
          it("should be valid when loaded from saved", function() {
            return expect(this.cbp.isValid()).toBeTruthy();
          });
          it("should be invalid when name is empty", function() {
            var filtErrors;
            this.cbp.get("cationic block name").set("labelText", "");
            expect(this.cbp.isValid()).toBeFalsy();
            filtErrors = _.filter(this.cbp.validationError, function(err) {
              return err.attribute === 'parentName';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
          it("should be invalid when recorded date is empty", function() {
            var filtErrors;
            this.cbp.set({
              recordedDate: new Date("").getTime()
            });
            expect(this.cbp.isValid()).toBeFalsy();
            filtErrors = _.filter(this.cbp.validationError, function(err) {
              return err.attribute === 'recordedDate';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
          it("should be invalid when scientist not selected", function() {
            var filtErrors;
            this.cbp.set({
              recordedBy: ""
            });
            expect(this.cbp.isValid()).toBeFalsy();
            filtErrors = _.filter(this.cbp.validationError, function(err) {
              return err.attribute === 'recordedBy';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
          it("should be invalid when completion date is empty", function() {
            var filtErrors;
            this.cbp.get("completion date").set("value", new Date("").getTime());
            expect(this.cbp.isValid()).toBeFalsy();
            filtErrors = _.filter(this.cbp.validationError, function(err) {
              return err.attribute === 'completionDate';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
          it("should be invalid when notebook is empty", function() {
            var filtErrors;
            this.cbp.get("notebook").set("value", "");
            expect(this.cbp.isValid()).toBeFalsy();
            filtErrors = _.filter(this.cbp.validationError, function(err) {
              return err.attribute === 'notebook';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
          return it("should be invalid when molecular weight is NaN", function() {
            var filtErrors;
            this.cbp.get("molecular weight").set("value", "fred");
            expect(this.cbp.isValid()).toBeFalsy();
            filtErrors = _.filter(this.cbp.validationError, function(err) {
              return err.attribute === 'molecularWeight';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
        });
      });
    });
    describe("Cationic Block Parent Controller testing", function() {
      describe("When instantiated from new", function() {
        beforeEach(function() {
          this.cbp = new CationicBlockParent();
          this.cbpc = new CationicBlockParentController({
            model: this.cbp,
            el: $('#fixture')
          });
          return this.cbpc.render();
        });
        return describe("basic existence tests", function() {
          it("should exist", function() {
            return expect(this.cbpc).toBeDefined();
          });
          it("should load the template", function() {
            return expect(this.cbpc.$('.bv_parentCode').html()).toEqual("autofill when saved");
          });
          return it("should load the additional parent attributes temlate", function() {
            return expect(this.cbpc.$('.bv_molecularWeight').length).toEqual(1);
          });
        });
      });
      return describe("When instantiated from existing", function() {
        beforeEach(function() {
          this.cbp = new CationicBlockParent(JSON.parse(JSON.stringify(window.cationicBlockTestJSON.cationicBlockParent)));
          this.cbpc = new CationicBlockParentController({
            model: this.cbp,
            el: $('#fixture')
          });
          return this.cbpc.render();
        });
        describe("render existing parameters", function() {
          it("should show the cationic block parent id", function() {
            return expect(this.cbpc.$('.bv_parentCode').val()).toEqual("CB000001");
          });
          it("should fill the cationic block parent name", function() {
            return expect(this.cbpc.$('.bv_parentName').val()).toEqual("cMAP10");
          });
          it("should fill the scientist field", function() {
            waitsFor(function() {
              return this.cbpc.$('.bv_recordedBy option').length > 0;
            }, 1000);
            return runs(function() {
              console.log(this.cbpc.$('.bv_recordedBy').val());
              return expect(this.cbpc.$('.bv_recordedBy').val()).toEqual("jane");
            });
          });
          it("should fill the completion date field", function() {
            return expect(this.cbpc.$('.bv_completionDate').val()).toEqual("2012-07-12");
          });
          it("should fill the notebook field", function() {
            return expect(this.cbpc.$('.bv_notebook').val()).toEqual("Notebook 1");
          });
          return it("should fill the molecular weight field", function() {
            return expect(this.cbpc.$('.bv_molecularWeight').val()).toEqual("231");
          });
        });
        describe("model updates", function() {
          it("should update model when parent name is changed", function() {
            this.cbpc.$('.bv_parentName').val(" New name   ");
            this.cbpc.$('.bv_parentName').change();
            return expect(this.cbpc.model.get('cationic block name').get('labelText')).toEqual("New name");
          });
          it("should update model when the scientist is changed", function() {
            waitsFor(function() {
              return this.cbpc.$('.bv_recordedBy option').length > 0;
            }, 1000);
            return runs(function() {
              this.cbpc.$('.bv_recordedBy').val('unassigned');
              this.cbpc.$('.bv_recordedBy').change();
              return expect(this.cbpc.model.get('recordedBy')).toEqual("unassigned");
            });
          });
          it("should update model when completion date is changed", function() {
            this.cbpc.$('.bv_completionDate').val(" 2013-3-16   ");
            this.cbpc.$('.bv_completionDate').change();
            return expect(this.cbpc.model.get('completion date').get('value')).toEqual(new Date(2013, 2, 16).getTime());
          });
          it("should update model when notebook is changed", function() {
            this.cbpc.$('.bv_notebook').val(" Updated notebook  ");
            this.cbpc.$('.bv_notebook').change();
            return expect(this.cbpc.model.get('notebook').get('value')).toEqual("Updated notebook");
          });
          return it("should update model when molecular weight is changed", function() {
            this.cbpc.$('.bv_molecularWeight').val(" 12  ");
            this.cbpc.$('.bv_molecularWeight').change();
            return expect(this.cbpc.model.get('molecular weight').get('value')).toEqual(12);
          });
        });
        return describe("controller validation rules", function() {
          beforeEach(function() {
            waitsFor(function() {
              return this.cbpc.$('.bv_recordedBy option').length > 0;
            }, 1000);
            return runs(function() {
              this.cbpc.$('.bv_parentName').val(" Updated entity name   ");
              this.cbpc.$('.bv_parentName').change();
              this.cbpc.$('.bv_recordedBy').val("bob");
              this.cbpc.$('.bv_recordedBy').change();
              this.cbpc.$('.bv_completionDate').val(" 2013-3-16   ");
              this.cbpc.$('.bv_completionDate').change();
              this.cbpc.$('.bv_notebook').val("my notebook");
              this.cbpc.$('.bv_notebook').change();
              this.cbpc.$('.bv_molecularWeight').val(" 24");
              return this.cbpc.$('.bv_molecularWeight').change();
            });
          });
          describe("form validation setup", function() {
            return it("should be valid if form fully filled out", function() {
              return runs(function() {
                return expect(this.cbpc.isValid()).toBeTruthy();
              });
            });
          });
          describe("when name field not filled in", function() {
            beforeEach(function() {
              return runs(function() {
                this.cbpc.$('.bv_parentName').val("");
                return this.cbpc.$('.bv_parentName').change();
              });
            });
            it("should be invalid if name not filled in", function() {
              return runs(function() {
                return expect(this.cbpc.isValid()).toBeFalsy();
              });
            });
            return it("should show error in name field", function() {
              return runs(function() {
                return expect(this.cbpc.$('.bv_group_parentName').hasClass('error')).toBeTruthy();
              });
            });
          });
          describe("when scientist not selected", function() {
            beforeEach(function() {
              return runs(function() {
                this.cbpc.$('.bv_recordedBy').val("");
                return this.cbpc.$('.bv_recordedBy').change();
              });
            });
            return it("should show error on scientist dropdown", function() {
              return runs(function() {
                return expect(this.cbpc.$('.bv_group_recordedBy').hasClass('error')).toBeTruthy();
              });
            });
          });
          describe("when date field not filled in", function() {
            beforeEach(function() {
              return runs(function() {
                this.cbpc.$('.bv_completionDate').val("");
                return this.cbpc.$('.bv_completionDate').change();
              });
            });
            return it("should show error in date field", function() {
              return runs(function() {
                return expect(this.cbpc.$('.bv_group_completionDate').hasClass('error')).toBeTruthy();
              });
            });
          });
          describe("when notebook not filled", function() {
            beforeEach(function() {
              return runs(function() {
                this.cbpc.$('.bv_notebook').val("");
                return this.cbpc.$('.bv_notebook').change();
              });
            });
            return it("should show error on notebook field", function() {
              return runs(function() {
                return expect(this.cbpc.$('.bv_group_notebook').hasClass('error')).toBeTruthy();
              });
            });
          });
          return describe("when molecular weight not filled", function() {
            beforeEach(function() {
              return runs(function() {
                this.cbpc.$('.bv_molecularWeight').val("");
                return this.cbpc.$('.bv_molecularWeight').change();
              });
            });
            return it("should show error on molecular weight field", function() {
              return runs(function() {
                return expect(this.cbpc.$('.bv_group_molecularWeight').hasClass('error')).toBeTruthy();
              });
            });
          });
        });
      });
    });
    describe("Cationic Block Batch model testing", function() {
      describe("when loaded from new", function() {
        beforeEach(function() {
          return this.cbb = new CationicBlockBatch();
        });
        return describe("Existence and Defaults", function() {
          it("should be defined", function() {
            return expect(this.cbb).toBeDefined();
          });
          it("should have a type", function() {
            return expect(this.cbb.get('lsType')).toEqual("batch");
          });
          it("should have a kind", function() {
            return expect(this.cbb.get('lsKind')).toEqual("cationic block");
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
          return this.cbb = new CationicBlockBatch(JSON.parse(JSON.stringify(window.cationicBlockTestJSON.cationicBlockBatch)));
        });
        return describe("after initial load", function() {
          it("should be defined", function() {
            return expect(this.cbb).toBeDefined();
          });
          it("should have a type", function() {
            return expect(this.cbb.get('lsType')).toEqual("batch");
          });
          it("should have a kind", function() {
            return expect(this.cbb.get('lsKind')).toEqual("cationic block");
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
            expect(this.cbb.get("lsStates").getStatesByTypeAndKind("metadata", "cationic block batch").length).toEqual(1);
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
          return this.cbb = new CationicBlockBatch(window.cationicBlockTestJSON.cationicBlockBatch);
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
    describe("Cationic Block Batch Controller testing", function() {
      describe("When instantiated from new", function() {
        beforeEach(function() {
          this.cbb = new CationicBlockBatch();
          this.cbbc = new CationicBlockBatchController({
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
          this.cbb = new CationicBlockBatch(JSON.parse(JSON.stringify(window.cationicBlockTestJSON.cationicBlockBatch)));
          this.cbbc = new CationicBlockBatchController({
            model: this.cbb,
            el: $('#fixture')
          });
          return this.cbbc.render();
        });
        describe("render existing parameters", function() {
          it("should show the cationic block batch id", function() {
            return expect(this.cbbc.$('.bv_batchCode').val()).toEqual("CB000001-1");
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
    describe("Cationic Block Batch Select Controller testing", function() {
      beforeEach(function() {
        this.cbb = new CationicBlockBatch();
        this.cbbsc = new CationicBlockBatchSelectController({
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
    return describe("Cationic Block Controller", function() {
      beforeEach(function() {
        this.cbc = new CationicBlockController({
          model: new CationicBlockParent(),
          el: $('#fixture')
        });
        return this.cbc.render();
      });
      return describe("Basic loading", function() {
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
    });
  });

}).call(this);
