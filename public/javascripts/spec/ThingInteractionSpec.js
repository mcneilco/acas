(function() {
  describe('Thing Interaction testing', function() {
    describe("First Thing Itx model testing", function() {
      describe('When created from new', function() {
        beforeEach(function() {
          return this.fti = new FirstThingItx();
        });
        return describe("Existence and Defaults", function() {
          it("should be defined", function() {
            return expect(this.fti).toBeDefined();
          });
          it("should have a type", function() {
            return expect(this.fti.get('lsType')).toEqual("interaction");
          });
          it("should have a kind", function() {
            return expect(this.fti.get('lsKind')).toEqual("interaction");
          });
          it("should have a type and kind", function() {
            return expect(this.fti.get('lsTypeAndKind')).toEqual("interaction_interaction");
          });
          it("should have an empty state list", function() {
            expect(this.fti.get('lsStates').length).toEqual(0);
            return expect(this.fti.get('lsStates') instanceof StateList).toBeTruthy();
          });
          it("should have the recordedBy set to the logged in user", function() {
            return expect(this.fti.get('recordedBy')).toEqual(window.AppLaunchParams.loginUser.username);
          });
          it("should have a recordedDate set to now", function() {
            return expect(new Date(this.fti.get('recordedDate')).getHours()).toEqual(new Date().getHours());
          });
          return it("should have an empty firstLsThing attribute", function() {
            return expect(this.fti.get('firstLsThing')).toEqual({});
          });
        });
      });
      describe("When created from existing", function() {
        beforeEach(function() {
          return this.fti = new FirstThingItx(JSON.parse(JSON.stringify(window.thingInteractionTestJSON.firstLsThingItx1)));
        });
        return describe("after initial load", function() {
          it("should be defined", function() {
            return expect(this.fti).toBeDefined();
          });
          it("should have a type", function() {
            return expect(this.fti.get('lsType')).toEqual("incorporates");
          });
          it("should have a kind", function() {
            return expect(this.fti.get('lsKind')).toEqual("assembly_component");
          });
          it("should have a type and kind", function() {
            return expect(this.fti.get('lsTypeAndKind')).toEqual("incorporates_assembly_component");
          });
          it("should have a state list", function() {
            expect(this.fti.get('lsStates').length).toEqual(1);
            return expect(this.fti.get('lsStates') instanceof StateList).toBeTruthy();
          });
          it("should have a recordedBy set", function() {
            return expect(this.fti.get('recordedBy')).toEqual("egao");
          });
          it("should have a recordedDate", function() {
            return expect(this.fti.get('recordedDate')).toEqual(1375141504000);
          });
          return it("should have a firstLsThing attribute", function() {
            return expect(this.fti.get('firstLsThing').codeName).toEqual("A000001");
          });
        });
      });
      return describe("other features", function() {
        beforeEach(function() {
          return this.fti = new FirstThingItx();
        });
        it("should be reformatted before being saved", function() {
          this.fti.reformatBeforeSaving();
          return expect(this.fti.get('attributes')).toBeUndefined();
        });
        return it("should be able to set an Itx thing", function() {
          var thingToAdd;
          thingToAdd = {
            codeName: "T000001",
            id: 1,
            lsKind: "test",
            lsType: "component"
          };
          this.fti.setItxThing(thingToAdd);
          return expect(this.fti.get('firstLsThing').codeName).toEqual("T000001");
        });
      });
    });
    describe("Second Thing Itx model testing", function() {
      describe('When created from new', function() {
        beforeEach(function() {
          return this.sti = new SecondThingItx();
        });
        return describe("Existence and Defaults", function() {
          it("should be defined", function() {
            return expect(this.sti).toBeDefined();
          });
          it("should have a type", function() {
            return expect(this.sti.get('lsType')).toEqual("interaction");
          });
          it("should have a kind", function() {
            return expect(this.sti.get('lsKind')).toEqual("interaction");
          });
          it("should have a type and kind", function() {
            return expect(this.sti.get('lsTypeAndKind')).toEqual("interaction_interaction");
          });
          it("should have an empty state list", function() {
            expect(this.sti.get('lsStates').length).toEqual(0);
            return expect(this.sti.get('lsStates') instanceof StateList).toBeTruthy();
          });
          it("should have the recordedBy set to the logged in user", function() {
            return expect(this.sti.get('recordedBy')).toEqual(window.AppLaunchParams.loginUser.username);
          });
          it("should have a recordedDate set to now", function() {
            return expect(new Date(this.sti.get('recordedDate')).getHours()).toEqual(new Date().getHours());
          });
          return it("should have an empty secondLsThing attribute", function() {
            return expect(this.sti.get('secondLsThing')).toEqual({});
          });
        });
      });
      describe("When created from existing", function() {
        beforeEach(function() {
          return this.sti = new SecondThingItx(JSON.parse(JSON.stringify(window.thingInteractionTestJSON.secondLsThingItx1)));
        });
        return describe("after initial load", function() {
          it("should be defined", function() {
            return expect(this.sti).toBeDefined();
          });
          it("should have a type", function() {
            return expect(this.sti.get('lsType')).toEqual("incorporates");
          });
          it("should have a kind", function() {
            return expect(this.sti.get('lsKind')).toEqual("assembly_component");
          });
          it("should have a type and kind", function() {
            return expect(this.sti.get('lsTypeAndKind')).toEqual("incorporates_assembly_component");
          });
          it("should have a state list", function() {
            expect(this.sti.get('lsStates').length).toEqual(1);
            return expect(this.sti.get('lsStates') instanceof StateList).toBeTruthy();
          });
          it("should have a recordedBy set", function() {
            return expect(this.sti.get('recordedBy')).toEqual("egao");
          });
          it("should have a recordedDate", function() {
            return expect(this.sti.get('recordedDate')).toEqual(1375141504000);
          });
          return it("should have a secondLsThing attribute", function() {
            return expect(this.sti.get('secondLsThing').codeName).toEqual("W000001");
          });
        });
      });
      return describe("other features", function() {
        beforeEach(function() {
          return this.sti = new SecondThingItx();
        });
        it("should be reformatted before being saved", function() {
          this.sti.reformatBeforeSaving();
          return expect(this.sti.get('attributes')).toBeUndefined();
        });
        return it("should be able to set an Itx thing", function() {
          var thingToAdd;
          thingToAdd = {
            codeName: "T000001",
            id: 1,
            lsKind: "test",
            lsType: "component"
          };
          this.sti.setItxThing(thingToAdd);
          return expect(this.sti.get('secondLsThing').codeName).toEqual("T000001");
        });
      });
    });
    describe("FirstLsThingItxList testing", function() {
      describe('When created from new', function() {
        beforeEach(function() {
          return this.fltil = new FirstLsThingItxList();
        });
        return describe("existence tests", function() {
          return it("should be defined", function() {
            return expect(this.fltil).toBeDefined();
          });
        });
      });
      return describe("when created from existing", function() {
        beforeEach(function() {
          return this.fltil = new FirstLsThingItxList(JSON.parse(JSON.stringify(window.thingInteractionTestJSON.firstLsThingItxList)));
        });
        return describe("get or create itx", function() {
          it("should be able to get an itx by type and kind", function() {
            var firstThingItxList;
            firstThingItxList = this.fltil.getItxByTypeAndKind("incorporates", "assembly_component");
            return expect(firstThingItxList.length).toEqual(3);
          });
          return it("should be able to create an itx by type and kind", function() {
            var firstThingItx;
            firstThingItx = this.fltil.createItxByTypeAndKind("instantiates", "batch_parent");
            expect(firstThingItx.get('lsType')).toEqual("instantiates");
            return expect(firstThingItx.get('lsKind')).toEqual("batch_parent");
          });
        });
      });
    });
    return describe("SecondLsThingItxList testing", function() {
      describe('When created from new', function() {
        beforeEach(function() {
          return this.sltil = new SecondLsThingItxList();
        });
        return describe("existence tests", function() {
          return it("should be defined", function() {
            return expect(this.sltil).toBeDefined();
          });
        });
      });
      return describe("when created from existing", function() {
        beforeEach(function() {
          return this.sltil = new SecondLsThingItxList(JSON.parse(JSON.stringify(window.thingInteractionTestJSON.secondLsThingItxList)));
        });
        return describe("get or create itx", function() {
          it("should be able to get an itx by type and kind", function() {
            var secondThingItxList;
            secondThingItxList = this.sltil.getItxByTypeAndKind("incorporates", "assembly_component");
            return expect(secondThingItxList.length).toEqual(3);
          });
          return it("should be able to create an itx by type and kind", function() {
            var secondThingItx;
            secondThingItx = this.sltil.createItxByTypeAndKind("instantiates", "batch_parent");
            expect(secondThingItx.get('lsType')).toEqual("instantiates");
            return expect(secondThingItx.get('lsKind')).toEqual("batch_parent");
          });
        });
      });
    });
  });

}).call(this);
