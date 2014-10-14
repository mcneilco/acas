(function() {
  beforeEach(function() {
    return this.fixture = $("#fixture");
  });

  afterEach(function() {
    $("#fixture").remove();
    return $("body").append('<div id="fixture"></div>');
  });

  describe("Reagent Reg Module Testing", function() {
    describe("Reagent model testing", function() {
      describe("When loaded from new", function() {
        beforeEach(function() {
          return this.reagent = new Reagent();
        });
        return describe("Existence and Defaults", function() {
          it("should be defined", function() {
            return expect(this.reagent).toBeDefined();
          });
          return it("should have defaults", function() {
            expect(this.reagent.get('cas')).toBeNull();
            expect(this.reagent.get('barcode')).toBeNull();
            expect(this.reagent.get('vendor')).toBeNull();
            return expect(this.reagent.get('hazardCategory')).toBeNull();
          });
        });
      });
      return describe("When loaded from existing", function() {
        beforeEach(function() {
          return this.reagent = new Reagent(window.reagentRegTestJSON.savedReagent);
        });
        describe("Existence and Defaults", function() {
          it("should be defined", function() {
            return expect(this.reagent).toBeDefined();
          });
          return it("should have defaults", function() {
            expect(this.reagent.get('cas')).toEqual(123456);
            expect(this.reagent.get('barcode')).toEqual("RR123345");
            expect(this.reagent.get('vendor')).toEqual("vendor1");
            return expect(this.reagent.get('hazardCategory')).toEqual("flammable");
          });
        });
        return describe("model validation tests", function() {
          it("should be valid as initialized", function() {
            return expect(this.reagent.isValid()).toBeTruthy();
          });
          return it("should be invalid when positive control batch is empty", function() {
            var filtErrors;
            this.reagent.set({
              barcode: ""
            });
            expect(this.reagent.isValid()).toBeFalsy();
            filtErrors = _.filter(this.reagent.validationError, function(err) {
              return err.attribute === 'barcode';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
        });
      });
    });
    return describe("Reagent Controller", function() {
      describe('when instantiated with new reagent', function() {
        beforeEach(function() {
          this.rc = new ReagentController({
            model: new Reagent(),
            el: $('#fixture')
          });
          return this.rc.render();
        });
        describe("basic existance tests", function() {
          it('should exist', function() {
            return expect(this.rc).toBeDefined();
          });
          return it('should load a template', function() {
            return expect(this.rc.$('.bv_barcode').length).toEqual(1);
          });
        });
        return describe("basic rendering", function() {
          return it("should show a populated hazard category select", function() {
            waitsFor(function() {
              return this.rc.$('.bv_hazardCategory option').length > 0;
            }, 200);
            return runs(function() {
              return expect(this.rc.$('.bv_hazardCategory option:eq(0)').val()).toEqual("unassigned");
            });
          });
        });
      });
      return describe('when instantiated with existing reagent', function() {
        beforeEach(function() {
          this.rc = new ReagentController({
            model: new Reagent(window.reagentRegTestJSON.savedReagent),
            el: $('#fixture')
          });
          return this.rc.render();
        });
        describe("should show current values", function() {
          it('should fill the cas field', function() {
            return expect(this.rc.$('.bv_cas').val()).toEqual('123456');
          });
          return it('should fill the barcode field', function() {
            return expect(this.rc.$('.bv_barcode').val()).toEqual("RR123345");
          });
        });
        describe("should update model", function() {
          it("should update cas when changed", function() {
            this.rc.$('.bv_cas').val(2222);
            this.rc.$('.bv_cas').change();
            return expect(this.rc.model.get('cas')).toEqual(2222);
          });
          it("should update cas when changed", function() {
            this.rc.$('.bv_barcode').val("newBarcode");
            this.rc.$('.bv_barcode').change();
            return expect(this.rc.model.get('barcode')).toEqual("newBarcode");
          });
          return it("should show the correct hazard category", function() {
            waitsFor(function() {
              return this.rc.$('.bv_hazardCategory option').length > 0;
            }, 200);
            return runs(function() {
              return expect(this.rc.$('.bv_hazardCategory').val()).toEqual("flammable");
            });
          });
        });
        return describe("validation testing", function() {
          return it("should show an error if barcode not filled", function() {
            this.rc.$('.bv_barcode').val("");
            this.rc.$('.bv_barcode').change();
            return expect(this.rc.$('.bv_group_barcode').hasClass("error")).toBeTruthy();
          });
        });
      });
    });
  });

}).call(this);
