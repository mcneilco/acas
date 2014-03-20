(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.Curve = (function(_super) {
    __extends(Curve, _super);

    function Curve() {
      return Curve.__super__.constructor.apply(this, arguments);
    }

    Curve.prototype.defaults = {
      curveid: "",
      algorithmApproved: null,
      userApproved: null,
      category: ""
    };

    return Curve;

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
      return this.url = "/api/curves/stub/" + exptCode;
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
      this.shinyLoaded = __bind(this.shinyLoaded, this);
      this.render = __bind(this.render, this);
      return CurveEditorController.__super__.constructor.apply(this, arguments);
    }

    CurveEditorController.prototype.template = _.template($("#CurveEditorView").html());

    CurveEditorController.prototype.render = function() {
      var curveUrl;
      this.$el.empty();
      if (this.model != null) {
        if (this.model.get('curveid') !== "") {
          curveUrl = window.conf.service.rshiny.fullpath + "/fit/?curveIds=";
          curveUrl += this.model.get('curveid');
        }
      }
      this.$el.html(this.template({
        curveUrl: curveUrl
      }));
      this;
      this.$('.bv_loading').show();
      return this.$('.bv_shinyContainer').load((function(_this) {
        return function() {
          return _this.$('.bv_loading').hide();
        };
      })(this));
    };

    CurveEditorController.prototype.setModel = function(model) {
      this.model = model;
      return this.render();
    };

    CurveEditorController.prototype.shinyLoaded = function() {};

    return CurveEditorController;

  })(Backbone.View);

  window.CurveCuratorController = (function(_super) {
    __extends(CurveCuratorController, _super);

    function CurveCuratorController() {
      this.handleSortChanged = __bind(this.handleSortChanged, this);
      this.handleFilterChanged = __bind(this.handleFilterChanged, this);
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
        if ((this.model.get('sortOptions')).length > 0) {
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
      return this.curveEditorController.setModel(who.model);
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
