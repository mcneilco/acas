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
    describe("AnalysisGroupState model testing", function() {
      describe("when created empty", function() {
        beforeEach(function() {
          return this.ags = new AnalysisGroupState();
        });
        it("Class should exist", function() {
          return expect(this.ags).toBeDefined();
        });
        return it("should have defaults", function() {
          return expect(this.ags.get('analysisGroupValues') instanceof AnalysisGroupValueList).toBeTruthy();
        });
      });
      return describe("When loaded from state json", function() {
        beforeEach(function() {
          return this.ags = new AnalysisGroupState(window.experimentServiceTestJSON.savedExperimentWithTreatmentGroup.analysisGroups[0].analysisGroupStates[0]);
        });
        return describe("after initial load", function() {
          it("state should have kind ", function() {
            return expect(this.ags.get('stateKind')).toEqual("Document for Batch");
          });
          it("state should have values", function() {
            expect(this.ags.get('analysisGroupValues') instanceof AnalysisGroupValueList).toBeTruthy();
            return expect(this.ags.get('analysisGroupValues').length).toEqual(3);
          });
          it("state should have populated value", function() {
            return expect(this.ags.get('analysisGroupValues').at(0).get('valueKind')).toEqual("annotation");
          });
          return it("should return requested value", function() {
            var values;
            values = this.ags.getValuesByTypeAndKind("codeValue", "batch code");
            expect(values.length).toEqual(1);
            return expect(values[0].get('codeValue')).toEqual("CMPD_1112");
          });
        });
      });
    });
    return describe("AnalysisGroup model testing", function() {
      describe("when created empty", function() {
        beforeEach(function() {
          return this.ag = new AnalysisGroup();
        });
        return describe("defaults", function() {
          it('Should have an empty label list', function() {
            expect(this.ag.get('analysisGroupLabels').length).toEqual(0);
            return expect(this.ag.get('analysisGroupLabels') instanceof LabelList).toBeTruthy();
          });
          it('Should have an empty state list', function() {
            expect(this.ag.get('analysisGroupStates').length).toEqual(0);
            return expect(this.ag.get('analysisGroupStates') instanceof AnalysisGroupStateList).toBeTruthy();
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
            return expect(this.ag.get('analysisGroupLabels').length).toEqual(0);
          });
          it("should have states ", function() {
            return expect(this.ag.get('analysisGroupStates').length).toEqual(3);
          });
          it("should have states with kind ", function() {
            return expect(this.ag.get('analysisGroupStates').at(0).get('stateKind')).toEqual("Document for Batch");
          });
          return it("states should have values", function() {
            return expect(this.ag.get('analysisGroupStates').at(0).get('analysisGroupValues').at(0).get('valueKind')).toEqual("annotation");
          });
        });
      });
    });
  });

}).call(this);
