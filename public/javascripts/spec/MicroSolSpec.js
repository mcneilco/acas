(function() {
  describe('MicroSol Behavior Testing', function() {
    beforeEach(function() {
      return this.fixture = $.clone($('#fixture').get(0));
    });
    afterEach(function() {
      $('#fixture').remove();
      return $('body').append($(this.fixture));
    });
    describe('MicroSol Model', function() {
      describe('when instantiated', function() {
        beforeEach(function() {
          return this.microSol = new MicroSol();
        });
        return describe("defaults tests", function() {
          return it('should have defaults', function() {
            expect(this.microSol.get('protocolName')).toEqual("");
            expect(this.microSol.get('scientist')).toEqual("");
            expect(this.microSol.get('notebook')).toEqual("");
            return expect(this.microSol.get('project')).toEqual("");
          });
        });
      });
      return describe("validation tests", function() {
        beforeEach(function() {
          return this.microSol = new MicroSol(window.MicroSolTestJSON.validMicroSol);
        });
        it("should be valid as initialized", function() {
          return expect(this.microSol.isValid()).toBeTruthy();
        });
        it('should require that protocolName not be "unassigned"', function() {
          var filtErrors;
          this.microSol.set({
            protocolName: "Select Protocol"
          });
          expect(this.microSol.isValid()).toBeFalsy();
          filtErrors = _.filter(this.microSol.validationError, function(err) {
            return err.attribute === 'protocolName';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it('should require that scientist not be ""', function() {
          var filtErrors;
          this.microSol.set({
            scientist: ""
          });
          expect(this.microSol.isValid()).toBeFalsy();
          filtErrors = _.filter(this.microSol.validationError, function(err) {
            return err.attribute === 'scientist';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it('should require that notebook not be ""', function() {
          var filtErrors;
          this.microSol.set({
            notebook: ""
          });
          expect(this.microSol.isValid()).toBeFalsy();
          filtErrors = _.filter(this.microSol.validationError, function(err) {
            return err.attribute === 'notebook';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        return it('should require that project not be "unassigned"', function() {
          var filtErrors;
          this.microSol.set({
            project: "unassigned"
          });
          expect(this.microSol.isValid()).toBeFalsy();
          filtErrors = _.filter(this.microSol.validationError, function(err) {
            return err.attribute === 'project';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
      });
    });
    return describe('MicroSol Controller', function() {
      describe('when instantiated', function() {
        beforeEach(function() {
          this.fpkc = new MicroSolController({
            model: new MicroSol(),
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
              this.fpkc.$('.bv_protocolName').val("PROT-00000012");
              this.fpkc.$('.bv_protocolName').change();
              return expect(this.fpkc.model.get('protocolName')).toEqual("ADME uSol Kinetic Solubility");
            });
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
          this.fpkc = new MicroSolController({
            model: new MicroSol(window.MicroSolTestJSON.validMicroSol),
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
          return it('should show error if project is unassigned', function() {
            waitsFor(function() {
              return this.fpkc.$('.bv_project option').length > 0;
            }, 1000);
            return runs(function() {
              this.fpkc.$(".bv_project").val("unassigned");
              this.fpkc.$(".bv_project").change();
              return expect(this.fpkc.$(".bv_group_project").hasClass("error")).toBeTruthy();
            });
          });
        });
      });
    });
  });

}).call(this);
