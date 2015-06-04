(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.ThingItx = (function(superClass) {
    extend(ThingItx, superClass);

    function ThingItx() {
      this.reformatBeforeSaving = bind(this.reformatBeforeSaving, this);
      this.parse = bind(this.parse, this);
      this.defaults = bind(this.defaults, this);
      return ThingItx.__super__.constructor.apply(this, arguments);
    }

    ThingItx.prototype.className = "ThingItx";

    ThingItx.prototype.defaults = function() {
      this.set({
        lsType: "interaction"
      });
      this.set({
        lsKind: "interaction"
      });
      this.set({
        lsTypeAndKind: this._lsTypeAndKind()
      });
      this.set({
        lsStates: new StateList()
      });
      this.set({
        recordedBy: window.AppLaunchParams.loginUser.username
      });
      return this.set({
        recordedDate: new Date().getTime()
      });
    };

    ThingItx.prototype._lsTypeAndKind = function() {
      return this.get('lsType') + '_' + this.get('lsKind');
    };

    ThingItx.prototype.initialize = function() {
      return this.set(this.parse(this.attributes));
    };

    ThingItx.prototype.parse = function(resp) {
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
      return resp;
    };

    ThingItx.prototype.reformatBeforeSaving = function() {
      var i;
      if (this.attributes.attributes != null) {
        delete this.attributes.attributes;
      }
      for (i in this.attributes) {
        if (_.isFunction(this.attributes[i])) {
          delete this.attributes[i];
        } else if (!isNaN(i)) {
          delete this.attributes[i];
        }
      }
      delete this.attributes._changing;
      delete this.attributes._previousAttributes;
      delete this.attributes.cid;
      delete this.attributes.changed;
      delete this.attributes._pending;
      return delete this.attributes.collection;
    };

    return ThingItx;

  })(Backbone.Model);

  window.FirstThingItx = (function(superClass) {
    extend(FirstThingItx, superClass);

    function FirstThingItx() {
      this.setItxThing = bind(this.setItxThing, this);
      this.defaults = bind(this.defaults, this);
      return FirstThingItx.__super__.constructor.apply(this, arguments);
    }

    FirstThingItx.prototype.className = "FirstThingItx";

    FirstThingItx.prototype.defaults = function() {
      FirstThingItx.__super__.defaults.call(this);
      return this.set({
        firstLsThing: {}
      });
    };

    FirstThingItx.prototype.setItxThing = function(thing) {
      return this.set({
        firstLsThing: thing
      });
    };

    return FirstThingItx;

  })(ThingItx);

  window.SecondThingItx = (function(superClass) {
    extend(SecondThingItx, superClass);

    function SecondThingItx() {
      this.setItxThing = bind(this.setItxThing, this);
      this.defaults = bind(this.defaults, this);
      return SecondThingItx.__super__.constructor.apply(this, arguments);
    }

    SecondThingItx.prototype.className = "SecondThingItx";

    SecondThingItx.prototype.defaults = function() {
      SecondThingItx.__super__.defaults.call(this);
      return this.set({
        secondLsThing: {}
      });
    };

    SecondThingItx.prototype.setItxThing = function(thing) {
      return this.set({
        secondLsThing: thing
      });
    };

    return SecondThingItx;

  })(ThingItx);

  window.LsThingItxList = (function(superClass) {
    extend(LsThingItxList, superClass);

    function LsThingItxList() {
      this.reformatBeforeSaving = bind(this.reformatBeforeSaving, this);
      return LsThingItxList.__super__.constructor.apply(this, arguments);
    }

    LsThingItxList.prototype.getItxByTypeAndKind = function(type, kind) {
      return this.filter(function(itx) {
        return (!itx.get('ignored')) && (itx.get('lsType') === type) && (itx.get('lsKind') === kind);
      });
    };

    LsThingItxList.prototype.createItxByTypeAndKind = function(itxType, itxKind) {
      var itx;
      itx = new this.model({
        lsType: itxType,
        lsKind: itxKind,
        lsTypeAndKind: itxType + "_" + itxKind
      });
      this.add(itx);
      itx.on('change', (function(_this) {
        return function() {
          return _this.trigger('change');
        };
      })(this));
      return itx;
    };

    LsThingItxList.prototype.getOrderedItxList = function(type, kind) {
      var i, itxs, nextItx, orderedItx;
      itxs = this.getItxByTypeAndKind(type, kind);
      orderedItx = [];
      i = 1;
      while (i <= itxs.length) {
        nextItx = _.filter(itxs, function(itx) {
          var order;
          order = itx.get('lsStates').getOrCreateValueByTypeAndKind('metadata', 'composition', 'numericValue', 'order');
          return order.get('numericValue') === i;
        });
        orderedItx.push.apply(orderedItx, nextItx);
        i++;
      }
      return orderedItx;
    };

    LsThingItxList.prototype.reformatBeforeSaving = function() {
      return this.each(function(model) {
        return model.reformatBeforeSaving();
      });
    };

    return LsThingItxList;

  })(Backbone.Collection);

  window.FirstLsThingItxList = (function(superClass) {
    extend(FirstLsThingItxList, superClass);

    function FirstLsThingItxList() {
      return FirstLsThingItxList.__super__.constructor.apply(this, arguments);
    }

    FirstLsThingItxList.prototype.model = FirstThingItx;

    return FirstLsThingItxList;

  })(LsThingItxList);

  window.SecondLsThingItxList = (function(superClass) {
    extend(SecondLsThingItxList, superClass);

    function SecondLsThingItxList() {
      return SecondLsThingItxList.__super__.constructor.apply(this, arguments);
    }

    SecondLsThingItxList.prototype.model = SecondThingItx;

    return SecondLsThingItxList;

  })(LsThingItxList);

}).call(this);
