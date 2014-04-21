(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.PickList = (function(_super) {
    __extends(PickList, _super);

    function PickList() {
      return PickList.__super__.constructor.apply(this, arguments);
    }

    return PickList;

  })(Backbone.Model);

  window.PickListList = (function(_super) {
    __extends(PickListList, _super);

    function PickListList() {
      return PickListList.__super__.constructor.apply(this, arguments);
    }

    PickListList.prototype.model = PickList;

    PickListList.prototype.setType = function(type) {
      return this.type = type;
    };

    PickListList.prototype.getModelWithCode = function(code) {
      return this.detect(function(enu) {
        return enu.get("code") === code;
      });
    };

    PickListList.prototype.getCurrent = function() {
      return this.filter(function(pl) {
        return !(pl.get('ignored'));
      });
    };

    return PickListList;

  })(Backbone.Collection);

  window.PickListOptionController = (function(_super) {
    __extends(PickListOptionController, _super);

    function PickListOptionController() {
      this.render = __bind(this.render, this);
      return PickListOptionController.__super__.constructor.apply(this, arguments);
    }

    PickListOptionController.prototype.tagName = "option";

    PickListOptionController.prototype.initialize = function() {};

    PickListOptionController.prototype.render = function() {
      $(this.el).attr("value", this.model.get("code")).text(this.model.get("name"));
      return this;
    };

    return PickListOptionController;

  })(Backbone.View);

  window.PickListSelectController = (function(_super) {
    __extends(PickListSelectController, _super);

    function PickListSelectController() {
      this.addOne = __bind(this.addOne, this);
      this.render = __bind(this.render, this);
      this.handleListReset = __bind(this.handleListReset, this);
      return PickListSelectController.__super__.constructor.apply(this, arguments);
    }

    PickListSelectController.prototype.initialize = function() {
      this.rendered = false;
      this.collection.bind("add", this.addOne);
      this.collection.bind("reset", this.handleListReset);
      this.collection.fetch({
        success: this.handleListReset
      });
      if (this.options.selectedCode !== "") {
        this.selectedCode = this.options.selectedCode;
      } else {
        this.selectedCode = null;
      }
      if (this.options.insertFirstOption != null) {
        return this.insertFirstOption = this.options.insertFirstOption;
      } else {
        return this.insertFirstOption = null;
      }
    };

    PickListSelectController.prototype.handleListReset = function() {
      if (this.insertFirstOption) {
        this.collection.add(this.insertFirstOption, {
          at: 0,
          silent: true
        });
      }
      return this.render();
    };

    PickListSelectController.prototype.render = function() {
      var self;
      $(this.el).empty();
      self = this;
      this.collection.each((function(_this) {
        return function(enm) {
          return _this.addOne(enm);
        };
      })(this));
      if (this.selectedCode) {
        $(this.el).val(this.selectedCode);
      }
      $(this.el).hide();
      $(this.el).show();
      return this.rendered = true;
    };

    PickListSelectController.prototype.addOne = function(enm) {
      if (!enm.get('ignored')) {
        return $(this.el).append(new PickListOptionController({
          model: enm
        }).render().el);
      }
    };

    PickListSelectController.prototype.setSelectedCode = function(code) {
      this.selectedCode = code;
      if (this.rendered) {
        return $(this.el).val(this.selectedCode);
      }
    };

    PickListSelectController.prototype.getSelectedCode = function() {
      return $(this.el).val();
    };

    PickListSelectController.prototype.getSelectedModel = function() {
      return this.collection.getModelWithCode(this.getSelectedCode());
    };

    return PickListSelectController;

  })(Backbone.View);

}).call(this);
