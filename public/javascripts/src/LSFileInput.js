(function() {
  var _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.LSFileInputController = (function(_super) {
    __extends(LSFileInputController, _super);

    function LSFileInputController() {
      _ref = LSFileInputController.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    LSFileInputController.prototype.fieldIsRequired = true;

    LSFileInputController.prototype.inputTitle = "A title should go here";

    LSFileInputController.prototype.lsFileChooser = null;

    LSFileInputController.prototype.requiresValidation = false;

    LSFileInputController.prototype.maxNumberOfFiles = 1;

    LSFileInputController.prototype.defaultMessage = "Drop a file here to upload it";

    LSFileInputController.prototype.dragOverMessage = "Drop the file here to upload it";

    LSFileInputController.prototype.nameOnServer = "";

    LSFileInputController.prototype.allowedFileTypes = ['xls', 'rtf', 'pdf', 'txt', 'csv', 'sdf', 'xlsx', 'doc', 'docx', 'png', 'gif', 'jpg'];

    LSFileInputController.prototype.initialize = function() {
      _.bindAll(this, 'render', 'handleFileChooserUploadComplete', 'handleFileChooserUploadFailed', 'handleFileChooserRemovedFile');
      if (this.options.inputTitle != null) {
        this.inputTitle = this.options.inputTitle;
      }
      if (this.options.fieldIsRequired != null) {
        this.fieldIsRequired = this.options.fieldIsRequired;
      }
      if (this.options.requiresValidation != null) {
        this.requiresValidation = this.options.requiresValidation;
      }
      if (this.options.maxNumberOfFiles != null) {
        this.maxNumberOfFiles = this.options.maxNumberOfFiles;
      }
      if (this.options.url != null) {
        this.url = this.options.url;
      }
      if (this.options.defaultMessage != null) {
        this.defaultMessage = this.options.defaultMessage;
      }
      if (this.options.dragOverMessage != null) {
        this.dragOverMessage = this.options.dragOverMessage;
      }
      if (this.options.allowedFileTypes != null) {
        return this.allowedFileTypes = this.options.allowedFileTypes;
      }
    };

    LSFileInputController.prototype.handleFileChooserUploadComplete = function(nameOnServer) {
      this.nameOnServer = nameOnServer;
      return this.trigger('fileInput:uploadComplete', nameOnServer);
    };

    LSFileInputController.prototype.handleFileChooserUploadFailed = function() {
      return this.$('.bv_status').addClass('icon-exclamation-sign');
    };

    LSFileInputController.prototype.handleFileChooserRemovedFile = function() {
      return this.trigger('fileInput:removedFile');
    };

    LSFileInputController.prototype.render = function() {
      var self, template;

      self = this;
      $(this.el).html("");
      template = _.template($("#LSFileInputView").html(), {
        inputTitle: this.inputTitle,
        fieldIsRequired: this.fieldIsRequired
      });
      $(this.el).html(template);
      this.lsFileChooser = new LSFileChooserController({
        el: this.$('.bv_fileChooserContainer'),
        formId: 'fieldBlah',
        maxNumberOfFiles: this.maxNumberOfFiles,
        requiresValidation: this.requiresValidation,
        url: this.url,
        defaultMessage: this.defaultMessage,
        dragOverMessage: this.dragOverMessage,
        allowedFileTypes: this.allowedFileTypes
      });
      this.lsFileChooser.render();
      this.lsFileChooser.on('fileUploader:uploadComplete', this.handleFileChooserUploadComplete);
      this.lsFileChooser.on('fileUploader:uploadFailed', this.handleFileChooserUploadFailed);
      this.lsFileChooser.on('fileUploader:removedFile', this.handleFileChooserRemovedFile);
      return this;
    };

    return LSFileInputController;

  })(Backbone.View);

}).call(this);
