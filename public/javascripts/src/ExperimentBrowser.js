(function() {
  var _ref, _ref1, _ref2,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.ExperimentSearch = (function(_super) {
    __extends(ExperimentSearch, _super);

    function ExperimentSearch() {
      _ref = ExperimentSearch.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    ExperimentSearch.prototype.defaults = {
      protocolCode: null,
      experimentCode: null
    };

    return ExperimentSearch;

  })(Backbone.Model);

  window.ExperimentSearchController = (function(_super) {
    __extends(ExperimentSearchController, _super);

    function ExperimentSearchController() {
      this.render = __bind(this.render, this);      _ref1 = ExperimentSearchController.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    ExperimentSearchController.prototype.template = _.template($("#ExperimentSearchView").html());

    ExperimentSearchController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      return this.setupProtocolSelect();
    };

    ExperimentSearchController.prototype.setupProtocolSelect = function() {
      this.protocolList = new PickListList();
      this.protocolList.url = "/api/protocolCodes/";
      return this.protocolListController = new PickListSelectController({
        el: this.$('.bv_protocolCode'),
        collection: this.protocolList,
        insertFirstOption: new PickList({
          code: "any",
          name: "any"
        }),
        selectedCode: null
      });
    };

    return ExperimentSearchController;

  })(Backbone.View);

  window.ExperimentBrowserController = (function(_super) {
    __extends(ExperimentBrowserController, _super);

    function ExperimentBrowserController() {
      this.render = __bind(this.render, this);      _ref2 = ExperimentBrowserController.__super__.constructor.apply(this, arguments);
      return _ref2;
    }

    ExperimentBrowserController.prototype.template = _.template($("#ExperimentBrowserView").html());

    ExperimentBrowserController.prototype.render = function() {
      $(this.el).empty();
      return $(this.el).html(this.template());
    };

    return ExperimentBrowserController;

  })(Backbone.View);

}).call(this);
