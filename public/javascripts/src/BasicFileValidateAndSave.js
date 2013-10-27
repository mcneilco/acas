(function() {
  var _ref,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
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
      this.handleReportFileRemoved = __bind(this.handleReportFileRemoved, this);
      this.handleReportFileUploaded = __bind(this.handleReportFileUploaded, this);
      this.handleParseFileRemoved = __bind(this.handleParseFileRemoved, this);
      this.handleParseFileUploaded = __bind(this.handleParseFileUploaded, this);
      this.render = __bind(this.render, this);      _ref = BasicFileValidateAndSaveController.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    BasicFileValidateAndSaveController.prototype.notificationController = null;

    BasicFileValidateAndSaveController.prototype.parseFileController = null;

    BasicFileValidateAndSaveController.prototype.parseFileNameOnServer = "";

    BasicFileValidateAndSaveController.prototype.parseFileUploaded = false;

    BasicFileValidateAndSaveController.prototype.filePassedValidation = false;

    BasicFileValidateAndSaveController.prototype.reportFileNameOnServer = null;

    BasicFileValidateAndSaveController.prototype.loadReportFile = false;

    BasicFileValidateAndSaveController.prototype.filePath = "serverOnlyModules/blueimp-file-upload-node/public/files/";

    BasicFileValidateAndSaveController.prototype.additionalData = {
      experimentId: 1234,
      otherparam: "fred"
    };

    BasicFileValidateAndSaveController.prototype.template = _.template($("#BasicFileValidateAndSaveView").html());

    BasicFileValidateAndSaveController.prototype.events = {
      'click .bv_next': 'validateParseFile',
      'click .bv_save': 'parseAndSave',
      'click .bv_back': 'backToUpload',
      'click .bv_loadAnother': 'loadAnother'
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
        url: "http://" + window.conf.host + ":" + window.conf.service.file.port,
        fieldIsRequired: false,
        allowedFileTypes: ['xls', 'xlsx', 'csv']
      });
      this.parseFileController.on('fileInput:uploadComplete', this.handleParseFileUploaded);
      this.parseFileController.on('fileInput:removedFile', this.handleParseFileRemoved);
      this.parseFileController.render();
      if (this.loadReportFile) {
        this.reportFileController = new LSFileInputController({
          el: this.$('.bv_reportFile'),
          inputTitle: '',
          url: "http://" + window.conf.host + ":" + window.conf.service.file.port,
          fieldIsRequired: false,
          allowedFileTypes: ['xls', 'rtf', 'pdf', 'txt', 'csv', 'sdf', 'xlsx', 'doc', 'docx', 'png', 'gif', 'jpg', 'ppt', 'pptx', 'pzf']
        });
        this.reportFileController.on('fileInput:uploadComplete', this.handleReportFileUploaded);
        this.reportFileController.on('fileInput:removedFile', this.handleReportFileRemoved);
        this.reportFileController.render();
        this.$('.bv_reportFileWrapper').show();
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

    BasicFileValidateAndSaveController.prototype.validateParseFile = function() {
      var _this = this;

      if (this.parseFileUploaded && !this.$(".bv_next").attr('disabled')) {
        this.notificationController.clearAllNotificiations();
        this.$('.bv_validateStatusDropDown').modal({
          backdrop: "static"
        });
        this.$('.bv_validateStatusDropDown').modal("show");
        return $.ajax({
          type: 'POST',
          url: this.fileProcessorURL,
          data: this.prepareDataToPost(true),
          success: this.handleValidationReturnSuccess,
          error: function(err) {
            return _this.$('.bv_validateStatusDropDown').modal("hide");
          },
          dataType: 'json'
        });
      }
    };

    BasicFileValidateAndSaveController.prototype.parseAndSave = function() {
      if (this.parseFileUploaded && this.filePassedValidation) {
        this.notificationController.clearAllNotificiations();
        this.$('.bv_saveStatusDropDown').modal({
          backdrop: "static"
        });
        this.$('.bv_saveStatusDropDown').modal("show");
        return $.ajax({
          type: 'POST',
          url: this.fileProcessorURL,
          data: this.prepareDataToPost(false),
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
        dryRunMode: dryRun,
        user: user
      };
      $.extend(data, this.additionalData);
      return data;
    };

    BasicFileValidateAndSaveController.prototype.handleValidationReturnSuccess = function(json) {
      var summaryStr, _ref1;

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
      if (((_ref1 = json.results) != null ? _ref1.htmlSummary : void 0) != null) {
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
      this.showFileUploadCompletePhase();
      this.$('.bv_resultStatus').html(summaryStr);
      this.$('.bv_saveStatusDropDown').modal("hide");
      return this.trigger('amClean');
    };

    BasicFileValidateAndSaveController.prototype.backToUpload = function() {
      return this.showFileSelectPhase();
    };

    BasicFileValidateAndSaveController.prototype.loadAnother = function() {
      var fn;

      this.showFileSelectPhase();
      fn = function() {
        return this.$('.bv_deleteFile').click();
      };
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
      var csvRows, headCells, r, rowCells, val, _i, _j, _k, _len, _len1, _ref1;

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
          for (r = _j = 1, _ref1 = csvRows.length - 2; 1 <= _ref1 ? _j <= _ref1 : _j >= _ref1; r = 1 <= _ref1 ? ++_j : --_j) {
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

    return BasicFileValidateAndSaveController;

  })(Backbone.View);

}).call(this);
