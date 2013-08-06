(function() {
  var _ref, _ref1, _ref2,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.MetStab = (function(_super) {
    __extends(MetStab, _super);

    function MetStab() {
      _ref = MetStab.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    MetStab.prototype.defaults = {
      protocolName: "",
      scientist: "",
      notebook: "",
      project: "",
      assayDate: null
    };

    MetStab.prototype.validate = function(attrs) {
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
      if (_.isNaN(attrs.assayDate)) {
        errors.push({
          attribute: 'assayDate',
          message: "Assay date must be set"
        });
      }
      if (errors.length > 0) {
        return errors;
      } else {
        return null;
      }
    };

    return MetStab;

  })(Backbone.Model);

  window.MetStabController = (function(_super) {
    __extends(MetStabController, _super);

    function MetStabController() {
      this.render = __bind(this.render, this);      _ref1 = MetStabController.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    MetStabController.prototype.template = _.template($("#MetStabView").html());

    MetStabController.prototype.events = {
      'change .bv_protocolName': "attributeChanged",
      'change .bv_scientist': "attributeChanged",
      'change .bv_notebook': "attributeChanged",
      'change .bv_project': "attributeChanged",
      'change .bv_assayDate': "attributeChanged"
    };

    MetStabController.prototype.initialize = function() {
      this.errorOwnerName = 'MetStabController';
      MetStabController.__super__.initialize.call(this);
      this.setupProjectSelect();
      return this.setupProtocolSelect("Microsome Stability");
    };

    MetStabController.prototype.render = function() {
      var date;

      MetStabController.__super__.render.call(this);
      this.$('.bv_assayDate').datepicker();
      this.$('.bv_assayDate').datepicker("option", "dateFormat", "yy-mm-dd");
      if (this.model.get('assayDate') !== null) {
        date = new Date(this.model.get('assayDate'));
        this.$('.bv_assayDate').val(date.getFullYear() + '-' + date.getMonth() + '-' + date.getDate());
      }
      return this;
    };

    MetStabController.prototype.updateModel = function() {
      this.model.set({
        protocolName: this.$('.bv_protocolName').find(":selected").text(),
        scientist: this.getTrimmedInput('.bv_scientist'),
        notebook: this.getTrimmedInput('.bv_notebook'),
        project: this.getTrimmedInput('.bv_project'),
        assayDate: this.convertYMDDateToMs(this.getTrimmedInput('.bv_assayDate'))
      });
      return this.trigger('amDirty');
    };

    return MetStabController;

  })(AbstractParserFormController);

  window.MetStabParserController = (function(_super) {
    __extends(MetStabParserController, _super);

    function MetStabParserController() {
      this.validateParseFile = __bind(this.validateParseFile, this);
      this.validateParseFile = __bind(this.validateParseFile, this);
      this.handleValidationReturnSuccess = __bind(this.handleValidationReturnSuccess, this);
      this.handleMSFormInvalid = __bind(this.handleMSFormInvalid, this);
      this.handleMSFormValid = __bind(this.handleMSFormValid, this);      _ref2 = MetStabParserController.__super__.constructor.apply(this, arguments);
      return _ref2;
    }

    MetStabParserController.prototype.initialize = function() {
      var _this = this;

      this.fileProcessorURL = "/api/metStabParser";
      this.errorOwnerName = 'MetStabParserController';
      this.loadReportFile = false;
      MetStabParserController.__super__.initialize.call(this);
      this.$('.bv_moduleTitle').html('MetStab Experiment Loader');
      this.msc = new MetStabController({
        model: new MetStab(),
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

    MetStabParserController.prototype.handleMSFormValid = function() {
      if (this.parseFileUploaded) {
        return this.handleFormValid();
      }
    };

    MetStabParserController.prototype.handleMSFormInvalid = function() {
      return this.handleFormInvalid();
    };

    MetStabParserController.prototype.handleFormValid = function() {
      if (this.msc.isValid()) {
        return MetStabParserController.__super__.handleFormValid.call(this);
      }
    };

    MetStabParserController.prototype.handleValidationReturnSuccess = function(json) {
      MetStabParserController.__super__.handleValidationReturnSuccess.call(this, json);
      return this.msc.disableAllInputs();
    };

    MetStabParserController.prototype.showFileSelectPhase = function() {
      MetStabParserController.__super__.showFileSelectPhase.call(this);
      if (this.msc != null) {
        return this.msc.enableAllInputs();
      }
    };

    MetStabParserController.prototype.validateParseFile = function() {
      this.msc.updateModel();
      if (!!this.msc.isValid()) {
        this.additionalData = {
          inputParameters: this.msc.model.toJSON()
        };
        return MetStabParserController.__super__.validateParseFile.call(this);
      }
    };

    MetStabParserController.prototype.validateParseFile = function() {
      this.msc.updateModel();
      if (!!this.msc.isValid()) {
        this.additionalData = {
          inputParameters: this.msc.model.toJSON()
        };
        return MetStabParserController.__super__.validateParseFile.call(this);
      }
    };

    return MetStabParserController;

  })(BasicFileValidateAndSaveController);

}).call(this);
