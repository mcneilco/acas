(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.ProtocolSearch = (function(_super) {
    __extends(ProtocolSearch, _super);

    function ProtocolSearch() {
      return ProtocolSearch.__super__.constructor.apply(this, arguments);
    }

    ProtocolSearch.prototype.defaults = {
      protocolCode: null
    };

    return ProtocolSearch;

  })(Backbone.Model);

  window.ProtocolSimpleSearchController = (function(_super) {
    __extends(ProtocolSimpleSearchController, _super);

    function ProtocolSimpleSearchController() {
      this.render = __bind(this.render, this);
      return ProtocolSimpleSearchController.__super__.constructor.apply(this, arguments);
    }

    ProtocolSimpleSearchController.prototype.template = _.template($("#ProtocolSimpleSearchView").html());

    ProtocolSimpleSearchController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      return this;
    };

    return ProtocolSimpleSearchController;

  })(AbstractFormController);

}).call(this);
