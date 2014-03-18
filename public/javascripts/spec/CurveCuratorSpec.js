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
          expect(this.curve.get('curveid')).toEqual("");
          expect(this.curve.get('algorithmApproved')).toBeNull();
          expect(this.curve.get('userApproved')).toBeNull();
          return expect(this.curve.get('category')).toEqual("");
        });
      });
    });
    describe("Curve List Model testing", function() {
      beforeEach(function() {
        this.curveList = new CurveList(window.curveCuratorTestJSON.curveCuratorThumbs.curves);
        return this.curvesFetched = false;
      });
      describe("basic plumbing tests", function() {
        return it("should have model defined", function() {
          return expect(CurveList).toBeDefined();
        });
      });
      return describe("making category list", function() {
        return it("should return a list of categories", function() {
          var categories;
          categories = this.curveList.getCategories();
          expect(categories.length).toEqual(3);
          return expect(categories instanceof Backbone.Collection).toBeTruthy();
        });
      });
    });
    describe("CurveCurationSetModel testing", function() {
      beforeEach(function() {
        this.ccs = new CurveCurationSet();
        return this.fetchReturn = false;
      });
      describe("basic plumbing tests", function() {
        it("should have model defined", function() {
          return expect(CurveCurationSet).toBeDefined();
        });
        return it("should have defaults", function() {
          expect(this.ccs.get('sortOptions') instanceof Backbone.Collection).toBeTruthy();
          return expect(this.ccs.get('curves') instanceof CurveList).toBeTruthy();
        });
      });
      return describe("curve fetching", function() {
        beforeEach(function() {
          runs(function() {
            this.ccs.on('sync', (function(_this) {
              return function() {
                return _this.fetchReturn = true;
              };
            })(this));
            this.ccs.setExperimentCode("EXPT-00000018");
            return this.ccs.fetch();
          });
          return waitsFor((function(_this) {
            return function() {
              return _this.fetchReturn;
            };
          })(this), 200);
        });
        it("should fetch curves set from expt code", function() {
          return runs(function() {
            return expect(this.ccs.get('curves').length).toBeGreaterThan(0);
          });
        });
        it("curves should be converted to CurveList", function() {
          return runs(function() {
            return expect(this.ccs.get('curves') instanceof CurveList).toBeTruthy();
          });
        });
        return it("sortOptions should be converted to Collection", function() {
          return runs(function() {
            return expect(this.ccs.get('sortOptions') instanceof Backbone.Collection).toBeTruthy();
          });
        });
      });
    });
    describe("Curve Summary Controller tests", function() {
      beforeEach(function() {
        this.curve = new Curve(window.curveCuratorTestJSON.curveCuratorThumbs.curves[0]);
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
      describe("selection", function() {
        return it("should show selected when clicked", function() {
          this.csc.$el.click();
          return expect(this.csc.$el.hasClass('selected')).toBeTruthy();
        });
      });
      describe("algorithm approved display", function() {
        it("should show approved when algorithm approved", function() {
          expect(this.csc.$('.bv_thumbnail').hasClass('algorithmApproved')).toBeTruthy();
          return expect(this.csc.$('.bv_thumbnail').hasClass('algorithmNotApproved')).toBeFalsy();
        });
        return it("should show not approved when algorithm not approved", function() {
          this.csc.model.set({
            algorithmApproved: false
          });
          this.csc.render();
          expect(this.csc.$('.bv_thumbnail').hasClass('algorithmNotApproved')).toBeTruthy();
          return expect(this.csc.$('.bv_thumbnail').hasClass('algorithmApproved')).toBeFalsy();
        });
      });
      return xdescribe("user approved display", function() {
        it("should show thumbs up when user approved", function() {
          console.log(this.csc.$('.bv_thumbsUp'));
          expect(this.csc.$('.bv_thumbsUp')).toBeVisible();
          return expect(this.csc.$('.bv_thumbsDown')).toBeHidden();
        });
        it("should show thumbs down when not user approved", function() {
          this.csc.model.set({
            userApproved: false
          });
          this.csc.render();
          expect(this.csc.$('.bv_thumbsDown')).toBeVisible();
          return expect(this.csc.$('.bv_thumbsUp')).toBeHidden();
        });
        return it("should hide thumbs up and thumbs down when no user input", function() {
          this.csc.model.set({
            userApproved: null
          });
          this.csc.render();
          expect(this.csc.$('.bv_thumbsUp')).toBeHidden();
          return expect(this.csc.$('.bv_thumbsDown')).toBeHidden();
        });
      });
    });
    describe("Curve Summary List Controller tests", function() {
      beforeEach(function() {
        this.curves = new CurveList(window.curveCuratorTestJSON.curveCuratorThumbs.curves);
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
          return expect(this.cslc.$('.bv_curveSummary').length).toEqual(9);
        });
      });
      describe("user thumbnail selection", function() {
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
      return describe("filtering", function() {
        it("should only show sigmoid when requested", function() {
          this.cslc.filter('sigmoid');
          return expect(this.cslc.$('.bv_curveSummary').length).toEqual(3);
        });
        return it("should show all when requested", function() {
          this.cslc.filter('sigmoid');
          this.cslc.filter('all');
          return expect(this.cslc.$('.bv_curveSummary').length).toEqual(9);
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
            mdl = new Curve(window.curveCuratorTestJSON.curveCuratorThumbs.curves[0]);
            this.cec.setModel(mdl);
            return expect(this.cec.$('.bv_shinyContainer').attr('src')).toContain("90807_AG-00000026");
          });
        });
      });
      return describe("when created with populated model", function() {
        beforeEach(function() {
          this.curve = new Curve(window.curveCuratorTestJSON.curveCuratorThumbs.curves[0]);
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
      return describe("should initialize and render sub controllers", function() {
        beforeEach(function() {
          runs(function() {
            return this.ccc.getCurvesFromExperimentCode("EXPT-00000018");
          });
          return waitsFor(function() {
            return this.ccc.model.get('curves').length > 0;
          });
        });
        describe("post fetch display", function() {
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
          return it("should show the curve editor", function() {
            return runs(function() {
              return expect(this.ccc.$('.bv_shinyContainer').length).toBeGreaterThan(0);
            });
          });
        });
        describe("sort option select display", function() {
          it("sortOption select should populate with options", function() {
            return runs(function() {
              return expect(this.ccc.$('.bv_sortBy option').length).toEqual(5);
            });
          });
          it("sortOption select should make first option none", function() {
            return runs(function() {
              return expect(this.ccc.$('.bv_sortBy option:eq(0)').html()).toEqual("No Sort");
            });
          });
          it("should sort by ", function() {
            return runs(function() {
              this.ccc.$('.bv_sortBy').val('EC50');
              this.ccc.$('.bv_sortDirection').val('ascending');
              this.ccc.$('.bv_sortBy').change();
              return expect(this.ccc.$('.bv_curveSummaries .bv_curveSummary .bv_compoundCode:eq(0)').html()).toEqual("CMPD-0000009");
            });
          });
          return it("should sort by ", function() {
            return runs(function() {
              this.ccc.$('.bv_sortBy').val('EC50');
              this.ccc.$('.bv_sortDirection').val('descending');
              this.ccc.$('.bv_sortBy').change();
              return expect(this.ccc.$('.bv_curveSummaries .bv_curveSummary .bv_compoundCode:eq(0)').html()).toEqual("CMPD-0000004");
            });
          });
        });
        describe("filter option select display", function() {
          it("filterOption select should populate with options", function() {
            return runs(function() {
              return expect(this.ccc.$('.bv_filterBy option').length).toEqual(4);
            });
          });
          it("sortOption select should make first option all", function() {
            return runs(function() {
              return expect(this.ccc.$('.bv_filterBy option:eq(0)').html()).toEqual("Show All");
            });
          });
          return it("should only show sigmoid thumbnails when sigmoid selected", function() {
            return runs(function() {
              this.ccc.$('.bv_filterBy').val('sigmoid');
              this.ccc.$('.bv_filterBy').change();
              return expect(this.ccc.$('.bv_curveSummaries .bv_curveSummary').length).toEqual(3);
            });
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
