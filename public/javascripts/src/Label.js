(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.Label = (function(_super) {
    __extends(Label, _super);

    function Label() {
      return Label.__super__.constructor.apply(this, arguments);
    }

    Label.prototype.defaults = {
      lsType: "name",
      lsKind: '',
      labelText: '',
      ignored: false,
      preferred: false,
      recordedDate: null,
      recordedBy: "",
      physicallyLabled: false,
      imageFile: null
    };

    Label.prototype.changeLabelText = function(options) {
      console.log("change label text");
      console.log(options);
      console.log(this);
      this.set({
        labelText: options
      });
      return console.log(this);
    };

    return Label;

  })(Backbone.Model);

  window.LabelList = (function(_super) {
    __extends(LabelList, _super);

    function LabelList() {
      return LabelList.__super__.constructor.apply(this, arguments);
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
            lsKind: label.get('lsKind'),
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

    LabelList.prototype.getLabelByTypeAndKind = function(type, kind) {
      return this.filter(function(label) {
        return (!label.get('ignored')) && (label.get('lsType') === type) && (label.get('lsKind') === kind);
      });
    };

    LabelList.prototype.getOrCreateLabelByTypeAndKind = function(type, kind) {
      var label, labels;
      labels = this.getLabelByTypeAndKind(type, kind);
      label = labels[0];
      if (label == null) {
        label = new Label({
          lsType: type,
          lsKind: kind
        });
        this.add(label);
        label.on('change', (function(_this) {
          return function() {
            return _this.trigger('change');
          };
        })(this));
      }
      return label;
    };

    return LabelList;

  })(Backbone.Collection);

  window.Value = (function(_super) {
    __extends(Value, _super);

    function Value() {
      return Value.__super__.constructor.apply(this, arguments);
    }

    Value.prototype.defaults = {
      ignored: false,
      recordedDate: null,
      recordedBy: ""
    };

    Value.prototype.initialize = function() {
      return this.on({
        "change:value": this.setValueType
      });
    };

    Value.prototype.setValueType = function() {
      console.log("value changed, setting value type");
      return this.set(this.get('lsType'), this.get('value'));
    };

    return Value;

  })(Backbone.Model);

  window.ValueList = (function(_super) {
    __extends(ValueList, _super);

    function ValueList() {
      return ValueList.__super__.constructor.apply(this, arguments);
    }

    ValueList.prototype.model = Value;

    return ValueList;

  })(Backbone.Collection);

  window.State = (function(_super) {
    __extends(State, _super);

    function State() {
      return State.__super__.constructor.apply(this, arguments);
    }

    State.prototype.defaults = function() {
      return {
        lsValues: new ValueList(),
        ignored: false,
        recordedDate: null,
        recordedBy: ""
      };
    };

    State.prototype.initialize = function() {
      return this.set(this.parse(this.attributes));
    };

    State.prototype.parse = function(resp) {
      if (resp.lsValues != null) {
        if (!(resp.lsValues instanceof ValueList)) {
          resp.lsValues = new ValueList(resp.lsValues);
        }
        resp.lsValues.on('change', (function(_this) {
          return function() {
            return _this.trigger('change');
          };
        })(this));
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
      return StateList.__super__.constructor.apply(this, arguments);
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
        mState.on('change', (function(_this) {
          return function() {
            return _this.trigger('change');
          };
        })(this));
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
        descVal.on('change', (function(_this) {
          return function() {
            return _this.trigger('change');
          };
        })(this));
      }
      return descVal;
    };

    return StateList;

  })(Backbone.Collection);

}).call(this);
