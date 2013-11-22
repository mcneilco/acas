(function() {
  var _ref, _ref1,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.AppRouter = (function(_super) {
    __extends(AppRouter, _super);

    function AppRouter() {
      _ref = AppRouter.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    AppRouter.prototype.routes = {
      "fred/:docid": "existingDoc",
      "fred": "newDoc"
    };

    AppRouter.prototype.initialize = function(options) {
      return this.appController = options.appController;
    };

    AppRouter.prototype.existingDoc = function(val) {};

    AppRouter.prototype.newDoc = function(val) {};

    return AppRouter;

  })(Backbone.Router);

  window.ModuleMenusController = (function(_super) {
    __extends(ModuleMenusController, _super);

    function ModuleMenusController() {
      this.render = __bind(this.render, this);
      _ref1 = ModuleMenusController.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    ModuleMenusController.prototype.template = _.template($("#ModuleMenusView").html());

    ModuleMenusController.prototype.initialize = function() {
      $(this.el).html(this.template());
      this.moduleLauncherList = new ModuleLauncherList(this.options.menuListJSON);
      this.moduleLauncherMenuListController = new ModuleLauncherMenuListController({
        el: this.$('.bv_modLaunchMenuWrapper'),
        collection: this.moduleLauncherList
      });
      return this.moduleLauncherListController = new ModuleLauncherListController({
        el: this.$('.bv_mainModuleWrapper'),
        collection: this.moduleLauncherList
      });
    };

    ModuleMenusController.prototype.render = function() {
      this.moduleLauncherMenuListController.render();
      this.moduleLauncherListController.render();
      if (window.conf.require.login) {
        this.$('.bv_loginUserFirstName').html(window.AppLaunchParams.loginUser.firstName);
        this.$('.bv_loginUserLastName').html(window.AppLaunchParams.loginUser.lastName);
      } else {
        this.$('.bv_userInfo').hide();
      }
      return this;
    };

    return ModuleMenusController;

  })(Backbone.View);

}).call(this);
