(function() {
  var _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.ModuleLauncher = (function(_super) {
    __extends(ModuleLauncher, _super);

    function ModuleLauncher() {
      _ref = ModuleLauncher.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    ModuleLauncher.prototype.defaults = {
      isHeader: false,
      menuName: "Menu Name Replace Me",
      mainControllerClassName: "controllerClassNameReplaceMe",
      isLoaded: false,
      isActive: false,
      isDirty: false
    };

    ModuleLauncher.prototype.requestActivation = function() {
      this.trigger('activationRequested', this);
      return this.set({
        isActive: true
      });
    };

    ModuleLauncher.prototype.requestDeactivation = function() {
      this.trigger('deactivationRequested', this);
      return this.set({
        isActive: false
      });
    };

    return ModuleLauncher;

  })(Backbone.Model);

  window.ModuleLauncherList = (function(_super) {
    __extends(ModuleLauncherList, _super);

    function ModuleLauncherList() {
      _ref1 = ModuleLauncherList.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    ModuleLauncherList.prototype.model = ModuleLauncher;

    return ModuleLauncherList;

  })(Backbone.Collection);

  window.ModuleLauncherMenuController = (function(_super) {
    __extends(ModuleLauncherMenuController, _super);

    function ModuleLauncherMenuController() {
      this.clearSelected = __bind(this.clearSelected, this);
      this.handleSelect = __bind(this.handleSelect, this);
      this.render = __bind(this.render, this);      _ref2 = ModuleLauncherMenuController.__super__.constructor.apply(this, arguments);
      return _ref2;
    }

    ModuleLauncherMenuController.prototype.template = _.template($("#ModuleLauncherMenuView").html());

    ModuleLauncherMenuController.prototype.tagName = 'li';

    ModuleLauncherMenuController.prototype.events = {
      'click': "handleSelect"
    };

    ModuleLauncherMenuController.prototype.initialize = function() {
      return this.model.bind("change", this.render);
    };

    ModuleLauncherMenuController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template(this.model.toJSON()));
      if (this.model.get('isActive')) {
        $(this.el).addClass("active");
      } else {
        $(this.el).removeClass("active");
      }
      if (this.model.get('isLoaded')) {
        this.$('.bv_isLoaded').show();
      } else {
        this.$('.bv_isLoaded').hide();
      }
      if (this.model.get('isDirty')) {
        this.$('.bv_isDirty').show();
      } else {
        this.$('.bv_isDirty').hide();
      }
      return this;
    };

    ModuleLauncherMenuController.prototype.handleSelect = function() {
      this.model.requestActivation();
      return this.trigger("selected", this);
    };

    ModuleLauncherMenuController.prototype.clearSelected = function(who) {
      var _ref3;

      if ((who != null ? (_ref3 = who.model) != null ? _ref3.get("menuName") : void 0 : void 0) !== this.model.get("menuName")) {
        return this.model.requestDeactivation();
      }
    };

    return ModuleLauncherMenuController;

  })(Backbone.View);

  window.ModuleLauncherMenuHeaderController = (function(_super) {
    __extends(ModuleLauncherMenuHeaderController, _super);

    function ModuleLauncherMenuHeaderController() {
      this.render = __bind(this.render, this);      _ref3 = ModuleLauncherMenuHeaderController.__super__.constructor.apply(this, arguments);
      return _ref3;
    }

    ModuleLauncherMenuHeaderController.prototype.tagName = 'li';

    ModuleLauncherMenuHeaderController.prototype.className = "nav-header";

    ModuleLauncherMenuHeaderController.prototype.initialize = function() {
      return this.model.bind("change", this.render);
    };

    ModuleLauncherMenuHeaderController.prototype.render = function() {
      $(this.el).html(this.model.get('menuName'));
      return this;
    };

    return ModuleLauncherMenuHeaderController;

  })(Backbone.View);

  window.ModuleLauncherMenuListController = (function(_super) {
    __extends(ModuleLauncherMenuListController, _super);

    function ModuleLauncherMenuListController() {
      this.selectionUpdated = __bind(this.selectionUpdated, this);
      this.addOne = __bind(this.addOne, this);
      this.render = __bind(this.render, this);      _ref4 = ModuleLauncherMenuListController.__super__.constructor.apply(this, arguments);
      return _ref4;
    }

    ModuleLauncherMenuListController.prototype.template = _.template($("#ModuleLauncherMenuListView").html());

    ModuleLauncherMenuListController.prototype.initialize = function() {};

    ModuleLauncherMenuListController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      this.collection.each(this.addOne);
      return this;
    };

    ModuleLauncherMenuListController.prototype.addOne = function(menuItem) {
      var menuItemController;

      menuItemController = this.makeMenuItemController(menuItem);
      return this.$('.bv_navList').append(menuItemController.render().el);
    };

    ModuleLauncherMenuListController.prototype.makeMenuItemController = function(menuItem) {
      var menuItemCont;

      if (menuItem.get('isHeader')) {
        menuItemCont = new ModuleLauncherMenuHeaderController({
          model: menuItem
        });
      } else {
        menuItemCont = new ModuleLauncherMenuController({
          model: menuItem
        });
        menuItemCont.bind('selected', this.selectionUpdated);
        this.bind('clearSelected', menuItemCont.clearSelected);
      }
      return menuItemCont;
    };

    ModuleLauncherMenuListController.prototype.selectionUpdated = function(who) {
      return this.trigger('clearSelected', who);
    };

    return ModuleLauncherMenuListController;

  })(Backbone.View);

  window.ModuleLauncherController = (function(_super) {
    __extends(ModuleLauncherController, _super);

    function ModuleLauncherController() {
      this.handleRouteRequested = __bind(this.handleRouteRequested, this);
      this.handleDeactivation = __bind(this.handleDeactivation, this);
      this.handleActivation = __bind(this.handleActivation, this);
      this.render = __bind(this.render, this);      _ref5 = ModuleLauncherController.__super__.constructor.apply(this, arguments);
      return _ref5;
    }

    ModuleLauncherController.prototype.tagName = 'div';

    ModuleLauncherController.prototype.template = _.template($("#ModuleLauncherView").html());

    ModuleLauncherController.prototype.initialize = function() {
      this.model.bind('activationRequested', this.handleActivation);
      return this.model.bind('deactivationRequested', this.handleDeactivation);
    };

    ModuleLauncherController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      $(this.el).addClass('bv_' + this.model.get('mainControllerClassName'));
      if (this.model.get('isActive')) {
        $(this.el).show();
      } else {
        $(this.el).hide();
      }
      return this;
    };

    ModuleLauncherController.prototype.handleActivation = function() {
      var _this = this;

      if (!this.model.get('isLoaded')) {
        if (!window.AppLaunchParams.testMode) {
          this.moduleController = new window[this.model.get('mainControllerClassName')]({
            el: this.$('.bv_moduleContent')
          });
          this.moduleController.bind('amDirty', function() {
            return _this.model.set({
              isDirty: true
            });
          });
          this.moduleController.bind('amClean', function() {
            return _this.model.set({
              isDirty: false
            });
          });
          this.moduleController.render();
          this.model.set({
            isLoaded: true
          });
        }
      }
      return $(this.el).show();
    };

    ModuleLauncherController.prototype.handleDeactivation = function() {
      return $(this.el).hide();
    };

    ModuleLauncherController.prototype.handleRouteRequested = function(params) {};

    return ModuleLauncherController;

  })(Backbone.View);

  window.ModuleLauncherListController = (function(_super) {
    __extends(ModuleLauncherListController, _super);

    function ModuleLauncherListController() {
      this.addOne = __bind(this.addOne, this);
      this.render = __bind(this.render, this);      _ref6 = ModuleLauncherListController.__super__.constructor.apply(this, arguments);
      return _ref6;
    }

    ModuleLauncherListController.prototype.template = _.template($("#ModuleLauncherListView").html());

    ModuleLauncherListController.prototype.initialize = function() {};

    ModuleLauncherListController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      return this.collection.each(this.addOne);
    };

    ModuleLauncherListController.prototype.addOne = function(moduleLauncher) {
      var modLaunchCont;

      if (!moduleLauncher.get('isHeader')) {
        modLaunchCont = new ModuleLauncherController({
          model: moduleLauncher
        });
        return this.$('.bv_moduleWrapper').append(modLaunchCont.render().el);
      }
    };

    return ModuleLauncherListController;

  })(Backbone.View);

}).call(this);
