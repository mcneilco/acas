(function() {
  var _ref, _ref1,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.AppRouter = (function(_super) {
    __extends(AppRouter, _super);

    function AppRouter() {
      this.existingDoc = __bind(this.existingDoc, this);
      this.newDoc = __bind(this.newDoc, this);
      _ref = AppRouter.__super__.constructor.apply(this, arguments);
      return _ref;
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

  window.AppController = (function(_super) {
    __extends(AppController, _super);

    function AppController() {
      this.existingDocReturn = __bind(this.existingDocReturn, this);
      this.existingDoc = __bind(this.existingDoc, this);
      this.newDoc = __bind(this.newDoc, this);
      this.render = __bind(this.render, this);
      _ref1 = AppController.__super__.constructor.apply(this, arguments);
      return _ref1;
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
      var _this = this;
      return $.ajax({
        type: 'GET',
        url: "/api/experiments/" + docId,
        success: function(json) {
          console.log("success from getting existing doc");
          console.log(json);
          return _this.existingDocReturn(json);
        },
        error: function(err) {
          return _this.serviceReturn = null;
        },
        dataType: 'json'
      });
    };

    AppController.prototype.existingDocReturn = function(json) {
      this.exp = new Experiment(json);
      console.log("existing return experiment");
      console.log(this.exp);
      this.dfb = new DocForBatches({
        experiment: this.exp
      });
      console.log("existing return docForBatches");
      console.log(this.dfb);
      this.docForBatchesController = new DocForBatchesController({
        el: this.$('.docForBatches'),
        model: this.dfb
      });
      return this.docForBatchesController.render();
    };

    return AppController;

  })(Backbone.View);

}).call(this);
