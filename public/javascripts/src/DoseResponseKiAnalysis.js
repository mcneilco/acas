(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.DoseResponseKiAnalysisParameters = (function(_super) {
    __extends(DoseResponseKiAnalysisParameters, _super);

    function DoseResponseKiAnalysisParameters() {
      this.fixCompositeClasses = __bind(this.fixCompositeClasses, this);
      return DoseResponseKiAnalysisParameters.__super__.constructor.apply(this, arguments);
    }

    DoseResponseKiAnalysisParameters.prototype.defaults = {
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
      kd: new Backbone.Model,
      ligandConc: new Backbone.Model
    };

    DoseResponseKiAnalysisParameters.prototype.initialize = function() {
      return this.fixCompositeClasses();
    };

    DoseResponseKiAnalysisParameters.prototype.fixCompositeClasses = function() {
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
      if (!(this.get('kd') instanceof Backbone.Model)) {
        this.set({
          kd: new Backbone.Model(this.get('kd'))
        });
      }
      if (!(this.get('ligandConc') instanceof Backbone.Model)) {
        return this.set({
          ligandConc: new Backbone.Model(this.get('ligandConc'))
        });
      }
    };

    DoseResponseKiAnalysisParameters.prototype.validate = function(attrs) {
      var errors, limitType;
      console.log("validate Ki analysis");
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
      if (_.isNaN(attrs.kd.get('value')) || attrs.kd.get('value') === null || attrs.kd.get('value') === void 0) {
        errors.push({
          attribute: 'kd_value',
          message: "Kd threshold value must be set"
        });
      }
      if (_.isNaN(attrs.ligandConc.get('value')) || attrs.ligandConc.get('value') === null || attrs.ligandConc.get('value') === void 0) {
        errors.push({
          attribute: 'ligandConc_value',
          message: "Ligand Conc. threshold value must be set"
        });
      }
      if (_.isNaN(attrs.inactiveThreshold)) {
        errors.push({
          attribute: 'inactiveThreshold',
          message: "Inactive threshold value must be set to a number"
        });
      }
      console.log(errors);
      if (errors.length > 0) {
        return errors;
      } else {
        return null;
      }
    };

    return DoseResponseKiAnalysisParameters;

  })(Backbone.Model);

  window.DoseResponseKiAnalysisParametersController = (function(_super) {
    __extends(DoseResponseKiAnalysisParametersController, _super);

    function DoseResponseKiAnalysisParametersController() {
      this.handleMinLimitTypeChanged = __bind(this.handleMinLimitTypeChanged, this);
      this.handleMaxLimitTypeChanged = __bind(this.handleMaxLimitTypeChanged, this);
      this.handleInverseAgonistModeChanged = __bind(this.handleInverseAgonistModeChanged, this);
      this.handleInactiveThresholdMoved = __bind(this.handleInactiveThresholdMoved, this);
      this.handleInactiveThresholdChanged = __bind(this.handleInactiveThresholdChanged, this);
      this.handleInactiveThresholdModeChanged = __bind(this.handleInactiveThresholdModeChanged, this);
      this.handleSmartModeChanged = __bind(this.handleSmartModeChanged, this);
      this.updateModel = __bind(this.updateModel, this);
      this.render = __bind(this.render, this);
      return DoseResponseKiAnalysisParametersController.__super__.constructor.apply(this, arguments);
    }

    DoseResponseKiAnalysisParametersController.prototype.template = _.template($("#DoseResponseKiAnalysisParametersView").html());

    DoseResponseKiAnalysisParametersController.prototype.autofillTemplate = _.template($("#DoseResponseKiAnalysisParametersAutofillView").html());

    DoseResponseKiAnalysisParametersController.prototype.events = {
      "change .bv_smartMode": "handleSmartModeChanged",
      "change .bv_inverseAgonistMode": "handleInverseAgonistModeChanged",
      "change .bv_inactiveThresholdMode": "handleInactiveThresholdModeChanged",
      "click .bv_max_limitType_none": "handleMaxLimitTypeChanged",
      "click .bv_max_limitType_pin": "handleMaxLimitTypeChanged",
      "click .bv_max_limitType_limit": "handleMaxLimitTypeChanged",
      "click .bv_min_limitType_none": "handleMinLimitTypeChanged",
      "click .bv_min_limitType_pin": "handleMinLimitTypeChanged",
      "click .bv_min_limitType_limit": "handleMinLimitTypeChanged",
      "change .bv_max_value": "attributeChanged",
      "change .bv_min_value": "attributeChanged",
      "change .bv_kd_value": "attributeChanged",
      "change .bv_ligandConc_value": "attributeChanged"
    };

    DoseResponseKiAnalysisParametersController.prototype.initialize = function() {
      $(this.el).html(this.template());
      this.errorOwnerName = 'DoseResponseKiAnalysisParametersController';
      return this.setBindings();
    };

    DoseResponseKiAnalysisParametersController.prototype.render = function() {
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

    DoseResponseKiAnalysisParametersController.prototype.updateThresholdDisplay = function(val) {
      return this.$('.bv_inactiveThresholdDisplay').html(val);
    };

    DoseResponseKiAnalysisParametersController.prototype.setThresholdModeEnabledState = function() {
      if (this.model.get('smartMode')) {
        this.$('.bv_inactiveThresholdMode').removeAttr('disabled');
      } else {
        this.$('.bv_inactiveThresholdMode').attr('disabled', 'disabled');
      }
      return this.setThresholdSliderEnabledState();
    };

    DoseResponseKiAnalysisParametersController.prototype.setThresholdSliderEnabledState = function() {
      if (this.model.get('inactiveThresholdMode') && this.model.get('smartMode')) {
        return this.$('.bv_inactiveThreshold').slider('enable');
      } else {
        return this.$('.bv_inactiveThreshold').slider('disable');
      }
    };

    DoseResponseKiAnalysisParametersController.prototype.setInverseAgonistModeEnabledState = function() {
      if (this.model.get('smartMode')) {
        return this.$('.bv_inverseAgonistMode').removeAttr('disabled');
      } else {
        return this.$('.bv_inverseAgonistMode').attr('disabled', 'disabled');
      }
    };

    DoseResponseKiAnalysisParametersController.prototype.updateModel = function() {
      this.model.get('max').set({
        value: parseFloat(UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_max_value')))
      });
      this.model.get('min').set({
        value: parseFloat(UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_min_value')))
      });
      this.model.get('kd').set({
        value: parseFloat(UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_kd_value')))
      });
      this.model.get('ligandConc').set({
        value: parseFloat(UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_ligandConc_value')))
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

    DoseResponseKiAnalysisParametersController.prototype.handleSmartModeChanged = function() {
      return this.attributeChanged();
    };

    DoseResponseKiAnalysisParametersController.prototype.handleInactiveThresholdModeChanged = function() {
      return this.attributeChanged();
    };

    DoseResponseKiAnalysisParametersController.prototype.handleInactiveThresholdChanged = function(event, ui) {
      this.model.set({
        'inactiveThreshold': ui.value
      });
      this.updateThresholdDisplay(this.model.get('inactiveThreshold'));
      return this.attributeChanged;
    };

    DoseResponseKiAnalysisParametersController.prototype.handleInactiveThresholdMoved = function(event, ui) {
      return this.updateThresholdDisplay(ui.value);
    };

    DoseResponseKiAnalysisParametersController.prototype.handleInverseAgonistModeChanged = function() {
      return this.attributeChanged();
    };

    DoseResponseKiAnalysisParametersController.prototype.handleMaxLimitTypeChanged = function() {
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

    DoseResponseKiAnalysisParametersController.prototype.handleMinLimitTypeChanged = function() {
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

    DoseResponseKiAnalysisParametersController.prototype.setFormTitle = function(title) {
      if (title != null) {
        this.formTitle = title;
        return this.$(".bv_formTitle").html(this.formTitle);
      } else if (this.formTitle != null) {
        return this.$(".bv_formTitle").html(this.formTitle);
      } else {
        return this.formTitle = this.$(".bv_formTitle").html();
      }
    };

    return DoseResponseKiAnalysisParametersController;

  })(AbstractFormController);

}).call(this);
