(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

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
      this.checkOptionInCollection = __bind(this.checkOptionInCollection, this);
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

    PickListSelectController.prototype.checkOptionInCollection = function(code) {
      console.log("checking Option");
      return this.collection.findWhere({
        code: code
      });
    };

    return PickListSelectController;

  })(Backbone.View);

  window.AddParameterOptionPanel = (function(_super) {
    __extends(AddParameterOptionPanel, _super);

    function AddParameterOptionPanel() {
      return AddParameterOptionPanel.__super__.constructor.apply(this, arguments);
    }

    AddParameterOptionPanel.prototype.defaults = {
      parameter: null,
      newOptionLabel: null,
      newOptionDescription: null,
      newOptionComments: null
    };

    AddParameterOptionPanel.prototype.validate = function(attrs) {
      var errors;
      console.log("validating add option panel");
      console.log(attrs);
      errors = [];
      if (attrs.newOptionLabel === null || attrs.newOptionLabel === "") {
        errors.push({
          attribute: 'newOptionLabel',
          message: "Label must be set"
        });
      }
      if (attrs.newOptionDescription === null || attrs.newOptionDescription === "") {
        errors.push({
          attribute: 'newOptionDescription',
          message: "Description must be set"
        });
      }
      if (attrs.newOptionComments === null || attrs.newOptionComments === "") {
        errors.push({
          attribute: 'newOptionComments',
          message: "Label must be set"
        });
      }
      if (errors.length > 0) {
        return errors;
      } else {
        return null;
      }
    };

    return AddParameterOptionPanel;

  })(Backbone.Model);

  window.AddParameterOptionPanelController = (function(_super) {
    __extends(AddParameterOptionPanelController, _super);

    function AddParameterOptionPanelController() {
      this.clearValidationErrorStyles = __bind(this.clearValidationErrorStyles, this);
      this.validationError = __bind(this.validationError, this);
      this.triggerAddRequest = __bind(this.triggerAddRequest, this);
      this.updateModel = __bind(this.updateModel, this);
      this.showModal = __bind(this.showModal, this);
      this.render = __bind(this.render, this);
      return AddParameterOptionPanelController.__super__.constructor.apply(this, arguments);
    }

    AddParameterOptionPanelController.prototype.template = _.template($("#AddParameterOptionPanelView").html());

    AddParameterOptionPanelController.prototype.events = {
      "change .bv_newOptionLabel": "attributeChanged",
      "change .bv_newOptionDescription": "attributeChanged",
      "change .bv_newOptionComments": "attributeChanged",
      "click .bv_addNewParameterOption": "triggerAddRequest"
    };

    AddParameterOptionPanelController.prototype.initialize = function() {
      this.errorOwnerName = 'AddParameterOptionPanelController';
      return this.setBindings();
    };

    AddParameterOptionPanelController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      this.showModal();
      return this;
    };

    AddParameterOptionPanelController.prototype.showModal = function() {
      var parameterNameWithSpaces, pascalCaseParameterName;
      console.log("add option button clicked");
      this.$('.bv_addParameterOptionModal').modal('show');
      parameterNameWithSpaces = this.model.get('parameter').replace(/([A-Z])/g, ' $1');
      pascalCaseParameterName = parameterNameWithSpaces.charAt(0).toUpperCase() + parameterNameWithSpaces.slice(1);
      return this.$('.bv_parameter').html(pascalCaseParameterName);
    };

    AddParameterOptionPanelController.prototype.updateModel = function() {
      console.log("updating model");
      this.model.set({
        newOptionLabel: this.getTrimmedInput('.bv_newOptionLabel'),
        newOptionDescription: this.getTrimmedInput('.bv_newOptionDescription'),
        newOptionComments: this.getTrimmedInput('.bv_newOptionComments')
      });
      return console.log(this.model.get('newOptionLabel'));
    };

    AddParameterOptionPanelController.prototype.triggerAddRequest = function() {
      console.log("trigger add request");
      return this.trigger('addOptionRequested');
    };

    AddParameterOptionPanelController.prototype.validationError = function() {
      AddParameterOptionPanelController.__super__.validationError.call(this);
      return this.$('.bv_addNewParameterOption').attr('disabled', 'disabled');
    };

    AddParameterOptionPanelController.prototype.clearValidationErrorStyles = function() {
      AddParameterOptionPanelController.__super__.clearValidationErrorStyles.call(this);
      return this.$('.bv_addNewParameterOption').removeAttr('disabled');
    };

    return AddParameterOptionPanelController;

  })(AbstractFormController);

  window.EditablePickListSelectController = (function(_super) {
    __extends(EditablePickListSelectController, _super);

    function EditablePickListSelectController() {
      this.handleAddOptionRequested = __bind(this.handleAddOptionRequested, this);
      this.handleShowAddPanel = __bind(this.handleShowAddPanel, this);
      this.setupEditingPrivileges = __bind(this.setupEditingPrivileges, this);
      this.render = __bind(this.render, this);
      return EditablePickListSelectController.__super__.constructor.apply(this, arguments);
    }

    EditablePickListSelectController.prototype.template = _.template($("#EditablePickListView").html());

    EditablePickListSelectController.prototype.events = {
      "click .bv_addOptionBtn": "handleShowAddPanel"
    };

    EditablePickListSelectController.prototype.initialize = function() {
      console.log("initialize editable pick list");
      return console.log(this.options.parameter);
    };

    EditablePickListSelectController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      this.setupEditablePickList();
      return this.setupEditingPrivileges();
    };

    EditablePickListSelectController.prototype.setupEditablePickList = function() {
      console.log("setting up editable picklist");
      this.pickListController = new PickListSelectController({
        el: this.$('.bv_parameterSelectList'),
        collection: this.collection,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select Rule"
        }),
        selectedCode: this.options.selectedCode
      });
      return console.log("finished setting up picklist");
    };

    EditablePickListSelectController.prototype.setupEditingPrivileges = function() {
      console.log("setup editing privileges");
      console.log(window.AppLaunchParams.loginUser);
      console.log(this.options.roles);
      if (!UtilityFunctions.prototype.testUserHasRole(window.AppLaunchParams.loginUser, this.options.roles)) {
        console.log("disable add button and insert tooltip");
        this.$('.bv_addOptionBtn').removeAttr('data-toggle');
        this.$('.bv_addOptionBtn').removeAttr('data-target');
        this.$('.bv_addOptionBtn').removeAttr('data-backdrop');
        this.$('.bv_addOptionBtn').css({
          'color': "#cccccc"
        });
        this.$('.bv_tooltipwrapper').tooltip();
        this.$("body").tooltip({
          selector: '.bv_tooltipwrapper'
        });
        return this.$('.bv_addOptionBtn');
      } else {
        return console.log("user can edit");
      }
    };

    EditablePickListSelectController.prototype.getSelectedCode = function() {
      return this.pickListController.getSelectedCode();
    };

    EditablePickListSelectController.prototype.handleShowAddPanel = function() {
      console.log("handle show add panel");
      if (UtilityFunctions.prototype.testUserHasRole(window.AppLaunchParams.loginUser, this.options.roles)) {
        console.log("setting up add panel");
        if (this.addPanelController == null) {
          this.addPanelController = new AddParameterOptionPanelController({
            model: new AddParameterOptionPanel({
              parameter: this.options.parameter
            }),
            el: this.$('.bv_addOptionPanel')
          });
          this.addPanelController.on('addOptionRequested', this.handleAddOptionRequested);
        }
        return this.addPanelController.render();
      }
    };

    EditablePickListSelectController.prototype.handleAddOptionRequested = function() {
      var newOptionName, newPickList;
      console.log("add new parameter option clicked");
      newOptionName = this.addPanelController.model.get('newOptionLabel').toLowerCase();
      if (this.pickListController.checkOptionInCollection(newOptionName) === void 0) {
        console.log("valid new option. will add");
        newPickList = new PickList({
          code: newOptionName,
          name: newOptionName,
          ignored: false,
          newOption: true
        });
        this.pickListController.collection.add(newPickList);
        this.$('.bv_optionAddedMessage').show();
        return this.$('.bv_errorMessage').hide();
      } else {
        console.log("option already exists");
        this.$('.bv_optionAddedMessage').hide();
        return this.$('.bv_errorMessage').show();
      }
    };

    EditablePickListSelectController.prototype.hideAddOptionButton = function() {
      console.log("hide add button");
      return this.$('.bv_addOptionBtn').hide();
    };

    EditablePickListSelectController.prototype.showAddOptionButton = function() {
      console.log("show add button");
      return this.$('.bv_addOptionBtn').show();
    };

    EditablePickListSelectController.prototype.saveNewOption = function() {
      var code, selectedModel;
      console.log("saveNewOption");
      code = this.pickListController.getSelectedCode();
      selectedModel = this.pickListController.collection.getModelWithCode(code);
      console.log(selectedModel);
      console.log(selectedModel.get('newOption'));
      if (selectedModel.get('newOption')) {
        console.log("new Option");
        selectedModel.unset('newOption');
        console.log(selectedModel);
        return console.log(this.pickListController.collection.getModelWithCode(code));
      } else {
        return console.log("don't need to save to database");
      }
    };

    return EditablePickListSelectController;

  })(Backbone.View);

}).call(this);
