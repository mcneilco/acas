(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.Thing = (function(_super) {
    __extends(Thing, _super);

    function Thing() {
      this.getStateValueHistory = __bind(this.getStateValueHistory, this);
      this.duplicate = __bind(this.duplicate, this);
      this.deleteInteractions = __bind(this.deleteInteractions, this);
      this.reformatBeforeSaving = __bind(this.reformatBeforeSaving, this);
      this.getAnalyticalFiles = __bind(this.getAnalyticalFiles, this);
      this.createDefaultSecondLsThingItx = __bind(this.createDefaultSecondLsThingItx, this);
      this.createDefaultFirstLsThingItx = __bind(this.createDefaultFirstLsThingItx, this);
      this.createNewValue = __bind(this.createNewValue, this);
      this.createDefaultStates = __bind(this.createDefaultStates, this);
      this.createDefaultLabels = __bind(this.createDefaultLabels, this);
      this.parse = __bind(this.parse, this);
      this.defaults = __bind(this.defaults, this);
      return Thing.__super__.constructor.apply(this, arguments);
    }

    Thing.prototype.lsProperties = {};

    Thing.prototype.className = "Thing";

    Thing.prototype.defaults = function() {
      this.set({
        lsType: "thing"
      });
      this.set({
        lsKind: "thing"
      });
      this.set({
        corpName: ""
      });
      this.set({
        recordedBy: window.AppLaunchParams.loginUser.username
      });
      this.set({
        recordedDate: new Date().getTime()
      });
      this.set({
        shortDescription: " "
      });
      this.set({
        lsLabels: new LabelList()
      });
      this.set({
        lsStates: new StateList()
      });
      this.set({
        firstLsThings: new FirstLsThingItxList()
      });
      return this.set({
        secondLsThings: new SecondLsThingItxList()
      });
    };

    Thing.prototype.initialize = function() {
      return this.set(this.parse(this.attributes));
    };

    Thing.prototype.parse = function(resp) {
      if (resp != null) {
        if (resp === 'not unique lsThing name') {
          this.createDefaultLabels();
          this.createDefaultStates();
          this.trigger('saveFailed');
          return;
        } else {
          if (resp.lsLabels != null) {
            if (!(resp.lsLabels instanceof LabelList)) {
              resp.lsLabels = new LabelList(resp.lsLabels);
            }
            resp.lsLabels.on('change', (function(_this) {
              return function() {
                return _this.trigger('change');
              };
            })(this));
          }
          if (resp.lsStates != null) {
            if (!(resp.lsStates instanceof StateList)) {
              resp.lsStates = new StateList(resp.lsStates);
            }
            resp.lsStates.on('change', (function(_this) {
              return function() {
                return _this.trigger('change');
              };
            })(this));
          }
          this.set(resp);
          this.createDefaultLabels();
          this.createDefaultStates();
          this.createDefaultFirstLsThingItx();
          this.createDefaultSecondLsThingItx();
        }
      } else {
        this.createDefaultLabels();
        this.createDefaultStates();
        this.createDefaultFirstLsThingItx();
        this.createDefaultSecondLsThingItx();
      }
      return resp;
    };

    Thing.prototype.createDefaultLabels = function() {
      var dLabel, newLabel, _i, _len, _ref, _results;
      if (this.lsProperties.defaultLabels != null) {
        _ref = this.lsProperties.defaultLabels;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          dLabel = _ref[_i];
          newLabel = this.get('lsLabels').getOrCreateLabelByTypeAndKind(dLabel.type, dLabel.kind);
          this.set(dLabel.key, newLabel);
          _results.push(newLabel.set({
            preferred: dLabel.preferred
          }));
        }
        return _results;
      }
    };

    Thing.prototype.createDefaultStates = function() {
      var dValue, newValue, _i, _len, _ref, _results;
      if (this.lsProperties.defaultValues != null) {
        _ref = this.lsProperties.defaultValues;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          dValue = _ref[_i];
          newValue = this.get('lsStates').getOrCreateValueByTypeAndKind(dValue.stateType, dValue.stateKind, dValue.type, dValue.kind);
          this.listenTo(newValue, 'createNewValue', this.createNewValue);
          if ((dValue.unitKind != null) && newValue.get('unitKind') === void 0) {
            newValue.set({
              unitKind: dValue.unitKind
            });
          }
          if ((dValue.unitType != null) && newValue.get('unitType') === void 0) {
            newValue.set({
              unitType: dValue.unitType
            });
          }
          if ((dValue.codeKind != null) && newValue.get('codeKind') === void 0) {
            newValue.set({
              codeKind: dValue.codeKind
            });
          }
          if ((dValue.codeType != null) && newValue.get('codeType') === void 0) {
            newValue.set({
              codeType: dValue.codeType
            });
          }
          if ((dValue.codeOrigin != null) && newValue.get('codeOrigin') === void 0) {
            newValue.set({
              codeOrigin: dValue.codeOrigin
            });
          }
          this.set(dValue.key, newValue);
          if ((dValue.value != null) && (newValue.get(dValue.type) === void 0)) {
            newValue.set(dValue.type, dValue.value);
          }
          _results.push(this.get(dValue.kind).set("value", newValue.get(dValue.type)));
        }
        return _results;
      }
    };

    Thing.prototype.createNewValue = function(vKind, newVal) {
      var newValue, valInfo;
      valInfo = _.where(this.lsProperties.defaultValues, {
        key: vKind
      })[0];
      this.unset(vKind);
      newValue = this.get('lsStates').getOrCreateValueByTypeAndKind(valInfo['stateType'], valInfo['stateKind'], valInfo['type'], valInfo['kind']);
      newValue.set(valInfo['type'], newVal);
      newValue.set({
        value: newVal
      });
      return this.set(vKind, newValue);
    };

    Thing.prototype.createDefaultFirstLsThingItx = function() {
      var itx, thingItx, _i, _len, _ref, _results;
      if (this.lsProperties.defaultFirstLsThingItx != null) {
        _ref = this.lsProperties.defaultFirstLsThingItx;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          itx = _ref[_i];
          thingItx = this.get('firstLsThings').getItxByTypeAndKind(itx.itxType, itx.itxKind);
          if (thingItx == null) {
            thingItx = this.get('firstLsThings').createItxByTypeAndKind(itx.itxType, itx.itxKind);
          }
          _results.push(this.set(itx.key, thingItx));
        }
        return _results;
      }
    };

    Thing.prototype.createDefaultSecondLsThingItx = function() {
      var itx, thingItx, _i, _len, _ref, _results;
      if (this.lsProperties.defaultSecondLsThingItx != null) {
        _ref = this.lsProperties.defaultSecondLsThingItx;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          itx = _ref[_i];
          thingItx = this.get('secondLsThings').getOrCreateItxByTypeAndKind(itx.itxType, itx.itxKind);
          _results.push(this.set(itx.key, thingItx));
        }
        return _results;
      }
    };

    Thing.prototype.getAnalyticalFiles = function(fileTypes) {
      var afm, analyticalFileState, analyticalFileValues, attachFileList, file, type, _i, _j, _len, _len1;
      attachFileList = new AttachFileList();
      for (_i = 0, _len = fileTypes.length; _i < _len; _i++) {
        type = fileTypes[_i];
        analyticalFileState = this.get('lsStates').getOrCreateStateByTypeAndKind("metadata", this.get('lsKind') + " batch");
        analyticalFileValues = analyticalFileState.getValuesByTypeAndKind("fileValue", type.code);
        if (analyticalFileValues.length > 0 && type.code !== "unassigned") {
          for (_j = 0, _len1 = analyticalFileValues.length; _j < _len1; _j++) {
            file = analyticalFileValues[_j];
            if (!file.get('ignored')) {
              afm = new AttachFile({
                fileType: type.code,
                fileValue: file.get('fileValue'),
                id: file.get('id'),
                comments: file.get('comments')
              });
              attachFileList.add(afm);
            }
          }
        }
      }
      return attachFileList;
    };

    Thing.prototype.reformatBeforeSaving = function() {
      var dLabel, dValue, i, itx, lsStates, value, _i, _j, _k, _l, _len, _len1, _len2, _len3, _ref, _ref1, _ref2, _ref3, _results;
      _ref = this.lsProperties.defaultLabels;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        dLabel = _ref[_i];
        this.unset(dLabel.key);
      }
      _ref1 = this.lsProperties.defaultFirstLsThingItx;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        itx = _ref1[_j];
        this.unset(itx.key);
      }
      if ((this.get('firstLsThings') != null) && this.get('firstLsThings') instanceof FirstLsThingItxList) {
        this.get('firstLsThings').reformatBeforeSaving();
      }
      _ref2 = this.lsProperties.defaultSecondLsThingItx;
      for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
        itx = _ref2[_k];
        this.unset(itx.key);
      }
      if ((this.get('secondLsThings') != null) && this.get('secondLsThings') instanceof SecondLsThingItxList) {
        this.get('secondLsThings').reformatBeforeSaving();
      }
      _ref3 = this.lsProperties.defaultValues;
      for (_l = 0, _len3 = _ref3.length; _l < _len3; _l++) {
        dValue = _ref3[_l];
        if (this.get(dValue.key) != null) {
          if (this.get(dValue.key).get('value') === void 0) {
            lsStates = this.get('lsStates').getStatesByTypeAndKind(dValue.stateType, dValue.stateKind);
            value = lsStates[0].getValuesByTypeAndKind(dValue.type, dValue.kind);
            lsStates[0].get('lsValues').remove(value);
          }
          this.unset(dValue.key);
        }
      }
      if (this.attributes.attributes != null) {
        delete this.attributes.attributes;
      }
      _results = [];
      for (i in this.attributes) {
        if (_.isFunction(this.attributes[i])) {
          _results.push(delete this.attributes[i]);
        } else if (!isNaN(i)) {
          _results.push(delete this.attributes[i]);
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    Thing.prototype.deleteInteractions = function() {
      delete this.attributes.firstLsThings;
      return delete this.attributes.secondLsThings;
    };

    Thing.prototype.duplicate = function() {
      var copiedStates, copiedThing, origStates;
      copiedThing = this.clone();
      copiedThing.unset('lsStates');
      copiedThing.unset('id');
      copiedThing.unset('codeName');
      copiedStates = new StateList();
      origStates = this.get('lsStates');
      origStates.each(function(st) {
        var copiedState, copiedValues, origValues;
        copiedState = new State(_.clone(st.attributes));
        copiedState.unset('id');
        copiedState.unset('lsTransactions');
        copiedState.unset('lsValues');
        copiedValues = new ValueList();
        origValues = st.get('lsValues');
        origValues.each(function(sv) {
          var copiedVal;
          copiedVal = new Value(sv.attributes);
          copiedVal.unset('id');
          copiedVal.unset('lsTransaction');
          return copiedValues.add(copiedVal);
        });
        copiedState.set({
          lsValues: copiedValues
        });
        return copiedStates.add(copiedState);
      });
      copiedThing.set({
        lsStates: copiedStates,
        recordedBy: window.AppLaunchParams.loginUser.username,
        recordedDate: new Date().getTime(),
        version: 0
      });
      copiedThing.get('notebook').set({
        value: ""
      });
      copiedThing.get('scientist').set({
        value: "unassigned"
      });
      copiedThing.get('completion date').set({
        value: null
      });
      copiedThing.createDefaultLabels();
      return copiedThing;
    };

    Thing.prototype.getStateValueHistory = function(vKind) {
      var valInfo;
      valInfo = _.where(this.lsProperties.defaultValues, {
        key: vKind
      })[0];
      return this.get('lsStates').getStateValueHistory(valInfo['stateType'], valInfo['stateKind'], valInfo['type'], valInfo['kind']);
    };

    return Thing;

  })(Backbone.Model);

}).call(this);
