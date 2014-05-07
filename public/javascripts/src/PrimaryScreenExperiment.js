(function() {
  var _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.PrimaryScreenAnalysisParameters = (function(_super) {
    __extends(PrimaryScreenAnalysisParameters, _super);

    function PrimaryScreenAnalysisParameters() {
      this.fixCompositeClasses = __bind(this.fixCompositeClasses, this);
      _ref = PrimaryScreenAnalysisParameters.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    PrimaryScreenAnalysisParameters.prototype.defaults = {
      transformationRule: "unassigned",
      normalizationRule: "unassigned",
      hitEfficacyThreshold: null,
      hitSDThreshold: null,
      positiveControl: new Backbone.Model(),
      negativeControl: new Backbone.Model(),
      vehicleControl: new Backbone.Model(),
      agonistControl: new Backbone.Model(),
      thresholdType: "sd"
    };

    PrimaryScreenAnalysisParameters.prototype.initialize = function() {
      return this.fixCompositeClasses();
    };

    PrimaryScreenAnalysisParameters.prototype.fixCompositeClasses = function() {
      var _this = this;
      if (!(this.get('positiveControl') instanceof Backbone.Model)) {
        this.set({
          positiveControl: new Backbone.Model(this.get('positiveControl'))
        });
      }
      this.get('positiveControl').on("change", function() {
        return _this.trigger('change');
      });
      if (!(this.get('negativeControl') instanceof Backbone.Model)) {
        this.set({
          negativeControl: new Backbone.Model(this.get('negativeControl'))
        });
      }
      this.get('negativeControl').on("change", function() {
        return _this.trigger('change');
      });
      if (!(this.get('vehicleControl') instanceof Backbone.Model)) {
        this.set({
          vehicleControl: new Backbone.Model(this.get('vehicleControl'))
        });
      }
      this.get('vehicleControl').on("change", function() {
        return _this.trigger('change');
      });
      if (!(this.get('agonistControl') instanceof Backbone.Model)) {
        this.set({
          agonistControl: new Backbone.Model(this.get('agonistControl'))
        });
      }
      return this.get('agonistControl').on("change", function() {
        return _this.trigger('change');
      });
    };

    PrimaryScreenAnalysisParameters.prototype.validate = function(attrs) {
      var agonistControl, agonistControlConc, errors, negativeControl, negativeControlConc, positiveControl, positiveControlConc, vehicleControl;
      errors = [];
      positiveControl = this.get('positiveControl').get('batchCode');
      if (positiveControl === "" || positiveControl === void 0) {
        errors.push({
          attribute: 'positiveControlBatch',
          message: "Positive control batch much be set"
        });
      }
      positiveControlConc = this.get('positiveControl').get('concentration');
      if (_.isNaN(positiveControlConc) || positiveControlConc === void 0) {
        errors.push({
          attribute: 'positiveControlConc',
          message: "Positive control conc much be set"
        });
      }
      negativeControl = this.get('negativeControl').get('batchCode');
      if (negativeControl === "" || negativeControl === void 0) {
        errors.push({
          attribute: 'negativeControlBatch',
          message: "Negative control batch much be set"
        });
      }
      negativeControlConc = this.get('negativeControl').get('concentration');
      if (_.isNaN(negativeControlConc) || negativeControlConc === void 0) {
        errors.push({
          attribute: 'negativeControlConc',
          message: "Negative control conc much be set"
        });
      }
      agonistControl = this.get('agonistControl').get('batchCode');
      if (agonistControl === "" || agonistControl === void 0) {
        errors.push({
          attribute: 'agonistControlBatch',
          message: "Agonist control batch much be set"
        });
      }
      agonistControlConc = this.get('agonistControl').get('concentration');
      if (_.isNaN(agonistControlConc) || agonistControlConc === void 0) {
        errors.push({
          attribute: 'agonistControlConc',
          message: "Agonist control conc much be set"
        });
      }
      vehicleControl = this.get('vehicleControl').get('batchCode');
      if (vehicleControl === "" || vehicleControl === void 0) {
        errors.push({
          attribute: 'vehicleControlBatch',
          message: "Vehicle control must be set"
        });
      }
      if (attrs.transformationRule === "unassigned" || attrs.transformationRule === "") {
        errors.push({
          attribute: 'transformationRule',
          message: "Transformation rule must be assigned"
        });
      }
      if (attrs.normalizationRule === "unassigned" || attrs.normalizationRule === "") {
        errors.push({
          attribute: 'normalizationRule',
          message: "Normalization rule must be assigned"
        });
      }
      if (attrs.thresholdType === "sd" && _.isNaN(attrs.hitSDThreshold)) {
        errors.push({
          attribute: 'hitSDThreshold',
          message: "SD threshold must be assigned"
        });
      }
      if (attrs.thresholdType === "efficacy" && _.isNaN(attrs.hitEfficacyThreshold)) {
        errors.push({
          attribute: 'hitEfficacyThreshold',
          message: "Efficacy threshold must be assigned"
        });
      }
      if (errors.length > 0) {
        return errors;
      } else {
        return null;
      }
    };

    return PrimaryScreenAnalysisParameters;

  })(Backbone.Model);

  window.PrimaryScreenExperiment = (function(_super) {
    __extends(PrimaryScreenExperiment, _super);

    function PrimaryScreenExperiment() {
      _ref1 = PrimaryScreenExperiment.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    PrimaryScreenExperiment.prototype.getAnalysisParameters = function() {
      var ap;
      ap = this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "experiment metadata", "clobValue", "data analysis parameters");
      if (ap.get('clobValue') != null) {
        return new PrimaryScreenAnalysisParameters($.parseJSON(ap.get('clobValue')));
      } else {
        return new PrimaryScreenAnalysisParameters();
      }
    };

    PrimaryScreenExperiment.prototype.getModelFitParameters = function() {
      var ap;
      ap = this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "experiment metadata", "clobValue", "model fit parameters");
      if (ap.get('clobValue') != null) {
        return $.parseJSON(ap.get('clobValue'));
      } else {
        return {};
      }
    };

    PrimaryScreenExperiment.prototype.getAnalysisStatus = function() {
      var status;
      status = this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "experiment metadata", "stringValue", "analysis status");
      if (!status.has('stringValue')) {
        status.set({
          stringValue: "not started"
        });
      }
      return status;
    };

    PrimaryScreenExperiment.prototype.getAnalysisResultHTML = function() {
      var result;
      result = this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "experiment metadata", "clobValue", "analysis result html");
      if (!result.has('clobValue')) {
        result.set({
          clobValue: ""
        });
      }
      return result;
    };

    PrimaryScreenExperiment.prototype.getModelFitStatus = function() {
      var status;
      status = this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "experiment metadata", "stringValue", "model fit status");
      if (!status.has('stringValue')) {
        status.set({
          stringValue: "not started"
        });
      }
      return status;
    };

    PrimaryScreenExperiment.prototype.getModelFitResultHTML = function() {
      var result;
      result = this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "experiment metadata", "clobValue", "model fit result html");
      if (!result.has('clobValue')) {
        result.set({
          clobValue: ""
        });
      }
      return result;
    };

    return PrimaryScreenExperiment;

  })(Experiment);

  window.PrimaryScreenAnalysisParametersController = (function(_super) {
    __extends(PrimaryScreenAnalysisParametersController, _super);

    function PrimaryScreenAnalysisParametersController() {
      this.handleThresholdTypeChanged = __bind(this.handleThresholdTypeChanged, this);
      this.updateModel = __bind(this.updateModel, this);
      this.render = __bind(this.render, this);
      _ref2 = PrimaryScreenAnalysisParametersController.__super__.constructor.apply(this, arguments);
      return _ref2;
    }

    PrimaryScreenAnalysisParametersController.prototype.template = _.template($("#PrimaryScreenAnalysisParametersView").html());

    PrimaryScreenAnalysisParametersController.prototype.autofillTemplate = _.template($("#PrimaryScreenAnalysisParametersAutofillView").html());

    PrimaryScreenAnalysisParametersController.prototype.events = {
      "change .bv_transformationRule": "attributeChanged",
      "change .bv_normalizationRule": "attributeChanged",
      "change .bv_transformationRule": "attributeChanged",
      "change .bv_hitEfficacyThreshold": "attributeChanged",
      "change .bv_hitSDThreshold": "attributeChanged",
      "change .bv_positiveControlBatch": "attributeChanged",
      "change .bv_positiveControlConc": "attributeChanged",
      "change .bv_negativeControlBatch": "attributeChanged",
      "change .bv_negativeControlConc": "attributeChanged",
      "change .bv_vehicleControlBatch": "attributeChanged",
      "change .bv_agonistControlBatch": "attributeChanged",
      "change .bv_agonistControlConc": "attributeChanged",
      "change .bv_thresholdTypeEfficacy": "handleThresholdTypeChanged",
      "change .bv_thresholdTypeSD": "handleThresholdTypeChanged"
    };

    PrimaryScreenAnalysisParametersController.prototype.initialize = function() {
      this.errorOwnerName = 'PrimaryScreenAnalysisParametersController';
      return PrimaryScreenAnalysisParametersController.__super__.initialize.call(this);
    };

    PrimaryScreenAnalysisParametersController.prototype.render = function() {
      this.$('.bv_autofillSection').empty();
      this.$('.bv_autofillSection').html(this.autofillTemplate(this.model.attributes));
      this.$('.bv_transformationRule').val(this.model.get('transformationRule'));
      this.$('.bv_normalizationRule').val(this.model.get('normalizationRule'));
      return this;
    };

    PrimaryScreenAnalysisParametersController.prototype.updateModel = function() {
      this.model.set({
        transformationRule: this.$('.bv_transformationRule').val(),
        normalizationRule: this.$('.bv_normalizationRule').val(),
        hitEfficacyThreshold: parseFloat(this.getTrimmedInput('.bv_hitEfficacyThreshold')),
        hitSDThreshold: parseFloat(this.getTrimmedInput('.bv_hitSDThreshold'))
      });
      this.model.get('positiveControl').set({
        batchCode: this.getTrimmedInput('.bv_positiveControlBatch'),
        concentration: parseFloat(this.getTrimmedInput('.bv_positiveControlConc'))
      });
      this.model.get('negativeControl').set({
        batchCode: this.getTrimmedInput('.bv_negativeControlBatch'),
        concentration: parseFloat(this.getTrimmedInput('.bv_negativeControlConc'))
      });
      this.model.get('vehicleControl').set({
        batchCode: this.getTrimmedInput('.bv_vehicleControlBatch'),
        concentration: null
      });
      return this.model.get('agonistControl').set({
        batchCode: this.getTrimmedInput('.bv_agonistControlBatch'),
        concentration: parseFloat(this.getTrimmedInput('.bv_agonistControlConc'))
      });
    };

    PrimaryScreenAnalysisParametersController.prototype.handleThresholdTypeChanged = function() {
      var thresholdType;
      thresholdType = this.$("input[name='bv_thresholdType']:checked").val();
      this.model.set({
        thresholdType: thresholdType
      });
      if (thresholdType === "efficacy") {
        this.$('.bv_hitSDThreshold').attr('disabled', 'disabled');
        this.$('.bv_hitEfficacyThreshold').removeAttr('disabled');
      } else {
        this.$('.bv_hitEfficacyThreshold').attr('disabled', 'disabled');
        this.$('.bv_hitSDThreshold').removeAttr('disabled');
      }
      return this.attributeChanged();
    };

    return PrimaryScreenAnalysisParametersController;

  })(AbstractParserFormController);

  window.AbstractUploadAndRunPrimaryAnalsysisController = (function(_super) {
    __extends(AbstractUploadAndRunPrimaryAnalsysisController, _super);

    function AbstractUploadAndRunPrimaryAnalsysisController() {
      this.validateParseFile = __bind(this.validateParseFile, this);
      this.handleSaveReturnSuccess = __bind(this.handleSaveReturnSuccess, this);
      this.handleValidationReturnSuccess = __bind(this.handleValidationReturnSuccess, this);
      this.parseAndSave = __bind(this.parseAndSave, this);
      this.handleMSFormInvalid = __bind(this.handleMSFormInvalid, this);
      this.handleMSFormValid = __bind(this.handleMSFormValid, this);
      _ref3 = AbstractUploadAndRunPrimaryAnalsysisController.__super__.constructor.apply(this, arguments);
      return _ref3;
    }

    AbstractUploadAndRunPrimaryAnalsysisController.prototype.completeInitialization = function() {
      var _this = this;
      this.analysisParameterController.on('valid', this.handleMSFormValid);
      this.analysisParameterController.on('invalid', this.handleMSFormInvalid);
      this.analysisParameterController.on('notifyError', this.notificationController.addNotification);
      this.analysisParameterController.on('clearErrors', this.notificationController.clearAllNotificiations);
      this.analysisParameterController.on('amDirty', function() {
        return _this.trigger('amDirty');
      });
      this.analyzedPreviously = this.options.analyzedPreviously;
      this.analysisParameterController.render();
      if (this.analyzedPreviously) {
        this.$('.bv_save').html("Re-Analyze");
      }
      return this.handleMSFormInvalid();
    };

    AbstractUploadAndRunPrimaryAnalsysisController.prototype.handleMSFormValid = function() {
      if (this.parseFileUploaded) {
        return this.handleFormValid();
      }
    };

    AbstractUploadAndRunPrimaryAnalsysisController.prototype.handleMSFormInvalid = function() {
      return this.handleFormInvalid();
    };

    AbstractUploadAndRunPrimaryAnalsysisController.prototype.handleFormValid = function() {
      if (this.analysisParameterController.isValid()) {
        return AbstractUploadAndRunPrimaryAnalsysisController.__super__.handleFormValid.call(this);
      }
    };

    AbstractUploadAndRunPrimaryAnalsysisController.prototype.parseAndSave = function() {
      if (this.analyzedPreviously) {
        if (!confirm("Re-analyzing the data will delete the previously saved results")) {
          return;
        }
      }
      return AbstractUploadAndRunPrimaryAnalsysisController.__super__.parseAndSave.call(this);
    };

    AbstractUploadAndRunPrimaryAnalsysisController.prototype.handleValidationReturnSuccess = function(json) {
      AbstractUploadAndRunPrimaryAnalsysisController.__super__.handleValidationReturnSuccess.call(this, json);
      return this.analysisParameterController.disableAllInputs();
    };

    AbstractUploadAndRunPrimaryAnalsysisController.prototype.handleSaveReturnSuccess = function(json) {
      AbstractUploadAndRunPrimaryAnalsysisController.__super__.handleSaveReturnSuccess.call(this, json);
      this.$('.bv_loadAnother').html("Re-Analyze");
      return this.trigger('analysis-completed');
    };

    AbstractUploadAndRunPrimaryAnalsysisController.prototype.showFileSelectPhase = function() {
      AbstractUploadAndRunPrimaryAnalsysisController.__super__.showFileSelectPhase.call(this);
      if (this.analysisParameterController != null) {
        return this.analysisParameterController.enableAllInputs();
      }
    };

    AbstractUploadAndRunPrimaryAnalsysisController.prototype.disableAll = function() {
      this.analysisParameterController.disableAllInputs();
      this.$('.bv_htmlSummary').hide();
      this.$('.bv_fileUploadWrapper').hide();
      this.$('.bv_nextControlContainer').hide();
      this.$('.bv_saveControlContainer').hide();
      this.$('.bv_completeControlContainer').hide();
      return this.$('.bv_notifications').hide();
    };

    AbstractUploadAndRunPrimaryAnalsysisController.prototype.enableAll = function() {
      this.analysisParameterController.enableAllInputs();
      return this.showFileSelectPhase();
    };

    AbstractUploadAndRunPrimaryAnalsysisController.prototype.validateParseFile = function() {
      this.analysisParameterController.updateModel();
      if (!!this.analysisParameterController.isValid()) {
        this.additionalData = {
          inputParameters: JSON.stringify(this.analysisParameterController.model),
          primaryAnalysisExperimentId: this.experimentId,
          testMode: false
        };
        return AbstractUploadAndRunPrimaryAnalsysisController.__super__.validateParseFile.call(this);
      }
    };

    AbstractUploadAndRunPrimaryAnalsysisController.prototype.setUser = function(user) {
      return this.userName = user;
    };

    AbstractUploadAndRunPrimaryAnalsysisController.prototype.setExperimentId = function(expId) {
      return this.experimentId = expId;
    };

    return AbstractUploadAndRunPrimaryAnalsysisController;

  })(BasicFileValidateAndSaveController);

  window.UploadAndRunPrimaryAnalsysisController = (function(_super) {
    __extends(UploadAndRunPrimaryAnalsysisController, _super);

    function UploadAndRunPrimaryAnalsysisController() {
      _ref4 = UploadAndRunPrimaryAnalsysisController.__super__.constructor.apply(this, arguments);
      return _ref4;
    }

    UploadAndRunPrimaryAnalsysisController.prototype.initialize = function() {
      this.fileProcessorURL = "/api/primaryAnalysis/runPrimaryAnalysis";
      this.errorOwnerName = 'UploadAndRunPrimaryAnalsysisController';
      this.allowedFileTypes = ['zip'];
      this.maxFileSize = 200000000;
      this.loadReportFile = false;
      UploadAndRunPrimaryAnalsysisController.__super__.initialize.call(this);
      this.$('.bv_moduleTitle').html("Upload Data and Analyze");
      this.analysisParameterController = new PrimaryScreenAnalysisParametersController({
        model: this.options.paramsFromExperiment,
        el: this.$('.bv_additionalValuesForm')
      });
      return this.completeInitialization();
    };

    return UploadAndRunPrimaryAnalsysisController;

  })(AbstractUploadAndRunPrimaryAnalsysisController);

  window.PrimaryScreenAnalysisController = (function(_super) {
    __extends(PrimaryScreenAnalysisController, _super);

    function PrimaryScreenAnalysisController() {
      this.handleStatusChanged = __bind(this.handleStatusChanged, this);
      this.handleAnalysisComplete = __bind(this.handleAnalysisComplete, this);
      this.handleExperimentSaved = __bind(this.handleExperimentSaved, this);
      this.setExperimentSaved = __bind(this.setExperimentSaved, this);
      this.render = __bind(this.render, this);
      _ref5 = PrimaryScreenAnalysisController.__super__.constructor.apply(this, arguments);
      return _ref5;
    }

    PrimaryScreenAnalysisController.prototype.template = _.template($("#PrimaryScreenAnalysisView").html());

    PrimaryScreenAnalysisController.prototype.initialize = function() {
      this.model.on("sync", this.handleExperimentSaved);
      this.model.getStatus().on('change', this.handleStatusChanged);
      this.dataAnalysisController = null;
      $(this.el).empty();
      $(this.el).html(this.template());
      if (this.model.isNew()) {
        return this.setExperimentNotSaved();
      } else {
        this.setupDataAnalysisController(this.options.uploadAndRunControllerName);
        return this.setExperimentSaved();
      }
    };

    PrimaryScreenAnalysisController.prototype.render = function() {
      return this.showExistingResults();
    };

    PrimaryScreenAnalysisController.prototype.showExistingResults = function() {
      var analysisStatus, res, resultValue;
      analysisStatus = this.model.getAnalysisStatus();
      if (analysisStatus !== null) {
        analysisStatus = analysisStatus.get('stringValue');
      } else {
        analysisStatus = "not started";
      }
      this.$('.bv_analysisStatus').html(analysisStatus);
      resultValue = this.model.getAnalysisResultHTML();
      if (resultValue !== null) {
        res = resultValue.get('clobValue');
        if (res === "") {
          return this.$('.bv_resultsContainer').hide();
        } else {
          this.$('.bv_analysisResultsHTML').html(res);
          return this.$('.bv_resultsContainer').show();
        }
      }
    };

    PrimaryScreenAnalysisController.prototype.setExperimentNotSaved = function() {
      this.$('.bv_fileUploadWrapper').hide();
      this.$('.bv_resultsContainer').hide();
      return this.$('.bv_saveExperimentToAnalyze').show();
    };

    PrimaryScreenAnalysisController.prototype.setExperimentSaved = function() {
      this.$('.bv_saveExperimentToAnalyze').hide();
      return this.$('.bv_fileUploadWrapper').show();
    };

    PrimaryScreenAnalysisController.prototype.handleExperimentSaved = function() {
      if (this.dataAnalysisController == null) {
        this.setupDataAnalysisController(this.options.uploadAndRunControllerName);
      }
      this.model.getStatus().on('change', this.handleStatusChanged);
      return this.setExperimentSaved();
    };

    PrimaryScreenAnalysisController.prototype.handleAnalysisComplete = function() {
      this.$('.bv_resultsContainer').hide();
      return this.trigger('analysis-completed');
    };

    PrimaryScreenAnalysisController.prototype.handleStatusChanged = function() {
      if (this.dataAnalysisController !== null) {
        if (this.model.isEditable()) {
          return this.dataAnalysisController.enableAll();
        } else {
          return this.dataAnalysisController.disableAll();
        }
      }
    };

    PrimaryScreenAnalysisController.prototype.setupDataAnalysisController = function(dacClassName) {
      var newArgs,
        _this = this;
      newArgs = {
        el: this.$('.bv_fileUploadWrapper'),
        paramsFromExperiment: this.model.getAnalysisParameters(),
        analyzedPreviously: this.model.getAnalysisStatus().get('stringValue') !== "not started"
      };
      this.dataAnalysisController = new window[dacClassName](newArgs);
      this.dataAnalysisController.setUser(window.AppLaunchParams.loginUserName);
      this.dataAnalysisController.setExperimentId(this.model.id);
      this.dataAnalysisController.on('analysis-completed', this.handleAnalysisComplete);
      this.dataAnalysisController.on('amDirty', function() {
        return _this.trigger('amDirty');
      });
      return this.dataAnalysisController.on('amClean', function() {
        return _this.trigger('amClean');
      });
    };

    return PrimaryScreenAnalysisController;

  })(Backbone.View);

  window.AbstractPrimaryScreenExperimentController = (function(_super) {
    __extends(AbstractPrimaryScreenExperimentController, _super);

    function AbstractPrimaryScreenExperimentController() {
      this.handleProtocolAttributesCopied = __bind(this.handleProtocolAttributesCopied, this);
      this.handleExperimentSaved = __bind(this.handleExperimentSaved, this);
      this.completeInitialization = __bind(this.completeInitialization, this);
      _ref6 = AbstractPrimaryScreenExperimentController.__super__.constructor.apply(this, arguments);
      return _ref6;
    }

    AbstractPrimaryScreenExperimentController.prototype.template = _.template($("#PrimaryScreenExperimentView").html());

    AbstractPrimaryScreenExperimentController.prototype.initialize = function() {
      var _this = this;
      if (this.model != null) {
        return this.completeInitialization();
      } else {
        if (window.AppLaunchParams.moduleLaunchParams != null) {
          if (window.AppLaunchParams.moduleLaunchParams.moduleName === this.moduleLaunchName) {
            return $.ajax({
              type: 'GET',
              url: "/api/experiments/codename/" + window.AppLaunchParams.moduleLaunchParams.code,
              dataType: 'json',
              error: function(err) {
                alert('Could not get experiment for code in this URL, creating new one');
                return this.completeInitialization();
              },
              success: function(json) {
                var exp;
                if (json.length === 0) {
                  alert('Could not get experiment for code in this URL, creating new one');
                } else {
                  exp = new PrimaryScreenExperiment(json);
                  exp.fixCompositeClasses();
                  _this.model = exp;
                }
                return _this.completeInitialization();
              }
            });
          } else {
            return this.completeInitialization();
          }
        } else {
          return this.completeInitialization();
        }
      }
    };

    AbstractPrimaryScreenExperimentController.prototype.completeInitialization = function() {
      var _this = this;
      if (this.model == null) {
        this.model = new PrimaryScreenExperiment();
      }
      $(this.el).html(this.template());
      this.model.on('sync', this.handleExperimentSaved);
      this.experimentBaseController = new ExperimentBaseController({
        model: this.model,
        el: this.$('.bv_experimentBase'),
        protocolFilter: this.protocolFilter
      });
      this.experimentBaseController.on('amDirty', function() {
        return _this.trigger('amDirty');
      });
      this.experimentBaseController.on('amClean', function() {
        return _this.trigger('amClean');
      });
      this.analysisController = new PrimaryScreenAnalysisController({
        model: this.model,
        el: this.$('.bv_primaryScreenDataAnalysis'),
        uploadAndRunControllerName: this.uploadAndRunControllerName
      });
      this.analysisController.on('amDirty', function() {
        return _this.trigger('amDirty');
      });
      this.analysisController.on('amClean', function() {
        return _this.trigger('amClean');
      });
      this.setupModelFitController(this.modelFitControllerName);
      this.analysisController.on('analysis-completed', function() {
        return _this.modelFitController.primaryAnalysisCompleted();
      });
      this.model.on("protocol_attributes_copied", this.handleProtocolAttributesCopied);
      this.experimentBaseController.render();
      this.analysisController.render();
      return this.modelFitController.render();
    };

    AbstractPrimaryScreenExperimentController.prototype.setupModelFitController = function(modelFitControllerName) {
      var newArgs,
        _this = this;
      newArgs = {
        model: this.model,
        el: this.$('.bv_doseResponseAnalysis')
      };
      this.modelFitController = new window[modelFitControllerName](newArgs);
      this.modelFitController.on('amDirty', function() {
        return _this.trigger('amDirty');
      });
      return this.modelFitController.on('amClean', function() {
        return _this.trigger('amClean');
      });
    };

    AbstractPrimaryScreenExperimentController.prototype.handleExperimentSaved = function() {
      return this.analysisController.render();
    };

    AbstractPrimaryScreenExperimentController.prototype.handleProtocolAttributesCopied = function() {
      return this.analysisController.render();
    };

    return AbstractPrimaryScreenExperimentController;

  })(Backbone.View);

  window.PrimaryScreenExperimentController = (function(_super) {
    __extends(PrimaryScreenExperimentController, _super);

    function PrimaryScreenExperimentController() {
      _ref7 = PrimaryScreenExperimentController.__super__.constructor.apply(this, arguments);
      return _ref7;
    }

    PrimaryScreenExperimentController.prototype.uploadAndRunControllerName = "UploadAndRunPrimaryAnalsysisController";

    PrimaryScreenExperimentController.prototype.modelFitControllerName = "DoseResponseAnalysisController";

    PrimaryScreenExperimentController.prototype.protocolFilter = "?protocolName=FLIPR";

    PrimaryScreenExperimentController.prototype.moduleLaunchName = "flipr_screening_assay";

    return PrimaryScreenExperimentController;

  })(AbstractPrimaryScreenExperimentController);

}).call(this);
