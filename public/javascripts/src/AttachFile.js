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
      fileValue: ""
    };

    AttachFile.prototype.validate = function(attrs) {
      var errors;
      console.log("validate");
      errors = [];
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
      console.log("validating attach file model");
      console.log(attrs.fileValue);
      console.log(errors);
      if (errors.length > 0) {
        return errors;
      } else {
        return null;
      }
    };

    return AttachFile;

  })(Backbone.Model);

  window.AttachFileList = (function(_super) {
    __extends(AttachFileList, _super);

    function AttachFileList() {
      return AttachFileList.__super__.constructor.apply(this, arguments);
    }

    AttachFileList.prototype.model = AttachFile;

    return AttachFileList;

  })(Backbone.Collection);

  window.AttachFileController = (function(_super) {
    __extends(AttachFileController, _super);

    function AttachFileController() {
      this.clear = __bind(this.clear, this);
      this.updateModel = __bind(this.updateModel, this);
      this.handleFileTypeChanged = __bind(this.handleFileTypeChanged, this);
      this.handleFileRemoved = __bind(this.handleFileRemoved, this);
      this.handleFileUpload = __bind(this.handleFileUpload, this);
      this.render = __bind(this.render, this);
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
      this.autoAddAttachFileModel = this.options.autoAddAttachFileModel;
      console.log("first Option Name?");
      console.log(this.options.firstOptionName);
      if (this.options.firstOptionName != null) {
        return this.firstOptionName = this.options.firstOptionName;
      } else {
        return this.firstOptionName = "Select File Type";
      }
    };

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
        hideDelete: this.autoAddAttachFileModel
      });
      this.lsFileChooser.render();
      this.lsFileChooser.on('fileUploader:uploadComplete', this.handleFileUpload);
      this.lsFileChooser.on('fileDeleted', this.handleFileRemoved);
      return this;
    };

    AttachFileController.prototype.setUpFileTypeSelect = function() {
      this.fileTypeList = new PickListList();
      this.fileTypeList.url = "/api/dataDict/analytical method/file type";
      return this.fileTypeListController = new PickListSelectController({
        el: this.$('.bv_fileType'),
        collection: this.fileTypeList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: this.firstOptionName
        }),
        selectedCode: this.model.get('fileType')
      });
    };

    AttachFileController.prototype.handleFileUpload = function(nameOnServer) {
      console.log("@autoAddAttachFileModel attach file controller");
      console.log(this.autoAddAttachFileModel);
      if (this.autoAddAttachFileModel) {
        this.$('.bv_delete').show();
        console.log("should delete file");
        this.$('td.delete').hide();
      }
      this.model.set({
        fileValue: nameOnServer
      });
      console.log(this.model);
      console.log(this.model.get('fileValue'));
      this.trigger('fileUploaded');
      return this.trigger('amDirty');
    };

    AttachFileController.prototype.handleFileRemoved = function() {
      this.model.set({
        fileValue: ""
      });
      return this.trigger('amDirty');
    };

    AttachFileController.prototype.handleFileTypeChanged = function() {
      this.updateModel();
      return this.trigger('amDirty');
    };

    AttachFileController.prototype.updateModel = function() {
      this.model.set({
        fileType: this.$('.bv_fileType').val()
      });
      return console.log(this.model);
    };

    AttachFileController.prototype.clear = function() {
      console.log("clear");
      return this.model.destroy();
    };

    return AttachFileController;

  })(AbstractFormController);

  window.AttachFileListController = (function(_super) {
    __extends(AttachFileListController, _super);

    function AttachFileListController() {
      this.isValid = __bind(this.isValid, this);
      this.checkIfNeedToAddNew = __bind(this.checkIfNeedToAddNew, this);
      this.ensureValidCollectionLength = __bind(this.ensureValidCollectionLength, this);
      this.addAttachFile = __bind(this.addAttachFile, this);
      this.uploadNewAttachFile = __bind(this.uploadNewAttachFile, this);
      this.render = __bind(this.render, this);
      return AttachFileListController.__super__.constructor.apply(this, arguments);
    }

    AttachFileListController.prototype.template = _.template($("#AttachFileListView").html());

    AttachFileListController.prototype.initialize = function() {
      var newModel;
      console.log("@options.autoAddAttachFileModel?");
      console.log(this.options.autoAddAttachFileModel != null);
      if (this.collection == null) {
        this.collection = new AttachFileList();
        newModel = new AttachFile();
        this.collection.add(newModel);
        console.log("added model to new collection");
      }
      console.log(this.collection);
      if (this.options.autoAddAttachFileModel != null) {
        this.autoAddAttachFileModel = this.options.autoAddAttachFileModel;
      } else {
        this.autoAddAttachFileModel = true;
      }
      if (this.autoAddAttachFileModel) {
        return this.collection.bind('remove', this.ensureValidCollectionLength);
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
        console.log("collection length is zero");
        this.uploadNewAttachFile();
      }
      return this;
    };

    AttachFileListController.prototype.uploadNewAttachFile = function() {
      var newModel;
      newModel = new AttachFile();
      this.collection.add(newModel);
      this.addAttachFile(newModel);
      return console.log("added new attach File");
    };

    AttachFileListController.prototype.addAttachFile = function(fileInfo) {
      var afc;
      console.log("addAttachFile");
      console.log(this);
      console.log(this.options.firstOptionName);
      afc = new AttachFileController({
        model: fileInfo,
        autoAddAttachFileModel: this.autoAddAttachFileModel,
        firstOptionName: this.options.firstOptionName
      });
      this.listenTo(afc, 'fileUploaded', this.checkIfNeedToAddNew);
      afc.on('amDirty', (function(_this) {
        return function() {
          console.log("afc trigger dirty to aflc");
          return _this.trigger('amDirty');
        };
      })(this));
      return this.$('.bv_attachFileInfo').append(afc.render().el);
    };

    AttachFileListController.prototype.ensureValidCollectionLength = function() {
      console.log("ensureValidCollection");
      if (this.collection.length === 0) {
        return this.uploadNewAttachFile();
      }
    };

    AttachFileListController.prototype.checkIfNeedToAddNew = function() {
      console.log("check if need to add new");
      console.log(this.autoAddAttachFileModel);
      if (this.autoAddAttachFileModel) {
        return this.uploadNewAttachFile();
      }
    };

    AttachFileListController.prototype.isValid = function() {
      var validCheck;
      console.log("is valid in attach file list controller");
      validCheck = true;
      this.collection.each(function(model) {
        var validModel;
        console.log("attach file model");
        console.log(model);
        validModel = model.isValid();
        console.log("validModel");
        console.log(validModel);
        if (validModel === false) {
          return validCheck = false;
        }
      });
      return validCheck;
    };

    return AttachFileListController;

  })(Backbone.View);

}).call(this);
