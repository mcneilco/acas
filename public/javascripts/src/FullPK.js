(function() {
  var _ref, _ref1, _ref2,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.FullPK = (function(_super) {
    __extends(FullPK, _super);

    function FullPK() {
      _ref = FullPK.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    FullPK.prototype.defaults = {
      format: "In Vivo Full PK",
      protocolName: "",
      experimentName: "",
      scientist: "",
      notebook: "",
      inLifeNotebook: "",
      assayDate: null,
      project: "",
      bioavailability: "",
      aucType: ""
    };

    FullPK.prototype.validate = function(attrs) {
      var errors;

      errors = [];
      if (attrs.protocolName === "") {
        errors.push({
          attribute: 'protocolName',
          message: "Protocol Name must be provided"
        });
      }
      if (errors.length > 0) {
        return errors;
      } else {
        return null;
      }
    };

    return FullPK;

  })(Backbone.Model);

  window.FullPKController = (function(_super) {
    __extends(FullPKController, _super);

    function FullPKController() {
      this.attributeChanged = __bind(this.attributeChanged, this);
      this.render = __bind(this.render, this);      _ref1 = FullPKController.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    FullPKController.prototype.template = _.template($("#FullPKView").html());

    FullPKController.prototype.events = {
      'change .bv_protocolName': "attributeChanged"
    };

    FullPKController.prototype.initialize = function() {
      this.errorOwnerName = 'FullPKController';
      $(this.el).html(this.template());
      this.setBindings();
      return this.setupProjectSelect();
    };

    FullPKController.prototype.render = function() {
      return this;
    };

    FullPKController.prototype.attributeChanged = function() {
      console.log("got attr changed");
      this.trigger('amDirty');
      return this.updateModel();
    };

    FullPKController.prototype.updateModel = function() {
      return this.model.set({
        protocolName: this.$('.bv_protocolName').val()
      });
    };

    FullPKController.prototype.setupProjectSelect = function() {
      console.log(this.$('.bv_project'));
      this.projectList = new PickListList();
      this.projectList.url = "/api/projects";
      return this.projectListController = new PickListSelectController({
        el: this.$('.bv_project'),
        collection: this.projectList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select Category"
        }),
        selectedCode: "unassigned"
      });
    };

    return FullPKController;

  })(AbstractFormController);

  window.FullPKParserController = (function(_super) {
    __extends(FullPKParserController, _super);

    function FullPKParserController() {
      _ref2 = FullPKParserController.__super__.constructor.apply(this, arguments);
      return _ref2;
    }

    FullPKParserController.prototype.initialize = function() {
      this.fileProcessorURL = "/api/fullPKParser";
      this.errorOwnerName = 'FullPKParser';
      this.loadReportFile = true;
      FullPKParserController.__super__.initialize.call(this);
      return this.$('.bv_moduleTitle').html('Full PK Experiment Loader');
    };

    return FullPKParserController;

  })(BasicFileValidateAndSaveController);

}).call(this);
