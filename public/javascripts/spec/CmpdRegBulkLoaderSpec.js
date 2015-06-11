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
      describe("when loaded from new", function() {
        beforeEach(function() {
          return this.spl = new SdfPropertiesList();
        });
        return describe("Existence", function() {
          return it("should be defined", function() {
            return expect(this.spl).toBeDefined();
          });
        });
      });
      return describe("when loaded from passed in attributes", function() {
        beforeEach(function() {
          return this.spl = new SdfPropertiesList(window.cmpdRegBulkLoaderServiceTestJSON.propertiesList['sdfProperties']);
        });
        return describe("Existence", function() {
          it("should be defined", function() {
            return expect(this.spl).toBeDefined();
          });
          it("should have 5 properties", function() {
            return expect(this.spl.length).toEqual(5);
          });
          return it("should have the correct values for each attribute in the models", function() {
            var prop1;
            prop1 = this.spl.at(0);
            return expect(prop1.get('name')).toEqual("prop1");
          });
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
      describe("when loaded from new", function() {
        beforeEach(function() {
          return this.dpl = new DbPropertiesList();
        });
        return describe("Existence", function() {
          return it("should be defined", function() {
            return expect(this.dpl).toBeDefined();
          });
        });
      });
      return describe("when loaded from passed in attributes", function() {
        beforeEach(function() {
          return this.dpl = new DbPropertiesList(window.cmpdRegBulkLoaderServiceTestJSON.propertiesList['dbProperties']);
        });
        describe("Existence", function() {
          return it("should be defined", function() {
            return expect(this.dpl).toBeDefined();
          });
        });
        return describe("features", function() {
          it("should return a filtered array of required properties", function() {
            return expect(this.dpl.getRequired().length).toEqual(4);
          });
          it("should have 5 properties", function() {
            return expect(this.dpl.length).toEqual(5);
          });
          return it("should have the correct values for each attribute in the models", function() {
            var prop1;
            prop1 = this.dpl.at(0);
            return expect(prop1.get('name')).toEqual("db1");
          });
        });
      });
    });
    describe("Assigned Property model testing", function() {
      describe("When loaded from new", function() {
        beforeEach(function() {
          return this.ap = new AssignedProperty();
        });
        return describe("Existence and Defaults", function() {
          it("should be defined", function() {
            return expect(this.ap).toBeDefined();
          });
          it("should have a default sdfProperty", function() {
            return expect(this.ap.get('sdfProperty')).toEqual(null);
          });
          it("should have a default dbProperty", function() {
            return expect(this.ap.get('dbProperty')).toEqual("none");
          });
          it("should have a default defaultVal", function() {
            return expect(this.ap.get('defaultVal')).toEqual("");
          });
          return it("should have a default required value", function() {
            return expect(this.ap.get('required')).toBeFalsy();
          });
        });
      });
      return describe("model validation tests", function() {
        beforeEach(function() {
          return this.ap = new AssignedProperty(window.cmpdRegBulkLoaderServiceTestJSON.propertiesList['bulkloadProperties'][0]);
        });
        return it("should be invalid when the dbProperty is required (and not corporate id) and the default value is empty", function() {
          var filtErrors;
          this.ap.set({
            required: true,
            dbProperty: "test",
            defaultVal: ""
          });
          expect(this.ap.isValid()).toBeFalsy();
          filtErrors = _.filter(this.ap.validationError, function(err) {
            return err.attribute === 'defaultVal';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
      });
    });
    describe("Assigned Properties List testing", function() {
      describe("When loaded from new", function() {
        beforeEach(function() {
          return this.apl = new AssignedPropertiesList();
        });
        return describe("Existence", function() {
          return it("should be defined", function() {
            return expect(this.apl).toBeDefined();
          });
        });
      });
      return describe("when loaded from passed in attributes", function() {
        beforeEach(function() {
          return this.apl = new AssignedPropertiesList(window.cmpdRegBulkLoaderServiceTestJSON.propertiesList['bulkloadProperties']);
        });
        describe("Existence", function() {
          it("should be defined", function() {
            return expect(this.apl).toBeDefined();
          });
          it("should have 2 properties", function() {
            return expect(this.apl.length).toEqual(2);
          });
          return it("should have the correct values for each attribute in the models", function() {
            var prop1;
            prop1 = this.apl.at(0);
            expect(prop1.get('dbProperty')).toEqual("db1");
            expect(prop1.get('sdfProperty')).toEqual("prop1");
            return expect(prop1.get('required')).toEqual(true);
          });
        });
        return describe("features", function() {
          return it("should return an array of models with the same dbProperty", function() {
            var filtErrors;
            this.apl.at(0).set({
              'dbProperty': "db2"
            });
            expect(this.apl.checkDuplicates().length).toEqual(2);
            filtErrors = _.filter(this.apl.checkDuplicates(), function(err) {
              return err.attribute === 'dbProperty:eq(0)';
            });
            expect(filtErrors.length).toEqual(1);
            filtErrors = _.filter(this.apl.checkDuplicates(), function(err) {
              return err.attribute === 'dbProperty:eq(1)';
            });
            return expect(filtErrors.length).toEqual(1);
          });
        });
      });
    });
    describe("DetectSdfPropertiesController testing", function() {
      return describe("when instantiated with no data", function() {
        beforeEach(function() {
          this.dspc = new DetectSdfPropertiesController({
            el: $('#fixture')
          });
          return this.dspc.render();
        });
        describe("basic existence and set up tests", function() {
          it("should exist", function() {
            return expect(this.dspc).toBeDefined();
          });
          it("should load a template", function() {
            return expect(this.dspc.$('.bv_detectedSdfPropertiesList').length).toEqual(1);
          });
          it("should have numRecords set to 100", function() {
            return expect(this.dspc.numRecords).toEqual(100);
          });
          it("should have use template set to none", function() {
            return expect(this.dspc.temp).toEqual("none");
          });
          it("should have records read show 0", function() {
            return expect(this.dspc.$('.bv_recordsRead').html()).toEqual('0');
          });
          it("should have the read more button disabled", function() {
            return expect(this.dspc.$('.bv_readMore').attr('disabled')).toEqual("disabled");
          });
          return it("should have the read all button disabled", function() {
            return expect(this.dspc.$('.bv_readAll').attr('disabled')).toEqual("disabled");
          });
        });
        describe("browse file controller testing", function() {
          it("should set up the browse file controller", function() {
            return expect(this.dspc.browseFileController).toBeDefined();
          });
          return it("should set the fileName property when a file is uploaded", function() {
            this.dspc.handleFileUploaded("testFile");
            return expect(this.dspc.fileName).toEqual("testFile");
          });
        });
        describe("behavior", function() {
          return it("should read more records when button is clicked", function() {
            this.dspc.$('.bv_readMore').click();
            waits(1000);
            expect(this.dspc.numRecords).toEqual(100);
            return expect(this.dspc.$('.bv_recordsRead').html()).toEqual('100');
          });
        });
        return describe("other features", function() {
          it("should show sdf properties", function() {
            var sdfPropsList;
            sdfPropsList = new SdfPropertiesList(window.cmpdRegBulkLoaderServiceTestJSON.propertiesList['sdfProperties']);
            this.dspc.showSdfProperties(sdfPropsList);
            expect(this.dspc.$('.bv_recordsRead').html()).toEqual('100');
            expect(this.dspc.$('.bv_detectedSdfPropertiesList').val().indexOf('prop1')).toBeGreaterThan(-1);
            expect(this.dspc.$('.bv_recordsMore').attr('disabled')).toBeUndefined();
            return expect(this.dspc.$('.bv_recordsAll').attr('disabled')).toBeUndefined();
          });
          return it("should update the temp attr when the template is changed", function() {
            this.dspc.handleTemplateChanged('Template 1');
            return expect(this.dspc.temp).toEqual("Template 1");
          });
        });
      });
    });
    describe("Assigned Property Controller testing", function() {
      describe("when instantiated with no data", function() {
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
            return expect(this.apc.$('.bv_sdfProperty').html()).toEqual("");
          });
          it("should show the database property", function() {
            waitsFor(function() {
              return this.apc.$('.bv_dbProperty option').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.apc.$('.bv_dbProperty').val()).toEqual("none");
            });
          });
          return it("should show the default value", function() {
            return expect(this.apc.$('.bv_defaultVal').val()).toEqual("");
          });
        });
      });
      return describe("when instantiated with data", function() {
        beforeEach(function() {
          this.apc = new AssignedPropertyController({
            el: $('#fixture'),
            model: new AssignedProperty(window.cmpdRegBulkLoaderServiceTestJSON.propertiesList['bulkloadProperties'][0]),
            dbPropertiesList: new DbPropertiesList(window.cmpdRegBulkLoaderServiceTestJSON.propertiesList['dbProperties'])
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
        describe("rendering", function() {
          it("should show the sdf property", function() {
            return expect(this.apc.$('.bv_sdfProperty').html()).toEqual("prop1");
          });
          it("should show the database property", function() {
            waitsFor(function() {
              return this.apc.$('.bv_dbProperty option').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.apc.$('.bv_dbProperty').val()).toEqual("db1");
            });
          });
          return it("should show the default value", function() {
            return expect(this.apc.$('.bv_defaultVal').val()).toEqual("");
          });
        });
        return describe("model updates", function() {
          it("should update the dbProperty", function() {
            waitsFor(function() {
              return this.apc.$('.bv_dbProperty option').length > 0;
            }, 1000);
            return runs(function() {
              this.apc.$('.bv_dbProperty').val('db5');
              this.apc.$('.bv_dbProperty').change();
              expect(this.apc.model.get('dbProperty')).toEqual('db5');
              return expect(this.apc.model.get('required')).toEqual(true);
            });
          });
          return it("should update the default val", function() {
            this.apc.$('.bv_defaultVal').val("  testVal    ");
            this.apc.$('.bv_defaultVal').change();
            return expect(this.apc.model.get('defaultVal')).toEqual("testVal");
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
    describe("AssignSdfPropertiesController", function() {
      beforeEach(function() {
        this.aspc = new AssignSdfPropertiesController({
          el: $('#fixture')
        });
        return this.aspc.render();
      });
      describe("basic existence tests", function() {
        it("should exist", function() {
          return expect(this.aspc).toBeDefined();
        });
        it("should load a template", function() {
          return expect(this.aspc.$('.bv_useTemplate').length).toEqual(1);
        });
        return it("should have an assigned properties list controller", function() {
          return expect(this.aspc.templateListController).toBeDefined();
        });
      });
      describe("rendering", function() {
        return it("should show a template select", function() {
          waitsFor(function() {
            return this.aspc.$('.bv_useTemplate option').length > 0;
          }, 1000);
          return runs(function() {
            return expect(this.aspc.$('.bv_useTemplate').val()).toEqual("none");
          });
        });
      });
      return describe("behavior and validation", function() {
        beforeEach(function() {
          return this.aspc.createPropertyCollections(window.cmpdRegBulkLoaderServiceTestJSON.propertiesList);
        });
        it("should trigger template changed when template is changed", function() {
          var triggered;
          triggered = false;
          this.aspc.on('templateChanged', (function(_this) {
            return function() {
              return triggered = true;
            };
          })(this));
          this.aspc.$('.bv_useTemplate').val("Template 2");
          this.aspc.$('.bv_useTemplate').change();
          return expect(triggered).toEqual(true);
        });
        it("should show error if a project is not selected", function() {
          waitsFor(function() {
            return this.aspc.$('.bv_dbProject option').length > 0;
          }, 1000);
          return runs(function() {
            this.aspc.$('.bv_dbProject').val("unassigned");
            this.aspc.$('.bv_dbProject').change();
            expect(this.aspc.$('.bv_group_dbProject').hasClass('error')).toBeTruthy();
            return expect(this.aspc.$('.bv_regCmpds').attr('disabled')).toEqual('disabled');
          });
        });
        it("should show error if a default value isn't given for a required dbProperty", function() {
          waitsFor(function() {
            return this.aspc.$('.bv_dbProperty option').length > 0;
          }, 1000);
          return runs(function() {
            this.aspc.$('.bv_dbProperty:eq(2)').val("db3");
            this.aspc.$('.bv_dbProperty:eq(2)').change();
            expect(this.aspc.$('.bv_group_defaultVal:eq(2)').hasClass("error")).toBeTruthy();
            return expect(this.aspc.$('.bv_regCmpds').attr('disabled')).toEqual('disabled');
          });
        });
        it("should show error if a db property is chosen more than once", function() {
          waitsFor(function() {
            return this.aspc.$('.bv_dbProperty option').length > 0;
          }, 1000);
          return runs(function() {
            this.aspc.$('.bv_dbProperty:eq(1)').val("db5");
            this.aspc.$('.bv_dbProperty:eq(1)').change();
            this.aspc.$('.bv_dbProperty:eq(2)').val("db5");
            this.aspc.$('.bv_dbProperty:eq(2)').change();
            expect(this.aspc.$('.bv_group_dbProperty:eq(1)').hasClass("error")).toBeTruthy();
            expect(this.aspc.$('.bv_group_dbProperty:eq(2)').hasClass("error")).toBeTruthy();
            return expect(this.aspc.$('.bv_regCmpds').attr('disabled')).toEqual('disabled');
          });
        });
        it("should show error if save template is checked and the template name is already used and overwrite is set to no", function() {
          waitsFor(function() {
            return this.aspc.$('.bv_useTemplate option').length > 0;
          }, 1000);
          return runs(function() {
            this.aspc.$('.bv_useTemplate').val("Template 1");
            this.aspc.$('.bv_useTemplate').change();
            waits(1000);
            this.aspc.$('.bv_saveTemplate').click();
            expect(this.aspc.$('.bv_saveTemplate').attr("checked")).toEqual("checked");
            expect(this.aspc.$('.bv_group_templateName').hasClass("error")).toBeTruthy();
            return expect(this.aspc.$('.bv_regCmpds').attr('disabled')).toEqual('disabled');
          });
        });
        it("should not show error if save template is checked and the template name is already used and overwrite is set to yes", function() {
          waitsFor(function() {
            return this.aspc.$('.bv_useTemplate option').length > 0;
          }, 1000);
          return runs(function() {
            this.aspc.$('.bv_useTemplate').val("Template 1");
            this.aspc.$('.bv_useTemplate').change();
            this.aspc.$('.bv_saveTemplate').change();
            this.aspc.$('.bv_overwrite').change();
            expect(this.aspc.$('.bv_saveTemplate').attr("checked")).toEqual("checked");
            expect(this.aspc.$('.bv_group_templateName').hasClass("error")).toBeFalsy();
            return expect(this.aspc.$('.bv_regCmpds').attr('disabled')).toBeUndefined();
          });
        });
        return it("should have the Register Compounds button be enabled when the form is valid", function() {
          waitsFor(function() {
            return this.aspc.$('.bv_useTemplate option').length > 0;
          }, 1000);
          return runs(function() {
            this.aspc.$('.bv_useTemplate').val("Template 1");
            this.aspc.$('.bv_useTemplate').change();
            this.aspc.$('.bv_dbProperty:eq(0)').val("db1*");
            this.aspc.$('.bv_dbProperty:eq(1)').val("db2*");
            this.aspc.$('.bv_dbProperty:eq(2)').val("db3*");
            this.aspc.$('.bv_dbProperty:eq(3)').val("db4*");
            this.aspc.$('.bv_dbProperty:eq(4)').val("db5");
            return expect(this.aspc.$('.bv_regCmpds').attr('disabled')).toBeUndefined();
          });
        });
      });
    });
    describe("BulkRegCmpdsController testing", function() {
      beforeEach(function() {
        this.brcc = new BulkRegCmpdsController();
        return this.brcc.render();
      });
      return describe("basic loading", function() {
        it("should exist", function() {
          return expect(this.brcc).toBeDefined();
        });
        it("Should load the template", function() {
          return expect(this.brcc.$('.bv_detectSdfProperties').length).toEqual(1);
        });
        it("Should load a detectSdfPropertiesController", function() {
          return expect(this.brcc.detectSdfPropertiesController).toBeDefined();
        });
        return it("Should load a assignSdfPropertiesController ", function() {
          return expect(this.brcc.assignSdfPropertiesController).toBeDefined();
        });
      });
    });
    describe("BulkRegCmpdsSummaryController testing", function() {
      beforeEach(function() {
        this.brcsc = new BulkRegCmpdsSummaryController();
        return this.brcsc.render();
      });
      describe("basic loading", function() {
        it("should exist", function() {
          return expect(this.brcsc).toBeDefined();
        });
        return it("Should load the template", function() {
          return expect(this.brcsc.$('.bv_regSummaryHTML').length).toEqual(1);
        });
      });
      return describe("features", function() {
        return it("should trigger loadAnother when loadAnother is clicked", function() {
          var triggered;
          triggered = false;
          this.brcsc.on('loadAnother', (function(_this) {
            return function() {
              return triggered = true;
            };
          })(this));
          this.brcsc.$('.bv_loadAnother').click();
          return expect(triggered).toBeTruthy();
        });
      });
    });
    return describe("Cmpd Reg Bulk Loader App Controller testing", function() {
      beforeEach(function() {
        this.crblap = new CmpdRegBulkLoaderAppController();
        return this.crblap.render();
      });
      return describe("basic loading", function() {
        it("should exist", function() {
          return expect(this.crblap).toBeDefined();
        });
        return it("Should load the template", function() {
          return expect(this.crblap.$('.bv_headerName').length).toEqual(1);
        });
      });
    });
  });

}).call(this);
