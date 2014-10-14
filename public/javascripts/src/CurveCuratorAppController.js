(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.CurveCuratorAppRouter = (function(_super) {
    __extends(CurveCuratorAppRouter, _super);

    function CurveCuratorAppRouter() {
      this.loadCurvesForExptCode = __bind(this.loadCurvesForExptCode, this);
      return CurveCuratorAppRouter.__super__.constructor.apply(this, arguments);
    }

    CurveCuratorAppRouter.prototype.routes = {
      ":exptCode": "loadCurvesForExptCode",
      ":exptCode/:curveID": "loadCurvesForExptCode"
    };

    CurveCuratorAppRouter.prototype.initialize = function(options) {
      return this.appController = options.appController;
    };

    CurveCuratorAppRouter.prototype.loadCurvesForExptCode = function(exptCode, curveID) {
      return this.appController.loadCurvesForExptCode(exptCode, curveID);
    };

    return CurveCuratorAppRouter;

  })(Backbone.Router);

  window.CurveCuratorAppController = (function(_super) {
    __extends(CurveCuratorAppController, _super);

    function CurveCuratorAppController() {
      this.loadCurvesForExptCode = __bind(this.loadCurvesForExptCode, this);
      this.render = __bind(this.render, this);
      return CurveCuratorAppController.__super__.constructor.apply(this, arguments);
    }

    CurveCuratorAppController.prototype.template = _.template($('#CurveCuratorAppView').html());

    CurveCuratorAppController.prototype.initialize = function() {
      $(this.el).html(this.template());
      this.ccc = new CurveCuratorController({
        el: this.$('.bv_curveCurator')
      });
      this.render();
      this.router = new CurveCuratorAppRouter({
        appController: this
      });
      return Backbone.history.start({
        pushState: true,
        root: "/curveCurator"
      });
    };

    CurveCuratorAppController.prototype.render = function() {
      this.ccc.render();
      return this;
    };

    CurveCuratorAppController.prototype.loadCurvesForExptCode = function(exptCode, curveID) {
      this.ccc.getCurvesFromExperimentCode(exptCode, curveID);
      return $.ajax({
        type: 'GET',
        url: "/api/experiments/resultViewerURL/" + exptCode,
        success: (function(_this) {
          return function(json) {
            var resultViewerURL;
            _this.resultViewerURL = json;
            resultViewerURL = _this.resultViewerURL.resultViewerURL;
            _this.$('.bv_resultViewerBtn').attr('href', resultViewerURL);
            return _this.$('.bv_resultViewerBtn').show();
          };
        })(this),
        error: (function(_this) {
          return function(err) {
            console.log('got ajax error');
            return _this.serviceReturn = null;
          };
        })(this),
        dataType: 'json'
      });
    };

    return CurveCuratorAppController;

  })(Backbone.View);

}).call(this);
