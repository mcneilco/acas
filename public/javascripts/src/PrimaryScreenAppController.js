(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.PrimaryScreenAppRouter = (function(superClass) {
    extend(PrimaryScreenAppRouter, superClass);

    function PrimaryScreenAppRouter() {
      this.existingExperimentByCode = bind(this.existingExperimentByCode, this);
      this.existingExperiment = bind(this.existingExperiment, this);
      this.newExperiment = bind(this.newExperiment, this);
      return PrimaryScreenAppRouter.__super__.constructor.apply(this, arguments);
    }

    PrimaryScreenAppRouter.prototype.routes = {
      ":expId": "existingExperiment",
      "codeName/:code": "existingExperimentByCode",
      "": "newExperiment"
    };

    PrimaryScreenAppRouter.prototype.initialize = function(options) {
      return this.appController = options.appController;
    };

    PrimaryScreenAppRouter.prototype.newExperiment = function() {
      return this.appController.newExperiment();
    };

    PrimaryScreenAppRouter.prototype.existingExperiment = function(expId) {
      return this.appController.existingExperiment(expId);
    };

    PrimaryScreenAppRouter.prototype.existingExperimentByCode = function(code) {
      return this.appController.existingExperimentByCode(code);
    };

    return PrimaryScreenAppRouter;

  })(Backbone.Router);

  window.PrimaryScreenAppController = (function(superClass) {
    extend(PrimaryScreenAppController, superClass);

    function PrimaryScreenAppController() {
      this.existingExperiment = bind(this.existingExperiment, this);
      this.existingExperimentByCode = bind(this.existingExperimentByCode, this);
      this.newExperiment = bind(this.newExperiment, this);
      this.render = bind(this.render, this);
      return PrimaryScreenAppController.__super__.constructor.apply(this, arguments);
    }

    PrimaryScreenAppController.prototype.template = _.template($('#PrimaryScreenAppControllerView').html());

    PrimaryScreenAppController.prototype.initialize = function() {
      $(this.el).html(this.template());
      this.render();
      this.router = new PrimaryScreenAppRouter({
        appController: this
      });
      return Backbone.history.start({
        pushState: true,
        root: "/primaryScreenExperiment"
      });
    };

    PrimaryScreenAppController.prototype.render = function() {
      return this;
    };

    PrimaryScreenAppController.prototype.newExperiment = function() {
      this.primaryScreenExperimentController = new PrimaryScreenExperimentController({
        model: new PrimaryScreenExperiment(),
        el: $('.bv_primaryScreenExperimentController')
      });
      return this.primaryScreenExperimentController.render();
    };

    PrimaryScreenAppController.prototype.existingExperimentByCode = function(code) {
      return $.ajax({
        type: 'GET',
        url: "/api/experiments/codename/" + code,
        dataType: 'json',
        error: function(err) {
          return alert('Could not get experiment for code in this URL');
        },
        success: (function(_this) {
          return function(json) {
            return _this.existingExperiment(json.id);
          };
        })(this)
      });
    };

    PrimaryScreenAppController.prototype.existingExperiment = function(expId) {
      var exp;
      exp = new PrimaryScreenExperiment({
        id: expId
      });
      return exp.fetch({
        success: (function(_this) {
          return function() {
            exp.fixCompositeClasses();
            _this.primaryScreenExperimentController = new PrimaryScreenExperimentController({
              model: exp,
              el: $('.bv_primaryScreenExperimentController')
            });
            return _this.primaryScreenExperimentController.render();
          };
        })(this)
      });
    };

    return PrimaryScreenAppController;

  })(Backbone.View);

}).call(this);
