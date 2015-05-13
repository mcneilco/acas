(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.Thing = (function(superClass) {
    extend(Thing, superClass);

    function Thing() {
      this.getStateValueHistory = bind(this.getStateValueHistory, this);
      this.resetClonedAttrs = bind(this.resetClonedAttrs, this);
      this.resetStatesAndVals = bind(this.resetStatesAndVals, this);
      this.duplicate = bind(this.duplicate, this);
      this.deleteInteractions = bind(this.deleteInteractions, this);
      this.reformatBeforeSaving = bind(this.reformatBeforeSaving, this);
      this.getAnalyticalFiles = bind(this.getAnalyticalFiles, this);
      this.createDefaultSecondLsThingItx = bind(this.createDefaultSecondLsThingItx, this);
      this.createDefaultFirstLsThingItx = bind(this.createDefaultFirstLsThingItx, this);
      this.createNewValue = bind(this.createNewValue, this);
      this.createDefaultStates = bind(this.createDefaultStates, this);
      this.createDefaultLabels = bind(this.createDefaultLabels, this);
      this.parse = bind(this.parse, this);
      this.defaults = bind(this.defaults, this);
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
      var dLabel, j, len, newLabel, ref, results;
      if (this.lsProperties.defaultLabels != null) {
        ref = this.lsProperties.defaultLabels;
        results = [];
        for (j = 0, len = ref.length; j < len; j++) {
          dLabel = ref[j];
          newLabel = this.get('lsLabels').getOrCreateLabelByTypeAndKind(dLabel.type, dLabel.kind);
          this.set(dLabel.key, newLabel);
          results.push(newLabel.set({
            preferred: dLabel.preferred
          }));
        }
        return results;
      }
    };

    Thing.prototype.createDefaultStates = function() {
      var dValue, j, len, newValue, ref, results;
      if (this.lsProperties.defaultValues != null) {
        ref = this.lsProperties.defaultValues;
        results = [];
        for (j = 0, len = ref.length; j < len; j++) {
          dValue = ref[j];
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
          results.push(this.get(dValue.kind).set("value", newValue.get(dValue.type)));
        }
        return results;
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
        unitKind: valInfo['unitKind'],
        unitType: valInfo['unitType'],
        codeKind: valInfo['codeKind'],
        codeType: valInfo['codeType'],
        codeOrigin: valInfo['codeOrigin'],
        value: newVal
      });
      return this.set(vKind, newValue);
    };

    Thing.prototype.createDefaultFirstLsThingItx = function() {
      var itx, j, len, ref, results, thingItx;
      if (this.lsProperties.defaultFirstLsThingItx != null) {
        ref = this.lsProperties.defaultFirstLsThingItx;
        results = [];
        for (j = 0, len = ref.length; j < len; j++) {
          itx = ref[j];
          thingItx = this.get('firstLsThings').getItxByTypeAndKind(itx.itxType, itx.itxKind);
          if (thingItx == null) {
            thingItx = this.get('firstLsThings').createItxByTypeAndKind(itx.itxType, itx.itxKind);
          }
          results.push(this.set(itx.key, thingItx));
        }
        return results;
      }
    };

    Thing.prototype.createDefaultSecondLsThingItx = function() {
      var itx, j, len, ref, results, thingItx;
      if (this.lsProperties.defaultSecondLsThingItx != null) {
        ref = this.lsProperties.defaultSecondLsThingItx;
        results = [];
        for (j = 0, len = ref.length; j < len; j++) {
          itx = ref[j];
          thingItx = this.get('secondLsThings').getOrCreateItxByTypeAndKind(itx.itxType, itx.itxKind);
          results.push(this.set(itx.key, thingItx));
        }
        return results;
      }
    };

    Thing.prototype.getAnalyticalFiles = function(fileTypes) {
      var afm, analyticalFileState, analyticalFileValues, attachFileList, file, j, k, len, len1, type;
      attachFileList = new AttachFileList();
      for (j = 0, len = fileTypes.length; j < len; j++) {
        type = fileTypes[j];
        analyticalFileState = this.get('lsStates').getOrCreateStateByTypeAndKind("metadata", this.get('lsKind') + " batch");
        analyticalFileValues = analyticalFileState.getValuesByTypeAndKind("fileValue", type.code);
        if (analyticalFileValues.length > 0 && type.code !== "unassigned") {
          for (k = 0, len1 = analyticalFileValues.length; k < len1; k++) {
            file = analyticalFileValues[k];
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
      var dLabel, dValue, i, itx, j, k, l, len, len1, len2, len3, lsStates, m, ref, ref1, ref2, ref3, results, value;
      if (this.lsProperties.defaultLabels != null) {
        ref = this.lsProperties.defaultLabels;
        for (j = 0, len = ref.length; j < len; j++) {
          dLabel = ref[j];
          this.unset(dLabel.key);
        }
      }
      if (this.lsProperties.defaultFirstLsThingItx != null) {
        ref1 = this.lsProperties.defaultFirstLsThingItx;
        for (k = 0, len1 = ref1.length; k < len1; k++) {
          itx = ref1[k];
          this.unset(itx.key);
        }
      }
      if ((this.get('firstLsThings') != null) && this.get('firstLsThings') instanceof FirstLsThingItxList) {
        this.get('firstLsThings').reformatBeforeSaving();
      }
      if (this.lsProperties.defaultSecondLsThingItx != null) {
        ref2 = this.lsProperties.defaultSecondLsThingItx;
        for (l = 0, len2 = ref2.length; l < len2; l++) {
          itx = ref2[l];
          this.unset(itx.key);
        }
      }
      if ((this.get('secondLsThings') != null) && this.get('secondLsThings') instanceof SecondLsThingItxList) {
        this.get('secondLsThings').reformatBeforeSaving();
      }
      if (this.lsProperties.defaultValues != null) {
        ref3 = this.lsProperties.defaultValues;
        for (m = 0, len3 = ref3.length; m < len3; m++) {
          dValue = ref3[m];
          if (this.get(dValue.key) != null) {
            if (this.get(dValue.key).get('value') === void 0) {
              lsStates = this.get('lsStates').getStatesByTypeAndKind(dValue.stateType, dValue.stateKind);
              value = lsStates[0].getValuesByTypeAndKind(dValue.type, dValue.kind);
              lsStates[0].get('lsValues').remove(value);
            }
            this.unset(dValue.key);
          }
        }
      }
      if (this.attributes.attributes != null) {
        delete this.attributes.attributes;
      }
      results = [];
      for (i in this.attributes) {
        if (_.isFunction(this.attributes[i])) {
          results.push(delete this.attributes[i]);
        } else if (!isNaN(i)) {
          results.push(delete this.attributes[i]);
        } else {
          results.push(void 0);
        }
      }
      return results;
    };

    Thing.prototype.deleteInteractions = function() {
      delete this.attributes.firstLsThings;
      return delete this.attributes.secondLsThings;
    };

    Thing.prototype.duplicate = function() {
      var copiedThing, labels, secondItxs, states;
      copiedThing = this.clone();
      copiedThing.unset('codeName');
      labels = copiedThing.get('lsLabels');
      labels.each((function(_this) {
        return function(label) {
          return _this.resetClonedAttrs(label);
        };
      })(this));
      states = copiedThing.get('lsStates');
      this.resetStatesAndVals(states);
      copiedThing.set({
        version: 0
      });
      this.resetClonedAttrs(copiedThing);
      copiedThing.get('notebook').set({
        value: ""
      });
      copiedThing.get('scientist').set({
        value: "unassigned"
      });
      copiedThing.get('completion date').set({
        value: null
      });
      delete copiedThing.attributes.firstLsThings;
      secondItxs = copiedThing.get('secondLsThings');
      secondItxs.each((function(_this) {
        return function(itx) {
          var itxStates;
          _this.resetClonedAttrs(itx);
          itxStates = itx.get('lsStates');
          return _this.resetStatesAndVals(itxStates);
        };
      })(this));
      return copiedThing;
    };

    Thing.prototype.resetStatesAndVals = function(states) {
      return states.each((function(_this) {
        return function(st) {
          var igVal, ignoredVals, j, len, val, values;
          _this.resetClonedAttrs(st);
          values = st.get('lsValues');
          if (values != null) {
            ignoredVals = values.filter(function(val) {
              return val.get('ignored');
            });
            for (j = 0, len = ignoredVals.length; j < len; j++) {
              val = ignoredVals[j];
              igVal = st.getValueById(val.get('id'))[0];
              values.remove(igVal);
            }
            return values.each(function(sv) {
              return _this.resetClonedAttrs(sv);
            });
          }
        };
      })(this));
    };

    Thing.prototype.resetClonedAttrs = function(clone) {
      clone.unset('id');
      clone.unset('lsTransaction');
      clone.unset('modifiedDate');
      return clone.set({
        recordedBy: window.AppLaunchParams.loginUser.username,
        recordedDate: new Date().getTime(),
        version: 0
      });
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
