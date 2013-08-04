(function() {
  var _ref, _ref1, _ref2,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.MicroSol = (function(_super) {
    __extends(MicroSol, _super);

    function MicroSol() {
      _ref = MicroSol.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    MicroSol.prototype.defaults = {
      protocolName: "",
      scientist: "",
      notebook: "",
      project: ""
    };

    MicroSol.prototype.validate = function(attrs) {
      var errors;

      errors = [];
      if (attrs.protocolName === "Select Protocol") {
        errors.push({
          attribute: 'protocolName',
          message: "Protocol Name must be provided"
        });
      }
      if (attrs.scientist === "") {
        errors.push({
          attribute: 'scientist',
          message: "Scientist must be provided"
        });
      }
      if (attrs.notebook === "") {
        errors.push({
          attribute: 'notebook',
          message: "Notebook must be provided"
        });
      }
      if (attrs.project === "unassigned") {
        errors.push({
          attribute: 'project',
          message: "Project must be provided"
        });
      }
      if (errors.length > 0) {
        return errors;
      } else {
        return null;
      }
    };

    return MicroSol;

  })(Backbone.Model);

  window.MicroSolController = (function(_super) {
    __extends(MicroSolController, _super);

    function MicroSolController() {
      this.attributeChanged = __bind(this.attributeChanged, this);
      this.render = __bind(this.render, this);      _ref1 = MicroSolController.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    MicroSolController.prototype.template = _.template($("#MicroSolView").html());

    MicroSolController.prototype.events = {
      'change .bv_protocolName': "attributeChanged",
      'change .bv_scientist': "attributeChanged",
      'change .bv_notebook': "attributeChanged",
      'change .bv_project': "attributeChanged"
    };

    MicroSolController.prototype.initialize = function() {
      this.errorOwnerName = 'MicroSolController';
      $(this.el).html(this.template());
      this.setBindings();
      this.setupProjectSelect();
      return this.setupProtocolSelect();
    };

    MicroSolController.prototype.render = function() {
      return this;
    };

    MicroSolController.prototype.attributeChanged = function() {
      this.trigger('amDirty');
      return this.updateModel();
    };

    MicroSolController.prototype.updateModel = function() {
      this.model.set({
        protocolName: this.$('.bv_protocolName').find(":selected").text(),
        scientist: this.getTrimmedInput('.bv_scientist'),
        notebook: this.getTrimmedInput('.bv_notebook'),
        project: this.getTrimmedInput('.bv_project')
      });
      return this.trigger('amDirty');
    };

    MicroSolController.prototype.setupProjectSelect = function() {
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

    MicroSolController.prototype.setupProtocolSelect = function() {
      this.protocolList = new PickListList();
      this.protocolList.url = "api/protocolCodes/filter/uSol";
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

    MicroSolController.prototype.disableAllInputs = function() {
      this.$('input').attr('disabled', 'disabled');
      return this.$('select').attr('disabled', 'disabled');
    };

    MicroSolController.prototype.enableAllInputs = function() {
      this.$('input').removeAttr('disabled');
      return this.$('select').removeAttr('disabled');
    };

    return MicroSolController;

  })(AbstractFormController);

  window.MicroSolParserController = (function(_super) {
    __extends(MicroSolParserController, _super);

    function MicroSolParserController() {
      this.validateParseFile = __bind(this.validateParseFile, this);
      this.validateParseFile = __bind(this.validateParseFile, this);
      this.handleValidationReturnSuccess = __bind(this.handleValidationReturnSuccess, this);
      this.handleMSFormInvalid = __bind(this.handleMSFormInvalid, this);
      this.handleMSFormValid = __bind(this.handleMSFormValid, this);      _ref2 = MicroSolParserController.__super__.constructor.apply(this, arguments);
      return _ref2;
    }

    MicroSolParserController.prototype.initialize = function() {
      var _this = this;

      this.fileProcessorURL = "/api/microSolParser";
      this.errorOwnerName = 'MicroSolParserController';
      this.loadReportFile = false;
      MicroSolParserController.__super__.initialize.call(this);
      this.$('.bv_moduleTitle').html('Micro Solubility Experiment Loader');
      this.msc = new MicroSolController({
        model: new MicroSol(),
        el: this.$('.bv_additionalValuesForm')
      });
      this.msc.on('valid', this.handleMSFormValid);
      this.msc.on('invalid', this.handleMSFormInvalid);
      this.msc.on('notifyError', this.notificationController.addNotification);
      this.msc.on('clearErrors', this.notificationController.clearAllNotificiations);
      this.msc.on('amDirty', function() {
        return _this.trigger('amDirty');
      });
      return this.msc.render();
    };

    MicroSolParserController.prototype.handleMSFormValid = function() {
      if (this.parseFileUploaded) {
        return this.handleFormValid();
      }
    };

    MicroSolParserController.prototype.handleMSFormInvalid = function() {
      return this.handleFormInvalid();
    };

    MicroSolParserController.prototype.handleFormValid = function() {
      if (this.msc.isValid()) {
        return MicroSolParserController.__super__.handleFormValid.call(this);
      }
    };

    MicroSolParserController.prototype.handleValidationReturnSuccess = function(json) {
      MicroSolParserController.__super__.handleValidationReturnSuccess.call(this, json);
      return this.msc.disableAllInputs();
    };

    MicroSolParserController.prototype.showFileSelectPhase = function() {
      MicroSolParserController.__super__.showFileSelectPhase.call(this);
      if (this.msc != null) {
        return this.msc.enableAllInputs();
      }
    };

    MicroSolParserController.prototype.validateParseFile = function() {
      this.msc.updateModel();
      if (!!this.msc.isValid()) {
        this.additionalData = {
          inputParameters: this.msc.model.toJSON()
        };
        return MicroSolParserController.__super__.validateParseFile.call(this);
      }
    };

    MicroSolParserController.prototype.validateParseFile = function() {
      this.msc.updateModel();
      if (!!this.msc.isValid()) {
        this.additionalData = {
          inputParameters: this.msc.model.toJSON()
        };
        return MicroSolParserController.__super__.validateParseFile.call(this);
      }
    };

    return MicroSolParserController;

  })(BasicFileValidateAndSaveController);

}).call(this);
