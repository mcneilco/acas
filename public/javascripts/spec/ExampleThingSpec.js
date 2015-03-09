(function() {
  beforeEach(function() {
    return this.fixture = $.clone($("#fixture").get(0));
  });

  afterEach(function() {
    $("#fixture").remove();
    return $("body").append($(this.fixture));
  });

  describe('Example Thing testing', function() {
    describe("Example Thing model testing", function() {
      describe("when loaded from new", function() {
        beforeEach(function() {
          return this.et = new ExampleThing();
        });
        describe("Existence and Defaults", function() {
          it("should be defined", function() {
            return expect(this.et).toBeDefined();
          });
          it("should have a type", function() {
            return expect(this.et.get('lsType')).toEqual("parent");
          });
          it("should have a kind", function() {
            return expect(this.et.get('lsKind')).toEqual("cationic block");
          });
          it("should have the recordedBy set to the logged in user", function() {
            return expect(this.et.get('recordedBy')).toEqual(window.AppLaunchParams.loginUser.username);
          });
          it("should have a recordedDate set to now", function() {
            return expect(new Date(this.et.get('recordedDate')).getHours()).toEqual(new Date().getHours());
          });
          it("Should have a lsLabels with one label", function() {
            expect(this.et.get('lsLabels')).toBeDefined();
            expect(this.et.get("lsLabels").length).toEqual(1);
            return expect(this.et.get("lsLabels").getLabelByTypeAndKind("name", "cationic block").length).toEqual(1);
          });
          it("Should have a model attribute for the label in defaultLabels", function() {
            return expect(this.et.get("cationic block name")).toBeDefined();
          });
          it("Should have a lsStates with the states in defaultStates", function() {
            expect(this.et.get('lsStates')).toBeDefined();
            expect(this.et.get("lsStates").length).toEqual(1);
            return expect(this.et.get("lsStates").getStatesByTypeAndKind("metadata", "cationic block parent").length).toEqual(1);
          });
          return describe("model attributes for each value in defaultValues", function() {
            it("Should have a model attribute for scientist", function() {
              return expect(this.et.get("scientist")).toBeDefined();
            });
            it("Should have a model attribute for completion date", function() {
              return expect(this.et.get("completion date")).toBeDefined();
            });
            it("Should have a model attribute for notebook", function() {
              return expect(this.et.get("notebook")).toBeDefined();
            });
            return it("Should have a model attribute for structural file", function() {
              return expect(this.et.get("structural file")).toBeDefined();
            });
          });
        });
        return describe("model validation", function() {
          return it("should be invalid when name is empty", function() {
            var filtErrors;
            this.et.get("cationic block name").set("labelText", "");
            expect(this.et.isValid()).toBeFalsy();
            filtErrors = _.filter(this.et.validationError, function(err) {
              return err.attribute === 'thingName';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
        });
      });
      return describe("When created from existing", function() {
        beforeEach(function() {
          return this.et = new ExampleThing(JSON.parse(JSON.stringify(window.exampleThingTestJSON.exampleThing)));
        });
        describe("after initial load", function() {
          it("should be defined", function() {
            return expect(this.et).toBeDefined();
          });
          it("should have a type", function() {
            return expect(this.et.get('lsType')).toEqual("parent");
          });
          it("should have a kind", function() {
            return expect(this.et.get('lsKind')).toEqual("cationic block");
          });
          it("should have a recordedBy set", function() {
            return expect(this.et.get('recordedBy')).toEqual("jane");
          });
          it("should have a recordedDate set", function() {
            return expect(this.et.get('recordedDate')).toEqual(1375141508000);
          });
          it("Should have label set", function() {
            var label;
            console.log(this.et);
            expect(this.et.get("cationic block name").get("labelText")).toEqual("cMAP10");
            label = this.et.get("lsLabels").getLabelByTypeAndKind("name", "cationic block");
            console.log(label[0]);
            return expect(label[0].get('labelText')).toEqual("cMAP10");
          });
          it("Should have a lsStates with the states in defaultStates", function() {
            expect(this.et.get('lsStates')).toBeDefined();
            expect(this.et.get("lsStates").length).toEqual(1);
            return expect(this.et.get("lsStates").getStatesByTypeAndKind("metadata", "cationic block parent").length).toEqual(1);
          });
          it("Should have a scientist value", function() {
            return expect(this.et.get("scientist").get("value")).toEqual("john");
          });
          it("Should have a completion date value", function() {
            return expect(this.et.get("completion date").get("value")).toEqual(1342080000000);
          });
          it("Should have a notebook value", function() {
            return expect(this.et.get("notebook").get("value")).toEqual("Notebook 1");
          });
          return it("Should have a structural file value", function() {
            return expect(this.et.get("structural file").get("value")).toEqual("TestFile.mol");
          });
        });
        return describe("model validation", function() {
          beforeEach(function() {
            return this.et = new ExampleThing(window.exampleThingTestJSON.exampleThing);
          });
          it("should be valid when loaded from saved", function() {
            return expect(this.et.isValid()).toBeTruthy();
          });
          it("should be invalid when name is empty", function() {
            var filtErrors;
            this.et.get("cationic block name").set("labelText", "");
            expect(this.et.isValid()).toBeFalsy();
            filtErrors = _.filter(this.et.validationError, function(err) {
              return err.attribute === 'thingName';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
          it("should be invalid when scientist not selected", function() {
            var filtErrors;
            this.et.get('scientist').set('value', "unassigned");
            expect(this.et.isValid()).toBeFalsy();
            filtErrors = _.filter(this.et.validationError, function(err) {
              return err.attribute === 'scientist';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
          it("should be invalid when completion date is empty", function() {
            var filtErrors;
            this.et.get("completion date").set("value", new Date("").getTime());
            expect(this.et.isValid()).toBeFalsy();
            filtErrors = _.filter(this.et.validationError, function(err) {
              return err.attribute === 'completionDate';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
          return it("should be invalid when notebook is empty", function() {
            var filtErrors;
            this.et.get("notebook").set("value", "");
            expect(this.et.isValid()).toBeFalsy();
            filtErrors = _.filter(this.et.validationError, function(err) {
              return err.attribute === 'notebook';
            });
            return expect(filtErrors.length).toBeGreaterThan(0);
          });
        });
      });
    });
    return describe("Cationic Block Parent Controller testing", function() {
      describe("When instantiated from new", function() {
        beforeEach(function() {
          this.et = new ExampleThing();
          this.etc = new ExampleThingController({
            model: this.et,
            el: $('#fixture')
          });
          return this.etc.render();
        });
        return describe("basic existence tests", function() {
          it("should exist", function() {
            return expect(this.etc).toBeDefined();
          });
          it("should load the template", function() {
            return expect(this.etc.$('.bv_thingCode').html()).toEqual("Autofilled when saved");
          });
          return it("should load the additional parent attributes temlate", function() {
            return expect(this.etc.$('.bv_structuralFile').length).toEqual(1);
          });
        });
      });
      return describe("When instantiated from existing", function() {
        beforeEach(function() {
          this.et = new ExampleThing(JSON.parse(JSON.stringify(window.exampleThingTestJSON.exampleThing)));
          this.etc = new ExampleThingController({
            model: this.et,
            el: $('#fixture')
          });
          return this.etc.render();
        });
        describe("render existing parameters", function() {
          it("should show the cationic block parent id", function() {
            return expect(this.etc.$('.bv_thingCode').val()).toEqual("CB000001");
          });
          it("should fill the cationic block parent name", function() {
            return expect(this.etc.$('.bv_thingName').val()).toEqual("cMAP10");
          });
          it("should fill the scientist field", function() {
            waitsFor(function() {
              return this.etc.$('.bv_scientist option').length > 0;
            }, 1000);
            return runs(function() {
              console.log(this.etc.$('.bv_scientist').val());
              return expect(this.etc.$('.bv_scientist').val()).toEqual("john");
            });
          });
          it("should fill the completion date field", function() {
            return expect(this.etc.$('.bv_completionDate').val()).toEqual("2012-07-12");
          });
          return it("should fill the notebook field", function() {
            return expect(this.etc.$('.bv_notebook').val()).toEqual("Notebook 1");
          });
        });
        describe("model updates", function() {
          it("should update model when parent name is changed", function() {
            this.etc.$('.bv_thingName').val(" New name   ");
            this.etc.$('.bv_thingName').keyup();
            return expect(this.etc.model.get('cationic block name').get('labelText')).toEqual("New name");
          });
          it("should update model when the scientist is changed", function() {
            waitsFor(function() {
              return this.etc.$('.bv_scientist option').length > 0;
            }, 1000);
            return runs(function() {
              this.etc.$('.bv_scientist').val('unassigned');
              this.etc.$('.bv_scientist').change();
              return expect(this.etc.model.get('scientist').get('value')).toEqual("unassigned");
            });
          });
          it("should update model when completion date is changed", function() {
            this.etc.$('.bv_completionDate').val(" 2013-3-16   ");
            this.etc.$('.bv_completionDate').keyup();
            return expect(this.etc.model.get('completion date').get('value')).toEqual(new Date(2013, 2, 16).getTime());
          });
          return it("should update model when notebook is changed", function() {
            this.etc.$('.bv_notebook').val(" Updated notebook  ");
            this.etc.$('.bv_notebook').keyup();
            return expect(this.etc.model.get('notebook').get('value')).toEqual("Updated notebook");
          });
        });
        return describe("controller validation rules", function() {
          beforeEach(function() {
            waitsFor(function() {
              return this.etc.$('.bv_scientist option').length > 0;
            }, 1000);
            return runs(function() {
              this.etc.$('.bv_thingName').val(" Updated entity name   ");
              this.etc.$('.bv_thingName').keyup();
              this.etc.$('.bv_scientist').val("bob");
              this.etc.$('.bv_scientist').change();
              this.etc.$('.bv_completionDate').val(" 2013-3-16   ");
              this.etc.$('.bv_completionDate').keyup();
              this.etc.$('.bv_notebook').val("my notebook");
              return this.etc.$('.bv_notebook').keyup();
            });
          });
          describe("form validation setup", function() {
            it("should be valid if form fully filled out", function() {
              return runs(function() {
                return expect(this.etc.isValid()).toBeTruthy();
              });
            });
            return it("should have the update button be enabled", function() {
              return runs(function() {
                return expect(this.etc.$('.bv_updateParent').attr('disabled')).toBeUndefined();
              });
            });
          });
          describe("when name field not filled in", function() {
            beforeEach(function() {
              return runs(function() {
                this.etc.$('.bv_thingName').val("");
                return this.etc.$('.bv_thingName').keyup();
              });
            });
            it("should be invalid if name not filled in", function() {
              return runs(function() {
                return expect(this.etc.isValid()).toBeFalsy();
              });
            });
            it("should show error in name field", function() {
              return runs(function() {
                return expect(this.etc.$('.bv_group_thingName').hasClass('error')).toBeTruthy();
              });
            });
            return it("should have the update button be disabled", function() {
              return runs(function() {
                return expect(this.etc.$('.bv_saveThing').attr('disabled')).toEqual('disabled');
              });
            });
          });
          describe("when scientist not selected", function() {
            beforeEach(function() {
              return runs(function() {
                this.etc.$('.bv_scientist').val("");
                return this.etc.$('.bv_scientist').change();
              });
            });
            return it("should show error on scientist dropdown", function() {
              return runs(function() {
                return expect(this.etc.$('.bv_group_scientist').hasClass('error')).toBeTruthy();
              });
            });
          });
          describe("when date field not filled in", function() {
            beforeEach(function() {
              return runs(function() {
                this.etc.$('.bv_completionDate').val("");
                return this.etc.$('.bv_completionDate').keyup();
              });
            });
            return it("should show error in date field", function() {
              return runs(function() {
                return expect(this.etc.$('.bv_group_completionDate').hasClass('error')).toBeTruthy();
              });
            });
          });
          return describe("when notebook not filled", function() {
            beforeEach(function() {
              return runs(function() {
                this.etc.$('.bv_notebook').val("");
                return this.etc.$('.bv_notebook').keyup();
              });
            });
            return it("should show error on notebook field", function() {
              return runs(function() {
                return expect(this.etc.$('.bv_group_notebook').hasClass('error')).toBeTruthy();
              });
            });
          });
        });
      });
    });
  });

}).call(this);
