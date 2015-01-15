(function() {
  beforeEach(function() {
    return this.fixture = $.clone($("#fixture").get(0));
  });

  afterEach(function() {
    $("#fixture").remove();
    return $("body").append($(this.fixture));
  });

  describe("Component Picker testing", function() {
    describe("AddComponent model testing", function() {
      return describe("When loaded from new", function() {
        beforeEach(function() {
          return this.ac = new AddComponent();
        });
        return describe("Existence and Defaults", function() {
          it("should be defined", function() {
            return expect(this.ac).toBeDefined();
          });
          return it("should have defaults", function() {
            return expect(this.ac.get('componentType')).toEqual("unassigned");
          });
        });
      });
    });
    describe("ComponentCodeName model testing", function() {
      describe("When loaded from new", function() {
        beforeEach(function() {
          return this.ccn = new ComponentCodeName();
        });
        return describe("Existence and Defaults", function() {
          it("should be defined", function() {
            return expect(this.ccn).toBeDefined();
          });
          return it("should have defaults", function() {
            expect(this.ccn.get('componentCodeName')).toEqual("unassigned");
            return expect(this.ccn.get('componentType')).toEqual("");
          });
        });
      });
      return describe("model validation tests", function() {
        beforeEach(function() {
          return this.ccn = new ComponentCodeName(window.componentPickerTestJSON.componentCodeNamesList[0]);
        });
        it("should be valid as initialized", function() {
          return expect(this.ccn.isValid()).toBeTruthy();
        });
        return it("should be invalid when component codeName is unassigned", function() {
          var filtErrors;
          this.ccn.set({
            componentCodeName: "unassigned"
          });
          expect(this.ccn.isValid()).toBeFalsy();
          filtErrors = _.filter(this.ccn.validationError, function(err) {
            return err.attribute === 'componentCodeName';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
      });
    });
    describe("ComponentCodeNamesList testing", function() {
      describe("When loaded from new", function() {
        beforeEach(function() {
          return this.ccnl = new ComponentCodeNamesList();
        });
        return describe("Existence", function() {
          return it("should be defined", function() {
            return expect(this.ccnl).toBeDefined();
          });
        });
      });
      return describe("When loaded form existing", function() {
        beforeEach(function() {
          return this.ccnl = new ComponentCodeNamesList(window.componentPickerTestJSON.componentCodeNamesList);
        });
        it("should have three components", function() {
          return expect(this.ccnl.length).toEqual(3);
        });
        it("should have the correct info for the first component", function() {
          var ruleone;
          ruleone = this.ccnl.at(0);
          expect(ruleone.get('componentType')).toEqual("Protein");
          return expect(ruleone.get('componentCodeName')).toEqual("PROT000001");
        });
        it("should have the correct info for the second component", function() {
          var ruletwo;
          ruletwo = this.ccnl.at(1);
          expect(ruletwo.get('componentType')).toEqual("Spacer");
          return expect(ruletwo.get('componentCodeName')).toEqual("SP000002");
        });
        return it("should have the correct read info for the third read", function() {
          var rulethree;
          rulethree = this.ccnl.at(2);
          expect(rulethree.get('componentType')).toEqual("Cationic Block");
          return expect(rulethree.get('componentCodeName')).toEqual("CB000003");
        });
      });
    });
    describe("AddComponentController", function() {
      return describe("when instantiated", function() {
        beforeEach(function() {
          this.acc = new AddComponentController({
            model: new AddComponent(),
            el: $('#fixture')
          });
          return this.acc.render();
        });
        describe("basic existence tests", function() {
          it("should exist", function() {
            return expect(this.acc).toBeDefined();
          });
          return it("should load a template", function() {
            return expect(this.acc.$('.bv_addComponentSelect').length).toEqual(1);
          });
        });
        describe("rendering", function() {
          return it("should show add component select", function() {
            waitsFor(function() {
              return this.acc.$('.bv_addComponentSelect option').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.acc.$('.bv_addComponentSelect').val()).toEqual("unassigned");
            });
          });
        });
        return describe("model updates", function() {
          return it("should update the component type", function() {
            waitsFor(function() {
              return this.acc.$('.bv_addComponentSelect option').length > 0;
            }, 1000);
            return runs(function() {
              this.acc.$('.bv_addComponentSelect').val('Protein');
              this.acc.$('.bv_addComponentSelect').change();
              return expect(this.acc.model.get('componentType')).toEqual("Protein");
            });
          });
        });
      });
    });
    describe("ComponentCodeNameController", function() {
      describe("when instantiated", function() {
        beforeEach(function() {
          this.ccnc = new ComponentCodeNameController({
            model: new ComponentCodeName(),
            el: $('#fixture')
          });
          return this.ccnc.render();
        });
        describe("basic existence tests", function() {
          it("should exist", function() {
            return expect(this.ccnc).toBeDefined();
          });
          return it("should load a template", function() {
            return expect(this.ccnc.$('.bv_componentCodeName').length).toEqual(1);
          });
        });
        return describe("rendering", function() {
          it("should show component codeName select", function() {
            return expect(this.ccnc.$('.bv_componentCodeName').length).toEqual(1);
          });
          return it("should show a label for the component", function() {
            return expect(this.ccnc.$('.bv_componentType').html()).toEqual("");
          });
        });
      });
      describe("when instantiated from existing", function() {
        beforeEach(function() {
          this.ccnc = new ComponentCodeNameController({
            model: new ComponentCodeName(window.componentPickerTestJSON.componentCodeNamesList[0]),
            el: $('#fixture')
          });
          return this.ccnc.render();
        });
        describe("rendering existing parameters", function() {
          it("should show component codeName select", function() {
            waitsFor(function() {
              return this.ccnc.$('.bv_componentCodeName option').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.ccnc.$('.bv_componentCodeName').val()).toEqual("PROT000001");
            });
          });
          return it("should show a label for the component", function() {
            return expect(this.ccnc.$('.bv_componentType').html()).toEqual("Protein");
          });
        });
        return describe("model updates", function() {
          return it("should update the component codeName", function() {
            waitsFor(function() {
              return this.ccnc.$('.bv_componentCodeName option').length > 0;
            }, 1000);
            return runs(function() {
              this.ccnc.$('.bv_componentCodeName').val('PROT000001');
              this.ccnc.$('.bv_componentCodeName').change();
              return expect(this.ccnc.model.get('componentCodeName')).toEqual("PROT000001");
            });
          });
        });
      });
      return describe("validation testing", function() {
        return beforeEach(function() {
          this.ccnc = new ComponentCodeNameController({
            model: new ComponentCodeName(),
            el: $('#fixture')
          });
          return this.ccnc.render();
        });
      });
    });
    return describe("ComponentCodeNameListController testing", function() {
      describe("when instantiated with no data", function() {
        beforeEach(function() {
          this.ccnlc = new ComponentCodeNamesListController({
            el: $('#fixture'),
            collection: new ComponentCodeNamesList()
          });
          return this.ccnlc.render();
        });
        describe("basic existence tests", function() {
          it("should exist", function() {
            return expect(this.ccnlc).toBeDefined();
          });
          return it("should load a template", function() {
            return expect(this.ccnlc.$('.bv_componentInfo').length).toEqual(1);
          });
        });
        return describe("rendering", function() {
          return it("should not show anything", function() {
            return expect(this.ccnlc.$('.bv_componentInfo').val()).toEqual("");
          });
        });
      });
      return describe("when instantiated with data", function() {
        beforeEach(function() {
          this.ccnlc = new ComponentCodeNamesListController({
            el: $('#fixture'),
            collection: new ComponentCodeNamesList(window.componentPickerTestJSON.componentCodeNamesList)
          });
          return this.ccnlc.render();
        });
        it("should have three reads", function() {
          return expect(this.ccnlc.collection.length).toEqual(3);
        });
        it("should have the correct info for the first component", function() {
          waitsFor(function() {
            return this.ccnlc.$('.bv_componentCodeName option').length > 0;
          }, 1000);
          return runs(function() {
            expect(this.ccnlc.$('.bv_componentType:eq(0)').html()).toEqual("Protein");
            return expect(this.ccnlc.$('.bv_componentCodeName:eq(0)').val()).toEqual("PROT000001");
          });
        });
        it("should have the correct info for the second component", function() {
          waitsFor(function() {
            return this.ccnlc.$('.bv_componentCodeName option').length > 0;
          }, 1000);
          return runs(function() {
            expect(this.ccnlc.$('.bv_componentType:eq(1)').html()).toEqual("Spacer");
            return expect(this.ccnlc.$('.bv_componentCodeName:eq(1)').val()).toEqual("SP000002");
          });
        });
        it("should have the correct info for the third component", function() {
          waitsFor(function() {
            return this.ccnlc.$('.bv_componentCodeName option').length > 0;
          }, 1000);
          return runs(function() {
            expect(this.ccnlc.$('.bv_componentType:eq(2)').html()).toEqual("Cationic Block");
            return expect(this.ccnlc.$('.bv_componentCodeName:eq(2)').val()).toEqual("CB000003");
          });
        });
        return describe("adding and removing", function() {
          return it("should have two components when the x is clicked", function() {
            this.ccnlc.$('.bv_deleteComponent:eq(0)').click();
            expect(this.ccnlc.$('.bv_componentInfo .bv_componentCodeName').length).toEqual(2);
            return expect(this.ccnlc.collection.length).toEqual(2);
          });
        });
      });
    });
  });

}).call(this);
