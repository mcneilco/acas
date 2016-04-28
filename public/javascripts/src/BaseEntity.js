(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.BaseEntity = (function(superClass) {
    extend(BaseEntity, superClass);

    function BaseEntity() {
      this.duplicateEntity = bind(this.duplicateEntity, this);
      this.getModelFitParameters = bind(this.getModelFitParameters, this);
      this.getAnalysisParameters = bind(this.getAnalysisParameters, this);
      this.getAttachedFiles = bind(this.getAttachedFiles, this);
      this.parse = bind(this.parse, this);
      return BaseEntity.__super__.constructor.apply(this, arguments);
    }

    BaseEntity.prototype.urlRoot = "/api/experiments";

    BaseEntity.prototype.defaults = function() {
      return {
        subclass: "entity",
        lsType: "default",
        lsKind: "default",
        recordedBy: window.AppLaunchParams.loginUser.username,
        recordedDate: new Date().getTime(),
        shortDescription: " ",
        lsLabels: new LabelList(),
        lsStates: new StateList()
      };
    };

    BaseEntity.prototype.initialize = function() {
      return this.set(this.parse(this.attributes));
    };

    BaseEntity.prototype.parse = function(resp) {
      if (resp.lsLabels != null) {
        if (!(resp.lsLabels instanceof LabelList)) {
          resp.lsLabels = new LabelList(resp.lsLabels);
        }
        resp.lsLabels.on('change', (function(_this) {
          return function() {
            return _this.trigger('change');
          };
        })(this));
      }
      if (resp.lsStates != null) {
        if (!(resp.lsStates instanceof StateList)) {
          resp.lsStates = new StateList(resp.lsStates);
        }
        resp.lsStates.on('change', (function(_this) {
          return function() {
            return _this.trigger('change');
          };
        })(this));
      }
      if (!(resp.lsTags instanceof TagList)) {
        resp.lsTags = new TagList(resp.lsTags);
        resp.lsTags.on('change', (function(_this) {
          return function() {
            return _this.trigger('change');
          };
        })(this));
      }
      return resp;
    };

    BaseEntity.prototype.getScientist = function() {
      var metadataKind, scientist;
      metadataKind = this.get('subclass') + " metadata";
      scientist = this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", metadataKind, "codeValue", "scientist");
      if (scientist.get('codeValue') === void 0) {
        scientist.set({
          codeType: "assay"
        });
        scientist.set({
          codeKind: "scientist"
        });
        scientist.set({
          codeOrigin: window.conf.scientistCodeOrigin
        });
        if (this.isNew()) {
          scientist.set({
            codeValue: window.AppLaunchParams.loginUserName
          });
        } else {
          scientist.set({
            codeValue: "unassigned"
          });
        }
      }
      return scientist;
    };

    BaseEntity.prototype.getDetails = function() {
      var entityDetails, metadataKind;
      metadataKind = this.get('subclass') + " metadata";
      entityDetails = this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", metadataKind, "clobValue", this.get('subclass') + " details");
      if (entityDetails.get('clobValue') === void 0 || entityDetails.get('clobValue') === "") {
        entityDetails.set({
          clobValue: ""
        });
      }
      return entityDetails;
    };

    BaseEntity.prototype.getComments = function() {
      var comments, metadataKind;
      metadataKind = this.get('subclass') + " metadata";
      comments = this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", metadataKind, "clobValue", "comments");
      if (comments.get('clobValue') === void 0 || comments.get('clobValue') === "") {
        comments.set({
          clobValue: ""
        });
      }
      return comments;
    };

    BaseEntity.prototype.getNotebook = function() {
      var metadataKind;
      metadataKind = this.get('subclass') + " metadata";
      return this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", metadataKind, "stringValue", "notebook");
    };

    BaseEntity.prototype.getStatus = function() {
      var metadataKind, status, subclass, valueKind;
      subclass = this.get('subclass');
      metadataKind = subclass + " metadata";
      valueKind = subclass + " status";
      status = this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", metadataKind, "codeValue", valueKind);
      if (status.get('codeValue') === void 0 || status.get('codeValue') === "") {
        status.set({
          codeValue: "created"
        });
        status.set({
          codeType: subclass
        });
        status.set({
          codeKind: "status"
        });
        status.set({
          codeOrigin: "ACAS DDICT"
        });
      }
      return status;
    };

    BaseEntity.prototype.getAttachedFiles = function(fileTypes) {
      var afm, analyticalFileState, analyticalFileValues, attachFileList, file, i, j, len, len1, type;
      attachFileList = new AttachFileList();
      for (i = 0, len = fileTypes.length; i < len; i++) {
        type = fileTypes[i];
        analyticalFileState = this.get('lsStates').getOrCreateStateByTypeAndKind("metadata", this.get('subclass') + " metadata");
        analyticalFileValues = analyticalFileState.getValuesByTypeAndKind("fileValue", type.code);
        if (analyticalFileValues.length > 0 && type.code !== "unassigned") {
          for (j = 0, len1 = analyticalFileValues.length; j < len1; j++) {
            file = analyticalFileValues[j];
            if (file.get('ignored') === false) {
              afm = new AttachFile({
                fileType: type.code,
                fileValue: file.get('fileValue'),
                id: file.get('id'),
                comments: file.get('comments')
              });
              attachFileList.add(afm);
            }
          }
        }
      }
      return attachFileList;
    };

    BaseEntity.prototype.getAnalysisParameters = function() {
      var ap;
      ap = this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "experiment metadata", "clobValue", "data analysis parameters");
      if (ap.get('clobValue') != null) {
        return new PrimaryScreenAnalysisParameters($.parseJSON(ap.get('clobValue')));
      } else {
        return new PrimaryScreenAnalysisParameters();
      }
    };

    BaseEntity.prototype.getModelFitParameters = function() {
      var ap;
      ap = this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "experiment metadata", "clobValue", "model fit parameters");
      if (ap.get('clobValue') != null) {
        return $.parseJSON(ap.get('clobValue'));
      } else {
        return {};
      }
    };

    BaseEntity.prototype.isEditable = function() {
      var status;
      status = this.getStatus().get('codeValue');
      switch (status) {
        case "created":
          return true;
        case "started":
          return true;
        case "complete":
          return true;
        case "approved":
          return false;
        case "rejected":
          return false;
        case "deleted":
          return false;
      }
      return true;
    };

    BaseEntity.prototype.validate = function(attrs) {
      var bestName, errors, nameError, notebook, scientist;
      errors = [];
      bestName = attrs.lsLabels.pickBestName();
      nameError = true;
      if (bestName != null) {
        nameError = true;
        if (bestName.get('labelText') !== "") {
          nameError = false;
        }
      }
      if (nameError) {
        errors.push({
          attribute: attrs.subclass + 'Name',
          message: attrs.subclass + " name must be set"
        });
      }
      if (_.isNaN(attrs.recordedDate)) {
        errors.push({
          attribute: 'recordedDate',
          message: attrs.subclass + " date must be set"
        });
      }
      if (attrs.subclass != null) {
        notebook = this.getNotebook().get('stringValue');
        if (notebook === "" || notebook === void 0 || notebook === null) {
          errors.push({
            attribute: 'notebook',
            message: "Notebook must be set"
          });
        }
        scientist = this.getScientist().get('codeValue');
        if (scientist === "unassigned" || scientist === void 0 || scientist === "" || scientist === null) {
          errors.push({
            attribute: 'scientist',
            message: "Scientist must be set"
          });
        }
      }
      if (errors.length > 0) {
        return errors;
      } else {
        return null;
      }
    };

    BaseEntity.prototype.prepareToSave = function() {
      var rBy, rDate;
      rBy = window.AppLaunchParams.loginUser.username;
      rDate = new Date().getTime();
      this.set({
        recordedDate: rDate
      });
      this.get('lsLabels').each(function(lab) {
        if (lab.get('recordedBy') === "") {
          lab.set({
            recordedBy: rBy
          });
        }
        if (lab.get('recordedDate') === null) {
          return lab.set({
            recordedDate: rDate
          });
        }
      });
      this.get('lsStates').each(function(state) {
        if (state.get('recordedBy') === "") {
          state.set({
            recordedBy: rBy
          });
        }
        if (state.get('recordedDate') === null) {
          state.set({
            recordedDate: rDate
          });
        }
        return state.get('lsValues').each(function(val) {
          if (val.get('recordedBy') === "") {
            val.set({
              recordedBy: rBy
            });
          }
          if (val.get('recordedDate') === null) {
            return val.set({
              recordedDate: rDate
            });
          }
        });
      });
      if (this.attributes.subclass != null) {
        delete this.attributes.subclass;
      }
      if (this.attributes.protocol != null) {
        if (this.attributes.protocol.attributes.subclass != null) {
          delete this.attributes.protocol.attributes.subclass;
        }
      }
      return this.trigger("readyToSave", this);
    };

    BaseEntity.prototype.duplicateEntity = function() {
      var copiedEntity, copiedStates, origStates;
      copiedEntity = this.clone();
      copiedEntity.unset('lsLabels');
      copiedEntity.unset('lsStates');
      copiedEntity.unset('id');
      copiedEntity.unset('codeName');
      copiedStates = new StateList();
      origStates = this.get('lsStates');
      origStates.each(function(st) {
        var copiedState, copiedValues, origValues;
        copiedState = new State(_.clone(st.attributes));
        copiedState.unset('id');
        copiedState.unset('lsTransactions');
        copiedState.unset('lsValues');
        copiedValues = new ValueList();
        origValues = st.get('lsValues');
        origValues.each(function(sv) {
          var copiedVal;
          if (sv.attributes.lsType !== 'fileValue') {
            copiedVal = new Value(sv.attributes);
            copiedVal.unset('id');
            copiedVal.unset('lsTransaction');
            return copiedValues.add(copiedVal);
          }
        });
        copiedState.set({
          lsValues: copiedValues
        });
        return copiedStates.add(copiedState);
      });
      copiedEntity.set({
        lsLabels: new LabelList(),
        lsStates: copiedStates,
        recordedBy: window.AppLaunchParams.loginUser.username,
        recordedDate: new Date().getTime(),
        version: 0
      });
      copiedEntity.getStatus().set({
        codeValue: "created"
      });
      copiedEntity.getNotebook().set({
        stringValue: ""
      });
      copiedEntity.getScientist().set({
        codeValue: "unassigned"
      });
      return copiedEntity;
    };

    return BaseEntity;

  })(Backbone.Model);

  window.BaseEntityList = (function(superClass) {
    extend(BaseEntityList, superClass);

    function BaseEntityList() {
      return BaseEntityList.__super__.constructor.apply(this, arguments);
    }

    BaseEntityList.prototype.model = BaseEntity;

    return BaseEntityList;

  })(Backbone.Collection);

  window.BaseEntityController = (function(superClass) {
    extend(BaseEntityController, superClass);

    function BaseEntityController() {
      this.isValid = bind(this.isValid, this);
      this.displayInReadOnlyMode = bind(this.displayInReadOnlyMode, this);
      this.checkDisplayMode = bind(this.checkDisplayMode, this);
      this.clearValidationErrorStyles = bind(this.clearValidationErrorStyles, this);
      this.validationError = bind(this.validationError, this);
      this.handleCancelComplete = bind(this.handleCancelComplete, this);
      this.handleCancelClicked = bind(this.handleCancelClicked, this);
      this.handleConfirmClearClicked = bind(this.handleConfirmClearClicked, this);
      this.handleCancelClearClicked = bind(this.handleCancelClearClicked, this);
      this.handleNewEntityClicked = bind(this.handleNewEntityClicked, this);
      this.prepareToSaveAttachedFiles = bind(this.prepareToSaveAttachedFiles, this);
      this.saveEntity = bind(this.saveEntity, this);
      this.handleSaveClicked = bind(this.handleSaveClicked, this);
      this.beginSave = bind(this.beginSave, this);
      this.updateEditable = bind(this.updateEditable, this);
      this.handleValueChanged = bind(this.handleValueChanged, this);
      this.handleStatusChanged = bind(this.handleStatusChanged, this);
      this.handleNotebookChanged = bind(this.handleNotebookChanged, this);
      this.handleNameChanged = bind(this.handleNameChanged, this);
      this.handleCommentsChanged = bind(this.handleCommentsChanged, this);
      this.handleDetailsChanged = bind(this.handleDetailsChanged, this);
      this.handleShortDescriptionChanged = bind(this.handleShortDescriptionChanged, this);
      this.handleScientistChanged = bind(this.handleScientistChanged, this);
      this.setupAttachFileListController = bind(this.setupAttachFileListController, this);
      this.modelChangeCallback = bind(this.modelChangeCallback, this);
      this.modelSyncCallback = bind(this.modelSyncCallback, this);
      this.render = bind(this.render, this);
      return BaseEntityController.__super__.constructor.apply(this, arguments);
    }

    BaseEntityController.prototype.template = _.template($("#BaseEntityView").html());

    BaseEntityController.prototype.events = function() {
      return {
        "change .bv_scientist": "handleScientistChanged",
        "keyup .bv_shortDescription": "handleShortDescriptionChanged",
        "keyup .bv_details": "handleDetailsChanged",
        "keyup .bv_comments": "handleCommentsChanged",
        "keyup .bv_entityName": "handleNameChanged",
        "keyup .bv_notebook": "handleNotebookChanged",
        "change .bv_status": "handleStatusChanged",
        "click .bv_save": "handleSaveClicked",
        "click .bv_newEntity": "handleNewEntityClicked",
        "click .bv_cancel": "handleCancelClicked",
        "click .bv_cancelClear": "handleCancelClearClicked",
        "click .bv_confirmClear": "handleConfirmClearClicked"
      };
    };

    BaseEntityController.prototype.initialize = function() {
      if (this.model == null) {
        this.model = new BaseEntity();
      }
      this.listenTo(this.model, 'sync', this.modelSyncCallback);
      this.listenTo(this.model, 'change', this.modelChangeCallback);
      this.errorOwnerName = 'BaseEntityController';
      this.setBindings();
      if (this.options.readOnly != null) {
        this.readOnly = this.options.readOnly;
      } else {
        this.readOnly = false;
      }
      $(this.el).empty();
      $(this.el).html(this.template());
      this.$('.bv_save').attr('disabled', 'disabled');
      this.setupStatusSelect();
      this.setupScientistSelect();
      this.setupTagList();
      return this.model.getStatus().on('change', this.updateEditable);
    };

    BaseEntityController.prototype.render = function() {
      var bestName, subclass;
      if (this.model == null) {
        this.model = new BaseEntity();
      }
      subclass = this.model.get('subclass');
      if (this.model.get('shortDescription') !== " ") {
        this.$('.bv_shortDescription').html(this.model.get('shortDescription'));
      }
      bestName = this.model.get('lsLabels').pickBestName();
      if (bestName != null) {
        this.$('.bv_' + subclass + 'Name').val(bestName.get('labelText'));
      }
      this.$('.bv_scientist').val(this.model.getScientist().get('codeValue'));
      this.$('.bv_' + subclass + 'Code').html(this.model.get('codeName'));
      this.$('.bv_' + subclass + 'Kind').html(this.model.get('lsKind'));
      this.$('.bv_details').val(this.model.getDetails().get('clobValue'));
      this.$('.bv_comments').val(this.model.getComments().get('clobValue'));
      this.$('.bv_notebook').val(this.model.getNotebook().get('stringValue'));
      this.$('.bv_status').val(this.model.getStatus().get('codeValue'));
      if (this.model.isNew()) {
        this.$('.bv_save').html("Save");
        this.$('.bv_newEntity').hide();
      } else {
        this.$('.bv_save').html("Update");
        this.$('.bv_newEntity').show();
      }
      this.updateEditable();
      this.$('.bv_save').attr('disabled', 'disabled');
      this.$('.bv_cancel').attr('disabled', 'disabled');
      if (this.readOnly === true) {
        this.displayInReadOnlyMode();
      }
      return this;
    };

    BaseEntityController.prototype.modelSyncCallback = function() {
      this.trigger('amClean');
      if (this.model.get('subclass') == null) {
        this.model.set({
          subclass: 'entity'
        });
      }
      this.$('.bv_saving').hide();
      this.$('.bv_updateComplete').show();
      return this.render();
    };

    BaseEntityController.prototype.modelChangeCallback = function() {
      this.trigger('amDirty');
      this.$('.bv_updateComplete').hide();
      this.$('.bv_cancel').removeAttr('disabled');
      return this.$('.bv_cancelComplete').hide();
    };

    BaseEntityController.prototype.setupStatusSelect = function() {
      var statusState;
      statusState = this.model.getStatus();
      this.statusList = new PickListList();
      this.statusList.url = "/api/codetables/" + statusState.get('codeType') + "/" + statusState.get('codeKind');
      return this.statusListController = new PickListSelectController({
        el: this.$('.bv_status'),
        collection: this.statusList,
        selectedCode: statusState.get('codeValue')
      });
    };

    BaseEntityController.prototype.setupScientistSelect = function() {
      this.scientistList = new PickListList();
      this.scientistList.url = "/api/authors";
      return this.scientistListController = new PickListSelectController({
        el: this.$('.bv_scientist'),
        collection: this.scientistList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select Scientist"
        }),
        selectedCode: this.model.getScientist().get('codeValue')
      });
    };

    BaseEntityController.prototype.setupAttachFileListController = function() {
      return $.ajax({
        type: 'GET',
        url: "/api/codetables/" + this.model.get('subclass') + " metadata/file type",
        dataType: 'json',
        error: function(err) {
          return alert('Could not get list of file types');
        },
        success: (function(_this) {
          return function(json) {
            var attachFileList;
            if (json.length === 0) {
              return alert('Got empty list of file types');
            } else {
              attachFileList = _this.model.getAttachedFiles(json);
              return _this.finishSetupAttachFileListController(attachFileList, json);
            }
          };
        })(this)
      });
    };

    BaseEntityController.prototype.finishSetupAttachFileListController = function(attachFileList, fileTypeList) {
      if (this.attachFileListController != null) {
        this.attachFileListController.undelegateEvents();
      }
      this.attachFileListController = new AttachFileListController({
        autoAddAttachFileModel: false,
        el: this.$('.bv_attachFileList'),
        collection: attachFileList,
        firstOptionName: "Select Method",
        allowedFileTypes: ['xls', 'rtf', 'pdf', 'txt', 'csv', 'sdf', 'xlsx', 'doc', 'docx', 'png', 'gif', 'jpg', 'ppt', 'pptx', 'pzf', 'zip'],
        fileTypeList: fileTypeList,
        required: false
      });
      this.attachFileListController.on('amClean', (function(_this) {
        return function() {
          return _this.trigger('amClean');
        };
      })(this));
      this.attachFileListController.on('renderComplete', (function(_this) {
        return function() {
          return _this.checkDisplayMode();
        };
      })(this));
      this.attachFileListController.render();
      return this.attachFileListController.on('amDirty', (function(_this) {
        return function() {
          _this.trigger('amDirty');
          return _this.model.trigger('change');
        };
      })(this));
    };

    BaseEntityController.prototype.setupTagList = function() {
      this.$('.bv_tags').val("");
      this.tagListController = new TagListController({
        el: this.$('.bv_tags'),
        collection: this.model.get('lsTags')
      });
      return this.tagListController.render();
    };

    BaseEntityController.prototype.handleScientistChanged = function() {
      var value;
      value = this.scientistListController.getSelectedCode();
      return this.handleValueChanged("Scientist", value);
    };

    BaseEntityController.prototype.handleShortDescriptionChanged = function() {
      var trimmedDesc;
      trimmedDesc = UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_shortDescription'));
      if (trimmedDesc === "") {
        trimmedDesc = " ";
      }
      return this.model.set({
        shortDescription: trimmedDesc
      });
    };

    BaseEntityController.prototype.handleDetailsChanged = function() {
      var value;
      value = UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_details'));
      return this.handleValueChanged("Details", value);
    };

    BaseEntityController.prototype.handleCommentsChanged = function() {
      var value;
      value = UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_comments'));
      return this.handleValueChanged("Comments", value);
    };

    BaseEntityController.prototype.handleNameChanged = function() {
      var newName, subclass;
      subclass = this.model.get('subclass');
      newName = UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_' + subclass + 'Name'));
      this.model.get('lsLabels').setBestName(new Label({
        lsKind: subclass + " name",
        labelText: newName,
        recordedBy: window.AppLaunchParams.loginUser.username,
        recordedDate: new Date().getTime()
      }));
      return this.model.trigger('change');
    };

    BaseEntityController.prototype.handleNotebookChanged = function() {
      var value;
      value = UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_notebook'));
      return this.handleValueChanged("Notebook", value);
    };

    BaseEntityController.prototype.handleStatusChanged = function() {
      var value;
      value = this.statusListController.getSelectedCode();
      if ((value === "approved" || value === "rejected") && !this.isValid()) {
        value = value.charAt(0).toUpperCase() + value.substring(1);
        alert('All fields must be valid before changing the status to "' + value + '"');
        return this.statusListController.setSelectedCode(this.model.getStatus().get('codeValue'));
      } else if (value === "deleted") {
        return this.handleDeleteStatusChosen();
      } else {
        this.handleValueChanged("Status", value);
        this.updateEditable();
        this.model.trigger('change');
        return this.model.trigger('statusChanged');
      }
    };

    BaseEntityController.prototype.handleValueChanged = function(vKind, value) {
      var currentVal;
      currentVal = this.model["get" + vKind]();
      if (!currentVal.isNew()) {
        currentVal.set({
          ignored: true
        });
        currentVal = this.model["get" + vKind]();
      }
      currentVal.set(currentVal.get('lsType'), value);
      return this.model.trigger('change');
    };

    BaseEntityController.prototype.updateEditable = function() {
      if (this.model.isEditable()) {
        this.enableAllInputs();
        this.$('.bv_lock').hide();
      } else {
        this.disableAllInputs();
        this.$('.bv_status').removeAttr('disabled');
        this.$('.bv_lock').show();
        this.$('.bv_newEntity').removeAttr('disabled');
        if (this.model.getStatus().get('codeValue') === "deleted") {
          this.$('.bv_status').attr('disabled', 'disabled');
        }
      }
      if (this.model.isNew()) {
        this.$('.bv_status').attr("disabled", "disabled");
      } else {
        if (this.model.getStatus().get('codeValue') !== "deleted") {
          this.$('.bv_status').removeAttr("disabled");
        }
      }
      return this.model.trigger('statusChanged');
    };

    BaseEntityController.prototype.beginSave = function() {
      this.prepareToSaveAttachedFiles();
      this.tagListController.handleTagsChanged();
      if (this.model.checkForNewPickListOptions != null) {
        return this.model.checkForNewPickListOptions();
      } else {
        return this.trigger("noEditablePickLists");
      }
    };

    BaseEntityController.prototype.handleSaveClicked = function() {
      return this.saveEntity();
    };

    BaseEntityController.prototype.saveEntity = function() {
      this.prepareToSaveAttachedFiles();
      this.tagListController.handleTagsChanged();
      this.model.prepareToSave();
      if (this.model.isNew()) {
        this.$('.bv_updateComplete').html("Save Complete");
      } else {
        this.$('.bv_updateComplete').html("Update Complete");
      }
      this.$('.bv_save').attr('disabled', 'disabled');
      this.$('.bv_saving').show();
      return this.model.save();
    };

    BaseEntityController.prototype.prepareToSaveAttachedFiles = function() {
      return this.attachFileListController.collection.each((function(_this) {
        return function(file) {
          var newFile, value;
          if (file.get('fileType') !== "unassigned") {
            if (file.get('id') === null) {
              newFile = _this.model.get('lsStates').createValueByTypeAndKind("metadata", _this.model.get('subclass') + " metadata", "fileValue", file.get('fileType'));
              return newFile.set({
                fileValue: file.get('fileValue')
              });
            } else {
              if (file.get('ignored') === true) {
                value = _this.model.get('lsStates').getValueById("metadata", _this.model.get('subclass') + " metadata", file.get('id'));
                return value[0].set("ignored", true);
              }
            }
          }
        };
      })(this));
    };

    BaseEntityController.prototype.handleNewEntityClicked = function() {
      this.$('.bv_confirmClearEntity').modal('show');
      this.$('.bv_confirmClear').removeAttr('disabled');
      this.$('.bv_cancelClear').removeAttr('disabled');
      return this.$('.bv_closeModalButton').removeAttr('disabled');
    };

    BaseEntityController.prototype.handleCancelClearClicked = function() {
      return this.$('.bv_confirmClearEntity').modal('hide');
    };

    BaseEntityController.prototype.handleConfirmClearClicked = function() {
      this.$('.bv_confirmClearEntity').modal('hide');
      if (this.model.get('lsKind') === "default") {
        this.model = null;
        this.completeInitialization();
      } else {
        this.trigger('reinitialize');
      }
      return this.trigger('amClean');
    };

    BaseEntityController.prototype.handleCancelClicked = function() {
      if (this.model.isNew()) {
        if (this.model.get('lsKind') === "default") {
          this.model = null;
          this.completeInitialization();
        } else {
          this.trigger('reinitialize');
        }
      } else {
        this.$('.bv_canceling').show();
        this.model.fetch({
          success: this.handleCancelComplete
        });
      }
      return this.trigger('amClean');
    };

    BaseEntityController.prototype.handleCancelComplete = function() {
      this.$('.bv_canceling').hide();
      return this.$('.bv_cancelComplete').show();
    };

    BaseEntityController.prototype.validationError = function() {
      BaseEntityController.__super__.validationError.call(this);
      return this.$('.bv_save').attr('disabled', 'disabled');
    };

    BaseEntityController.prototype.clearValidationErrorStyles = function() {
      BaseEntityController.__super__.clearValidationErrorStyles.call(this);
      return this.$('.bv_save').removeAttr('disabled');
    };

    BaseEntityController.prototype.checkDisplayMode = function() {
      var status;
      status = this.model.getStatus().get('codeValue');
      if (this.readOnly === true) {
        return this.displayInReadOnlyMode();
      } else if (status === "deleted" || status === "approved" || status === "rejected") {
        this.disableAllInputs();
        if (this.model.getStatus().get('codeValue') !== "deleted") {
          this.$('.bv_status').removeAttr('disabled');
        }
        this.$('.bv_newEntity').removeAttr('disabled');
        return this.$('.bv_newEntity').removeAttr('disabled');
      }
    };

    BaseEntityController.prototype.displayInReadOnlyMode = function() {
      this.$(".bv_save").hide();
      this.$(".bv_cancel").hide();
      this.$(".bv_newEntity").hide();
      this.$(".bv_addFileInfo").hide();
      return this.disableAllInputs();
    };

    BaseEntityController.prototype.isValid = function() {
      var validCheck;
      validCheck = BaseEntityController.__super__.isValid.call(this);
      if (this.attachFileListController != null) {
        if (this.attachFileListController.isValid() === true) {
          return validCheck;
        } else {
          this.$('.bv_save').attr('disabled', 'disabled');
          return false;
        }
      } else {
        return validCheck;
      }
    };

    return BaseEntityController;

  })(AbstractFormController);

}).call(this);
