(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.Thing = (function(_super) {
    __extends(Thing, _super);

    function Thing() {
      this.reformatBeforeSaving = __bind(this.reformatBeforeSaving, this);
      this.getAnalyticalFiles = __bind(this.getAnalyticalFiles, this);
      this.createDefaultStates = __bind(this.createDefaultStates, this);
      this.createDefaultLabels = __bind(this.createDefaultLabels, this);
      this.parse = __bind(this.parse, this);
      this.defaults = __bind(this.defaults, this);
      return Thing.__super__.constructor.apply(this, arguments);
    }

    Thing.prototype.lsProperties = {};

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
        recordedBy: ""
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
      return this.set({
        lsStates: new StateList()
      });
    };

    Thing.prototype.initialize = function() {
      console.log("initialize");
      console.log(this);
      return this.set(this.parse(this.attributes));
    };

    Thing.prototype.parse = function(resp) {
      console.log("parse");
      if (resp != null) {
        if (resp.lsLabels != null) {
          console.log("passed resp.labels?");
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
          console.log("lsStates exists");
          console.log(resp.lsStates);
          if (!(resp.lsStates instanceof StateList)) {
            console.log("resp.lsStates = new StateList");
            resp.lsStates = new StateList(resp.lsStates);
            console.log("new resp.lsStates");
            console.log(resp.lsStates);
          }
          resp.lsStates.on('change', (function(_this) {
            return function() {
              return _this.trigger('change');
            };
          })(this));
        }
      }
      this.createDefaultLabels();
      this.createDefaultStates();
      return resp;
    };

    Thing.prototype.createDefaultLabels = function() {
      var dLabel, newLabel, _i, _len, _ref, _results;
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
    };

    Thing.prototype.createDefaultStates = function() {
      var dValue, newValue, _i, _len, _ref, _results;
      _ref = this.lsProperties.defaultValues;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        dValue = _ref[_i];
        newValue = this.get('lsStates').getOrCreateValueByTypeAndKind(dValue.stateType, dValue.stateKind, dValue.type, dValue.kind);
        if (dValue.unitKind != null) {
          newValue.set({
            unitKind: dValue.unitKind
          });
        }
        if (dValue.unitType != null) {
          newValue.set({
            unitType: dValue.unitType
          });
        }
        if (dValue.codeKind != null) {
          newValue.set({
            codeKind: dValue.codeKind
          });
        }
        if (dValue.codeType != null) {
          newValue.set({
            codeType: dValue.codeType
          });
        }
        if (dValue.codeOrigin != null) {
          newValue.set({
            codeOrigin: dValue.codeOrigin
          });
        }
        this.set(dValue.key, newValue);
        if (dValue.value != null) {
          newValue.set(dValue.type, dValue.value);
        }
        _results.push(this.get(dValue.kind).set("value", newValue.get(dValue.type)));
      }
      return _results;
    };

    Thing.prototype.getAnalyticalFiles = function(fileTypes) {
      var afm, analyticalFileValue, attachFileList, type, _i, _len;
      console.log("get analytical files");
      console.log(fileTypes);
      attachFileList = new AttachFileList();
      for (_i = 0, _len = fileTypes.length; _i < _len; _i++) {
        type = fileTypes[_i];
        analyticalFileValue = this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", this.get('lsKind') + " batch", "fileValue", type.code);
        if (!(analyticalFileValue.get('fileValue') === void 0 || analyticalFileValue.get('fileValue') === "")) {
          afm = new AttachFile({
            fileType: type.code,
            fileValue: analyticalFileValue.get('fileValue')
          });
          attachFileList.add(afm);
        }
      }
      return attachFileList;
    };

    Thing.prototype.reformatBeforeSaving = function() {
      var dLabel, dValue, i, _i, _j, _len, _len1, _ref, _ref1, _results;
      _ref = this.lsProperties.defaultLabels;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        dLabel = _ref[_i];
        this.unset(dLabel.key);
      }
      _ref1 = this.lsProperties.defaultValues;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        dValue = _ref1[_j];
        this.unset(dValue.key);
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

    return Thing;

  })(Backbone.Model);

  window.BviditySiRNA = (function(_super) {
    __extends(BviditySiRNA, _super);

    function BviditySiRNA() {
      return BviditySiRNA.__super__.constructor.apply(this, arguments);
    }

    BviditySiRNA.prototype.defaultLabels = [
      {
        key: 'somename',
        type: 'name',
        kind: 'name',
        preferred: true,
        labelText: ""
      }, {
        key: 'somecorpName',
        type: 'name',
        kind: 'corpName',
        preferred: false,
        labelText: ""
      }, {
        key: 'somebarcode',
        type: 'barcode',
        kind: 'barcode',
        preferred: false,
        labelText: ""
      }
    ];

    BviditySiRNA.prototype.defaultValues = [
      {
        key: 'sequenceValue',
        stateType: 'descriptors',
        stateKind: 'unique attributes',
        type: 'stringValue',
        kind: 'sequence',
        value: ""
      }, {
        key: 'massValue',
        stateType: 'descriptors',
        stateKind: 'other attributes',
        type: 'numberValue',
        kind: 'mass',
        units: 'mg',
        value: 42.34
      }, {
        key: 'analysisParameters',
        stateType: 'meta',
        stateKind: 'experoiment meta',
        type: 'compositeObkectClob',
        kind: 'AnalysisParameters'
      }
    ];

    BviditySiRNA.prototype.defaultValueArrays = [
      {
        key: 'temperatureValueArray',
        stateType: 'measurements',
        stateKind: 'stateVsTime',
        type: 'numberValue',
        kind: 'temperature',
        units: 'C',
        value: null
      }, {
        key: 'timeValueArray',
        stateType: 'measurements',
        stateKind: 'stateVsTime',
        type: 'dateValue',
        kind: 'time',
        value: null
      }
    ];

    BviditySiRNA.prototype.defaults = function() {
      var attrs;
      attrs = BviditySiRNA.__super__.defaults.call(this);
      attrs.shortDescription = "awesome";
      return attrs;
    };

    BviditySiRNA.prototype.someMethod = function() {
      this.get('corpName').set({
        labelText: "fred"
      });
      this.set({
        coprpName: "don't do this"
      });
      return this.get('massValue').set({
        value: 42.0
      });
    };

    return BviditySiRNA;

  })(Thing);

}).call(this);
