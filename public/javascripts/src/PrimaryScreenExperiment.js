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
      console.log(this.attributes);
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
      console.log(this.get('agonistControl'));
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
      var agonistControl, errors, negativeControl, positiveControl, vehicleControl;
      errors = [];
      positiveControl = this.get('positiveControl').get('batchCode');
      if (positiveControl === "" || positiveControl === void 0) {
        errors.push({
          attribute: 'positiveControlBatch',
          message: "Positive control batch much be set"
        });
      }
      positiveControl = this.get('positiveControl').get('concentration');
      if (positiveControl === "" || positiveControl === void 0) {
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
      negativeControl = this.get('negativeControl').get('concentration');
      if (negativeControl === "" || negativeControl === void 0) {
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
      agonistControl = this.get('agonistControl').get('concentration');
      if (agonistControl === "" || agonistControl === void 0) {
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
        return new PrimaryScreenAnalysisParameters(eval(ap.get('clobValue')));
      } else {
        return new PrimaryScreenAnalysisParameters();
      }
    };

    return PrimaryScreenExperiment;

  })(Experiment);

  window.PrimaryScreenAnalysisParametersController = (function(_super) {
    __extends(PrimaryScreenAnalysisParametersController, _super);

    function PrimaryScreenAnalysisParametersController() {
      this.handleThresholdTypeChanged = __bind(this.handleThresholdTypeChanged, this);
      this.handleInputChanged = __bind(this.handleInputChanged, this);
      this.render = __bind(this.render, this);
      _ref2 = PrimaryScreenAnalysisParametersController.__super__.constructor.apply(this, arguments);
      return _ref2;
    }

    PrimaryScreenAnalysisParametersController.prototype.template = _.template($("#PrimaryScreenAnalysisParametersView").html());

    PrimaryScreenAnalysisParametersController.prototype.autofillTemplate = _.template($("#PrimaryScreenAnalysisParametersAutofillView").html());

    PrimaryScreenAnalysisParametersController.prototype.events = {
      "change .bv_transformationRule": "handleInputChanged",
      "change .bv_normalizationRule": "handleInputChanged",
      "change .bv_transformationRule": "handleInputChanged",
      "change .bv_hitEfficacyThreshold": "handleInputChanged",
      "change .bv_hitSDThreshold": "handleInputChanged",
      "change .bv_positiveControlBatch": "handleInputChanged",
      "change .bv_positiveControlConc": "handleInputChanged",
      "change .bv_negativeControlBatch": "handleInputChanged",
      "change .bv_negativeControlConc": "handleInputChanged",
      "change .bv_vehicleControlBatch": "handleInputChanged",
      "change .bv_agonistControlBatch": "handleInputChanged",
      "change .bv_agonistControlConc": "handleInputChanged",
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

    PrimaryScreenAnalysisParametersController.prototype.handleInputChanged = function() {
      this.model.set({
        transformationRule: this.$('.bv_transformationRule').val(),
        normalizationRule: this.$('.bv_normalizationRule').val(),
        hitEfficacyThreshold: this.getTrimmedInput('.bv_hitEfficacyThreshold'),
        hitSDThreshold: this.getTrimmedInput('.bv_hitSDThreshold')
      });
      this.model.get('positiveControl').set({
        batchCode: this.getTrimmedInput('.bv_positiveControlBatch'),
        concentration: this.getTrimmedInput('.bv_positiveControlConc')
      });
      this.model.get('negativeControl').set({
        batchCode: this.getTrimmedInput('.bv_negativeControlBatch'),
        concentration: this.getTrimmedInput('.bv_negativeControlConc')
      });
      this.model.get('vehicleControl').set({
        batchCode: this.getTrimmedInput('.bv_vehicleControlBatch'),
        concentration: null
      });
      return this.model.get('agonistControl').set({
        batchCode: this.getTrimmedInput('.bv_agonistControlBatch'),
        concentration: this.getTrimmedInput('.bv_agonistControlConc')
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

  window.PrimaryScreenAnalysisController = (function(_super) {
    __extends(PrimaryScreenAnalysisController, _super);

    function PrimaryScreenAnalysisController() {
      this.handleExperimentSaved = __bind(this.handleExperimentSaved, this);
      this.render = __bind(this.render, this);
      _ref3 = PrimaryScreenAnalysisController.__super__.constructor.apply(this, arguments);
      return _ref3;
    }

    PrimaryScreenAnalysisController.prototype.template = _.template($("#PrimaryScreenAnalysisView").html());

    PrimaryScreenAnalysisController.prototype.initialize = function() {
      return this.model.on("synced_and_repaired", this.handleExperimentSaved);
    };

    PrimaryScreenAnalysisController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      this.showExistingResults();
      if (true) {
        this.handleExperimentSaved();
      }
      return this;
    };

    PrimaryScreenAnalysisController.prototype.showExistingResults = function() {
      var analysisStatus, resultValue;
      analysisStatus = this.model.get('lsStates').getStateValueByTypeAndKind("metadata", "experiment metadata", "stringValue", "analysis status");
      if (analysisStatus !== null) {
        this.analysisStatus = analysisStatus.get('stringValue');
        this.$('.bv_analysisStatus').html(this.analysisStatus);
      } else {
        this.analysisStatus = "not started";
      }
      resultValue = this.model.get('lsStates').getStateValueByTypeAndKind("metadata", "experiment metadata", "clobValue", "analysis result html");
      if (resultValue !== null) {
        return this.$('.bv_analysisResultsHTML').html(resultValue.get('clobValue'));
      }
    };

    PrimaryScreenAnalysisController.prototype.handleExperimentSaved = function() {
      this.dataAnalysisController = new UploadAndRunPrimaryAnalsysisController({
        el: this.$('.bv_fileUploadWrapper'),
        paramsFromExperiment: this.model.getAnalysisParameters()
      });
      this.dataAnalysisController.setUser(this.model.get('recordedBy'));
      this.dataAnalysisController.setExperimentId(this.model.id);
      if (this.analysisStatus === "complete") {
        return this.dataAnalysisController.psapc.disableAllInputs();
      }
    };

    return PrimaryScreenAnalysisController;

  })(Backbone.View);

  window.UploadAndRunPrimaryAnalsysisController = (function(_super) {
    __extends(UploadAndRunPrimaryAnalsysisController, _super);

    function UploadAndRunPrimaryAnalsysisController() {
      this.validateParseFile = __bind(this.validateParseFile, this);
      this.validateParseFile = __bind(this.validateParseFile, this);
      this.handleValidationReturnSuccess = __bind(this.handleValidationReturnSuccess, this);
      this.handleMSFormInvalid = __bind(this.handleMSFormInvalid, this);
      this.handleMSFormValid = __bind(this.handleMSFormValid, this);
      _ref4 = UploadAndRunPrimaryAnalsysisController.__super__.constructor.apply(this, arguments);
      return _ref4;
    }

    UploadAndRunPrimaryAnalsysisController.prototype.initialize = function() {
      var _this = this;
      UploadAndRunPrimaryAnalsysisController.__super__.initialize.apply(this, arguments);
      this.fileProcessorURL = "/api/primaryAnalysis/runPrimaryAnalysis";
      this.errorOwnerName = 'UploadAndRunPrimaryAnalsysisController';
      this.allowedFileTypes = ['zip'];
      this.loadReportFile = false;
      UploadAndRunPrimaryAnalsysisController.__super__.initialize.call(this);
      this.$('.bv_moduleTitle').html("Upload Data and Analyze");
      this.psapc = new PrimaryScreenAnalysisParametersController({
        model: new PrimaryScreenAnalysisParameters(this.options.paramsFromExperiment),
        el: this.$('.bv_additionalValuesForm')
      });
      this.psapc.on('valid', this.handleMSFormValid);
      this.psapc.on('invalid', this.handleMSFormInvalid);
      this.psapc.on('notifyError', this.notificationController.addNotification);
      this.psapc.on('clearErrors', this.notificationController.clearAllNotificiations);
      this.psapc.on('amDirty', function() {
        return _this.trigger('amDirty');
      });
      return this.psapc.render();
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

    UploadAndRunPrimaryAnalsysisController.prototype.handleValidationReturnSuccess = function(json) {
      UploadAndRunPrimaryAnalsysisController.__super__.handleValidationReturnSuccess.call(this, json);
      return this.psapc.disableAllInputs();
    };

    UploadAndRunPrimaryAnalsysisController.prototype.showFileSelectPhase = function() {
      UploadAndRunPrimaryAnalsysisController.__super__.showFileSelectPhase.call(this);
      if (this.psapc != null) {
        return this.psapc.enableAllInputs();
      }
    };

    UploadAndRunPrimaryAnalsysisController.prototype.validateParseFile = function() {
      this.psapc.updateModel();
      if (!!this.psapc.isValid()) {
        this.additionalData = {
          inputParameters: this.psapc.model.toJSON()
        };
        return UploadAndRunPrimaryAnalsysisController.__super__.validateParseFile.call(this);
      }
    };

    UploadAndRunPrimaryAnalsysisController.prototype.validateParseFile = function() {
      this.psapc.updateModel();
      if (!!this.psapc.isValid()) {
        this.additionalData = {
          inputParameters: this.psapc.model.toJSON(),
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
