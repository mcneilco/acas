(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.AnalysisGroup = (function(_super) {
    __extends(AnalysisGroup, _super);

    function AnalysisGroup() {
      this.parse = __bind(this.parse, this);
      return AnalysisGroup.__super__.constructor.apply(this, arguments);
    }

    AnalysisGroup.prototype.defaults = {
      kind: "",
      recordedBy: "",
      recordedDate: null,
      lsLabels: [],
      lsStates: []
    };

    AnalysisGroup.prototype.initialize = function() {
      return this.set(this.parse(this.attributes));
    };

    AnalysisGroup.prototype.parse = function(resp) {
      if (resp.lsLabels != null) {
        if (!(resp.lsLabels instanceof LabelList)) {
          resp.lsLabels = new LabelList(resp.lsLabels);
          resp.lsLabels.on('change', (function(_this) {
            return function() {
              return _this.trigger('change');
            };
          })(this));
        }
      }
      if (resp.lsStates != null) {
        if (!(resp.lsStates instanceof StateList)) {
          resp.lsStates = new StateList(resp.lsStates);
          resp.lsStates.on('change', (function(_this) {
            return function() {
              return _this.trigger('change');
            };
          })(this));
        }
      }
      return resp;
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
