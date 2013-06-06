(function() {
  var _ref, _ref1, _ref2, _ref3, _ref4,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.ProtocolValue = (function(_super) {
    __extends(ProtocolValue, _super);

    function ProtocolValue() {
      _ref = ProtocolValue.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    return ProtocolValue;

  })(Backbone.Model);

  window.ProtocolValueList = (function(_super) {
    __extends(ProtocolValueList, _super);

    function ProtocolValueList() {
      _ref1 = ProtocolValueList.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    ProtocolValueList.prototype.model = ProtocolValue;

    return ProtocolValueList;

  })(Backbone.Collection);

  window.ProtocolState = (function(_super) {
    __extends(ProtocolState, _super);

    function ProtocolState() {
      _ref2 = ProtocolState.__super__.constructor.apply(this, arguments);
      return _ref2;
    }

    ProtocolState.prototype.defaults = {
      protocolValues: new ProtocolValueList()
    };

    ProtocolState.prototype.initialize = function() {
      var _this = this;

      if (this.has('protocolValues')) {
        if (!(this.get('protocolValues') instanceof ProtocolValueList)) {
          this.set({
            protocolValues: new ProtocolValueList(this.get('protocolValues'))
          });
        }
      }
      return this.get('protocolValues').on('change', function() {
        return _this.trigger('change');
      });
    };

    ProtocolState.prototype.parse = function(resp) {
      var _this = this;

      if (resp.protocolValues != null) {
        if (!(resp.protocolValues instanceof ProtocolValueList)) {
          resp.protocolValues = new ProtocolValueList(resp.protocolValues);
          resp.protocolValues.on('change', function() {
            return _this.trigger('change');
          });
        }
      }
      return resp;
    };

    return ProtocolState;

  })(Backbone.Model);

  window.ProtocolStateList = (function(_super) {
    __extends(ProtocolStateList, _super);

    function ProtocolStateList() {
      _ref3 = ProtocolStateList.__super__.constructor.apply(this, arguments);
      return _ref3;
    }

    ProtocolStateList.prototype.model = ProtocolState;

    return ProtocolStateList;

  })(Backbone.Collection);

  window.Protocol = (function(_super) {
    __extends(Protocol, _super);

    function Protocol() {
      this.parse = __bind(this.parse, this);      _ref4 = Protocol.__super__.constructor.apply(this, arguments);
      return _ref4;
    }

    Protocol.prototype.urlRoot = "/api/protocols";

    Protocol.prototype.defaults = {
      kind: "",
      recordedBy: "",
      shortDescription: "",
      protocolLabels: new LabelList(),
      protocolStates: new ProtocolStateList()
    };

    Protocol.prototype.initialize = function() {
      this.fixCompositeClasses();
      return this.setupCompositeChangeTriggers();
    };

    Protocol.prototype.parse = function(resp) {
      var _this = this;

      if (resp.protocolLabels != null) {
        if (!(resp.protocolLabels instanceof LabelList)) {
          resp.protocolLabels = new LabelList(resp.protocolLabels);
          resp.protocolLabels.on('change', function() {
            return _this.trigger('change');
          });
        }
      }
      if (resp.protocolStates != null) {
        if (!(resp.protocolStates instanceof ProtocolStateList)) {
          resp.protocolStates = new ProtocolStateList(resp.protocolStates);
          resp.protocolStates.on('change', function() {
            return _this.trigger('change');
          });
        }
      }
      return resp;
    };

    Protocol.prototype.fixCompositeClasses = function() {
      if (this.has('protocolLabels')) {
        if (!(this.get('protocolLabels') instanceof LabelList)) {
          this.set({
            protocolLabels: new LabelList(this.get('protocolLabels'))
          });
        }
      }
      if (this.has('protocolStates')) {
        if (!(this.get('protocolStates') instanceof ProtocolStateList)) {
          return this.set({
            protocolStates: new ProtocolStateList(this.get('protocolStates'))
          });
        }
      }
    };

    Protocol.prototype.setupCompositeChangeTriggers = function() {
      var _this = this;

      this.get('protocolLabels').on('change', function() {
        return _this.trigger('change');
      });
      return this.get('protocolStates').on('change', function() {
        return _this.trigger('change');
      });
    };

    Protocol.prototype.isStub = function() {
      return this.get('protocolLabels').length === 0;
    };

    return Protocol;

  })(Backbone.Model);

}).call(this);
