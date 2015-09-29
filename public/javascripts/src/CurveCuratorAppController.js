(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.CurveCuratorAppRouter = (function(superClass) {
    extend(CurveCuratorAppRouter, superClass);

    function CurveCuratorAppRouter() {
      this.loadCurvesForExptCode = bind(this.loadCurvesForExptCode, this);
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

  window.CurveCuratorAppController = (function(superClass) {
    extend(CurveCuratorAppController, superClass);

    function CurveCuratorAppController() {
      this.hideLoadCurvesModal = bind(this.hideLoadCurvesModal, this);
      this.loadCurvesForExptCode = bind(this.loadCurvesForExptCode, this);
      this.render = bind(this.render, this);
      return CurveCuratorAppController.__super__.constructor.apply(this, arguments);
    }

    CurveCuratorAppController.prototype.template = _.template($('#CurveCuratorAppView').html());

    CurveCuratorAppController.prototype.initialize = function() {
      $(this.el).html(this.template());
      this.ccc = new CurveCuratorController({
        el: this.$('.bv_curveCurator')
      });
      this.ccc.on('getCurvesSuccessful', this.hideLoadCurvesModal);
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
      var resultViewerURL;
      UtilityFunctions.prototype.showProgressModal(this.$('.bv_loadCurvesModal'));
      this.ccc.setupCurator(exptCode, curveID);
      resultViewerURL = "/openExptInQueryTool?experiment=" + exptCode;
      this.$('.bv_resultViewerBtn').attr('href', resultViewerURL);
      this.$('.bv_resultViewerBtn').html('Open in ' + window.conf.service.result.viewer.displayName);
      return this.$('.bv_resultViewerBtn').show();
    };

    CurveCuratorAppController.prototype.hideLoadCurvesModal = function() {
      return UtilityFunctions.prototype.hideProgressModal(this.$('.bv_loadCurvesModal'));
    };

    return CurveCuratorAppController;

  })(Backbone.View);

}).call(this);
