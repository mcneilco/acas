(function() {
  beforeEach(function() {
    return this.fixture = $.clone($("#fixture").get(0));
  });

  afterEach(function() {
    $("#fixture").remove();
    return $("body").append($(this.fixture));
  });

  describe('Cationic Block testing', function() {
    describe("Cationic Block Parent model testing", function() {
      describe("when loaded from new", function() {
        beforeEach(function() {
          return this.cbp = new CationicBlockParent();
        });
        return describe("Existence and Defaults", function() {
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
      });
      describe("When created from existing", function() {
        beforeEach(function() {
          return this.cbp = new CationicBlockParent(JSON.parse(JSON.stringify(window.cationicBlockTestJSON.cationicBlockParent)));
        });
        return describe("after initial load", function() {
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
            return expect(this.cbp.get('recordedBy')).toEqual("egao");
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
            return expect(this.cbp.get("completion date").get("value")).toEqual("1342080000000");
          });
          it("Should have a notebook value", function() {
            return expect(this.cbp.get("notebook").get("value")).toEqual("Notebook 1");
          });
          return it("Should have a molecular weight value", function() {
            return expect(this.cbp.get("molecular weight").get("value")).toEqual(231);
          });
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
            return err.attribute === 'cationicBlockName';
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
          return filtErrors = _.filter(this.cbp.validationError, function(err) {
            return err.attribute === 'recordedBy';
          });
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
    return describe("Cationic Block Parent Controller testing", function() {
      return describe("When instantiated", function() {
        beforeEach(function() {
          this.cbp = new CationicBlockParent(JSON.parse(JSON.stringify(window.cationicBlockTestJSON.cationicBlockParent)));
          this.cbpc = new CationicBlockParentController({
            model: this.cbp,
            el: $('#fixture')
          });
          return this.cbpc.render();
        });
        describe("basic existence tests", function() {
          it("should exist", function() {
            return expect(this.cbpc).toBeDefined();
          });
          return it("should load the template", function() {
            return expect(this.cbpc.$('.bv_cationicBlockParentCode').html()).toEqual("autofill when saved");
          });
        });
        return describe("render existing parameters", function() {
          it("should show the cationic block parent id", function() {
            return expect(this.cbpc.$('.bv_cationicBlockParentCode').val()).toEqual("CB000001");
          });
          it("should show the cationic block parent name", function() {
            return expect(this.cbpc.$('.bv_cationicBlockParentName').val()).toEqual("cMAP10");
          });
          it("should fill the scientist field", function() {
            return expect(this.cbpc.$('.bv_recordedBy').val()).toEqual("egao");
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
      });
    });
  });

}).call(this);
