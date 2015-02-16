(function() {
  beforeEach(function() {
    return this.fixture = $.clone($("#fixture").get(0));
  });

  afterEach(function() {
    $("#fixture").remove();
    return $("body").append($(this.fixture));
  });

  describe('Protein testing', function() {
    describe("Protein Parent model testing", function() {
      describe("when loaded from new", function() {
        beforeEach(function() {
          return this.pp = new ProteinParent();
        });
        describe("Existence and Defaults", function() {
          it("should be defined", function() {
            return expect(this.pp).toBeDefined();
          });
          it("should have a type", function() {
            return expect(this.pp.get('lsType')).toEqual("parent");
          });
          it("should have a kind", function() {
            return expect(this.pp.get('lsKind')).toEqual("protein");
          });
          it("should have the recordedBy set to the logged in user", function() {
            return expect(this.pp.get('recordedBy')).toEqual(window.AppLaunchParams.loginUser.username);
          });
          it("should have a recordedDate set to now", function() {
            return expect(new Date(this.pp.get('recordedDate')).getHours()).toEqual(new Date().getHours());
          });
          it("Should have a lsLabels with one label", function() {
            expect(this.pp.get('lsLabels')).toBeDefined();
            expect(this.pp.get("lsLabels").length).toEqual(1);
            return expect(this.pp.get("lsLabels").getLabelByTypeAndKind("name", "protein").length).toEqual(1);
          });
          it("Should have a model attribute for the label in defaultLabels", function() {
            return expect(this.pp.get("protein name")).toBeDefined();
          });
          it("Should have a lsStates with the states in defaultStates", function() {
            expect(this.pp.get('lsStates')).toBeDefined();
            expect(this.pp.get("lsStates").length).toEqual(1);
            return expect(this.pp.get("lsStates").getStatesByTypeAndKind("metadata", "protein parent").length).toEqual(1);
          });
          return describe("model attributes for each value in defaultValues", function() {
            it("Should have a model attribute for scientist", function() {
              return expect(this.pp.get("scientist")).toBeDefined();
            });
            it("Should have a model attribute for completion date", function() {
              return expect(this.pp.get("completion date")).toBeDefined();
            });
            it("Should have a model attribute for notebook", function() {
              return expect(this.pp.get("notebook")).toBeDefined();
            });
            it("Should have a model attribute for molecular weight", function() {
              return expect(this.pp.get("molecular weight")).toBeDefined();
            });
            it("Should have a model attribute for type", function() {
              return expect(this.pp.get("type")).toBeDefined();
            });
            return it("Should have a model attribute for aa sequence", function() {
              return expect(this.pp.get("aa sequence")).toBeDefined();
            });
          });
        });
        return describe("model validation", function() {
          it("should be invalid when name is empty", function() {
            var filtErrors;
            this.pp.get("protein name").set("labelText", "");
            expect(this.pp.isValid()).toBeFalsy();
            filtErrors = _.filter(this.pp.validationError, function(err) {
              return err.attribute === 'parentName';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
          it("should be invalid when molecular weight is not filled", function() {
            var filtErrors;
            this.pp.get("molecular weight").set("value", "");
            expect(this.pp.isValid()).toBeFalsy();
            filtErrors = _.filter(this.pp.validationError, function(err) {
              return err.attribute === 'molecularWeight';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
          return it("should be invalid when type is not selected", function() {
            var filtErrors;
            this.pp.get("type").set("value", "");
            expect(this.pp.isValid()).toBeFalsy();
            filtErrors = _.filter(this.pp.validationError, function(err) {
              return err.attribute === 'type';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
        });
      });
      return describe("When created from existing", function() {
        beforeEach(function() {
          return this.pp = new ProteinParent(JSON.parse(JSON.stringify(window.proteinTestJSON.proteinParent)));
        });
        describe("after initial load", function() {
          it("should be defined", function() {
            return expect(this.pp).toBeDefined();
          });
          it("should have a type", function() {
            return expect(this.pp.get('lsType')).toEqual("parent");
          });
          it("should have a kind", function() {
            return expect(this.pp.get('lsKind')).toEqual("protein");
          });
          it("should have a recordedBy set", function() {
            return expect(this.pp.get('recordedBy')).toEqual("jane");
          });
          it("should have a recordedDate set", function() {
            return expect(this.pp.get('recordedDate')).toEqual(1375141508000);
          });
          it("Should have label set", function() {
            var label;
            console.log(this.pp);
            expect(this.pp.get("protein name").get("labelText")).toEqual("EGFR 31");
            label = this.pp.get("lsLabels").getLabelByTypeAndKind("name", "protein");
            console.log(label[0]);
            return expect(label[0].get('labelText')).toEqual("EGFR 31");
          });
          it("Should have a lsStates with the states in defaultStates", function() {
            expect(this.pp.get('lsStates')).toBeDefined();
            expect(this.pp.get("lsStates").length).toEqual(1);
            return expect(this.pp.get("lsStates").getStatesByTypeAndKind("metadata", "protein parent").length).toEqual(1);
          });
          it("Should have a scientist value", function() {
            return expect(this.pp.get("scientist").get("value")).toEqual("john");
          });
          it("Should have a completion date value", function() {
            return expect(this.pp.get("completion date").get("value")).toEqual(1342080000000);
          });
          it("Should have a notebook value", function() {
            return expect(this.pp.get("notebook").get("value")).toEqual("Notebook 1");
          });
          it("Should have a molecular weight value", function() {
            return expect(this.pp.get("molecular weight").get("value")).toEqual(231);
          });
          it("Should have a type value", function() {
            return expect(this.pp.get("type").get("value")).toEqual("fab");
          });
          return it("Should have a sequence value", function() {
            return expect(this.pp.get("aa sequence").get("value")).toEqual("AUGCGACUG");
          });
        });
        return describe("model validation", function() {
          beforeEach(function() {
            return this.pp = new ProteinParent(window.proteinTestJSON.proteinParent);
          });
          it("should be valid when loaded from saved", function() {
            return expect(this.pp.isValid()).toBeTruthy();
          });
          it("should be invalid when name is empty", function() {
            var filtErrors;
            this.pp.get("protein name").set("labelText", "");
            expect(this.pp.isValid()).toBeFalsy();
            filtErrors = _.filter(this.pp.validationError, function(err) {
              return err.attribute === 'parentName';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
          it("should be invalid when scientist not selected", function() {
            var filtErrors;
            this.pp.get('scientist').set('value', "unassigned");
            expect(this.pp.isValid()).toBeFalsy();
            filtErrors = _.filter(this.pp.validationError, function(err) {
              return err.attribute === 'scientist';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
          it("should be invalid when completion date is empty", function() {
            var filtErrors;
            this.pp.get("completion date").set("value", new Date("").getTime());
            expect(this.pp.isValid()).toBeFalsy();
            filtErrors = _.filter(this.pp.validationError, function(err) {
              return err.attribute === 'completionDate';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
          it("should be invalid when notebook is empty", function() {
            var filtErrors;
            this.pp.get("notebook").set("value", "");
            expect(this.pp.isValid()).toBeFalsy();
            filtErrors = _.filter(this.pp.validationError, function(err) {
              return err.attribute === 'notebook';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
          it("should be invalid when molecular weight is empty", function() {
            var filtErrors;
            this.pp.get("molecular weight").set("value", "");
            expect(this.pp.isValid()).toBeFalsy();
            filtErrors = _.filter(this.pp.validationError, function(err) {
              return err.attribute === 'molecularWeight';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
          return it("should be invalid when type is not selected", function() {
            var filtErrors;
            this.pp.get("type").set("value", "");
            expect(this.pp.isValid()).toBeFalsy();
            filtErrors = _.filter(this.pp.validationError, function(err) {
              return err.attribute === 'type';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
        });
      });
    });
    describe("Protein Batch model testing", function() {
      describe("when loaded from new", function() {
        beforeEach(function() {
          return this.pb = new ProteinBatch();
        });
        return describe("Existence and Defaults", function() {
          it("should be defined", function() {
            return expect(this.pb).toBeDefined();
          });
          it("should have a type", function() {
            return expect(this.pb.get('lsType')).toEqual("batch");
          });
          it("should have a kind", function() {
            return expect(this.pb.get('lsKind')).toEqual("protein");
          });
          it("should have a recordedBy set to logged in user", function() {
            return expect(this.pb.get('recordedBy')).toEqual(window.AppLaunchParams.loginUser.username);
          });
          it("should have a recordedDate set to now", function() {
            return expect(new Date(this.pb.get('recordedDate')).getHours()).toEqual(new Date().getHours());
          });
          return describe("model attributes for each value in defaultValues", function() {
            it("Should have a model attribute for scientist", function() {
              return expect(this.pb.get("scientist")).toBeDefined();
            });
            it("Should have a model attribute for completion date", function() {
              return expect(this.pb.get("completion date")).toBeDefined();
            });
            it("Should have a model attribute for notebook", function() {
              return expect(this.pb.get("notebook")).toBeDefined();
            });
            it("Should have a model attribute for source", function() {
              expect(this.pb.get("source").get).toBeDefined();
              return expect(this.pb.get("source").get('value')).toEqual("Avidity");
            });
            it("Should have a model attribute for source id", function() {
              return expect(this.pb.get("source id")).toBeDefined();
            });
            it("Should have a model attribute for purity", function() {
              return expect(this.pb.get("purity")).toBeDefined();
            });
            it("Should have a model attribute for amount made", function() {
              return expect(this.pb.get("amount made")).toBeDefined();
            });
            return it("Should have a model attribute for location", function() {
              return expect(this.pb.get("location")).toBeDefined();
            });
          });
        });
      });
      describe("When created from existing", function() {
        beforeEach(function() {
          return this.pb = new ProteinBatch(JSON.parse(JSON.stringify(window.proteinTestJSON.proteinBatch)));
        });
        return describe("after initial load", function() {
          it("should be defined", function() {
            return expect(this.pb).toBeDefined();
          });
          it("should have a type", function() {
            return expect(this.pb.get('lsType')).toEqual("batch");
          });
          it("should have a kind", function() {
            return expect(this.pb.get('lsKind')).toEqual("protein");
          });
          it("Should have a scientist value", function() {
            return expect(this.pb.get("scientist").get("value")).toEqual("john");
          });
          it("should have a recordedDate set", function() {
            return expect(this.pb.get('recordedDate')).toEqual(1375141508000);
          });
          it("Should have a lsStates with the states in defaultStates", function() {
            expect(this.pb.get('lsStates')).toBeDefined();
            expect(this.pb.get("lsStates").length).toEqual(2);
            expect(this.pb.get("lsStates").getStatesByTypeAndKind("metadata", "protein batch").length).toEqual(1);
            return expect(this.pb.get("lsStates").getStatesByTypeAndKind("metadata", "inventory").length).toEqual(1);
          });
          it("Should have a completion date value", function() {
            return expect(this.pb.get("completion date").get("value")).toEqual(1342080000000);
          });
          it("Should have a notebook value", function() {
            return expect(this.pb.get("notebook").get("value")).toEqual("Notebook 1");
          });
          it("Should have a source value", function() {
            return expect(this.pb.get("source").get("value")).toEqual("Avidity");
          });
          it("Should have a source id", function() {
            return expect(this.pb.get("source id").get("value")).toEqual("12345");
          });
          it("Should have a purity value", function() {
            return expect(this.pb.get("purity").get("value")).toEqual(92);
          });
          it("Should have an amount made value", function() {
            return expect(this.pb.get("amount made").get("value")).toEqual(2.3);
          });
          return it("Should have a location value", function() {
            return expect(this.pb.get("location").get("value")).toEqual("Cabinet 1");
          });
        });
      });
      return describe("model validation", function() {
        beforeEach(function() {
          return this.pb = new ProteinBatch(window.proteinTestJSON.proteinBatch);
        });
        it("should be valid when loaded from saved", function() {
          return expect(this.pb.isValid()).toBeTruthy();
        });
        it("should be invalid when scientist not selected", function() {
          var filtErrors;
          this.pb.get('scientist').set('value', "unassigned");
          expect(this.pb.isValid()).toBeFalsy();
          return filtErrors = _.filter(this.pb.validationError, function(err) {
            return err.attribute === 'scientist';
          });
        });
        it("should be invalid when completion date is empty", function() {
          var filtErrors;
          this.pb.get("completion date").set("value", new Date("").getTime());
          expect(this.pb.isValid()).toBeFalsy();
          filtErrors = _.filter(this.pb.validationError, function(err) {
            return err.attribute === 'completionDate';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it("should be invalid when notebook is empty", function() {
          var filtErrors;
          this.pb.get("notebook").set("value", "");
          expect(this.pb.isValid()).toBeFalsy();
          filtErrors = _.filter(this.pb.validationError, function(err) {
            return err.attribute === 'notebook';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it("should be invalid when source is not selected", function() {
          var filtErrors;
          this.pb.get("source").set("value", "unassigned");
          expect(this.pb.isValid()).toBeFalsy();
          return filtErrors = _.filter(this.pb.validationError, function(err) {
            return err.attribute === 'source';
          });
        });
        it("should be invalid when purity is NaN", function() {
          var filtErrors;
          this.pb.get("purity").set("value", "fred");
          expect(this.pb.isValid()).toBeFalsy();
          filtErrors = _.filter(this.pb.validationError, function(err) {
            return err.attribute === 'purity';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it("should be invalid when amount made is NaN", function() {
          var filtErrors;
          this.pb.get("amount made").set("value", "fred");
          expect(this.pb.isValid()).toBeFalsy();
          filtErrors = _.filter(this.pb.validationError, function(err) {
            return err.attribute === 'amountMade';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        return it("should be invalid when location is empty", function() {
          var filtErrors;
          this.pb.get("location").set("value", "");
          expect(this.pb.isValid()).toBeFalsy();
          filtErrors = _.filter(this.pb.validationError, function(err) {
            return err.attribute === 'location';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
      });
    });
    describe("Protein Parent Controller testing", function() {
      describe("When instantiated from new", function() {
        beforeEach(function() {
          this.pp = new ProteinParent();
          this.ppc = new ProteinParentController({
            model: this.pp,
            el: $('#fixture')
          });
          return this.ppc.render();
        });
        return describe("basic existence tests", function() {
          it("should exist", function() {
            return expect(this.ppc).toBeDefined();
          });
          it("should load the template", function() {
            return expect(this.ppc.$('.bv_parentCode').html()).toEqual("Autofilled when saved");
          });
          return it("should load the additional parent attributes template", function() {
            return expect(this.ppc.$('.bv_type').length).toEqual(1);
          });
        });
      });
      return describe("When instantiated from existing", function() {
        beforeEach(function() {
          this.pp = new ProteinParent(JSON.parse(JSON.stringify(window.proteinTestJSON.proteinParent)));
          this.ppc = new ProteinParentController({
            model: this.pp,
            el: $('#fixture')
          });
          return this.ppc.render();
        });
        describe("render existing parameters", function() {
          it("should show the protein parent id", function() {
            return expect(this.ppc.$('.bv_parentCode').val()).toEqual("PROT000001");
          });
          it("should fill the protein parent name", function() {
            return expect(this.ppc.$('.bv_parentName').val()).toEqual("EGFR 31");
          });
          it("should fill the scientist field", function() {
            waitsFor(function() {
              return this.ppc.$('.bv_scientist option').length > 0;
            }, 1000);
            return runs(function() {
              console.log(this.ppc.$('.bv_scientist').val());
              return expect(this.ppc.$('.bv_scientist').val()).toEqual("john");
            });
          });
          it("should fill the completion date field", function() {
            return expect(this.ppc.$('.bv_completionDate').val()).toEqual("2012-07-12");
          });
          it("should fill the notebook field", function() {
            return expect(this.ppc.$('.bv_notebook').val()).toEqual("Notebook 1");
          });
          it("should fill the type field", function() {
            waitsFor(function() {
              return this.ppc.$('.bv_type option').length > 0;
            }, 1000);
            return runs(function() {
              console.log(this.ppc.$('.bv_type').val());
              console.log(this.ppc.model);
              return expect(this.ppc.$('.bv_type').val()).toEqual("fab");
            });
          });
          return it("should fill the aa sequence field", function() {
            return expect(this.ppc.$('.bv_sequence').val()).toEqual("AUGCGACUG");
          });
        });
        describe("model updates", function() {
          it("should update model when parent name is changed", function() {
            this.ppc.$('.bv_parentName').val(" New name   ");
            this.ppc.$('.bv_parentName').keyup();
            return expect(this.ppc.model.get('protein name').get('labelText')).toEqual("New name");
          });
          it("should update model when the scientist is changed", function() {
            waitsFor(function() {
              return this.ppc.$('.bv_scientist option').length > 0;
            }, 1000);
            return runs(function() {
              this.ppc.$('.bv_scientist').val('unassigned');
              this.ppc.$('.bv_scientist').change();
              return expect(this.ppc.model.get('scientist').get('value')).toEqual("unassigned");
            });
          });
          it("should update model when completion date is changed", function() {
            this.ppc.$('.bv_completionDate').val(" 2013-3-16   ");
            this.ppc.$('.bv_completionDate').keyup();
            return expect(this.ppc.model.get('completion date').get('value')).toEqual(new Date(2013, 2, 16).getTime());
          });
          it("should update model when notebook is changed", function() {
            this.ppc.$('.bv_notebook').val(" Updated notebook  ");
            this.ppc.$('.bv_notebook').keyup();
            return expect(this.ppc.model.get('notebook').get('value')).toEqual("Updated notebook");
          });
          it("should update model when the type is changed", function() {
            waitsFor(function() {
              return this.ppc.$('.bv_type option').length > 0;
            }, 1000);
            return runs(function() {
              this.ppc.$('.bv_type').val('unassigned');
              this.ppc.$('.bv_type').change();
              return expect(this.ppc.model.get('type').get('value')).toEqual("unassigned");
            });
          });
          return it("should update model when aa sequence is changed", function() {
            this.ppc.$('.bv_sequence').val(" Updated sequence  ");
            this.ppc.$('.bv_sequence').keyup();
            return expect(this.ppc.model.get('aa sequence').get('value')).toEqual("Updated sequence");
          });
        });
        return describe("controller validation rules", function() {
          beforeEach(function() {
            waitsFor(function() {
              return this.ppc.$('.bv_scientist option').length > 0;
            }, 1000);
            return runs(function() {
              this.ppc.$('.bv_parentName').val(" Updated entity name   ");
              this.ppc.$('.bv_parentName').keyup();
              this.ppc.$('.bv_scientist').val("bob");
              this.ppc.$('.bv_scientist').change();
              this.ppc.$('.bv_completionDate').val(" 2013-3-16   ");
              this.ppc.$('.bv_completionDate').keyup();
              this.ppc.$('.bv_notebook').val("my notebook");
              this.ppc.$('.bv_notebook').keyup();
              this.ppc.$('.bv_type').val("mab");
              this.ppc.$('.bv_type').change();
              this.ppc.$('.bv_sequence').val("AUG");
              return this.ppc.$('.bv_sequence').keyup();
            });
          });
          describe("form validation setup", function() {
            it("should be valid if form fully filled out", function() {
              return runs(function() {
                return expect(this.ppc.isValid()).toBeTruthy();
              });
            });
            return it("should have the update button be enabled", function() {
              return runs(function() {
                return expect(this.ppc.$('.bv_updateParent').attr('disabled')).toBeUndefined();
              });
            });
          });
          describe("when name field not filled in", function() {
            beforeEach(function() {
              return runs(function() {
                this.ppc.$('.bv_parentName').val("");
                return this.ppc.$('.bv_parentName').keyup();
              });
            });
            it("should be invalid if name not filled in", function() {
              return runs(function() {
                return expect(this.ppc.isValid()).toBeFalsy();
              });
            });
            it("should show error in name field", function() {
              return runs(function() {
                return expect(this.ppc.$('.bv_group_parentName').hasClass('error')).toBeTruthy();
              });
            });
            return it("should have the update button be disabled", function() {
              return runs(function() {
                return expect(this.ppc.$('.bv_updateParent').attr('disabled')).toEqual('disabled');
              });
            });
          });
          describe("when scientist not selected", function() {
            beforeEach(function() {
              return runs(function() {
                this.ppc.$('.bv_scientist').val("");
                return this.ppc.$('.bv_scientist').change();
              });
            });
            return it("should show error on scientist dropdown", function() {
              return runs(function() {
                return expect(this.ppc.$('.bv_group_scientist').hasClass('error')).toBeTruthy();
              });
            });
          });
          describe("when date field not filled in", function() {
            beforeEach(function() {
              return runs(function() {
                this.ppc.$('.bv_completionDate').val("");
                return this.ppc.$('.bv_completionDate').keyup();
              });
            });
            return it("should show error in date field", function() {
              return runs(function() {
                return expect(this.ppc.$('.bv_group_completionDate').hasClass('error')).toBeTruthy();
              });
            });
          });
          describe("when notebook not filled", function() {
            beforeEach(function() {
              return runs(function() {
                this.ppc.$('.bv_notebook').val("");
                return this.ppc.$('.bv_notebook').keyup();
              });
            });
            return it("should show error on notebook field", function() {
              return runs(function() {
                return expect(this.ppc.$('.bv_group_notebook').hasClass('error')).toBeTruthy();
              });
            });
          });
          return describe("when type not filled", function() {
            beforeEach(function() {
              waitsFor(function() {
                return this.ppc.$('.bv_scientist option').length > 0;
              }, 1000);
              return runs(function() {
                this.ppc.$('.bv_type').val("unassigned");
                return this.ppc.$('.bv_type').change();
              });
            });
            return it("should show error on type field", function() {
              return runs(function() {
                return expect(this.ppc.$('.bv_group_type').hasClass('error')).toBeTruthy();
              });
            });
          });
        });
      });
    });
    describe("Protein Batch Controller testing", function() {
      describe("When instantiated from new", function() {
        beforeEach(function() {
          this.pb = new ProteinBatch();
          this.pbc = new ProteinBatchController({
            model: this.pb,
            el: $('#fixture')
          });
          return this.pbc.render();
        });
        return describe("basic existence tests", function() {
          it("should exist", function() {
            return expect(this.pbc).toBeDefined();
          });
          return it("should load the template", function() {
            return expect(this.pbc.$('.bv_batchCode').html()).toEqual("Autofilled when saved");
          });
        });
      });
      return describe("When instantiated from existing", function() {
        beforeEach(function() {
          this.pb = new ProteinBatch(JSON.parse(JSON.stringify(window.proteinTestJSON.proteinBatch)));
          this.pbc = new ProteinBatchController({
            model: this.pb,
            el: $('#fixture')
          });
          return this.pbc.render();
        });
        describe("render existing parameters", function() {
          it("should show the protein batch id", function() {
            return expect(this.pbc.$('.bv_batchCode').val()).toEqual("PROT000001-1");
          });
          it("should fill the scientist field", function() {
            waitsFor(function() {
              return this.pbc.$('.bv_scientist option').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.pbc.$('.bv_scientist').val()).toEqual("john");
            });
          });
          it("should fill the completion date field", function() {
            return expect(this.pbc.$('.bv_completionDate').val()).toEqual("2012-07-12");
          });
          it("should fill the notebook field", function() {
            return expect(this.pbc.$('.bv_notebook').val()).toEqual("Notebook 1");
          });
          it("should fill the source field", function() {
            waitsFor(function() {
              return this.pbc.$('.bv_source option').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.pbc.$('.bv_source').val()).toEqual("Avidity");
            });
          });
          it("should fill the source id field", function() {
            return expect(this.pbc.$('.bv_sourceId').val()).toEqual("12345");
          });
          it("should fill the purity field", function() {
            return expect(this.pbc.$('.bv_purity').val()).toEqual("92");
          });
          it("should fill the amount made field", function() {
            return expect(this.pbc.$('.bv_amountMade').val()).toEqual("2.3");
          });
          return it("should fill the location field", function() {
            return expect(this.pbc.$('.bv_location').val()).toEqual("Cabinet 1");
          });
        });
        describe("model updates", function() {
          it("should update model when the scientist is changed", function() {
            waitsFor(function() {
              return this.pbc.$('.bv_scientist option').length > 0;
            }, 1000);
            return runs(function() {
              this.pbc.$('.bv_scientist').val('unassigned');
              this.pbc.$('.bv_scientist').change();
              return expect(this.pbc.model.get('scientist').get('value')).toEqual("unassigned");
            });
          });
          it("should update model when completion date is changed", function() {
            this.pbc.$('.bv_completionDate').val(" 2013-3-16   ");
            this.pbc.$('.bv_completionDate').keyup();
            return expect(this.pbc.model.get('completion date').get('value')).toEqual(new Date(2013, 2, 16).getTime());
          });
          it("should update model when notebook is changed", function() {
            this.pbc.$('.bv_notebook').val(" Updated notebook  ");
            this.pbc.$('.bv_notebook').keyup();
            return expect(this.pbc.model.get('notebook').get('value')).toEqual("Updated notebook");
          });
          it("should update model when the source is changed", function() {
            waitsFor(function() {
              return this.pbc.$('.bv_source option').length > 0;
            }, 1000);
            return runs(function() {
              this.pbc.$('.bv_source').val('unassigned');
              this.pbc.$('.bv_source').change();
              return expect(this.pbc.model.get('source').get('value')).toEqual("unassigned");
            });
          });
          it("should update model when source id is changed", function() {
            this.pbc.$('.bv_sourceId').val(" 252  ");
            this.pbc.$('.bv_sourceId').keyup();
            return expect(this.pbc.model.get('source id').get('value')).toEqual("252");
          });
          it("should update model when purity is changed", function() {
            this.pbc.$('.bv_purity').val(" 29  ");
            this.pbc.$('.bv_purity').keyup();
            return expect(this.pbc.model.get('purity').get('value')).toEqual(29);
          });
          it("should update model when amount made is changed", function() {
            this.pbc.$('.bv_amountMade').val(" 12  ");
            this.pbc.$('.bv_amountMade').keyup();
            return expect(this.pbc.model.get('amount made').get('value')).toEqual(12);
          });
          return it("should update model when location is changed", function() {
            this.pbc.$('.bv_location').val(" Updated location  ");
            this.pbc.$('.bv_location').keyup();
            return expect(this.pbc.model.get('location').get('value')).toEqual("Updated location");
          });
        });
        return describe("controller validation rules", function() {
          beforeEach(function() {
            waitsFor(function() {
              return this.pbc.$('.bv_scientist option').length > 0;
            }, 1000);
            return runs(function() {
              this.pbc.$('.bv_scientist').val("bob");
              this.pbc.$('.bv_scientist').change();
              this.pbc.$('.bv_completionDate').val(" 2013-3-16   ");
              this.pbc.$('.bv_completionDate').keyup();
              this.pbc.$('.bv_notebook').val("my notebook");
              this.pbc.$('.bv_notebook').keyup();
              this.pbc.$('.bv_source').val("vendor A");
              this.pbc.$('.bv_source').change();
              this.pbc.$('.bv_sourceId').val(" 24");
              this.pbc.$('.bv_sourceId').keyup();
              this.pbc.$('.bv_purity').val(" 82");
              this.pbc.$('.bv_purity').keyup();
              this.pbc.$('.bv_amountMade').val(" 24");
              this.pbc.$('.bv_amountMade').keyup();
              this.pbc.$('.bv_location').val(" Hood 4");
              return this.pbc.$('.bv_location').keyup();
            });
          });
          describe("form validation setup", function() {
            it("should be valid if form fully filled out", function() {
              return runs(function() {
                return expect(this.pbc.isValid()).toBeTruthy();
              });
            });
            return it("save button should be enabled", function() {
              return runs(function() {
                return expect(this.pbc.$('.bv_saveBatch').attr('disabled')).toBeUndefined();
              });
            });
          });
          describe("when scientist not selected", function() {
            beforeEach(function() {
              return runs(function() {
                this.pbc.$('.bv_scientist').val("");
                return this.pbc.$('.bv_scientist').change();
              });
            });
            it("should show error on scientist dropdown", function() {
              return runs(function() {
                return expect(this.pbc.$('.bv_group_scientist').hasClass('error')).toBeTruthy();
              });
            });
            return it("should have the update button be disabled", function() {
              return runs(function() {
                return expect(this.pbc.$('.bv_saveBatch').attr('disabled')).toEqual('disabled');
              });
            });
          });
          describe("when date field not filled in", function() {
            beforeEach(function() {
              return runs(function() {
                this.pbc.$('.bv_completionDate').val("");
                return this.pbc.$('.bv_completionDate').keyup();
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
                return this.pbc.$('.bv_notebook').keyup();
              });
            });
            return it("should show error on notebook field", function() {
              return runs(function() {
                return expect(this.pbc.$('.bv_group_notebook').hasClass('error')).toBeTruthy();
              });
            });
          });
          describe("when source not selected", function() {
            beforeEach(function() {
              return runs(function() {
                this.pbc.$('.bv_source').val("");
                return this.pbc.$('.bv_source').change();
              });
            });
            it("should show error on source dropdown", function() {
              return runs(function() {
                return expect(this.pbc.$('.bv_group_source').hasClass('error')).toBeTruthy();
              });
            });
            return it("should have the update button be disabled", function() {
              return runs(function() {
                return expect(this.pbc.$('.bv_saveBatch').attr('disabled')).toEqual('disabled');
              });
            });
          });
          describe("when purity not filled", function() {
            beforeEach(function() {
              return runs(function() {
                this.pbc.$('.bv_purity').val("");
                return this.pbc.$('.bv_purity').keyup();
              });
            });
            return it("should show error on purity  field", function() {
              return runs(function() {
                return expect(this.pbc.$('.bv_group_purity').hasClass('error')).toBeTruthy();
              });
            });
          });
          describe("when amount made not filled", function() {
            beforeEach(function() {
              return runs(function() {
                this.pbc.$('.bv_amountMade').val("");
                return this.pbc.$('.bv_amountMade').keyup();
              });
            });
            return it("should show error on amount made field", function() {
              return runs(function() {
                return expect(this.pbc.$('.bv_group_amountMade').hasClass('error')).toBeTruthy();
              });
            });
          });
          return describe("when location not filled", function() {
            beforeEach(function() {
              return runs(function() {
                this.pbc.$('.bv_location').val("");
                return this.pbc.$('.bv_location').keyup();
              });
            });
            return it("should show error on location field", function() {
              return runs(function() {
                return expect(this.pbc.$('.bv_group_location').hasClass('error')).toBeTruthy();
              });
            });
          });
        });
      });
    });
    describe("Protein Batch Select Controller testing", function() {
      beforeEach(function() {
        this.pb = new ProteinBatch();
        this.pbsc = new ProteinBatchSelectController({
          model: this.pb,
          el: $('#fixture')
        });
        return this.pbsc.render();
      });
      describe("When instantiated", function() {
        describe("basic existence tests", function() {
          it("should exist", function() {
            return expect(this.pbsc).toBeDefined();
          });
          return it("should load the template", function() {
            return expect(this.pbsc.$('.bv_batchList').length).toEqual(1);
          });
        });
        return describe("rendering", function() {
          it("should have the batch list default to register new batch", function() {
            waitsFor(function() {
              return this.pbsc.$('.bv_batchList option').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.pbsc.$('.bv_batchList').val()).toEqual("new batch");
            });
          });
          return it("should a new batch registration form", function() {
            console.log(this.pbsc.$('.bv_batchCode'));
            waitsFor(function() {
              return this.pbsc.$('.bv_batchList option').length > 0;
            }, 1000);
            return runs(function() {
              expect(this.pbsc.$('.bv_batchCode').val()).toEqual("");
              return expect(this.pbsc.$('.bv_batchCode').html()).toEqual("Autofilled when saved");
            });
          });
        });
      });
      return describe("behavior", function() {
        return it("should show the information for a selected batch", function() {
          waitsFor(function() {
            return this.pbsc.$('.bv_batchList option').length > 0;
          }, 1000);
          runs(function() {
            console.log(this.pbsc.$('.bv_batchList'));
            this.pbsc.$('.bv_batchList').val("CB000001-1");
            return this.pbsc.$('.bv_batchList').change();
          });
          waitsFor(function() {
            return this.pbsc.$('.bv_scientist option').length > 0;
          }, 1000);
          runs(function() {
            return waits(1000);
          });
          return runs(function() {
            return expect(this.pbsc.$('.bv_batchCode').html()).toEqual("CB000001-1");
          });
        });
      });
    });
    return describe("Protein Controller", function() {
      beforeEach(function() {
        this.pc = new ProteinController({
          model: new ProteinParent(),
          el: $('#fixture')
        });
        return this.pc.render();
      });
      describe("Basic loading", function() {
        it("Class should exist", function() {
          return expect(this.pc).toBeDefined();
        });
        it("Should load the template", function() {
          return expect(this.pc.$('.bv_save').length).toEqual(1);
        });
        it("Should load a parent controller", function() {
          return expect(this.pc.$('.bv_parent .bv_parentCode').length).toEqual(1);
        });
        return it("Should load a batch controller", function() {
          waitsFor(function() {
            return this.pc.$('.bv_batchList option').length > 0;
          }, 1000);
          return runs(function() {
            return expect(this.pc.$('.bv_batch .bv_batchCode').length).toEqual(1);
          });
        });
      });
      return describe("saving parent/batch for the first time", function() {
        describe("when form is initialized", function() {
          return it("should have the save button be disabled initially", function() {
            return expect(this.pc.$('.bv_save').attr('disabled')).toEqual('disabled');
          });
        });
        return describe('when save is clicked', function() {
          beforeEach(function() {
            waitsFor(function() {
              return this.pc.$('.bv_fileType option').length > 0;
            }, 1000);
            runs(function() {
              this.pc.$('.bv_parentName').val(" Updated entity name   ");
              this.pc.$('.bv_parentName').keyup();
              this.pc.$('.bv_scientist').val("bob");
              this.pc.$('.bv_scientist').change();
              this.pc.$('.bv_completionDate').val(" 2013-3-16   ");
              this.pc.$('.bv_completionDate').keyup();
              this.pc.$('.bv_notebook').val("my notebook");
              this.pc.$('.bv_notebook').keyup();
              this.pc.$('.bv_molecularWeight').val("192");
              this.pc.$('.bv_molecularWeight').keyup();
              this.pc.$('.bv_type').val("mab");
              this.pc.$('.bv_type').change();
              this.pc.$('.bv_sequence').val(" AUC");
              this.pc.$('.bv_sequence').keyup();
              this.pc.$('.bv_source').val("Avidity");
              this.pc.$('.bv_source').change();
              this.pc.$('.bv_sourceId').val("12345");
              this.pc.$('.bv_sourceId').keyup();
              this.pc.$('.bv_purity').val(" 24");
              this.pc.$('.bv_purity').keyup();
              this.pc.$('.bv_amountMade').val(" 24");
              this.pc.$('.bv_amountMade').keyup();
              this.pc.$('.bv_location').val(" Hood 4");
              return this.pc.$('.bv_location').keyup();
            });
            return waitsFor(function() {
              return this.pc.$('.bv_fileType option').length > 0;
            }, 1000);
          });
          return it("should have the save button be enabled", function() {
            return runs(function() {
              console.log(this.pc.model.validationError);
              console.log("here in test");
              return expect(this.pc.$('.bv_save').attr('disabled')).toBeUndefined();
            });
          });
        });
      });
    });
  });

}).call(this);
