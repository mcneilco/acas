(function() {
  beforeEach(function() {
    return this.fixture = $.clone($("#fixture").get(0));
  });

  afterEach(function() {
    $("#fixture").remove();
    return $("body").append($(this.fixture));
  });

  describe('Base Component testing', function() {
    return describe("Base Component Batch model testing", function() {
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
            return expect(this.bcb.get('lsKind')).toEqual("component");
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
          return this.bcb = new BaseComponentBatch(JSON.parse(JSON.stringify(window.cationicBlockTestJSON.cationicBlockBatch)));
        });
        return describe("after initial load", function() {
          it("should be defined", function() {
            return expect(this.bcb).toBeDefined();
          });
          it("should have a type", function() {
            return expect(this.bcb.get('lsType')).toEqual("batch");
          });
          it("should have a kind", function() {
            return expect(this.bcb.get('lsKind')).toEqual("cationic block");
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
  });

}).call(this);
