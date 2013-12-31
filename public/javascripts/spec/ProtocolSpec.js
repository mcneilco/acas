(function() {
  beforeEach(function() {
    return this.fixture = $.clone($("#fixture").get(0));
  });

  afterEach(function() {
    $("#fixture").remove();
    return $("body").append($(this.fixture));
  });

  describe("Protocol module testing", function() {
    return describe("Protocol model testing", function() {
      describe("When loaded from new", function() {
        beforeEach(function() {
          return this.prot = new Protocol();
        });
        return describe("Defaults", function() {
          it('Should have an empty label list', function() {
            return expect(this.prot.get('lsLabels').length).toEqual(0);
          });
          it('Should have an empty state list', function() {
            return expect(this.prot.get('lsStates').length).toEqual(0);
          });
          it('Should have an empty scientist', function() {
            return expect(this.prot.get('recordedBy')).toEqual("");
          });
          return it('Should have an empty short description', function() {
            return expect(this.prot.get('shortDescription')).toEqual("");
          });
        });
      });
      describe("when loaded from existing", function() {
        beforeEach(function() {
          return this.prot = new Protocol(window.protocolServiceTestJSON.fullSavedProtocol);
        });
        return describe("after initial load", function() {
          it("should have a kind", function() {
            return expect(this.prot.get('lsKind')).toEqual("default");
          });
          it("should have a code ", function() {
            return expect(this.prot.get('codeName')).toEqual("PROT-00000001");
          });
          it("should have the shortDescription set", function() {
            return expect(this.prot.get('shortDescription')).toEqual(window.protocolServiceTestJSON.fullSavedProtocol.shortDescription);
          });
          it("should have labels", function() {
            return expect(this.prot.get('lsLabels').length).toEqual(window.protocolServiceTestJSON.fullSavedProtocol.lsLabels.length);
          });
          it("should have labels", function() {
            return expect(this.prot.get('lsLabels').at(0).get('lsKind')).toEqual("protocol name");
          });
          it("should have states ", function() {
            return expect(this.prot.get('lsStates').length).toEqual(window.protocolServiceTestJSON.fullSavedProtocol.lsStates.length);
          });
          it("should have states with kind ", function() {
            return expect(this.prot.get('lsStates').at(0).get('lsKind')).toEqual("experiment controls");
          });
          return it("states should have values", function() {
            return expect(this.prot.get('lsStates').at(0).get('lsValues').at(0).get('lsKind')).toEqual("data analysis parameters");
          });
        });
      });
      describe("when loaded from stub", function() {
        beforeEach(function() {
          this.prot = new Protocol(window.protocolServiceTestJSON.stubSavedProtocol[0]);
          return runs(function() {
            var _this = this;

            this.fetchReturned = false;
            return this.prot.fetch({
              success: function() {
                return _this.fetchReturned = true;
              }
            });
          });
        });
        describe("utility functions", function() {
          return it("should know it's a stub", function() {
            return expect(this.prot.isStub()).toBeTruthy();
          });
        });
        return describe("get full object", function() {
          it("should have raw labels when fetched", function() {
            waitsFor(function() {
              return this.fetchReturned;
            });
            return runs(function() {
              return expect(this.prot.has('lsLabels')).toBeTruthy();
            });
          });
          return it("should have raw labels converted to LabelList when fetched", function() {
            waitsFor(function() {
              return this.fetchReturned;
            });
            return runs(function() {
              return expect(this.prot.get('lsLabels') instanceof LabelList).toBeTruthy();
            });
          });
        });
      });
      describe("model composite component conversion", function() {
        beforeEach(function() {
          runs(function() {
            var _this = this;

            this.saveSucessful = false;
            this.saveComplete = false;
            this.prot = new Protocol(window.protocolServiceTestJSON);
            this.prot.set({
              shortDescription: "new description"
            });
            this.prot.on('sync', function() {
              _this.saveSucessful = true;
              return _this.saveComplete = true;
            });
            this.prot.on('invalid', function() {
              return _this.saveComplete = true;
            });
            return this.prot.save();
          });
          return waitsFor(function() {
            return this.saveComplete === true;
          }, 500);
        });
        it("should return from sync, not invalid", function() {
          return runs(function() {
            return expect(this.saveSucessful).toBeTruthy();
          });
        });
        it("should convert labels array to label list", function() {
          return runs(function() {
            expect(this.prot.get('lsLabels') instanceof LabelList).toBeTruthy();
            return expect(this.prot.get('lsLabels').length).toBeGreaterThan(0);
          });
        });
        return it("should convert state array to state list", function() {
          return runs(function() {
            expect(this.prot.get('lsStates') instanceof StateList).toBeTruthy();
            return expect(this.prot.get('lsStates').length).toBeGreaterThan(0);
          });
        });
      });
      return describe("model change propogation", function() {
        it("should trigger change when label changed", function() {
          runs(function() {
            var _this = this;

            this.prot = new Protocol();
            this.protocolChanged = false;
            this.prot.get('lsLabels').setBestName(new Label({
              labelKind: "protocol name",
              labelText: "test label",
              recordedBy: this.prot.get('recordedBy'),
              recordedDate: this.prot.get('recordedDate')
            }));
            this.prot.on('change', function() {
              return _this.protocolChanged = true;
            });
            this.protocolChanged = false;
            return this.prot.get('lsLabels').setBestName(new Label({
              labelKind: "protocol name",
              labelText: "new label",
              recordedBy: this.prot.get('recordedBy'),
              recordedDate: this.prot.get('recordedDate')
            }));
          });
          waitsFor(function() {
            return this.protocolChanged;
          }, 500);
          return runs(function() {
            return expect(this.protocolChanged).toBeTruthy();
          });
        });
        return it("should trigger change when value changed in state", function() {
          runs(function() {
            var _this = this;

            this.prot = new Protocol(window.protocolServiceTestJSON.fullSavedProtocol);
            this.protocolChanged = false;
            this.prot.on('change', function() {
              return _this.protocolChanged = true;
            });
            return this.prot.get('lsStates').at(0).get('lsValues').at(0).set({
              lsKind: 'fred'
            });
          });
          waitsFor(function() {
            return this.protocolChanged;
          }, 500);
          return runs(function() {
            return expect(this.protocolChanged).toBeTruthy();
          });
        });
      });
    });
  });

}).call(this);
