(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.PrimaryScreenProtocolParameters = (function(superClass) {
    extend(PrimaryScreenProtocolParameters, superClass);

    function PrimaryScreenProtocolParameters() {
      this.validate = bind(this.validate, this);
      return PrimaryScreenProtocolParameters.__super__.constructor.apply(this, arguments);
    }

    PrimaryScreenProtocolParameters.prototype.validate = function(attrs) {
      var cloneName, errors, maxY, minY, molecularTarget;
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
      molecularTarget = this.getMolecularTarget().get('codeValue');
      if (molecularTarget === "required") {
        errors.push({
          attribute: 'molecularTarget',
          message: "The target for the clone must be selected"
        });
      }
      if (molecularTarget === "invalid") {
        errors.push({
          attribute: 'molecularTarget',
          message: "This target is not associated with the clone below"
        });
      }
      cloneName = this.getCloneName().get('stringValue');
      if (cloneName === "invalid") {
        errors.push({
          attribute: 'cloneName',
          message: "This clone does not exist"
        });
      }
      if (errors.length > 0) {
        return errors;
      } else {
        return null;
      }
    };

    PrimaryScreenProtocolParameters.prototype.getCurveDisplayMin = function() {
      var minY;
      minY = this.getOrCreateValueByTypeAndKind("numericValue", "curve display min");
      if (minY.get('numericValue') === void 0 || minY.get('numericValue') === "") {
        minY.set({
          numericValue: -20.0
        });
      }
      return minY;
    };

    PrimaryScreenProtocolParameters.prototype.getCurveDisplayMax = function() {
      var maxY;
      maxY = this.getOrCreateValueByTypeAndKind("numericValue", "curve display max");
      if (maxY.get('numericValue') === void 0 || maxY.get('numericValue') === "") {
        maxY.set({
          numericValue: 120.0
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
          codeOrigin: window.conf.molecularTargetCodeOrigin
        });
      }
      return mt;
    };

    PrimaryScreenProtocolParameters.prototype.getCloneName = function() {
      var cloneName;
      cloneName = this.getOrCreateValueByTypeAndKind("stringValue", "clone name");
      if (cloneName.get('stringValue') === void 0 || cloneName.get('stringValue') === null) {
        cloneName.set({
          stringValue: ""
        });
      }
      return cloneName;
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

  window.PrimaryScreenProtocol = (function(superClass) {
    extend(PrimaryScreenProtocol, superClass);

    function PrimaryScreenProtocol() {
      this.validate = bind(this.validate, this);
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
      var errors, psAnalysisParameters, psAnalysisParametersErrors, psModelFitParameters, psModelFitParametersErrors, psProtocolParameters, psProtocolParametersErrors;
      errors = [];
      errors.push.apply(errors, PrimaryScreenProtocol.__super__.validate.call(this, attrs));
      psProtocolParameters = this.getPrimaryScreenProtocolParameters();
      psProtocolParametersErrors = psProtocolParameters.validate();
      errors.push.apply(errors, psProtocolParametersErrors);
      psAnalysisParameters = this.getAnalysisParameters();
      psAnalysisParametersErrors = psAnalysisParameters.validate(psAnalysisParameters.attributes);
      errors.push.apply(errors, psAnalysisParametersErrors);
      psModelFitParameters = new DoseResponseAnalysisParameters(this.getModelFitParameters());
      psModelFitParametersErrors = psModelFitParameters.validate(psModelFitParameters.attributes);
      errors.push.apply(errors, psModelFitParametersErrors);
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

    PrimaryScreenProtocol.prototype.getModelFitTransformation = function() {
      var trans;
      trans = this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "experiment metadata", "stringValue", "model fit transformation");
      if (!trans.has('stringValue')) {
        trans.set({
          stringValue: "Select Fit Transformation"
        });
      }
      return trans;
    };

    PrimaryScreenProtocol.prototype.getModelFitTransformationUnits = function() {
      var tu;
      tu = this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "experiment metadata", "codeValue", "model fit transformation units");
      if (!tu.has('codeValue')) {
        tu.set({
          codeValue: "%"
        });
        tu.set({
          codeType: "model fit"
        });
        tu.set({
          codeKind: "transformation units"
        });
        tu.set({
          codeOrigin: "ACAS DDICT"
        });
      }
      return tu;
    };

    return PrimaryScreenProtocol;

  })(Protocol);

  window.PrimaryScreenProtocolParametersController = (function(superClass) {
    extend(PrimaryScreenProtocolParametersController, superClass);

    function PrimaryScreenProtocolParametersController() {
      this.saveNewPickListOptions = bind(this.saveNewPickListOptions, this);
      this.handleCurveDisplayMinChanged = bind(this.handleCurveDisplayMinChanged, this);
      this.handleCurveDisplayMaxChanged = bind(this.handleCurveDisplayMaxChanged, this);
      this.handleCellLineChanged = bind(this.handleCellLineChanged, this);
      this.handleAssayTechnologyChanged = bind(this.handleAssayTechnologyChanged, this);
      this.handleAssayTypeChanged = bind(this.handleAssayTypeChanged, this);
      this.handleTargetOriginChanged = bind(this.handleTargetOriginChanged, this);
      this.checkCloneTarget = bind(this.checkCloneTarget, this);
      this.handleCloneValidationReturn = bind(this.handleCloneValidationReturn, this);
      this.validateClone = bind(this.validateClone, this);
      this.handleCloneNameChanged = bind(this.handleCloneNameChanged, this);
      this.handleMolecularTargetChanged = bind(this.handleMolecularTargetChanged, this);
      this.handleAssayActivityChanged = bind(this.handleAssayActivityChanged, this);
      this.render = bind(this.render, this);
      return PrimaryScreenProtocolParametersController.__super__.constructor.apply(this, arguments);
    }

    PrimaryScreenProtocolParametersController.prototype.template = _.template($("#PrimaryScreenProtocolParametersView").html());

    PrimaryScreenProtocolParametersController.prototype.autofillTemplate = _.template($("#PrimaryScreenProtocolParametersAutofillView").html());

    PrimaryScreenProtocolParametersController.prototype.events = {
      "keyup .bv_maxY": "handleCurveDisplayMaxChanged",
      "keyup .bv_minY": "handleCurveDisplayMinChanged",
      "change .bv_assayActivity": "handleAssayActivityChanged",
      "change .bv_molecularTarget": "handleMolecularTargetChanged",
      "change .bv_targetOrigin": "handleTargetOriginChanged",
      "change .bv_assayType": "handleAssayTypeChanged",
      "change .bv_assayTechnology": "handleAssayTechnologyChanged",
      "change .bv_cellLine": "handleCellLineChanged",
      "keyup .bv_cloneName": "handleCloneNameChanged"
    };

    PrimaryScreenProtocolParametersController.prototype.initialize = function() {
      this.errorOwnerName = 'PrimaryScreenProtocolParametersController';
      this.setBindings();
      PrimaryScreenProtocolParametersController.__super__.initialize.call(this);
      this.htsAdmin = window.conf.roles.htsAdmin;
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
      this.$('.bv_cloneName').val(this.model.getCloneName().get('stringValue'));
      this.setupAssayActivitySelect();
      this.setupMolecularTargetSelect();
      this.setupTargetOriginSelect();
      this.setupAssayTypeSelect();
      this.setupAssayTechnologySelect();
      this.setupCellLineSelect();
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
        roles: [this.htsAdmin]
      });
      this.assayActivityListController.on('change', this.handleAssayActivityChanged);
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
        roles: [this.htsAdmin]
      });
      this.targetOriginListController.on('change', this.handleTargetOriginChanged);
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
        roles: [this.htsAdmin]
      });
      this.assayTypeListController.on('change', this.handleAssayTypeChanged);
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
        roles: [this.htsAdmin]
      });
      this.assayTechnologyListController.on('change', this.handleAssayTechnologyChanged);
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
        roles: [this.htsAdmin]
      });
      this.cellLineListController.on('change', this.handleCellLineChanged);
      return this.cellLineListController.render();
    };

    PrimaryScreenProtocolParametersController.prototype.setupMolecularTargetSelect = function() {
      this.molecularTargetList = new PickListList();
      this.molecularTargetList.url = "/api/customerMolecularTargetCodeTable";
      return this.molecularTargetListController = new PickListSelectController({
        el: this.$('.bv_molecularTarget'),
        collection: this.molecularTargetList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select Target"
        }),
        selectedCode: this.model.getMolecularTarget().get('codeValue')
      });
    };

    PrimaryScreenProtocolParametersController.prototype.handleAssayActivityChanged = function() {
      return this.model.getAssayActivity().set({
        codeValue: this.assayActivityListController.getSelectedCode(),
        recordedBy: window.AppLaunchParams.loginUser.username,
        recordedDate: new Date().getTime()
      });
    };

    PrimaryScreenProtocolParametersController.prototype.handleMolecularTargetChanged = function() {
      this.model.getMolecularTarget().set({
        codeValue: this.molecularTargetListController.getSelectedCode(),
        recordedBy: window.AppLaunchParams.loginUser.username,
        recordedDate: new Date().getTime()
      });
      return this.handleCloneNameChanged();
    };

    PrimaryScreenProtocolParametersController.prototype.handleCloneNameChanged = function() {
      var cloneName;
      cloneName = UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_cloneName'));
      this.model.getCloneName().set({
        stringValue: cloneName,
        recordedBy: window.AppLaunchParams.loginUser.username,
        recordedDate: new Date().getTime()
      });
      if (cloneName === "") {
        return this.model.getMolecularTarget().set({
          codeValue: this.molecularTargetListController.getSelectedCode(),
          recordedBy: window.AppLaunchParams.loginUser.username,
          recordedDate: new Date().getTime()
        });
      } else {
        return this.validateClone(cloneName);
      }
    };

    PrimaryScreenProtocolParametersController.prototype.validateClone = function(cloneName) {
      return $.ajax({
        type: 'GET',
        url: "/api/cloneValidation/" + cloneName,
        success: (function(_this) {
          return function(json) {
            return _this.handleCloneValidationReturn(json);
          };
        })(this),
        error: (function(_this) {
          return function(err) {
            return alert('got error validating clone');
          };
        })(this)
      });
    };

    PrimaryScreenProtocolParametersController.prototype.handleCloneValidationReturn = function(json) {
      var cloneTarget;
      if (json.length === 0) {
        return this.model.getCloneName().set({
          stringValue: 'invalid'
        });
      } else {
        cloneTarget = json[0];
        return this.checkCloneTarget(cloneTarget);
      }
    };

    PrimaryScreenProtocolParametersController.prototype.checkCloneTarget = function(cloneTarget) {
      var selectedTarget;
      selectedTarget = this.model.getMolecularTarget().get('codeValue');
      if (selectedTarget !== cloneTarget) {
        if (this.model.getMolecularTarget().get('codeValue') === "unassigned") {
          return this.model.getMolecularTarget().set({
            codeValue: 'required'
          });
        } else {
          return this.model.getMolecularTarget().set({
            codeValue: 'invalid'
          });
        }
      }
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

    PrimaryScreenProtocolParametersController.prototype.saveNewPickListOptions = function(callback) {
      return this.assayActivityListController.saveNewOption((function(_this) {
        return function() {
          return _this.targetOriginListController.saveNewOption(function() {
            return _this.assayTypeListController.saveNewOption(function() {
              return _this.assayTechnologyListController.saveNewOption(function() {
                return _this.cellLineListController.saveNewOption(function() {
                  return callback.call();
                });
              });
            });
          });
        };
      })(this));
    };

    return PrimaryScreenProtocolParametersController;

  })(AbstractFormController);

  window.PrimaryScreenProtocolController = (function(superClass) {
    extend(PrimaryScreenProtocolController, superClass);

    function PrimaryScreenProtocolController() {
      this.attachFilesAreValid = bind(this.attachFilesAreValid, this);
      this.displayInReadOnlyMode = bind(this.displayInReadOnlyMode, this);
      this.handleCheckForNewPickListOptions = bind(this.handleCheckForNewPickListOptions, this);
      this.handleSaveClicked = bind(this.handleSaveClicked, this);
      this.setupPrimaryScreenProtocolParametersController = bind(this.setupPrimaryScreenProtocolParametersController, this);
      this.setupProtocolBaseController = bind(this.setupProtocolBaseController, this);
      return PrimaryScreenProtocolController.__super__.constructor.apply(this, arguments);
    }

    PrimaryScreenProtocolController.prototype.initialize = function() {
      if (this.options.readOnly != null) {
        this.readOnly = this.options.readOnly;
      } else {
        this.readOnly = false;
      }
      this.setupProtocolBaseController();
      this.setupPrimaryScreenProtocolParametersController();
      return this.protocolBaseController.model.on("checkForNewPickListOptions", this.handleCheckForNewPickListOptions);
    };

    PrimaryScreenProtocolController.prototype.setupProtocolBaseController = function() {
      this.protocolBaseController = new ProtocolBaseController({
        model: this.model,
        el: this.el,
        readOnly: this.readOnly
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
      this.protocolBaseController.on('reinitialize', (function(_this) {
        return function() {
          return _this.trigger('reinitialize');
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

    PrimaryScreenProtocolController.prototype.attachFilesAreValid = function() {
      return this.protocolBaseController.isValid();
    };

    return PrimaryScreenProtocolController;

  })(Backbone.View);

  window.AbstractPrimaryScreenProtocolModuleController = (function(superClass) {
    extend(AbstractPrimaryScreenProtocolModuleController, superClass);

    function AbstractPrimaryScreenProtocolModuleController() {
      this.handleConfirmClearClicked = bind(this.handleConfirmClearClicked, this);
      this.handleCancelClearClicked = bind(this.handleCancelClearClicked, this);
      this.handleNewEntityClicked = bind(this.handleNewEntityClicked, this);
      this.handleCancelComplete = bind(this.handleCancelComplete, this);
      this.handleCancelClicked = bind(this.handleCancelClicked, this);
      this.reinitialize = bind(this.reinitialize, this);
      this.isValid = bind(this.isValid, this);
      this.clearValidationErrorStyles = bind(this.clearValidationErrorStyles, this);
      this.validationError = bind(this.validationError, this);
      this.handleFinishSave = bind(this.handleFinishSave, this);
      this.prepareToSaveToDatabase = bind(this.prepareToSaveToDatabase, this);
      this.handleSaveModule = bind(this.handleSaveModule, this);
      this.updateModelFitClobValue = bind(this.updateModelFitClobValue, this);
      this.updateAnalysisClobValue = bind(this.updateAnalysisClobValue, this);
      this.setupModelFitTypeController = bind(this.setupModelFitTypeController, this);
      this.setupPrimaryScreenAnalysisParametersController = bind(this.setupPrimaryScreenAnalysisParametersController, this);
      this.setupPrimaryScreenProtocolController = bind(this.setupPrimaryScreenProtocolController, this);
      this.handleProtocolSaved = bind(this.handleProtocolSaved, this);
      this.modelChangeCallback = bind(this.modelChangeCallback, this);
      this.modelSyncCallback = bind(this.modelSyncCallback, this);
      this.completeInitialization = bind(this.completeInitialization, this);
      this.initialize = bind(this.initialize, this);
      return AbstractPrimaryScreenProtocolModuleController.__super__.constructor.apply(this, arguments);
    }

    AbstractPrimaryScreenProtocolModuleController.prototype.template = _.template($("#PrimaryScreenProtocolModuleView").html());

    AbstractPrimaryScreenProtocolModuleController.prototype.events = {
      "click .bv_saveModule": "handleSaveModule",
      "click .bv_cancelModule": "handleCancelClicked",
      "click .bv_newModule": "handleNewEntityClicked",
      "click .bv_cancelClearModule": "handleCancelClearClicked",
      "click .bv_confirmModuleClear": "handleConfirmClearClicked"
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
                    lsKind = json.lsKind;
                    if (lsKind === "Bio Activity") {
                      prot = new PrimaryScreenProtocol(json);
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
      this.listenTo(this.model, 'sync', this.modelSyncCallback);
      this.listenTo(this.model, 'change', this.modelChangeCallback);
      this.model.on('readyToSave', this.handleFinishSave);
      this.model.on('notUniqueName', (function(_this) {
        return function() {
          return _this.$('.bv_saveModuleFailed').show();
        };
      })(this));
      this.setupPrimaryScreenProtocolController();
      this.setupPrimaryScreenAnalysisParametersController();
      this.setupModelFitTypeController();
      this.errorOwnerName = 'PrimaryScreenProtocolModuleController';
      this.setBindings();
      this.$('.bv_saveAndCancelButtons').hide();
      this.$('.bv_saveModule').attr('disabled', 'disabled');
      if (this.model.isNew()) {
        this.$('.bv_saveModule').html("Save");
        this.$('.bv_saveInstructions').show();
        this.$('.bv_newModule').hide();
      } else {
        this.$('.bv_saveModule').html("Update");
        this.$('.bv_saveInstructions').hide();
        this.$('.bv_newModule').show();
      }
      this.$('.bv_cancelModule').attr('disabled', 'disabled');
      return this.trigger('amClean');
    };

    AbstractPrimaryScreenProtocolModuleController.prototype.modelSyncCallback = function() {
      if (this.model.get('subclass') == null) {
        this.model.set({
          subclass: 'protocol'
        });
      }
      this.setupPrimaryScreenProtocolController();
      this.setupPrimaryScreenAnalysisParametersController();
      this.setupModelFitTypeController();
      this.$('.bv_savingModule').hide();
      this.$('.bv_saveAndCancelButtons').hide();
      if (this.$('.bv_cancelModuleComplete').is(":visible") || $('.bv_saveModuleFailed').is(":visible")) {
        this.$('.bv_saveModuleFailed').hide();
        this.$('.bv_updateModuleComplete').hide();
      } else {
        this.$('.bv_updateModuleComplete').show();
      }
      this.$('.bv_saveModule').attr('disabled', 'disabled');
      if (this.model.isNew()) {
        this.$('.bv_saveModule').html("Save");
        this.$('.bv_saveInstructions').show();
      } else {
        this.$('.bv_saveModule').html("Update");
        this.$('.bv_saveInstructions').hide();
      }
      this.$('.bv_cancelModule').attr('disabled', 'disabled');
      return this.trigger('amClean');
    };

    AbstractPrimaryScreenProtocolModuleController.prototype.modelChangeCallback = function() {
      this.trigger('amDirty');
      this.$('.bv_updateModuleComplete').hide();
      this.$('.bv_cancelModule').removeAttr('disabled');
      return this.$('.bv_cancelModuleComplete').hide();
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
      if (this.primaryScreenProtocolController != null) {
        this.primaryScreenProtocolController.undelegateEvents();
      }
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
      this.primaryScreenProtocolController.on('reinitialize', this.reinitialize);
      this.primaryScreenProtocolController.render();
      return this.primaryScreenProtocolController.on('prepareToSaveToDatabase', this.prepareToSaveToDatabase);
    };

    AbstractPrimaryScreenProtocolModuleController.prototype.setupPrimaryScreenAnalysisParametersController = function() {
      if (this.primaryScreenAnalysisParametersController != null) {
        this.primaryScreenAnalysisParametersController.undelegateEvents();
      }
      this.primaryScreenAnalysisParametersController = new PrimaryScreenAnalysisParametersController({
        model: this.model.getAnalysisParameters(),
        el: this.$('.bv_primaryScreenAnalysisParameters')
      });
      this.primaryScreenAnalysisParametersController.model.on("transformationRuleChanged", (function(_this) {
        return function() {
          return _this.modelFitTypeController.handleTransformationRuleChanged(_this.primaryScreenAnalysisParametersController.model.get('transformationRuleList'));
        };
      })(this));
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

    AbstractPrimaryScreenProtocolModuleController.prototype.setupModelFitTypeController = function() {
      if (this.modelFitTypeController != null) {
        this.modelFitTypeController.undelegateEvents();
      }
      this.modelFitTypeController = new ModelFitTypeController({
        model: this.model,
        el: this.$('.bv_doseResponseAnalysisParameters')
      });
      this.modelFitTypeController.on('amDirty', (function(_this) {
        return function() {
          return _this.trigger('amDirty');
        };
      })(this));
      this.modelFitTypeController.on('amClean', (function(_this) {
        return function() {
          return _this.trigger('amClean');
        };
      })(this));
      this.modelFitTypeController.render();
      return this.modelFitTypeController.on('updateState', this.updateModelFitClobValue);
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
        clobValue: JSON.stringify(this.modelFitTypeController.parameterController.model.attributes),
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
        this.$('.bv_updateModuleComplete').html("Update Complete");
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

    AbstractPrimaryScreenProtocolModuleController.prototype.isValid = function() {
      if (!this.primaryScreenProtocolController.attachFilesAreValid()) {
        return this.$('.bv_saveModule').attr('disabled', 'disabled');
      }
    };

    AbstractPrimaryScreenProtocolModuleController.prototype.reinitialize = function() {
      this.model = null;
      return this.completeInitialization();
    };

    AbstractPrimaryScreenProtocolModuleController.prototype.handleCancelClicked = function() {
      if (this.model.isNew()) {
        this.reinitialize();
      } else {
        this.$('.bv_cancelingModule').show();
        this.model.fetch({
          success: this.handleCancelComplete
        });
      }
      return this.trigger('amClean');
    };

    AbstractPrimaryScreenProtocolModuleController.prototype.handleCancelComplete = function() {
      this.$('.bv_cancelingModule').hide();
      return this.$('.bv_cancelModuleComplete').show();
    };

    AbstractPrimaryScreenProtocolModuleController.prototype.handleNewEntityClicked = function() {
      return this.primaryScreenProtocolController.protocolBaseController.handleNewEntityClicked();
    };

    AbstractPrimaryScreenProtocolModuleController.prototype.handleCancelClearClicked = function() {
      return this.primaryScreenProtocolController.protocolBaseController.handleCancelClearClicked();
    };

    AbstractPrimaryScreenProtocolModuleController.prototype.handleConfirmClearClicked = function() {
      return this.primaryScreenProtocolController.protocolBaseController.handleConfirmClearClicked();
    };

    return AbstractPrimaryScreenProtocolModuleController;

  })(AbstractFormController);

  window.PrimaryScreenProtocolModuleController = (function(superClass) {
    extend(PrimaryScreenProtocolModuleController, superClass);

    function PrimaryScreenProtocolModuleController() {
      return PrimaryScreenProtocolModuleController.__super__.constructor.apply(this, arguments);
    }

    PrimaryScreenProtocolModuleController.prototype.moduleLaunchName = "primary_screen_protocol";

    return PrimaryScreenProtocolModuleController;

  })(AbstractPrimaryScreenProtocolModuleController);

}).call(this);
