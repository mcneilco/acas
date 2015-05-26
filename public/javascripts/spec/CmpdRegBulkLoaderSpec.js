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
    describe("Assigned Property Controller testing", function() {
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
    return describe("Assigned Prop List Controller testing", function() {
      return describe("when instantiated with no data", function() {
        beforeEach(function() {
          this.aplc = new AssignedPropListController({
            el: $('#fixture'),
            collection: new AssignedPropertiesList()
          });
          return this.aplc.render();
        });
        describe("basic existence tests", function() {
          it("should exist", function() {
            return expect(this.aplc).toBeDefined();
          });
          return it("should load a template", function() {
            return expect(this.aplc.$('.bv_addDbProp').length).toEqual(1);
          });
        });
        return describe("adding and removing", function() {
          it("should have one read when add db prop button is clicked", function() {
            this.aplc.$('.bv_addDbProp').click();
            expect(this.aplc.$('.bv_propInfo .bv_dbProp').length).toEqual(1);
            return expect(this.aplc.collection.length).toEqual(1);
          });
          return it("should have no reads when there is one read and remove is clicked", function() {
            this.aplc.$('.bv_addDbProp').click();
            expect(this.aplc.collection.length).toEqual(1);
            this.aplc.$('.bv_deleteProp').click();
            expect(this.aplc.$('.bv_propInfo .bv_dbProp').length).toEqual(0);
            return expect(this.aplc.collection.length).toEqual(0);
          });
        });
      });
    });
  });

}).call(this);
