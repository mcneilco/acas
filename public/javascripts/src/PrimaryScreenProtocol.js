(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.PrimaryScreenProtocolParameters = (function(_super) {
    __extends(PrimaryScreenProtocolParameters, _super);

    function PrimaryScreenProtocolParameters() {
      return PrimaryScreenProtocolParameters.__super__.constructor.apply(this, arguments);
    }

    PrimaryScreenProtocolParameters.prototype.validate = function(attrs) {
      var errors, maxY, minY;
      errors = [];
      maxY = this.getCurveDisplayMax().get('numericValue');
      if (isNaN(maxY)) {
        errors.push({
          attribute: 'maxY',
          message: "maxY must be a number"
        });
      }
      minY = this.getCurveDisplayMin().get('numericValue');
      if (isNaN(minY)) {
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

    PrimaryScreenProtocolParameters.prototype.getCustomerMolecularTargetCodeOrigin = function() {
      var molecularTarget;
      molecularTarget = this.getOrCreateValueByTypeAndKind("codeValue", "molecular target");
      console.log(molecularTarget.get('codeOrigin'));
      if (molecularTarget.get('codeOrigin') === "customer ddict") {
        console.log("getCustomerMolecularTargetCodeOrigin and is customer ddict");
        return true;
      } else {
        return false;
      }
    };

    PrimaryScreenProtocolParameters.prototype.setCustomerMolecularTargetCodeOrigin = function(customerCodeOrigin) {
      var molecularTarget;
      console.log(this);
      console.log("setting customer target List");
      molecularTarget = this.getOrCreateValueByTypeAndKind("codeValue", "molecular target");
      if (customerCodeOrigin) {
        return molecularTarget.set({
          codeOrigin: "customer ddict"
        });
      } else {
        return molecularTarget.set({
          codeOrigin: "acas ddict"
        });
      }
    };

    PrimaryScreenProtocolParameters.prototype.getCurveDisplayMin = function() {
      var minY;
      minY = this.getOrCreateValueByTypeAndKind("numericValue", "curve display min");
      if (minY.get('numericValue') === void 0 || minY.get('numericValue') === "") {
        minY.set({
          numericValue: 0.0
        });
      }
      return minY;
    };

    PrimaryScreenProtocolParameters.prototype.getCurveDisplayMax = function() {
      var maxY;
      maxY = this.getOrCreateValueByTypeAndKind("numericValue", "curve display max");
      if (maxY.get('numericValue') === void 0 || maxY.get('numericValue') === "") {
        maxY.set({
          numericValue: 100.0
        });
      }
      return maxY;
    };

    PrimaryScreenProtocolParameters.prototype.getPrimaryScreenProtocolParameterCodeValue = function(parameterName) {
      var parameter;
      parameter = this.getOrCreateValueByTypeAndKind("codeValue", parameterName);
      if (parameter.get('codeValue') === void 0 || parameter.get('codeValue') === "") {
        parameter.set({
          codeValue: "unassigned"
        });
      }
      if (parameter.get('codeOrigin') === void 0 || parameter.get('codeOrigin') === "") {
        parameter.set({
          codeOrigin: "acas ddict"
        });
      }
      return parameter;
    };

    PrimaryScreenProtocolParameters.prototype.getOrCreateValueByTypeAndKind = function(vType, vKind) {
      var descVal, descVals;
      descVals = this.getValuesByTypeAndKind(vType, vKind);
      descVal = descVals[0];
      if (descVal == null) {
        descVal = new Value({
          lsType: vType,
          lsKind: vKind
        });
        this.get('lsValues').add(descVal);
        descVal.on('change', (function(_this) {
          return function() {
            return _this.trigger('change');
          };
        })(this));
      }
      return descVal;
    };

    return PrimaryScreenProtocolParameters;

  })(State);

  window.PrimaryScreenProtocol = (function(_super) {
    __extends(PrimaryScreenProtocol, _super);

    function PrimaryScreenProtocol() {
      return PrimaryScreenProtocol.__super__.constructor.apply(this, arguments);
    }

    PrimaryScreenProtocol.prototype.getPrimaryScreenProtocolParameters = function() {
      var pspp;
      pspp = this.get('lsStates').getOrCreateStateByTypeAndKind("metadata", "screening assay");
      return new PrimaryScreenProtocolParameters(pspp.attributes);
    };

    return PrimaryScreenProtocol;

  })(Protocol);

  window.PrimaryScreenProtocolParametersController = (function(_super) {
    __extends(PrimaryScreenProtocolParametersController, _super);

    function PrimaryScreenProtocolParametersController() {
      this.saveNewPickListOptions = __bind(this.saveNewPickListOptions, this);
      this.handleMolecularTargetDDictChanged = __bind(this.handleMolecularTargetDDictChanged, this);
      this.updateModel = __bind(this.updateModel, this);
      this.render = __bind(this.render, this);
      return PrimaryScreenProtocolParametersController.__super__.constructor.apply(this, arguments);
    }

    PrimaryScreenProtocolParametersController.prototype.template = _.template($("#PrimaryScreenProtocolParametersView").html());

    PrimaryScreenProtocolParametersController.prototype.autofillTemplate = _.template($("#PrimaryScreenProtocolParametersAutofillView").html());

    PrimaryScreenProtocolParametersController.prototype.events = {
      "click .bv_customerMolecularTargetDDictChkbx": "handleMolecularTargetDDictChanged",
      "change .bv_assayStage": "attributeChanged",
      "change .bv_maxY": "attributeChanged",
      "change .bv_minY": "attributeChanged",
      "change .bv_assayActivity": "attributeChanged",
      "change .bv_molecularTarget": "attributeChanged",
      "change .bv_targetOrigin": "attributeChanged",
      "change .bv_assayType": "attributeChanged",
      "change .bv_assayTechnology": "attributeChanged",
      "change .bv_cellLine": "attributeChanged"
    };

    PrimaryScreenProtocolParametersController.prototype.initialize = function() {
      this.errorOwnerName = 'PrimaryScreenProtocolParametersController';
      this.setBindings();
      PrimaryScreenProtocolParametersController.__super__.initialize.call(this);
      this.setupAssayActivitySelect();
      this.setupMolecularTargetSelect();
      this.setupTargetOriginSelect();
      this.setupAssayTypeSelect();
      this.setupAssayTechnologySelect();
      this.setupCellLineSelect();
      return this.setUpAssayStageSelect();
    };

    PrimaryScreenProtocolParametersController.prototype.render = function() {
      this.$el.empty();
      this.$el.html(this.autofillTemplate(this.model.attributes));
      this.$('.bv_maxY').val(this.model.getCurveDisplayMax().get('numericValue'));
      this.$('.bv_minY').val(this.model.getCurveDisplayMin().get('numericValue'));
      this.setupAssayActivitySelect();
      this.setupMolecularTargetSelect();
      this.setupTargetOriginSelect();
      this.setUpAssayStageSelect();
      this.setupAssayTypeSelect();
      this.setupAssayTechnologySelect();
      this.setupCellLineSelect();
      this.setupCustomerMolecularTargetDDictChkbx();
      PrimaryScreenProtocolParametersController.__super__.render.call(this);
      return this;
    };

    PrimaryScreenProtocolParametersController.prototype.setupAssayActivitySelect = function() {
      console.log("setting up assay activity select");
      console.log(this.model);
      console.log(this.model.getPrimaryScreenProtocolParameterCodeValue('assay activity'));
      this.assayActivityList = new PickListList();
      this.assayActivityList.url = "/api/dataDict/protocolMetadata/assay activity";
      this.assayActivityListController = new EditablePickListSelectController({
        el: this.$('.bv_assayActivity'),
        collection: this.assayActivityList,
        selectedCode: this.model.getPrimaryScreenProtocolParameterCodeValue('assay activity').get('codeValue'),
        parameter: "assayActivity",
        roles: ["admin"]
      });
      this.assayActivityListController.render();
      return console.log(this.assayActivityListController);
    };

    PrimaryScreenProtocolParametersController.prototype.setupMolecularTargetSelect = function() {
      console.log("setting up molecular target select");
      console.log(this.model);
      console.log(this.model.getPrimaryScreenProtocolParameterCodeValue('molecular target'));
      this.molecularTargetList = new PickListList();
      this.molecularTargetList.url = "/api/dataDict/protocolMetadata/molecular target";
      this.molecularTargetListController = new EditablePickListSelectController({
        el: this.$('.bv_molecularTarget'),
        collection: this.molecularTargetList,
        selectedCode: this.model.getPrimaryScreenProtocolParameterCodeValue('molecular target').get('codeValue'),
        parameter: "molecularTarget",
        roles: ["admin"]
      });
      this.molecularTargetListController.render();
      return console.log(this.molecularTargetListController);
    };

    PrimaryScreenProtocolParametersController.prototype.setupTargetOriginSelect = function() {
      this.targetOriginList = new PickListList();
      this.targetOriginList.url = "/api/dataDict/protocolMetadata/target origin";
      this.targetOriginListController = new EditablePickListSelectController({
        el: this.$('.bv_targetOrigin'),
        collection: this.targetOriginList,
        selectedCode: this.model.getPrimaryScreenProtocolParameterCodeValue('target origin').get('codeValue'),
        parameter: "targetOrigin",
        roles: ["admin"]
      });
      return this.targetOriginListController.render();
    };

    PrimaryScreenProtocolParametersController.prototype.setupAssayTypeSelect = function() {
      this.assayTypeList = new PickListList();
      this.assayTypeList.url = "/api/dataDict/protocolMetadata/assay type";
      this.assayTypeListController = new EditablePickListSelectController({
        el: this.$('.bv_assayType'),
        collection: this.assayTypeList,
        selectedCode: this.model.getPrimaryScreenProtocolParameterCodeValue('assay type').get('codeValue'),
        parameter: "assayType",
        roles: ["admin"]
      });
      return this.assayTypeListController.render();
    };

    PrimaryScreenProtocolParametersController.prototype.setupAssayTechnologySelect = function() {
      this.assayTechnologyList = new PickListList();
      this.assayTechnologyList.url = "/api/dataDict/protocolMetadata/assay technology";
      this.assayTechnologyListController = new EditablePickListSelectController({
        el: this.$('.bv_assayTechnology'),
        collection: this.assayTechnologyList,
        selectedCode: this.model.getPrimaryScreenProtocolParameterCodeValue('assay technology').get('codeValue'),
        parameter: "assayTechnology",
        roles: ["admin"]
      });
      return this.assayTechnologyListController.render();
    };

    PrimaryScreenProtocolParametersController.prototype.setupCellLineSelect = function() {
      this.cellLineList = new PickListList();
      this.cellLineList.url = "/api/dataDict/protocolMetadata/cell line";
      this.cellLineListController = new EditablePickListSelectController({
        el: this.$('.bv_cellLine'),
        collection: this.cellLineList,
        selectedCode: this.model.getPrimaryScreenProtocolParameterCodeValue('cell line').get('codeValue'),
        parameter: "cellLine",
        roles: ["admin"]
      });
      return this.cellLineListController.render();
    };

    PrimaryScreenProtocolParametersController.prototype.setUpAssayStageSelect = function() {
      this.assayStageList = new PickListList();
      this.assayStageList.url = "/api/dataDict/protocolMetadata/assay stage";
      console.log("about to set up assay stage");
      console.log(this.model);
      return this.assayStageListController = new PickListSelectController({
        el: this.$('.bv_assayStage'),
        collection: this.assayStageList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select assay stage"
        }),
        selectedCode: this.model.getPrimaryScreenProtocolParameterCodeValue('assay stage').get('codeValue')
      });
    };

    PrimaryScreenProtocolParametersController.prototype.setupCustomerMolecularTargetDDictChkbx = function() {
      var checked;
      checked = this.model.getCustomerMolecularTargetCodeOrigin();
      if (checked) {
        console.log("code origin is customer specific");
        return this.$('.bv_customerMolecularTargetDDictChkbx').attr("checked", "checked");
      }
    };

    PrimaryScreenProtocolParametersController.prototype.updateModel = function() {
      console.log("update model");
      this.model.getPrimaryScreenProtocolParameterCodeValue('assay activity').set({
        codeValue: this.assayActivityListController.getSelectedCode()
      });
      this.model.getPrimaryScreenProtocolParameterCodeValue('molecular target').set({
        codeValue: this.molecularTargetListController.getSelectedCode()
      });
      this.model.getPrimaryScreenProtocolParameterCodeValue('target origin').set({
        codeValue: this.targetOriginListController.getSelectedCode()
      });
      this.model.getPrimaryScreenProtocolParameterCodeValue('assay type').set({
        codeValue: this.assayTypeListController.getSelectedCode()
      });
      this.model.getPrimaryScreenProtocolParameterCodeValue('assay technology').set({
        codeValue: this.assayTechnologyListController.getSelectedCode()
      });
      this.model.getPrimaryScreenProtocolParameterCodeValue('cell line').set({
        codeValue: this.cellLineListController.getSelectedCode()
      });
      this.model.getPrimaryScreenProtocolParameterCodeValue('assay stage').set({
        codeValue: this.assayStageListController.getSelectedCode()
      });
      this.model.getCurveDisplayMax().set({
        numericValue: parseFloat(this.getTrimmedInput('.bv_maxY'))
      });
      this.model.getCurveDisplayMin().set({
        numericValue: parseFloat(this.getTrimmedInput('.bv_minY'))
      });
      return console.log(this.model);
    };

    PrimaryScreenProtocolParametersController.prototype.handleMolecularTargetDDictChanged = function() {
      var customerDDict, targetListurl;
      customerDDict = this.$('.bv_customerMolecularTargetDDictChkbx').is(":checked");
      console.log("handle molec traget ddict changed");
      console.log(customerDDict);
      this.model.setCustomerMolecularTargetCodeOrigin(customerDDict);
      if (customerDDict) {
        this.molecularTargetListController.hideAddOptionButton();
        targetListurl = "http://imapp01-d:8080/DNS/codes/v1/Codes/SB_Variant_Construct";
      } else {
        this.molecularTargetListController.showAddOptionButton();
        targetListurl = "/api/dataDict/protocolMetadata/molecular target";
      }
      return this.attributeChanged();
    };

    PrimaryScreenProtocolParametersController.prototype.saveNewPickListOptions = function() {
      console.log("save new pick list options");
      this.assayActivityListController.saveNewOption();
      this.molecularTargetListController.saveNewOption();
      this.targetOriginListController.saveNewOption();
      this.assayTypeListController.saveNewOption();
      this.assayTechnologyListController.saveNewOption();
      return this.cellLineListController.saveNewOption();
    };

    return PrimaryScreenProtocolParametersController;

  })(AbstractFormController);

  window.PrimaryScreenProtocolController = (function(_super) {
    __extends(PrimaryScreenProtocolController, _super);

    function PrimaryScreenProtocolController() {
      this.handleCheckForNewPickListOption = __bind(this.handleCheckForNewPickListOption, this);
      return PrimaryScreenProtocolController.__super__.constructor.apply(this, arguments);
    }

    PrimaryScreenProtocolController.prototype.initialize = function() {
      this.setupProtocolBaseController();
      this.setupPrimaryScreenProtocolParametersController();
      return this.protocolBaseController.model.on("checkForNewPickListOption", this.handleCheckForNewPickListOption);
    };

    PrimaryScreenProtocolController.prototype.setupProtocolBaseController = function() {
      console.log(this.model);
      this.protocolBaseController = new ProtocolBaseController({
        model: this.model,
        el: this.el
      });
      this.protocolBaseController.on('amDirty', (function(_this) {
        return function() {
          return _this.trigger('amDirty');
        };
      })(this));
      this.protocolBaseController.on('amClean', (function(_this) {
        return function() {
          return _this.trigger('amClean');
        };
      })(this));
      this.protocolBaseController.render();
      return console.log("set up protocol base controller");
    };

    PrimaryScreenProtocolController.prototype.setupPrimaryScreenProtocolParametersController = function() {
      console.log("SETTING UP PRIMARY SCREEN PROTOCOL PARAMETERS CONTROLLER");
      this.primaryScreenProtocolParametersController = new PrimaryScreenProtocolParametersController({
        model: this.model.getPrimaryScreenProtocolParameters(),
        el: this.$('.bv_primaryScreenProtocolAutofillSection')
      });
      this.primaryScreenProtocolParametersController.on('amDirty', (function(_this) {
        return function() {
          return _this.trigger('amDirty');
        };
      })(this));
      this.primaryScreenProtocolParametersController.on('amClean', (function(_this) {
        return function() {
          return _this.trigger('amClean');
        };
      })(this));
      this.primaryScreenProtocolParametersController.render();
      return console.log("set up ps protocol parameters controller");
    };

    PrimaryScreenProtocolController.prototype.handleCheckForNewPickListOption = function() {
      console.log("triggered save new picklist option");
      return this.primaryScreenProtocolParametersController.saveNewPickListOptions();
    };

    return PrimaryScreenProtocolController;

  })(Backbone.View);

  window.AbstractPrimaryScreenProtocolModuleController = (function(_super) {
    __extends(AbstractPrimaryScreenProtocolModuleController, _super);

    function AbstractPrimaryScreenProtocolModuleController() {
      this.handleProtocolSaved = __bind(this.handleProtocolSaved, this);
      return AbstractPrimaryScreenProtocolModuleController.__super__.constructor.apply(this, arguments);
    }

    AbstractPrimaryScreenProtocolModuleController.prototype.template = _.template($("#PrimaryScreenProtocolModuleView").html());

    AbstractPrimaryScreenProtocolModuleController.prototype.initialize = function() {
      if (this.model != null) {
        return this.completeInitialization();
      } else {
        if (window.AppLaunchParams.moduleLaunchParams != null) {
          if (window.AppLaunchParams.moduleLaunchParams.moduleName === this.moduleLaunchName) {
            return $.ajax({
              type: 'GET',
              url: "/api/protocols/codename/" + window.AppLaunchParams.moduleLaunchParams.code,
              dataType: 'json',
              error: function(err) {
                alert('Could not get protocol for code in this URL, creating new one');
                return this.completeInitialization();
              },
              success: (function(_this) {
                return function(json) {
                  var prot;
                  if (json.length === 0) {
                    alert('Could not get protocol for code in this URL, creating new one');
                  } else {
                    prot = new PrimaryScreenProtocol(json);
                    prot.fixCompositeClasses();
                    _this.model = prot;
                  }
                  return _this.completeInitialization();
                };
              })(this)
            });
          } else {
            return this.completeInitialization();
          }
        } else {
          return this.completeInitialization();
        }
      }
    };

    AbstractPrimaryScreenProtocolModuleController.prototype.completeInitialization = function() {
      if (this.model == null) {
        this.model = new PrimaryScreenProtocol();
      }
      $(this.el).html(this.template());
      this.model.on('sync', this.handleProtocolSaved);
      this.setupPrimaryScreenProtocolController();
      return this.setupPrimaryScreenAnalysisParametersController();
    };

    AbstractPrimaryScreenProtocolModuleController.prototype.handleProtocolSaved = function() {
      return this.primaryScreenAnalysisParametersController.render();
    };

    AbstractPrimaryScreenProtocolModuleController.prototype.setupPrimaryScreenProtocolController = function() {
      this.primaryScreenProtocolController = new PrimaryScreenProtocolController({
        model: this.model,
        el: this.$('.bv_primaryScreenProtocolGeneralInfoWrapper')
      });
      this.primaryScreenProtocolController.on('amDirty', (function(_this) {
        return function() {
          return _this.trigger('amDirty');
        };
      })(this));
      this.primaryScreenProtocolController.on('amClean', (function(_this) {
        return function() {
          return _this.trigger('amClean');
        };
      })(this));
      return this.primaryScreenProtocolController.render();
    };

    AbstractPrimaryScreenProtocolModuleController.prototype.setupPrimaryScreenAnalysisParametersController = function() {
      this.primaryScreenAnalysisParametersController = new PrimaryScreenAnalysisParametersController({
        model: this.model.getAnalysisParameters(),
        el: this.$('.bv_primaryScreenAnalysisParameters')
      });
      this.primaryScreenAnalysisParametersController.on('amDirty', (function(_this) {
        return function() {
          return _this.trigger('amDirty');
        };
      })(this));
      this.primaryScreenAnalysisParametersController.on('amClean', (function(_this) {
        return function() {
          return _this.trigger('amClean');
        };
      })(this));
      this.primaryScreenAnalysisParametersController.render();
      return console.log(this.primaryScreenAnalysisParametersController);
    };

    return AbstractPrimaryScreenProtocolModuleController;

  })(Backbone.View);

  window.PrimaryScreenProtocolModuleController = (function(_super) {
    __extends(PrimaryScreenProtocolModuleController, _super);

    function PrimaryScreenProtocolModuleController() {
      return PrimaryScreenProtocolModuleController.__super__.constructor.apply(this, arguments);
    }

    PrimaryScreenProtocolModuleController.prototype.moduleLaunchName = "primary_screen_protocol";

    return PrimaryScreenProtocolModuleController;

  })(AbstractPrimaryScreenProtocolModuleController);

}).call(this);
