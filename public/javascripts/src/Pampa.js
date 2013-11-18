(function() {
  var _ref, _ref1, _ref2,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.Pampa = (function(_super) {
    __extends(Pampa, _super);

    function Pampa() {
      _ref = Pampa.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Pampa.prototype.defaults = {
      protocolName: "",
      scientist: "",
      notebook: "",
      project: ""
    };

    Pampa.prototype.validate = function(attrs) {
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

    return Pampa;

  })(Backbone.Model);

  window.PampaController = (function(_super) {
    __extends(PampaController, _super);

    function PampaController() {
      this.render = __bind(this.render, this);
      _ref1 = PampaController.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    PampaController.prototype.template = _.template($("#PampaView").html());

    PampaController.prototype.events = {
      'change .bv_protocolName': "attributeChanged",
      'change .bv_scientist': "attributeChanged",
      'change .bv_notebook': "attributeChanged",
      'change .bv_project': "attributeChanged"
    };

    PampaController.prototype.initialize = function() {
      this.errorOwnerName = 'PampaController';
      PampaController.__super__.initialize.call(this);
      this.setupProjectSelect();
      return this.setupProtocolSelect("pampa");
    };

    PampaController.prototype.render = function() {
      PampaController.__super__.render.call(this);
      return this;
    };

    PampaController.prototype.updateModel = function() {
      this.model.set({
        protocolName: this.$('.bv_protocolName').find(":selected").text(),
        scientist: this.getTrimmedInput('.bv_scientist'),
        notebook: this.getTrimmedInput('.bv_notebook'),
        project: this.getTrimmedInput('.bv_project')
      });
      return this.trigger('amDirty');
    };

    return PampaController;

  })(AbstractParserFormController);

  window.PampaParserController = (function(_super) {
    __extends(PampaParserController, _super);

    function PampaParserController() {
      this.validateParseFile = __bind(this.validateParseFile, this);
      this.validateParseFile = __bind(this.validateParseFile, this);
      this.handleValidationReturnSuccess = __bind(this.handleValidationReturnSuccess, this);
      this.handleMSFormInvalid = __bind(this.handleMSFormInvalid, this);
      this.handleMSFormValid = __bind(this.handleMSFormValid, this);
      _ref2 = PampaParserController.__super__.constructor.apply(this, arguments);
      return _ref2;
    }

    PampaParserController.prototype.initialize = function() {
      var _this = this;
      this.fileProcessorURL = "/api/pampaParser";
      this.errorOwnerName = 'PampaParserController';
      this.loadReportFile = false;
      PampaParserController.__super__.initialize.call(this);
      this.$('.bv_moduleTitle').html('Pampa Experiment Loader');
      this.msc = new PampaController({
        model: new Pampa(),
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

    PampaParserController.prototype.handleMSFormValid = function() {
      if (this.parseFileUploaded) {
        return this.handleFormValid();
      }
    };

    PampaParserController.prototype.handleMSFormInvalid = function() {
      return this.handleFormInvalid();
    };

    PampaParserController.prototype.handleFormValid = function() {
      if (this.msc.isValid()) {
        return PampaParserController.__super__.handleFormValid.call(this);
      }
    };

    PampaParserController.prototype.handleValidationReturnSuccess = function(json) {
      PampaParserController.__super__.handleValidationReturnSuccess.call(this, json);
      return this.msc.disableAllInputs();
    };

    PampaParserController.prototype.showFileSelectPhase = function() {
      PampaParserController.__super__.showFileSelectPhase.call(this);
      if (this.msc != null) {
        return this.msc.enableAllInputs();
      }
    };

    PampaParserController.prototype.validateParseFile = function() {
      this.msc.updateModel();
      if (!!this.msc.isValid()) {
        this.additionalData = {
          inputParameters: this.msc.model.toJSON()
        };
        return PampaParserController.__super__.validateParseFile.call(this);
      }
    };

    PampaParserController.prototype.validateParseFile = function() {
      this.msc.updateModel();
      if (!!this.msc.isValid()) {
        this.additionalData = {
          inputParameters: this.msc.model.toJSON()
        };
        return PampaParserController.__super__.validateParseFile.call(this);
      }
    };

    return PampaParserController;

  })(BasicFileValidateAndSaveController);

}).call(this);
