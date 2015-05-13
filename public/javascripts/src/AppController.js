(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.AppRouter = (function(superClass) {
    extend(AppRouter, superClass);

    function AppRouter() {
      this.existingDoc = bind(this.existingDoc, this);
      this.newDoc = bind(this.newDoc, this);
      return AppRouter.__super__.constructor.apply(this, arguments);
    }

    AppRouter.prototype.routes = {
      ":docId": "existingDoc",
      "": "newDoc"
    };

    AppRouter.prototype.initialize = function(options) {
      return this.appController = options.appController;
    };

    AppRouter.prototype.newDoc = function() {
      return this.appController.newDoc();
    };

    AppRouter.prototype.existingDoc = function(docId) {
      return this.appController.existingDoc(docId);
    };

    return AppRouter;

  })(Backbone.Router);

  window.AppController = (function(superClass) {
    extend(AppController, superClass);

    function AppController() {
      this.existingDocReturn = bind(this.existingDocReturn, this);
      this.existingDoc = bind(this.existingDoc, this);
      this.newDoc = bind(this.newDoc, this);
      this.render = bind(this.render, this);
      return AppController.__super__.constructor.apply(this, arguments);
    }

    AppController.prototype.template = _.template($('#DocForBatchesAppControllerView').html());

    AppController.prototype.initialize = function() {
      $(this.el).html(this.template());
      this.render();
      this.router = new AppRouter({
        appController: this
      });
      return Backbone.history.start({
        pushState: true,
        root: "/docForBatches"
      });
    };

    AppController.prototype.render = function() {
      return this;
    };

    AppController.prototype.newDoc = function() {
      this.docForBatchesController = new DocForBatchesController({
        el: this.$('.docForBatches'),
        model: new DocForBatches()
      });
      return this.docForBatchesController.render();
    };

    AppController.prototype.existingDoc = function(docId) {
      return $.ajax({
        type: 'GET',
        url: "/api/experiments/" + docId,
        success: (function(_this) {
          return function(json) {
            return _this.existingDocReturn(json);
          };
        })(this),
        error: (function(_this) {
          return function(err) {
            return _this.serviceReturn = null;
          };
        })(this),
        dataType: 'json'
      });
    };

    AppController.prototype.existingDocReturn = function(json) {
      this.exp = new Experiment(json);
      this.dfb = new DocForBatches({
        experiment: this.exp
      });
      this.docForBatchesController = new DocForBatchesController({
        el: this.$('.docForBatches'),
        model: this.dfb
      });
      return this.docForBatchesController.render();
    };

    return AppController;

  })(Backbone.View);

}).call(this);
