(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.PrimaryScreenProtocolParameters = (function(_super) {
    __extends(PrimaryScreenProtocolParameters, _super);

    function PrimaryScreenProtocolParameters() {
      this.getCustomerMolecularTargetCodeOrigin = __bind(this.getCustomerMolecularTargetCodeOrigin, this);
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
      if (maxY < minY) {
        errors.push({
          attribute: 'maxY',
          message: "maxY must be greater than minY"
        });
        errors.push({
          attribute: 'minY',
          message: "minY must be less than maxY"
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
      molecularTarget = this.getMolecularTarget();
      if (molecularTarget.get('codeOrigin') === "customer ddict") {
        return true;
      } else {
        return false;
      }
    };

    PrimaryScreenProtocolParameters.prototype.setCustomerMolecularTargetCodeOrigin = function(customerCodeOrigin) {
      var molecularTarget;
      molecularTarget = this.getMolecularTarget();
      if (customerCodeOrigin) {
        return molecularTarget.set({
          codeOrigin: "customer ddict"
        });
      } else {
        return molecularTarget.set({
          codeOrigin: "ACAS DDICT"
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

    PrimaryScreenProtocolParameters.prototype.getAssayActivity = function() {
      var aa;
      aa = this.getOrCreateValueByTypeAndKind("codeValue", "assay activity");
      if (aa.get('codeValue') === void 0 || aa.get('codeValue') === "" || aa.get('codeValue') === null) {
        aa.set({
          codeValue: "unassigned"
        });
        aa.set({
          codeType: "assay"
        });
        aa.set({
          codeKind: "activity"
        });
        aa.set({
          codeOrigin: "ACAS DDICT"
        });
      }
      return aa;
    };

    PrimaryScreenProtocolParameters.prototype.getMolecularTarget = function() {
      var mt;
      mt = this.getOrCreateValueByTypeAndKind("codeValue", "molecular target");
      if (mt.get('codeValue') === void 0 || mt.get('codeValue') === "" || mt.get('codeValue') === null) {
        mt.set({
          codeValue: "unassigned"
        });
        mt.set({
          codeType: "assay"
        });
        mt.set({
          codeKind: "molecular target"
        });
        mt.set({
          codeOrigin: "ACAS DDICT"
        });
      }
      return mt;
    };

    PrimaryScreenProtocolParameters.prototype.getTargetOrigin = function() {
      var to;
      to = this.getOrCreateValueByTypeAndKind("codeValue", "target origin");
      if (to.get('codeValue') === void 0 || to.get('codeValue') === "" || to.get('codeValue') === null) {
        to.set({
          codeValue: "unassigned"
        });
        to.set({
          codeType: "target"
        });
        to.set({
          codeKind: "origin"
        });
        to.set({
          codeOrigin: "ACAS DDICT"
        });
      }
      return to;
    };

    PrimaryScreenProtocolParameters.prototype.getAssayType = function() {
      var at;
      at = this.getOrCreateValueByTypeAndKind("codeValue", "assay type");
      if (at.get('codeValue') === void 0 || at.get('codeValue') === "" || at.get('codeValue') === null) {
        at.set({
          codeValue: "unassigned"
        });
        at.set({
          codeType: "assay"
        });
        at.set({
          codeKind: "type"
        });
        at.set({
          codeOrigin: "ACAS DDICT"
        });
      }
      return at;
    };

    PrimaryScreenProtocolParameters.prototype.getAssayTechnology = function() {
      var at;
      at = this.getOrCreateValueByTypeAndKind("codeValue", "assay technology");
      if (at.get('codeValue') === void 0 || at.get('codeValue') === "" || at.get('codeValue') === null) {
        at.set({
          codeValue: "unassigned"
        });
        at.set({
          codeType: "assay"
        });
        at.set({
          codeKind: "technology"
        });
        at.set({
          codeOrigin: "ACAS DDICT"
        });
      }
      return at;
    };

    PrimaryScreenProtocolParameters.prototype.getCellLine = function() {
      var cl;
      cl = this.getOrCreateValueByTypeAndKind("codeValue", "cell line");
      if (cl.get('codeValue') === void 0 || cl.get('codeValue') === "" || cl.get('codeValue') === null) {
        cl.set({
          codeValue: "unassigned"
        });
        cl.set({
          codeType: "reagent"
        });
        cl.set({
          codeKind: "cell line"
        });
        cl.set({
          codeOrigin: "ACAS DDICT"
        });
      }
      return cl;
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

    PrimaryScreenProtocol.prototype.initialize = function() {
      PrimaryScreenProtocol.__super__.initialize.call(this);
      this.set({
        lsType: "Biology"
      });
      return this.set({
        lsKind: "Bio Activity"
      });
    };

    PrimaryScreenProtocol.prototype.validate = function(attrs) {
      var bestName, cDate, errors, psAnalysisParameters, psAnalysisParametersErrors, psModelFitParameters, psModelFitParametersErrors, psProtocolParameters, psProtocolParametersErrors;
      errors = [];
      psProtocolParameters = this.getPrimaryScreenProtocolParameters();
      psProtocolParametersErrors = psProtocolParameters.validate();
      errors.push.apply(errors, psProtocolParametersErrors);
      psAnalysisParameters = this.getAnalysisParameters();
      psAnalysisParametersErrors = psAnalysisParameters.validate(psAnalysisParameters.attributes);
      errors.push.apply(errors, psAnalysisParametersErrors);
      psModelFitParameters = new DoseResponseAnalysisParameters(this.getModelFitParameters());
      psModelFitParametersErrors = psModelFitParameters.validate(psModelFitParameters.attributes);
      errors.push.apply(errors, psModelFitParametersErrors);
      bestName = attrs.lsLabels.pickBestName();
      errors.push.apply(errors, PrimaryScreenProtocol.__super__.validate.call(this, attrs));
      if (attrs.subclass != null) {
        cDate = this.getCreationDate().get('dateValue');
        if (cDate === void 0 || cDate === "" || cDate === null) {
          cDate = "fred";
        }
        if (isNaN(cDate)) {
          errors.push({
            attribute: 'creationDate',
            message: "Assay creation date must be set"
          });
        }
      }
      if (errors.length > 0) {
        return errors;
      } else {
        return null;
      }
    };

    PrimaryScreenProtocol.prototype.getPrimaryScreenProtocolParameters = function() {
      var pspp;
      pspp = this.get('lsStates').getOrCreateStateByTypeAndKind("metadata", "screening assay");
      return new PrimaryScreenProtocolParameters(pspp.attributes);
    };

    PrimaryScreenProtocol.prototype.checkForNewPickListOptions = function() {
      return this.trigger("checkForNewPickListOptions");
    };

    PrimaryScreenProtocol.prototype.getModelFitType = function() {
      var type;
      type = this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "experiment metadata", "codeValue", "model fit type");
      if (!type.has('codeValue')) {
        type.set({
          codeValue: "unassigned"
        });
        type.set({
          codeType: "model fit"
        });
        type.set({
          codeKind: "type"
        });
        type.set({
          codeOrigin: "ACAS DDICT"
        });
      }
      return type;
    };

    return PrimaryScreenProtocol;

  })(Protocol);

  window.PrimaryScreenProtocolParametersController = (function(_super) {
    __extends(PrimaryScreenProtocolParametersController, _super);

    function PrimaryScreenProtocolParametersController() {
      this.saveNewPickListOptions = __bind(this.saveNewPickListOptions, this);
      this.handleMolecularTargetDDictChanged = __bind(this.handleMolecularTargetDDictChanged, this);
      this.handleCurveDisplayMinChanged = __bind(this.handleCurveDisplayMinChanged, this);
      this.handleCurveDisplayMaxChanged = __bind(this.handleCurveDisplayMaxChanged, this);
      this.handleCellLineChanged = __bind(this.handleCellLineChanged, this);
      this.handleAssayTechnologyChanged = __bind(this.handleAssayTechnologyChanged, this);
      this.handleAssayTypeChanged = __bind(this.handleAssayTypeChanged, this);
      this.handleTargetOriginChanged = __bind(this.handleTargetOriginChanged, this);
      this.handleMolecularTargetChanged = __bind(this.handleMolecularTargetChanged, this);
      this.handleAssayActivityChanged = __bind(this.handleAssayActivityChanged, this);
      this.render = __bind(this.render, this);
      return PrimaryScreenProtocolParametersController.__super__.constructor.apply(this, arguments);
    }

    PrimaryScreenProtocolParametersController.prototype.template = _.template($("#PrimaryScreenProtocolParametersView").html());

    PrimaryScreenProtocolParametersController.prototype.autofillTemplate = _.template($("#PrimaryScreenProtocolParametersAutofillView").html());

    PrimaryScreenProtocolParametersController.prototype.events = {
      "click .bv_customerMolecularTargetDDictChkbx": "handleMolecularTargetDDictChanged",
      "change .bv_maxY": "handleCurveDisplayMaxChanged",
      "change .bv_minY": "handleCurveDisplayMinChanged",
      "change .bv_assayActivity": "handleAssayActivityChanged",
      "change .bv_molecularTarget": "handleMolecularTargetChanged",
      "change .bv_targetOrigin": "handleTargetOriginChanged",
      "change .bv_assayType": "handleAssayTypeChanged",
      "change .bv_assayTechnology": "handleAssayTechnologyChanged",
      "change .bv_cellLine": "handleCellLineChanged"
    };

    PrimaryScreenProtocolParametersController.prototype.initialize = function() {
      this.errorOwnerName = 'PrimaryScreenProtocolParametersController';
      this.setBindings();
      PrimaryScreenProtocolParametersController.__super__.initialize.call(this);
      this.setupAssayActivitySelect();
      this.setupTargetOriginSelect();
      this.setupAssayTypeSelect();
      this.setupAssayTechnologySelect();
      return this.setupCellLineSelect();
    };

    PrimaryScreenProtocolParametersController.prototype.render = function() {
      this.$el.empty();
      this.$el.html(this.autofillTemplate(this.model.attributes));
      this.$('.bv_maxY').val(this.model.getCurveDisplayMax().get('numericValue'));
      this.$('.bv_minY').val(this.model.getCurveDisplayMin().get('numericValue'));
      this.setupAssayActivitySelect();
      this.setupTargetOriginSelect();
      this.setupAssayTypeSelect();
      this.setupAssayTechnologySelect();
      this.setupCellLineSelect();
      this.setupCustomerMolecularTargetDDictChkbx();
      PrimaryScreenProtocolParametersController.__super__.render.call(this);
      return this;
    };

    PrimaryScreenProtocolParametersController.prototype.setupAssayActivitySelect = function() {
      this.assayActivityList = new PickListList();
      this.assayActivityList.url = "/api/codetables/assay/activity";
      this.assayActivityListController = new EditablePickListSelectController({
        el: this.$('.bv_assayActivity'),
        collection: this.assayActivityList,
        selectedCode: this.model.getAssayActivity().get('codeValue'),
        parameter: "assayActivity",
        codeType: "assay",
        codeKind: "activity",
        roles: ["admin"]
      });
      return this.assayActivityListController.render();
    };

    PrimaryScreenProtocolParametersController.prototype.setupTargetOriginSelect = function() {
      this.targetOriginList = new PickListList();
      this.targetOriginList.url = "/api/codetables/target/origin";
      this.targetOriginListController = new EditablePickListSelectController({
        el: this.$('.bv_targetOrigin'),
        collection: this.targetOriginList,
        selectedCode: this.model.getTargetOrigin().get('codeValue'),
        parameter: "targetOrigin",
        codeType: "target",
        codeKind: "origin",
        roles: ["admin"]
      });
      return this.targetOriginListController.render();
    };

    PrimaryScreenProtocolParametersController.prototype.setupAssayTypeSelect = function() {
      this.assayTypeList = new PickListList();
      this.assayTypeList.url = "/api/codetables/assay/type";
      this.assayTypeListController = new EditablePickListSelectController({
        el: this.$('.bv_assayType'),
        collection: this.assayTypeList,
        selectedCode: this.model.getAssayType().get('codeValue'),
        parameter: "assayType",
        codeType: "assay",
        codeKind: "type",
        roles: ["admin"]
      });
      return this.assayTypeListController.render();
    };

    PrimaryScreenProtocolParametersController.prototype.setupAssayTechnologySelect = function() {
      this.assayTechnologyList = new PickListList();
      this.assayTechnologyList.url = "/api/codetables/assay/technology";
      this.assayTechnologyListController = new EditablePickListSelectController({
        el: this.$('.bv_assayTechnology'),
        collection: this.assayTechnologyList,
        selectedCode: this.model.getAssayTechnology().get('codeValue'),
        parameter: "assayTechnology",
        codeType: "assay",
        codeKind: "technology",
        roles: ["admin"]
      });
      return this.assayTechnologyListController.render();
    };

    PrimaryScreenProtocolParametersController.prototype.setupCellLineSelect = function() {
      this.cellLineList = new PickListList();
      this.cellLineList.url = "/api/codetables/reagent/cell line";
      this.cellLineListController = new EditablePickListSelectController({
        el: this.$('.bv_cellLine'),
        collection: this.cellLineList,
        selectedCode: this.model.getCellLine().get('codeValue'),
        parameter: "cellLine",
        codeType: "reagent",
        codeKind: "cell line",
        roles: ["admin"]
      });
      return this.cellLineListController.render();
    };

    PrimaryScreenProtocolParametersController.prototype.setupCustomerMolecularTargetDDictChkbx = function() {
      var checked;
      this.molecularTargetList = new PickListList();
      checked = this.model.getCustomerMolecularTargetCodeOrigin();
      if (checked) {
        this.$('.bv_customerMolecularTargetDDictChkbx').attr("checked", "checked");
        this.molecularTargetList.url = "/api/customerMolecularTargetCodeTable";
      } else {
        this.molecularTargetList.url = "/api/codetables/assay/molecular target";
      }
      this.molecularTargetListController = new EditablePickListSelectController({
        el: this.$('.bv_molecularTarget'),
        collection: this.molecularTargetList,
        selectedCode: this.model.getMolecularTarget().get('codeValue'),
        parameter: "molecularTarget",
        codeType: "assay",
        codeKind: "molecular target",
        roles: ["admin"]
      });
      this.molecularTargetListController.render();
      if (checked) {
        return this.molecularTargetListController.hideAddOptionButton();
      } else {
        return this.molecularTargetListController.showAddOptionButton();
      }
    };

    PrimaryScreenProtocolParametersController.prototype.handleAssayActivityChanged = function() {
      return this.model.getAssayActivity().set({
        codeValue: this.assayActivityListController.getSelectedCode(),
        recordedBy: window.AppLaunchParams.loginUser.username,
        recordedDate: new Date().getTime()
      });
    };

    PrimaryScreenProtocolParametersController.prototype.handleMolecularTargetChanged = function() {
      return this.model.getMolecularTarget().set({
        codeValue: this.molecularTargetListController.getSelectedCode(),
        recordedBy: window.AppLaunchParams.loginUser.username,
        recordedDate: new Date().getTime()
      });
    };

    PrimaryScreenProtocolParametersController.prototype.handleTargetOriginChanged = function() {
      return this.model.getTargetOrigin().set({
        codeValue: this.targetOriginListController.getSelectedCode(),
        recordedBy: window.AppLaunchParams.loginUser.username,
        recordedDate: new Date().getTime()
      });
    };

    PrimaryScreenProtocolParametersController.prototype.handleAssayTypeChanged = function() {
      return this.model.getAssayType().set({
        codeValue: this.assayTypeListController.getSelectedCode(),
        recordedBy: window.AppLaunchParams.loginUser.username,
        recordedDate: new Date().getTime()
      });
    };

    PrimaryScreenProtocolParametersController.prototype.handleAssayTechnologyChanged = function() {
      return this.model.getAssayTechnology().set({
        codeValue: this.assayTechnologyListController.getSelectedCode(),
        recordedBy: window.AppLaunchParams.loginUser.username,
        recordedDate: new Date().getTime()
      });
    };

    PrimaryScreenProtocolParametersController.prototype.handleCellLineChanged = function() {
      return this.model.getCellLine().set({
        codeValue: this.cellLineListController.getSelectedCode(),
        recordedBy: window.AppLaunchParams.loginUser.username,
        recordedDate: new Date().getTime()
      });
    };

    PrimaryScreenProtocolParametersController.prototype.handleCurveDisplayMaxChanged = function() {
      return this.model.getCurveDisplayMax().set({
        numericValue: parseFloat(UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_maxY'))),
        recordedBy: window.AppLaunchParams.loginUser.username,
        recordedDate: new Date().getTime()
      });
    };

    PrimaryScreenProtocolParametersController.prototype.handleCurveDisplayMinChanged = function() {
      return this.model.getCurveDisplayMin().set({
        numericValue: parseFloat(UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_minY'))),
        recordedBy: window.AppLaunchParams.loginUser.username,
        recordedDate: new Date().getTime()
      });
    };

    PrimaryScreenProtocolParametersController.prototype.handleMolecularTargetDDictChanged = function() {
      var customerDDict;
      customerDDict = this.$('.bv_customerMolecularTargetDDictChkbx').is(":checked");
      this.model.setCustomerMolecularTargetCodeOrigin(customerDDict);
      if (customerDDict) {
        this.molecularTargetList.url = "/api/customerMolecularTargetCodeTable";
        this.molecularTargetListController.render();
        this.molecularTargetListController.hideAddOptionButton();
      } else {
        this.molecularTargetList.url = "/api/codetables/assay/molecular target";
        this.molecularTargetListController.render();
        this.molecularTargetListController.showAddOptionButton();
      }
      return this.handleMolecularTargetChanged();
    };

    PrimaryScreenProtocolParametersController.prototype.saveNewPickListOptions = function(callback) {
      return this.assayActivityListController.saveNewOption((function(_this) {
        return function() {
          return _this.molecularTargetListController.saveNewOption(function() {
            return _this.targetOriginListController.saveNewOption(function() {
              return _this.assayTypeListController.saveNewOption(function() {
                return _this.assayTechnologyListController.saveNewOption(function() {
                  return _this.cellLineListController.saveNewOption(function() {
                    return callback.call();
                  });
                });
              });
            });
          });
        };
      })(this));
    };

    return PrimaryScreenProtocolParametersController;

  })(AbstractFormController);

  window.PrimaryScreenProtocolController = (function(_super) {
    __extends(PrimaryScreenProtocolController, _super);

    function PrimaryScreenProtocolController() {
      this.displayInReadOnlyMode = __bind(this.displayInReadOnlyMode, this);
      this.handleCheckForNewPickListOptions = __bind(this.handleCheckForNewPickListOptions, this);
      this.handleSaveClicked = __bind(this.handleSaveClicked, this);
      this.setupPrimaryScreenProtocolParametersController = __bind(this.setupPrimaryScreenProtocolParametersController, this);
      this.setupProtocolBaseController = __bind(this.setupProtocolBaseController, this);
      return PrimaryScreenProtocolController.__super__.constructor.apply(this, arguments);
    }

    PrimaryScreenProtocolController.prototype.initialize = function() {
      this.setupProtocolBaseController();
      this.setupPrimaryScreenProtocolParametersController();
      return this.protocolBaseController.model.on("checkForNewPickListOptions", this.handleCheckForNewPickListOptions);
    };

    PrimaryScreenProtocolController.prototype.setupProtocolBaseController = function() {
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
      this.protocolBaseController.on("noEditablePickLists", (function(_this) {
        return function() {
          return _this.trigger('prepareToSaveToDatabase');
        };
      })(this));
      return this.protocolBaseController.render();
    };

    PrimaryScreenProtocolController.prototype.setupPrimaryScreenProtocolParametersController = function() {
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
      return this.primaryScreenProtocolParametersController.render();
    };

    PrimaryScreenProtocolController.prototype.handleSaveClicked = function() {
      return this.protocolBaseController.beginSave();
    };

    PrimaryScreenProtocolController.prototype.handleCheckForNewPickListOptions = function() {
      return this.primaryScreenProtocolParametersController.saveNewPickListOptions((function(_this) {
        return function() {
          return _this.trigger("prepareToSaveToDatabase");
        };
      })(this));
    };

    PrimaryScreenProtocolController.prototype.displayInReadOnlyMode = function() {
      return this.protocolBaseController.displayInReadOnlyMode();
    };

    return PrimaryScreenProtocolController;

  })(Backbone.View);

  window.AbstractPrimaryScreenProtocolModuleController = (function(_super) {
    __extends(AbstractPrimaryScreenProtocolModuleController, _super);

    function AbstractPrimaryScreenProtocolModuleController() {
      this.clearValidationErrorStyles = __bind(this.clearValidationErrorStyles, this);
      this.validationError = __bind(this.validationError, this);
      this.handleFinishSave = __bind(this.handleFinishSave, this);
      this.prepareToSaveToDatabase = __bind(this.prepareToSaveToDatabase, this);
      this.handleSaveModule = __bind(this.handleSaveModule, this);
      this.updateModelFitClobValue = __bind(this.updateModelFitClobValue, this);
      this.updateAnalysisClobValue = __bind(this.updateAnalysisClobValue, this);
      this.setupPrimaryScreenModelFitParametersController = __bind(this.setupPrimaryScreenModelFitParametersController, this);
      this.test = __bind(this.test, this);
      this.setupPrimaryScreenAnalysisParametersController = __bind(this.setupPrimaryScreenAnalysisParametersController, this);
      this.setupPrimaryScreenProtocolController = __bind(this.setupPrimaryScreenProtocolController, this);
      this.handleProtocolSaved = __bind(this.handleProtocolSaved, this);
      this.completeInitialization = __bind(this.completeInitialization, this);
      this.initialize = __bind(this.initialize, this);
      return AbstractPrimaryScreenProtocolModuleController.__super__.constructor.apply(this, arguments);
    }

    AbstractPrimaryScreenProtocolModuleController.prototype.template = _.template($("#PrimaryScreenProtocolModuleView").html());

    AbstractPrimaryScreenProtocolModuleController.prototype.events = {
      "click .bv_saveModule": "handleSaveModule"
    };

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
                  var lsKind, prot;
                  if (json.length === 0) {
                    alert('Could not get protocol for code in this URL, creating new one');
                  } else {
                    lsKind = json[0].lsKind;
                    if (lsKind === "Bio Activity") {
                      prot = new PrimaryScreenProtocol(json[0]);
                      prot.set(prot.parse(prot.attributes));
                      if (window.AppLaunchParams.moduleLaunchParams.copy) {
                        _this.model = prot.duplicateEntity();
                      } else {
                        _this.model = prot;
                      }
                    } else {
                      alert('Could not get primary screen protocol for code in this URL. Creating new primary screen protocol');
                    }
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
      this.model.on('sync', (function(_this) {
        return function() {
          _this.trigger('amClean');
          if (_this.model.get('subclass') == null) {
            _this.model.set({
              subclass: 'protocol'
            });
          }
          _this.$('.bv_savingModule').hide();
          _this.$('.bv_updateModuleComplete').show();
          _this.$('.bv_saveModule').attr('disabled', 'disabled');
          if (_this.model.isNew()) {
            _this.$('.bv_saveModule').html("Save");
            return _this.$('.bv_saveInstructions').show();
          } else {
            _this.$('.bv_saveModule').html("Update");
            return _this.$('.bv_saveInstructions').hide();
          }
        };
      })(this));
      if (this.model.isNew()) {
        this.$('.bv_saveModule').html("Save");
      } else {
        this.$('.bv_saveModule').html("Update");
      }
      this.model.on('change', (function(_this) {
        return function() {
          _this.trigger('amDirty');
          return _this.$('.bv_updateModuleComplete').hide();
        };
      })(this));
      this.model.on('readyToSave', this.handleFinishSave);
      this.setupPrimaryScreenProtocolController();
      this.setupPrimaryScreenAnalysisParametersController();
      this.setupPrimaryScreenModelFitTypeSelect();
      this.errorOwnerName = 'PrimaryScreenProtocolModuleController';
      this.setBindings();
      this.$('.bv_save').hide();
      this.$('.bv_saveModule').attr('disabled', 'disabled');
      if (this.model.isNew()) {
        this.$('.bv_saveModule').html("Save");
        this.$('.bv_saveInstructions').show();
      } else {
        this.$('.bv_saveModule').html("Update");
        this.$('.bv_saveInstructions').hide();
      }
      return this.trigger('amClean');
    };

    AbstractPrimaryScreenProtocolModuleController.prototype.handleProtocolSaved = function() {
      this.trigger('amClean');
      this.$('.bv_savingModule').hide();
      this.$('.bv_updateModuleComplete').show();
      if (this.model.isNew()) {
        return this.$('.bv_saveModule').html("Save");
      } else {
        return this.$('.bv_saveModule').html("Update");
      }
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
      this.primaryScreenProtocolController.render();
      return this.primaryScreenProtocolController.on('prepareToSaveToDatabase', this.prepareToSaveToDatabase);
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
      this.primaryScreenAnalysisParametersController.on('updateState', this.updateAnalysisClobValue);
      return this.primaryScreenAnalysisParametersController.render();
    };

    AbstractPrimaryScreenProtocolModuleController.prototype.setupPrimaryScreenModelFitTypeSelect = function() {
      this.modelFitTypeList = new PickListList();
      this.modelFitTypeList.url = "/api/codetables/model fit/type";
      this.modelFitTypeListController = new PickListSelectController({
        el: this.$('.bv_modelFitType'),
        collection: this.modelFitTypeList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select Model Fit Type"
        }),
        selectedCode: this.model.getModelFitType()
      });
      return this.$('.bv_modelFitType').on('change', (function(_this) {
        return function() {
          return _this.test;
        };
      })(this));
    };

    AbstractPrimaryScreenProtocolModuleController.prototype.test = function() {
      return console.log("test");
    };

    AbstractPrimaryScreenProtocolModuleController.prototype.setupPrimaryScreenModelFitParametersController = function() {
      console.log(this.model);
      this.primaryScreenModelFitParametersController = new DoseResponseAnalysisController({
        model: this.model,
        el: this.$('.bv_analysisParameterForm')
      });
      this.primaryScreenModelFitParametersController.on('amDirty', (function(_this) {
        return function() {
          return _this.trigger('amDirty');
        };
      })(this));
      this.primaryScreenModelFitParametersController.on('amClean', (function(_this) {
        return function() {
          return _this.trigger('amClean');
        };
      })(this));
      this.primaryScreenModelFitParametersController.render();
      this.updateModelFitClobValue();
      return this.primaryScreenModelFitParametersController.on('updateState', this.updateModelFitClobValue);
    };

    AbstractPrimaryScreenProtocolModuleController.prototype.updateAnalysisClobValue = function() {
      var ap;
      if (this.primaryScreenAnalysisParametersController.model.get('positiveControl').get('concentration') === Infinity) {
        this.primaryScreenAnalysisParametersController.model.get('positiveControl').set({
          concentration: "Infinity"
        });
      }
      ap = this.model.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "experiment metadata", "clobValue", "data analysis parameters");
      return ap.set({
        clobValue: JSON.stringify(this.primaryScreenAnalysisParametersController.model.attributes),
        recordedBy: window.AppLaunchParams.loginUser.username,
        recordedDate: new Date().getTime()
      });
    };

    AbstractPrimaryScreenProtocolModuleController.prototype.updateModelFitClobValue = function() {
      var mfp;
      mfp = this.model.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "experiment metadata", "clobValue", "model fit parameters");
      return mfp.set({
        clobValue: JSON.stringify(this.primaryScreenModelFitParametersController.model.attributes),
        recordedBy: window.AppLaunchParams.loginUser.username,
        recordedDate: new Date().getTime()
      });
    };

    AbstractPrimaryScreenProtocolModuleController.prototype.handleSaveModule = function() {
      this.$('.bv_savingModule').show();
      return this.primaryScreenProtocolController.handleSaveClicked();
    };

    AbstractPrimaryScreenProtocolModuleController.prototype.prepareToSaveToDatabase = function() {
      return this.model.prepareToSave();
    };

    AbstractPrimaryScreenProtocolModuleController.prototype.handleFinishSave = function() {
      if (this.model.isNew()) {
        this.$('.bv_updateModuleComplete').html("Save Complete");
      } else {
        this.$('.bv_updateModuleComplete').html("c Complete");
      }
      this.$('.bv_saveModule').attr('disabled', 'disabled');
      return this.model.save();
    };

    AbstractPrimaryScreenProtocolModuleController.prototype.validationError = function() {
      AbstractPrimaryScreenProtocolModuleController.__super__.validationError.call(this);
      this.$('.bv_saveModule').attr('disabled', 'disabled');
      return this.$('.bv_saveInstructions').show();
    };

    AbstractPrimaryScreenProtocolModuleController.prototype.clearValidationErrorStyles = function() {
      AbstractPrimaryScreenProtocolModuleController.__super__.clearValidationErrorStyles.call(this);
      this.$('.bv_saveModule').removeAttr('disabled');
      return this.$('.bv_saveInstructions').hide();
    };

    return AbstractPrimaryScreenProtocolModuleController;

  })(AbstractFormController);

  window.PrimaryScreenProtocolModuleController = (function(_super) {
    __extends(PrimaryScreenProtocolModuleController, _super);

    function PrimaryScreenProtocolModuleController() {
      return PrimaryScreenProtocolModuleController.__super__.constructor.apply(this, arguments);
    }

    PrimaryScreenProtocolModuleController.prototype.moduleLaunchName = "primary_screen_protocol";

    return PrimaryScreenProtocolModuleController;

  })(AbstractPrimaryScreenProtocolModuleController);

}).call(this);
