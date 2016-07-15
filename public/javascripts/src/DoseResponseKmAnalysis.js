(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.DoseResponseKmAnalysisParameters = (function(superClass) {
    extend(DoseResponseKmAnalysisParameters, superClass);

    function DoseResponseKmAnalysisParameters() {
      this.handleTheoreticalMaxChanged = bind(this.handleTheoreticalMaxChanged, this);
      this.handleInactiveThresholdChanged = bind(this.handleInactiveThresholdChanged, this);
      this.fixCompositeClasses = bind(this.fixCompositeClasses, this);
      return DoseResponseKmAnalysisParameters.__super__.constructor.apply(this, arguments);
    }

    DoseResponseKmAnalysisParameters.prototype.defaults = {
      smartMode: true,
      inactiveThresholdMode: true,
      inactiveThreshold: 20,
      theoreticalMaxMode: false,
      theoreticalMax: null,
      inverseAgonistMode: false,
      vmax: new Backbone.Model({
        limitType: 'none'
      }),
      et: new Backbone.Model
    };

    DoseResponseKmAnalysisParameters.prototype.initialize = function(options) {
      if (options != null) {
        if (typeof options.inactiveThreshold === "undefined") {
          this.set('inactiveThreshold', null);
        } else {
          this.set('inactiveThreshold', options.inactiveThreshold);
        }
        if (typeof options.theoreticalMax === "undefined") {
          this.set('theoreticalMax', null);
        } else {
          this.set('theoreticalMax', options.theoreticalMax);
        }
      }
      this.fixCompositeClasses();
      this.on('change:inactiveThreshold', this.handleInactiveThresholdChanged);
      return this.on('change:theoreticalMax', this.handleTheoreticalMaxChanged);
    };

    DoseResponseKmAnalysisParameters.prototype.fixCompositeClasses = function() {
      if (!(this.get('vmax') instanceof Backbone.Model)) {
        this.set({
          vmax: new Backbone.Model(this.get('vmax'))
        });
      }
      if (!(this.get('et') instanceof Backbone.Model)) {
        return this.set({
          et: new Backbone.Model(this.get('et'))
        });
      }
    };

    DoseResponseKmAnalysisParameters.prototype.handleInactiveThresholdChanged = function() {
      if (_.isNaN(this.get('inactiveThreshold')) || this.get('inactiveThreshold') === null) {
        return this.set({
          'inactiveThresholdMode': false
        });
      } else {
        return this.set({
          'inactiveThresholdMode': true
        });
      }
    };

    DoseResponseKmAnalysisParameters.prototype.handleTheoreticalMaxChanged = function() {
      if (_.isNaN(this.get('theoreticalMax')) || this.get('theoreticalMax') === null) {
        return this.set({
          'theoreticalMaxMode': false
        });
      } else {
        return this.set({
          'theoreticalMaxMode': true
        });
      }
    };

    DoseResponseKmAnalysisParameters.prototype.validate = function(attrs) {
      var errors, limitType;
      errors = [];
      limitType = attrs.vmax.get('limitType');
      if ((limitType === "pin" || limitType === "limit") && (_.isNaN(attrs.vmax.get('value')) || attrs.vmax.get('value') === null)) {
        errors.push({
          attribute: 'vmax_value',
          message: "VMax threshold value must be set when limit type is pin or limit"
        });
      }
      if (_.isNaN(attrs.et.get('value'))) {
        errors.push({
          attribute: 'et_value',
          message: "Et value must be set as numeric"
        });
      }
      if (attrs.inactiveThresholdMode && _.isNaN(attrs.inactiveThreshold)) {
        errors.push({
          attribute: 'inactiveThreshold',
          message: "Inactive threshold value must be set to a number"
        });
      }
      if (attrs.theoreticalMaxMode && _.isNaN(attrs.theoreticalMax)) {
        errors.push({
          attribute: 'theoreticalMax',
          message: "Theoretical max value must be set to a number"
        });
      }
      if (errors.length > 0) {
        return errors;
      } else {
        return null;
      }
    };

    return DoseResponseKmAnalysisParameters;

  })(Backbone.Model);

  window.DoseResponseKmAnalysisParametersController = (function(superClass) {
    extend(DoseResponseKmAnalysisParametersController, superClass);

    function DoseResponseKmAnalysisParametersController() {
      this.handleMaxLimitTypeChanged = bind(this.handleMaxLimitTypeChanged, this);
      this.handleInverseAgonistModeChanged = bind(this.handleInverseAgonistModeChanged, this);
      this.handleSmartModeChanged = bind(this.handleSmartModeChanged, this);
      this.updateModel = bind(this.updateModel, this);
      this.render = bind(this.render, this);
      return DoseResponseKmAnalysisParametersController.__super__.constructor.apply(this, arguments);
    }

    DoseResponseKmAnalysisParametersController.prototype.template = _.template($("#DoseResponseKmAnalysisParametersView").html());

    DoseResponseKmAnalysisParametersController.prototype.autofillTemplate = _.template($("#DoseResponseKmAnalysisParametersAutofillView").html());

    DoseResponseKmAnalysisParametersController.prototype.events = {
      "change .bv_smartMode": "handleSmartModeChanged",
      "change .bv_inverseAgonistMode": "handleInverseAgonistModeChanged",
      "click .bv_vmax_limitType_none": "handleMaxLimitTypeChanged",
      "click .bv_vmax_limitType_pin": "handleMaxLimitTypeChanged",
      "click .bv_vmax_limitType_limit": "handleMaxLimitTypeChanged",
      "change .bv_vmax_value": "attributeChanged",
      "change .bv_et_value": "attributeChanged",
      "change .bv_inactiveThreshold": "attributeChanged",
      "change .bv_theoreticalMax": "attributeChanged"
    };

    DoseResponseKmAnalysisParametersController.prototype.initialize = function() {
      $(this.el).html(this.template());
      this.errorOwnerName = 'DoseResponseAnalysisParametersController';
      return this.setBindings();
    };

    DoseResponseKmAnalysisParametersController.prototype.render = function() {
      this.$('.bv_autofillSection').empty();
      this.$('.bv_autofillSection').html(this.autofillTemplate($.parseJSON(JSON.stringify(this.model))));
      this.setFormTitle();
      this.setInverseAgonistModeEnabledState();
      return this;
    };

    DoseResponseKmAnalysisParametersController.prototype.setInverseAgonistModeEnabledState = function() {
      if (this.model.get('smartMode')) {
        return this.$('.bv_inverseAgonistMode').removeAttr('disabled');
      } else {
        return this.$('.bv_inverseAgonistMode').attr('disabled', 'disabled');
      }
    };

    DoseResponseKmAnalysisParametersController.prototype.updateModel = function() {
      var et;
      this.model.get('vmax').set({
        value: parseFloat(UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_vmax_value')))
      });
      if (UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_et_value')) === "") {
        et = null;
      } else {
        et = parseFloat(UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_et_value')));
      }
      this.model.get('et').set({
        value: et
      });
      this.model.set({
        inverseAgonistMode: this.$('.bv_inverseAgonistMode').is(":checked"),
        smartMode: this.$('.bv_smartMode').is(":checked"),
        inactiveThreshold: parseFloat(UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_inactiveThreshold'))),
        theoreticalMax: parseFloat(UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_theoreticalMax'))),
        silent: true
      });
      this.setInverseAgonistModeEnabledState();
      this.model.trigger('change');
      return this.trigger('updateState');
    };

    DoseResponseKmAnalysisParametersController.prototype.handleSmartModeChanged = function() {
      if (this.$('.bv_smartMode').is(":checked")) {
        this.$('.bv_inactiveThreshold').removeAttr('disabled');
        this.$('.bv_theoreticalMax').removeAttr('disabled');
      } else {
        this.$('.bv_inactiveThreshold').attr('disabled', 'disabled');
        this.$('.bv_inactiveThreshold').val("");
        this.$('.bv_theoreticalMax').attr('disabled', 'disabled');
        this.$('.bv_theoreticalMax').val("");
      }
      return this.attributeChanged();
    };

    DoseResponseKmAnalysisParametersController.prototype.handleInverseAgonistModeChanged = function() {
      return this.attributeChanged();
    };

    DoseResponseKmAnalysisParametersController.prototype.handleMaxLimitTypeChanged = function() {
      var radioValue;
      radioValue = this.$("input[name='bv_vmax_limitType']:checked").val();
      this.model.get('vmax').set({
        limitType: radioValue,
        silent: true
      });
      if (radioValue === 'none') {
        this.$('.bv_vmax_value').attr('disabled', 'disabled');
      } else {
        this.$('.bv_vmax_value').removeAttr('disabled');
      }
      return this.attributeChanged();
    };

    DoseResponseKmAnalysisParametersController.prototype.setFormTitle = function(title) {
      if (title != null) {
        this.formTitle = title;
        return this.$(".bv_formTitle").html(this.formTitle);
      } else if (this.formTitle != null) {
        return this.$(".bv_formTitle").html(this.formTitle);
      } else {
        return this.formTitle = this.$(".bv_formTitle").html();
      }
    };

    return DoseResponseKmAnalysisParametersController;

  })(AbstractFormController);

  window.DoseResponsePlotCurveKm = (function(superClass) {
    extend(DoseResponsePlotCurveKm, superClass);

    function DoseResponsePlotCurveKm() {
      this.render = bind(this.render, this);
      return DoseResponsePlotCurveKm.__super__.constructor.apply(this, arguments);
    }

    DoseResponsePlotCurveKm.prototype.log10 = function(val) {
      return Math.log(val) / Math.LN10;
    };

    DoseResponsePlotCurveKm.prototype.render = function(brd, curve, plotWindow) {
      var fct, log10;
      log10 = this.log10;
      fct = function(x) {
        return (x / (x + curve.km)) * curve.vmax;
      };
      return brd.create('functiongraph', [fct, plotWindow[0], plotWindow[2]], {
        strokeWidth: 2
      });
    };

    return DoseResponsePlotCurveKm;

  })(Backbone.Model);

}).call(this);
