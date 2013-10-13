(function() {
  var _ref,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.DoseResponseAnalysisController = (function(_super) {
    __extends(DoseResponseAnalysisController, _super);

    function DoseResponseAnalysisController() {
      this.handleCurveMaxChanged = __bind(this.handleCurveMaxChanged, this);
      this.handleCurveMinChanged = __bind(this.handleCurveMinChanged, this);
      this.render = __bind(this.render, this);      _ref = DoseResponseAnalysisController.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    DoseResponseAnalysisController.prototype.template = _.template($("#DoseResponseAnalysisView").html());

    DoseResponseAnalysisController.prototype.events = {
      "change .bv_curveMin": "handleCurveMinChanged"
    };

    DoseResponseAnalysisController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      console.log(this.getCurveMin());
      this.$('.bv_curveMin').val(this.getCurveMin());
      this.$('.bv_curveMax').val(this.getCurveMax());
      return this;
    };

    DoseResponseAnalysisController.prototype.getCurveMin = function() {
      var value;

      value = this.model.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "experiment analysis parameters", "numericValue", "curve min");
      return value.get('numericValue');
    };

    DoseResponseAnalysisController.prototype.getCurveMax = function() {
      var value;

      value = this.model.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "experiment analysis parameters", "numericValue", "curve max");
      return value.get('numericValue');
    };

    DoseResponseAnalysisController.prototype.handleCurveMinChanged = function() {
      var value;

      value = this.model.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "experiment analysis parameters", "numericValue", "curve min");
      return value.set({
        numericValue: parseFloat($.trim(this.$('.bv_curveMin').val()))
      });
    };

    DoseResponseAnalysisController.prototype.handleCurveMaxChanged = function() {
      var value;

      value = this.model.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "experiment analysis parameters", "numericValue", "curve max");
      return value.set({
        numericValue: parseFloat($.trim(this.$('.bv_curveMax').val()))
      });
    };

    return DoseResponseAnalysisController;

  })(AbstractFormController);

}).call(this);
