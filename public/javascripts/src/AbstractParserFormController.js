(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.AbstractParserFormController = (function(_super) {
    __extends(AbstractParserFormController, _super);

    function AbstractParserFormController() {
      this.render = __bind(this.render, this);
      return AbstractParserFormController.__super__.constructor.apply(this, arguments);
    }

    AbstractParserFormController.prototype.initialize = function() {
      $(this.el).html(this.template());
      return this.setBindings();
    };

    AbstractParserFormController.prototype.render = function() {
      return this;
    };

    AbstractParserFormController.prototype.setupProjectSelect = function() {
      this.projectList = new PickListList();
      this.projectList.url = "/api/projects";
      return this.projectListController = new PickListSelectController({
        el: this.$('.bv_project'),
        collection: this.projectList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select Project"
        }),
        selectedCode: "unassigned"
      });
    };

    AbstractParserFormController.prototype.setupProtocolSelect = function(search) {
      this.protocolList = new PickListList();
      this.protocolList.url = "/api/protocolCodes/?protocolName=" + search;
      return this.protocolListController = new PickListSelectController({
        el: this.$('.bv_protocolName'),
        collection: this.protocolList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select Protocol"
        }),
        selectedCode: "unassigned"
      });
    };

    AbstractParserFormController.prototype.enableAllInputs = function() {
      AbstractParserFormController.__super__.enableAllInputs.call(this);
      return this.$('.bv_csvPreviewContainer').hide();
    };

    return AbstractParserFormController;

  })(AbstractFormController);

}).call(this);
