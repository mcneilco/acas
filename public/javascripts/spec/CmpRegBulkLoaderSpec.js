(function() {
  beforeEach(function() {
    return this.fixture = $.clone($("#fixture").get(0));
  });

  afterEach(function() {
    $("#fixture").remove();
    return $("body").append($(this.fixture));
  });

  describe("Compound Reg Bulk Loader module testing", function() {
    describe("Assigned Property model testing", function() {
      beforeEach(function() {
        return this.ap = new AssignedProperty();
      });
      return describe("Existence and Defaults", function() {
        it("should be defined", function() {
          return expect(this.ap).toBeDefined();
        });
        return it("should have defaults", function() {
          expect(this.ap.get('sdfProp')).toEqual("sdfProp");
          expect(this.ap.get('dbProp')).toEqual("unassigned");
          return expect(this.ap.get('defaultVal')).toEqual("");
        });
      });
    });
    describe("Assigned Properties List testing", function() {
      return describe("When loaded from new", function() {
        beforeEach(function() {
          return this.apl = new AssignedPropertiesList();
        });
        return describe("Existence", function() {
          return it("should be defined", function() {
            return expect(this.apl).toBeDefined();
          });
        });
      });
    });
    return describe("Assigned Property Controller testing", function() {
      return describe("when instantiated with no data", function() {
        beforeEach(function() {
          this.apc = new AssignedPropController({
            el: $('#fixture'),
            model: new AssignedProperty()
          });
          return this.apc.render();
        });
        describe("basic existence tests", function() {
          it("should exist", function() {
            return expect(this.apc).toBeDefined();
          });
          return it("should load a template", function() {
            return expect(this.apc.$('.bv_sdfProp').length).toEqual(1);
          });
        });
        return describe("rendering", function() {
          it("should show the sdf property", function() {
            return expect(this.apc.$('.bv_sdfProp').html()).toEqual("sdfProp");
          });
          it("should show the database property", function() {
            waitsFor(function() {
              return this.apc.$('.bv_dbProp option').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.apc.$('.bv_dbProp').val()).toEqual("unassigned");
            });
          });
          return it("should show the default value", function() {
            return expect(this.apc.$('.bv_defaultVal').val()).toEqual("");
          });
        });
      });
    });
  });

}).call(this);
