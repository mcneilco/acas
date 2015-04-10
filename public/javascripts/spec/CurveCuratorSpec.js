(function() {
  beforeEach(function() {});

  afterEach(function() {
    $("#fixture").remove();
    return $("body").append('<div id = "#fixture"></div>');
  });

  describe("Curve Curator Module testing", function() {
    describe("Curve Model testing", function() {
      beforeEach(function() {
        return this.curve = new Curve();
      });
      return describe("basic plumbing tests", function() {
        return it("should have model defined", function() {
          return expect(Curve).toBeDefined();
        });
      });
    });
    describe("Curve List Model testing", function() {
      beforeEach(function() {
        return this.curveList = new CurveList(window.curveCuratorTestJSON.curveCuratorThumbs.curves);
      });
      describe("basic plumbing tests", function() {
        return it("should have model defined", function() {
          return expect(CurveList).toBeDefined();
        });
      });
      describe("making category list", function() {
        return it("should return a list of categories", function() {
          var categories;
          categories = this.curveList.getCategories();
          expect(categories.length).toEqual(5);
          return expect(categories instanceof Backbone.Collection).toBeTruthy();
        });
      });
      describe("getting curve by curveid", function() {
        return it("should return a curve", function() {
          var curve;
          curve = this.curveList.getCurveByID("AG-00440011_6863");
          return expect(curve instanceof Curve);
        });
      });
      describe("getting curve index by curveid", function() {
        return it("should return a curve", function() {
          var curveIndex;
          curveIndex = this.curveList.getIndexByCurveID("AG-00440011_6863");
          return expect(curveIndex).toEqual(15);
        });
      });
      describe("updating a curve summary", function() {
        return it("should update curve summary", function() {
          var category, dirty, flagAlgorithm, flagUser, newCurveID, oldCurveID, originalCurve, updatedCurve;
          originalCurve = this.curveList.models[0];
          oldCurveID = originalCurve.get('curveid');
          newCurveID = originalCurve.get('curveid' + " test");
          dirty = !originalCurve.get('dirty');
          category = originalCurve.get('category' + " test");
          flagUser = originalCurve.get('flagUser' + " test");
          flagAlgorithm = originalCurve.get('flagAlgorithm' + " test");
          this.curveList.updateCurveSummary(oldCurveID, newCurveID, dirty, category, flagUser, flagAlgorithm);
          updatedCurve = this.curveList.models[0];
          expect(updatedCurve.get('curveid')).toEqual(newCurveID);
          expect(updatedCurve.get('dirty')).toEqual(dirty);
          expect(updatedCurve.get('category')).toEqual(category);
          expect(updatedCurve.get('flagUser')).toEqual(flagUser);
          return expect(updatedCurve.get('flagAlgorithm')).toEqual(flagAlgorithm);
        });
      });
      describe("updating dirty flag", function() {
        return it("should update dirty flag", function() {
          var dirty, originalCurve, updatedCurve;
          originalCurve = this.curveList.models[0];
          dirty = !originalCurve.get('dirty');
          this.curveList.updateDirtyFlag(originalCurve.get('curveid'), dirty);
          updatedCurve = this.curveList.models[0];
          return expect(updatedCurve.get('dirty')).toEqual(dirty);
        });
      });
      return describe("updating flag user", function() {
        return it("should update flag user", function() {
          var originalCurve, updatedCurve, userFlagStatus;
          originalCurve = this.curveList.models[0];
          userFlagStatus = originalCurve.get('userFlagStatus' + " test");
          this.curveList.updateUserFlagStatus(originalCurve.get('curveid'), userFlagStatus);
          updatedCurve = this.curveList.models[0];
          return expect(updatedCurve.get('userFlagStatus')).toEqual(userFlagStatus);
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
          el: $("#fixture"),
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
        it("should have img src attribute set", function() {
          return expect(this.csc.$('.bv_thumbnail').attr('src')).toContain("AG-00439996_6863");
        });
        return it("should show the compound code", function() {
          return expect(this.csc.$('.bv_compoundCode').html()).toEqual("CMPD-0000001-01A");
        });
      });
      describe("selection", function() {
        return it("should show selected when clicked", function() {
          this.csc.$('.bv_flagUser').click();
          return this.csc.$el.hasClass('selected');
        });
      });
      describe("algorithm approved display", function() {
        it("should show not approved when algorithm flagged", function() {
          this.csc.model.set({
            algorithmFlagStatus: "no fit"
          });
          expect(this.csc.$('.bv_fail')).toBeVisible();
          return expect(this.csc.$('.bv_pass')).toBeHidden();
        });
        return it("should show approved when algorithm not flagged ", function() {
          this.csc.model.set({
            algorithmFlagStatus: ""
          });
          this.csc.render();
          expect(this.csc.$('.bv_pass')).toBeVisible();
          return expect(this.csc.$('.bv_fail')).toBeHidden();
        });
      });
      describe("user flagged display", function() {
        it("should show thumbs up when user approved", function() {
          this.csc.model.set({
            userFlagStatus: "approved"
          });
          expect(this.csc.$('.bv_thumbsUp')).toBeVisible();
          return expect(this.csc.$('.bv_thumbsDown')).toBeHidden();
        });
        it("should show thumbs down when not user approved", function() {
          this.csc.model.set({
            userFlagStatus: "rejected"
          });
          this.csc.render();
          expect(this.csc.$('.bv_thumbsDown')).toBeVisible();
          return expect(this.csc.$('.bv_thumbsUp')).toBeHidden();
        });
        return it("should hide thumbs up and thumbs down when no user input", function() {
          this.csc.model.set({
            userFlagStatus: ""
          });
          this.csc.render();
          expect(this.csc.$('.bv_thumbsUp')).toBeHidden();
          expect(this.csc.$('.bv_thumbsDown')).toBeHidden();
          return expect(this.csc.$('.bv_na')).toBeVisible();
        });
      });
      return describe("user flagged curation", function() {
        it("should show flag user menu when flag user button is clicked", function() {
          this.csc.$('.bv_flagUser').click();
          return expect(this.csc.$('.bv_dropdown')).toBeVisible();
        });
        it("should update user flag when user selects reject dropdown menu item", function() {
          this.csc.model.set({
            userFlagStatus: ''
          });
          this.csc.$('.bv_flagUser').click();
          this.csc.$('.bv_userReject').click();
          waitsFor((function(_this) {
            return function() {
              return _this.csc.model.get('userFlagStatus') === "rejected";
            };
          })(this), 200);
          return runs((function(_this) {
            return function() {
              return expect(_this.csc.model.get('userFlagStatus')).toEqual("rejected");
            };
          })(this));
        });
        it("should update user flag when user selects approve dropdown menu item", function() {
          this.csc.model.set({
            flagUser: ''
          });
          this.csc.$('.bv_flagUser').click();
          this.csc.$('.bv_userApprove').click();
          waitsFor((function(_this) {
            return function() {
              return _this.csc.model.get('userFlagStatus') === "approved";
            };
          })(this), 200);
          return runs((function(_this) {
            return function() {
              return expect(_this.csc.model.get('userFlagStatus')).toEqual("approved");
            };
          })(this));
        });
        return it("should update user flag when user selects NA dropdown menu item", function() {
          this.csc.model.set({
            userFlagStatus: 'approved'
          });
          this.csc.$('.bv_flagUser').click();
          this.csc.$('.bv_userNA').click();
          waitsFor((function(_this) {
            return function() {
              return _this.csc.model.get('userFlagStatus') === "";
            };
          })(this), 200);
          return runs((function(_this) {
            return function() {
              return expect(_this.csc.model.get('userFlagStatus')).toEqual("");
            };
          })(this));
        });
      });
    });
    describe("Curve Summary List Controller tests", function() {
      beforeEach(function() {
        this.curves = new CurveList(window.curveCuratorTestJSON.curveCuratorThumbs.curves);
        this.cslc = new CurveSummaryListController({
          el: $("#fixture"),
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
          return expect(this.cslc.$('.bv_curveSummary').length).toEqual(18);
        });
      });
      describe("user thumbnail selection", function() {
        beforeEach(function() {
          return this.cslc.$('.bv_curveSummaries .bv_curveSummary .bv_group_thumbnail')[0].click();
        });
        it("should highlight selected row", function() {
          return expect(this.cslc.$('.bv_curveSummaries .bv_curveSummary').eq(0).hasClass('selected')).toBeTruthy();
        });
        it("should select other row when other row is selected", function() {
          this.cslc.$('.bv_curveSummaries .bv_curveSummary .bv_group_thumbnail')[1].click();
          return expect(this.cslc.$('.bv_curveSummaries .bv_curveSummary').eq(1).hasClass('selected')).toBeTruthy();
        });
        return it("should clear selected when another row is selected", function() {
          this.cslc.$('.bv_curveSummaries .bv_curveSummary .bv_group_thumbnail')[1].click();
          return expect(this.cslc.$('.bv_curveSummaries .bv_curveSummary').eq(0).hasClass('selected')).toBeFalsy();
        });
      });
      describe("filtering", function() {
        it("should only show Sigmoid when requested", function() {
          this.cslc.filter('sigmoid');
          return expect(this.cslc.$('.bv_curveSummary').length).toEqual(12);
        });
        return it("should show all when requested", function() {
          this.cslc.filter('sigmoid');
          this.cslc.filter('all');
          return expect(this.cslc.$('.bv_curveSummary').length).toEqual(18);
        });
      });
      return describe("sorting", function() {
        it("should show the lowest EC50 when requested", function() {
          this.cslc.sort('EC50', true);
          return expect(this.cslc.$('.bv_curveSummary:eq(0) .bv_compoundCode').html()).toEqual("CMPD-0000008-01A");
        });
        it("should show the highest EC50 when requested", function() {
          this.cslc.sort('EC50', false);
          return expect(this.cslc.$('.bv_curveSummary:eq(0) .bv_compoundCode').html()).toEqual("CMPD-0000011-01A");
        });
        return it("should show the first one when no sorting is requested", function() {
          this.cslc.sort('none');
          return expect(this.cslc.$('.bv_curveSummary:eq(0) .bv_compoundCode').html()).toEqual("CMPD-0000001-01A");
        });
      });
    });
    describe("Dose Response Plot Controller tests", function() {
      beforeEach(function() {
        this.drpc = new DoseResponsePlotController({
          el: $("#fixture")
        });
        return this.drpc.render();
      });
      describe("basic plumbing", function() {
        it("should have controller defined", function() {
          return expect(DoseResponsePlotController).toBeDefined();
        });
        return it("should show plot details not loaded when model is missing", function() {
          return expect($(this.drpc.el).html()).toContain("Plot data not loaded");
        });
      });
      return describe("when a model is set", function() {
        beforeEach(function() {
          this.drpc = new DoseResponsePlotController({
            model: new Backbone.Model(window.curveCuratorTestJSON.curveDetail.plotData),
            el: $("#fixture")
          });
          return this.drpc.render();
        });
        return describe("basic plot rendering", function() {
          it("should load the template", function() {
            return expect(this.drpc.$('.bv_plotWindow').length).toEqual(1);
          });
          it("should set the div id to a unique cid", function() {
            return expect(this.drpc.$('.bv_plotWindow').attr('id')).toEqual("bvID_plotWindow_" + this.drpc.model.cid);
          });
          it("should have rendered an svg", function() {
            expect(this.drpc.$('#bvID_plotWindow_' + this.drpc.model.cid)[0].innerHTML).toContain('<svg');
            return window.blah = this.drpc.$('#bvID_plotWindow_' + this.drpc.model.cid);
          });
          return it("should have a populated point list", function() {
            return expect(this.drpc.pointList.length).toBeGreaterThan(0);
          });
        });
      });
    });
    describe("Dose Response Knockout Panel Controller", function() {
      beforeEach(function() {
        this.kpc = new DoseResponseKnockoutPanelController({
          el: $("#fixture")
        });
        return this.kpc.render();
      });
      describe("basic plumbing", function() {
        it("should have controller defined", function() {
          return expect(DoseResponseKnockoutPanelController).toBeDefined();
        });
        it("should setup a cause pick list list", function() {
          return expect(this.kpc.knockoutReasonList).toBeDefined;
        });
        return it("should have a set of pick list models", function() {
          return expect(this.kpc.knockoutReasonList.models.length) > 1;
        });
      });
      return describe("should trigger event when ok button is clicked and return an observation", function() {
        beforeEach(function() {
          runs(function() {
            this.kpc.on('observationSelected', (function(_this) {
              return function(observation) {
                return _this.observationSelected = observation;
              };
            })(this));
            return this.kpc.show();
          });
          return waitsFor((function(_this) {
            return function() {
              return _this.kpc.$("option").length > 0;
            };
          })(this));
        });
        it("should return an observation when the ok button is clicked", function() {
          runs(function() {
            return $('.bv_doseResponseKnockoutPanelOKBtn').click();
          }, 1000);
          waitsFor((function(_this) {
            return function() {
              return _this.observationSelected != null;
            };
          })(this), 1000);
          return runs((function(_this) {
            return function() {
              return expect(_this.observationSelected).toEqual('knocked out');
            };
          })(this));
        });
        return it("should return a different value if the options is changed", function() {
          runs(function() {
            this.kpc.$('.bv_dataDictPicklist').val("knocked out");
            return this.kpc.$('.bv_doseResponseKnockoutPanelOKBtn').click();
          }, 1000);
          waitsFor((function(_this) {
            return function() {
              return _this.observationSelected != null;
            };
          })(this), 1000);
          return runs((function(_this) {
            return function() {
              return expect(_this.observationSelected).toEqual('knocked out');
            };
          })(this));
        });
      });
    });
    describe("Curve Editor Controller tests", function() {
      beforeEach(function() {
        this.cec = new CurveEditorController({
          el: $("#fixture")
        });
        return this.cec.render();
      });
      describe("basic plumbing", function() {
        it("should have controller defined", function() {
          return expect(this.cec).toBeDefined();
        });
        return it("should should show no curve selected when model is missing", function() {
          return expect($(this.cec.el).html()).toContain("No curve selected");
        });
      });
      return describe("when a model is set", function() {
        beforeEach(function() {
          this.curve = new CurveDetail(window.curveCuratorTestJSON.curveDetail);
          this.cec = new CurveEditorController({
            el: $("#fixture")
          });
          return this.cec.setModel(this.curve);
        });
        describe("basic result rendering", function() {
          it("should load template", function() {
            return expect(this.cec.$('.bv_reportedValues').length).toEqual(1);
          });
          it("should show the reported values", function() {
            return expect(this.cec.$('.bv_reportedValues').html()).toContain("slope");
          });
          it("should show the fitSummary", function() {
            return expect(this.cec.$('.bv_fitSummary').html()).toContain("Model&nbsp;fitted");
          });
          it("should show the parameterStdErrors", function() {
            return expect(this.cec.$('.bv_parameterStdErrors').html()).toContain("stdErr");
          });
          it("should show the curveErrors", function() {
            return expect(this.cec.$('.bv_curveErrors').html()).toContain("SSE");
          });
          return it("should show the category", function() {
            return expect(this.cec.$('.bv_category').html()).toContain("sigmoid");
          });
        });
        describe("dose response parameter controller", function() {
          it("should have a populated dose response parameter controller", function() {
            return expect(this.cec.$('.bv_analysisParameterForm')).toBeDefined();
          });
          it('should set the max_value to the number', function() {
            return expect(this.cec.$(".bv_max_value").val()).toEqual("101");
          });
          it('should show the inverse agonist mode', function() {
            return expect(this.cec.$('.bv_inverseAgonistMode').attr('checked')).toEqual('checked');
          });
          return it('should show parameter title as Fit Criteria', function() {
            return expect(this.cec.$('.bv_formTitle').html()).toEqual('Fit Criteria');
          });
        });
        describe("editing curve parameters should update the model", function() {
          return it("should update curve parameters if the max value is changed", function() {
            this.cec.$('.bv_max_value').val(200);
            this.cec.$('.bv_max_value').change();
            return expect(this.cec.model.get('fitSettings').get('max').get('value')).toEqual(200);
          });
        });
        describe("dose response plot", function() {
          it("should have a dose response plot controller", function() {
            return expect(this.cec.$('.bv_plotWindow')).toBeDefined();
          });
          return it("should have a dose response plot controller", function() {
            return expect(this.cec.$('.bv_plotWindow')).toBeDefined();
          });
        });
        return describe("when a curve fails to update from service", function() {
          it("should show an error", function() {});
          describe("editing curve parameters should update the model", function() {});
          return it("should update curve parameters if the max value is changed", function() {
            this.cec.$('.bv_max_value').val(200);
            this.cec.$('.bv_max_value').change();
            return expect(this.cec.model.get('fitSettings').get('max').get('value')).toEqual(200);
          });
        });
      });
    });
    return describe("Curve Curator Controller tests", function() {
      beforeEach(function() {
        this.ccc = new CurveCuratorController({
          el: $("#fixture")
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
      describe("should initialize and render sub controllers", function() {
        beforeEach(function() {
          runs(function() {
            return this.ccc.getCurvesFromExperimentCode("EXPT-00000018");
          });
          waitsFor(function() {
            return this.ccc.model.get('curves').length > 0;
          });
          return waits(200);
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
            waitsFor((function(_this) {
              return function() {
                return _this.ccc.$('.bv_reportedValues').length > 0;
              };
            })(this), 500);
            return runs(function() {
              return expect(this.ccc.$('.bv_reportedValues').length).toBeGreaterThan(0);
            });
          });
        });
        describe("sort option select display", function() {
          it("sortOption select should populate with options", function() {
            return runs(function() {
              return expect(this.ccc.$('.bv_sortBy option').length).toEqual(7);
            });
          });
          it("default sort option should be the first in the list from the server", function() {
            return runs(function() {
              expect(this.ccc.$('.bv_sortBy option:eq(0)').html()).toEqual("Compound Code");
              return expect(this.ccc.$('.bv_curveSummaries .bv_curveSummary .bv_compoundCode:eq(0)').html()).toEqual("CMPD-0000001-01A");
            });
          });
          it("should sort by ascending", function() {
            return runs(function() {
              this.ccc.$('.bv_sortDirection_descending').prop("checked", false);
              this.ccc.$('.bv_sortDirection_ascending').prop("checked", true);
              this.ccc.$('.bv_sortDirection_ascending').click();
              return expect(this.ccc.$('.bv_curveSummaries .bv_curveSummary .bv_compoundCode:eq(0)').html()).toEqual("CMPD-0000001-01A");
            });
          });
          it("should sort by descending", function() {
            return runs(function() {
              this.ccc.$('.bv_sortBy').val('EC50');
              this.ccc.$('.bv_sortDirection_descending').prop("checked", true);
              this.ccc.$('.bv_sortDirection_ascending').prop("checked", false);
              this.ccc.$('.bv_sortDirection_descending').click();
              return expect(this.ccc.$('.bv_curveSummaries .bv_curveSummary .bv_compoundCode:eq(0)').html()).toEqual("CMPD-0000011-01A");
            });
          });
          it("should update sort when ascending/descending is changed", function() {
            return runs(function() {
              this.ccc.$('.bv_sortBy').val('EC50');
              this.ccc.$('.bv_sortBy').change();
              this.ccc.$('.bv_sortDirection_descending').prop("checked", false);
              this.ccc.$('.bv_sortDirection_ascending').prop("checked", true);
              this.ccc.$('.bv_sortDirection_ascending').click();
              expect(this.ccc.$('.bv_curveSummaries .bv_curveSummary .bv_compoundCode:eq(0)').html()).toEqual("CMPD-0000008-01A");
              this.ccc.$('.bv_sortDirection_descending').prop("checked", true);
              this.ccc.$('.bv_sortDirection_ascending').prop("checked", false);
              this.ccc.$('.bv_sortDirection_descending').click();
              return expect(this.ccc.$('.bv_curveSummaries .bv_curveSummary .bv_compoundCode:eq(0)').html()).toEqual("CMPD-0000011-01A");
            });
          });
          it("should add the 'none' option if no sortBy options are received from the server", function() {
            return runs(function() {
              this.ccc.model.set({
                sortOptions: new Backbone.Collection()
              });
              this.ccc.render();
              waits(200);
              return expect(this.ccc.$('.bv_sortBy').val()).toEqual("none");
            });
          });
          return it("should disable sortDirection radio buttons if 'none' sortBy option is selected", function() {
            return runs(function() {
              this.ccc.model.set({
                sortOptions: new Backbone.Collection()
              });
              this.ccc.render();
              waits(200);
              expect(this.ccc.$('.bv_sortBy').val()).toEqual("none");
              expect(this.ccc.$(".bv_sortDirection_ascending").prop("disabled")).toEqual(true);
              return expect(this.ccc.$(".bv_sortDirection_descending").prop("disabled")).toEqual(true);
            });
          });
        });
        describe("filter option select display", function() {
          it("filterOption select should populate with options", function() {
            return runs(function() {
              return expect(this.ccc.$('.bv_filterBy option').length).toEqual(6);
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
              return expect(this.ccc.$('.bv_curveSummaries .bv_curveSummary').length).toEqual(12);
            });
          });
        });
        return describe("When new thumbnail selected", function() {
          beforeEach(function() {
            return runs(function() {
              return this.ccc.$('.bv_curveSummaries .bv_curveSummary').eq(0).click();
            });
          });
          return it("should show the selected curve details", function() {
            waitsFor((function(_this) {
              return function() {
                return _this.ccc.$('.bv_reportedValues').length > 0;
              };
            })(this), 500);
            waits(200);
            return runs(function() {
              return expect(this.ccc.$('.bv_reportedValues').html()).toContain("slope");
            });
          });
        });
      });
      describe("should show error when experiment code does not exist", function() {
        beforeEach(function() {
          runs(function() {
            return this.ccc.getCurvesFromExperimentCode("EXPT-ERROR");
          });
          return waits(500);
        });
        return it("should show error message", function() {
          return expect(this.ccc.$('.bv_badExperimentCode')).toBeVisible();
        });
      });
      return describe("should show error when curve id service returns no results", function() {
        beforeEach(function() {
          runs(function() {
            return this.ccc.getCurvesFromExperimentCode("EXPT-0000018", "CURVE-ERROR");
          });
          return waits(500);
        });
        return it("should show error message", function() {
          return expect(this.ccc.$('.bv_badCurveID')).toBeVisible();
        });
      });
    });
  });

}).call(this);
