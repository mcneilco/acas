(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.AbstractProtocolParameter = (function(_super) {
    __extends(AbstractProtocolParameter, _super);

    function AbstractProtocolParameter() {
      this.triggerAmDirty = __bind(this.triggerAmDirty, this);
      return AbstractProtocolParameter.__super__.constructor.apply(this, arguments);
    }

    AbstractProtocolParameter.prototype.defaults = {
      parameter: "abstractParameter"
    };

    AbstractProtocolParameter.prototype.triggerAmDirty = function() {
      return this.trigger('amDirty', this);
    };

    return AbstractProtocolParameter;

  })(Backbone.Model);

  window.AssayActivity = (function(_super) {
    __extends(AssayActivity, _super);

    function AssayActivity() {
      return AssayActivity.__super__.constructor.apply(this, arguments);
    }

    AssayActivity.prototype.defaults = {
      parameter: "assayActivity",
      assayActivity: "unassigned"
    };

    return AssayActivity;

  })(AbstractProtocolParameter);

  window.TargetOrigin = (function(_super) {
    __extends(TargetOrigin, _super);

    function TargetOrigin() {
      return TargetOrigin.__super__.constructor.apply(this, arguments);
    }

    TargetOrigin.prototype.defaults = {
      parameter: "targetOrigin",
      targetOrigin: "unassigned"
    };

    return TargetOrigin;

  })(AbstractProtocolParameter);

  window.AssayType = (function(_super) {
    __extends(AssayType, _super);

    function AssayType() {
      return AssayType.__super__.constructor.apply(this, arguments);
    }

    AssayType.prototype.defaults = {
      parameter: "assayType",
      assayType: "unassigned"
    };

    return AssayType;

  })(AbstractProtocolParameter);

  window.AssayTechnology = (function(_super) {
    __extends(AssayTechnology, _super);

    function AssayTechnology() {
      return AssayTechnology.__super__.constructor.apply(this, arguments);
    }

    AssayTechnology.prototype.defaults = {
      parameter: "assayTechnology",
      assayTechnology: "unassigned"
    };

    return AssayTechnology;

  })(AbstractProtocolParameter);

  window.CellLine = (function(_super) {
    __extends(CellLine, _super);

    function CellLine() {
      return CellLine.__super__.constructor.apply(this, arguments);
    }

    CellLine.prototype.defaults = {
      parameter: "cellLine",
      cellLine: "unassigned"
    };

    return CellLine;

  })(AbstractProtocolParameter);

  window.AbstractProtocolParameterList = (function(_super) {
    __extends(AbstractProtocolParameterList, _super);

    function AbstractProtocolParameterList() {
      return AbstractProtocolParameterList.__super__.constructor.apply(this, arguments);
    }

    AbstractProtocolParameterList.prototype.validateCollection = function() {
      var currentRule, index, model, modelErrors, parameter, usedRules, _i, _ref;
      modelErrors = [];
      usedRules = {};
      if (this.length !== 0) {
        for (index = _i = 0, _ref = this.length - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; index = 0 <= _ref ? ++_i : --_i) {
          model = this.at(index);
          parameter = model.get('parameter');
          currentRule = model.get(parameter);
          if (currentRule in usedRules) {
            modelErrors.push({
              attribute: parameter + ':eq(' + index + ')',
              message: parameter + " can not be chosen more than once"
            });
            modelErrors.push({
              attribute: parameter + ':eq(' + usedRules[currentRule] + ')',
              message: parameter + " can not be chosen more than once"
            });
          } else {
            usedRules[currentRule] = index;
          }
        }
      }
      return modelErrors;
    };

    return AbstractProtocolParameterList;

  })(Backbone.Collection);

  window.AssayActivityList = (function(_super) {
    __extends(AssayActivityList, _super);

    function AssayActivityList() {
      return AssayActivityList.__super__.constructor.apply(this, arguments);
    }

    AssayActivityList.prototype.model = AssayActivity;

    return AssayActivityList;

  })(AbstractProtocolParameterList);

  window.TargetOriginList = (function(_super) {
    __extends(TargetOriginList, _super);

    function TargetOriginList() {
      return TargetOriginList.__super__.constructor.apply(this, arguments);
    }

    TargetOriginList.prototype.model = TargetOrigin;

    return TargetOriginList;

  })(AbstractProtocolParameterList);

  window.AssayTypeList = (function(_super) {
    __extends(AssayTypeList, _super);

    function AssayTypeList() {
      return AssayTypeList.__super__.constructor.apply(this, arguments);
    }

    AssayTypeList.prototype.model = AssayType;

    return AssayTypeList;

  })(AbstractProtocolParameterList);

  window.AssayTechnologyList = (function(_super) {
    __extends(AssayTechnologyList, _super);

    function AssayTechnologyList() {
      return AssayTechnologyList.__super__.constructor.apply(this, arguments);
    }

    AssayTechnologyList.prototype.model = AssayTechnology;

    return AssayTechnologyList;

  })(AbstractProtocolParameterList);

  window.CellLineList = (function(_super) {
    __extends(CellLineList, _super);

    function CellLineList() {
      return CellLineList.__super__.constructor.apply(this, arguments);
    }

    CellLineList.prototype.model = CellLine;

    return CellLineList;

  })(AbstractProtocolParameterList);

  window.Protocol = (function(_super) {
    __extends(Protocol, _super);

    function Protocol() {
      this.fixCompositeClasses = __bind(this.fixCompositeClasses, this);
      this.parse = __bind(this.parse, this);
      return Protocol.__super__.constructor.apply(this, arguments);
    }

    Protocol.prototype.urlRoot = "/api/protocols";

    Protocol.prototype.defaults = function() {
      return _(Protocol.__super__.defaults.call(this)).extend({
        assayTreeRule: null,
        dnsTargetList: true,
        assayStage: "unassigned",
        maxY: 100,
        minY: 0,
        assayActivityList: new AssayActivityList(),
        targetOriginList: new TargetOriginList(),
        assayTypeList: new AssayTypeList()
      });
    };

    Protocol.prototype.initialize = function() {
      this.set({
        subclass: "protocol"
      });
      return Protocol.__super__.initialize.call(this);
    };

    Protocol.prototype.parse = function(resp) {
      if (resp.lsLabels != null) {
        if (!(resp.lsLabels instanceof LabelList)) {
          resp.lsLabels = new LabelList(resp.lsLabels);
          resp.lsLabels.on('change', (function(_this) {
            return function() {
              return _this.trigger('change');
            };
          })(this));
        }
      }
      if (resp.lsStates != null) {
        if (!(resp.lsStates instanceof StateList)) {
          resp.lsStates = new StateList(resp.lsStates);
          resp.lsStates.on('change', (function(_this) {
            return function() {
              return _this.trigger('change');
            };
          })(this));
        }
      }
      if (!(resp.lsTags instanceof TagList)) {
        resp.lsTags = new TagList(resp.lsTags);
        resp.lsTags.on('change', (function(_this) {
          return function() {
            return _this.trigger('change');
          };
        })(this));
      }
      if (!(resp.assayActivityList instanceof AssayActivityList)) {
        resp.assayActivityList = new AssayActivityList(resp.assayActivityList);
        resp.assayActivityList.on('change', (function(_this) {
          return function() {
            return _this.trigger('change');
          };
        })(this));
      }
      if (!(resp.targetOriginList instanceof TargetOriginList)) {
        resp.targetOriginList = new TargetOriginList(resp.targetOriginList);
        resp.targetOriginList.on('change', (function(_this) {
          return function() {
            return _this.trigger('change');
          };
        })(this));
      }
      if (!(resp.assayTypeList instanceof AssayTypeList)) {
        resp.assayTypeList = new AssayTypeList(resp.assayTypeList);
        resp.assayTypeList.on('change', (function(_this) {
          return function() {
            return _this.trigger('change');
          };
        })(this));
      }
      if (!(resp.assayTechnologyList instanceof AssayTechnologyList)) {
        resp.assayTechnologyList = new AssayTechnologyList(resp.assayTechnologyList);
        resp.assayTechnologyList.on('change', (function(_this) {
          return function() {
            return _this.trigger('change');
          };
        })(this));
      }
      if (!(resp.cellLineList instanceof CellLineList)) {
        resp.cellLineList = new CellLineList(resp.cellLineList);
        resp.cellLineList.on('change', (function(_this) {
          return function() {
            return _this.trigger('change');
          };
        })(this));
      }
      return resp;
    };

    Protocol.prototype.fixCompositeClasses = function() {
      if (!(this.get('assayActivityList') instanceof AssayActivityList)) {
        this.set({
          assayActivityList: new AssayActivityList(this.get('assayActivityList'))
        });
      }
      this.get('assayActivityList').on("change", (function(_this) {
        return function() {
          return _this.trigger('change');
        };
      })(this));
      this.get('assayActivityList').on("amDirty", (function(_this) {
        return function() {
          return _this.trigger('amDirty');
        };
      })(this));
      if (!(this.get('targetOriginList') instanceof TargetOriginList)) {
        this.set({
          targetOriginList: new TargetOriginList(this.get('targetOriginList'))
        });
      }
      this.get('targetOriginList').on("change", (function(_this) {
        return function() {
          return _this.trigger('change');
        };
      })(this));
      this.get('targetOriginList').on("amDirty", (function(_this) {
        return function() {
          return _this.trigger('amDirty');
        };
      })(this));
      if (!(this.get('assayTypeList') instanceof AssayTypeList)) {
        this.set({
          assayTypeList: new AssayTypeList(this.get('assayTypeList'))
        });
      }
      this.get('assayTypeList').on("change", (function(_this) {
        return function() {
          return _this.trigger('change');
        };
      })(this));
      this.get('assayTypeList').on("amDirty", (function(_this) {
        return function() {
          return _this.trigger('amDirty');
        };
      })(this));
      if (!(this.get('assayTechnologyList') instanceof AssayTechnologyList)) {
        this.set({
          assayTechnologyList: new AssayTechnologyList(this.get('assayTechnologyList'))
        });
      }
      this.get('assayTechnologyList').on("change", (function(_this) {
        return function() {
          return _this.trigger('change');
        };
      })(this));
      this.get('assayTechnologyList').on("amDirty", (function(_this) {
        return function() {
          return _this.trigger('amDirty');
        };
      })(this));
      if (!(this.get('cellLineList') instanceof CellLineList)) {
        this.set({
          cellLineList: new CellLineList(this.get('cellLineList'))
        });
      }
      this.get('cellLineList').on("change", (function(_this) {
        return function() {
          return _this.trigger('change');
        };
      })(this));
      this.get('cellLineList').on("amDirty", (function(_this) {
        return function() {
          return _this.trigger('amDirty');
        };
      })(this));
      return Protocol.__super__.fixCompositeClasses.call(this);
    };

    Protocol.prototype.validate = function(attrs) {
      var assayActivityErrors, assayTechnologyErrors, assayTypeErrors, bestName, cellLineErrors, errors, nameError, notebook, targetOriginErrors;
      errors = [];
      assayActivityErrors = this.get('assayActivityList').validateCollection();
      errors.push.apply(errors, assayActivityErrors);
      targetOriginErrors = this.get('targetOriginList').validateCollection();
      errors.push.apply(errors, targetOriginErrors);
      assayTypeErrors = this.get('assayTypeList').validateCollection();
      errors.push.apply(errors, assayTypeErrors);
      assayTechnologyErrors = this.get('assayTechnologyList').validateCollection();
      errors.push.apply(errors, assayTechnologyErrors);
      cellLineErrors = this.get('cellLineList').validateCollection();
      errors.push.apply(errors, cellLineErrors);
      bestName = attrs.lsLabels.pickBestName();
      nameError = true;
      if (bestName != null) {
        nameError = true;
        if (bestName.get('labelText') !== "") {
          nameError = false;
        }
      }
      if (nameError) {
        errors.push({
          attribute: 'protocolName',
          message: attrs.subclass + " name must be set"
        });
      }
      if (_.isNaN(attrs.recordedDate)) {
        errors.push({
          attribute: 'recordedDate',
          message: attrs.subclass + " date must be set"
        });
      }
      if (attrs.recordedBy === "") {
        errors.push({
          attribute: 'recordedBy',
          message: "Scientist must be set"
        });
      }
      notebook = this.getNotebook().get('stringValue');
      if (notebook === "" || notebook === "unassigned" || notebook === void 0) {
        errors.push({
          attribute: 'notebook',
          message: "Notebook must be set"
        });
      }
      if (_.isNaN(attrs.maxY)) {
        errors.push({
          attribute: 'maxY',
          message: "maxY must be a number"
        });
      }
      if (_.isNaN(attrs.minY)) {
        errors.push({
          attribute: 'minY',
          message: "minY must be a number"
        });
      }
      if (errors.length > 0) {
        return errors;
      } else {
        return null;
      }
    };

    Protocol.prototype.isStub = function() {
      return this.get('lsLabels').length === 0;
    };

    return Protocol;

  })(BaseEntity);

  window.ProtocolList = (function(_super) {
    __extends(ProtocolList, _super);

    function ProtocolList() {
      return ProtocolList.__super__.constructor.apply(this, arguments);
    }

    ProtocolList.prototype.model = Protocol;

    return ProtocolList;

  })(Backbone.Collection);

  window.AbstractProtocolParameterController = (function(_super) {
    __extends(AbstractProtocolParameterController, _super);

    function AbstractProtocolParameterController() {
      this.clear = __bind(this.clear, this);
      this.render = __bind(this.render, this);
      return AbstractProtocolParameterController.__super__.constructor.apply(this, arguments);
    }

    AbstractProtocolParameterController.prototype.initialize = function() {
      this.setBindings();
      return this.model.on("destroy", this.remove, this);
    };

    AbstractProtocolParameterController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template(this.model.attributes));
      this.setUpParameterSelect();
      return this;
    };

    AbstractProtocolParameterController.prototype.setUpParameterSelect = function() {
      var formattedParameterName, parameter;
      parameter = this.model.get('parameter');
      formattedParameterName = parameter.replace(/([a-z](?=[A-Z]))/g, '$1 ');
      formattedParameterName = formattedParameterName.toLowerCase();
      this.parameterList = new PickListList();
      this.parameterList.url = "/api/dataDict/" + parameter + "Codes";
      return this.parameterList = new PickListSelectController({
        el: this.$('.bv_' + parameter),
        collection: this.parameterList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select " + formattedParameterName
        }),
        selectedCode: this.model.get(parameter)
      });
    };

    AbstractProtocolParameterController.prototype.clear = function() {
      this.model.destroy();
      return this.model.triggerAmDirty();
    };

    return AbstractProtocolParameterController;

  })(AbstractFormController);

  window.AssayActivityController = (function(_super) {
    __extends(AssayActivityController, _super);

    function AssayActivityController() {
      this.updateModel = __bind(this.updateModel, this);
      return AssayActivityController.__super__.constructor.apply(this, arguments);
    }

    AssayActivityController.prototype.template = _.template($("#AssayActivityView").html());

    AssayActivityController.prototype.events = {
      "change .bv_assayActivity": "attributeChanged",
      "click .bv_deleteActivity": "clear"
    };

    AssayActivityController.prototype.initialize = function() {
      this.errorOwnerName = 'AssayActivityController';
      return AssayActivityController.__super__.initialize.call(this);
    };

    AssayActivityController.prototype.updateModel = function() {
      this.model.set({
        assayActivity: this.$('.bv_assayActivity').val()
      });
      return this.model.triggerAmDirty();
    };

    return AssayActivityController;

  })(AbstractProtocolParameterController);

  window.TargetOriginController = (function(_super) {
    __extends(TargetOriginController, _super);

    function TargetOriginController() {
      this.updateModel = __bind(this.updateModel, this);
      return TargetOriginController.__super__.constructor.apply(this, arguments);
    }

    TargetOriginController.prototype.template = _.template($("#TargetOriginView").html());

    TargetOriginController.prototype.events = {
      "change .bv_targetOrigin": "attributeChanged",
      "click .bv_deleteTargetOrigin": "clear"
    };

    TargetOriginController.prototype.initialize = function() {
      this.errorOwnerName = 'TargetOriginController';
      return TargetOriginController.__super__.initialize.call(this);
    };

    TargetOriginController.prototype.updateModel = function() {
      this.model.set({
        targetOrigin: this.$('.bv_targetOrigin').val()
      });
      return this.model.triggerAmDirty();
    };

    return TargetOriginController;

  })(AbstractProtocolParameterController);

  window.AssayTypeController = (function(_super) {
    __extends(AssayTypeController, _super);

    function AssayTypeController() {
      this.updateModel = __bind(this.updateModel, this);
      return AssayTypeController.__super__.constructor.apply(this, arguments);
    }

    AssayTypeController.prototype.template = _.template($("#AssayTypeView").html());

    AssayTypeController.prototype.events = {
      "change .bv_assayType": "attributeChanged",
      "click .bv_deleteAssayType": "clear"
    };

    AssayTypeController.prototype.initialize = function() {
      this.errorOwnerName = 'AssayTypeController';
      return AssayTypeController.__super__.initialize.call(this);
    };

    AssayTypeController.prototype.updateModel = function() {
      this.model.set({
        assayType: this.$('.bv_assayType').val()
      });
      return this.model.triggerAmDirty();
    };

    return AssayTypeController;

  })(AbstractProtocolParameterController);

  window.AssayTechnologyController = (function(_super) {
    __extends(AssayTechnologyController, _super);

    function AssayTechnologyController() {
      this.updateModel = __bind(this.updateModel, this);
      return AssayTechnologyController.__super__.constructor.apply(this, arguments);
    }

    AssayTechnologyController.prototype.template = _.template($("#AssayTechnologyView").html());

    AssayTechnologyController.prototype.events = {
      "change .bv_assayTechnology": "attributeChanged",
      "click .bv_deleteAssayTechnology": "clear"
    };

    AssayTechnologyController.prototype.initialize = function() {
      this.errorOwnerName = 'AssayTechnologyController';
      return AssayTechnologyController.__super__.initialize.call(this);
    };

    AssayTechnologyController.prototype.updateModel = function() {
      this.model.set({
        assayTechnology: this.$('.bv_assayTechnology').val()
      });
      return this.model.triggerAmDirty();
    };

    return AssayTechnologyController;

  })(AbstractProtocolParameterController);

  window.CellLineController = (function(_super) {
    __extends(CellLineController, _super);

    function CellLineController() {
      this.updateModel = __bind(this.updateModel, this);
      return CellLineController.__super__.constructor.apply(this, arguments);
    }

    CellLineController.prototype.template = _.template($("#CellLineView").html());

    CellLineController.prototype.events = {
      "change .bv_cellLine": "attributeChanged",
      "click .bv_deleteCellLine": "clear"
    };

    CellLineController.prototype.initialize = function() {
      this.errorOwnerName = 'CellLineController';
      return CellLineController.__super__.initialize.call(this);
    };

    CellLineController.prototype.updateModel = function() {
      this.model.set({
        cellLine: this.$('.bv_cellLine').val()
      });
      return this.model.triggerAmDirty();
    };

    return CellLineController;

  })(AbstractProtocolParameterController);

  window.AbstractProtocolParameterListController = (function(_super) {
    __extends(AbstractProtocolParameterListController, _super);

    function AbstractProtocolParameterListController() {
      this.checkForDuplicateSelections = __bind(this.checkForDuplicateSelections, this);
      this.render = __bind(this.render, this);
      this.initialize = __bind(this.initialize, this);
      return AbstractProtocolParameterListController.__super__.constructor.apply(this, arguments);
    }

    AbstractProtocolParameterListController.prototype.initialize = function() {
      this.collection.on('remove', this.checkForDuplicateSelections);
      this.collection.on('remove', (function(_this) {
        return function() {
          return _this.collection.trigger('amDirty');
        };
      })(this));
      return this.collection.on('remove', (function(_this) {
        return function() {
          return _this.collection.trigger('change');
        };
      })(this));
    };

    AbstractProtocolParameterListController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      this.collection.each((function(_this) {
        return function(parameter) {
          return _this.addOneSelectList(parameter);
        };
      })(this));
      if (this.collection.length === 0) {
        this.addNewSelectList();
      }
      return this;
    };

    AbstractProtocolParameterListController.prototype.checkForDuplicateSelections = function() {
      if (this.collection.length === 0) {
        return this.addNewSelectList();
      }
    };

    return AbstractProtocolParameterListController;

  })(AbstractFormController);

  window.AssayActivityListController = (function(_super) {
    __extends(AssayActivityListController, _super);

    function AssayActivityListController() {
      this.addNewSelectList = __bind(this.addNewSelectList, this);
      return AssayActivityListController.__super__.constructor.apply(this, arguments);
    }

    AssayActivityListController.prototype.template = _.template($("#AssayActivityListView").html());

    AssayActivityListController.prototype.events = {
      "click .bv_addActivityButton": "addNewSelectList"
    };

    AssayActivityListController.prototype.addNewSelectList = function() {
      var newModel;
      newModel = new AssayActivity();
      this.collection.add(newModel);
      this.addOneSelectList(newModel);
      return newModel.triggerAmDirty();
    };

    AssayActivityListController.prototype.addOneSelectList = function(parameter) {
      var aac;
      aac = new AssayActivityController({
        model: parameter
      });
      return this.$('.bv_assayActivityInfo').append(aac.render().el);
    };

    return AssayActivityListController;

  })(AbstractProtocolParameterListController);

  window.TargetOriginListController = (function(_super) {
    __extends(TargetOriginListController, _super);

    function TargetOriginListController() {
      this.addNewSelectList = __bind(this.addNewSelectList, this);
      return TargetOriginListController.__super__.constructor.apply(this, arguments);
    }

    TargetOriginListController.prototype.template = _.template($("#TargetOriginListView").html());

    TargetOriginListController.prototype.events = {
      "click .bv_addTargetOriginButton": "addNewSelectList"
    };

    TargetOriginListController.prototype.addNewSelectList = function() {
      var newModel;
      newModel = new TargetOrigin();
      this.collection.add(newModel);
      this.addOneSelectList(newModel);
      return newModel.triggerAmDirty();
    };

    TargetOriginListController.prototype.addOneSelectList = function(parameter) {
      var toc;
      toc = new TargetOriginController({
        model: parameter
      });
      return this.$('.bv_targetOriginInfo').append(toc.render().el);
    };

    return TargetOriginListController;

  })(AbstractProtocolParameterListController);

  window.AssayTypeListController = (function(_super) {
    __extends(AssayTypeListController, _super);

    function AssayTypeListController() {
      this.addNewSelectList = __bind(this.addNewSelectList, this);
      return AssayTypeListController.__super__.constructor.apply(this, arguments);
    }

    AssayTypeListController.prototype.template = _.template($("#AssayTypeListView").html());

    AssayTypeListController.prototype.events = {
      "click .bv_addAssayTypeButton": "addNewSelectList"
    };

    AssayTypeListController.prototype.addNewSelectList = function() {
      var newModel;
      newModel = new AssayType();
      this.collection.add(newModel);
      this.addOneSelectList(newModel);
      return newModel.triggerAmDirty();
    };

    AssayTypeListController.prototype.addOneSelectList = function(parameter) {
      var atc;
      atc = new AssayTypeController({
        model: parameter
      });
      return this.$('.bv_assayTypeInfo').append(atc.render().el);
    };

    return AssayTypeListController;

  })(AbstractProtocolParameterListController);

  window.AssayTechnologyListController = (function(_super) {
    __extends(AssayTechnologyListController, _super);

    function AssayTechnologyListController() {
      this.addNewSelectList = __bind(this.addNewSelectList, this);
      return AssayTechnologyListController.__super__.constructor.apply(this, arguments);
    }

    AssayTechnologyListController.prototype.template = _.template($("#AssayTechnologyListView").html());

    AssayTechnologyListController.prototype.events = {
      "click .bv_addAssayTechnologyButton": "addNewSelectList"
    };

    AssayTechnologyListController.prototype.addNewSelectList = function() {
      var newModel;
      newModel = new AssayTechnology();
      this.collection.add(newModel);
      this.addOneSelectList(newModel);
      return newModel.triggerAmDirty();
    };

    AssayTechnologyListController.prototype.addOneSelectList = function(parameter) {
      var atc;
      atc = new AssayTechnologyController({
        model: parameter
      });
      return this.$('.bv_assayTechnologyInfo').append(atc.render().el);
    };

    return AssayTechnologyListController;

  })(AbstractProtocolParameterListController);

  window.CellLineListController = (function(_super) {
    __extends(CellLineListController, _super);

    function CellLineListController() {
      this.addNewSelectList = __bind(this.addNewSelectList, this);
      return CellLineListController.__super__.constructor.apply(this, arguments);
    }

    CellLineListController.prototype.template = _.template($("#CellLineListView").html());

    CellLineListController.prototype.events = {
      "click .bv_addCellLineButton": "addNewSelectList"
    };

    CellLineListController.prototype.addNewSelectList = function() {
      var newModel;
      newModel = new CellLine();
      this.collection.add(newModel);
      this.addOneSelectList(newModel);
      return newModel.triggerAmDirty();
    };

    CellLineListController.prototype.addOneSelectList = function(parameter) {
      var clc;
      clc = new CellLineController({
        model: parameter
      });
      return this.$('.bv_cellLineInfo').append(clc.render().el);
    };

    return CellLineListController;

  })(AbstractProtocolParameterListController);

  window.ProtocolBaseController = (function(_super) {
    __extends(ProtocolBaseController, _super);

    function ProtocolBaseController() {
      this.updateModel = __bind(this.updateModel, this);
      this.render = __bind(this.render, this);
      return ProtocolBaseController.__super__.constructor.apply(this, arguments);
    }

    ProtocolBaseController.prototype.template = _.template($("#ProtocolBaseView").html());

    ProtocolBaseController.prototype.events = function() {
      return _(ProtocolBaseController.__super__.events.call(this)).extend({
        "change .bv_protocolName": "handleNameChanged",
        "change .bv_assayTreeRule": "attributeChanged",
        "click .bv_dnsTargetList": "attributeChanged",
        "change .bv_assayStage": "attributeChanged",
        "change .bv_maxY": "attributeChanged",
        "change .bv_minY": "attributeChanged"
      });
    };

    ProtocolBaseController.prototype.initialize = function() {
      if (this.model == null) {
        this.model = new Protocol();
      }
      this.model.on('sync', (function(_this) {
        return function() {
          _this.trigger('amClean');
          _this.$('.bv_saving').hide();
          _this.$('.bv_updateComplete').show();
          return _this.render();
        };
      })(this));
      this.model.on('change', (function(_this) {
        return function() {
          _this.trigger('amDirty');
          return _this.$('.bv_updateComplete').hide();
        };
      })(this));
      this.errorOwnerName = 'ProtocolBaseController';
      this.setBindings();
      $(this.el).empty();
      $(this.el).html(this.template(this.model.attributes));
      this.$('.bv_save').attr('disabled', 'disabled');
      this.setupStatusSelect();
      this.setupTagList();
      this.model.getStatus().on('change', this.updateEditable);
      return this.setupAssayStageSelect();
    };

    ProtocolBaseController.prototype.render = function() {
      this.$('.bv_assayTreeRule').val(this.model.get('assayTreeRule'));
      this.$('.bv_dnsTargetList').val(this.model.get('dnsTargetList'));
      this.$('.bv_maxY').val(this.model.get('maxY'));
      this.$('.bv_minY').val(this.model.get('minY'));
      this.setupAssayStageSelect();
      this.setupAssayActivityListController();
      this.setupTargetOriginListController();
      this.setupAssayTypeListController();
      this.setupAssayTechnologyListController();
      this.setupCellLineListController();
      ProtocolBaseController.__super__.render.call(this);
      return this;
    };

    ProtocolBaseController.prototype.setupAssayStageSelect = function() {
      this.assayStageList = new PickListList();
      this.assayStageList.url = "/api/dataDict/assayStageCodes";
      return this.assayStageListController = new PickListSelectController({
        el: this.$('.bv_assayStage'),
        collection: this.assayStageList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select assay stage"
        }),
        selectedCode: this.model.get('assayStage')
      });
    };

    ProtocolBaseController.prototype.setupAssayActivityListController = function() {
      this.assayActivityListController = new AssayActivityListController({
        el: this.$('.bv_assayActivityList'),
        collection: this.model.get('assayActivityList')
      });
      return this.assayActivityListController.render();
    };

    ProtocolBaseController.prototype.setupTargetOriginListController = function() {
      this.targetOriginListController = new TargetOriginListController({
        el: this.$('.bv_targetOriginList'),
        collection: this.model.get('targetOriginList')
      });
      return this.targetOriginListController.render();
    };

    ProtocolBaseController.prototype.setupAssayTypeListController = function() {
      this.assayTypeListController = new AssayTypeListController({
        el: this.$('.bv_assayTypeList'),
        collection: this.model.get('assayTypeList')
      });
      return this.assayTypeListController.render();
    };

    ProtocolBaseController.prototype.setupAssayTechnologyListController = function() {
      this.assayTechnologyListController = new AssayTechnologyListController({
        el: this.$('.bv_assayTechnologyList'),
        collection: this.model.get('assayTechnologyList')
      });
      return this.assayTechnologyListController.render();
    };

    ProtocolBaseController.prototype.setupCellLineListController = function() {
      this.cellLineListController = new CellLineListController({
        el: this.$('.bv_cellLineList'),
        collection: this.model.get('cellLineList')
      });
      return this.cellLineListController.render();
    };

    ProtocolBaseController.prototype.updateModel = function() {
      return this.model.set({
        assayTreeRule: this.getTrimmedInput('.bv_assayTreeRule'),
        dnsTargetList: this.$('.bv_dnsTargetList').is(":checked"),
        assayStage: this.$('.bv_assayStage').val(),
        maxY: parseFloat(this.getTrimmedInput('.bv_maxY')),
        minY: parseFloat(this.getTrimmedInput('.bv_minY'))
      });
    };

    return ProtocolBaseController;

  })(BaseEntityController);

}).call(this);
