(function() {
  beforeEach(function() {
    return this.fixture = $.clone($("#fixture").get(0));
  });

  afterEach(function() {
    $("#fixture").remove();
    return $("body").append($(this.fixture));
  });

  describe("Curve Curator Module testing", function() {
    describe("Curve Model testing", function() {
      beforeEach(function() {
        return this.curve = new Curve();
      });
      return describe("basic plumbing tests", function() {
        it("should have model defined", function() {
          return expect(Curve).toBeDefined();
        });
        return it("should have defaults", function() {
          expect(this.curve.get("curveid")).toEqual("");
          expect(this.curve.get("status")).toEqual("pass");
          return expect(this.curve.get("category")).toEqual("sigmoid");
        });
      });
    });
    describe("Curve List Model testing", function() {
      beforeEach(function() {
        this.curveList = new CurveList();
        return this.curvesFetched = false;
      });
      describe("basic plumbing tests", function() {
        return it("should have model defined", function() {
          return expect(CurveList).toBeDefined();
        });
      });
      return describe("get data from server", function() {
        return it("should return the curves", function() {
          var _this = this;

          runs(function() {
            var _this = this;

            this.curveList.setExperimentCode("EXPT-00000018");
            return this.curveList.fetch({
              success: function() {
                return _this.curvesFetched = true;
              }
            });
          });
          waitsFor(function() {
            return _this.curvesFetched;
          }, 200);
          return runs(function() {
            return expect(this.curveList.length).toBeGreaterThan(0);
          });
        });
      });
    });
    describe("Curve Summary Controller tests", function() {
      beforeEach(function() {
        this.curve = new Curve(window.curveCuratorTestJSON.curveStubs[0]);
        this.csc = new CurveSummaryController({
          el: this.fixture,
          model: this.curve
        });
        return this.csc.render();
      });
      describe("basic plumbing", function() {
        it("should have controller defined", function() {
          return expect(CurveSummaryController).toBeDefined();
        });
        it("should load template", function() {
          return expect(this.csc.$('.bv_thumbnail').length).toEqual(1);
        });
        return it(" should have a default tag name", function() {
          return expect(this.csc.tagName).toEqual('div');
        });
      });
      describe("rendering thumbnail", function() {
        return it("should have img src attribute set", function() {
          return expect(this.csc.$('.bv_thumbnail').attr('src')).toContain("90807_AG-00000026");
        });
      });
      return describe("selection", function() {
        return it("should show selected when clicked", function() {
          this.csc.$el.click();
          return expect(this.csc.$el.hasClass('selected')).toBeTruthy();
        });
      });
    });
    describe("Curve Summary List Controller tests", function() {
      beforeEach(function() {
        this.curves = new CurveList(window.curveCuratorTestJSON.curveStubs);
        this.cslc = new CurveSummaryListController({
          el: this.fixture,
          collection: this.curves
        });
        return this.cslc.render();
      });
      describe("basic plumbing", function() {
        it("should have controller defined", function() {
          return expect(CurveSummaryListController).toBeDefined();
        });
        return it("should load template", function() {
          return expect(this.cslc.$('.bv_curveSummaries').length).toEqual(1);
        });
      });
      describe("summary rendering", function() {
        return it("should create summary divs", function() {
          return expect(this.cslc.$('.bv_curveSummary').length).toBeGreaterThan(0);
        });
      });
      return describe("user thumbnail selection", function() {
        beforeEach(function() {
          return this.cslc.$('.bv_curveSummaries .bv_curveSummary').eq(0).click();
        });
        it("should highlight selected row", function() {
          return expect(this.cslc.$('.bv_curveSummaries .bv_curveSummary').eq(0).hasClass('selected')).toBeTruthy();
        });
        it("should select other row when other row is selected", function() {
          this.cslc.$('.bv_curveSummaries .bv_curveSummary').eq(1).click();
          return expect(this.cslc.$('.bv_curveSummaries .bv_curveSummary').eq(1).hasClass('selected')).toBeTruthy();
        });
        return it("should clear selected when another row is selected", function() {
          this.cslc.$('.bv_curveSummaries .bv_curveSummary').eq(1).click();
          return expect(this.cslc.$('.bv_curveSummaries .bv_curveSummary').eq(0).hasClass('selected')).toBeFalsy();
        });
      });
    });
    describe("Curve Editor Controller tests", function() {
      describe("when created with no model", function() {
        beforeEach(function() {
          this.cec = new CurveEditorController({
            el: this.fixture
          });
          return this.cec.render();
        });
        describe("basic plumbing", function() {
          it("should have controller defined", function() {
            return expect(CurveEditorController).toBeDefined();
          });
          it("should load template", function() {
            return expect(this.cec.$('.bv_shinyContainer').length).toEqual(1);
          });
          return it("should show no curve selected", function() {
            return expect(this.cec.$('.bv_shinyContainer').html()).toContain("No Curve Selected");
          });
        });
        return describe("when new model set", function() {
          return it("should set the iframe src", function() {
            var mdl;

            mdl = new Curve(window.curveCuratorTestJSON.curveStubs[0]);
            this.cec.setModel(mdl);
            return expect(this.cec.$('.bv_shinyContainer').attr('src')).toContain("90807_AG-00000026");
          });
        });
      });
      return describe("when created with populated model", function() {
        beforeEach(function() {
          this.curve = new Curve(window.curveCuratorTestJSON.curveStubs[0]);
          this.cec = new CurveEditorController({
            el: this.fixture,
            model: this.curve
          });
          return this.cec.render();
        });
        return describe("rendering editor", function() {
          return it("should have iframe src attribute set", function() {
            return expect(this.cec.$('.bv_shinyContainer').attr('src')).toContain("90807_AG-00000026");
          });
        });
      });
    });
    return describe("Curve Curator Controller tests", function() {
      beforeEach(function() {
        this.ccc = new CurveCuratorController({
          el: this.fixture
        });
        return this.ccc.render();
      });
      describe("basic plumbing", function() {
        it("should have controller defined", function() {
          return expect(CurveCuratorController).toBeDefined();
        });
        it("should load template", function() {
          return expect(this.ccc.$('.bv_curveList').length).toEqual(1);
        });
        return it("should load template", function() {
          return expect(this.ccc.$('.bv_curveEditor').length).toEqual(1);
        });
      });
      describe("curve fetching", function() {
        return it("should fetch curves from expt code", function() {
          runs(function() {
            return this.ccc.getCurvesFromExperimentCode("EXPT-00000018");
          });
          waits(200);
          return runs(function() {
            return expect(this.ccc.collection.length).toBeGreaterThan(0);
          });
        });
      });
      return describe("should initialize and render sub controllers", function() {
        beforeEach(function() {
          runs(function() {
            return this.ccc.getCurvesFromExperimentCode("EXPT-00000018");
          });
          return waitsFor(function() {
            return this.ccc.collection.length > 0;
          });
        });
        it("should show the curve summary list", function() {
          return runs(function() {
            return expect(this.ccc.$('.bv_curveSummary').length).toBeGreaterThan(0);
          });
        });
        it("should select the first curve in the list", function() {
          return runs(function() {
            return expect(this.ccc.$('.bv_curveSummaries .bv_curveSummary').eq(0).hasClass('selected')).toBeTruthy();
          });
        });
        it("should show the curve editor", function() {
          return runs(function() {
            return expect(this.ccc.$('.bv_shinyContainer').length).toBeGreaterThan(0);
          });
        });
        return describe("When new thumbnail selected", function() {
          beforeEach(function() {
            return runs(function() {
              return this.ccc.$('.bv_curveSummaries .bv_curveSummary').eq(0).click();
            });
          });
          return it("should set the curve editor iframe src", function() {
            return runs(function() {
              return expect(this.ccc.$('.bv_shinyContainer').attr('src')).toContain("90807_AG-00000026");
            });
          });
        });
      });
    });
  });

}).call(this);
