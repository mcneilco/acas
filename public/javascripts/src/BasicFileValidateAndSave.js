(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.BasicFileValidateAndSaveController = (function(_super) {
    __extends(BasicFileValidateAndSaveController, _super);

    function BasicFileValidateAndSaveController() {
      this.handleFormValid = __bind(this.handleFormValid, this);
      this.handleFormInvalid = __bind(this.handleFormInvalid, this);
      this.loadAnother = __bind(this.loadAnother, this);
      this.backToUpload = __bind(this.backToUpload, this);
      this.handleSaveReturnSuccess = __bind(this.handleSaveReturnSuccess, this);
      this.handleValidationReturnSuccess = __bind(this.handleValidationReturnSuccess, this);
      this.parseAndSave = __bind(this.parseAndSave, this);
      this.validateParseFile = __bind(this.validateParseFile, this);
      this.handleImagesFileRemoved = __bind(this.handleImagesFileRemoved, this);
      this.handleImagesFileUploaded = __bind(this.handleImagesFileUploaded, this);
      this.handleReportFileRemoved = __bind(this.handleReportFileRemoved, this);
      this.handleReportFileUploaded = __bind(this.handleReportFileUploaded, this);
      this.handleParseFileRemoved = __bind(this.handleParseFileRemoved, this);
      this.handleParseFileUploaded = __bind(this.handleParseFileUploaded, this);
      this.render = __bind(this.render, this);
      return BasicFileValidateAndSaveController.__super__.constructor.apply(this, arguments);
    }

    BasicFileValidateAndSaveController.prototype.notificationController = null;

    BasicFileValidateAndSaveController.prototype.parseFileController = null;

    BasicFileValidateAndSaveController.prototype.parseFileNameOnServer = "";

    BasicFileValidateAndSaveController.prototype.parseFileUploaded = false;

    BasicFileValidateAndSaveController.prototype.filePassedValidation = false;

    BasicFileValidateAndSaveController.prototype.reportFileNameOnServer = null;

    BasicFileValidateAndSaveController.prototype.loadReportFile = false;

    BasicFileValidateAndSaveController.prototype.imagesFileNameOnServer = null;

    BasicFileValidateAndSaveController.prototype.loadImagesFile = false;

    BasicFileValidateAndSaveController.prototype.filePath = "";

    BasicFileValidateAndSaveController.prototype.additionalData = {
      experimentId: 1234,
      otherparam: "fred"
    };

    BasicFileValidateAndSaveController.prototype.allowedFileTypes = ['xls', 'xlsx', 'csv'];

    BasicFileValidateAndSaveController.prototype.maxFileSize = 200000000;

    BasicFileValidateAndSaveController.prototype.attachReportFile = false;

    BasicFileValidateAndSaveController.prototype.attachImagesFile = false;

    BasicFileValidateAndSaveController.prototype.template = _.template($("#BasicFileValidateAndSaveView").html());

    BasicFileValidateAndSaveController.prototype.events = {
      'click .bv_next': 'validateParseFile',
      'click .bv_save': 'parseAndSave',
      'click .bv_back': 'backToUpload',
      'click .bv_loadAnother': 'loadAnother',
      'click .bv_attachReportFile': 'handleAttachReportFileChanged',
      'click .bv_attachImagesFile': 'handleAttachImagesFileChanged'
    };

    BasicFileValidateAndSaveController.prototype.initialize = function() {
      $(this.el).html(this.template());
      this.notificationController = new LSNotificationController({
        el: this.$('.bv_notifications'),
        showPreview: false
      });
      this.parseFileController = new LSFileInputController({
        el: this.$('.bv_parseFile'),
        inputTitle: '',
        url: UtilityFunctions.prototype.getFileServiceURL(),
        fieldIsRequired: false,
        allowedFileTypes: this.allowedFileTypes,
        maxFileSize: this.maxFileSize
      });
      this.parseFileController.on('fileInput:uploadComplete', this.handleParseFileUploaded);
      this.parseFileController.on('fileInput:removedFile', this.handleParseFileRemoved);
      this.parseFileController.render();
      if (this.loadReportFile) {
        this.reportFileController = new LSFileInputController({
          el: this.$('.bv_reportFile'),
          inputTitle: '',
          url: UtilityFunctions.prototype.getFileServiceURL(),
          fieldIsRequired: false,
          allowedFileTypes: ['xls', 'rtf', 'pdf', 'txt', 'csv', 'sdf', 'xlsx', 'doc', 'docx', 'png', 'gif', 'jpg', 'ppt', 'pptx', 'pzf']
        });
        this.reportFileController.on('fileInput:uploadComplete', this.handleReportFileUploaded);
        this.reportFileController.on('fileInput:removedFile', this.handleReportFileRemoved);
        this.reportFileController.render();
        this.handleAttachReportFileChanged();
      }
      if (this.loadImagesFile) {
        this.imagesFileController = new LSFileInputController({
          el: this.$('.bv_imagesFile'),
          inputTitle: '',
          url: UtilityFunctions.prototype.getFileServiceURL(),
          fieldIsRequired: false,
          allowedFileTypes: ['zip']
        });
        this.imagesFileController.on('fileInput:uploadComplete', this.handleImagesFileUploaded);
        this.imagesFileController.on('fileInput:removedFile', this.handleImagesFileRemoved);
        this.imagesFileController.render();
        this.handleAttachImagesFileChanged();
      }
      return this.showFileSelectPhase();
    };

    BasicFileValidateAndSaveController.prototype.render = function() {
      if (!this.parseFileUploaded) {
        this.handleFormInvalid();
      }
      return this;
    };

    BasicFileValidateAndSaveController.prototype.handleParseFileUploaded = function(fileName) {
      this.parseFileUploaded = true;
      this.parseFileNameOnServer = this.filePath + fileName;
      this.handleFormValid();
      return this.trigger('amDirty');
    };

    BasicFileValidateAndSaveController.prototype.handleParseFileRemoved = function() {
      this.parseFileUploaded = false;
      this.parseFileNameOnServer = "";
      this.notificationController.clearAllNotificiations();
      return this.handleFormInvalid();
    };

    BasicFileValidateAndSaveController.prototype.handleReportFileUploaded = function(fileName) {
      this.reportFileNameOnServer = this.filePath + fileName;
      return this.trigger('amDirty');
    };

    BasicFileValidateAndSaveController.prototype.handleReportFileRemoved = function() {
      return this.reportFileNameOnServer = null;
    };

    BasicFileValidateAndSaveController.prototype.handleImagesFileUploaded = function(fileName) {
      this.imagesFileNameOnServer = this.filePath + fileName;
      return this.trigger('amDirty');
    };

    BasicFileValidateAndSaveController.prototype.handleImagesFileRemoved = function() {
      return this.imagesFileNameOnServer = null;
    };

    BasicFileValidateAndSaveController.prototype.validateParseFile = function() {
      var dataToPost;
      if (this.parseFileUploaded && !this.$(".bv_next").attr('disabled')) {
        this.notificationController.clearAllNotificiations();
        this.$('.bv_validateStatusDropDown').modal({
          backdrop: "static"
        });
        this.$('.bv_validateStatusDropDown').modal("show");
        dataToPost = this.prepareDataToPost(true);
        return $.ajax({
          type: 'POST',
          url: this.fileProcessorURL,
          data: dataToPost,
          success: this.handleValidationReturnSuccess,
          error: (function(_this) {
            return function(err) {
              return _this.$('.bv_validateStatusDropDown').modal("hide");
            };
          })(this),
          dataType: 'json'
        });
      }
    };

    BasicFileValidateAndSaveController.prototype.parseAndSave = function() {
      var dataToPost;
      if (this.parseFileUploaded && this.filePassedValidation) {
        this.notificationController.clearAllNotificiations();
        this.$('.bv_saveStatusDropDown').modal({
          backdrop: "static"
        });
        this.$('.bv_saveStatusDropDown').modal("show");
        dataToPost = this.prepareDataToPost(false);
        return $.ajax({
          type: 'POST',
          url: this.fileProcessorURL,
          data: dataToPost,
          success: this.handleSaveReturnSuccess,
          dataType: 'json'
        });
      }
    };

    BasicFileValidateAndSaveController.prototype.prepareDataToPost = function(dryRun) {
      var data, user;
      user = this.userName;
      if (user == null) {
        user = window.AppLaunchParams.loginUserName;
      }
      data = {
        fileToParse: this.parseFileNameOnServer,
        reportFile: this.reportFileNameOnServer,
        imagesFile: this.imagesFileNameOnServer,
        dryRunMode: dryRun,
        user: user
      };
      $.extend(data, this.additionalData);
      return data;
    };

    BasicFileValidateAndSaveController.prototype.handleValidationReturnSuccess = function(json) {
      var summaryStr, _ref;
      summaryStr = "Validation Results: ";
      if (!json.hasError) {
        this.filePassedValidation = true;
        this.parseFileController.lsFileChooser.filePassedServerValidation();
        summaryStr += "Success ";
        if (json.hasWarning) {
          summaryStr += "but with warnings";
        }
      } else {
        this.filePassedValidation = false;
        this.parseFileController.lsFileChooser.fileFailedServerValidation();
        summaryStr += "Failed due to errors ";
        this.handleFormInvalid();
      }
      this.showFileUploadPhase();
      this.$('.bv_resultStatus').html(summaryStr);
      this.notificationController.addNotifications(this.errorOwnerName, json.errorMessages);
      if (((_ref = json.results) != null ? _ref.htmlSummary : void 0) != null) {
        this.$('.bv_htmlSummary').html(json.results.htmlSummary);
      }
      this.$('.bv_validateStatusDropDown').modal("hide");
      if (json.results.csvDataPreview != null) {
        return this.showCSVPreview(json.results.csvDataPreview);
      }
    };

    BasicFileValidateAndSaveController.prototype.handleSaveReturnSuccess = function(json) {
      var summaryStr;
      summaryStr = "Upload Results: ";
      if (!json.hasError) {
        summaryStr += "Success ";
      } else {
        summaryStr += "Failed due to errors ";
      }
      this.notificationController.addNotifications(this.errorOwnerName, json.errorMessages);
      this.$('.bv_htmlSummary').html(json.results.htmlSummary);
      this.newExperimentCode = json.results.experimentCode;
      this.showFileUploadCompletePhase();
      this.$('.bv_resultStatus').html(summaryStr);
      this.$('.bv_saveStatusDropDown').modal("hide");
      return this.trigger('amClean');
    };

    BasicFileValidateAndSaveController.prototype.backToUpload = function() {
      return this.showFileSelectPhase();
    };

    BasicFileValidateAndSaveController.prototype.loadAnother = function() {
      this.showFileSelectPhase();
      return setTimeout(fn, 200);
    };

    BasicFileValidateAndSaveController.prototype.showFileSelectPhase = function() {
      this.$('.bv_resultStatus').html("");
      this.$('.bv_htmlSummary').hide();
      this.$('.bv_htmlSummary').html('');
      this.$('.bv_fileUploadWrapper').show();
      this.$('.bv_nextControlContainer').show();
      this.$('.bv_saveControlContainer').hide();
      this.$('.bv_completeControlContainer').hide();
      this.$('.bv_notifications').hide();
      return this.$('.bv_csvPreviewContainer').hide();
    };

    BasicFileValidateAndSaveController.prototype.handleAttachReportFileChanged = function() {
      var attachReportFile;
      attachReportFile = this.$('.bv_attachReportFile').is(":checked");
      if (attachReportFile) {
        return this.$('.bv_reportFileWrapper').show();
      } else {
        this.handleReportFileRemoved();
        this.$('.bv_reportFileWrapper').hide();
        return this.reportFileController.render();
      }
    };

    BasicFileValidateAndSaveController.prototype.handleAttachImagesFileChanged = function() {
      var attachImagesFile;
      attachImagesFile = this.$('.bv_attachImagesFile').is(":checked");
      if (attachImagesFile) {
        return this.$('.bv_imagesFileWrapper').show();
      } else {
        this.handleImagesFileRemoved();
        this.$('.bv_imagesFileWrapper').hide();
        return this.imagesFileController.render();
      }
    };

    BasicFileValidateAndSaveController.prototype.showFileUploadPhase = function() {
      this.$('.bv_htmlSummary').show();
      this.$('.bv_fileUploadWrapper').hide();
      this.$('.bv_nextControlContainer').hide();
      this.$('.bv_saveControlContainer').show();
      this.$('.bv_completeControlContainer').hide();
      return this.$('.bv_notifications').show();
    };

    BasicFileValidateAndSaveController.prototype.showFileUploadCompletePhase = function() {
      this.$('.bv_htmlSummary').show();
      this.$('.bv_csvPreviewContainer').hide();
      this.$('.bv_fileUploadWrapper').hide();
      this.$('.bv_nextControlContainer').hide();
      this.$('.bv_saveControlContainer').hide();
      this.$('.bv_completeControlContainer').show();
      return this.$('.bv_notifications').show();
    };

    BasicFileValidateAndSaveController.prototype.handleFormInvalid = function() {
      this.$(".bv_next").attr('disabled', 'disabled');
      this.$(".bv_save").attr('disabled', 'disabled');
      return this.$('.bv_notifications').show();
    };

    BasicFileValidateAndSaveController.prototype.handleFormValid = function() {
      this.$(".bv_next").removeAttr('disabled');
      return this.$(".bv_save").removeAttr('disabled');
    };

    BasicFileValidateAndSaveController.prototype.showCSVPreview = function(csv) {
      var csvRows, headCells, r, rowCells, val, _i, _j, _k, _len, _len1, _ref;
      this.$('.csvPreviewTHead').empty();
      this.$('.csvPreviewTBody').empty();
      csvRows = csv.split('\n');
      if (csvRows.length > 1) {
        headCells = csvRows[0].split(',');
        if (headCells.length > 1) {
          this.$('.csvPreviewTHead').append("<tr></tr>");
          for (_i = 0, _len = headCells.length; _i < _len; _i++) {
            val = headCells[_i];
            this.$('.csvPreviewTHead tr').append("<th>" + val + "</th>");
          }
          for (r = _j = 1, _ref = csvRows.length - 2; 1 <= _ref ? _j <= _ref : _j >= _ref; r = 1 <= _ref ? ++_j : --_j) {
            this.$('.csvPreviewTBody').append("<tr></tr>");
            rowCells = csvRows[r].split(',');
            for (_k = 0, _len1 = rowCells.length; _k < _len1; _k++) {
              val = rowCells[_k];
              this.$('.csvPreviewTBody tr:last').append("<td>" + val + "</td>");
            }
          }
          return this.$('.bv_csvPreviewContainer').show();
        }
      }
    };

    BasicFileValidateAndSaveController.prototype.getNewExperimentCode = function() {
      return this.newExperimentCode;
    };

    return BasicFileValidateAndSaveController;

  })(Backbone.View);

}).call(this);
