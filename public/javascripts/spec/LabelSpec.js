(function() {
  beforeEach(function() {
    return this.fixture = $.clone($("#fixture").get(0));
  });

  afterEach(function() {
    $("#fixture").remove();
    return $("body").append($(this.fixture));
  });

  describe("Label module testing", function() {
    describe("Label model test", function() {
      beforeEach(function() {
        return this.el = new Label();
      });
      return describe("Basic new label", function() {
        it("Class should exist", function() {
          return expect(this.el).toBeDefined();
        });
        return it("should have defaults", function() {
          expect(this.el.get('labelType')).toEqual('name');
          expect(this.el.get('labelKind')).toEqual('');
          expect(this.el.get('labelText')).toEqual('');
          expect(this.el.get('ignored')).toEqual(false);
          expect(this.el.get('preferred')).toEqual(false);
          expect(this.el.get('recordedDate')).toEqual('');
          expect(this.el.get('recordedBy')).toEqual('');
          expect(this.el.get('physicallyLabled')).toEqual(false);
          return expect(this.el.get('imageFile')).toBeNull();
        });
      });
    });
    return describe("Label List testing", function() {
      describe("label list features when loaded from existing list", function() {
        beforeEach(function() {
          return this.ell = new LabelList(window.experimentServiceTestJSON.experimentLabels);
        });
        it("Class should exist", function() {
          return expect(this.ell).toBeDefined();
        });
        it("Class should have labels", function() {
          return expect(this.ell.length).toEqual(4);
        });
        it("Should return current (not ignored) labels", function() {
          return expect(this.ell.getCurrent().length).toEqual(3);
        });
        it("Should return not ignored name labels", function() {
          return expect(this.ell.getNames().length).toEqual(2);
        });
        it("Should return not ignored preferred labels", function() {
          return expect(this.ell.getPreferred().length).toEqual(1);
        });
        describe("best label picker", function() {
          it("Should select newest preferred label when there are preferred labels", function() {
            return expect(this.ell.pickBestLabel().get('labelText')).toEqual("FLIPR target A biochemical");
          });
          it("Should select newest name when there are no preferred labels but there are names", function() {
            this.ell2 = new LabelList(window.experimentServiceTestJSON.experimentLabelsNoPreferred);
            return expect(this.ell2.pickBestLabel().get('labelText')).toEqual("FLIPR target A biochemical with additional name awesomness");
          });
          return it("Should select newest label when there are no preferred labels and no names", function() {
            this.ell2 = new LabelList(window.experimentServiceTestJSON.experimentLabelsNoPreferredNoNames);
            return expect(this.ell2.pickBestLabel().get('labelText')).toEqual("AAABBD13343434");
          });
        });
        describe("best name picker", function() {
          return it("Should select newest preferred name label", function() {
            return expect(this.ell.pickBestName().get('labelText')).toEqual("FLIPR target A biochemical");
          });
        });
        return describe("setBestName functionality", function() {
          return it("should update existing unsaved label when best name changed", function() {
            var oldBestId;

            oldBestId = this.ell.pickBestLabel().id;
            this.ell.setBestName(new Label({
              labelText: "new best name",
              recordedBy: "fmcneil",
              recordedDate: 3362435677000
            }));
            expect(this.ell.pickBestLabel().get('labelText')).toEqual("new best name");
            expect(this.ell.pickBestLabel().isNew).toBeTruthy();
            return expect(this.ell.get(oldBestId).get('ignored')).toBeTruthy();
          });
        });
      });
      return describe("label list features when new and empty", function() {
        beforeEach(function() {
          return this.ell = new LabelList();
        });
        it("Class should have labels", function() {
          return expect(this.ell.length).toEqual(0);
        });
        return describe("setBestName functionality", function() {
          beforeEach(function() {
            return this.ell.setBestName(new Label({
              labelText: "best name",
              recordedBy: "jmcneil",
              recordedDate: 2362435677000
            }));
          });
          it("should add new label when best name added for first time", function() {
            expect(this.ell.pickBestLabel().get('labelText')).toEqual("best name");
            expect(this.ell.pickBestLabel().get('recordedBy')).toEqual("jmcneil");
            return expect(this.ell.pickBestLabel().get('recordedDate')).toEqual(2362435677000);
          });
          return it("should update existing unsaved label when best name changed", function() {
            this.ell.setBestName(new Label({
              labelText: "new best name",
              recordedBy: "fmcneil",
              recordedDate: 3362435677000
            }));
            expect(this.ell.length).toEqual(1);
            expect(this.ell.pickBestLabel().get('labelText')).toEqual("new best name");
            expect(this.ell.pickBestLabel().get('recordedBy')).toEqual("fmcneil");
            return expect(this.ell.pickBestLabel().get('recordedDate')).toEqual(3362435677000);
          });
        });
      });
    });
  });

}).call(this);
