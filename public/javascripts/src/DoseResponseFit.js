(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.DoseResponseDataParserController = (function(superClass) {
    extend(DoseResponseDataParserController, superClass);

    function DoseResponseDataParserController() {
      this.handleSaveReturnSuccess = bind(this.handleSaveReturnSuccess, this);
      return DoseResponseDataParserController.__super__.constructor.apply(this, arguments);
    }

    DoseResponseDataParserController.prototype.initialize = function() {
      this.loadReportFile = true;
      this.fileProcessorURL = "/api/genericDataParser";
      this.errorOwnerName = 'DoseResponseDataParserController';
      this.additionalData = {
        requireDoseResponse: true
      };
      DoseResponseDataParserController.__super__.initialize.call(this);
      return this.$('.bv_moduleTitle').html('Load Efficacy Data for Dose Response Fit');
    };

    DoseResponseDataParserController.prototype.handleSaveReturnSuccess = function(json) {
      DoseResponseDataParserController.__super__.handleSaveReturnSuccess.call(this, json);
      this.trigger('dataUploadComplete');
      return this.$('.bv_completeControlContainer').hide();
    };

    return DoseResponseDataParserController;

  })(BasicFileValidateAndSaveController);

  window.DoseResponseFitController = (function(superClass) {
    extend(DoseResponseFitController, superClass);

    function DoseResponseFitController() {
      this.fitReturnSuccess = bind(this.fitReturnSuccess, this);
      this.launchFit = bind(this.launchFit, this);
      this.paramsInvalid = bind(this.paramsInvalid, this);
      this.paramsValid = bind(this.paramsValid, this);
      this.setupParameterController = bind(this.setupParameterController, this);
      this.render = bind(this.render, this);
      return DoseResponseFitController.__super__.constructor.apply(this, arguments);
    }

    DoseResponseFitController.prototype.template = _.template($("#DoseResponseFitView").html());

    DoseResponseFitController.prototype.events = {
      "click .bv_fitModelButton": "launchFit",
      "change .bv_modelFitType": "handleModelFitTypeChanged"
    };

    DoseResponseFitController.prototype.initialize = function() {
      if (this.options.experimentCode == null) {
        return alert("DoseResponseFitController must be initialized with an experimentCode");
      }
    };

    DoseResponseFitController.prototype.render = function() {
      this.parameterController = null;
      $(this.el).empty();
      $(this.el).html(this.template());
      return this.setupModelFitTypeSelect();
    };

    DoseResponseFitController.prototype.setupModelFitTypeSelect = function() {
      this.modelFitTypeList = new PickListList();
      this.modelFitTypeList.url = "/api/codetables/model fit/type";
      return this.modelFitTypeListController = new PickListSelectController({
        el: this.$('.bv_modelFitType'),
        collection: this.modelFitTypeList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select Model Fit Type"
        }),
        selectedCode: "unassigned"
      });
    };

    DoseResponseFitController.prototype.setupParameterController = function(modelFitType) {
      var controllerClass, curveFitClasses, curvefitClassesCollection, drap, drapType, drapcType, parametersClass;
      curvefitClassesCollection = new Backbone.Collection($.parseJSON(window.conf.curvefit.modelfitparameter.classes));
      curveFitClasses = curvefitClassesCollection.findWhere({
        code: modelFitType
      });
      if (curveFitClasses != null) {
        parametersClass = curveFitClasses.get('parametersClass');
        drapType = window[parametersClass];
        controllerClass = curveFitClasses.get('parametersController');
        drapcType = window[controllerClass];
      } else {
        drapType = 'unassigned';
      }
      if (drapType === "unassigned") {
        this.$('.bv_analysisParameterForm').empty();
        return this.$('.bv_fitModelButton').hide();
      } else {
        this.$('.bv_fitModelButton').show();
        if ((this.options != null) && (this.options.initialAnalysisParameters != null)) {
          drap = new drapType(this.options.initialAnalysisParameters);
        } else {
          drap = new drapType();
        }
        this.parameterController = new drapcType({
          el: this.$('.bv_analysisParameterForm'),
          model: drap
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
      }
    };

    DoseResponseFitController.prototype.handleModelFitTypeChanged = function() {
      var modelFitType;
      modelFitType = this.$('.bv_modelFitType').val();
      this.setupParameterController(modelFitType);
      if (this.parameterController != null) {
        if (this.parameterController.isValid() === true) {
          return this.paramsValid();
        } else {
          return this.paramsInvalid();
        }
      }
    };

    DoseResponseFitController.prototype.paramsValid = function() {
      return this.$('.bv_fitModelButton').removeAttr('disabled');
    };

    DoseResponseFitController.prototype.paramsInvalid = function() {
      return this.$('.bv_fitModelButton').attr('disabled', 'disabled');
    };

    DoseResponseFitController.prototype.launchFit = function() {
      var fitData;
      this.$('.bv_fitStatusDropDown').modal({
        backdrop: "static"
      });
      this.$('.bv_fitStatusDropDown').modal("show");
      fitData = {
        inputParameters: JSON.stringify(this.parameterController.model),
        user: window.AppLaunchParams.loginUserName,
        experimentCode: this.options.experimentCode,
        modelFitType: this.modelFitTypeListController.getSelectedCode(),
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

    DoseResponseFitController.prototype.fitReturnSuccess = function(json) {
      this.$('.bv_modelFitResultsHTML').html(json.results.htmlSummary);
      this.$('.bv_resultsContainer').show();
      this.$('.bv_fitModelButton').hide();
      this.$('.bv_fitOptionWrapper').hide();
      this.$('.bv_fitStatusDropDown').modal("hide");
      this.trigger('fitComplete');
      return this.trigger('amClean');
    };

    return DoseResponseFitController;

  })(Backbone.View);

  window.DoseResponseFitWorkflowController = (function(superClass) {
    extend(DoseResponseFitWorkflowController, superClass);

    function DoseResponseFitWorkflowController() {
      this.handleFitAnother = bind(this.handleFitAnother, this);
      this.handleFitComplete = bind(this.handleFitComplete, this);
      this.handleDataUploadComplete = bind(this.handleDataUploadComplete, this);
      this.initializeCurveFitController = bind(this.initializeCurveFitController, this);
      this.render = bind(this.render, this);
      return DoseResponseFitWorkflowController.__super__.constructor.apply(this, arguments);
    }

    DoseResponseFitWorkflowController.prototype.template = _.template($("#DoseResponseFitWorkflowView").html());

    DoseResponseFitWorkflowController.prototype.events = {
      "click .bv_loadAnother": "handleFitAnother"
    };

    DoseResponseFitWorkflowController.prototype.render = function() {
      this.$el.empty();
      this.$el.html(this.template());
      this.intializeParserController();
      return this;
    };

    DoseResponseFitWorkflowController.prototype.intializeParserController = function() {
      this.$('.bv_dataParser').empty();
      this.drdpc = new DoseResponseDataParserController({
        el: this.$('.bv_dataParser')
      });
      this.drdpc.on('dataUploadComplete', this.handleDataUploadComplete);
      this.drdpc.on('amDirty', (function(_this) {
        return function() {
          return _this.trigger('amDirty');
        };
      })(this));
      this.drdpc.on('amClean', (function(_this) {
        return function() {
          return _this.trigger('amClean');
        };
      })(this));
      return this.drdpc.render();
    };

    DoseResponseFitWorkflowController.prototype.initializeCurveFitController = function() {
      this.$('.bv_doseResponseAnalysis').empty();
      if (this.modelFitController != null) {
        this.modelFitController.undelegateEvents();
      }
      this.modelFitController = new DoseResponseFitController({
        experimentCode: this.drdpc.getNewExperimentCode(),
        el: this.$('.bv_doseResponseAnalysis')
      });
      this.modelFitController.on('amDirty', (function(_this) {
        return function() {
          return _this.trigger('amDirty');
        };
      })(this));
      this.modelFitController.on('amClean', (function(_this) {
        return function() {
          return _this.trigger('amClean');
        };
      })(this));
      this.modelFitController.render();
      return this.modelFitController.on('fitComplete', this.handleFitComplete);
    };

    DoseResponseFitWorkflowController.prototype.handleDataUploadComplete = function() {
      this.$('.bv_modelFitTabLink').click();
      this.initializeCurveFitController();
      return this.trigger('amDirty');
    };

    DoseResponseFitWorkflowController.prototype.handleFitComplete = function() {
      this.$('.bv_completeControlContainer').show();
      return this.drdpc.$('.bv_loadAnother').hide();
    };

    DoseResponseFitWorkflowController.prototype.handleFitAnother = function() {
      this.drdpc.loadAnother();
      this.$('.bv_doseResponseAnalysis').empty();
      this.$('.bv_doseResponseAnalysis').append("<div class='bv_uploadDataToFit span10'>Data must be uploaded first before fitting.</div>");
      this.$('.bv_completeControlContainer').hide();
      return this.$('.bv_uploadDataTabLink').click();
    };

    return DoseResponseFitWorkflowController;

  })(Backbone.View);

}).call(this);
