(function() {
  describe('Full PK Behavior Testing', function() {
    beforeEach(function() {
      return this.fixture = $.clone($('#fixture').get(0));
    });
    afterEach(function() {
      $('#fixture').remove();
      return $('body').append($(this.fixture));
    });
    describe('FullPK Model', function() {
      describe('when instantiated', function() {
        beforeEach(function() {
          return this.fullPK = new FullPK();
        });
        return describe("defaults tests", function() {
          return it('should have defaults', function() {
            expect(this.fullPK.get('format')).toEqual("In Vivo Full PK");
            expect(this.fullPK.get('protocolName')).toEqual("");
            expect(this.fullPK.get('experimentName')).toEqual("");
            expect(this.fullPK.get('scientist')).toEqual("");
            expect(this.fullPK.get('notebook')).toEqual("");
            expect(this.fullPK.get('inLifeNotebook')).toEqual("");
            expect(this.fullPK.get('assayDate')).toEqual(null);
            expect(this.fullPK.get('project')).toEqual("");
            expect(this.fullPK.get('bioavailability')).toEqual("");
            return expect(this.fullPK.get('aucType')).toEqual("");
          });
        });
      });
      return describe("validation tests", function() {
        beforeEach(function() {
          return this.fullPK = new FullPK(window.FullPKTestJSON.validFullPK);
        });
        it("should be valid as initialized", function() {
          return expect(this.fullPK.isValid()).toBeTruthy();
        });
        it('should require that protocolName not be "unassigned"', function() {
          var filtErrors;
          this.fullPK.set({
            protocolName: "Select Protocol"
          });
          expect(this.fullPK.isValid()).toBeFalsy();
          filtErrors = _.filter(this.fullPK.validationError, function(err) {
            return err.attribute === 'protocolName';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it('should require that experimentName not be ""', function() {
          var filtErrors;
          this.fullPK.set({
            experimentName: ""
          });
          expect(this.fullPK.isValid()).toBeFalsy();
          filtErrors = _.filter(this.fullPK.validationError, function(err) {
            return err.attribute === 'experimentName';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it('should require that scientist not be ""', function() {
          var filtErrors;
          this.fullPK.set({
            scientist: ""
          });
          expect(this.fullPK.isValid()).toBeFalsy();
          filtErrors = _.filter(this.fullPK.validationError, function(err) {
            return err.attribute === 'scientist';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it('should require that notebook not be ""', function() {
          var filtErrors;
          this.fullPK.set({
            notebook: ""
          });
          expect(this.fullPK.isValid()).toBeFalsy();
          filtErrors = _.filter(this.fullPK.validationError, function(err) {
            return err.attribute === 'notebook';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it('should require that inLifeNotebook not be ""', function() {
          var filtErrors;
          this.fullPK.set({
            inLifeNotebook: ""
          });
          expect(this.fullPK.isValid()).toBeFalsy();
          filtErrors = _.filter(this.fullPK.validationError, function(err) {
            return err.attribute === 'inLifeNotebook';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it('should require that project not be "unassigned"', function() {
          var filtErrors;
          this.fullPK.set({
            project: "unassigned"
          });
          expect(this.fullPK.isValid()).toBeFalsy();
          filtErrors = _.filter(this.fullPK.validationError, function(err) {
            return err.attribute === 'project';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it('should require that bioavailability not be ""', function() {
          var filtErrors;
          this.fullPK.set({
            bioavailability: ""
          });
          expect(this.fullPK.isValid()).toBeFalsy();
          filtErrors = _.filter(this.fullPK.validationError, function(err) {
            return err.attribute === 'bioavailability';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it('should require that aucType not be ""', function() {
          var filtErrors;
          this.fullPK.set({
            aucType: ""
          });
          expect(this.fullPK.isValid()).toBeFalsy();
          filtErrors = _.filter(this.fullPK.validationError, function(err) {
            return err.attribute === 'aucType';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        return it('should require that assayDate not be ""', function() {
          var filtErrors;
          this.fullPK.set({
            assayDate: new Date("").getTime()
          });
          expect(this.fullPK.isValid()).toBeFalsy();
          filtErrors = _.filter(this.fullPK.validationError, function(err) {
            return err.attribute === 'assayDate';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
      });
    });
    return describe('FullPK Controller', function() {
      describe('when instantiated', function() {
        beforeEach(function() {
          this.fpkc = new FullPKController({
            model: new FullPK(),
            el: $('#fixture')
          });
          return this.fpkc.render();
        });
        describe("basic existance tests", function() {
          it('should exist', function() {
            return expect(this.fpkc).toBeDefined();
          });
          return it('should load a template', function() {
            return expect(this.fpkc.$('.bv_protocolName').length).toEqual(1);
          });
        });
        describe("it should show a picklist for projects", function() {
          beforeEach(function() {
            waitsFor(function() {
              return this.fpkc.$('.bv_project option').length > 0;
            }, 1000);
            return runs(function() {});
          });
          it("should show project options after loading them from server", function() {
            return expect(this.fpkc.$('.bv_project option').length).toBeGreaterThan(0);
          });
          return it("should default to unassigned", function() {
            return expect(this.fpkc.$('.bv_project').val()).toEqual("unassigned");
          });
        });
        describe("it should show a picklist for protocols", function() {
          beforeEach(function() {
            waitsFor(function() {
              return this.fpkc.$('.bv_protocolName option').length > 0;
            }, 1000);
            return runs(function() {});
          });
          it("should show protocol options after loading them from server", function() {
            return expect(this.fpkc.$('.bv_protocolName option').length).toBeGreaterThan(0);
          });
          return it("should default to unassigned", function() {
            return expect(this.fpkc.$('.bv_protocolName').val()).toEqual("unassigned");
          });
        });
        describe("disable and enable", function() {
          it("should disable all inputs on request", function() {
            this.fpkc.disableAllInputs();
            expect(this.fpkc.$('.bv_scientist').attr("disabled")).toEqual("disabled");
            expect(this.fpkc.$('.bv_project').attr("disabled")).toEqual("disabled");
            return expect(this.fpkc.$('.bv_protocolName').attr("disabled")).toEqual("disabled");
          });
          return it("should enable all inputs on request", function() {
            this.fpkc.disableAllInputs();
            expect(this.fpkc.$('.bv_scientist').attr("disabled")).toEqual("disabled");
            expect(this.fpkc.$('.bv_project').attr("disabled")).toEqual("disabled");
            expect(this.fpkc.$('.bv_protocolName').attr("disabled")).toEqual("disabled");
            this.fpkc.enableAllInputs();
            expect(this.fpkc.$('.bv_scientist').attr("disabled")).toBeUndefined();
            expect(this.fpkc.$('.bv_project').attr("disabled")).toBeUndefined();
            return expect(this.fpkc.$('.bv_protocolName').attr("disabled")).toBeUndefined();
          });
        });
        return describe('update model when fields changed', function() {
          it("should update the protocolName", function() {
            waitsFor(function() {
              return this.fpkc.$('.bv_protocolName option').length > 0;
            }, 1000);
            return runs(function() {
              this.fpkc.$('.bv_protocolName').val("PROT-00000009");
              this.fpkc.$('.bv_protocolName').change();
              return expect(this.fpkc.model.get('protocolName')).toEqual("Dog IVPO PK");
            });
          });
          it("should update the experimentName", function() {
            this.fpkc.$('.bv_experimentName').val(" test experiment ");
            this.fpkc.$('.bv_experimentName').change();
            return expect(this.fpkc.model.get('experimentName')).toEqual("test experiment");
          });
          it("should update the scientist", function() {
            this.fpkc.$('.bv_scientist').val(" test scientist ");
            this.fpkc.$('.bv_scientist').change();
            return expect(this.fpkc.model.get('scientist')).toEqual("test scientist");
          });
          it("should update the notebook", function() {
            this.fpkc.$('.bv_notebook').val(" test notebook ");
            this.fpkc.$('.bv_notebook').change();
            return expect(this.fpkc.model.get('notebook')).toEqual("test notebook");
          });
          it("should update the inLifeNotebook", function() {
            this.fpkc.$('.bv_inLifeNotebook').val(" test inLifeNotebook ");
            this.fpkc.$('.bv_inLifeNotebook').change();
            return expect(this.fpkc.model.get('inLifeNotebook')).toEqual("test inLifeNotebook");
          });
          it("should update the project", function() {
            waitsFor(function() {
              return this.fpkc.$('.bv_project option').length > 0;
            }, 1000);
            return runs(function() {
              this.fpkc.$('.bv_project').val("project2");
              this.fpkc.$('.bv_project').change();
              return expect(this.fpkc.model.get('project')).toEqual("project2");
            });
          });
          it("should update the bioavailability", function() {
            this.fpkc.$('.bv_bioavailability').val(" test bioavailability ");
            this.fpkc.$('.bv_bioavailability').change();
            return expect(this.fpkc.model.get('bioavailability')).toEqual("test bioavailability");
          });
          it("should update the aucType", function() {
            this.fpkc.$('.bv_aucType').val(" test aucType ");
            this.fpkc.$('.bv_aucType').change();
            return expect(this.fpkc.model.get('aucType')).toEqual("test aucType");
          });
          it("should update the assayDate", function() {
            this.fpkc.$('.bv_assayDate').val(" 2013-6-6 ");
            this.fpkc.$('.bv_assayDate').change();
            return expect(this.fpkc.model.get('assayDate')).toEqual(new Date(2013, 5, 6).getTime());
          });
          return it("should trigger 'amDirty' when field changed", function() {
            var _this = this;
            runs(function() {
              var _this = this;
              this.amDirtySet = false;
              this.fpkc.on('amDirty', function() {
                return _this.amDirtySet = true;
              });
              this.fpkc.$('.bv_notebook').val(" test notebook ");
              return this.fpkc.$('.bv_notebook').change();
            });
            waitsFor(function() {
              return _this.amDirtySet;
            }, 500);
            return runs(function() {
              return expect(this.amDirtySet).toBeTruthy();
            });
          });
        });
      });
      return describe("validation testing", function() {
        beforeEach(function() {
          this.fpkc = new FullPKController({
            model: new FullPK(window.FullPKTestJSON.validFullPK),
            el: $('#fixture')
          });
          return this.fpkc.render();
        });
        return describe("error notification", function() {
          it('should show error if protocol is unassigned', function() {
            waitsFor(function() {
              return this.fpkc.$('.bv_protocolName option').length > 0;
            }, 1000);
            return runs(function() {
              this.fpkc.$(".bv_protocolName").val("unassigned");
              this.fpkc.$(".bv_protocolName").change();
              console.log(this.fpkc.$(".bv_protocolName").val());
              return expect(this.fpkc.$(".bv_group_protocolName").hasClass("error")).toBeTruthy();
            });
          });
          it('should show error if experimentName is empty', function() {
            this.fpkc.$(".bv_experimentName").val("");
            this.fpkc.$(".bv_experimentName").change();
            return expect(this.fpkc.$(".bv_group_experimentName").hasClass("error")).toBeTruthy();
          });
          it('should show error if scientist is empty', function() {
            this.fpkc.$(".bv_scientist").val("");
            this.fpkc.$(".bv_scientist").change();
            return expect(this.fpkc.$(".bv_group_scientist").hasClass("error")).toBeTruthy();
          });
          it('should show error if notebook is empty', function() {
            this.fpkc.$(".bv_notebook").val("");
            this.fpkc.$(".bv_notebook").change();
            return expect(this.fpkc.$(".bv_group_notebook").hasClass("error")).toBeTruthy();
          });
          it('should show error if inLifeNotebook is empty', function() {
            this.fpkc.$(".bv_inLifeNotebook").val("");
            this.fpkc.$(".bv_inLifeNotebook").change();
            return expect(this.fpkc.$(".bv_group_inLifeNotebook").hasClass("error")).toBeTruthy();
          });
          it('should show error if project is unassigned', function() {
            waitsFor(function() {
              return this.fpkc.$('.bv_project option').length > 0;
            }, 1000);
            return runs(function() {
              this.fpkc.$(".bv_project").val("unassigned");
              this.fpkc.$(".bv_project").change();
              return expect(this.fpkc.$(".bv_group_project").hasClass("error")).toBeTruthy();
            });
          });
          it('should show error if bioavailability is empty', function() {
            this.fpkc.$(".bv_bioavailability").val("");
            this.fpkc.$(".bv_bioavailability").change();
            return expect(this.fpkc.$(".bv_group_bioavailability").hasClass("error")).toBeTruthy();
          });
          it('should show error if aucType is empty', function() {
            this.fpkc.$(".bv_aucType").val("");
            this.fpkc.$(".bv_aucType").change();
            return expect(this.fpkc.$(".bv_group_aucType").hasClass("error")).toBeTruthy();
          });
          return it('should show error if assayDate is empty', function() {
            this.fpkc.$(".bv_assayDate").val("");
            this.fpkc.$(".bv_assayDate").change();
            return expect(this.fpkc.$(".bv_group_assayDate").hasClass("error")).toBeTruthy();
          });
        });
      });
    });
  });

}).call(this);
