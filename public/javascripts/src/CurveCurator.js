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
      status: "pass",
      category: "sigmoid"
    };

    return Curve;

  })(Backbone.Model);

  window.CurveList = (function(_super) {
    __extends(CurveList, _super);

    function CurveList() {
      return CurveList.__super__.constructor.apply(this, arguments);
    }

    CurveList.prototype.model = Curve;

    CurveList.prototype.setExperimentCode = function(exptCode) {
      return this.url = "/api/curves/stub/" + exptCode;
    };

    return CurveList;

  })(Backbone.Collection);

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
      curveUrl = window.conf.service.rapache.fullpath + "/curve/render/?legend=false&curveIds=";
      curveUrl += this.model.get('curveid') + "&height=200&width=250&axes=false";
      this.$el.html(this.template({
        curveUrl: curveUrl
      }));
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

    CurveSummaryListController.prototype.render = function() {
      this.$el.empty();
      this.$el.html(this.template());
      this.collection.each((function(_this) {
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
      this.curveSelectionUpdated = __bind(this.curveSelectionUpdated, this);
      this.render = __bind(this.render, this);
      return CurveCuratorController.__super__.constructor.apply(this, arguments);
    }

    CurveCuratorController.prototype.template = _.template($("#CurveCuratorView").html());

    CurveCuratorController.prototype.initialize = function() {
      return this.collection = new CurveList();
    };

    CurveCuratorController.prototype.render = function() {
      this.$el.empty();
      this.$el.html(this.template());
      this.curveListController = new CurveSummaryListController({
        el: this.$('.bv_curveList'),
        collection: this.collection
      });
      this.curveListController.render();
      this.curveListController.on('selectionUpdated', this.curveSelectionUpdated);
      this.curveEditorController = new CurveEditorController({
        el: this.$('.bv_curveEditor')
      });
      this.curveEditorController.render();
      this.$('.bv_curveSummaries .bv_curveSummary').eq(0).click();
      return this;
    };

    CurveCuratorController.prototype.getCurvesFromExperimentCode = function(exptCode) {
      this.collection.setExperimentCode(exptCode);
      return this.collection.fetch({
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

    return CurveCuratorController;

  })(Backbone.View);

}).call(this);
