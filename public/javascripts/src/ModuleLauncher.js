(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.ModuleLauncher = (function(superClass) {
    extend(ModuleLauncher, superClass);

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
      console.log("request activation");
      if (this.get('autoLaunchName') === "dataViewer") {
        console.log(this);
        console.log(window.AppLaunchParams.moduleLaunchParams);
        return window.open("/dataViewer", '_blank');
      } else {
        this.trigger('activationRequested', this);
        return this.set({
          isActive: true
        });
      }
    };

    ModuleLauncher.prototype.requestDeactivation = function() {
      this.trigger('deactivationRequested', this);
      return this.set({
        isActive: false
      });
    };

    return ModuleLauncher;

  })(Backbone.Model);

  window.ModuleLauncherList = (function(superClass) {
    extend(ModuleLauncherList, superClass);

    function ModuleLauncherList() {
      return ModuleLauncherList.__super__.constructor.apply(this, arguments);
    }

    ModuleLauncherList.prototype.model = ModuleLauncher;

    return ModuleLauncherList;

  })(Backbone.Collection);

  window.ModuleLauncherMenuController = (function(superClass) {
    extend(ModuleLauncherMenuController, superClass);

    function ModuleLauncherMenuController() {
      this.clearSelected = bind(this.clearSelected, this);
      this.handleSelect = bind(this.handleSelect, this);
      this.render = bind(this.render, this);
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
        window.conf.leaveACASMessage = "There are no unsaved changes.";
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
      var ref;
      if ((who != null ? (ref = who.model) != null ? ref.get("menuName") : void 0 : void 0) !== this.model.get("menuName")) {
        return this.model.requestDeactivation();
      }
    };

    return ModuleLauncherMenuController;

  })(Backbone.View);

  window.ModuleLauncherMenuHeaderController = (function(superClass) {
    extend(ModuleLauncherMenuHeaderController, superClass);

    function ModuleLauncherMenuHeaderController() {
      this.render = bind(this.render, this);
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

  window.ModuleLauncherMenuListController = (function(superClass) {
    extend(ModuleLauncherMenuListController, superClass);

    function ModuleLauncherMenuListController() {
      this.selectionUpdated = bind(this.selectionUpdated, this);
      this.addOne = bind(this.addOne, this);
      this.render = bind(this.render, this);
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
      console.log("launchModule");
      selector = '.bv_launch_' + moduleName;
      return this.$(selector).click();
    };

    return ModuleLauncherMenuListController;

  })(Backbone.View);

  window.ModuleLauncherController = (function(superClass) {
    extend(ModuleLauncherController, superClass);

    function ModuleLauncherController() {
      this.handleDeactivation = bind(this.handleDeactivation, this);
      this.handleActivation = bind(this.handleActivation, this);
      this.render = bind(this.render, this);
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

  window.ModuleLauncherListController = (function(superClass) {
    extend(ModuleLauncherListController, superClass);

    function ModuleLauncherListController() {
      this.addOne = bind(this.addOne, this);
      this.render = bind(this.render, this);
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
