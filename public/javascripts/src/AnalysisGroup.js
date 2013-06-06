(function() {
  var _ref, _ref1, _ref2, _ref3, _ref4, _ref5,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.AnalysisGroupValue = (function(_super) {
    __extends(AnalysisGroupValue, _super);

    function AnalysisGroupValue() {
      _ref = AnalysisGroupValue.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    return AnalysisGroupValue;

  })(Backbone.Model);

  window.AnalysisGroupValueList = (function(_super) {
    __extends(AnalysisGroupValueList, _super);

    function AnalysisGroupValueList() {
      _ref1 = AnalysisGroupValueList.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    AnalysisGroupValueList.prototype.model = AnalysisGroupValue;

    return AnalysisGroupValueList;

  })(Backbone.Collection);

  window.AnalysisGroupState = (function(_super) {
    __extends(AnalysisGroupState, _super);

    function AnalysisGroupState() {
      _ref2 = AnalysisGroupState.__super__.constructor.apply(this, arguments);
      return _ref2;
    }

    AnalysisGroupState.prototype.defaults = {
      analysisGroupValues: new AnalysisGroupValueList()
    };

    AnalysisGroupState.prototype.initialize = function() {
      if (this.has('analysisGroupValues')) {
        if (!(this.get('analysisGroupValues') instanceof AnalysisGroupValueList)) {
          return this.set({
            analysisGroupValues: new AnalysisGroupValueList(this.get('analysisGroupValues'))
          });
        }
      }
    };

    AnalysisGroupState.prototype.getValuesByTypeAndKind = function(type, kind) {
      return this.get('analysisGroupValues').filter(function(value) {
        return (!value.get('ignored')) && (value.get('valueType') === type) && (value.get('valueKind') === kind);
      });
    };

    return AnalysisGroupState;

  })(Backbone.Model);

  window.AnalysisGroupStateList = (function(_super) {
    __extends(AnalysisGroupStateList, _super);

    function AnalysisGroupStateList() {
      _ref3 = AnalysisGroupStateList.__super__.constructor.apply(this, arguments);
      return _ref3;
    }

    AnalysisGroupStateList.prototype.model = AnalysisGroupState;

    return AnalysisGroupStateList;

  })(Backbone.Collection);

  window.AnalysisGroup = (function(_super) {
    __extends(AnalysisGroup, _super);

    function AnalysisGroup() {
      this.fixCompositeClasses = __bind(this.fixCompositeClasses, this);      _ref4 = AnalysisGroup.__super__.constructor.apply(this, arguments);
      return _ref4;
    }

    AnalysisGroup.prototype.defaults = {
      kind: "",
      recordedBy: "",
      recordedDate: null,
      analysisGroupLabels: new LabelList(),
      analysisGroupStates: new AnalysisGroupStateList()
    };

    AnalysisGroup.prototype.initialize = function() {
      return this.fixCompositeClasses();
    };

    AnalysisGroup.prototype.fixCompositeClasses = function() {
      if (this.has('analysisGroupLabels')) {
        if (!(this.get('analysisGroupLabels') instanceof LabelList)) {
          this.set({
            analysisGroupLabels: new LabelList(this.get('analysisGroupLabels'))
          });
        }
      }
      if (this.has('analysisGroupStates')) {
        if (!(this.get('analysisGroupStates') instanceof AnalysisGroupStateList)) {
          return this.set({
            analysisGroupStates: new AnalysisGroupStateList(this.get('analysisGroupStates'))
          });
        }
      }
    };

    return AnalysisGroup;

  })(Backbone.Model);

  window.AnalysisGroupList = (function(_super) {
    __extends(AnalysisGroupList, _super);

    function AnalysisGroupList() {
      _ref5 = AnalysisGroupList.__super__.constructor.apply(this, arguments);
      return _ref5;
    }

    AnalysisGroupList.prototype.model = AnalysisGroup;

    return AnalysisGroupList;

  })(Backbone.Collection);

}).call(this);
