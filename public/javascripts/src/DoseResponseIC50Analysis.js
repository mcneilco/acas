(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.DoseResponsePlotCurveLL4IC50 = (function(superClass) {
    extend(DoseResponsePlotCurveLL4IC50, superClass);

    function DoseResponsePlotCurveLL4IC50() {
      this.render = bind(this.render, this);
      return DoseResponsePlotCurveLL4IC50.__super__.constructor.apply(this, arguments);
    }

    DoseResponsePlotCurveLL4IC50.prototype.log10 = function(val) {
      return Math.log(val) / Math.LN10;
    };

    DoseResponsePlotCurveLL4IC50.prototype.render = function(brd, curve, plotWindow) {
      var color, fct, intersect, log10;
      log10 = this.log10;
      fct = function(x) {
        return curve.min + (curve.max - curve.min) / (1 + Math.exp(curve.slope * Math.log(Math.pow(10, x) / curve.ic50)));
      };
      brd.create('functiongraph', [fct, plotWindow[0], plotWindow[2]], {
        strokeWidth: 2
      });
      if (curve.curveAttributes.IC50 != null) {
        intersect = fct(log10(curve.curveAttributes.IC50));
        if (curve.curveAttributes.Operator != null) {
          color = '#ff0000';
        } else {
          color = '#808080';
        }
        brd.create('line', [[plotWindow[0], intersect], [log10(curve.curveAttributes.IC50), intersect]], {
          fixed: true,
          straightFirst: false,
          straightLast: false,
          strokeWidth: 2,
          dash: 3,
          strokeColor: color
        });
        return brd.create('line', [[log10(curve.curveAttributes.IC50), intersect], [log10(curve.curveAttributes.IC50), 0]], {
          fixed: true,
          straightFirst: false,
          straightLast: false,
          strokeWidth: 2,
          dash: 3,
          strokeColor: color
        });
      }
    };

    return DoseResponsePlotCurveLL4IC50;

  })(Backbone.Model);

  window.DoseResponseIC50AnalysisParameters = (function(superClass) {
    extend(DoseResponseIC50AnalysisParameters, superClass);

    function DoseResponseIC50AnalysisParameters() {
      return DoseResponseIC50AnalysisParameters.__super__.constructor.apply(this, arguments);
    }

    DoseResponseIC50AnalysisParameters.prototype.defaults = _.extend({}, DoseResponseAnalysisParameters.prototype.defaults, {
      inactiveThresholdMode: false,
      inactiveThreshold: null,
      inverseAgonistMode: true
    });

    return DoseResponseIC50AnalysisParameters;

  })(DoseResponseAnalysisParameters);

}).call(this);
