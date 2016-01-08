(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.BasicFile = (function(superClass) {
    extend(BasicFile, superClass);

    function BasicFile() {
      return BasicFile.__super__.constructor.apply(this, arguments);
    }

    BasicFile.prototype.defaults = function() {
      return {
        id: null,
        comments: null,
        required: false
      };
    };

    return BasicFile;

  })(Backbone.Model);

  window.BasicFileList = (function(superClass) {
    extend(BasicFileList, superClass);

    function BasicFileList() {
      return BasicFileList.__super__.constructor.apply(this, arguments);
    }

    BasicFileList.prototype.model = BasicFile;

    return BasicFileList;

  })(Backbone.Collection);

  window.AttachFile = (function(superClass) {
    extend(AttachFile, superClass);

    function AttachFile() {
      return AttachFile.__super__.constructor.apply(this, arguments);
    }

    AttachFile.prototype.defaults = function() {
      return _(AttachFile.__super__.defaults.call(this)).extend({
        fileType: "unassigned",
        fileValue: ""
      });
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

  })(BasicFile);

  window.AttachFileList = (function(superClass) {
    extend(AttachFileList, superClass);

    function AttachFileList() {
      return AttachFileList.__super__.constructor.apply(this, arguments);
    }

    AttachFileList.prototype.model = AttachFile;

    return AttachFileList;

  })(BasicFileList);

  window.ExperimentAttachFileList = (function(superClass) {
    extend(ExperimentAttachFileList, superClass);

    function ExperimentAttachFileList() {
      this.validateCollection = bind(this.validateCollection, this);
      return ExperimentAttachFileList.__super__.constructor.apply(this, arguments);
    }

    ExperimentAttachFileList.prototype.validateCollection = function() {
      var currentFileType, error, i, index, indivModelErrors, j, len, model, modelErrors, ref, uneditableFileTypes, usedFileTypes;
      modelErrors = [];
      usedFileTypes = {};
      if (this.length !== 0) {
        for (index = i = 0, ref = this.length - 1; 0 <= ref ? i <= ref : i >= ref; index = 0 <= ref ? ++i : --i) {
          model = this.at(index);
          indivModelErrors = model.validate(model.attributes);
          if (indivModelErrors !== null) {
            for (j = 0, len = indivModelErrors.length; j < len; j++) {
              error = indivModelErrors[j];
              modelErrors.push({
                attribute: error.attribute + ':eq(' + index + ')',
                message: error.message
              });
            }
          }
          currentFileType = model.get('fileType');
          uneditableFileTypes = window.conf.experiment.uneditableFileTypes;
          if (uneditableFileTypes == null) {
            uneditableFileTypes = "";
          }
          if (uneditableFileTypes.indexOf(currentFileType) > -1) {
            if (currentFileType in usedFileTypes) {
              modelErrors.push({
                attribute: 'fileType:eq(' + index + ')',
                message: "This file type can not be chosen more than once"
              });
              modelErrors.push({
                attribute: 'fileType:eq(' + usedFileTypes[currentFileType] + ')',
                message: "This file type can not be chosen more than once"
              });
            } else {
              usedFileTypes[currentFileType] = index;
            }
          }
        }
      }
      return modelErrors;
    };

    return ExperimentAttachFileList;

  })(AttachFileList);

  window.BasicFileController = (function(superClass) {
    extend(BasicFileController, superClass);

    function BasicFileController() {
      this.clear = bind(this.clear, this);
      this.handleFileUpload = bind(this.handleFileUpload, this);
      this.createNewFileChooser = bind(this.createNewFileChooser, this);
      this.render = bind(this.render, this);
      return BasicFileController.__super__.constructor.apply(this, arguments);
    }

    BasicFileController.prototype.template = _.template($("#BasicFileView").html());

    BasicFileController.prototype.tagName = "div";

    BasicFileController.prototype.events = function() {
      return {
        "click .bv_delete": "clear"
      };
    };

    BasicFileController.prototype.initialize = function() {
      this.errorOwnerName = 'BasicFileController';
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

    BasicFileController.prototype.render = function() {
      var fileValue, urlValue;
      $(this.el).empty();
      $(this.el).html(this.template(this.model.attributes));
      fileValue = this.model.get('fileValue');
      urlValue = this.model.get('urlValue');
      if ((fileValue === null || fileValue === "" || fileValue === void 0) && (urlValue === null || urlValue === "" || urlValue === void 0)) {
        this.createNewFileChooser();
      } else {
        if (urlValue != null) {
          this.$('.bv_uploadFile').html('<div style="margin-top:5px;margin-left:4px;"> <a href="' + this.model.get('urlValue') + '">' + this.model.get('urlValue') + '</a></div>');
        } else {
          this.$('.bv_uploadFile').html('<div style="margin-top:5px;margin-left:4px;"> <a href="' + window.conf.datafiles.downloadurl.prefix + fileValue + '">' + this.model.get('comments') + '</a></div>');
        }
        this.$('.bv_recordedBy').html(this.model.get("recordedBy"));
        this.$('.bv_recordedDate').html(UtilityFunctions.prototype.convertMSToYMDDate(this.model.get("recordedDate")));
      }
      return this;
    };

    BasicFileController.prototype.createNewFileChooser = function() {
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

    BasicFileController.prototype.handleFileUpload = function(nameOnServer) {
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

    BasicFileController.prototype.clear = function() {
      if (this.model.get('id') === null) {
        this.model.destroy();
      } else {
        this.model.set("ignored", true);
        this.$('.bv_fileInfoWrapper').hide();
      }
      this.trigger('removeFile');
      return this.trigger('amDirty');
    };

    return BasicFileController;

  })(AbstractFormController);

  window.BasicFileListController = (function(superClass) {
    extend(BasicFileListController, superClass);

    function BasicFileListController() {
      this.isValid = bind(this.isValid, this);
      this.checkIfNeedToAddNew = bind(this.checkIfNeedToAddNew, this);
      this.ensureValidCollectionLength = bind(this.ensureValidCollectionLength, this);
      this.addBasicFile = bind(this.addBasicFile, this);
      this.uploadNewFile = bind(this.uploadNewFile, this);
      this.render = bind(this.render, this);
      return BasicFileListController.__super__.constructor.apply(this, arguments);
    }

    BasicFileListController.prototype.template = _.template($("#BasicFileListView").html());

    BasicFileListController.prototype.initialize = function() {
      var newModel;
      if (this.options.required != null) {
        this.required = this.options.required;
      } else {
        this.required = false;
      }
      if (this.collection == null) {
        this.collection = new BasicFileList();
        newModel = new BasicFile;
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
        return this.allowedFileTypes = this.options.allowedFileTypes;
      } else {
        return this.allowedFileTypes = ['xls', 'rtf', 'pdf', 'txt', 'csv', 'sdf', 'xlsx', 'doc', 'docx', 'png', 'gif', 'jpg', 'ppt', 'pptx', 'pzf'];
      }
    };

    BasicFileListController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      this.collection.each((function(_this) {
        return function(fileInfo) {
          return _this.addBasicFile(fileInfo);
        };
      })(this));
      if (this.collection.length === 0) {
        this.uploadNewFile();
      }
      this.trigger('renderComplete');
      return this;
    };

    BasicFileListController.prototype.uploadNewFile = function() {
      var newModel;
      newModel = new BasicFile;
      this.collection.add(newModel);
      this.addBasicFile(newModel);
      return this.trigger('amDirty');
    };

    BasicFileListController.prototype.addBasicFile = function(fileInfo) {
      var afc;
      fileInfo.set({
        required: this.required
      });
      afc = new BasicFileController({
        model: fileInfo,
        autoAddAttachFileModel: this.autoAddAttachFileModel,
        firstOptionName: this.options.firstOptionName,
        allowedFileTypes: this.allowedFileTypes
      });
      this.listenTo(afc, 'fileUploaded', this.checkIfNeedToAddNew);
      this.listenTo(afc, 'removeFile', this.ensureValidCollectionLength);
      afc.on('addNewModel', (function(_this) {
        return function(newModel) {
          _this.collection.add(newModel);
          return _this.addBasicFile(newModel);
        };
      })(this));
      afc.on('amDirty', (function(_this) {
        return function() {
          return _this.trigger('amDirty');
        };
      })(this));
      return this.$('.bv_basicFileInfo').append(afc.render().el);
    };

    BasicFileListController.prototype.ensureValidCollectionLength = function() {
      var notIgnoredFiles;
      notIgnoredFiles = this.collection.filter(function(model) {
        return model.get('ignored') === false || model.get('ignored') === void 0;
      });
      if (notIgnoredFiles.length === 0) {
        return this.uploadNewFile();
      }
    };

    BasicFileListController.prototype.checkIfNeedToAddNew = function() {
      if (this.autoAddAttachFileModel) {
        return this.uploadNewFile();
      }
    };

    BasicFileListController.prototype.isValid = function() {
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

    return BasicFileListController;

  })(Backbone.View);

  window.AttachFileController = (function(superClass) {
    extend(AttachFileController, superClass);

    function AttachFileController() {
      this.updateModel = bind(this.updateModel, this);
      this.handleFileTypeChanged = bind(this.handleFileTypeChanged, this);
      this.render = bind(this.render, this);
      return AttachFileController.__super__.constructor.apply(this, arguments);
    }

    AttachFileController.prototype.template = _.template($("#AttachFileView").html());

    AttachFileController.prototype.tagName = "div";

    AttachFileController.prototype.events = function() {
      return _(AttachFileController.__super__.events.call(this)).extend({
        "change .bv_fileType": "handleFileTypeChanged"
      });
    };

    AttachFileController.prototype.initialize = function() {
      AttachFileController.__super__.initialize.call(this);
      return this.errorOwnerName = 'AttachFileController';
    };

    AttachFileController.prototype.render = function() {
      var fileValue, uneditableFileTypes;
      $(this.el).empty();
      $(this.el).html(this.template(this.model.attributes));
      this.setUpFileTypeSelect();
      fileValue = this.model.get('fileValue');
      if (fileValue === null || fileValue === "" || fileValue === void 0) {
        this.createNewFileChooser();
      } else {
        this.$('.bv_uploadFile').html('<div style="margin-top:5px;margin-left:4px;"> <a href="' + window.conf.datafiles.downloadurl.prefix + fileValue + '">' + this.model.get('comments') + '</a></div>');
      }
      uneditableFileTypes = window.conf.experiment.uneditableFileTypes;
      if (uneditableFileTypes == null) {
        uneditableFileTypes = "";
      }
      if (uneditableFileTypes.indexOf(this.model.get('fileType')) > -1 && (this.model.get('id') != null)) {
        this.$('.bv_delete').hide();
        this.$('.bv_fileType').attr('disabled', 'disabled');
      } else {
        this.$('.bv_delete').show();
        this.$('.bv_fileType').removeAttr('disabled');
      }
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

    return AttachFileController;

  })(BasicFileController);

  window.AttachFileListController = (function(superClass) {
    extend(AttachFileListController, superClass);

    function AttachFileListController() {
      this.addAttachFile = bind(this.addAttachFile, this);
      this.uploadNewFile = bind(this.uploadNewFile, this);
      this.render = bind(this.render, this);
      return AttachFileListController.__super__.constructor.apply(this, arguments);
    }

    AttachFileListController.prototype.template = _.template($("#AttachFileListView").html());

    AttachFileListController.prototype.events = {
      "click .bv_addFileInfo": "uploadNewFile"
    };

    AttachFileListController.prototype.initialize = function() {
      var newModel;
      if (this.collection == null) {
        this.collection = new AttachFileList();
        newModel = new AttachFile;
        this.collection.add(newModel);
      }
      AttachFileListController.__super__.initialize.call(this);
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
        this.uploadNewFile();
      }
      this.trigger('renderComplete');
      return this;
    };

    AttachFileListController.prototype.uploadNewFile = function() {
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

    return AttachFileListController;

  })(BasicFileListController);

  window.ExperimentAttachFileListController = (function(superClass) {
    extend(ExperimentAttachFileListController, superClass);

    function ExperimentAttachFileListController() {
      this.clearValidationErrorStyles = bind(this.clearValidationErrorStyles, this);
      this.validationError = bind(this.validationError, this);
      this.isValid = bind(this.isValid, this);
      return ExperimentAttachFileListController.__super__.constructor.apply(this, arguments);
    }

    ExperimentAttachFileListController.prototype.initialize = function() {
      var newModel;
      if (this.collection == null) {
        this.collection = new ExperimentAttachFileList();
        newModel = new AttachFile;
        this.collection.add(newModel);
      }
      ExperimentAttachFileListController.__super__.initialize.call(this);
      if (this.options.fileTypeList != null) {
        return this.fileTypeList = this.options.fileTypeList;
      } else {
        return this.fileTypeList = new PickListList();
      }
    };

    ExperimentAttachFileListController.prototype.isValid = function() {
      var errors, validCheck;
      validCheck = true;
      errors = this.collection.validateCollection();
      if (errors.length > 0) {
        validCheck = false;
      }
      this.validationError(errors);
      return validCheck;
    };

    ExperimentAttachFileListController.prototype.validationError = function(errors) {
      this.clearValidationErrorStyles();
      return _.each(errors, (function(_this) {
        return function(err) {
          if (_this.$('.bv_' + err.attribute).attr('disabled') !== 'disabled') {
            _this.$('.bv_group_' + err.attribute).attr('data-toggle', 'tooltip');
            _this.$('.bv_group_' + err.attribute).attr('data-placement', 'bottom');
            _this.$('.bv_group_' + err.attribute).attr('data-original-title', err.message);
            _this.$("[data-toggle=tooltip]").tooltip();
            _this.$("body").tooltip({
              selector: '.bv_group_' + err.attribute
            });
            _this.$('.bv_group_' + err.attribute).addClass('input_error error');
            return _this.trigger('notifyError', {
              owner: _this.errorOwnerName,
              errorLevel: 'error',
              message: err.message
            });
          }
        };
      })(this));
    };

    ExperimentAttachFileListController.prototype.clearValidationErrorStyles = function() {
      var errorElms;
      errorElms = this.$('.input_error');
      return _.each(errorElms, (function(_this) {
        return function(ee) {
          $(ee).removeAttr('data-toggle');
          $(ee).removeAttr('data-placement');
          $(ee).removeAttr('title');
          $(ee).removeAttr('data-original-title');
          return $(ee).removeClass('input_error error');
        };
      })(this));
    };

    return ExperimentAttachFileListController;

  })(AttachFileListController);

}).call(this);
