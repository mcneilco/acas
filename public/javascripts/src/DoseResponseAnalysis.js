(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.DoseResponseAnalysisParameters = (function(_super) {
    __extends(DoseResponseAnalysisParameters, _super);

    function DoseResponseAnalysisParameters() {
      this.fixCompositeClasses = __bind(this.fixCompositeClasses, this);
      return DoseResponseAnalysisParameters.__super__.constructor.apply(this, arguments);
    }

    DoseResponseAnalysisParameters.prototype.defaults = {
      inactiveThreshold: 20,
      inverseAgonistMode: false,
      max: new Backbone.Model(),
      min: new Backbone.Model(),
      slope: new Backbone.Model()
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
      this.get('max').on("change", (function(_this) {
        return function() {
          return _this.trigger('change');
        };
      })(this));
      if (!(this.get('min') instanceof Backbone.Model)) {
        this.set({
          min: new Backbone.Model(this.get('min'))
        });
      }
      this.get('min').on("change", (function(_this) {
        return function() {
          return _this.trigger('change');
        };
      })(this));
      if (!(this.get('slope') instanceof Backbone.Model)) {
        this.set({
          slope: new Backbone.Model(this.get('slope'))
        });
      }
      return this.get('slope').on("change", (function(_this) {
        return function() {
          return _this.trigger('change');
        };
      })(this));
    };

    DoseResponseAnalysisParameters.prototype.validate = function(attrs) {
      var errors, limitType;
      errors = [];
      limitType = attrs.min.get('limitType');
      if ((limitType === "pin" || limitType === "limit") && _.isNaN(attrs.min.get('value'))) {
        errors.push({
          attribute: 'min_value',
          message: "Min threshold value must be set when limit type is pin or limit"
        });
      }
      limitType = attrs.max.get('limitType');
      if ((limitType === "pin" || limitType === "limit") && _.isNaN(attrs.max.get('value'))) {
        errors.push({
          attribute: 'max_value',
          message: "Max threshold value must be set when limit type is pin or limit"
        });
      }
      limitType = attrs.slope.get('limitType');
      if ((limitType === "pin" || limitType === "limit") && _.isNaN(attrs.slope.get('value'))) {
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
      this.updateModel = __bind(this.updateModel, this);
      this.render = __bind(this.render, this);
      return DoseResponseAnalysisParametersController.__super__.constructor.apply(this, arguments);
    }

    DoseResponseAnalysisParametersController.prototype.template = _.template($("#DoseResponseAnalysisParametersView").html());

    DoseResponseAnalysisParametersController.prototype.autofillTemplate = _.template($("#DoseResponseAnalysisParametersAutofillView").html());

    DoseResponseAnalysisParametersController.prototype.events = {
      "change .bv_inverseAgonistMode": "handleInverseAgonistModeChanged",
      "change .bv_max_limitType_none": "handleMaxLimitTypeChanged",
      "change .bv_max_limitType_pin": "handleMaxLimitTypeChanged",
      "change .bv_max_limitType_limit": "handleMaxLimitTypeChanged",
      "change .bv_min_limitType_none": "handleMinLimitTypeChanged",
      "change .bv_min_limitType_pin": "handleMinLimitTypeChanged",
      "change .bv_min_limitType_limit": "handleMinLimitTypeChanged",
      "change .bv_slope_limitType_none": "handleSlopeLimitTypeChanged",
      "change .bv_slope_limitType_pin": "handleSlopeLimitTypeChanged",
      "change .bv_slope_limitType_limit": "handleSlopeLimitTypeChanged",
      "change .bv_max_value": "attributeChanged",
      "change .bv_min_value": "attributeChanged",
      "change .bv_slope_value": "attributeChanged"
    };

    DoseResponseAnalysisParametersController.prototype.render = function() {
      DoseResponseAnalysisParametersController.__super__.render.call(this);
      this.$('.bv_autofillSection').empty();
      return this.$('.bv_autofillSection').html(this.autofillTemplate($.parseJSON(JSON.stringify(this.model))));
    };

    DoseResponseAnalysisParametersController.prototype.updateModel = function() {
      this.model.get('max').set({
        value: parseFloat(this.getTrimmedInput('.bv_max_value'))
      });
      this.model.get('min').set({
        value: parseFloat(this.getTrimmedInput('.bv_min_value'))
      });
      return this.model.get('slope').set({
        value: parseFloat(this.getTrimmedInput('.bv_slope_value'))
      });
    };

    DoseResponseAnalysisParametersController.prototype.handleInverseAgonistModeChanged = function() {
      this.model.set({
        inverseAgonistMode: this.$('.bv_inverseAgonist').is(":checked")
      });
      return this.attributeChanged();
    };

    DoseResponseAnalysisParametersController.prototype.handleMaxLimitTypeChanged = function() {
      this.model.get('max').set({
        limitType: this.$("input[name='bv_max_limitType']:checked").val()
      });
      return this.attributeChanged();
    };

    DoseResponseAnalysisParametersController.prototype.handleMinLimitTypeChanged = function() {
      this.model.get('min').set({
        limitType: this.$("input[name='bv_min_limitType']:checked").val()
      });
      return this.attributeChanged();
    };

    DoseResponseAnalysisParametersController.prototype.handleSlopeLimitTypeChanged = function() {
      this.model.get('slope').set({
        limitType: this.$("input[name='bv_slope_limitType']:checked").val()
      });
      return this.attributeChanged();
    };

    return DoseResponseAnalysisParametersController;

  })(AbstractParserFormController);

}).call(this);
