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
      codeType: null,
      codeOrigin: "ACAS DDICT",
      codeKind: null,
      newOptionLabel: null,
      newOptionDescription: null,
      newOptionComments: null
    };

    AddParameterOptionPanel.prototype.validate = function(attrs) {
      var errors;
      errors = [];
      if (attrs.newOptionLabel === null || attrs.newOptionLabel === "") {
        errors.push({
          attribute: 'newOptionLabel',
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
      this.$('.bv_addParameterOptionModal').modal('show');
      parameterNameWithSpaces = this.model.get('parameter').replace(/([A-Z])/g, ' $1');
      pascalCaseParameterName = parameterNameWithSpaces.charAt(0).toUpperCase() + parameterNameWithSpaces.slice(1);
      return this.$('.bv_parameter').html(pascalCaseParameterName);
    };

    AddParameterOptionPanelController.prototype.hideModal = function() {
      return this.$('.bv_addParameterOptionModal').modal('hide');
    };

    AddParameterOptionPanelController.prototype.updateModel = function() {
      return this.model.set({
        newOptionLabel: UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_newOptionLabel')),
        newOptionDescription: UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_newOptionDescription')),
        newOptionComments: UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_newOptionComments'))
      });
    };

    AddParameterOptionPanelController.prototype.triggerAddRequest = function() {
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

    EditablePickListSelectController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      this.setupEditablePickList();
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
      if (UtilityFunctions.prototype.testUserHasRole(window.AppLaunchParams.loginUser, this.options.roles)) {
        this.$('.bv_tooltipWrapper').removeAttr('data-toggle');
        return this.$('.bv_tooltipWrapper').removeAttr('data-original-title');
      } else {
        this.$('.bv_addOptionBtn').removeAttr('data-toggle');
        this.$('.bv_addOptionBtn').removeAttr('data-target');
        this.$('.bv_addOptionBtn').removeAttr('data-backdrop');
        this.$('.bv_addOptionBtn').css({
          'color': "#cccccc"
        });
        this.$('.bv_tooltipWrapper').tooltip();
        return this.$("body").tooltip({
          selector: '.bv_tooltipWrapper'
        });
      }
    };

    EditablePickListSelectController.prototype.getSelectedCode = function() {
      return this.pickListController.getSelectedCode();
    };

    EditablePickListSelectController.prototype.handleShowAddPanel = function() {
      if (UtilityFunctions.prototype.testUserHasRole(window.AppLaunchParams.loginUser, this.options.roles)) {
        if (this.addPanelController == null) {
          this.addPanelController = new AddParameterOptionPanelController({
            model: new AddParameterOptionPanel({
              parameter: this.options.parameter,
              codeType: this.options.codeType,
              codeKind: this.options.codeKind
            }),
            el: this.$('.bv_addOptionPanel')
          });
          this.addPanelController.on('addOptionRequested', this.handleAddOptionRequested);
        }
        return this.addPanelController.render();
      }
    };

    EditablePickListSelectController.prototype.handleAddOptionRequested = function() {
      var newOptionCode, newPickList, requestedOptionModel;
      requestedOptionModel = this.addPanelController.model;
      newOptionCode = requestedOptionModel.get('newOptionLabel').toLowerCase();
      if (this.pickListController.checkOptionInCollection(newOptionCode) === void 0) {
        newPickList = new PickList({
          code: newOptionCode,
          name: requestedOptionModel.get('newOptionLabel'),
          ignored: false,
          codeType: requestedOptionModel.get('codeType'),
          codeKind: requestedOptionModel.get('codeKind'),
          codeOrigin: requestedOptionModel.get('codeOrigin'),
          description: requestedOptionModel.get('newOptionDescription'),
          comments: requestedOptionModel.get('newOptionComments')
        });
        this.pickListController.collection.add(newPickList);
        this.pickListController.setSelectedCode(newPickList.get('code'));
        this.$('.bv_errorMessage').hide();
        return this.addPanelController.hideModal();
      } else {
        return this.$('.bv_errorMessage').show();
      }
    };

    EditablePickListSelectController.prototype.hideAddOptionButton = function() {
      return this.$('.bv_addOptionBtn').hide();
    };

    EditablePickListSelectController.prototype.showAddOptionButton = function() {
      return this.$('.bv_addOptionBtn').show();
    };

    EditablePickListSelectController.prototype.saveNewOption = function(callback) {
      var code, selectedModel;
      code = this.pickListController.getSelectedCode();
      selectedModel = this.pickListController.collection.getModelWithCode(code);
      if (selectedModel !== void 0) {
        if (selectedModel.get('id') != null) {
          return callback.call();
        } else {
          return $.ajax({
            type: 'POST',
            url: "/api/codetables/" + selectedModel.get('codeType') + "/" + selectedModel.get('codeKind'),
            data: selectedModel,
            success: callback.call(),
            error: (function(_this) {
              return function(err) {
                alert('could not add option to code table');
                return _this.serviceReturn = null;
              };
            })(this),
            dataType: 'json'
          });
        }
      } else {
        return callback.call();
      }
    };

    return EditablePickListSelectController;

  })(Backbone.View);

}).call(this);
