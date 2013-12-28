(function() {
  var _ref, _ref1, _ref2,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.PrimaryScreenExperimentController = (function(_super) {
    __extends(PrimaryScreenExperimentController, _super);

    function PrimaryScreenExperimentController() {
      this.handleProtocolAttributesCopied = __bind(this.handleProtocolAttributesCopied, this);
      this.handleExperimentSaved = __bind(this.handleExperimentSaved, this);
      this.handleSaveClicked = __bind(this.handleSaveClicked, this);
      _ref = PrimaryScreenExperimentController.__super__.constructor.apply(this, arguments);
      return _ref;
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
      this.handleHitThresholdChanged = __bind(this.handleHitThresholdChanged, this);
      this.render = __bind(this.render, this);
      _ref1 = PrimaryScreenAnalysisController.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    PrimaryScreenAnalysisController.prototype.template = _.template($("#PrimaryScreenAnalysisView").html());

    PrimaryScreenAnalysisController.prototype.events = {
      "change .bv_hitThreshold": "handleHitThresholdChanged"
    };

    PrimaryScreenAnalysisController.prototype.initialize = function() {
      return this.model.on("synced_and_repaired", this.handleExperimentSaved);
    };

    PrimaryScreenAnalysisController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      this.getControlStates();
      this.$('.bv_hitThreshold').val(this.getHitThreshold());
      this.showExistingResults();
      if (!this.model.isNew()) {
        this.handleExperimentSaved();
      }
      return this;
    };

    PrimaryScreenAnalysisController.prototype.getControlStates = function() {
      return this.controlStates = this.model.get('experimentStates').getStatesByTypeAndKind("metadata", "experiment controls");
    };

    PrimaryScreenAnalysisController.prototype.getHitThreshold = function() {
      var desc, value;
      value = this.model.get('experimentStates').getStateValueByTypeAndKind("metadata", "experiment analysis parameters", "numericValue", "active efficacy threshold");
      desc = "";
      if (value !== null) {
        desc = value.get('numericValue');
      }
      return desc;
    };

    PrimaryScreenAnalysisController.prototype.showExistingResults = function() {
      var analysisStatus, resultValue;
      analysisStatus = this.model.get('experimentStates').getStateValueByTypeAndKind("metadata", "experiment metadata", "stringValue", "analysis status");
      if (analysisStatus !== null) {
        this.analysisStatus = analysisStatus.get('stringValue');
        this.$('.bv_analysisStatus').html(this.analysisStatus);
      } else {
        this.analysisStatus = "not started";
      }
      resultValue = this.model.get('experimentStates').getStateValueByTypeAndKind("metadata", "experiment metadata", "clobValue", "analysis result html");
      if (resultValue !== null) {
        return this.$('.bv_analysisResultsHTML').html(resultValue.get('clobValue'));
      }
    };

    PrimaryScreenAnalysisController.prototype.handleHitThresholdChanged = function() {
      var value;
      value = this.model.get('experimentStates').getStateValueByTypeAndKind("metadata", "experiment analysis parameters", "numericValue", "active efficacy threshold");
      return value.set({
        numericValue: parseFloat($.trim(this.$('.bv_hitThreshold').val()))
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
      _ref2 = UploadAndRunPrimaryAnalsysisController.__super__.constructor.apply(this, arguments);
      return _ref2;
    }

    UploadAndRunPrimaryAnalsysisController.prototype.initialize = function() {
      UploadAndRunPrimaryAnalsysisController.__super__.initialize.apply(this, arguments);
      this.fileProcessorURL = "/api/primaryAnalysis/runPrimaryAnalysis";
      this.errorOwnerName = 'UploadAndRunPrimaryAnalsysisController';
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
