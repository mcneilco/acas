(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.PickList = (function(superClass) {
    extend(PickList, superClass);

    function PickList() {
      return PickList.__super__.constructor.apply(this, arguments);
    }

    return PickList;

  })(Backbone.Model);

  window.PickListList = (function(superClass) {
    extend(PickListList, superClass);

    function PickListList() {
      return PickListList.__super__.constructor.apply(this, arguments);
    }

    PickListList.prototype.model = PickList;

    PickListList.prototype.setType = function(type) {
      return this.type = type;
    };

    PickListList.prototype.getModelWithId = function(id) {
      return this.detect(function(enu) {
        return enu.get("id") === id;
      });
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

  window.PickListOptionController = (function(superClass) {
    extend(PickListOptionController, superClass);

    function PickListOptionController() {
      this.render = bind(this.render, this);
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

  window.PickListOptionControllerForLsThing = (function(superClass) {
    extend(PickListOptionControllerForLsThing, superClass);

    function PickListOptionControllerForLsThing() {
      this.render = bind(this.render, this);
      return PickListOptionControllerForLsThing.__super__.constructor.apply(this, arguments);
    }

    PickListOptionControllerForLsThing.prototype.tagName = "option";

    PickListOptionControllerForLsThing.prototype.initialize = function() {
      if (this.options.insertFirstOption != null) {
        this.insertFirstOption = this.options.insertFirstOption;
      } else {
        this.insertFirstOption = null;
      }
      if (this.options.displayName != null) {
        return this.displayName = this.options.displayName;
      } else {
        return this.displayName = null;
      }
    };

    PickListOptionControllerForLsThing.prototype.render = function() {
      var bestName, corpName, displayValue, notebookValue, preferredNames;
      if (this.displayName !== null) {
        if (this.displayName === 'corpName' || this.displayName === 'corpName_notebook') {
          if (!(this.model.get('lsLabels') instanceof LabelList)) {
            this.model.set('lsLabels', new LabelList(this.model.get('lsLabels')));
          }
          if (!(this.model.get('lsStates') instanceof StateList)) {
            this.model.set('lsStates', new StateList(this.model.get('lsStates')));
          }
          corpName = this.model.get('lsLabels').getACASLsThingCorpName();
          if (corpName != null) {
            displayValue = corpName.get('labelText');
            if (this.displayName === 'corpName_notebook') {
              notebookValue = this.model.get('lsStates').getOrCreateValueByTypeAndKind('metadata', this.model.get('lsKind') + ' batch', 'stringValue', 'notebook');
              displayValue = displayValue + " " + notebookValue.get('stringValue');
            }
          } else {
            displayValue = this.insertFirstOption.get('name');
          }
        } else if (this.model.get(this.displayName) != null) {
          displayValue = this.model.get(this.displayName);
        } else {
          displayValue = this.insertFirstOption.get('name');
        }
        $(this.el).attr("value", this.model.get("id")).text(displayValue);
      } else {
        preferredNames = _.filter(this.model.get('lsLabels'), function(lab) {
          return lab.preferred && (lab.lsType === "name") && !lab.ignored;
        });
        bestName = _.max(preferredNames, function(lab) {
          var rd;
          rd = lab.recordedDate;
          if (rd === "") {
            return Infinity;
          } else {
            return rd;
          }
        });
        if (bestName != null) {
          displayValue = bestName.labelText;
        } else if (this.model.get('codeName') != null) {
          displayValue = this.model.get('codeName');
        } else {
          displayValue = this.insertFirstOption.get('name');
        }
        $(this.el).attr("value", this.model.get("id")).text(displayValue);
      }
      return this;
    };

    return PickListOptionControllerForLsThing;

  })(Backbone.View);

  window.PickListSelectController = (function(superClass) {
    extend(PickListSelectController, superClass);

    function PickListSelectController() {
      this.checkOptionInCollection = bind(this.checkOptionInCollection, this);
      this.addOne = bind(this.addOne, this);
      this.render = bind(this.render, this);
      this.handleListReset = bind(this.handleListReset, this);
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
      if (this.options.showIgnored != null) {
        this.showIgnored = this.options.showIgnored;
      } else {
        this.showIgnored = false;
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
      if (this.autoFetch === true) {
        return this.collection.fetch({
          success: this.handleListReset
        });
      } else {
        return this.handleListReset();
      }
    };

    PickListSelectController.prototype.handleListReset = function() {
      var newOption;
      if (this.insertFirstOption) {
        this.collection.add(this.insertFirstOption, {
          at: 0,
          silent: true
        });
        if (!(this.selectedCode === this.insertFirstOption.get('code'))) {
          if ((this.collection.where({
            code: this.selectedCode
          })).length === 0) {
            newOption = new PickList({
              code: this.selectedCode,
              name: this.selectedCode
            });
            this.collection.add(newOption);
          }
        }
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
      var shouldRender;
      shouldRender = this.showIgnored;
      if (enm.get('ignored')) {
        if (this.selectedCode != null) {
          if (this.selectedCode === enm.get('code')) {
            shouldRender = true;
          }
        }
      } else {
        shouldRender = true;
      }
      if (shouldRender) {
        return $(this.el).append(new PickListOptionController({
          model: enm
        }).render().el);
      }
    };

    PickListSelectController.prototype.setSelectedCode = function(code) {
      this.selectedCode = code;
      if (this.rendered) {
        return $(this.el).val(this.selectedCode);
      } else {
        return "not done";
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

  window.PickListForLsThingsSelectController = (function(superClass) {
    extend(PickListForLsThingsSelectController, superClass);

    function PickListForLsThingsSelectController() {
      this.addOne = bind(this.addOne, this);
      this.handleListReset = bind(this.handleListReset, this);
      return PickListForLsThingsSelectController.__super__.constructor.apply(this, arguments);
    }

    PickListForLsThingsSelectController.prototype.initialize = function() {
      PickListForLsThingsSelectController.__super__.initialize.call(this);
      if (this.options.displayName != null) {
        return this.displayName = this.options.displayName;
      } else {
        return this.displayName = null;
      }
    };

    PickListForLsThingsSelectController.prototype.handleListReset = function() {
      var newOption;
      if (this.insertFirstOption) {
        this.collection.add(this.insertFirstOption, {
          at: 0,
          silent: true
        });
        if (!(this.selectedCode === this.insertFirstOption.get('code'))) {
          if ((this.collection.where({
            id: this.selectedCode
          })).length === 0) {
            newOption = new PickList({
              id: this.selectedCode,
              name: this.selectedCode
            });
            this.collection.add(newOption);
          }
        }
      }
      return this.render();
    };

    PickListForLsThingsSelectController.prototype.addOne = function(enm) {
      var shouldRender;
      shouldRender = this.showIgnored;
      if (enm.get('ignored')) {
        if (this.selectedCode != null) {
          if (this.selectedCode === enm.get('code')) {
            shouldRender = true;
          }
        }
      } else {
        shouldRender = true;
      }
      if (shouldRender) {
        return $(this.el).append(new PickListOptionControllerForLsThing({
          model: enm,
          insertFirstOption: this.insertFirstOption,
          displayName: this.displayName
        }).render().el);
      }
    };

    PickListForLsThingsSelectController.prototype.getSelectedModel = function() {
      return this.collection.getModelWithId(parseInt(this.getSelectedCode()));
    };

    return PickListForLsThingsSelectController;

  })(PickListSelectController);

  window.ComboBoxController = (function(superClass) {
    extend(ComboBoxController, superClass);

    function ComboBoxController() {
      this.handleListReset = bind(this.handleListReset, this);
      return ComboBoxController.__super__.constructor.apply(this, arguments);
    }

    ComboBoxController.prototype.handleListReset = function() {
      ComboBoxController.__super__.handleListReset.call(this);
      return $(this.el).combobox({
        bsVersion: '2'
      });
    };

    return ComboBoxController;

  })(PickListSelectController);

  window.AddParameterOptionPanel = (function(superClass) {
    extend(AddParameterOptionPanel, superClass);

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

  window.AddParameterOptionPanelController = (function(superClass) {
    extend(AddParameterOptionPanelController, superClass);

    function AddParameterOptionPanelController() {
      this.clearValidationErrorStyles = bind(this.clearValidationErrorStyles, this);
      this.validationError = bind(this.validationError, this);
      this.triggerAddRequest = bind(this.triggerAddRequest, this);
      this.updateModel = bind(this.updateModel, this);
      this.showModal = bind(this.showModal, this);
      this.render = bind(this.render, this);
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
      this.$('.bv_addParameterOptionModal').on('hidden.bs.modal', (function(_this) {
        return function() {
          return _this.trigger('hideModal');
        };
      })(this));
      this.$('.bv_addParameterOptionModal').on('show.bs.modal', (function(_this) {
        return function() {
          return _this.trigger('showModal');
        };
      })(this));
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

  window.EditablePickListSelectController = (function(superClass) {
    extend(EditablePickListSelectController, superClass);

    function EditablePickListSelectController() {
      this.saveNewOption = bind(this.saveNewOption, this);
      this.handleAddOptionRequested = bind(this.handleAddOptionRequested, this);
      this.handleShowAddPanel = bind(this.handleShowAddPanel, this);
      this.setupEditingPrivileges = bind(this.setupEditingPrivileges, this);
      this.render = bind(this.render, this);
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
      var parameterNameWithSpaces, pascalCaseParameterName;
      parameterNameWithSpaces = this.options.parameter.replace(/([A-Z])/g, ' $1');
      pascalCaseParameterName = parameterNameWithSpaces.charAt(0).toUpperCase() + parameterNameWithSpaces.slice(1);
      return this.pickListController = new PickListSelectController({
        el: this.$('.bv_parameterSelectList'),
        collection: this.collection,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select " + pascalCaseParameterName
        }),
        selectedCode: this.options.selectedCode
      });
    };

    EditablePickListSelectController.prototype.setupEditingPrivileges = function() {
      if (this.options.roles != null) {
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
      } else {
        this.$('.bv_tooltipWrapper').removeAttr('data-toggle');
        return this.$('.bv_tooltipWrapper').removeAttr('data-original-title');
      }
    };

    EditablePickListSelectController.prototype.getSelectedCode = function() {
      return this.pickListController.getSelectedCode();
    };

    EditablePickListSelectController.prototype.setSelectedCode = function(code) {
      return this.pickListController.setSelectedCode(code);
    };

    EditablePickListSelectController.prototype.handleShowAddPanel = function() {
      var showPanel;
      showPanel = false;
      if (this.options.roles != null) {
        if (UtilityFunctions.prototype.testUserHasRole(window.AppLaunchParams.loginUser, this.options.roles)) {
          showPanel = true;
        }
      } else {
        showPanel = true;
      }
      if (showPanel) {
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
          this.addPanelController.on('showModal', (function(_this) {
            return function() {
              return _this.trigger('showModal');
            };
          })(this));
          this.addPanelController.on('hideModal', (function(_this) {
            return function() {
              return _this.trigger('hideModal');
            };
          })(this));
        }
        return this.addPanelController.render();
      }
    };

    EditablePickListSelectController.prototype.handleAddOptionRequested = function() {
      var newOptionCode, newPickList, requestedOptionModel;
      requestedOptionModel = this.addPanelController.model;
      newOptionCode = requestedOptionModel.get('newOptionLabel');
      if (this.pickListController.checkOptionInCollection(newOptionCode) === void 0) {
        newPickList = new PickList({
          code: newOptionCode,
          name: newOptionCode,
          ignored: false,
          codeType: requestedOptionModel.get('codeType'),
          codeKind: requestedOptionModel.get('codeKind'),
          codeOrigin: requestedOptionModel.get('codeOrigin'),
          description: requestedOptionModel.get('newOptionDescription'),
          comments: requestedOptionModel.get('newOptionComments')
        });
        this.pickListController.collection.add(newPickList);
        this.pickListController.setSelectedCode(newPickList.get('code'));
        this.trigger('change');
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
      if (selectedModel !== void 0 && selectedModel.get('code') !== "unassigned") {
        if (selectedModel.get('id') != null) {
          return callback.call();
        } else {
          if (selectedModel.get('codeType') == null) {
            selectedModel.set('codeType', this.options.codeType);
          }
          if (selectedModel.get('codeKind') == null) {
            selectedModel.set('codeKind', this.options.codeKind);
          }
          return $.ajax({
            type: 'POST',
            url: "/api/codetables",
            data: JSON.stringify({
              codeEntry: selectedModel
            }),
            contentType: 'application/json',
            dataType: 'json',
            success: (function(_this) {
              return function(response) {
                return callback.call();
              };
            })(this),
            error: (function(_this) {
              return function(err) {
                alert('could not add option to code table');
                return _this.serviceReturn = null;
              };
            })(this)
          });
        }
      } else {
        return callback.call();
      }
    };

    return EditablePickListSelectController;

  })(Backbone.View);

}).call(this);
