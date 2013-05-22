(function() {
  var _ref,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.DoseResponseAnalysisController = (function(_super) {
    __extends(DoseResponseAnalysisController, _super);

    function DoseResponseAnalysisController() {
      this.render = __bind(this.render, this);      _ref = DoseResponseAnalysisController.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    DoseResponseAnalysisController.prototype.template = _.template($("#DoseResponseAnalysisView").html());

    DoseResponseAnalysisController.prototype.render = function() {
      $(this.el).empty();
      return $(this.el).html(this.template());
    };

    return DoseResponseAnalysisController;

  })(AbstractFormController);

}).call(this);
