(function() {
  var _ref, _ref1, _ref2, _ref3, _ref4, _ref5,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.Label = (function(_super) {
    __extends(Label, _super);

    function Label() {
      _ref = Label.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Label.prototype.defaults = {
      lsType: "name",
      lsKind: '',
      labelText: '',
      ignored: false,
      preferred: false,
      recordedDate: "",
      recordedBy: "",
      physicallyLabled: false,
      imageFile: null
    };

    return Label;

  })(Backbone.Model);

  window.LabelList = (function(_super) {
    __extends(LabelList, _super);

    function LabelList() {
      _ref1 = LabelList.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    LabelList.prototype.model = Label;

    LabelList.prototype.getCurrent = function() {
      return this.filter(function(lab) {
        return !(lab.get('ignored'));
      });
    };

    LabelList.prototype.getNames = function() {
      return _.filter(this.getCurrent(), function(lab) {
        return lab.get('lsType') === "name";
      });
    };

    LabelList.prototype.getPreferred = function() {
      return _.filter(this.getCurrent(), function(lab) {
        return lab.get('preferred');
      });
    };

    LabelList.prototype.pickBestLabel = function() {
      var bestLabel, current, names, preferred;
      preferred = this.getPreferred();
      if (preferred.length > 0) {
        bestLabel = _.max(preferred, function(lab) {
          var rd;
          rd = lab.get('recordedDate');
          if (rd === "") {
            return rd;
          } else {
            return -1;
          }
        });
      } else {
        names = this.getNames();
        if (names.length > 0) {
          bestLabel = _.max(names, function(lab) {
            var rd;
            rd = lab.get('recordedDate');
            if (rd === "") {
              return rd;
            } else {
              return -1;
            }
          });
        } else {
          current = this.getCurrent();
          bestLabel = _.max(current, function(lab) {
            var rd;
            rd = lab.get('recordedDate');
            if (rd === "") {
              return rd;
            } else {
              return -1;
            }
          });
        }
      }
      return bestLabel;
    };

    LabelList.prototype.pickBestName = function() {
      var bestLabel, preferredNames;
      preferredNames = _.filter(this.getCurrent(), function(lab) {
        return lab.get('preferred') && (lab.get('lsType') === "name");
      });
      bestLabel = _.max(preferredNames, function(lab) {
        var rd;
        rd = lab.get('recordedDate');
        if (rd === "") {
          return rd;
        } else {
          return -1;
        }
      });
      return bestLabel;
    };

    LabelList.prototype.setBestName = function(label) {
      var currentName;
      label.set({
        lsType: 'name',
        preferred: true,
        ignored: false
      });
      currentName = this.pickBestName();
      if (currentName != null) {
        if (currentName.isNew()) {
          return currentName.set({
            labelText: label.get('labelText'),
            recordedBy: label.get('recordedBy'),
            recordedDate: label.get('recordedDate')
          });
        } else {
          currentName.set({
            ignored: true
          });
          return this.add(label);
        }
      } else {
        return this.add(label);
      }
    };

    return LabelList;

  })(Backbone.Collection);

  window.Value = (function(_super) {
    __extends(Value, _super);

    function Value() {
      _ref2 = Value.__super__.constructor.apply(this, arguments);
      return _ref2;
    }

    return Value;

  })(Backbone.Model);

  window.ValueList = (function(_super) {
    __extends(ValueList, _super);

    function ValueList() {
      _ref3 = ValueList.__super__.constructor.apply(this, arguments);
      return _ref3;
    }

    ValueList.prototype.model = Value;

    return ValueList;

  })(Backbone.Collection);

  window.State = (function(_super) {
    __extends(State, _super);

    function State() {
      _ref4 = State.__super__.constructor.apply(this, arguments);
      return _ref4;
    }

    State.prototype.defaults = {
      lsValues: new ValueList()
    };

    State.prototype.initialize = function() {
      var _this = this;
      if (this.has('lsValues')) {
        if (!(this.get('lsValues') instanceof ValueList)) {
          this.set({
            lsValues: new ValueList(this.get('lsValues'))
          });
        }
      }
      return this.get('lsValues').on('change', function() {
        return _this.trigger('change');
      });
    };

    State.prototype.parse = function(resp) {
      var _this = this;
      if (resp.lsValues != null) {
        if (!(resp.lsValues instanceof ValueList)) {
          resp.lsValues = new ValueList(resp.lsValues);
          resp.lsValues.on('change', function() {
            return _this.trigger('change');
          });
        }
      }
      return resp;
    };

    State.prototype.getValuesByTypeAndKind = function(type, kind) {
      return this.get('lsValues').filter(function(value) {
        return (!value.get('ignored')) && (value.get('lsType') === type) && (value.get('lsKind') === kind);
      });
    };

    return State;

  })(Backbone.Model);

  window.StateList = (function(_super) {
    __extends(StateList, _super);

    function StateList() {
      _ref5 = StateList.__super__.constructor.apply(this, arguments);
      return _ref5;
    }

    StateList.prototype.model = State;

    StateList.prototype.getStatesByTypeAndKind = function(type, kind) {
      return this.filter(function(state) {
        return (!state.get('ignored')) && (state.get('lsType') === type) && (state.get('lsKind') === kind);
      });
    };

    StateList.prototype.getStateValueByTypeAndKind = function(stype, skind, vtype, vkind) {
      var states, value, values;
      value = null;
      states = this.getStatesByTypeAndKind(stype, skind);
      if (states.length > 0) {
        values = states[0].getValuesByTypeAndKind(vtype, vkind);
        if (values.length > 0) {
          value = values[0];
        }
      }
      return value;
    };

    StateList.prototype.getOrCreateStateByTypeAndKind = function(sType, sKind) {
      var mState, mStates;
      mStates = this.getStatesByTypeAndKind(sType, sKind);
      mState = mStates[0];
      if (mState == null) {
        mState = new State({
          lsType: sType,
          lsKind: sKind
        });
        this.add(mState);
      }
      return mState;
    };

    StateList.prototype.getOrCreateValueByTypeAndKind = function(sType, sKind, vType, vKind) {
      var descVal, descVals, metaState;
      metaState = this.getOrCreateStateByTypeAndKind(sType, sKind);
      descVals = metaState.getValuesByTypeAndKind(vType, vKind);
      descVal = descVals[0];
      if (descVal == null) {
        descVal = new Value({
          lsType: vType,
          lsKind: vKind
        });
        metaState.get('lsValues').add(descVal);
      }
      return descVal;
    };

    return StateList;

  })(Backbone.Collection);

}).call(this);
