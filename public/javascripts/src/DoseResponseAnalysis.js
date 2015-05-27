(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.DoseResponseAnalysisParameters = (function(superClass) {
    extend(DoseResponseAnalysisParameters, superClass);

    function DoseResponseAnalysisParameters() {
      this.fixCompositeClasses = bind(this.fixCompositeClasses, this);
      return DoseResponseAnalysisParameters.__super__.constructor.apply(this, arguments);
    }

    DoseResponseAnalysisParameters.prototype.defaults = {
      smartMode: true,
      inactiveThresholdMode: true,
      inactiveThreshold: 20,
      inverseAgonistMode: false,
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

    DoseResponseAnalysisParameters.prototype.initialize = function() {
      return this.fixCompositeClasses();
    };

    DoseResponseAnalysisParameters.prototype.fixCompositeClasses = function() {
      if (!(this.get('max') instanceof Backbone.Model)) {
        this.set({
          max: new Backbone.Model(this.get('max'))
        });
      }
      if (!(this.get('min') instanceof Backbone.Model)) {
        this.set({
          min: new Backbone.Model(this.get('min'))
        });
      }
      if (!(this.get('slope') instanceof Backbone.Model)) {
        return this.set({
          slope: new Backbone.Model(this.get('slope'))
        });
      }
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

  window.DoseResponseAnalysisParametersController = (function(superClass) {
    extend(DoseResponseAnalysisParametersController, superClass);

    function DoseResponseAnalysisParametersController() {
      this.handleSlopeLimitTypeChanged = bind(this.handleSlopeLimitTypeChanged, this);
      this.handleMinLimitTypeChanged = bind(this.handleMinLimitTypeChanged, this);
      this.handleMaxLimitTypeChanged = bind(this.handleMaxLimitTypeChanged, this);
      this.handleInverseAgonistModeChanged = bind(this.handleInverseAgonistModeChanged, this);
      this.handleInactiveThresholdMoved = bind(this.handleInactiveThresholdMoved, this);
      this.handleInactiveThresholdChanged = bind(this.handleInactiveThresholdChanged, this);
      this.handleInactiveThresholdModeChanged = bind(this.handleInactiveThresholdModeChanged, this);
      this.handleSmartModeChanged = bind(this.handleSmartModeChanged, this);
      this.updateModel = bind(this.updateModel, this);
      this.render = bind(this.render, this);
      return DoseResponseAnalysisParametersController.__super__.constructor.apply(this, arguments);
    }

    DoseResponseAnalysisParametersController.prototype.template = _.template($("#DoseResponseAnalysisParametersView").html());

    DoseResponseAnalysisParametersController.prototype.autofillTemplate = _.template($("#DoseResponseAnalysisParametersAutofillView").html());

    DoseResponseAnalysisParametersController.prototype.events = {
      "change .bv_smartMode": "handleSmartModeChanged",
      "change .bv_inverseAgonistMode": "handleInverseAgonistModeChanged",
      "change .bv_inactiveThresholdMode": "handleInactiveThresholdModeChanged",
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
      this.setThresholdModeEnabledState();
      this.setInverseAgonistModeEnabledState();
      return this;
    };

    DoseResponseAnalysisParametersController.prototype.updateThresholdDisplay = function(val) {
      return this.$('.bv_inactiveThresholdDisplay').html(val);
    };

    DoseResponseAnalysisParametersController.prototype.setThresholdModeEnabledState = function() {
      if (this.model.get('smartMode')) {
        this.$('.bv_inactiveThresholdMode').removeAttr('disabled');
      } else {
        this.$('.bv_inactiveThresholdMode').attr('disabled', 'disabled');
      }
      return this.setThresholdSliderEnabledState();
    };

    DoseResponseAnalysisParametersController.prototype.setThresholdSliderEnabledState = function() {
      if (this.model.get('inactiveThresholdMode') && this.model.get('smartMode')) {
        return this.$('.bv_inactiveThreshold').slider('enable');
      } else {
        return this.$('.bv_inactiveThreshold').slider('disable');
      }
    };

    DoseResponseAnalysisParametersController.prototype.setInverseAgonistModeEnabledState = function() {
      if (this.model.get('smartMode')) {
        return this.$('.bv_inverseAgonistMode').removeAttr('disabled');
      } else {
        return this.$('.bv_inverseAgonistMode').attr('disabled', 'disabled');
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
        inactiveThresholdMode: this.$('.bv_inactiveThresholdMode').is(":checked")
      }, {
        silent: true
      });
      this.model.set({
        inverseAgonistMode: this.$('.bv_inverseAgonistMode').is(":checked")
      }, {
        silent: true
      });
      this.model.set({
        smartMode: this.$('.bv_smartMode').is(":checked")
      }, {
        silent: true
      });
      this.setThresholdModeEnabledState();
      this.setInverseAgonistModeEnabledState();
      this.model.trigger('change');
      return this.trigger('updateState');
    };

    DoseResponseAnalysisParametersController.prototype.handleSmartModeChanged = function() {
      return this.attributeChanged();
    };

    DoseResponseAnalysisParametersController.prototype.handleInactiveThresholdModeChanged = function() {
      return this.attributeChanged();
    };

    DoseResponseAnalysisParametersController.prototype.handleInactiveThresholdChanged = function(event, ui) {
      this.model.set({
        'inactiveThreshold': ui.value
      });
      this.updateThresholdDisplay(this.model.get('inactiveThreshold'));
      return this.attributeChanged;
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

  window.ModelFitTypeController = (function(superClass) {
    extend(ModelFitTypeController, superClass);

    function ModelFitTypeController() {
      this.updateModel = bind(this.updateModel, this);
      this.handleModelFitTypeChanged = bind(this.handleModelFitTypeChanged, this);
      this.setupParameterController = bind(this.setupParameterController, this);
      this.setupModelFitTypeSelect = bind(this.setupModelFitTypeSelect, this);
      this.render = bind(this.render, this);
      return ModelFitTypeController.__super__.constructor.apply(this, arguments);
    }

    ModelFitTypeController.prototype.template = _.template($("#ModelFitTypeView").html());

    ModelFitTypeController.prototype.events = {
      "change .bv_modelFitType": "handleModelFitTypeChanged"
    };

    ModelFitTypeController.prototype.render = function() {
      var modelFitType;
      $(this.el).empty();
      $(this.el).html(this.template());
      this.setupModelFitTypeSelect();
      modelFitType = this.model.getModelFitType().get('codeValue');
      return this.setupParameterController(modelFitType);
    };

    ModelFitTypeController.prototype.setupModelFitTypeSelect = function() {
      var modelFitType;
      modelFitType = this.model.getModelFitType().get('codeValue');
      this.modelFitTypeList = new PickListList();
      this.modelFitTypeList.url = "/api/codetables/model fit/type";
      return this.modelFitTypeListController = new PickListSelectController({
        el: this.$('.bv_modelFitType'),
        collection: this.modelFitTypeList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select Model Fit Type"
        }),
        selectedCode: modelFitType
      });
    };

    ModelFitTypeController.prototype.setupParameterController = function(modelFitType) {
      var controllerClass, curveFitClasses, curvefitClassesCollection, drap, drapType, drapcType, mfp, parametersClass;
      curvefitClassesCollection = new Backbone.Collection($.parseJSON(window.conf.curvefit.modelfitparameter.classes));
      curveFitClasses = curvefitClassesCollection.findWhere({
        codeValue: modelFitType
      });
      if (curveFitClasses != null) {
        parametersClass = curveFitClasses.get('parametersClass');
        drapType = window[parametersClass];
        controllerClass = curveFitClasses.get('controllerClass');
        drapcType = window[controllerClass];
      } else {
        drapType = 'unassigned';
      }
      if (this.parameterController != null) {
        this.parameterController.undelegateEvents();
      }
      if (drapType === "unassigned") {
        this.$('.bv_analysisParameterForm').empty();
        this.parameterController = null;
        mfp = this.model.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "experiment metadata", "clobValue", "model fit parameters");
        if (!(mfp.get('clobValue') === "" || "[]")) {
          return mfp.set({
            clobValue: ""
          });
        }
      } else {
        if (this.model.getModelFitParameters() === {}) {
          drap = new drapType();
        } else {
          drap = new drapType(this.model.getModelFitParameters());
        }
        this.parameterController = new drapcType({
          el: this.$('.bv_analysisParameterForm'),
          model: drap
        });
        this.trigger('updateState');
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
        this.parameterController.model.on('change', (function(_this) {
          return function() {
            return _this.trigger('updateState');
          };
        })(this));
        return this.parameterController.render();
      }
    };

    ModelFitTypeController.prototype.handleModelFitTypeChanged = function() {
      var modelFitType;
      modelFitType = this.$('.bv_modelFitType').val();
      this.setupParameterController(modelFitType);
      this.updateModel();
      return this.modelFitTypeListController.trigger('change');
    };

    ModelFitTypeController.prototype.updateModel = function() {
      this.model.getModelFitType().set({
        codeValue: this.modelFitTypeListController.getSelectedCode(),
        recordedBy: window.AppLaunchParams.loginUser.username,
        recordedDate: new Date().getTime()
      });
      return this.model.trigger('change');
    };

    return ModelFitTypeController;

  })(Backbone.View);

  window.DoseResponseAnalysisController = (function(superClass) {
    extend(DoseResponseAnalysisController, superClass);

    function DoseResponseAnalysisController() {
      this.fitReturnSuccess = bind(this.fitReturnSuccess, this);
      this.launchFit = bind(this.launchFit, this);
      this.paramsInvalid = bind(this.paramsInvalid, this);
      this.paramsValid = bind(this.paramsValid, this);
      this.handleModelFitTypeChanged = bind(this.handleModelFitTypeChanged, this);
      this.handleModelStatusChanged = bind(this.handleModelStatusChanged, this);
      this.handleStatusChanged = bind(this.handleStatusChanged, this);
      this.setReadyForFit = bind(this.setReadyForFit, this);
      this.testReadyForFit = bind(this.testReadyForFit, this);
      this.render = bind(this.render, this);
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
      this.analyzedPreviously = this.model.getModelFitStatus().get('codeValue') === "not started" ? false : true;
      $(this.el).empty();
      $(this.el).html(this.template());
      return this.testReadyForFit();
    };

    DoseResponseAnalysisController.prototype.render = function() {
      var buttonText;
      this.analyzedPreviously = this.model.getModelFitStatus().get('codeValue') === "not started" ? false : true;
      this.showExistingResults();
      buttonText = this.analyzedPreviously ? "Re-Fit" : "Fit Data";
      return this.$('.bv_fitModelButton').html(buttonText);
    };

    DoseResponseAnalysisController.prototype.showExistingResults = function() {
      var fitStatus, res, resultValue;
      fitStatus = this.model.getModelFitStatus().get('codeValue');
      this.$('.bv_modelFitStatus').html(fitStatus);
      if (this.analyzedPreviously) {
        resultValue = this.model.getModelFitResultHTML();
        if (resultValue !== null) {
          res = resultValue.get('clobValue');
          if (res === "") {
            return this.$('.bv_resultsContainer').hide();
          } else {
            this.$('.bv_modelFitResultsHTML').html(res);
            return this.$('.bv_resultsContainer').show();
          }
        }
      } else {
        return this.$('.bv_resultsContainer').hide();
      }
    };

    DoseResponseAnalysisController.prototype.testReadyForFit = function() {
      if (this.model.getAnalysisStatus().get('codeValue') === "not started") {
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
      this.setupModelFitTypeController();
      this.$('.bv_fitOptionWrapper').show();
      this.$('.bv_analyzeExperimentToFit').hide();
      return this.handleStatusChanged();
    };

    DoseResponseAnalysisController.prototype.primaryAnalysisCompleted = function() {
      return this.testReadyForFit();
    };

    DoseResponseAnalysisController.prototype.handleStatusChanged = function() {
      if (this.parameterController !== null && this.parameterController !== void 0) {
        if (this.model.isEditable()) {
          return this.parameterController.enableAllInputs();
        } else {
          return this.parameterController.disableAllInputs();
        }
      }
    };

    DoseResponseAnalysisController.prototype.handleModelStatusChanged = function() {
      if (this.model.isEditable()) {
        this.$('.bv_fitModelButton').removeAttr('disabled');
        this.$('select').removeAttr('disabled');
        if (this.parameterController != null) {
          return this.parameterController.enableAllInputs();
        }
      } else {
        this.$('.bv_fitModelButton').attr('disabled', 'disabled');
        this.$('select').attr('disabled', 'disabled');
        if (this.parameterController != null) {
          return this.parameterController.disableAllInputs();
        }
      }
    };

    DoseResponseAnalysisController.prototype.setupModelFitTypeController = function() {
      var modelFitType;
      this.modelFitTypeController = new ModelFitTypeController({
        model: this.model,
        el: this.$('.bv_analysisParameterForm')
      });
      this.modelFitTypeController.render();
      this.parameterController = this.modelFitTypeController.parameterController;
      this.modelFitTypeController.modelFitTypeListController.on('change', (function(_this) {
        return function() {
          return _this.handleModelFitTypeChanged();
        };
      })(this));
      modelFitType = this.model.getModelFitType().get('codeValue');
      if (modelFitType === "unassigned") {
        return this.$('.bv_fitModelButton').hide();
      } else {
        return this.$('.bv_fitModelButton').show();
      }
    };

    DoseResponseAnalysisController.prototype.handleModelFitTypeChanged = function() {
      var modelFitType;
      modelFitType = this.modelFitTypeController.modelFitTypeListController.getSelectedCode();
      if (modelFitType === "unassigned") {
        this.$('.bv_fitModelButton').hide();
        if (this.modelFitTypeController.parameterController != null) {
          return this.modelFitTypeController.parameterController.undelegateEvents();
        }
      } else {
        this.$('.bv_fitModelButton').show();
        if (this.modelFitTypeController.parameterController != null) {
          this.modelFitTypeController.parameterController.on('valid', this.paramsValid);
          this.modelFitTypeController.parameterController.on('invalid', this.paramsInvalid);
          if (this.modelFitTypeController.parameterController.isValid() === true) {
            return this.paramsValid();
          } else {
            return this.paramsInvalid();
          }
        }
      }
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
      this.$('.bv_fitStatusDropDown').modal({
        backdrop: "static"
      });
      this.$('.bv_fitStatusDropDown').modal("show");
      fitData = {
        inputParameters: JSON.stringify(this.modelFitTypeController.parameterController.model),
        user: window.AppLaunchParams.loginUserName,
        experimentCode: this.model.get('codeName'),
        modelFitType: this.modelFitTypeController.modelFitTypeListController.getSelectedCode(),
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
            _this.serviceReturn = null;
            return _this.$('.bv_fitStatusDropDown').modal("hide");
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
      this.$('.bv_resultsContainer').show();
      return this.$('.bv_fitStatusDropDown').modal("hide");
    };

    return DoseResponseAnalysisController;

  })(Backbone.View);

}).call(this);
