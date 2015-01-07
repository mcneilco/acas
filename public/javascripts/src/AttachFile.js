(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.AttachFile = (function(_super) {
    __extends(AttachFile, _super);

    function AttachFile() {
      return AttachFile.__super__.constructor.apply(this, arguments);
    }

    AttachFile.prototype.defaults = {
      fileType: "unassigned",
      nameOnServer: ""
    };

    AttachFile.prototype.validate = function(attrs) {
      var errors;
      console.log(attrs);
      errors = [];
      if (attrs.fileType === "unassigned" && attrs.nameOnServer !== "") {
        errors.push({
          attribute: 'fileType',
          message: "Read name must be assigned"
        });
      }
      console.log("validating attach file model");
      console.log(attrs.nameOnServer);
      console.log(errors);
      if (errors.length > 0) {
        return errors;
      } else {
        return null;
      }
    };

    return AttachFile;

  })(Backbone.Model);

  window.AttachFileController = (function(_super) {
    __extends(AttachFileController, _super);

    function AttachFileController() {
      this.clear = __bind(this.clear, this);
      this.updateModel = __bind(this.updateModel, this);
      this.handleFileTypeChanged = __bind(this.handleFileTypeChanged, this);
      this.handleFileUpload = __bind(this.handleFileUpload, this);
      this.render = __bind(this.render, this);
      return AttachFileController.__super__.constructor.apply(this, arguments);
    }

    AttachFileController.prototype.template = _.template($("#AttachFileView").html());

    AttachFileController.prototype.tagName = "div";

    AttachFileController.prototype.className = "form-inline";

    AttachFileController.prototype.events = {
      "change .bv_fileType": "handleFileTypeChanged"
    };

    AttachFileController.prototype.initialize = function() {};

    AttachFileController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template(this.model.attributes));
      this.setUpFileTypeSelect();
      this.lsFileChooser = new LSFileChooserController({
        el: this.$('.bv_uploadFile'),
        formId: 'fieldBlah',
        maxNumberOfFiles: 1,
        requiresValidation: false,
        url: UtilityFunctions.prototype.getFileServiceURL(),
        allowedFileTypes: ['xls', 'rtf', 'pdf', 'txt', 'csv', 'sdf', 'xlsx', 'doc', 'docx', 'png', 'gif', 'jpg', 'ppt', 'pptx', 'pzf', 'zip'],
        hideDelete: true
      });
      this.lsFileChooser.render();
      this.lsFileChooser.on('fileUploader:uploadComplete', this.handleFileUpload);
      return this;
    };

    AttachFileController.prototype.setUpFileTypeSelect = function() {
      this.fileTypeList = new PickListList();
      this.fileTypeList.url = "/api/dataDict/analytical method/file type";
      return this.fileTypeList = new PickListSelectController({
        el: this.$('.bv_fileType'),
        collection: this.fileTypeList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select File Type"
        }),
        selectedCode: this.model.get('fileType')
      });
    };

    AttachFileController.prototype.handleFileUpload = function(nameOnServer) {
      this.$('.bv_delete').show();
      this.model.set({
        nameOnServer: nameOnServer
      });
      console.log(this.model.get('nameOnServer'));
      this.trigger('fileUploaded');
      return this.trigger('amDirty');
    };

    AttachFileController.prototype.handleFileTypeChanged = function() {
      return this.updateModel();
    };

    AttachFileController.prototype.updateModel = function() {
      return this.model.set({
        fileType: this.$('.bv_fileType').val()
      });
    };

    AttachFileController.prototype.clear = function() {
      console.log("clear");
      return this.model.destroy();
    };

    return AttachFileController;

  })(Backbone.View);

}).call(this);
