(function() {
  beforeEach(function() {
    return this.fixture = $.clone($("#fixture").get(0));
  });

  afterEach(function() {
    $("#fixture").remove();
    return $("body").append($(this.fixture));
  });

  describe('Base Component testing', function() {
    describe("Base Component Batch model testing", function() {
      describe("when loaded from new", function() {
        beforeEach(function() {
          return this.bcb = new BaseComponentBatch();
        });
        return describe("Existence and Defaults", function() {
          it("should be defined", function() {
            return expect(this.bcb).toBeDefined();
          });
          it("should have a type", function() {
            return expect(this.bcb.get('lsType')).toEqual("batch");
          });
          it("should have a kind", function() {
            return expect(this.bcb.get('lsKind')).toEqual("base component");
          });
          it("should have an empty scientist", function() {
            return expect(this.bcb.get('recordedBy')).toEqual("");
          });
          it("should have a recordedDate set to now", function() {
            return expect(new Date(this.bcb.get('recordedDate')).getHours()).toEqual(new Date().getHours());
          });
          return describe("model attributes for each value in defaultValues", function() {
            it("Should have a model attribute for completion date", function() {
              return expect(this.bcb.get("completion date")).toBeDefined();
            });
            it("Should have a model attribute for notebook", function() {
              return expect(this.bcb.get("notebook")).toBeDefined();
            });
            it("Should have a model attribute for amount", function() {
              return expect(this.bcb.get("amount")).toBeDefined();
            });
            return it("Should have a model attribute for location", function() {
              return expect(this.bcb.get("location")).toBeDefined();
            });
          });
        });
      });
      describe("When created from existing", function() {
        beforeEach(function() {
          return this.bcb = new BaseComponentBatch(JSON.parse(JSON.stringify(window.baseComponentTestJSON.baseComponentBatch)));
        });
        return describe("after initial load", function() {
          it("should be defined", function() {
            return expect(this.bcb).toBeDefined();
          });
          it("should have a type", function() {
            return expect(this.bcb.get('lsType')).toEqual("batch");
          });
          it("should have a kind", function() {
            return expect(this.bcb.get('lsKind')).toEqual("base component");
          });
          it("should have a scientist set", function() {
            return expect(this.bcb.get('recordedBy')).toEqual("jane");
          });
          it("should have a recordedDate set", function() {
            return expect(this.bcb.get('recordedDate')).toEqual(1375141508000);
          });
          it("Should have a lsStates with the states in defaultStates", function() {
            expect(this.bcb.get('lsStates')).toBeDefined();
            expect(this.bcb.get("lsStates").length).toEqual(2);
            expect(this.bcb.get("lsStates").getStatesByTypeAndKind("metadata", "cationic block batch").length).toEqual(1);
            return expect(this.bcb.get("lsStates").getStatesByTypeAndKind("metadata", "inventory").length).toEqual(1);
          });
          it("Should have a completion date value", function() {
            return expect(this.bcb.get("completion date").get("value")).toEqual(1342080000000);
          });
          it("Should have a notebook value", function() {
            return expect(this.bcb.get("notebook").get("value")).toEqual("Notebook 1");
          });
          it("Should have an amount value", function() {
            return expect(this.bcb.get("amount").get("value")).toEqual(2.3);
          });
          return it("Should have a location value", function() {
            return expect(this.bcb.get("location").get("value")).toEqual("Cabinet 1");
          });
        });
      });
      return describe("model validation", function() {
        beforeEach(function() {
          return this.bcb = new CationicBlockBatch(window.cationicBlockTestJSON.cationicBlockBatch);
        });
        it("should be valid when loaded from saved", function() {
          return expect(this.bcb.isValid()).toBeTruthy();
        });
        it("should be invalid when recorded date is empty", function() {
          var filtErrors;
          this.bcb.set({
            recordedDate: new Date("").getTime()
          });
          expect(this.bcb.isValid()).toBeFalsy();
          filtErrors = _.filter(this.bcb.validationError, function(err) {
            return err.attribute === 'recordedDate';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it("should be invalid when scientist not selected", function() {
          var filtErrors;
          this.bcb.set({
            recordedBy: ""
          });
          expect(this.bcb.isValid()).toBeFalsy();
          return filtErrors = _.filter(this.bcb.validationError, function(err) {
            return err.attribute === 'recordedBy';
          });
        });
        it("should be invalid when completion date is empty", function() {
          var filtErrors;
          this.bcb.get("completion date").set("value", new Date("").getTime());
          expect(this.bcb.isValid()).toBeFalsy();
          filtErrors = _.filter(this.bcb.validationError, function(err) {
            return err.attribute === 'completionDate';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it("should be invalid when notebook is empty", function() {
          var filtErrors;
          this.bcb.get("notebook").set("value", "");
          expect(this.bcb.isValid()).toBeFalsy();
          filtErrors = _.filter(this.bcb.validationError, function(err) {
            return err.attribute === 'notebook';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        it("should be invalid when amount is NaN", function() {
          var filtErrors;
          this.bcb.get("amount").set("value", "fred");
          expect(this.bcb.isValid()).toBeFalsy();
          filtErrors = _.filter(this.bcb.validationError, function(err) {
            return err.attribute === 'amount';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
        return it("should be invalid when location is empty", function() {
          var filtErrors;
          this.bcb.get("location").set("value", "");
          expect(this.bcb.isValid()).toBeFalsy();
          filtErrors = _.filter(this.bcb.validationError, function(err) {
            return err.attribute === 'location';
          });
          return expect(filtErrors.length).toBeGreaterThan(0);
        });
      });
    });
    return describe("Base Component Batch Controller testing", function() {
      describe("When instantiated from new", function() {
        beforeEach(function() {
          this.cbb = new CationicBlockBatch();
          this.bcbc = new BaseComponentBatchController({
            model: this.cbb,
            el: $('#fixture')
          });
          return this.bcbc.render();
        });
        return describe("basic existence tests", function() {
          it("should exist", function() {
            return expect(this.bcbc).toBeDefined();
          });
          return it("should load the template", function() {
            return expect(this.bcbc.$('.bv_cationicBlockBatchCode').html()).toEqual("autofill when saved");
          });
        });
      });
      return describe("When instantiated from existing", function() {
        beforeEach(function() {
          this.cbb = new CationicBlockBatch(JSON.parse(JSON.stringify(window.cationicBlockTestJSON.cationicBlockBatch)));
          this.bcbc = new CationicBlockBatchController({
            model: this.cbb,
            el: $('#fixture')
          });
          return this.bcbc.render();
        });
        describe("render existing parameters", function() {
          it("should show the cationic block batch id", function() {
            return expect(this.bcbc.$('.bv_cationicBlockBatchCode').val()).toEqual("CB000001-1");
          });
          it("should fill the scientist field", function() {
            waitsFor(function() {
              return this.bcbc.$('.bv_recordedBy option').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.bcbc.$('.bv_recordedBy').val()).toEqual("jane");
            });
          });
          it("should fill the completion date field", function() {
            return expect(this.bcbc.$('.bv_completionDate').val()).toEqual("2012-07-12");
          });
          it("should fill the notebook field", function() {
            return expect(this.bcbc.$('.bv_notebook').val()).toEqual("Notebook 1");
          });
          it("should fill the amount field", function() {
            return expect(this.bcbc.$('.bv_amount').val()).toEqual("2.3");
          });
          return it("should fill the location field", function() {
            return expect(this.bcbc.$('.bv_location').val()).toEqual("Cabinet 1");
          });
        });
        describe("model updates", function() {
          it("should update model when the scientist is changed", function() {
            waitsFor(function() {
              return this.bcbc.$('.bv_recordedBy option').length > 0;
            }, 1000);
            return runs(function() {
              this.bcbc.$('.bv_recordedBy').val('unassigned');
              this.bcbc.$('.bv_recordedBy').change();
              return expect(this.bcbc.model.get('recordedBy')).toEqual("unassigned");
            });
          });
          it("should update model when completion date is changed", function() {
            this.bcbc.$('.bv_completionDate').val(" 2013-3-16   ");
            this.bcbc.$('.bv_completionDate').change();
            return expect(this.bcbc.model.get('completion date').get('value')).toEqual(new Date(2013, 2, 16).getTime());
          });
          it("should update model when notebook is changed", function() {
            this.bcbc.$('.bv_notebook').val(" Updated notebook  ");
            this.bcbc.$('.bv_notebook').change();
            return expect(this.bcbc.model.get('notebook').get('value')).toEqual("Updated notebook");
          });
          it("should update model when amount is changed", function() {
            this.bcbc.$('.bv_amount').val(" 12  ");
            this.bcbc.$('.bv_amount').change();
            return expect(this.bcbc.model.get('amount').get('value')).toEqual(12);
          });
          return it("should update model when location is changed", function() {
            this.bcbc.$('.bv_location').val(" Updated location  ");
            this.bcbc.$('.bv_location').change();
            return expect(this.bcbc.model.get('location').get('value')).toEqual("Updated location");
          });
        });
        return describe("controller validation rules", function() {
          beforeEach(function() {
            waitsFor(function() {
              return this.bcbc.$('.bv_recordedBy option').length > 0;
            }, 1000);
            return runs(function() {
              this.bcbc.$('.bv_recordedBy').val("bob");
              this.bcbc.$('.bv_recordedBy').change();
              this.bcbc.$('.bv_completionDate').val(" 2013-3-16   ");
              this.bcbc.$('.bv_completionDate').change();
              this.bcbc.$('.bv_notebook').val("my notebook");
              this.bcbc.$('.bv_notebook').change();
              this.bcbc.$('.bv_amount').val(" 24");
              this.bcbc.$('.bv_amount').change();
              this.bcbc.$('.bv_location').val(" Hood 4");
              return this.bcbc.$('.bv_location').change();
            });
          });
          describe("form validation setup", function() {
            return it("should be valid if form fully filled out", function() {
              return runs(function() {
                return expect(this.bcbc.isValid()).toBeTruthy();
              });
            });
          });
          describe("when scientist not selected", function() {
            beforeEach(function() {
              return runs(function() {
                this.bcbc.$('.bv_recordedBy').val("");
                return this.bcbc.$('.bv_recordedBy').change();
              });
            });
            return it("should show error on scientist dropdown", function() {
              return runs(function() {
                return expect(this.bcbc.$('.bv_group_recordedBy').hasClass('error')).toBeTruthy();
              });
            });
          });
          describe("when date field not filled in", function() {
            beforeEach(function() {
              return runs(function() {
                this.bcbc.$('.bv_completionDate').val("");
                return this.bcbc.$('.bv_completionDate').change();
              });
            });
            return it("should show error in date field", function() {
              return runs(function() {
                return expect(this.bcbc.$('.bv_group_completionDate').hasClass('error')).toBeTruthy();
              });
            });
          });
          describe("when notebook not filled", function() {
            beforeEach(function() {
              return runs(function() {
                this.bcbc.$('.bv_notebook').val("");
                return this.bcbc.$('.bv_notebook').change();
              });
            });
            return it("should show error on notebook field", function() {
              return runs(function() {
                return expect(this.bcbc.$('.bv_group_notebook').hasClass('error')).toBeTruthy();
              });
            });
          });
          describe("when amount not filled", function() {
            beforeEach(function() {
              return runs(function() {
                this.bcbc.$('.bv_amount').val("");
                return this.bcbc.$('.bv_amount').change();
              });
            });
            return it("should show error on amount field", function() {
              return runs(function() {
                return expect(this.bcbc.$('.bv_group_amount').hasClass('error')).toBeTruthy();
              });
            });
          });
          return describe("when location not filled", function() {
            beforeEach(function() {
              return runs(function() {
                this.bcbc.$('.bv_location').val("");
                return this.bcbc.$('.bv_location').change();
              });
            });
            return it("should show error on location field", function() {
              return runs(function() {
                return expect(this.bcbc.$('.bv_group_location').hasClass('error')).toBeTruthy();
              });
            });
          });
        });
      });
    });
  });

}).call(this);
