(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.DoseResponseAnalysisParameters = (function(_super) {
    __extends(DoseResponseAnalysisParameters, _super);

    function DoseResponseAnalysisParameters() {
      this.parse = __bind(this.parse, this);
      return DoseResponseAnalysisParameters.__super__.constructor.apply(this, arguments);
    }

    DoseResponseAnalysisParameters.prototype.defaults = function() {
      return {
        inactiveThreshold: 20,
        inverseAgonistMode: true,
        max: new Backbone.Model({
          limitType: 'none'
        }),
        min: new Backbone.Model({
          limitType: 'none'
        }),
        slope: new Backbone.Model({
          limitType: 'none'
        })
      };
    };

    DoseResponseAnalysisParameters.prototype.initialize = function() {
      return this.set(this.parse(this.attributes));
    };

    DoseResponseAnalysisParameters.prototype.parse = function(resp) {
      if (resp.max != null) {
        if (!(resp.max instanceof Backbone.Model)) {
          resp.max = new Backbone.Model(resp.max);
        }
        resp.max.on('change', (function(_this) {
          return function() {
            return _this.trigger('change');
          };
        })(this));
      }
      if (resp.min != null) {
        if (!(resp.min instanceof Backbone.Model)) {
          resp.min = new Backbone.Model(resp.min);
        }
        resp.min.on('change', (function(_this) {
          return function() {
            return _this.trigger('change');
          };
        })(this));
      }
      if (resp.slope != null) {
        if (!(resp.slope instanceof Backbone.Model)) {
          resp.slope = new Backbone.Model(resp.slope);
        }
        resp.slope.on('change', (function(_this) {
          return function() {
            return _this.trigger('change');
          };
        })(this));
      }
      return resp;
    };

    DoseResponseAnalysisParameters.prototype.validate = function(attrs) {
      var errors, limitType;
      errors = [];
      limitType = attrs.min.get('limitType');
      if ((limitType === "pin" || limitType === "limit") && (_.isNaN(attrs.min.get('value')) || attrs.min.get('value') === null)) {
        errors.push({
          attribute: 'min_value',
          message: "Min threshold value must be set when limit type is pin or limit"
        });
      }
      limitType = attrs.max.get('limitType');
      if ((limitType === "pin" || limitType === "limit") && (_.isNaN(attrs.max.get('value')) || attrs.max.get('value') === null)) {
        errors.push({
          attribute: 'max_value',
          message: "Max threshold value must be set when limit type is pin or limit"
        });
      }
      limitType = attrs.slope.get('limitType');
      if ((limitType === "pin" || limitType === "limit") && (_.isNaN(attrs.slope.get('value')) || attrs.slope.get('value') === null)) {
        errors.push({
          attribute: 'slope_value',
          message: "Slope threshold value must be set when limit type is pin or limit"
        });
      }
      if (_.isNaN(attrs.inactiveThreshold)) {
        errors.push({
          attribute: 'inactiveThreshold',
          message: "Inactive threshold value must be set to a number"
        });
      }
      if (errors.length > 0) {
        return errors;
      } else {
        return null;
      }
    };

    return DoseResponseAnalysisParameters;

  })(Backbone.Model);

  window.DoseResponseAnalysisParametersController = (function(_super) {
    __extends(DoseResponseAnalysisParametersController, _super);

    function DoseResponseAnalysisParametersController() {
      this.handleSlopeLimitTypeChanged = __bind(this.handleSlopeLimitTypeChanged, this);
      this.handleMinLimitTypeChanged = __bind(this.handleMinLimitTypeChanged, this);
      this.handleMaxLimitTypeChanged = __bind(this.handleMaxLimitTypeChanged, this);
      this.handleInverseAgonistModeChanged = __bind(this.handleInverseAgonistModeChanged, this);
      this.handleInactiveThresholdMoved = __bind(this.handleInactiveThresholdMoved, this);
      this.handleInactiveThresholdChanged = __bind(this.handleInactiveThresholdChanged, this);
      this.updateModel = __bind(this.updateModel, this);
      this.render = __bind(this.render, this);
      return DoseResponseAnalysisParametersController.__super__.constructor.apply(this, arguments);
    }

    DoseResponseAnalysisParametersController.prototype.template = _.template($("#DoseResponseAnalysisParametersView").html());

    DoseResponseAnalysisParametersController.prototype.autofillTemplate = _.template($("#DoseResponseAnalysisParametersAutofillView").html());

    DoseResponseAnalysisParametersController.prototype.events = {
      "change .bv_inverseAgonistMode": "handleInverseAgonistModeChanged",
      "click .bv_max_limitType_none": "handleMaxLimitTypeChanged",
      "click .bv_max_limitType_pin": "handleMaxLimitTypeChanged",
      "click .bv_max_limitType_limit": "handleMaxLimitTypeChanged",
      "click .bv_min_limitType_none": "handleMinLimitTypeChanged",
      "click .bv_min_limitType_pin": "handleMinLimitTypeChanged",
      "click .bv_min_limitType_limit": "handleMinLimitTypeChanged",
      "click .bv_slope_limitType_none": "handleSlopeLimitTypeChanged",
      "click .bv_slope_limitType_pin": "handleSlopeLimitTypeChanged",
      "click .bv_slope_limitType_limit": "handleSlopeLimitTypeChanged",
      "change .bv_max_value": "attributeChanged",
      "change .bv_min_value": "attributeChanged",
      "change .bv_slope_value": "attributeChanged"
    };

    DoseResponseAnalysisParametersController.prototype.initialize = function() {
      $(this.el).html(this.template());
      this.errorOwnerName = 'DoseResponseAnalysisParametersController';
      return this.setBindings();
    };

    DoseResponseAnalysisParametersController.prototype.render = function() {
      this.$('.bv_autofillSection').empty();
      this.$('.bv_autofillSection').html(this.autofillTemplate($.parseJSON(JSON.stringify(this.model))));
      this.$('.bv_inactiveThreshold').slider({
        value: this.model.get('inactiveThreshold'),
        min: 0,
        max: 100
      });
      this.$('.bv_inactiveThreshold').on('slide', this.handleInactiveThresholdMoved);
      this.$('.bv_inactiveThreshold').on('slidestop', this.handleInactiveThresholdChanged);
      this.updateThresholdDisplay(this.model.get('inactiveThreshold'));
      this.setFormTitle();
      return this;
    };

    DoseResponseAnalysisParametersController.prototype.updateThresholdDisplay = function(val) {
      return this.$('.bv_inactiveThresholdDisplay').html(val);
    };

    DoseResponseAnalysisParametersController.prototype.setThresholdEnabledState = function() {
      if (this.model.get('inverseAgonistMode')) {
        return this.$('.bv_inactiveThreshold').slider('disable');
      } else {
        return this.$('.bv_inactiveThreshold').slider('enable');
      }
    };

    DoseResponseAnalysisParametersController.prototype.updateModel = function() {
      this.model.get('max').set({
        value: parseFloat(UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_max_value')))
      });
      this.model.get('min').set({
        value: parseFloat(UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_min_value')))
      });
      this.model.get('slope').set({
        value: parseFloat(UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_slope_value')))
      });
      this.model.set({
        inverseAgonistMode: this.$('.bv_inverseAgonistMode').is(":checked")
      }, {
        silent: true
      });
      this.model.trigger('change');
      return this.trigger('updateState');
    };

    DoseResponseAnalysisParametersController.prototype.handleInactiveThresholdChanged = function(event, ui) {
      this.model.set({
        'inactiveThreshold': ui.value
      });
      this.updateThresholdDisplay(this.model.get('inactiveThreshold'));
      return this.attributeChanged();
    };

    DoseResponseAnalysisParametersController.prototype.handleInactiveThresholdMoved = function(event, ui) {
      return this.updateThresholdDisplay(ui.value);
    };

    DoseResponseAnalysisParametersController.prototype.handleInverseAgonistModeChanged = function() {
      return this.attributeChanged();
    };

    DoseResponseAnalysisParametersController.prototype.handleMaxLimitTypeChanged = function() {
      var radioValue;
      radioValue = this.$("input[name='bv_max_limitType']:checked").val();
      this.model.get('max').set({
        limitType: radioValue,
        silent: true
      });
      if (radioValue === 'none') {
        this.$('.bv_max_value').attr('disabled', 'disabled');
      } else {
        this.$('.bv_max_value').removeAttr('disabled');
      }
      return this.attributeChanged();
    };

    DoseResponseAnalysisParametersController.prototype.handleMinLimitTypeChanged = function() {
      var radioValue;
      radioValue = this.$("input[name='bv_min_limitType']:checked").val();
      this.model.get('min').set({
        limitType: radioValue
      });
      if (radioValue === 'none') {
        this.$('.bv_min_value').attr('disabled', 'disabled');
      } else {
        this.$('.bv_min_value').removeAttr('disabled');
      }
      return this.attributeChanged();
    };

    DoseResponseAnalysisParametersController.prototype.handleSlopeLimitTypeChanged = function() {
      var radioValue;
      radioValue = this.$("input[name='bv_slope_limitType']:checked").val();
      this.model.get('slope').set({
        limitType: radioValue
      });
      if (radioValue === 'none') {
        this.$('.bv_slope_value').attr('disabled', 'disabled');
      } else {
        this.$('.bv_slope_value').removeAttr('disabled');
      }
      return this.attributeChanged();
    };

    DoseResponseAnalysisParametersController.prototype.setFormTitle = function(title) {
      if (title != null) {
        this.formTitle = title;
        return this.$(".bv_formTitle").html(this.formTitle);
      } else if (this.formTitle != null) {
        return this.$(".bv_formTitle").html(this.formTitle);
      } else {
        return this.formTitle = this.$(".bv_formTitle").html();
      }
    };

    return DoseResponseAnalysisParametersController;

  })(AbstractFormController);

  window.DoseResponseAnalysisController = (function(_super) {
    __extends(DoseResponseAnalysisController, _super);

    function DoseResponseAnalysisController() {
      this.fitReturnSuccess = __bind(this.fitReturnSuccess, this);
      this.launchFit = __bind(this.launchFit, this);
      this.paramsInvalid = __bind(this.paramsInvalid, this);
      this.paramsValid = __bind(this.paramsValid, this);
      this.handleStatusChanged = __bind(this.handleStatusChanged, this);
      this.setReadyForFit = __bind(this.setReadyForFit, this);
      this.testReadyForFit = __bind(this.testReadyForFit, this);
      this.render = __bind(this.render, this);
      return DoseResponseAnalysisController.__super__.constructor.apply(this, arguments);
    }

    DoseResponseAnalysisController.prototype.template = _.template($("#DoseResponseAnalysisView").html());

    DoseResponseAnalysisController.prototype.events = {
      "click .bv_fitModelButton": "launchFit"
    };

    DoseResponseAnalysisController.prototype.initialize = function() {
      this.model.on("sync", this.handleExperimentSaved);
      this.model.getStatus().on('change', this.handleStatusChanged);
      this.parameterController = null;
      this.analyzedPreviously = this.model.getModelFitStatus().get('stringValue') === "not started" ? false : true;
      $(this.el).empty();
      $(this.el).html(this.template());
      return this.testReadyForFit();
    };

    DoseResponseAnalysisController.prototype.render = function() {
      var buttonText;
      this.showExistingResults();
      buttonText = this.analyzedPreviously ? "Re-Fit" : "Fit Data";
      return this.$('.bv_fitModelButton').html(buttonText);
    };

    DoseResponseAnalysisController.prototype.showExistingResults = function() {
      var fitStatus, res, resultValue;
      fitStatus = this.model.getModelFitStatus().get('stringValue');
      this.$('.bv_modelFitStatus').html(fitStatus);
      resultValue = this.model.getModelFitResultHTML();
      if (!!this.analyzedPreviously) {
        if (resultValue !== null) {
          res = resultValue.get('clobValue');
          if (res === "") {
            return this.$('.bv_resultsContainer').hide();
          } else {
            this.$('.bv_modelFitResultsHTML').html(res);
            return this.$('.bv_resultsContainer').show();
          }
        }
      }
    };

    DoseResponseAnalysisController.prototype.testReadyForFit = function() {
      if (this.model.getAnalysisStatus().get('stringValue') === "not started") {
        return this.setNotReadyForFit();
      } else {
        return this.setReadyForFit();
      }
    };

    DoseResponseAnalysisController.prototype.setNotReadyForFit = function() {
      this.$('.bv_fitOptionWrapper').hide();
      this.$('.bv_resultsContainer').hide();
      return this.$('.bv_analyzeExperimentToFit').show();
    };

    DoseResponseAnalysisController.prototype.setReadyForFit = function() {
      if (!this.parameterController) {
        this.setupCurveFitAnalysisParameterController();
      }
      this.$('.bv_fitOptionWrapper').show();
      this.$('.bv_fitModelButton').show();
      this.$('.bv_analyzeExperimentToFit').hide();
      return this.handleStatusChanged();
    };

    DoseResponseAnalysisController.prototype.primaryAnalysisCompleted = function() {
      return this.testReadyForFit();
    };

    DoseResponseAnalysisController.prototype.handleStatusChanged = function() {
      if (this.parameterController !== null) {
        if (this.model.isEditable()) {
          return this.parameterController.enableAllInputs();
        } else {
          return this.parameterController.disableAllInputs();
        }
      }
    };

    DoseResponseAnalysisController.prototype.setupCurveFitAnalysisParameterController = function() {
      this.parameterController = new DoseResponseAnalysisParametersController({
        el: this.$('.bv_analysisParameterForm'),
        model: new DoseResponseAnalysisParameters(this.model.getModelFitParameters())
      });
      this.parameterController.on('amDirty', (function(_this) {
        return function() {
          return _this.trigger('amDirty');
        };
      })(this));
      this.parameterController.on('amClean', (function(_this) {
        return function() {
          return _this.trigger('amClean');
        };
      })(this));
      this.parameterController.on('valid', this.paramsValid);
      this.parameterController.on('invalid', this.paramsInvalid);
      return this.parameterController.render();
    };

    DoseResponseAnalysisController.prototype.paramsValid = function() {
      return this.$('.bv_fitModelButton').removeAttr('disabled');
    };

    DoseResponseAnalysisController.prototype.paramsInvalid = function() {
      return this.$('.bv_fitModelButton').attr('disabled', 'disabled');
    };

    DoseResponseAnalysisController.prototype.launchFit = function() {
      var fitData;
      if (this.analyzedPreviously) {
        if (!confirm("Re-fitting the data will delete the previously fitted results")) {
          return;
        }
      }
      fitData = {
        inputParameters: JSON.stringify(this.parameterController.model),
        user: window.AppLaunchParams.loginUserName,
        experimentCode: this.model.get('codeName'),
        testMode: false
      };
      return $.ajax({
        type: 'POST',
        url: "/api/doseResponseCurveFit",
        data: fitData,
        success: this.fitReturnSuccess,
        error: (function(_this) {
          return function(err) {
            alert('got ajax error');
            return _this.serviceReturn = null;
          };
        })(this),
        dataType: 'json'
      });
    };

    DoseResponseAnalysisController.prototype.fitReturnSuccess = function(json) {
      if (!json.hasError) {
        this.analyzedPreviously = true;
        this.$('.bv_fitModelButton').html("Re-Fit");
      }
      this.$('.bv_modelFitResultsHTML').html(json.results.htmlSummary);
      this.$('.bv_modelFitStatus').html(json.results.status);
      return this.$('.bv_resultsContainer').show();
    };

    return DoseResponseAnalysisController;

  })(Backbone.View);

}).call(this);
