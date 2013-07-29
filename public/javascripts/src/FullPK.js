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
      if (attrs.protocolName === "Select Protocol") {
        errors.push({
          attribute: 'protocolName',
          message: "Protocol Name must be provided"
        });
      }
      if (attrs.experimentName === "") {
        errors.push({
          attribute: 'experimentName',
          message: "Experiment Name must be provided"
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
      if (attrs.inLifeNotebook === "") {
        errors.push({
          attribute: 'inLifeNotebook',
          message: "inLifeNotebook must be provided"
        });
      }
      if (attrs.project === "unassigned") {
        errors.push({
          attribute: 'project',
          message: "Project must be provided"
        });
      }
      if (attrs.bioavailability === "") {
        errors.push({
          attribute: 'bioavailability',
          message: "Bioavailability must be provided"
        });
      }
      if (attrs.aucType === "") {
        errors.push({
          attribute: 'aucType',
          message: "AUC Type must be provided"
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
      'change .bv_protocolName': "attributeChanged",
      'change .bv_experimentName': "attributeChanged",
      'change .bv_scientist': "attributeChanged",
      'change .bv_notebook': "attributeChanged",
      'change .bv_inLifeNotebook': "attributeChanged",
      'change .bv_project': "attributeChanged",
      'change .bv_bioavailability': "attributeChanged",
      'change .bv_aucType': "attributeChanged",
      'change .bv_assayDate': "attributeChanged"
    };

    FullPKController.prototype.initialize = function() {
      this.errorOwnerName = 'FullPKController';
      $(this.el).html(this.template());
      this.setBindings();
      this.setupProjectSelect();
      return this.setupProtocolSelect();
    };

    FullPKController.prototype.render = function() {
      var date;

      this.$('.bv_assayDate').datepicker();
      this.$('.bv_assayDate').datepicker("option", "dateFormat", "yy-mm-dd");
      if (this.model.get('assayDate') !== null) {
        date = new Date(this.model.get('assayDate'));
        this.$('.bv_assayDate').val(date.getFullYear() + '-' + date.getMonth() + '-' + date.getDate());
      }
      return this;
    };

    FullPKController.prototype.attributeChanged = function() {
      this.trigger('amDirty');
      return this.updateModel();
    };

    FullPKController.prototype.updateModel = function() {
      this.model.set({
        protocolName: this.$('.bv_protocolName').find(":selected").text(),
        experimentName: this.getTrimmedInput('.bv_experimentName'),
        scientist: this.getTrimmedInput('.bv_scientist'),
        notebook: this.getTrimmedInput('.bv_notebook'),
        inLifeNotebook: this.getTrimmedInput('.bv_inLifeNotebook'),
        project: this.getTrimmedInput('.bv_project'),
        bioavailability: this.getTrimmedInput('.bv_bioavailability'),
        aucType: this.getTrimmedInput('.bv_aucType'),
        assayDate: this.convertYMDDateToMs(this.getTrimmedInput('.bv_assayDate'))
      });
      return this.trigger('amDirty');
    };

    FullPKController.prototype.setupProjectSelect = function() {
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

    FullPKController.prototype.setupProtocolSelect = function() {
      this.protocolList = new PickListList();
      this.protocolList.url = "api/protocolCodes/filter/PK";
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

    FullPKController.prototype.disableAllInputs = function() {
      this.$('input').attr('disabled', 'disabled');
      return this.$('select').attr('disabled', 'disabled');
    };

    FullPKController.prototype.enableAllInputs = function() {
      return this.$('input').removeAttr('disabled');
    };

    return FullPKController;

  })(AbstractFormController);

  window.FullPKParserController = (function(_super) {
    __extends(FullPKParserController, _super);

    function FullPKParserController() {
      this.validateParseFile = __bind(this.validateParseFile, this);
      this.validateParseFile = __bind(this.validateParseFile, this);
      this.handleValidationReturnSuccess = __bind(this.handleValidationReturnSuccess, this);
      this.handleFPKFormInvalid = __bind(this.handleFPKFormInvalid, this);
      this.handleFPKFormValid = __bind(this.handleFPKFormValid, this);      _ref2 = FullPKParserController.__super__.constructor.apply(this, arguments);
      return _ref2;
    }

    FullPKParserController.prototype.initialize = function() {
      var _this = this;

      this.fileProcessorURL = "/api/fullPKParser";
      this.errorOwnerName = 'FullPKParser';
      this.loadReportFile = true;
      FullPKParserController.__super__.initialize.call(this);
      this.$('.bv_moduleTitle').html('Full PK Experiment Loader');
      this.fpkc = new FullPKController({
        model: new FullPK(),
        el: this.$('.bv_additionalValuesForm')
      });
      this.fpkc.on('valid', this.handleFPKFormValid);
      this.fpkc.on('invalid', this.handleFPKFormInvalid);
      this.fpkc.on('notifyError', this.notificationController.addNotification);
      this.fpkc.on('clearErrors', this.notificationController.clearAllNotificiations);
      this.fpkc.on('amDirty', function() {
        return _this.trigger('amDirty');
      });
      return this.fpkc.render();
    };

    FullPKParserController.prototype.handleFPKFormValid = function() {
      if (this.parseFileUploaded) {
        return this.handleFormValid();
      }
    };

    FullPKParserController.prototype.handleFPKFormInvalid = function() {
      return this.handleFormInvalid();
    };

    FullPKParserController.prototype.handleFormValid = function() {
      if (this.fpkc.isValid()) {
        return FullPKParserController.__super__.handleFormValid.call(this);
      }
    };

    FullPKParserController.prototype.handleValidationReturnSuccess = function(json) {
      FullPKParserController.__super__.handleValidationReturnSuccess.call(this, json);
      return this.fpkc.disableAllInputs();
    };

    FullPKParserController.prototype.showFileSelectPhase = function() {
      FullPKParserController.__super__.showFileSelectPhase.call(this);
      if (this.fpkc != null) {
        return this.fpkc.enableAllInputs();
      }
    };

    FullPKParserController.prototype.validateParseFile = function() {
      this.fpkc.updateModel();
      if (!!this.fpkc.isValid()) {
        this.additionalData = {
          inputParameters: this.fpkc.model.toJSON()
        };
        return FullPKParserController.__super__.validateParseFile.call(this);
      }
    };

    FullPKParserController.prototype.validateParseFile = function() {
      this.fpkc.updateModel();
      if (!!this.fpkc.isValid()) {
        this.additionalData = {
          inputParameters: this.fpkc.model.toJSON()
        };
        return FullPKParserController.__super__.validateParseFile.call(this);
      }
    };

    return FullPKParserController;

  })(BasicFileValidateAndSaveController);

}).call(this);
