(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  window.PickList = (function(_super) {
    __extends(PickList, _super);

    function PickList() {
      return PickList.__super__.constructor.apply(this, arguments);
    }

    return PickList;

  })(Backbone.Model);

  window.PickListList = (function(_super) {
    __extends(PickListList, _super);

    function PickListList() {
      return PickListList.__super__.constructor.apply(this, arguments);
    }

    PickListList.prototype.model = PickList;

    PickListList.prototype.setType = function(type) {
      return this.type = type;
    };

    PickListList.prototype.getModelWithCode = function(code) {
      return this.detect(function(enu) {
        return enu.get("code") === code;
      });
    };

    PickListList.prototype.getCurrent = function() {
      return this.filter(function(pl) {
        return !(pl.get('ignored'));
      });
    };

    return PickListList;

  })(Backbone.Collection);

  window.PickListOptionController = (function(_super) {
    __extends(PickListOptionController, _super);

    function PickListOptionController() {
      this.render = __bind(this.render, this);
      return PickListOptionController.__super__.constructor.apply(this, arguments);
    }

    PickListOptionController.prototype.tagName = "option";

    PickListOptionController.prototype.initialize = function() {};

    PickListOptionController.prototype.render = function() {
      $(this.el).attr("value", this.model.get("code")).text(this.model.get("name"));
      return this;
    };

    return PickListOptionController;

  })(Backbone.View);

  window.PickListSelectController = (function(_super) {
    __extends(PickListSelectController, _super);

    function PickListSelectController() {
      this.addOne = __bind(this.addOne, this);
      this.render = __bind(this.render, this);
      this.handleListReset = __bind(this.handleListReset, this);
      return PickListSelectController.__super__.constructor.apply(this, arguments);
    }

    PickListSelectController.prototype.initialize = function() {
      this.rendered = false;
      this.collection.bind("add", this.addOne);
      this.collection.bind("reset", this.handleListReset);
      if (this.options.selectedCode !== "") {
        this.selectedCode = this.options.selectedCode;
      } else {
        this.selectedCode = null;
      }
      if (this.options.insertFirstOption != null) {
        this.insertFirstOption = this.options.insertFirstOption;
      } else {
        this.insertFirstOption = null;
      }
      if (this.options.autoFetch != null) {
        this.autoFetch = this.options.autoFetch;
      } else {
        this.autoFetch = true;
      }
      if (this.autoFetch) {
        return this.collection.fetch({
          success: this.handleListReset
        });
      } else {
        return this.handleListReset();
      }
    };

    PickListSelectController.prototype.handleListReset = function() {
      if (this.insertFirstOption) {
        this.collection.add(this.insertFirstOption, {
          at: 0,
          silent: true
        });
      }
      return this.render();
    };

    PickListSelectController.prototype.render = function() {
      var self;
      $(this.el).empty();
      self = this;
      this.collection.each((function(_this) {
        return function(enm) {
          return _this.addOne(enm);
        };
      })(this));
      if (this.selectedCode) {
        $(this.el).val(this.selectedCode);
      }
      $(this.el).hide();
      $(this.el).show();
      return this.rendered = true;
    };

    PickListSelectController.prototype.addOne = function(enm) {
      if (!enm.get('ignored')) {
        return $(this.el).append(new PickListOptionController({
          model: enm
        }).render().el);
      }
    };

    PickListSelectController.prototype.setSelectedCode = function(code) {
      this.selectedCode = code;
      if (this.rendered) {
        return $(this.el).val(this.selectedCode);
      }
    };

    PickListSelectController.prototype.getSelectedCode = function() {
      return $(this.el).val();
    };

    PickListSelectController.prototype.getSelectedModel = function() {
      return this.collection.getModelWithCode(this.getSelectedCode());
    };

    return PickListSelectController;

  })(Backbone.View);

  window.EditablePickListSelectController = (function(_super) {
    __extends(EditablePickListSelectController, _super);

    function EditablePickListSelectController() {
      this.render = __bind(this.render, this);
      return EditablePickListSelectController.__super__.constructor.apply(this, arguments);
    }

    EditablePickListSelectController.prototype.template = _.template($("#EditablePickListView").html());

    EditablePickListSelectController.prototype.events = {
      "click .bv_addOptionBtn": "clearModal",
      "click .bv_addNewParameterOption": "addNewParameterOption"
    };

    EditablePickListSelectController.prototype.initialize = function() {
      return this.addedOptions = [];
    };

    EditablePickListSelectController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      this.setupEditablePickList();
      this.setupContextMenu();
      return this.setupEditingPrivileges();
    };

    EditablePickListSelectController.prototype.setupEditablePickList = function() {
      return this.pickListController = new PickListSelectController({
        el: this.$('.bv_parameterSelectList'),
        collection: this.collection,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select Rule"
        }),
        selectedCode: this.options.selectedCode
      });
    };

    EditablePickListSelectController.prototype.setupEditingPrivileges = function() {
      console.log("setup editing privileges");
      console.log(window.AppLaunchParams.loginUser);
      if (!UtilityFunctions.prototype.testUserHasRole(window.AppLaunchParams.loginUser, ["admin"])) {
        console.log("disable add button and insert tooltip");
        this.$('.bv_addOptionBtn').removeAttr('data-toggle');
        this.$('.bv_addOptionBtn').removeAttr('data-target');
        this.$('.bv_addOptionBtn').removeAttr('data-backdrop');
        this.$('.bv_addOptionBtn').css({
          'color': "#cccccc"
        });
        this.$('.bv_tooltipwrapper').tooltip();
        return this.$("body").tooltip({
          selector: '.bv_tooltipwrapper'
        });
      } else {
        return console.log("user can edit");
      }
    };

    EditablePickListSelectController.prototype.clearModal = function() {
      var parameterNameWithSpaces, pascalCaseParameterName;
      parameterNameWithSpaces = this.options.parameter.replace(/([A-Z])/g, ' $1');
      pascalCaseParameterName = parameterNameWithSpaces.charAt(0).toUpperCase() + parameterNameWithSpaces.slice(1);
      this.$('.bv_optionAddedMessage').hide();
      this.$('.bv_errorMessage').hide();
      this.$('.bv_parameter').html(pascalCaseParameterName);
      this.$('.bv_newOptionLabel').val("");
      this.$('.bv_newOptionDescription').val("");
      return this.$('.bv_newOptionComments').val("");
    };

    EditablePickListSelectController.prototype.addNewParameterOption = function() {
      var newOptionName;
      newOptionName = (this.$('.bv_newOptionLabel').val()).toLowerCase();
      if (this.validNewOption(newOptionName)) {
        console.log("valid new option. will add");
        this.$('.bv_parameterSelectList').append('<option value=' + newOptionName + '>' + newOptionName + '</option>');
        this.$('.bv_optionAddedMessage').show();
        this.$('.bv_errorMessage').hide();
        return this.addedOptions.push(newOptionName);
      } else {
        console.log("option already exists");
        this.$('.bv_optionAddedMessage').hide();
        return this.$('.bv_errorMessage').show();
      }
    };

    EditablePickListSelectController.prototype.validNewOption = function(newOptionName) {
      if (this.$('.bv_parameterSelectList option[value="' + newOptionName + '"]').length > 0) {
        return false;
      } else {
        return true;
      }
    };

    EditablePickListSelectController.prototype.saveNewOption = function() {
      var code;
      code = this.pickListController.getSelectedCode();
      if (__indexOf.call(this.addedOptions, code) >= 0) {
        return console.log("need to save new option to database");
      } else {
        return console.log("don't need to save to database");
      }
    };

    EditablePickListSelectController.prototype.setupContextMenu = function() {
      $.fn.contextMenu = function(settings) {
        var getLeftLocation, getTopLocation;
        getLeftLocation = function(e) {
          var absoluteMouseWidth, menuWidth, pageWidth, relativeMouseWidth;
          relativeMouseWidth = e.pageX - $(window).scrollLeft();
          absoluteMouseWidth = e.pageX;
          pageWidth = $(window).width();
          menuWidth = $(settings.menuSelector).width();
          if (relativeMouseWidth + menuWidth > pageWidth && menuWidth < relativeMouseWidth) {
            return absoluteMouseWidth - menuWidth;
          } else {
            return absoluteMouseWidth;
          }
        };
        getTopLocation = function(e) {
          var absoluteMouseHeight, menuHeight, pageHeight, relativeMouseHeight;
          relativeMouseHeight = e.pageY - $(window).scrollTop();
          absoluteMouseHeight = e.pageY;
          pageHeight = $(window).height();
          menuHeight = $(settings.menuSelector).height();
          if (relativeMouseHeight + menuHeight > pageHeight && menuHeight < relativeMouseHeight) {
            return absoluteMouseHeight - menuHeight;
          } else {
            return absoluteMouseHeight;
          }
        };
        return this.each(function() {
          $(this).on("contextmenu", function(e) {
            $(settings.menuSelector).data("invokedOn", $(e.target)).show().css({
              position: "absolute",
              left: getLeftLocation(e),
              top: getTopLocation(e)
            }).off("click").on("click", function(e) {
              var $invokedOn, $selectedMenu;
              $(this).hide();
              $invokedOn = $(this).data("invokedOn");
              $selectedMenu = $(e.target);
              return settings.menuSelected.call(this, $invokedOn, $selectedMenu);
            });
            return false;
          });
          return $(document).click(function() {
            return $(settings.menuSelector).hide();
          });
        });
      };
      return this.$('.bv_addOptionBtn').contextMenu({
        menuSelector: "#contextMenu",
        menuSelected: function(invokedOn, selectedMenu) {
          var msg;
          msg = "You selected the menu item '" + selectedMenu.text() + "' on the value '" + invokedOn.text() + "'";
          return alert(msg);
        }
      });
    };

    return EditablePickListSelectController;

  })(Backbone.View);

}).call(this);
