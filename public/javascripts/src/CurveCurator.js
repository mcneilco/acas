(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.Curve = (function(_super) {
    __extends(Curve, _super);

    function Curve() {
      return Curve.__super__.constructor.apply(this, arguments);
    }

    return Curve;

  })(Backbone.Model);

  window.CurveDetail = (function(_super) {
    __extends(CurveDetail, _super);

    function CurveDetail() {
      this.fixCompositeClasses = __bind(this.fixCompositeClasses, this);
      return CurveDetail.__super__.constructor.apply(this, arguments);
    }

    CurveDetail.prototype.initialize = function() {
      return this.fixCompositeClasses();
    };

    CurveDetail.prototype.fixCompositeClasses = function() {
      if (!(this.get('fitSettings') instanceof DoseResponseAnalysisParameters)) {
        return this.set({
          fitSettings: new DoseResponseAnalysisParameters(this.get('fitSettings'))
        });
      }
    };

    return CurveDetail;

  })(Backbone.Model);

  window.CurveList = (function(_super) {
    __extends(CurveList, _super);

    function CurveList() {
      return CurveList.__super__.constructor.apply(this, arguments);
    }

    CurveList.prototype.model = Curve;

    CurveList.prototype.getCategories = function() {
      var catList, cats;
      cats = _.unique(this.pluck('category'));
      catList = new Backbone.Collection();
      _.each(cats, function(cat) {
        return catList.add({
          code: cat,
          name: cat
        });
      });
      return catList;
    };

    return CurveList;

  })(Backbone.Collection);

  window.CurveCurationSet = (function(_super) {
    __extends(CurveCurationSet, _super);

    function CurveCurationSet() {
      this.parse = __bind(this.parse, this);
      return CurveCurationSet.__super__.constructor.apply(this, arguments);
    }

    CurveCurationSet.prototype.defaults = {
      sortOptions: new Backbone.Collection(),
      curves: new CurveList()
    };

    CurveCurationSet.prototype.setExperimentCode = function(exptCode) {
      return this.url = "/api/curves/stubs/" + exptCode;
    };

    CurveCurationSet.prototype.parse = function(resp) {
      if (resp.curves != null) {
        if (!(resp.curves instanceof CurveList)) {
          resp.curves = new CurveList(resp.curves);
          resp.curves.on('change', (function(_this) {
            return function() {
              return _this.trigger('change');
            };
          })(this));
        }
      }
      if (resp.sortOptions != null) {
        if (!(resp.sortOptions instanceof Backbone.Collection)) {
          resp.sortOptions = new Backbone.Collection(resp.sortOptions);
          resp.sortOptions.on('change', (function(_this) {
            return function() {
              return _this.trigger('change');
            };
          })(this));
        }
      }
      return resp;
    };

    return CurveCurationSet;

  })(Backbone.Model);

  window.CurveSummaryController = (function(_super) {
    __extends(CurveSummaryController, _super);

    function CurveSummaryController() {
      this.clearSelected = __bind(this.clearSelected, this);
      this.setSelected = __bind(this.setSelected, this);
      this.render = __bind(this.render, this);
      return CurveSummaryController.__super__.constructor.apply(this, arguments);
    }

    CurveSummaryController.prototype.template = _.template($("#CurveSummaryView").html());

    CurveSummaryController.prototype.tagName = 'div';

    CurveSummaryController.prototype.className = 'bv_curveSummary';

    CurveSummaryController.prototype.events = {
      'click': 'setSelected'
    };

    CurveSummaryController.prototype.render = function() {
      var curveUrl;
      this.$el.empty();
      if (window.AppLaunchParams.testMode) {
        curveUrl = "/src/modules/curveAnalysis/spec/testFixtures/testThumbs/";
        curveUrl += this.model.get('curveid') + ".png";
      } else {
        curveUrl = window.conf.service.rapache.fullpath + "/curve/render/?legend=false&curveIds=";
        curveUrl += this.model.get('curveid') + "&height=200&width=250&axes=false";
      }
      this.$el.html(this.template({
        curveUrl: curveUrl
      }));
      if (this.model.get('algorithmApproved')) {
        this.$('.bv_thumbnail').addClass('algorithmApproved');
        this.$('.bv_thumbnail').removeClass('algorithmNotApproved');
      } else {
        this.$('.bv_thumbnail').removeClass('algorithmApproved');
        this.$('.bv_thumbnail').addClass('algorithmNotApproved');
      }
      if (this.model.get('userApproved')) {
        this.$('.bv_thumbsUp').show();
        this.$('.bv_thumbsDown').hide();
      } else {
        this.$('.bv_thumbsUp').hide();
        if (this.model.get('userApproved') === null) {
          this.$('.bv_thumbsDown').hide();
        } else {
          this.$('.bv_thumbsDown').show();
        }
      }
      this.$('.bv_compoundCode').html(this.model.get('curveAttributes').compoundCode);
      return this;
    };

    CurveSummaryController.prototype.setSelected = function() {
      this.$el.addClass('selected');
      return this.trigger('selected', this);
    };

    CurveSummaryController.prototype.clearSelected = function(who) {
      if (who != null) {
        if (who.model.cid === this.model.cid) {
          return;
        }
      }
      return this.$el.removeClass('selected');
    };

    return CurveSummaryController;

  })(Backbone.View);

  window.CurveSummaryListController = (function(_super) {
    __extends(CurveSummaryListController, _super);

    function CurveSummaryListController() {
      this.selectionUpdated = __bind(this.selectionUpdated, this);
      this.render = __bind(this.render, this);
      return CurveSummaryListController.__super__.constructor.apply(this, arguments);
    }

    CurveSummaryListController.prototype.template = _.template($("#CurveSummaryListView").html());

    CurveSummaryListController.prototype.initialize = function() {
      this.filterKey = 'all';
      this.sortKey = 'none';
      return this.sortAscending = true;
    };

    CurveSummaryListController.prototype.render = function() {
      var toRender;
      this.$el.empty();
      this.$el.html(this.template());
      if (this.filterKey !== 'all') {
        toRender = new Backbone.Collection(this.collection.filter((function(_this) {
          return function(cs) {
            return cs.get('category') === _this.filterKey;
          };
        })(this)));
      } else {
        toRender = this.collection;
      }
      if (this.sortKey !== 'none') {
        toRender = toRender.sortBy((function(_this) {
          return function(curve) {
            var attributes;
            attributes = curve.get('curveAttributes');
            return attributes[_this.sortKey];
          };
        })(this));
        if (!this.sortAscending) {
          toRender = toRender.reverse();
        }
        toRender = new Backbone.Collection(toRender);
      }
      toRender.each((function(_this) {
        return function(cs) {
          var csController;
          csController = new CurveSummaryController({
            model: cs
          });
          _this.$('.bv_curveSummaries').append(csController.render().el);
          csController.on('selected', _this.selectionUpdated);
          return _this.on('clearSelected', csController.clearSelected);
        };
      })(this));
      return this;
    };

    CurveSummaryListController.prototype.selectionUpdated = function(who) {
      this.trigger('clearSelected', who);
      return this.trigger('selectionUpdated', who);
    };

    CurveSummaryListController.prototype.filter = function(key) {
      this.filterKey = key;
      return this.render();
    };

    CurveSummaryListController.prototype.sort = function(key, ascending) {
      this.sortKey = key;
      this.sortAscending = ascending;
      return this.render();
    };

    return CurveSummaryListController;

  })(Backbone.View);

  window.CurveEditorController = (function(_super) {
    __extends(CurveEditorController, _super);

    function CurveEditorController() {
      this.render = __bind(this.render, this);
      return CurveEditorController.__super__.constructor.apply(this, arguments);
    }

    CurveEditorController.prototype.template = _.template($("#CurveEditorView").html());

    CurveEditorController.prototype.render = function() {
      this.$el.empty();
      this.$el.html(this.template());
      if (this.model != null) {
        this.drapc = new DoseResponseAnalysisParametersController({
          model: this.model.get('fitSettings'),
          el: this.$('.bv_analysisParameterForm')
        });
        this.drapc.render();
        this.drpc = new DoseResponsePlotController({
          model: new Backbone.Model(this.model.get('plotData')),
          el: this.$('.bv_plotWindowWrapper')
        });
        this.drpc.render();
        this.$('.bv_reportedValues').html(this.model.get('reportedValues'));
        this.$('.bv_fitSummary').html(this.model.get('fitSummary'));
        this.$('.bv_parameterStdErrors').html(this.model.get('parameterStdErrors'));
        this.$('.bv_curveErrors').html(this.model.get('curveErrors'));
        return this.$('.bv_category').html(this.model.get('category'));
      } else {
        return this.$el.html("No curve selected");
      }
    };

    CurveEditorController.prototype.setModel = function(model) {
      this.model = model;
      return this.render();
    };

    return CurveEditorController;

  })(Backbone.View);

  window.DoseResponsePlotController = (function(_super) {
    __extends(DoseResponsePlotController, _super);

    function DoseResponsePlotController() {
      this.handlePointsChanged = __bind(this.handlePointsChanged, this);
      this.render = __bind(this.render, this);
      return DoseResponsePlotController.__super__.constructor.apply(this, arguments);
    }

    DoseResponsePlotController.prototype.template = _.template($("#DoseResponsePlotView").html());

    DoseResponsePlotController.prototype.render = function() {
      this.$el.empty();
      this.$el.html(this.template());
      if (this.model != null) {
        this.$('.bv_plotWindow').attr('id', "bvID_plotWindow_" + this.model.cid);
        this.initJSXGraph(this.model.get('points'), this.model.get('curve'), this.model.get('plotWindow'), this.$('.bv_plotWindow').attr('id'));
        console.log(this.model);
        this.model.on("change", this.handlePointsChanged);
        return this;
      } else {
        return this.$el.html("Plot data not loaded");
      }
    };

    DoseResponsePlotController.prototype.handlePointsChanged = function() {
      return console.log(this.model.get('points'));
    };

    DoseResponsePlotController.prototype.initJSXGraph = function(points, curve, plotWindow, divID) {
      var brd, down, flag, getMouseCoords, ii, p1, t, x, y;
      if (typeof brd === "undefined") {
        brd = JXG.JSXGraph.initBoard(divID, {
          boundingbox: plotWindow,
          axis: false,
          showCopyright: false,
          zoom: {
            wheel: true
          }
        });
        ii = 0;
        while (ii < points.response_sv_id.length) {
          x = JXG.trunc(Math.log(points.dose[ii]), 4);
          y = points.response[ii];
          flag = points.flag[ii];
          if (flag !== "NA") {
            p1 = brd.create("point", [x, y], {
              name: points.response_sv_id[ii],
              fixed: true,
              size: 4,
              face: "cross",
              strokecolor: "gray",
              withLabel: false
            });
          } else {
            p1 = brd.create("point", [x, y], {
              name: points.response_sv_id[ii],
              fixed: true,
              size: 4,
              face: "circle",
              strokecolor: "blue",
              withLabel: false
            });
          }
          p1.idx = ii;
          p1.model = this.model;
          p1.knockOutPoint = function() {
            if (points.flag[this.idx] === "NA") {
              this.setAttribute({
                strokecolor: "gray",
                face: "cross"
              });
              points.flag[this.idx] = "user";
            } else {
              this.setAttribute({
                strokecolor: "blue",
                face: "circle"
              });
              points.flag[this.idx] = "NA";
            }
            this.model.set({
              points: points
            });
            this.model.trigger('change');
          };
          p1.xLabel = JXG.trunc(points.dose[ii], 4);
          p1.on("mouseup", p1.knockOutPoint, p1);
          brd.highlightInfobox = function(x, y, el) {
            brd.infobox.setText("(" + el.xLabel + ", " + y + ")");
          };
          ii++;
        }
        x = brd.create("line", [[0, 0], [1, 0]], {
          strokeColor: "#888888"
        });
        y = brd.create("axis", [[plotWindow[0] * 0.98, 0], [plotWindow[0] * 0.98, 1]]);
        x.isDraggable = false;
        t = brd.create("ticks", [x, 1], {
          drawLabels: true,
          drawZero: true,
          generateLabelValue: function(tick) {
            p1 = this.line.point1;
            return Math.pow(10, tick.usrCoords[1] - p1.coords.usrCoords[1]);
          }
        });
      } else {
        if (typeof window.curve !== "undefined") {
          brd.removeObject(window.curve);
        }
      }
      if (curve != null) {
        Math.logArray = function(input_array, base) {
          var i, output_array;
          output_array = [];
          if (input_array instanceof Array) {
            i = 0;
            while (i < input_array.length) {
              output_array.push(Math.log(input_array[i], base));
              i++;
            }
            return output_array;
          } else {
            return null;
          }
        };
        window.curve = brd.create("curve", [Math.logArray(curve.dose), curve.response], {
          strokeColor: "black",
          strokeWidth: 2
        });
        getMouseCoords = function(e, i) {
          var absPos, cPos, dx, dy;
          cPos = brd.getCoordsTopLeftCorner(e, i);
          absPos = JXG.getPosition(e, i);
          dx = absPos[0] - cPos[0];
          dy = absPos[1] - cPos[1];
          return new JXG.Coords(JXG.COORDS_BY_SCREEN, [dx, dy], brd);
        };
        down = function(e) {
          var A, canCreate, coords, el, i;
          canCreate = true;
          i = void 0;
          coords = void 0;
          el = void 0;
          if (e[JXG.touchProperty]) {
            i = 0;
          }
          coords = getMouseCoords(e, i);
          for (el in brd.objects) {
            if (JXG.isPoint(brd.objects[el]) && brd.objects[el].hasPoint(coords.scrCoords[1], coords.scrCoords[2])) {
              canCreate = false;
              break;
            }
          }
          if (canCreate) {
            A = brd.create("point", [coords.usrCoords[1], coords.usrCoords[2]]);
          }
        };
        brd.on("down", down);
      }
    };

    return DoseResponsePlotController;

  })(AbstractFormController);

  window.CurveCuratorController = (function(_super) {
    __extends(CurveCuratorController, _super);

    function CurveCuratorController() {
      this.handleSortChanged = __bind(this.handleSortChanged, this);
      this.handleFilterChanged = __bind(this.handleFilterChanged, this);
      this.handleGetCurveDetailReturn = __bind(this.handleGetCurveDetailReturn, this);
      this.curveSelectionUpdated = __bind(this.curveSelectionUpdated, this);
      this.render = __bind(this.render, this);
      return CurveCuratorController.__super__.constructor.apply(this, arguments);
    }

    CurveCuratorController.prototype.template = _.template($("#CurveCuratorView").html());

    CurveCuratorController.prototype.events = {
      'change .bv_filterBy': 'handleFilterChanged',
      'change .bv_sortBy': 'handleSortChanged',
      'click .bv_sortDirection_ascending': 'handleSortChanged',
      'click .bv_sortDirection_descending': 'handleSortChanged'
    };

    CurveCuratorController.prototype.render = function() {
      this.$el.empty();
      this.$el.html(this.template());
      if (this.model != null) {
        this.curveListController = new CurveSummaryListController({
          el: this.$('.bv_curveList'),
          collection: this.model.get('curves')
        });
        this.curveListController.render();
        this.curveListController.on('selectionUpdated', this.curveSelectionUpdated);
        this.curveEditorController = new CurveEditorController({
          el: this.$('.bv_curveEditor')
        });
        if (this.model.get('sortOptions').length > 0) {
          this.sortBySelect = new PickListSelectController({
            collection: this.model.get('sortOptions'),
            el: this.$('.bv_sortBy'),
            selectedCode: (this.model.get('sortOptions'))[0],
            autoFetch: false
          });
        } else {
          this.sortBySelect = new PickListSelectController({
            collection: this.model.get('sortOptions'),
            el: this.$('.bv_sortBy'),
            insertFirstOption: new PickList({
              code: "none",
              name: "No Sort"
            }),
            selectedCode: "none",
            autoFetch: false
          });
        }
        this.sortBySelect.render();
        this.filterBySelect = new PickListSelectController({
          collection: this.model.get('curves').getCategories(),
          el: this.$('.bv_filterBy'),
          insertFirstOption: new PickList({
            code: "all",
            name: "Show All"
          }),
          selectedCode: "all",
          autoFetch: false
        });
        this.filterBySelect.render();
        if (this.curveListController.sortAscending) {
          this.$('.bv_sortDirection_ascending').attr("checked", true);
        } else {
          this.$('.bv_sortDirection_descending').attr("checked", true);
        }
        this.handleSortChanged();
        this.$('.bv_curveSummaries .bv_curveSummary').eq(0).click();
      }
      return this;
    };

    CurveCuratorController.prototype.getCurvesFromExperimentCode = function(exptCode) {
      this.model = new CurveCurationSet;
      this.model.setExperimentCode(exptCode);
      return this.model.fetch({
        success: (function(_this) {
          return function() {
            return _this.render();
          };
        })(this)
      });
    };

    CurveCuratorController.prototype.curveSelectionUpdated = function(who) {
      return $.ajax({
        type: 'GET',
        url: "/api/curve/detail/" + who.model.get('curveid'),
        dataType: 'json',
        success: this.handleGetCurveDetailReturn,
        error: function(err) {
          return console.log('got ajax error');
        }
      });
    };

    CurveCuratorController.prototype.handleGetCurveDetailReturn = function(json) {
      return this.curveEditorController.setModel(new CurveDetail(json));
    };

    CurveCuratorController.prototype.handleFilterChanged = function() {
      return this.curveListController.filter(this.$('.bv_filterBy').val());
    };

    CurveCuratorController.prototype.handleSortChanged = function() {
      var sortBy, sortDirection;
      sortBy = this.$('.bv_sortBy').val();
      if (sortBy === "none") {
        this.$("input[name='bv_sortDirection']").prop('disabled', true);
      } else {
        this.$("input[name='bv_sortDirection']").prop('disabled', false);
      }
      sortDirection = this.$("input[name='bv_sortDirection']:checked").val() === "descending" ? false : true;
      return this.curveListController.sort(sortBy, sortDirection);
    };

    return CurveCuratorController;

  })(Backbone.View);

}).call(this);
