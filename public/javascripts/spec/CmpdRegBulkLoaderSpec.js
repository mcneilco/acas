(function() {
  beforeEach(function() {
    return this.fixture = $.clone($("#fixture").get(0));
  });

  afterEach(function() {
    $("#fixture").remove();
    return $("body").append($(this.fixture));
  });

  describe("Compound Reg Bulk Loader module testing", function() {
    describe("SDF Property model testing", function() {
      beforeEach(function() {
        return this.sp = new SdfProperty();
      });
      return describe("Existence", function() {
        return it("should be defined", function() {
          return expect(this.sp).toBeDefined();
        });
      });
    });
    describe("SDF Properties List testing", function() {
      beforeEach(function() {
        return this.spl = new SdfPropertiesList();
      });
      return describe("Existence", function() {
        return it("should be defined", function() {
          return expect(this.spl).toBeDefined();
        });
      });
    });
    describe("DB Property model testing", function() {
      beforeEach(function() {
        return this.dp = new DbProperty();
      });
      return describe("Existence", function() {
        return it("should be defined", function() {
          return expect(this.dp).toBeDefined();
        });
      });
    });
    describe("Db Properties List testing", function() {
      beforeEach(function() {
        return this.dpl = new DbPropertiesList();
      });
      return describe("Existence", function() {
        return it("should be defined", function() {
          return expect(this.dpl).toBeDefined();
        });
      });
    });
    describe("Assigned Property model testing", function() {
      beforeEach(function() {
        return this.ap = new AssignedProperty();
      });
      return describe("Existence and Defaults", function() {
        it("should be defined", function() {
          return expect(this.ap).toBeDefined();
        });
        return it("should have defaults", function() {
          console.log("getting defaults");
          expect(this.ap.get('sdfProperty')).toEqual(null);
          expect(this.ap.get('dbProperty')).toEqual("unassigned");
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
          this.apc = new AssignedPropertyController({
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
            return expect(this.apc.$('.bv_sdfProperty').length).toEqual(1);
          });
        });
        return describe("rendering", function() {
          it("should show the sdf property", function() {
            return expect(this.apc.$('.bv_sdfProperty').html()).toEqual("sdfProperty");
          });
          it("should show the database property", function() {
            waitsFor(function() {
              return this.apc.$('.bv_dbProperty option').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.apc.$('.bv_dbProperty').val()).toEqual("unassigned");
            });
          });
          return it("should show the default value", function() {
            return expect(this.apc.$('.bv_defaultVal').val()).toEqual("");
          });
        });
      });
    });
    describe("Assigned Properties List Controller testing", function() {
      return describe("when instantiated with no data", function() {
        beforeEach(function() {
          this.aplc = new AssignedPropertiesListController({
            el: $('#fixture'),
            collection: new AssignedPropertiesList()
          });
          this.aplc.render();
          return this.aplc.$('.bv_addDbProperty').removeAttr('disabled');
        });
        describe("basic existence tests", function() {
          it("should exist", function() {
            return expect(this.aplc).toBeDefined();
          });
          return it("should load a template", function() {
            return expect(this.aplc.$('.bv_addDbProperty').length).toEqual(1);
          });
        });
        return describe("adding and removing", function() {
          it("should have one read when add db prop button is clicked", function() {
            this.aplc.$('.bv_addDbProperty').click();
            expect(this.aplc.$('.bv_propInfo .bv_dbProperty').length).toEqual(1);
            return expect(this.aplc.collection.length).toEqual(1);
          });
          return it("should have no reads when there is one read and remove is clicked", function() {
            this.aplc.$('.bv_addDbProperty').click();
            expect(this.aplc.collection.length).toEqual(1);
            this.aplc.$('.bv_deleteProperty').click();
            expect(this.aplc.$('.bv_propInfo .bv_dbProperty').length).toEqual(0);
            return expect(this.aplc.collection.length).toEqual(0);
          });
        });
      });
    });
    return describe("Cmpd Reg Bulk Loader App Controller testing", function() {
      beforeEach(function() {
        this.crblap = new CmpdRegBulkLoaderAppController();
        return this.crblap.render();
      });
      describe("basic loading", function() {
        it("should exist", function() {
          return expect(this.crblap).toBeDefined();
        });
        it("Should load the template", function() {
          return expect(this.crblap.$('.bv_headerName').length).toEqual(1);
        });
        return it("Should load a browseFileController", function() {
          return expect(this.crblap.browseFileController).toBeDefined();
        });
      });
      return describe("display logic", function() {
        return it("should start off with all buttons except the browse files button disabled", function() {
          expect(this.crblap.$('.bv_readMore').attr('disabled')).toEqual("disabled");
          expect(this.crblap.$('.bv_readAll').attr('disabled')).toEqual("disabled");
          expect(this.crblap.$('.bv_addDbProperty').attr('disabled')).toEqual("disabled");
          return expect(this.crblap.$('.bv_regCmpds').attr('disabled')).toEqual("disabled");
        });
      });
    });
  });

}).call(this);
