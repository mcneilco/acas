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
      return this.get('vehicleControl').on("change", function() {
        return _this.trigger('change');
      });
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
      "change .bv_posControlBatch": "handleInputChanged",
      "change .bv_posControlConc": "handleInputChanged",
      "change .bv_negControlBatch": "handleInputChanged",
      "change .bv_negControlConc": "handleInputChanged",
      "change .bv_vehControlBatch": "handleInputChanged",
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
        batchCode: this.getTrimmedInput('.bv_posControlBatch'),
        concentration: this.getTrimmedInput('.bv_posControlConc')
      });
      this.model.get('negativeControl').set({
        batchCode: this.getTrimmedInput('.bv_negControlBatch'),
        concentration: this.getTrimmedInput('.bv_negControlConc')
      });
      return this.model.get('vehicleControl').set({
        batchCode: this.getTrimmedInput('.bv_vehControlBatch'),
        concentration: null
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

  window.PrimaryScreenExperimentController = (function(_super) {
    __extends(PrimaryScreenExperimentController, _super);

    function PrimaryScreenExperimentController() {
      this.handleProtocolAttributesCopied = __bind(this.handleProtocolAttributesCopied, this);
      this.handleExperimentSaved = __bind(this.handleExperimentSaved, this);
      this.handleSaveClicked = __bind(this.handleSaveClicked, this);
      _ref3 = PrimaryScreenExperimentController.__super__.constructor.apply(this, arguments);
      return _ref3;
    }

    PrimaryScreenExperimentController.prototype.template = _.template($("#PrimaryScreenExperimentView").html());

    PrimaryScreenExperimentController.prototype.events = {
      "click .bv_save": "handleSaveClicked"
    };

    PrimaryScreenExperimentController.prototype.initialize = function() {
      if (this.model == null) {
        this.model = new Experiment();
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

    PrimaryScreenExperimentController.prototype.handleSaveClicked = function() {
      return this.model.save();
    };

    PrimaryScreenExperimentController.prototype.handleExperimentSaved = function() {
      return this.analysisController.render();
    };

    PrimaryScreenExperimentController.prototype.handleProtocolAttributesCopied = function() {
      return this.analysisController.render();
    };

    return PrimaryScreenExperimentController;

  })(Backbone.View);

  window.PrimaryScreenAnalysisController = (function(_super) {
    __extends(PrimaryScreenAnalysisController, _super);

    function PrimaryScreenAnalysisController() {
      this.handleExperimentSaved = __bind(this.handleExperimentSaved, this);
      this.handleNormalizationRuleChanged = __bind(this.handleNormalizationRuleChanged, this);
      this.handleTransformationRuleChanged = __bind(this.handleTransformationRuleChanged, this);
      this.handleHitThresholdChanged = __bind(this.handleHitThresholdChanged, this);
      this.render = __bind(this.render, this);
      _ref4 = PrimaryScreenAnalysisController.__super__.constructor.apply(this, arguments);
      return _ref4;
    }

    PrimaryScreenAnalysisController.prototype.template = _.template($("#PrimaryScreenAnalysisView").html());

    PrimaryScreenAnalysisController.prototype.events = {
      "change .bv_hitThreshold": "handleHitThresholdChanged",
      "change .bv_transformationRule": "handleTransformationRuleChanged",
      "change .bv_normalizationRule": "handleNormalizationRuleChanged"
    };

    PrimaryScreenAnalysisController.prototype.initialize = function() {
      return this.model.on("synced_and_repaired", this.handleExperimentSaved);
    };

    PrimaryScreenAnalysisController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      this.showControlValues();
      this.$('.bv_hitThreshold').val(this.getHitThreshold());
      this.$('.bv_transformationRule').val(this.getTransformationRule());
      this.$('.bv_normalizationRule').val(this.getNormalizationRule());
      this.showExistingResults();
      if (!this.model.isNew()) {
        this.handleExperimentSaved();
      }
      return this;
    };

    PrimaryScreenAnalysisController.prototype.showControlValues = function() {};

    PrimaryScreenAnalysisController.prototype.getHitThreshold = function() {
      var value;
      value = this.model.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "experiment analysis parameters", "numericValue", "active efficacy threshold");
      return value.get('numericValue');
    };

    PrimaryScreenAnalysisController.prototype.getTransformationRule = function() {
      var value;
      value = this.model.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "experiment analysis parameters", "stringValue", "data transformation rule");
      return value.get('stringValue');
    };

    PrimaryScreenAnalysisController.prototype.getNormalizationRule = function() {
      var value;
      value = this.model.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "experiment analysis parameters", "stringValue", "normalization rule");
      return value.get('stringValue');
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

    PrimaryScreenAnalysisController.prototype.handleHitThresholdChanged = function() {
      var value;
      value = this.model.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "experiment analysis parameters", "numericValue", "active efficacy threshold");
      return value.set({
        numericValue: parseFloat($.trim(this.$('.bv_hitThreshold').val()))
      });
    };

    PrimaryScreenAnalysisController.prototype.handleTransformationRuleChanged = function() {
      var value;
      value = this.model.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "experiment analysis parameters", "stringValue", "data transformation rule");
      return value.set({
        stringValue: $.trim(this.$('.bv_transformationRule').val())
      });
    };

    PrimaryScreenAnalysisController.prototype.handleNormalizationRuleChanged = function() {
      var value;
      value = this.model.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "experiment analysis parameters", "stringValue", "normalization rule");
      return value.set({
        stringValue: $.trim(this.$('.bv_normalizationRule').val())
      });
    };

    PrimaryScreenAnalysisController.prototype.handleExperimentSaved = function() {
      if (this.analysisStatus === "complete") {
        return this.$('.bv_fileUploadWrapper').html("");
      } else {
        this.dataAnalysisController = new UploadAndRunPrimaryAnalsysisController({
          el: this.$('.bv_fileUploadWrapper')
        });
        this.dataAnalysisController.setUser(this.model.get('recordedBy'));
        return this.dataAnalysisController.setExperimentId(this.model.id);
      }
    };

    return PrimaryScreenAnalysisController;

  })(Backbone.View);

  window.UploadAndRunPrimaryAnalsysisController = (function(_super) {
    __extends(UploadAndRunPrimaryAnalsysisController, _super);

    function UploadAndRunPrimaryAnalsysisController() {
      _ref5 = UploadAndRunPrimaryAnalsysisController.__super__.constructor.apply(this, arguments);
      return _ref5;
    }

    UploadAndRunPrimaryAnalsysisController.prototype.initialize = function() {
      UploadAndRunPrimaryAnalsysisController.__super__.initialize.apply(this, arguments);
      this.fileProcessorURL = "/api/primaryAnalysis/runPrimaryAnalysis";
      this.errorOwnerName = 'UploadAndRunPrimaryAnalsysisController';
      this.allowedFileTypes = ['zip'];
      UploadAndRunPrimaryAnalsysisController.__super__.initialize.call(this);
      return this.$('.bv_moduleTitle').html("Upload Data and Analyze");
    };

    UploadAndRunPrimaryAnalsysisController.prototype.setUser = function(user) {
      return this.userName = user;
    };

    UploadAndRunPrimaryAnalsysisController.prototype.setExperimentId = function(expId) {
      return this.additionalData = {
        primaryAnalysisExperimentId: expId,
        testMode: false
      };
    };

    return UploadAndRunPrimaryAnalsysisController;

  })(BasicFileValidateAndSaveController);

}).call(this);
