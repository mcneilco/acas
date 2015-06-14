(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.AnalysisGroup = (function(_super) {
    __extends(AnalysisGroup, _super);

    function AnalysisGroup() {
      this.fixCompositeClasses = __bind(this.fixCompositeClasses, this);
      return AnalysisGroup.__super__.constructor.apply(this, arguments);
    }

    AnalysisGroup.prototype.defaults = {
      kind: "",
      recordedBy: "",
      recordedDate: null,
      lsLabels: new LabelList(),
      lsStates: new StateList()
    };

    AnalysisGroup.prototype.initialize = function() {
      return this.fixCompositeClasses();
    };

    AnalysisGroup.prototype.fixCompositeClasses = function() {
      if (this.has('lsLabels')) {
        if (!(this.get('lsLabels') instanceof LabelList)) {
          this.set({
            lsLabels: new LabelList(this.get('lsLabels'))
          });
        }
      }
      if (this.has('lsStates')) {
        if (!(this.get('lsStates') instanceof StateList)) {
          return this.set({
            lsStates: new StateList(this.get('lsStates'))
          });
        }
      }
    };

    return AnalysisGroup;

  })(Backbone.Model);

  window.AnalysisGroupList = (function(_super) {
    __extends(AnalysisGroupList, _super);

    function AnalysisGroupList() {
      return AnalysisGroupList.__super__.constructor.apply(this, arguments);
    }

    AnalysisGroupList.prototype.model = AnalysisGroup;

    return AnalysisGroupList;

  })(Backbone.Collection);

}).call(this);
