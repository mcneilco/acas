(function() {
  beforeEach(function() {
    this.fixture = $.clone($("#fixture").get(0));
    window.logger = {
      log: function(message) {}
    };
    window.Office = {
      context: {
        document: {
          getSelectedDataAsync: function(type, callback) {
            return callback(window.resultMockObject);
          }
        }
      }
    };
    window.successfulResultMockObject = {
      status: 'succeeded',
      value: 'mockResultValue'
    };
    return window.unsuccessfulResultMockObject = {
      status: 'failed',
      value: null,
      error: {
        name: "error message name",
        value: "mock error message"
      }
    };
  });

  afterEach(function() {
    $("#fixture").remove();
    return $("body").append($(this.fixture));
  });

  describe("Excel Compound Info App module testing", function() {
    describe("Attributes Controller", function() {
      beforeEach(function() {
        this.attributesController = new AttributesController({
          el: $("#fixture")
        });
        return this.attributesController.render();
      });
      return describe("Basic existence tests and defaults", function() {
        it("should be defined", function() {
          return expect(this.attributesController).toBeDefined();
        });
        return it("insert column headers and include requested ids should be checked by default", function() {
          expect(this.attributesController.$('.bv_insertColumnHeaders').attr("checked")).toEqual("checked");
          return expect(this.attributesController.$('.bv_includeRequestedID').attr("checked")).toBeUndefined();
        });
      });
    });
    describe("Property Descriptor Controller", function() {
      beforeEach(function() {
        this.pdc = new PropertyDescriptorController({
          el: $("#fixture"),
          model: new PropertyDescriptor(window.parentPropertyDescriptorsTestJSON.parentPropertyDescriptors[0])
        });
        return this.pdc.render();
      });
      describe('basic existence testing', function(done) {
        return it("should have a Property Descriptor as a model", function() {
          return expect(this.pdc.model instanceof PropertyDescriptor).toBeTruthy();
        });
      });
      describe('rendering testing', function() {
        it("should set the description label to the models pretty name", function() {
          var descriptorLabel, modelPrettyName;
          modelPrettyName = this.pdc.model.get('valueDescriptor').prettyName;
          descriptorLabel = this.pdc.$('.bv_descriptorLabel').html();
          return expect(descriptorLabel).toEqual(modelPrettyName);
        });
        return it("should set the description label title attribute to the models description", function() {
          var descriptorTitle, modelDescription;
          modelDescription = this.pdc.model.get('valueDescriptor').description;
          descriptorTitle = this.pdc.$('.bv_descriptorLabel').attr('title');
          return expect(descriptorTitle).toEqual(modelDescription);
        });
      });
      return describe('clicking on the property descriptor checkbox', function() {
        return it("should trigger handleDescriptorCheckboxChanged", function() {
          spyOn(this.pdc, "handleDescriptorCheckboxChanged");
          this.pdc.delegateEvents();
          this.pdc.$('.bv_propertyDescriptorCheckbox').click();
          return expect(this.pdc.handleDescriptorCheckboxChanged).toHaveBeenCalled();
        });
      });
    });
    describe("Property Descriptor List Controller", function() {
      beforeEach(function(done) {
        setTimeout((function() {
          window.propertyDescriptorListController = new PropertyDescriptorListController({
            el: $("#fixture"),
            title: 'Parent Properties',
            url: '/api/compound/parent/property/descriptors'
          });
          window.propertyDescriptorListController.on('ready', function() {
            window.propertyDescriptorListController.render();
            return done();
          });
        }), 100);
      });
      describe('basic existence testing', function(done) {
        return it("should populate a collection", function() {
          return expect(window.propertyDescriptorListController.collection.length).toBeGreaterThan(0);
        });
      });
      return describe('basic rendering', function(done) {
        it("should have a title", function() {
          return expect(window.propertyDescriptorListController.$('.propertyDescriptorListControllerTitle').html()).toEqual('Parent Properties');
        });
        return it("should render the property descriptor list", function() {
          return expect(window.propertyDescriptorListController.$('.bv_propertyDescriptorList .bv_descriptorLabel').length).toBeGreaterThan(0);
        });
      });
    });
    return describe("Excel Compound Info App controller", function() {
      beforeEach(function(done) {
        setTimeout((function() {
          var numberReady;
          window.insertCompoundPropertiesController = new ExcelInsertCompoundPropertiesController({
            el: $("#fixture")
          });
          window.insertCompoundPropertiesController.render();
          numberReady = 0;
          window.insertCompoundPropertiesController.batchPropertyDescriptorListController.on('ready', function() {
            if (numberReady === 1) {
              return done();
            } else {
              return numberReady = 1;
            }
          });
          window.insertCompoundPropertiesController.parentPropertyDescriptorListController.on('ready', function() {
            if (numberReady === 1) {
              return done();
            } else {
              return numberReady = 1;
            }
          });
        }), 100);
      });
      describe("Basic existence tests", function() {
        return it("should be defined", function() {
          expect(insertCompoundPropertiesController).toBeDefined();
          expect(insertCompoundPropertiesController.attributesController).toBeDefined();
          expect(insertCompoundPropertiesController.parentPropertyDescriptorListController).toBeDefined();
          return expect(insertCompoundPropertiesController.batchPropertyDescriptorListController).toBeDefined();
        });
      });
      describe("getSelectedProperties", function() {
        return it("should return an array of properties with a batch and parent key", function() {
          console.log(window.insertCompoundPropertiesController.$('.bv_parentProperties'));
          window.insertCompoundPropertiesController.$('.bv_batchProperties .bv_propertyDescriptorList .bv_propertyDescriptorCheckbox')[0].click();
          window.insertCompoundPropertiesController.$('.bv_batchProperties .bv_propertyDescriptorList .bv_propertyDescriptorCheckbox')[1].click();
          window.insertCompoundPropertiesController.$('.bv_parentProperties .bv_propertyDescriptorList .bv_propertyDescriptorCheckbox')[0].click();
          return window.insertCompoundPropertiesController.getSelectedProperties(function(selectedProperties) {
            expect(selectedProperties.parentNames.length).toEqual(1);
            return expect(selectedProperties.batchNames.length).toEqual(2);
          });
        });
      });
      return describe("handleGetPropertiesClicked", function() {
        it("should call fetchPrepared if result.status is 'succeeded'", function() {
          window.resultMockObject = window.successfulResultMockObject;
          spyOn(insertCompoundPropertiesController, "getPropertiesAndRequestData");
          insertCompoundPropertiesController.handleGetPropertiesClicked();
          return expect(insertCompoundPropertiesController.getPropertiesAndRequestData).toHaveBeenCalled();
        });
        return it("should not call fetchPrepared if result.status is not 'succeeded'", function() {
          window.resultMockObject = window.unsuccessfulResultMockObject;
          spyOn(insertCompoundPropertiesController, "getPropertiesAndRequestData");
          insertCompoundPropertiesController.handleGetPropertiesClicked();
          return expect(insertCompoundPropertiesController.getPropertiesAndRequestData).not.toHaveBeenCalled();
        });
      });
    });
  });

}).call(this);
