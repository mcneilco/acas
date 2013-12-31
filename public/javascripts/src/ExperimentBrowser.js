(function() {
  var _ref, _ref1, _ref2, _ref3,
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
      this.handleFindClicked = __bind(this.handleFindClicked, this);
      this.updateModel = __bind(this.updateModel, this);
      this.render = __bind(this.render, this);      _ref1 = ExperimentSearchController.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    ExperimentSearchController.prototype.template = _.template($("#ExperimentSearchView").html());

    ExperimentSearchController.prototype.events = {
      'change .bv_protocolCode': 'updateModel',
      'change .bv_experimentCode': 'updateModel',
      'click .bv_find': 'handleFindClicked'
    };

    ExperimentSearchController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      return this.setupProtocolSelect();
    };

    ExperimentSearchController.prototype.updateModel = function() {
      return this.model.set({
        protocolCode: this.$('.bv_protocolCode').val(),
        experimentCode: this.getTrimmedInput('.bv_experimentCode')
      });
    };

    ExperimentSearchController.prototype.handleFindClicked = function() {
      return this.trigger('find');
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

  })(AbstractFormController);

  window.ExperimentRowSummaryController = (function(_super) {
    __extends(ExperimentRowSummaryController, _super);

    function ExperimentRowSummaryController() {
      this.render = __bind(this.render, this);      _ref2 = ExperimentRowSummaryController.__super__.constructor.apply(this, arguments);
      return _ref2;
    }

    ExperimentRowSummaryController.prototype.tagName = 'tr';

    ExperimentRowSummaryController.prototype.initialize = function() {
      return this.template = _.template($('#ExperimentRowSummaryView').html());
    };

    ExperimentRowSummaryController.prototype.render = function() {
      var toDisplay;

      toDisplay = {
        experimentName: this.model.get('lsLabels').pickBestName().get('labelText'),
        experimentCode: this.model.get('codeName')
      };
      return $(this.el).html(this.template(toDisplay));
    };

    return ExperimentRowSummaryController;

  })(Backbone.View);

  window.ExperimentBrowserController = (function(_super) {
    __extends(ExperimentBrowserController, _super);

    function ExperimentBrowserController() {
      this.render = __bind(this.render, this);      _ref3 = ExperimentBrowserController.__super__.constructor.apply(this, arguments);
      return _ref3;
    }

    ExperimentBrowserController.prototype.template = _.template($("#ExperimentBrowserView").html());

    ExperimentBrowserController.prototype.initialize = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      this.searchController = new ExperimentSearchController({
        model: new ExperimentSearch(),
        el: this.$('.bv_experimentSearchController')
      });
      return this.searchController.render();
    };

    ExperimentBrowserController.prototype.render = function() {
      return this;
    };

    return ExperimentBrowserController;

  })(Backbone.View);

}).call(this);
