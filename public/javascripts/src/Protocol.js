(function() {
  var _ref,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.Protocol = (function(_super) {
    __extends(Protocol, _super);

    function Protocol() {
      this.parse = __bind(this.parse, this);      _ref = Protocol.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Protocol.prototype.urlRoot = "/api/protocols";

    Protocol.prototype.defaults = {
      kind: "",
      recordedBy: "",
      shortDescription: "",
      lsLabels: new LabelList(),
      lsStates: new StateList()
    };

    Protocol.prototype.initialize = function() {
      this.fixCompositeClasses();
      return this.setupCompositeChangeTriggers();
    };

    Protocol.prototype.parse = function(resp) {
      var _this = this;

      if (resp.lsLabels != null) {
        if (!(resp.lsLabels instanceof LabelList)) {
          resp.lsLabels = new LabelList(resp.lsLabels);
          resp.lsLabels.on('change', function() {
            return _this.trigger('change');
          });
        }
      }
      if (resp.lsStates != null) {
        if (!(resp.lsStates instanceof StateList)) {
          resp.lsStates = new StateList(resp.lsStates);
          resp.lsStates.on('change', function() {
            return _this.trigger('change');
          });
        }
      }
      return resp;
    };

    Protocol.prototype.fixCompositeClasses = function() {
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

    Protocol.prototype.setupCompositeChangeTriggers = function() {
      var _this = this;

      this.get('lsLabels').on('change', function() {
        return _this.trigger('change');
      });
      return this.get('lsStates').on('change', function() {
        return _this.trigger('change');
      });
    };

    Protocol.prototype.isStub = function() {
      return this.get('lsLabels').length === 0;
    };

    return Protocol;

  })(Backbone.Model);

}).call(this);
