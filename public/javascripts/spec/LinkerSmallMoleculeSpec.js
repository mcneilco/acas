(function() {
  beforeEach(function() {
    return this.fixture = $.clone($("#fixture").get(0));
  });

  afterEach(function() {
    $("#fixture").remove();
    return $("body").append($(this.fixture));
  });

  describe('Linker Small Molecule testing', function() {
    describe(" Parent model testing", function() {
      describe("when loaded from new", function() {
        beforeEach(function() {
          return this.lsmp = new LinkerSmallMoleculeParent();
        });
        describe("Existence and Defaults", function() {
          it("should be defined", function() {
            return expect(this.lsmp).toBeDefined();
          });
          it("should have a type", function() {
            return expect(this.lsmp.get('lsType')).toEqual("parent");
          });
          it("should have a kind", function() {
            return expect(this.lsmp.get('lsKind')).toEqual("linker small molecule");
          });
          it("should have the recordedBy set to the logged in user", function() {
            return expect(this.lsmp.get('recordedBy')).toEqual(window.AppLaunchParams.loginUser.username);
          });
          it("should have a recordedDate set to now", function() {
            return expect(new Date(this.lsmp.get('recordedDate')).getHours()).toEqual(new Date().getHours());
          });
          it("Should have a lsLabels with one label", function() {
            expect(this.lsmp.get('lsLabels')).toBeDefined();
            expect(this.lsmp.get("lsLabels").length).toEqual(1);
            return expect(this.lsmp.get("lsLabels").getLabelByTypeAndKind("name", "linker small molecule").length).toEqual(1);
          });
          it("Should have a model attribute for the label in defaultLabels", function() {
            return expect(this.lsmp.get("linker small molecule name")).toBeDefined();
          });
          it("Should have a lsStates with the states in defaultStates", function() {
            expect(this.lsmp.get('lsStates')).toBeDefined();
            expect(this.lsmp.get("lsStates").length).toEqual(1);
            return expect(this.lsmp.get("lsStates").getStatesByTypeAndKind("metadata", "linker small molecule parent").length).toEqual(1);
          });
          return describe("model attributes for each value in defaultValues", function() {
            it("Should have a model attribute for scientist", function() {
              return expect(this.lsmp.get("scientist")).toBeDefined();
            });
            it("Should have a model attribute for completion date", function() {
              return expect(this.lsmp.get("completion date")).toBeDefined();
            });
            it("Should have a model attribute for notebook", function() {
              return expect(this.lsmp.get("notebook")).toBeDefined();
            });
            it("Should have a model attribute for molecular weight", function() {
              return expect(this.lsmp.get("molecular weight")).toBeDefined();
            });
            return it("Should have a model attribute for structural file", function() {
              return expect(this.lsmp.get("structural file")).toBeDefined();
            });
          });
        });
        return describe("model validation", function() {
          it("should be invalid when name is empty", function() {
            var filtErrors;
            this.lsmp.get("linker small molecule name").set("labelText", "");
            expect(this.lsmp.isValid()).toBeFalsy();
            filtErrors = _.filter(this.lsmp.validationError, function(err) {
              return err.attribute === 'parentName';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
          return it("should be invalid when molecular weight is NaN", function() {
            var filtErrors;
            this.lsmp.get("molecular weight").set("value", "fred");
            expect(this.lsmp.isValid()).toBeFalsy();
            filtErrors = _.filter(this.lsmp.validationError, function(err) {
              return err.attribute === 'molecularWeight';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
        });
      });
      return describe("When created from existing", function() {
        beforeEach(function() {
          return this.lsmp = new LinkerSmallMoleculeParent(JSON.parse(JSON.stringify(window.linkerSmallMoleculeTestJSON.linkerSmallMoleculeParent)));
        });
        describe("after initial load", function() {
          it("should be defined", function() {
            return expect(this.lsmp).toBeDefined();
          });
          it("should have a type", function() {
            return expect(this.lsmp.get('lsType')).toEqual("parent");
          });
          it("should have a kind", function() {
            return expect(this.lsmp.get('lsKind')).toEqual("linker small molecule");
          });
          it("should have a recordedBy set", function() {
            return expect(this.lsmp.get('recordedBy')).toEqual("jane");
          });
          it("should have a recordedDate set", function() {
            return expect(this.lsmp.get('recordedDate')).toEqual(1375141508000);
          });
          it("Should have label set", function() {
            var label;
            console.log(this.lsmp);
            expect(this.lsmp.get("linker small molecule name").get("labelText")).toEqual("Ad");
            label = this.lsmp.get("lsLabels").getLabelByTypeAndKind("name", "linker small molecule");
            console.log(label[0]);
            return expect(label[0].get('labelText')).toEqual("Ad");
          });
          it("Should have a lsStates with the states in defaultStates", function() {
            expect(this.lsmp.get('lsStates')).toBeDefined();
            expect(this.lsmp.get("lsStates").length).toEqual(1);
            return expect(this.lsmp.get("lsStates").getStatesByTypeAndKind("metadata", "linker small molecule parent").length).toEqual(1);
          });
          it("Should have a scientist value", function() {
            return expect(this.lsmp.get("scientist").get("value")).toEqual("john");
          });
          it("Should have a completion date value", function() {
            return expect(this.lsmp.get("completion date").get("value")).toEqual(1342080000000);
          });
          it("Should have a notebook value", function() {
            return expect(this.lsmp.get("notebook").get("value")).toEqual("Notebook 1");
          });
          it("Should have a molecular weight value", function() {
            return expect(this.lsmp.get("molecular weight").get("value")).toEqual(231);
          });
          return it("Should have a structural file value", function() {
            return expect(this.lsmp.get("structural file").get("value")).toEqual("TestFile.mol");
          });
        });
        return describe("model validation", function() {
          beforeEach(function() {
            return this.lsmp = new LinkerSmallMoleculeParent(window.linkerSmallMoleculeTestJSON.linkerSmallMoleculeParent);
          });
          it("should be valid when loaded from saved", function() {
            return expect(this.lsmp.isValid()).toBeTruthy();
          });
          it("should be invalid when name is empty", function() {
            var filtErrors;
            this.lsmp.get("linker small molecule name").set("labelText", "");
            expect(this.lsmp.isValid()).toBeFalsy();
            filtErrors = _.filter(this.lsmp.validationError, function(err) {
              return err.attribute === 'parentName';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
          it("should be invalid when scientist not selected", function() {
            var filtErrors;
            this.lsmp.get('scientist').set('value', "unassigned");
            expect(this.lsmp.isValid()).toBeFalsy();
            filtErrors = _.filter(this.lsmp.validationError, function(err) {
              return err.attribute === 'scientist';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
          it("should be invalid when completion date is empty", function() {
            var filtErrors;
            this.lsmp.get("completion date").set("value", new Date("").getTime());
            expect(this.lsmp.isValid()).toBeFalsy();
            filtErrors = _.filter(this.lsmp.validationError, function(err) {
              return err.attribute === 'completionDate';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
          it("should be invalid when notebook is empty", function() {
            var filtErrors;
            this.lsmp.get("notebook").set("value", "");
            expect(this.lsmp.isValid()).toBeFalsy();
            filtErrors = _.filter(this.lsmp.validationError, function(err) {
              return err.attribute === 'notebook';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
          return it("should be invalid when molecular weight is NaN", function() {
            var filtErrors;
            this.lsmp.get("molecular weight").set("value", "fred");
            expect(this.lsmp.isValid()).toBeFalsy();
            filtErrors = _.filter(this.lsmp.validationError, function(err) {
              return err.attribute === 'molecularWeight';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
        });
      });
    });
    describe("Linker Small Molecule Batch model testing", function() {
      describe("when loaded from new", function() {
        beforeEach(function() {
          return this.lsmb = new LinkerSmallMoleculeBatch();
        });
        return describe("Existence and Defaults", function() {
          it("should be defined", function() {
            return expect(this.lsmb).toBeDefined();
          });
          it("should have a type", function() {
            return expect(this.lsmb.get('lsType')).toEqual("batch");
          });
          it("should have a kind", function() {
            return expect(this.lsmb.get('lsKind')).toEqual("linker small molecule");
          });
          it("should have a recordedBy set to logged in user", function() {
            return expect(this.lsmb.get('recordedBy')).toEqual(window.AppLaunchParams.loginUser.username);
          });
          it("should have a recordedDate set to now", function() {
            return expect(new Date(this.lsmb.get('recordedDate')).getHours()).toEqual(new Date().getHours());
          });
          return describe("model attributes for each value in defaultValues", function() {
            it("Should have a model attribute for scientist", function() {
              return expect(this.lsmb.get("scientist")).toBeDefined();
            });
            it("Should have a model attribute for completion date", function() {
              return expect(this.lsmb.get("completion date")).toBeDefined();
            });
            it("Should have a model attribute for notebook", function() {
              return expect(this.lsmb.get("notebook")).toBeDefined();
            });
            it("Should have a model attribute for source", function() {
              expect(this.lsmb.get("source").get).toBeDefined();
              return expect(this.lsmb.get("source").get('value')).toEqual("Avidity");
            });
            it("Should have a model attribute for source id", function() {
              return expect(this.lsmb.get("source id")).toBeDefined();
            });
            it("Should have a model attribute for purity", function() {
              return expect(this.lsmb.get("purity")).toBeDefined();
            });
            it("Should have a model attribute for amount made", function() {
              return expect(this.lsmb.get("amount made")).toBeDefined();
            });
            return it("Should have a model attribute for location", function() {
              return expect(this.lsmb.get("location")).toBeDefined();
            });
          });
        });
      });
      describe("When created from existing", function() {
        beforeEach(function() {
          return this.lsmb = new LinkerSmallMoleculeBatch(JSON.parse(JSON.stringify(window.linkerSmallMoleculeTestJSON.linkerSmallMoleculeBatch)));
        });
        return describe("after initial load", function() {
          it("should be defined", function() {
            return expect(this.lsmb).toBeDefined();
          });
          it("should have a type", function() {
            return expect(this.lsmb.get('lsType')).toEqual("batch");
          });
          it("should have a kind", function() {
            return expect(this.lsmb.get('lsKind')).toEqual("linker small molecule");
          });
          it("should have a scientist set", function() {
            return expect(this.lsmb.get('recordedBy')).toEqual("jane");
          });
          it("should have a recordedDate set", function() {
            return expect(this.lsmb.get('recordedDate')).toEqual(1375141508000);
          });
          it("Should have a lsStates with the states in defaultStates", function() {
            expect(this.lsmb.get('lsStates')).toBeDefined();
            expect(this.lsmb.get("lsStates").length).toEqual(2);
            expect(this.lsmb.get("lsStates").getStatesByTypeAndKind("metadata", "linker small molecule batch").length).toEqual(1);
            return expect(this.lsmb.get("lsStates").getStatesByTypeAndKind("metadata", "inventory").length).toEqual(1);
          });
          it("Should have a scientist value", function() {
            return expect(this.lsmb.get("scientist").get("value")).toEqual("john");
          });
          it("Should have a completion date value", function() {
            return expect(this.lsmb.get("completion date").get("value")).toEqual(1342080000000);
          });
          it("Should have a notebook value", function() {
            return expect(this.lsmb.get("notebook").get("value")).toEqual("Notebook 1");
          });
          it("Should have a source value", function() {
            return expect(this.lsmb.get("source").get("value")).toEqual("Avidity");
          });
          it("Should have a source id", function() {
            return expect(this.lsmb.get("source id").get("value")).toEqual("12345");
          });
          it("Should have a purity value", function() {
            return expect(this.lsmb.get("purity").get("value")).toEqual(92);
          });
          it("Should have an amount made value", function() {
            return expect(this.lsmb.get("amount made").get("value")).toEqual(2.3);
          });
          return it("Should have a location value", function() {
            return expect(this.lsmb.get("location").get("value")).toEqual("Cabinet 1");
          });
        });
      });
      return describe("model validation", function() {
        beforeEach(function() {
          return this.lsmb = new LinkerSmallMoleculeBatch(window.linkerSmallMoleculeTestJSON.linkerSmallMoleculeBatch);
        });
        it("should be valid when loaded from saved", function() {
          return expect(this.lsmb.isValid()).toBeTruthy();
        });
        it("should be invalid when scientist not selected", function() {
          var filtErrors;
          this.lsmb.get('scientist').set('value', "unassigned");
          expect(this.lsmb.isValid()).toBeFalsy();
          return filtErrors = _.filter(this.lsmb.validationError, function(err) {
            return err.attribute === 'scientist';
          });
        });
        it("should be invalid when completion date is empty", function() {
          var filtErrors;
          this.lsmb.get("completion date").set("value", new Date("").getTime());
          expect(this.lsmb.isValid()).toBeFalsy();
          filtErrors = _.filter(this.lsmb.validationError, function(err) {
            return err.attribute === 'completionDate';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it("should be invalid when notebook is empty", function() {
          var filtErrors;
          this.lsmb.get("notebook").set("value", "");
          expect(this.lsmb.isValid()).toBeFalsy();
          filtErrors = _.filter(this.lsmb.validationError, function(err) {
            return err.attribute === 'notebook';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it("should be invalid when source is not selected", function() {
          var filtErrors;
          this.lsmb.get("source").set("value", "unassigned");
          expect(this.lsmb.isValid()).toBeFalsy();
          return filtErrors = _.filter(this.lsmb.validationError, function(err) {
            return err.attribute === 'source';
          });
        });
        it("should be invalid when purity is NaN", function() {
          var filtErrors;
          this.lsmb.get("purity").set("value", "fred");
          expect(this.lsmb.isValid()).toBeFalsy();
          filtErrors = _.filter(this.lsmb.validationError, function(err) {
            return err.attribute === 'purity';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it("should be invalid when amount made is NaN", function() {
          var filtErrors;
          this.lsmb.get("amount made").set("value", "fred");
          expect(this.lsmb.isValid()).toBeFalsy();
          filtErrors = _.filter(this.lsmb.validationError, function(err) {
            return err.attribute === 'amountMade';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        return it("should be invalid when location is empty", function() {
          var filtErrors;
          this.lsmb.get("location").set("value", "");
          expect(this.lsmb.isValid()).toBeFalsy();
          filtErrors = _.filter(this.lsmb.validationError, function(err) {
            return err.attribute === 'location';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
      });
    });
    describe("Linker Small Molecule Parent Controller testing", function() {
      describe("When instantiated from new", function() {
        beforeEach(function() {
          this.lsmp = new LinkerSmallMoleculeParent();
          this.lsmpc = new LinkerSmallMoleculeParentController({
            model: this.lsmp,
            el: $('#fixture')
          });
          return this.lsmpc.render();
        });
        return describe("basic existence tests", function() {
          it("should exist", function() {
            return expect(this.lsmpc).toBeDefined();
          });
          it("should load the template", function() {
            return expect(this.lsmpc.$('.bv_parentCode').html()).toEqual("Autofilled when saved");
          });
          return it("should load the additional parent attributes temlate", function() {
            return expect(this.lsmpc.$('.bv_molecularWeight').length).toEqual(1);
          });
        });
      });
      return describe("When instantiated from existing", function() {
        beforeEach(function() {
          this.lsmp = new LinkerSmallMoleculeParent(JSON.parse(JSON.stringify(window.linkerSmallMoleculeTestJSON.linkerSmallMoleculeParent)));
          this.lsmpc = new LinkerSmallMoleculeParentController({
            model: this.lsmp,
            el: $('#fixture')
          });
          return this.lsmpc.render();
        });
        describe("render existing parameters", function() {
          it("should show the linker small molecule parent id", function() {
            return expect(this.lsmpc.$('.bv_parentCode').val()).toEqual("LSM000001");
          });
          it("should fill the linker small molecule parent name", function() {
            return expect(this.lsmpc.$('.bv_parentName').val()).toEqual("Ad");
          });
          it("should fill the scientist field", function() {
            waitsFor(function() {
              return this.lsmpc.$('.bv_scientist option').length > 0;
            }, 1000);
            return runs(function() {
              console.log(this.lsmpc.$('.bv_scientist').val());
              return expect(this.lsmpc.$('.bv_scientist').val()).toEqual("john");
            });
          });
          it("should fill the completion date field", function() {
            return expect(this.lsmpc.$('.bv_completionDate').val()).toEqual("2012-07-12");
          });
          it("should fill the notebook field", function() {
            return expect(this.lsmpc.$('.bv_notebook').val()).toEqual("Notebook 1");
          });
          return it("should fill the molecular weight field", function() {
            return expect(this.lsmpc.$('.bv_molecularWeight').val()).toEqual("231");
          });
        });
        describe("model updates", function() {
          it("should update model when parent name is changed", function() {
            this.lsmpc.$('.bv_parentName').val(" New name   ");
            this.lsmpc.$('.bv_parentName').keyup();
            return expect(this.lsmpc.model.get('linker small molecule name').get('labelText')).toEqual("New name");
          });
          it("should update model when the scientist is changed", function() {
            waitsFor(function() {
              return this.lsmpc.$('.bv_scientist option').length > 0;
            }, 1000);
            return runs(function() {
              this.lsmpc.$('.bv_scientist').val('unassigned');
              this.lsmpc.$('.bv_scientist').change();
              return expect(this.lsmpc.model.get('scientist').get('value')).toEqual("unassigned");
            });
          });
          it("should update model when completion date is changed", function() {
            this.lsmpc.$('.bv_completionDate').val(" 2013-3-16   ");
            this.lsmpc.$('.bv_completionDate').keyup();
            return expect(this.lsmpc.model.get('completion date').get('value')).toEqual(new Date(2013, 2, 16).getTime());
          });
          it("should update model when notebook is changed", function() {
            this.lsmpc.$('.bv_notebook').val(" Updated notebook  ");
            this.lsmpc.$('.bv_notebook').keyup();
            return expect(this.lsmpc.model.get('notebook').get('value')).toEqual("Updated notebook");
          });
          return it("should update model when molecular weight is changed", function() {
            this.lsmpc.$('.bv_molecularWeight').val(" 12  ");
            this.lsmpc.$('.bv_molecularWeight').keyup();
            return expect(this.lsmpc.model.get('molecular weight').get('value')).toEqual(12);
          });
        });
        return describe("controller validation rules", function() {
          beforeEach(function() {
            waitsFor(function() {
              return this.lsmpc.$('.bv_scientist option').length > 0;
            }, 1000);
            return runs(function() {
              this.lsmpc.$('.bv_parentName').val(" Updated entity name   ");
              this.lsmpc.$('.bv_parentName').keyup();
              this.lsmpc.$('.bv_scientist').val("bob");
              this.lsmpc.$('.bv_scientist').change();
              this.lsmpc.$('.bv_completionDate').val(" 2013-3-16   ");
              this.lsmpc.$('.bv_completionDate').keyup();
              this.lsmpc.$('.bv_notebook').val("my notebook");
              this.lsmpc.$('.bv_notebook').keyup();
              this.lsmpc.$('.bv_molecularWeight').val(" 24");
              return this.lsmpc.$('.bv_molecularWeight').keyup();
            });
          });
          describe("form validation setup", function() {
            it("should be valid if form fully filled out", function() {
              return runs(function() {
                return expect(this.lsmpc.isValid()).toBeTruthy();
              });
            });
            return it("should have the update button be enabled", function() {
              return runs(function() {
                return expect(this.lsmpc.$('.bv_updateParent').attr('disabled')).toBeUndefined();
              });
            });
          });
          describe("when name field not filled in", function() {
            beforeEach(function() {
              return runs(function() {
                this.lsmpc.$('.bv_parentName').val("");
                return this.lsmpc.$('.bv_parentName').keyup();
              });
            });
            it("should be invalid if name not filled in", function() {
              return runs(function() {
                return expect(this.lsmpc.isValid()).toBeFalsy();
              });
            });
            it("should show error in name field", function() {
              return runs(function() {
                return expect(this.lsmpc.$('.bv_group_parentName').hasClass('error')).toBeTruthy();
              });
            });
            return it("should have the update button be disabled", function() {
              return runs(function() {
                return expect(this.lsmpc.$('.bv_updateParent').attr('disabled')).toEqual('disabled');
              });
            });
          });
          describe("when scientist not selected", function() {
            beforeEach(function() {
              return runs(function() {
                this.lsmpc.$('.bv_scientist').val("");
                return this.lsmpc.$('.bv_scientist').change();
              });
            });
            return it("should show error on scientist dropdown", function() {
              return runs(function() {
                return expect(this.lsmpc.$('.bv_group_scientist').hasClass('error')).toBeTruthy();
              });
            });
          });
          describe("when date field not filled in", function() {
            beforeEach(function() {
              return runs(function() {
                this.lsmpc.$('.bv_completionDate').val("");
                return this.lsmpc.$('.bv_completionDate').keyup();
              });
            });
            return it("should show error in date field", function() {
              return runs(function() {
                return expect(this.lsmpc.$('.bv_group_completionDate').hasClass('error')).toBeTruthy();
              });
            });
          });
          describe("when notebook not filled", function() {
            beforeEach(function() {
              return runs(function() {
                this.lsmpc.$('.bv_notebook').val("");
                return this.lsmpc.$('.bv_notebook').keyup();
              });
            });
            return it("should show error on notebook field", function() {
              return runs(function() {
                return expect(this.lsmpc.$('.bv_group_notebook').hasClass('error')).toBeTruthy();
              });
            });
          });
          return describe("when molecular weight not filled", function() {
            beforeEach(function() {
              return runs(function() {
                this.lsmpc.$('.bv_molecularWeight').val("");
                return this.lsmpc.$('.bv_molecularWeight').keyup();
              });
            });
            return it("should show error on molecular weight field", function() {
              return runs(function() {
                return expect(this.lsmpc.$('.bv_group_molecularWeight').hasClass('error')).toBeTruthy();
              });
            });
          });
        });
      });
    });
    describe("Linker Small Molecule Batch Controller testing", function() {
      describe("When instantiated from new", function() {
        beforeEach(function() {
          this.lsmb = new LinkerSmallMoleculeBatch();
          this.lsmbc = new LinkerSmallMoleculeBatchController({
            model: this.lsmb,
            el: $('#fixture')
          });
          return this.lsmbc.render();
        });
        return describe("basic existence tests", function() {
          it("should exist", function() {
            return expect(this.lsmbc).toBeDefined();
          });
          return it("should load the template", function() {
            return expect(this.lsmbc.$('.bv_batchCode').html()).toEqual("Autofilled when saved");
          });
        });
      });
      return describe("When instantiated from existing", function() {
        beforeEach(function() {
          this.lsmb = new LinkerSmallMoleculeBatch(JSON.parse(JSON.stringify(window.linkerSmallMoleculeTestJSON.linkerSmallMoleculeBatch)));
          this.lsmbc = new LinkerSmallMoleculeBatchController({
            model: this.lsmb,
            el: $('#fixture')
          });
          return this.lsmbc.render();
        });
        describe("render existing parameters", function() {
          it("should show the linker small molecule batch id", function() {
            return expect(this.lsmbc.$('.bv_batchCode').val()).toEqual("LSM000001-1");
          });
          it("should fill the scientist field", function() {
            waitsFor(function() {
              return this.lsmbc.$('.bv_scientist option').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.lsmbc.$('.bv_scientist').val()).toEqual("john");
            });
          });
          it("should fill the completion date field", function() {
            return expect(this.lsmbc.$('.bv_completionDate').val()).toEqual("2012-07-12");
          });
          it("should fill the notebook field", function() {
            return expect(this.lsmbc.$('.bv_notebook').val()).toEqual("Notebook 1");
          });
          it("should fill the source field", function() {
            waitsFor(function() {
              return this.lsmbc.$('.bv_source option').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.lsmbc.$('.bv_source').val()).toEqual("Avidity");
            });
          });
          it("should fill the source id field", function() {
            return expect(this.lsmbc.$('.bv_sourceId').val()).toEqual("12345");
          });
          it("should fill the purity field", function() {
            return expect(this.lsmbc.$('.bv_purity').val()).toEqual("92");
          });
          it("should fill the amount made field", function() {
            return expect(this.lsmbc.$('.bv_amountMade').val()).toEqual("2.3");
          });
          return it("should fill the location field", function() {
            return expect(this.lsmbc.$('.bv_location').val()).toEqual("Cabinet 1");
          });
        });
        describe("model updates", function() {
          it("should update model when the scientist is changed", function() {
            waitsFor(function() {
              return this.lsmbc.$('.bv_scientist option').length > 0;
            }, 1000);
            return runs(function() {
              this.lsmbc.$('.bv_scientist').val('unassigned');
              this.lsmbc.$('.bv_scientist').change();
              return expect(this.lsmbc.model.get('scientist').get('value')).toEqual("unassigned");
            });
          });
          it("should update model when completion date is changed", function() {
            this.lsmbc.$('.bv_completionDate').val(" 2013-3-16   ");
            this.lsmbc.$('.bv_completionDate').keyup();
            return expect(this.lsmbc.model.get('completion date').get('value')).toEqual(new Date(2013, 2, 16).getTime());
          });
          it("should update model when notebook is changed", function() {
            this.lsmbc.$('.bv_notebook').val(" Updated notebook  ");
            this.lsmbc.$('.bv_notebook').keyup();
            return expect(this.lsmbc.model.get('notebook').get('value')).toEqual("Updated notebook");
          });
          it("should update model when the source is changed", function() {
            waitsFor(function() {
              return this.lsmbc.$('.bv_source option').length > 0;
            }, 1000);
            return runs(function() {
              this.lsmbc.$('.bv_source').val('unassigned');
              this.lsmbc.$('.bv_source').change();
              return expect(this.lsmbc.model.get('source').get('value')).toEqual("unassigned");
            });
          });
          it("should update model when source id is changed", function() {
            this.lsmbc.$('.bv_sourceId').val(" 252  ");
            this.lsmbc.$('.bv_sourceId').keyup();
            return expect(this.lsmbc.model.get('source id').get('value')).toEqual("252");
          });
          it("should update model when purity is changed", function() {
            this.lsmbc.$('.bv_purity').val(" 29  ");
            this.lsmbc.$('.bv_purity').keyup();
            return expect(this.lsmbc.model.get('purity').get('value')).toEqual(29);
          });
          it("should update model when amount made is changed", function() {
            this.lsmbc.$('.bv_amountMade').val(" 12  ");
            this.lsmbc.$('.bv_amountMade').keyup();
            return expect(this.lsmbc.model.get('amount made').get('value')).toEqual(12);
          });
          return it("should update model when location is changed", function() {
            this.lsmbc.$('.bv_location').val(" Updated location  ");
            this.lsmbc.$('.bv_location').keyup();
            return expect(this.lsmbc.model.get('location').get('value')).toEqual("Updated location");
          });
        });
        return describe("controller validation rules", function() {
          beforeEach(function() {
            waitsFor(function() {
              return this.lsmbc.$('.bv_scientist option').length > 0;
            }, 1000);
            return runs(function() {
              this.lsmbc.$('.bv_scientist').val("bob");
              this.lsmbc.$('.bv_scientist').change();
              this.lsmbc.$('.bv_completionDate').val(" 2013-3-16   ");
              this.lsmbc.$('.bv_completionDate').keyup();
              this.lsmbc.$('.bv_notebook').val("my notebook");
              this.lsmbc.$('.bv_notebook').keyup();
              this.lsmbc.$('.bv_source').val("vendor A");
              this.lsmbc.$('.bv_source').change();
              this.lsmbc.$('.bv_sourceId').val(" 24");
              this.lsmbc.$('.bv_sourceId').keyup();
              this.lsmbc.$('.bv_purity').val(" 82");
              this.lsmbc.$('.bv_purity').keyup();
              this.lsmbc.$('.bv_amountMade').val(" 24");
              this.lsmbc.$('.bv_amountMade').keyup();
              this.lsmbc.$('.bv_location').val(" Hood 4");
              return this.lsmbc.$('.bv_location').keyup();
            });
          });
          describe("form validation setup", function() {
            it("should be valid if form fully filled out", function() {
              return runs(function() {
                return expect(this.lsmbc.isValid()).toBeTruthy();
              });
            });
            return it("save button should be enabled", function() {
              return runs(function() {
                return expect(this.lsmbc.$('.bv_saveBatch').attr('disabled')).toBeUndefined();
              });
            });
          });
          describe("when scientist not selected", function() {
            beforeEach(function() {
              return runs(function() {
                this.lsmbc.$('.bv_scientist').val("");
                return this.lsmbc.$('.bv_scientist').change();
              });
            });
            it("should show error on scientist dropdown", function() {
              return runs(function() {
                return expect(this.lsmbc.$('.bv_group_scientist').hasClass('error')).toBeTruthy();
              });
            });
            return it("should have the update button be disabled", function() {
              return runs(function() {
                return expect(this.lsmbc.$('.bv_saveBatch').attr('disabled')).toEqual('disabled');
              });
            });
          });
          describe("when date field not filled in", function() {
            beforeEach(function() {
              return runs(function() {
                this.lsmbc.$('.bv_completionDate').val("");
                return this.lsmbc.$('.bv_completionDate').keyup();
              });
            });
            return it("should show error in date field", function() {
              return runs(function() {
                return expect(this.lsmbc.$('.bv_group_completionDate').hasClass('error')).toBeTruthy();
              });
            });
          });
          describe("when notebook not filled", function() {
            beforeEach(function() {
              return runs(function() {
                this.lsmbc.$('.bv_notebook').val("");
                return this.lsmbc.$('.bv_notebook').keyup();
              });
            });
            return it("should show error on notebook field", function() {
              return runs(function() {
                return expect(this.lsmbc.$('.bv_group_notebook').hasClass('error')).toBeTruthy();
              });
            });
          });
          describe("when source not selected", function() {
            beforeEach(function() {
              return runs(function() {
                this.lsmbc.$('.bv_source').val("");
                return this.lsmbc.$('.bv_source').change();
              });
            });
            it("should show error on source dropdown", function() {
              return runs(function() {
                return expect(this.lsmbc.$('.bv_group_source').hasClass('error')).toBeTruthy();
              });
            });
            return it("should have the update button be disabled", function() {
              return runs(function() {
                return expect(this.lsmbc.$('.bv_saveBatch').attr('disabled')).toEqual('disabled');
              });
            });
          });
          describe("when purity not filled", function() {
            beforeEach(function() {
              return runs(function() {
                this.lsmbc.$('.bv_purity').val("");
                return this.lsmbc.$('.bv_purity').keyup();
              });
            });
            return it("should show error on purity  field", function() {
              return runs(function() {
                return expect(this.lsmbc.$('.bv_group_purity').hasClass('error')).toBeTruthy();
              });
            });
          });
          describe("when amount made not filled", function() {
            beforeEach(function() {
              return runs(function() {
                this.lsmbc.$('.bv_amountMade').val("");
                return this.lsmbc.$('.bv_amountMade').keyup();
              });
            });
            return it("should show error on amount made field", function() {
              return runs(function() {
                return expect(this.lsmbc.$('.bv_group_amountMade').hasClass('error')).toBeTruthy();
              });
            });
          });
          return describe("when location not filled", function() {
            beforeEach(function() {
              return runs(function() {
                this.lsmbc.$('.bv_location').val("");
                return this.lsmbc.$('.bv_location').keyup();
              });
            });
            return it("should show error on location field", function() {
              return runs(function() {
                return expect(this.lsmbc.$('.bv_group_location').hasClass('error')).toBeTruthy();
              });
            });
          });
        });
      });
    });
    describe("Linker Small Molecule Batch Select Controller testing", function() {
      beforeEach(function() {
        this.lsmb = new LinkerSmallMoleculeBatch();
        this.lsmbsc = new LinkerSmallMoleculeBatchSelectController({
          model: this.lsmb,
          el: $('#fixture')
        });
        return this.lsmbsc.render();
      });
      describe("When instantiated", function() {
        describe("basic existence tests", function() {
          it("should exist", function() {
            return expect(this.lsmbsc).toBeDefined();
          });
          return it("should load the template", function() {
            return expect(this.lsmbsc.$('.bv_batchList').length).toEqual(1);
          });
        });
        return describe("rendering", function() {
          it("should have the batch list default to register new batch", function() {
            waitsFor(function() {
              return this.lsmbsc.$('.bv_batchList option').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.lsmbsc.$('.bv_batchList').val()).toEqual("new batch");
            });
          });
          return it("should a new batch registration form", function() {
            console.log(this.lsmbsc.$('.bv_batchCode'));
            waitsFor(function() {
              return this.lsmbsc.$('.bv_batchList option').length > 0;
            }, 1000);
            return runs(function() {
              expect(this.lsmbsc.$('.bv_batchCode').val()).toEqual("");
              return expect(this.lsmbsc.$('.bv_batchCode').html()).toEqual("Autofilled when saved");
            });
          });
        });
      });
      return describe("behavior", function() {
        return it("should show the information for a selected batch", function() {
          waitsFor(function() {
            return this.lsmbsc.$('.bv_batchList option').length > 0;
          }, 1000);
          runs(function() {
            console.log(this.lsmbsc.$('.bv_batchList'));
            this.lsmbsc.$('.bv_batchList').val("CB000001-1");
            return this.lsmbsc.$('.bv_batchList').change();
          });
          waitsFor(function() {
            return this.lsmbsc.$('.bv_scientist option').length > 0;
          }, 1000);
          runs(function() {
            return waits(1000);
          });
          return runs(function() {
            return expect(this.lsmbsc.$('.bv_batchCode').html()).toEqual("CB000001-1");
          });
        });
      });
    });
    return describe("Linker Small Molecule Controller", function() {
      beforeEach(function() {
        this.lsmc = new LinkerSmallMoleculeController({
          model: new LinkerSmallMoleculeParent(),
          el: $('#fixture')
        });
        return this.lsmc.render();
      });
      describe("Basic loading", function() {
        it("Class should exist", function() {
          return expect(this.lsmc).toBeDefined();
        });
        it("Should load the template", function() {
          return expect(this.lsmc.$('.bv_save').length).toEqual(1);
        });
        it("Should load a parent controller", function() {
          return expect(this.lsmc.$('.bv_parent .bv_parentCode').length).toEqual(1);
        });
        return it("Should load a batch controller", function() {
          waitsFor(function() {
            return this.lsmc.$('.bv_batchList option').length > 0;
          }, 1000);
          return runs(function() {
            return expect(this.lsmc.$('.bv_batch .bv_batchCode').length).toEqual(1);
          });
        });
      });
      return describe("saving parent/batch for the first time", function() {
        describe("when form is initialized", function() {
          return it("should have the save button be disabled initially", function() {
            return expect(this.lsmc.$('.bv_save').attr('disabled')).toEqual('disabled');
          });
        });
        return describe('when save is clicked', function() {
          beforeEach(function() {
            waitsFor(function() {
              return this.lsmc.$('.bv_fileType option').length > 0;
            }, 1000);
            runs(function() {
              this.lsmc.$('.bv_parentName').val(" Updated entity name   ");
              this.lsmc.$('.bv_parentName').keyup();
              this.lsmc.$('.bv_scientist').val("bob");
              this.lsmc.$('.bv_scientist').change();
              this.lsmc.$('.bv_completionDate').val(" 2013-3-16   ");
              this.lsmc.$('.bv_completionDate').keyup();
              this.lsmc.$('.bv_notebook').val("my notebook");
              this.lsmc.$('.bv_notebook').keyup();
              this.lsmc.$('.bv_source').val("Avidity");
              this.lsmc.$('.bv_source').change();
              this.lsmc.$('.bv_sourceId').val("12345");
              this.lsmc.$('.bv_sourceId').keyup();
              this.lsmc.$('.bv_molecularWeight').val(" 24");
              this.lsmc.$('.bv_molecularWeight').keyup();
              this.lsmc.$('.bv_purity').val(" 24");
              this.lsmc.$('.bv_purity').keyup();
              this.lsmc.$('.bv_amountMade').val(" 24");
              this.lsmc.$('.bv_amountMade').keyup();
              this.lsmc.$('.bv_location').val(" Hood 4");
              return this.lsmc.$('.bv_location').keyup();
            });
            return waitsFor(function() {
              return this.lsmc.$('.bv_fileType option').length > 0;
            }, 1000);
          });
          it("should have the save button be enabled", function() {
            return runs(function() {
              return expect(this.lsmc.$('.bv_save').attr('disabled')).toBeUndefined();
            });
          });
          it("should update the parent code", function() {
            runs(function() {
              return this.lsmc.$('.bv_save').click();
            });
            waits(1000);
            return runs(function() {
              return expect(this.lsmc.$('.bv_parentCode').html()).toEqual("LSM000001");
            });
          });
          it("should update the batch code", function() {
            runs(function() {
              return this.lsmc.$('.bv_save').click();
            });
            waits(1000);
            return runs(function() {
              return expect(this.lsmc.$('.bv_batchCode').html()).toEqual("LSM000001-1");
            });
          });
          it("should show the update parent button", function() {
            runs(function() {
              return this.lsmc.$('.bv_save').click();
            });
            waits(1000);
            return runs(function() {
              return expect(this.lsmc.$('.bv_updateParent')).toBeVisible();
            });
          });
          return it("should show the update batch button", function() {
            runs(function() {
              return this.lsmc.$('.bv_save').click();
            });
            waits(1000);
            return runs(function() {
              return expect(this.lsmc.$('.bv_saveBatch')).toBeVisible();
            });
          });
        });
      });
    });
  });

}).call(this);
