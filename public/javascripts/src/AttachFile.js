(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.AttachFile = (function(superClass) {
    extend(AttachFile, superClass);

    function AttachFile() {
      return AttachFile.__super__.constructor.apply(this, arguments);
    }

    AttachFile.prototype.defaults = {
      fileType: "unassigned",
      fileValue: "",
      id: null,
      comments: null,
      required: false
    };

    AttachFile.prototype.validate = function(attrs) {
      var errors;
      errors = [];
      if (this.get('required') === true) {
        if (attrs.fileType === "unassigned" && attrs.fileValue === "") {
          errors.push({
            attribute: 'fileType',
            message: "Option must be selected and file must be uploaded"
          });
        }
      }
      if (attrs.fileType === "unassigned" && attrs.fileValue !== "") {
        errors.push({
          attribute: 'fileType',
          message: "Option must be selected"
        });
      }
      if (attrs.fileType !== "unassigned" && attrs.fileValue === "") {
        errors.push({
          attribute: 'fileType',
          message: "File must be uploaded"
        });
      }
      if (errors.length > 0) {
        return errors;
      } else {
        return null;
      }
    };

    return AttachFile;

  })(Backbone.Model);

  window.AttachFileList = (function(superClass) {
    extend(AttachFileList, superClass);

    function AttachFileList() {
      return AttachFileList.__super__.constructor.apply(this, arguments);
    }

    AttachFileList.prototype.model = AttachFile;

    return AttachFileList;

  })(Backbone.Collection);

  window.AttachFileController = (function(superClass) {
    extend(AttachFileController, superClass);

    function AttachFileController() {
      this.clear = bind(this.clear, this);
      this.updateModel = bind(this.updateModel, this);
      this.handleFileTypeChanged = bind(this.handleFileTypeChanged, this);
      this.handleFileUpload = bind(this.handleFileUpload, this);
      this.createNewFileChooser = bind(this.createNewFileChooser, this);
      this.render = bind(this.render, this);
      return AttachFileController.__super__.constructor.apply(this, arguments);
    }

    AttachFileController.prototype.template = _.template($("#AttachFileView").html());

    AttachFileController.prototype.tagName = "div";

    AttachFileController.prototype.events = {
      "change .bv_fileType": "handleFileTypeChanged",
      "click .bv_delete": "clear"
    };

    AttachFileController.prototype.initialize = function() {
      this.errorOwnerName = 'AttachFileController';
      this.setBindings();
      this.model.on("destroy", this.remove, this);
      this.model.on("removeFile", this.trigger('removeFile'));
      this.autoAddAttachFileModel = this.options.autoAddAttachFileModel;
      if (this.options.firstOptionName != null) {
        this.firstOptionName = this.options.firstOptionName;
      } else {
        this.firstOptionName = "Select File Type";
      }
      if (this.options.allowedFileTypes != null) {
        this.allowedFileTypes = this.options.allowedFileTypes;
      } else {
        this.allowedFileTypes = ['xls', 'rtf', 'pdf', 'txt', 'csv', 'sdf', 'xlsx', 'doc', 'docx', 'png', 'gif', 'jpg', 'ppt', 'pptx', 'pzf'];
      }
      if (this.options.fileTypeList != null) {
        return this.fileTypeList = new PickListList(this.options.fileTypeList);
      } else {
        return this.fileTypeList = new PickListList();
      }
    };

    AttachFileController.prototype.render = function() {
      var fileValue;
      $(this.el).empty();
      $(this.el).html(this.template(this.model.attributes));
      this.setUpFileTypeSelect();
      fileValue = this.model.get('fileValue');
      if (fileValue === null || fileValue === "" || fileValue === void 0) {
        this.createNewFileChooser();
      } else {
        this.$('.bv_uploadFile').html('<div style="margin-top:5px;margin-left:4px;"> <a href="' + window.conf.datafiles.downloadurl.prefix + fileValue + '">' + this.model.get('comments') + '</a></div>');
      }
      return this;
    };

    AttachFileController.prototype.createNewFileChooser = function() {
      this.lsFileChooser = new LSFileChooserController({
        el: this.$('.bv_uploadFile'),
        formId: 'fieldBlah',
        maxNumberOfFiles: 1,
        requiresValidation: false,
        url: UtilityFunctions.prototype.getFileServiceURL(),
        allowedFileTypes: this.allowedFileTypes,
        hideDelete: true
      });
      this.lsFileChooser.render();
      this.lsFileChooser.on('fileUploader:uploadComplete', this.handleFileUpload);
      return this;
    };

    AttachFileController.prototype.setUpFileTypeSelect = function() {
      return this.fileTypeListController = new PickListSelectController({
        el: this.$('.bv_fileType'),
        collection: this.fileTypeList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: this.firstOptionName
        }),
        selectedCode: this.model.get('fileType'),
        autoFetch: false
      });
    };

    AttachFileController.prototype.handleFileUpload = function(nameOnServer) {
      if (this.autoAddAttachFileModel) {
        this.$('.bv_delete').show();
        this.$('td.delete').hide();
      }
      this.model.set({
        fileValue: nameOnServer
      });
      this.trigger('fileUploaded');
      return this.trigger('amDirty');
    };

    AttachFileController.prototype.handleFileTypeChanged = function() {
      this.updateModel();
      return this.trigger('amDirty');
    };

    AttachFileController.prototype.updateModel = function() {
      var newModel;
      if (this.model.get('id') === null) {
        return this.model.set({
          fileType: this.$('.bv_fileType').val()
        });
      } else {
        newModel = new AttachFile(_.clone(this.model.attributes));
        newModel.unset('id');
        newModel.set({
          fileType: this.$('.bv_fileType').val()
        });
        this.model.set("ignored", true);
        this.$('.bv_fileInfoWrapper').hide();
        return this.trigger('addNewModel', newModel);
      }
    };

    AttachFileController.prototype.clear = function() {
      if (this.model.get('id') === null) {
        this.model.destroy();
      } else {
        this.model.set("ignored", true);
        this.$('.bv_fileInfoWrapper').hide();
      }
      this.trigger('removeFile');
      return this.trigger('amDirty');
    };

    return AttachFileController;

  })(AbstractFormController);

  window.AttachFileListController = (function(superClass) {
    extend(AttachFileListController, superClass);

    function AttachFileListController() {
      this.isValid = bind(this.isValid, this);
      this.checkIfNeedToAddNew = bind(this.checkIfNeedToAddNew, this);
      this.ensureValidCollectionLength = bind(this.ensureValidCollectionLength, this);
      this.addAttachFile = bind(this.addAttachFile, this);
      this.uploadNewAttachFile = bind(this.uploadNewAttachFile, this);
      this.render = bind(this.render, this);
      return AttachFileListController.__super__.constructor.apply(this, arguments);
    }

    AttachFileListController.prototype.template = _.template($("#AttachFileListView").html());

    AttachFileListController.prototype.events = {
      "click .bv_addFileInfo": "uploadNewAttachFile"
    };

    AttachFileListController.prototype.initialize = function() {
      var newModel;
      if (this.options.required != null) {
        this.required = this.options.required;
      } else {
        this.required = false;
      }
      if (this.collection == null) {
        this.collection = new AttachFileList();
        newModel = new AttachFile;
        this.collection.add(newModel);
      }
      if (this.options.autoAddAttachFileModel != null) {
        this.autoAddAttachFileModel = this.options.autoAddAttachFileModel;
      } else {
        this.autoAddAttachFileModel = true;
      }
      if (this.autoAddAttachFileModel) {
        this.collection.on('removeFile', this.ensureValidCollectionLength);
      }
      if (this.options.allowedFileTypes != null) {
        this.allowedFileTypes = this.options.allowedFileTypes;
      } else {
        this.allowedFileTypes = ['xls', 'rtf', 'pdf', 'txt', 'csv', 'sdf', 'xlsx', 'doc', 'docx', 'png', 'gif', 'jpg', 'ppt', 'pptx', 'pzf'];
      }
      if (this.options.fileTypeList != null) {
        return this.fileTypeList = this.options.fileTypeList;
      } else {
        return this.fileTypeList = new PickListList();
      }
    };

    AttachFileListController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      this.collection.each((function(_this) {
        return function(fileInfo) {
          return _this.addAttachFile(fileInfo);
        };
      })(this));
      if (this.collection.length === 0) {
        this.uploadNewAttachFile();
      }
      this.trigger('renderComplete');
      return this;
    };

    AttachFileListController.prototype.uploadNewAttachFile = function() {
      var newModel;
      newModel = new AttachFile;
      this.collection.add(newModel);
      this.addAttachFile(newModel);
      return this.trigger('amDirty');
    };

    AttachFileListController.prototype.addAttachFile = function(fileInfo) {
      var afc;
      fileInfo.set({
        required: this.required
      });
      afc = new AttachFileController({
        model: fileInfo,
        autoAddAttachFileModel: this.autoAddAttachFileModel,
        firstOptionName: this.options.firstOptionName,
        allowedFileTypes: this.allowedFileTypes,
        fileTypeList: this.fileTypeList
      });
      this.listenTo(afc, 'fileUploaded', this.checkIfNeedToAddNew);
      this.listenTo(afc, 'removeFile', this.ensureValidCollectionLength);
      afc.on('addNewModel', (function(_this) {
        return function(newModel) {
          _this.collection.add(newModel);
          return _this.addAttachFile(newModel);
        };
      })(this));
      afc.on('amDirty', (function(_this) {
        return function() {
          return _this.trigger('amDirty');
        };
      })(this));
      return this.$('.bv_attachFileInfo').append(afc.render().el);
    };

    AttachFileListController.prototype.ensureValidCollectionLength = function() {
      var notIgnoredFiles;
      notIgnoredFiles = this.collection.filter(function(model) {
        return model.get('ignored') === false || model.get('ignored') === void 0;
      });
      if (notIgnoredFiles.length === 0) {
        return this.uploadNewAttachFile();
      }
    };

    AttachFileListController.prototype.checkIfNeedToAddNew = function() {
      if (this.autoAddAttachFileModel) {
        return this.uploadNewAttachFile();
      }
    };

    AttachFileListController.prototype.isValid = function() {
      var validCheck;
      validCheck = true;
      this.collection.each(function(model) {
        var validModel;
        validModel = model.isValid();
        if (validModel === false) {
          return validCheck = false;
        }
      });
      return validCheck;
    };

    return AttachFileListController;

  })(Backbone.View);

}).call(this);
