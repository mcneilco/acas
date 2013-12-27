(function() {
  var _ref, _ref1, _ref2, _ref3, _ref4, _ref5,
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

    PrimaryScreenExperiment.prototype.getAnalysisStatus = function() {
      return this.get('lsStates').getStateValueByTypeAndKind("metadata", "experiment metadata", "stringValue", "analysis status");
    };

    PrimaryScreenExperiment.prototype.getAnalysisResultHTML = function() {
      return this.get('lsStates').getStateValueByTypeAndKind("metadata", "experiment metadata", "clobValue", "analysis result html");
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
      "change .bv_transformationRule": "updateModel",
      "change .bv_normalizationRule": "updateModel",
      "change .bv_transformationRule": "updateModel",
      "change .bv_hitEfficacyThreshold": "updateModel",
      "change .bv_hitSDThreshold": "updateModel",
      "change .bv_positiveControlBatch": "updateModel",
      "change .bv_positiveControlConc": "updateModel",
      "change .bv_negativeControlBatch": "updateModel",
      "change .bv_negativeControlConc": "updateModel",
      "change .bv_vehicleControlBatch": "updateModel",
      "change .bv_agonistControlBatch": "updateModel",
      "change .bv_agonistControlConc": "updateModel",
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
        return this.$('.bv_hitEfficacyThreshold').removeAttr('disabled');
      } else {
        this.$('.bv_hitEfficacyThreshold').attr('disabled', 'disabled');
        return this.$('.bv_hitSDThreshold').removeAttr('disabled');
      }
    };

    return PrimaryScreenAnalysisParametersController;

  })(AbstractParserFormController);

  window.UploadAndRunPrimaryAnalsysisController = (function(_super) {
    __extends(UploadAndRunPrimaryAnalsysisController, _super);

    function UploadAndRunPrimaryAnalsysisController() {
      this.validateParseFile = __bind(this.validateParseFile, this);
      this.handleSaveReturnSuccess = __bind(this.handleSaveReturnSuccess, this);
      this.handleValidationReturnSuccess = __bind(this.handleValidationReturnSuccess, this);
      this.parseAndSave = __bind(this.parseAndSave, this);
      this.handleMSFormInvalid = __bind(this.handleMSFormInvalid, this);
      this.handleMSFormValid = __bind(this.handleMSFormValid, this);
      _ref3 = UploadAndRunPrimaryAnalsysisController.__super__.constructor.apply(this, arguments);
      return _ref3;
    }

    UploadAndRunPrimaryAnalsysisController.prototype.initialize = function() {
      var _this = this;
      this.fileProcessorURL = "/api/primaryAnalysis/runPrimaryAnalysis";
      this.errorOwnerName = 'UploadAndRunPrimaryAnalsysisController';
      this.allowedFileTypes = ['zip'];
      this.loadReportFile = false;
      UploadAndRunPrimaryAnalsysisController.__super__.initialize.call(this);
      this.$('.bv_moduleTitle').html("Upload Data and Analyze");
      this.psapc = new PrimaryScreenAnalysisParametersController({
        model: this.options.paramsFromExperiment,
        el: this.$('.bv_additionalValuesForm')
      });
      this.psapc.on('valid', this.handleMSFormValid);
      this.psapc.on('invalid', this.handleMSFormInvalid);
      this.psapc.on('notifyError', this.notificationController.addNotification);
      this.psapc.on('clearErrors', this.notificationController.clearAllNotificiations);
      this.psapc.on('amDirty', function() {
        return _this.trigger('amDirty');
      });
      this.analyzedPreviously = this.options.analyzedPreviously;
      this.psapc.render();
      if (this.analyzedPreviously) {
        this.$('.bv_save').html("Re-Analyze");
      }
      return this.handleMSFormInvalid();
    };

    UploadAndRunPrimaryAnalsysisController.prototype.handleMSFormValid = function() {
      if (this.parseFileUploaded) {
        return this.handleFormValid();
      }
    };

    UploadAndRunPrimaryAnalsysisController.prototype.handleMSFormInvalid = function() {
      return this.handleFormInvalid();
    };

    UploadAndRunPrimaryAnalsysisController.prototype.handleFormValid = function() {
      if (this.psapc.isValid()) {
        return UploadAndRunPrimaryAnalsysisController.__super__.handleFormValid.call(this);
      }
    };

    UploadAndRunPrimaryAnalsysisController.prototype.parseAndSave = function() {
      if (this.analyzedPreviously) {
        if (!confirm("Re-analyzing the data will delete the previously saved results")) {
          return;
        }
      }
      return UploadAndRunPrimaryAnalsysisController.__super__.parseAndSave.call(this);
    };

    UploadAndRunPrimaryAnalsysisController.prototype.handleValidationReturnSuccess = function(json) {
      UploadAndRunPrimaryAnalsysisController.__super__.handleValidationReturnSuccess.call(this, json);
      return this.psapc.disableAllInputs();
    };

    UploadAndRunPrimaryAnalsysisController.prototype.handleSaveReturnSuccess = function(json) {
      UploadAndRunPrimaryAnalsysisController.__super__.handleSaveReturnSuccess.call(this, json);
      this.$('.bv_loadAnother').html("Re-Analyze");
      return this.trigger('analysis-completed');
    };

    UploadAndRunPrimaryAnalsysisController.prototype.showFileSelectPhase = function() {
      UploadAndRunPrimaryAnalsysisController.__super__.showFileSelectPhase.call(this);
      if (this.psapc != null) {
        return this.psapc.enableAllInputs();
      }
    };

    UploadAndRunPrimaryAnalsysisController.prototype.disableAll = function() {
      this.psapc.disableAllInputs();
      this.$('.bv_htmlSummary').hide();
      this.$('.bv_fileUploadWrapper').hide();
      this.$('.bv_nextControlContainer').hide();
      this.$('.bv_saveControlContainer').hide();
      this.$('.bv_completeControlContainer').hide();
      return this.$('.bv_notifications').hide();
    };

    UploadAndRunPrimaryAnalsysisController.prototype.enableAll = function() {
      this.psapc.enableAllInputs();
      return this.showFileSelectPhase();
    };

    UploadAndRunPrimaryAnalsysisController.prototype.validateParseFile = function() {
      this.psapc.updateModel();
      if (!!this.psapc.isValid()) {
        this.additionalData = {
          inputParameters: JSON.stringify(this.psapc.model),
          primaryAnalysisExperimentId: this.experimentId,
          testMode: false
        };
        return UploadAndRunPrimaryAnalsysisController.__super__.validateParseFile.call(this);
      }
    };

    UploadAndRunPrimaryAnalsysisController.prototype.setUser = function(user) {
      return this.userName = user;
    };

    UploadAndRunPrimaryAnalsysisController.prototype.setExperimentId = function(expId) {
      return this.experimentId = expId;
    };

    return UploadAndRunPrimaryAnalsysisController;

  })(BasicFileValidateAndSaveController);

  window.PrimaryScreenAnalysisController = (function(_super) {
    __extends(PrimaryScreenAnalysisController, _super);

    function PrimaryScreenAnalysisController() {
      this.handleStatusChanged = __bind(this.handleStatusChanged, this);
      this.handleAnalysisComplete = __bind(this.handleAnalysisComplete, this);
      this.handleExperimentSaved = __bind(this.handleExperimentSaved, this);
      this.setExperimentSaved = __bind(this.setExperimentSaved, this);
      this.render = __bind(this.render, this);
      _ref4 = PrimaryScreenAnalysisController.__super__.constructor.apply(this, arguments);
      return _ref4;
    }

    PrimaryScreenAnalysisController.prototype.template = _.template($("#PrimaryScreenAnalysisView").html());

    PrimaryScreenAnalysisController.prototype.initialize = function() {
      this.model.on("sync", this.handleExperimentSaved);
      this.model.getStatus().on('change', this.handleStatusChanged);
      $(this.el).empty();
      $(this.el).html(this.template());
      if (this.model.isNew()) {
        return this.setExperimentNotSaved();
      } else {
        this.setupDataAnalysisController();
        return this.setExperimentSaved();
      }
    };

    PrimaryScreenAnalysisController.prototype.render = function() {
      return this.showExistingResults();
    };

    PrimaryScreenAnalysisController.prototype.showExistingResults = function() {
      var analysisStatus, resultValue;
      analysisStatus = this.model.getAnalysisStatus();
      if (analysisStatus !== null) {
        analysisStatus = analysisStatus.get('stringValue');
      } else {
        analysisStatus = "not started";
      }
      this.$('.bv_analysisStatus').html(analysisStatus);
      resultValue = this.model.getAnalysisResultHTML();
      if (resultValue !== null) {
        this.$('.bv_analysisResultsHTML').html(resultValue.get('clobValue'));
        return this.$('.bv_resultsContainer').show();
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
        this.setupDataAnalysisController();
      }
      return this.setExperimentSaved();
    };

    PrimaryScreenAnalysisController.prototype.handleAnalysisComplete = function() {
      console.log("got analysis complete");
      return this.$('.bv_resultsContainer').hide();
    };

    PrimaryScreenAnalysisController.prototype.handleStatusChanged = function() {
      console.log("got status change");
      if (this.model.isEditable()) {
        return this.dataAnalysisController.enableAll();
      } else {
        return this.dataAnalysisController.disableAll();
      }
    };

    PrimaryScreenAnalysisController.prototype.setupDataAnalysisController = function() {
      this.dataAnalysisController = new UploadAndRunPrimaryAnalsysisController({
        el: this.$('.bv_fileUploadWrapper'),
        paramsFromExperiment: this.model.getAnalysisParameters(),
        analyzedPreviously: this.model.getAnalysisStatus().get('stringValue') !== "not started"
      });
      this.dataAnalysisController.setUser(this.model.get('recordedBy'));
      this.dataAnalysisController.setExperimentId(this.model.id);
      return this.dataAnalysisController.on('analysis-completed', this.handleAnalysisComplete);
    };

    return PrimaryScreenAnalysisController;

  })(Backbone.View);

  window.PrimaryScreenExperimentController = (function(_super) {
    __extends(PrimaryScreenExperimentController, _super);

    function PrimaryScreenExperimentController() {
      this.handleProtocolAttributesCopied = __bind(this.handleProtocolAttributesCopied, this);
      this.handleExperimentSaved = __bind(this.handleExperimentSaved, this);
      _ref5 = PrimaryScreenExperimentController.__super__.constructor.apply(this, arguments);
      return _ref5;
    }

    PrimaryScreenExperimentController.prototype.template = _.template($("#PrimaryScreenExperimentView").html());

    PrimaryScreenExperimentController.prototype.initialize = function() {
      if (this.model == null) {
        this.model = new PrimaryScreenExperiment();
      }
      $(this.el).html(this.template());
      this.model.on('sync', this.handleExperimentSaved);
      this.experimentBaseController = new ExperimentBaseController({
        model: this.model,
        el: this.$('.bv_experimentBase')
      });
      this.analysisController = new PrimaryScreenAnalysisController({
        model: this.model,
        el: this.$('.bv_primaryScreenDataAnalysis')
      });
      this.doseRespController = new DoseResponseAnalysisController({
        model: this.model,
        el: this.$('.bv_doseResponseAnalysis')
      });
      return this.model.on("protocol_attributes_copied", this.handleProtocolAttributesCopied);
    };

    PrimaryScreenExperimentController.prototype.render = function() {
      this.experimentBaseController.render();
      this.analysisController.render();
      this.doseRespController.render();
      return this;
    };

    PrimaryScreenExperimentController.prototype.handleExperimentSaved = function() {
      return this.analysisController.render();
    };

    PrimaryScreenExperimentController.prototype.handleProtocolAttributesCopied = function() {
      return this.analysisController.render();
    };

    return PrimaryScreenExperimentController;

  })(Backbone.View);

}).call(this);
