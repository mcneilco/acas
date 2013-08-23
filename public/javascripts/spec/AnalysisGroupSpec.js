/*
This suite of services provides CRUD operations on Analysis Group Objects
*/


(function() {
  describe('AnalysisGroup CRUD testing', function() {
    beforeEach(function() {
      return this.waitForServiceReturn = function() {
        return typeof this.serviceReturn !== 'undefined';
      };
    });
    return describe("AnalysisGroup model testing", function() {
      describe("when created empty", function() {
        beforeEach(function() {
          return this.ag = new AnalysisGroup();
        });
        return describe("defaults", function() {
          it('Should have an empty label list', function() {
            expect(this.ag.get('lsLabels').length).toEqual(0);
            return expect(this.ag.get('lsLabels') instanceof LabelList).toBeTruthy();
          });
          it('Should have an empty state list', function() {
            expect(this.ag.get('lsStates').length).toEqual(0);
            return expect(this.ag.get('lsStates') instanceof StateList).toBeTruthy();
          });
          it('Should have an empty scientist', function() {
            return expect(this.ag.get('recordedBy')).toEqual("");
          });
          it('Should have an empty recordedDate', function() {
            return expect(this.ag.get('recordedDate')).toBeNull();
          });
          return it('Should have an empty kind', function() {
            return expect(this.ag.get('kind')).toEqual("");
          });
        });
      });
      return describe("when loaded from existing", function() {
        beforeEach(function() {
          return this.ag = new AnalysisGroup(window.experimentServiceTestJSON.savedExperimentWithTreatmentGroup.analysisGroups[0]);
        });
        return describe("after initial load", function() {
          it("should have a kind", function() {
            return expect(this.ag.get('kind')).toEqual("ACAS doc for batches");
          });
          it("should have a code ", function() {
            return expect(this.ag.get('codeName')).toEqual("AG-00037424");
          });
          it("should have labels", function() {
            return expect(this.ag.get('lsLabels').length).toEqual(0);
          });
          it("should have states ", function() {
            return expect(this.ag.get('lsStates').length).toEqual(3);
          });
          it("should have states with kind ", function() {
            return expect(this.ag.get('lsStates').at(0).get('lsKind')).toEqual("Document for Batch");
          });
          it("states should have values", function() {
            return expect(this.ag.get('lsStates').at(0).get('lsValues').at(0).get('lsKind')).toEqual("annotation");
          });
          return it("states should have ignored to be false", function() {
            return expect(this.ag.get('lsStates').at(0).get('lsValues').at(0).get('ignored')).toBeFalsy();
          });
        });
      });
    });
  });

}).call(this);
