(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.ModuleLauncher = (function(_super) {
    __extends(ModuleLauncher, _super);

    function ModuleLauncher() {
      return ModuleLauncher.__super__.constructor.apply(this, arguments);
    }

    ModuleLauncher.prototype.defaults = {
      isHeader: false,
      menuName: "Menu Name Replace Me",
      mainControllerClassName: "controllerClassNameReplaceMe",
      isLoaded: false,
      isActive: false,
      isDirty: false,
      autoLaunchName: null
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
      return ModuleLauncherList.__super__.constructor.apply(this, arguments);
    }

    ModuleLauncherList.prototype.model = ModuleLauncher;

    return ModuleLauncherList;

  })(Backbone.Collection);

  window.ModuleLauncherMenuController = (function(_super) {
    __extends(ModuleLauncherMenuController, _super);

    function ModuleLauncherMenuController() {
      this.clearSelected = __bind(this.clearSelected, this);
      this.handleSelect = __bind(this.handleSelect, this);
      this.render = __bind(this.render, this);
      return ModuleLauncherMenuController.__super__.constructor.apply(this, arguments);
    }

    ModuleLauncherMenuController.prototype.template = _.template($("#ModuleLauncherMenuView").html());

    ModuleLauncherMenuController.prototype.tagName = 'li';

    ModuleLauncherMenuController.prototype.events = {
      'click .bv_menuName': "handleSelect"
    };

    ModuleLauncherMenuController.prototype.initialize = function() {
      return this.model.bind("change", this.render);
    };

    ModuleLauncherMenuController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template(this.model.toJSON()));
      this.$('.bv_menuName').addClass('bv_launch_' + this.model.get('autoLaunchName'));
      if (this.model.get('isActive')) {
        $(this.el).addClass("active");
      } else {
        $(this.el).removeClass("active");
      }
      this.$('.bv_isLoaded').hide();
      if (this.model.get('isDirty')) {
        this.$('.bv_isDirty').show();
        window.conf.leaveACASMessage = "WARNING: There are unsaved changes.";
      } else {
        this.$('.bv_isDirty').hide();
      }
      if (this.model.has('requireUserRoles')) {
        if (!UtilityFunctions.prototype.testUserHasRole(window.AppLaunchParams.loginUser, this.model.get('requireUserRoles'))) {
          $(this.el).attr('title', "User is not authorized to use this feature");
          this.$('.bv_menuName').hide();
          this.$('.bv_menuName_disabled').show();
        }
      }
      return this;
    };

    ModuleLauncherMenuController.prototype.handleSelect = function() {
      this.model.requestActivation();
      return this.trigger("selected", this);
    };

    ModuleLauncherMenuController.prototype.clearSelected = function(who) {
      var _ref;
      if ((who != null ? (_ref = who.model) != null ? _ref.get("menuName") : void 0 : void 0) !== this.model.get("menuName")) {
        return this.model.requestDeactivation();
      }
    };

    return ModuleLauncherMenuController;

  })(Backbone.View);

  window.ModuleLauncherMenuHeaderController = (function(_super) {
    __extends(ModuleLauncherMenuHeaderController, _super);

    function ModuleLauncherMenuHeaderController() {
      this.render = __bind(this.render, this);
      return ModuleLauncherMenuHeaderController.__super__.constructor.apply(this, arguments);
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
      this.render = __bind(this.render, this);
      return ModuleLauncherMenuListController.__super__.constructor.apply(this, arguments);
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

    ModuleLauncherMenuListController.prototype.launchModule = function(moduleName) {
      var selector;
      selector = '.bv_launch_' + moduleName;
      return this.$(selector).click();
    };

    return ModuleLauncherMenuListController;

  })(Backbone.View);

  window.ModuleLauncherController = (function(_super) {
    __extends(ModuleLauncherController, _super);

    function ModuleLauncherController() {
      this.handleDeactivation = __bind(this.handleDeactivation, this);
      this.handleActivation = __bind(this.handleActivation, this);
      this.render = __bind(this.render, this);
      return ModuleLauncherController.__super__.constructor.apply(this, arguments);
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
      if (!this.model.get('isLoaded')) {
        if (!window.AppLaunchParams.testMode) {
          this.moduleController = new window[this.model.get('mainControllerClassName')]({
            el: this.$('.bv_moduleContent')
          });
          this.moduleController.bind('amDirty', (function(_this) {
            return function() {
              return _this.model.set({
                isDirty: true
              });
            };
          })(this));
          this.moduleController.bind('amClean', (function(_this) {
            return function() {
              return _this.model.set({
                isDirty: false
              });
            };
          })(this));
          this.moduleController.render();
          this.model.set({
            isLoaded: true
          });
        }
      }
      $(this.el).show();
      $('.bv_mainModuleWrapper').show();
      return $('.bv_homePageWrapper').hide();
    };

    ModuleLauncherController.prototype.handleDeactivation = function() {
      return $(this.el).hide();
    };

    return ModuleLauncherController;

  })(Backbone.View);

  window.ModuleLauncherListController = (function(_super) {
    __extends(ModuleLauncherListController, _super);

    function ModuleLauncherListController() {
      this.addOne = __bind(this.addOne, this);
      this.render = __bind(this.render, this);
      return ModuleLauncherListController.__super__.constructor.apply(this, arguments);
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
