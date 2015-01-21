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
            return expect(this.spc.$('.bv_parentCode').html()).toEqual("Autofilled when saved");
          });
          return it("should load the additional parent attributes template", function() {
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
            this.spc.$('.bv_parentName').keyup();
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
            this.spc.$('.bv_completionDate').keyup();
            return expect(this.spc.model.get('completion date').get('value')).toEqual(new Date(2013, 2, 16).getTime());
          });
          it("should update model when notebook is changed", function() {
            this.spc.$('.bv_notebook').val(" Updated notebook  ");
            this.spc.$('.bv_notebook').keyup();
            return expect(this.spc.model.get('notebook').get('value')).toEqual("Updated notebook");
          });
          return it("should update model when molecular weight is changed", function() {
            this.spc.$('.bv_molecularWeight').val(" 12  ");
            this.spc.$('.bv_molecularWeight').keyup();
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
              this.spc.$('.bv_parentName').keyup();
              this.spc.$('.bv_recordedBy').val("bob");
              this.spc.$('.bv_recordedBy').change();
              this.spc.$('.bv_completionDate').val(" 2013-3-16   ");
              this.spc.$('.bv_completionDate').keyup();
              this.spc.$('.bv_notebook').val("my notebook");
              this.spc.$('.bv_notebook').keyup();
              this.spc.$('.bv_molecularWeight').val(" 24");
              return this.spc.$('.bv_molecularWeight').keyup();
            });
          });
          describe("form validation setup", function() {
            it("should be valid if form fully filled out", function() {
              return runs(function() {
                return expect(this.spc.isValid()).toBeTruthy();
              });
            });
            return it("should have the update button be enabled", function() {
              return runs(function() {
                return expect(this.spc.$('.bv_updateParent').attr('disabled')).toBeUndefined();
              });
            });
          });
          describe("when name field not filled in", function() {
            beforeEach(function() {
              return runs(function() {
                this.spc.$('.bv_parentName').val("");
                return this.spc.$('.bv_parentName').keyup();
              });
            });
            it("should be invalid if name not filled in", function() {
              return runs(function() {
                return expect(this.spc.isValid()).toBeFalsy();
              });
            });
            it("should show error in name field", function() {
              return runs(function() {
                return expect(this.spc.$('.bv_group_parentName').hasClass('error')).toBeTruthy();
              });
            });
            return it("should have the update button be disabled", function() {
              return runs(function() {
                return expect(this.spc.$('.bv_updateParent').attr('disabled')).toEqual('disabled');
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
                return this.spc.$('.bv_completionDate').keyup();
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
                return this.spc.$('.bv_notebook').keyup();
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
                return this.spc.$('.bv_molecularWeight').keyup();
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
          return this.sb = new SpacerBatch();
        });
        return describe("Existence and Defaults", function() {
          it("should be defined", function() {
            return expect(this.sb).toBeDefined();
          });
          it("should have a type", function() {
            return expect(this.sb.get('lsType')).toEqual("batch");
          });
          it("should have a kind", function() {
            return expect(this.sb.get('lsKind')).toEqual("spacer");
          });
          it("should have an empty scientist", function() {
            return expect(this.sb.get('recordedBy')).toEqual("");
          });
          it("should have a recordedDate set to now", function() {
            return expect(new Date(this.sb.get('recordedDate')).getHours()).toEqual(new Date().getHours());
          });
          return describe("model attributes for each value in defaultValues", function() {
            it("Should have a model attribute for completion date", function() {
              return expect(this.sb.get("completion date")).toBeDefined();
            });
            it("Should have a model attribute for notebook", function() {
              return expect(this.sb.get("notebook")).toBeDefined();
            });
            it("Should have a model attribute for source", function() {
              expect(this.sb.get("source").get).toBeDefined();
              return expect(this.sb.get("source").get('value')).toEqual("Avidity");
            });
            it("Should have a model attribute for source id", function() {
              return expect(this.sb.get("source id")).toBeDefined();
            });
            it("Should have a model attribute for amount made", function() {
              return expect(this.sb.get("amount made")).toBeDefined();
            });
            return it("Should have a model attribute for location", function() {
              return expect(this.sb.get("location")).toBeDefined();
            });
          });
        });
      });
      describe("When created from existing", function() {
        beforeEach(function() {
          return this.sb = new SpacerBatch(JSON.parse(JSON.stringify(window.spacerTestJSON.spacerBatch)));
        });
        return describe("after initial load", function() {
          it("should be defined", function() {
            return expect(this.sb).toBeDefined();
          });
          it("should have a type", function() {
            return expect(this.sb.get('lsType')).toEqual("batch");
          });
          it("should have a kind", function() {
            return expect(this.sb.get('lsKind')).toEqual("spacer");
          });
          it("should have a scientist set", function() {
            return expect(this.sb.get('recordedBy')).toEqual("jane");
          });
          it("should have a recordedDate set", function() {
            return expect(this.sb.get('recordedDate')).toEqual(1375141508000);
          });
          it("Should have a lsStates with the states in defaultStates", function() {
            expect(this.sb.get('lsStates')).toBeDefined();
            expect(this.sb.get("lsStates").length).toEqual(2);
            expect(this.sb.get("lsStates").getStatesByTypeAndKind("metadata", "spacer batch").length).toEqual(1);
            return expect(this.sb.get("lsStates").getStatesByTypeAndKind("metadata", "inventory").length).toEqual(1);
          });
          it("Should have a completion date value", function() {
            return expect(this.sb.get("completion date").get("value")).toEqual(1342080000000);
          });
          it("Should have a notebook value", function() {
            return expect(this.sb.get("notebook").get("value")).toEqual("Notebook 1");
          });
          it("Should have a source value", function() {
            return expect(this.sb.get("source").get("value")).toEqual("Avidity");
          });
          it("Should have a source id", function() {
            return expect(this.sb.get("source id").get("value")).toEqual("12345");
          });
          it("Should have an amount made value", function() {
            return expect(this.sb.get("amount made").get("value")).toEqual(2.3);
          });
          return it("Should have a location value", function() {
            return expect(this.sb.get("location").get("value")).toEqual("Cabinet 1");
          });
        });
      });
      return describe("model validation", function() {
        beforeEach(function() {
          return this.sb = new SpacerBatch(window.spacerTestJSON.spacerBatch);
        });
        it("should be valid when loaded from saved", function() {
          return expect(this.sb.isValid()).toBeTruthy();
        });
        it("should be invalid when recorded date is empty", function() {
          var filtErrors;
          this.sb.set({
            recordedDate: new Date("").getTime()
          });
          expect(this.sb.isValid()).toBeFalsy();
          filtErrors = _.filter(this.sb.validationError, function(err) {
            return err.attribute === 'recordedDate';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it("should be invalid when scientist not selected", function() {
          var filtErrors;
          this.sb.set({
            recordedBy: ""
          });
          expect(this.sb.isValid()).toBeFalsy();
          return filtErrors = _.filter(this.sb.validationError, function(err) {
            return err.attribute === 'recordedBy';
          });
        });
        it("should be invalid when completion date is empty", function() {
          var filtErrors;
          this.sb.get("completion date").set("value", new Date("").getTime());
          expect(this.sb.isValid()).toBeFalsy();
          filtErrors = _.filter(this.sb.validationError, function(err) {
            return err.attribute === 'completionDate';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it("should be invalid when notebook is empty", function() {
          var filtErrors;
          this.sb.get("notebook").set("value", "");
          expect(this.sb.isValid()).toBeFalsy();
          filtErrors = _.filter(this.sb.validationError, function(err) {
            return err.attribute === 'notebook';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it("should be invalid when source is not selected", function() {
          var filtErrors;
          this.sb.get("source").set("value", "unassigned");
          expect(this.sb.isValid()).toBeFalsy();
          return filtErrors = _.filter(this.sb.validationError, function(err) {
            return err.attribute === 'source';
          });
        });
        it("should be invalid when amount made is NaN", function() {
          var filtErrors;
          this.sb.get("amount made").set("value", "fred");
          expect(this.sb.isValid()).toBeFalsy();
          filtErrors = _.filter(this.sb.validationError, function(err) {
            return err.attribute === 'amountMade';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        return it("should be invalid when location is empty", function() {
          var filtErrors;
          this.sb.get("location").set("value", "");
          expect(this.sb.isValid()).toBeFalsy();
          filtErrors = _.filter(this.sb.validationError, function(err) {
            return err.attribute === 'location';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
      });
    });
    describe("Spacer Batch Controller testing", function() {
      describe("When instantiated from new", function() {
        beforeEach(function() {
          this.sb = new SpacerBatch();
          this.sbc = new SpacerBatchController({
            model: this.sb,
            el: $('#fixture')
          });
          return this.sbc.render();
        });
        return describe("basic existence tests", function() {
          it("should exist", function() {
            return expect(this.sbc).toBeDefined();
          });
          return it("should load the template", function() {
            return expect(this.sbc.$('.bv_batchCode').html()).toEqual("Autofilled when saved");
          });
        });
      });
      return describe("When instantiated from existing", function() {
        beforeEach(function() {
          this.sb = new SpacerBatch(JSON.parse(JSON.stringify(window.spacerTestJSON.spacerBatch)));
          this.sbc = new SpacerBatchController({
            model: this.sb,
            el: $('#fixture')
          });
          return this.sbc.render();
        });
        describe("render existing parameters", function() {
          it("should show the spacer batch id", function() {
            return expect(this.sbc.$('.bv_batchCode').val()).toEqual("SP000001-1");
          });
          it("should fill the scientist field", function() {
            waitsFor(function() {
              return this.sbc.$('.bv_recordedBy option').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.sbc.$('.bv_recordedBy').val()).toEqual("jane");
            });
          });
          it("should fill the completion date field", function() {
            return expect(this.sbc.$('.bv_completionDate').val()).toEqual("2012-07-12");
          });
          it("should fill the notebook field", function() {
            return expect(this.sbc.$('.bv_notebook').val()).toEqual("Notebook 1");
          });
          it("should fill the source field", function() {
            waitsFor(function() {
              return this.sbc.$('.bv_source option').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.sbc.$('.bv_source').val()).toEqual("Avidity");
            });
          });
          it("should fill the source id field", function() {
            return expect(this.sbc.$('.bv_sourceId').val()).toEqual("12345");
          });
          it("should fill the amountMade field", function() {
            return expect(this.sbc.$('.bv_amountMade').val()).toEqual("2.3");
          });
          return it("should fill the location field", function() {
            return expect(this.sbc.$('.bv_location').val()).toEqual("Cabinet 1");
          });
        });
        describe("model updates", function() {
          it("should update model when the scientist is changed", function() {
            waitsFor(function() {
              return this.sbc.$('.bv_recordedBy option').length > 0;
            }, 1000);
            return runs(function() {
              this.sbc.$('.bv_recordedBy').val('unassigned');
              this.sbc.$('.bv_recordedBy').change();
              return expect(this.sbc.model.get('recordedBy')).toEqual("unassigned");
            });
          });
          it("should update model when completion date is changed", function() {
            this.sbc.$('.bv_completionDate').val(" 2013-3-16   ");
            this.sbc.$('.bv_completionDate').keyup();
            return expect(this.sbc.model.get('completion date').get('value')).toEqual(new Date(2013, 2, 16).getTime());
          });
          it("should update model when notebook is changed", function() {
            this.sbc.$('.bv_notebook').val(" Updated notebook  ");
            this.sbc.$('.bv_notebook').keyup();
            return expect(this.sbc.model.get('notebook').get('value')).toEqual("Updated notebook");
          });
          it("should update model when the source is changed", function() {
            waitsFor(function() {
              return this.sbc.$('.bv_source option').length > 0;
            }, 1000);
            return runs(function() {
              this.sbc.$('.bv_source').val('unassigned');
              this.sbc.$('.bv_source').change();
              return expect(this.sbc.model.get('source').get('value')).toEqual("unassigned");
            });
          });
          it("should update model when source id is changed", function() {
            this.sbc.$('.bv_sourceId').val(" 252  ");
            this.sbc.$('.bv_sourceId').keyup();
            return expect(this.sbc.model.get('source id').get('value')).toEqual("252");
          });
          it("should update model when amount made is changed", function() {
            this.sbc.$('.bv_amountMade').val(" 12  ");
            this.sbc.$('.bv_amountMade').keyup();
            return expect(this.sbc.model.get('amount made').get('value')).toEqual(12);
          });
          return it("should update model when location is changed", function() {
            this.sbc.$('.bv_location').val(" Updated location  ");
            this.sbc.$('.bv_location').keyup();
            return expect(this.sbc.model.get('location').get('value')).toEqual("Updated location");
          });
        });
        return describe("controller validation rules", function() {
          beforeEach(function() {
            waitsFor(function() {
              return this.sbc.$('.bv_recordedBy option').length > 0;
            }, 1000);
            return runs(function() {
              this.sbc.$('.bv_recordedBy').val("bob");
              this.sbc.$('.bv_recordedBy').change();
              this.sbc.$('.bv_completionDate').val(" 2013-3-16   ");
              this.sbc.$('.bv_completionDate').keyup();
              this.sbc.$('.bv_notebook').val("my notebook");
              this.sbc.$('.bv_notebook').keyup();
              this.sbc.$('.bv_source').val("vendor A");
              this.sbc.$('.bv_source').change();
              this.sbc.$('.bv_sourceId').val(" 24");
              this.sbc.$('.bv_sourceId').keyup();
              this.sbc.$('.bv_amountMade').val(" 24");
              this.sbc.$('.bv_amountMade').keyup();
              this.sbc.$('.bv_location').val(" Hood 4");
              return this.sbc.$('.bv_location').keyup();
            });
          });
          describe("form validation setup", function() {
            it("should be valid if form fully filled out", function() {
              return runs(function() {
                return expect(this.sbc.isValid()).toBeTruthy();
              });
            });
            return it("save button should be enabled", function() {
              return runs(function() {
                return expect(this.sbc.$('.bv_saveBatch').attr('disabled')).toBeUndefined();
              });
            });
          });
          describe("when scientist not selected", function() {
            beforeEach(function() {
              return runs(function() {
                this.sbc.$('.bv_recordedBy').val("");
                return this.sbc.$('.bv_recordedBy').change();
              });
            });
            it("should show error on scientist dropdown", function() {
              return runs(function() {
                return expect(this.sbc.$('.bv_group_recordedBy').hasClass('error')).toBeTruthy();
              });
            });
            return it("should have the update button be disabled", function() {
              return runs(function() {
                return expect(this.sbc.$('.bv_saveBatch').attr('disabled')).toEqual('disabled');
              });
            });
          });
          describe("when date field not filled in", function() {
            beforeEach(function() {
              return runs(function() {
                this.sbc.$('.bv_completionDate').val("");
                return this.sbc.$('.bv_completionDate').keyup();
              });
            });
            return it("should show error in date field", function() {
              return runs(function() {
                return expect(this.sbc.$('.bv_group_completionDate').hasClass('error')).toBeTruthy();
              });
            });
          });
          describe("when notebook not filled", function() {
            beforeEach(function() {
              return runs(function() {
                this.sbc.$('.bv_notebook').val("");
                return this.sbc.$('.bv_notebook').keyup();
              });
            });
            return it("should show error on notebook field", function() {
              return runs(function() {
                return expect(this.sbc.$('.bv_group_notebook').hasClass('error')).toBeTruthy();
              });
            });
          });
          describe("when source not selected", function() {
            beforeEach(function() {
              return runs(function() {
                this.sbc.$('.bv_source').val("");
                return this.sbc.$('.bv_source').change();
              });
            });
            it("should show error on source dropdown", function() {
              return runs(function() {
                return expect(this.sbc.$('.bv_group_source').hasClass('error')).toBeTruthy();
              });
            });
            return it("should have the update button be disabled", function() {
              return runs(function() {
                return expect(this.sbc.$('.bv_saveBatch').attr('disabled')).toEqual('disabled');
              });
            });
          });
          describe("when amount made not filled", function() {
            beforeEach(function() {
              return runs(function() {
                this.sbc.$('.bv_amountMade').val("");
                return this.sbc.$('.bv_amountMade').keyup();
              });
            });
            return it("should show error on amount made field", function() {
              return runs(function() {
                return expect(this.sbc.$('.bv_group_amountMade').hasClass('error')).toBeTruthy();
              });
            });
          });
          return describe("when location not filled", function() {
            beforeEach(function() {
              return runs(function() {
                this.sbc.$('.bv_location').val("");
                return this.sbc.$('.bv_location').keyup();
              });
            });
            return it("should show error on location field", function() {
              return runs(function() {
                return expect(this.sbc.$('.bv_group_location').hasClass('error')).toBeTruthy();
              });
            });
          });
        });
      });
    });
    describe("Spacer Batch Select Controller testing", function() {
      beforeEach(function() {
        this.sb = new SpacerBatch();
        this.sbsc = new SpacerBatchSelectController({
          model: this.sb,
          el: $('#fixture')
        });
        return this.sbsc.render();
      });
      describe("When instantiated", function() {
        describe("basic existence tests", function() {
          it("should exist", function() {
            return expect(this.sbsc).toBeDefined();
          });
          return it("should load the template", function() {
            return expect(this.sbsc.$('.bv_batchList').length).toEqual(1);
          });
        });
        return describe("rendering", function() {
          it("should have the batch list default to register new batch", function() {
            waitsFor(function() {
              return this.sbsc.$('.bv_batchList option').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.sbsc.$('.bv_batchList').val()).toEqual("new batch");
            });
          });
          return it("should a new batch registration form", function() {
            console.log(this.sbsc.$('.bv_batchCode'));
            expect(this.sbsc.$('.bv_batchCode').val()).toEqual("");
            return expect(this.sbsc.$('.bv_batchCode').html()).toEqual("Autofilled when saved");
          });
        });
      });
      return describe("behavior", function() {
        return it("should show the information for a selected batch", function() {
          waitsFor(function() {
            return this.sbsc.$('.bv_batchList option').length > 0;
          }, 1000);
          runs(function() {
            console.log(this.sbsc.$('.bv_batchList'));
            this.sbsc.$('.bv_batchList').val("CB000001-1");
            return this.sbsc.$('.bv_batchList').change();
          });
          waitsFor(function() {
            return this.sbsc.$('.bv_recordedBy option').length > 0;
          }, 1000);
          runs(function() {
            return waits(1000);
          });
          return runs(function() {
            expect(this.sbsc.$('.bv_batchCode').html()).toEqual("CB000001-1");
            return expect(this.sbsc.$('.bv_recordedBy').val()).toEqual("jane");
          });
        });
      });
    });
    return describe("Spacer Controller", function() {
      beforeEach(function() {
        this.sbc = new SpacerController({
          model: new SpacerParent(),
          el: $('#fixture')
        });
        return this.sbc.render();
      });
      describe("Basic loading", function() {
        it("Class should exist", function() {
          return expect(this.sbc).toBeDefined();
        });
        it("Should load the template", function() {
          return expect(this.sbc.$('.bv_save').length).toEqual(1);
        });
        it("Should load a parent controller", function() {
          return expect(this.sbc.$('.bv_parent .bv_parentCode').length).toEqual(1);
        });
        return it("Should load a batch controller", function() {
          return expect(this.sbc.$('.bv_batch .bv_batchCode').length).toEqual(1);
        });
      });
      return describe("saving parent/batch for the first time", function() {
        describe("when form is initialized", function() {
          return it("should have the save button be disabled initially", function() {
            return expect(this.sbc.$('.bv_save').attr('disabled')).toEqual('disabled');
          });
        });
        return describe('when save is clicked', function() {
          beforeEach(function() {
            runs(function() {
              this.sbc.$('.bv_parentName').val(" Updated entity name   ");
              this.sbc.$('.bv_parentName').keyup();
              this.sbc.$('.bv_recordedBy').val("bob");
              this.sbc.$('.bv_recordedBy').change();
              this.sbc.$('.bv_completionDate').val(" 2013-3-16   ");
              this.sbc.$('.bv_completionDate').keyup();
              this.sbc.$('.bv_notebook').val("my notebook");
              this.sbc.$('.bv_notebook').keyup();
              this.sbc.$('.bv_source').val("Avidity");
              this.sbc.$('.bv_source').change();
              this.sbc.$('.bv_sourceId').val("12345");
              this.sbc.$('.bv_sourceId').keyup();
              this.sbc.$('.bv_molecularWeight').val(" 24");
              this.sbc.$('.bv_molecularWeight').keyup();
              this.sbc.$('.bv_amountMade').val(" 24");
              this.sbc.$('.bv_amountMade').keyup();
              this.sbc.$('.bv_location').val(" Hood 4");
              return this.sbc.$('.bv_location').keyup();
            });
            return waitsFor(function() {
              return this.sbc.$('.bv_recordedBy option').length > 0;
            }, 1000);
          });
          it("should have the save button be enabled", function() {
            return runs(function() {
              return expect(this.sbc.$('.bv_save').attr('disabled')).toBeUndefined();
            });
          });
          it("should update the parent code", function() {
            runs(function() {
              return this.sbc.$('.bv_save').click();
            });
            waits(1000);
            return runs(function() {
              return expect(this.sbc.$('.bv_parentCode').html()).toEqual("SP000001");
            });
          });
          it("should update the batch code", function() {
            runs(function() {
              return this.sbc.$('.bv_save').click();
            });
            waits(1000);
            return runs(function() {
              return expect(this.sbc.$('.bv_batchCode').html()).toEqual("SP000001-1");
            });
          });
          it("should show the update parent button", function() {
            runs(function() {
              return this.sbc.$('.bv_save').click();
            });
            waits(1000);
            return runs(function() {
              return expect(this.sbc.$('.bv_updateParent')).toBeVisible();
            });
          });
          return it("should show the update batch button", function() {
            runs(function() {
              return this.sbc.$('.bv_save').click();
            });
            waits(1000);
            return runs(function() {
              return expect(this.sbc.$('.bv_saveBatch')).toBeVisible();
            });
          });
        });
      });
    });
  });

}).call(this);
