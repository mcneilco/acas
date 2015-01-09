(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.BaseEntity = (function(_super) {
    __extends(BaseEntity, _super);

    function BaseEntity() {
      this.duplicateEntity = __bind(this.duplicateEntity, this);
      this.getModelFitParameters = __bind(this.getModelFitParameters, this);
      this.getAnalysisParameters = __bind(this.getAnalysisParameters, this);
      this.parse = __bind(this.parse, this);
      return BaseEntity.__super__.constructor.apply(this, arguments);
    }

    BaseEntity.prototype.urlRoot = "/api/experiments";

    BaseEntity.prototype.defaults = function() {
      return {
        subclass: "entity",
        lsType: "default",
        lsKind: "default",
        recordedBy: "",
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

    BaseEntity.prototype.getDescription = function() {
      var description, metadataKind;
      metadataKind = this.get('subclass') + " metadata";
      description = this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", metadataKind, "clobValue", "description");
      if (description.get('clobValue') === void 0 || description.get('clobValue') === "") {
        description.set({
          clobValue: ""
        });
      }
      return description;
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

    BaseEntity.prototype.getCompletionDate = function() {
      var metadataKind;
      metadataKind = this.get('subclass') + " metadata";
      return this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", metadataKind, "dateValue", "completion date");
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
        case "finalized":
          return false;
        case "rejected":
          return false;
      }
      return true;
    };

    BaseEntity.prototype.validate = function(attrs) {
      var bestName, cDate, errors, nameError, notebook;
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
      if (attrs.recordedBy === "" || attrs.recordedBy === "unassigned") {
        errors.push({
          attribute: 'recordedBy',
          message: "Scientist must be set"
        });
      }
      cDate = this.getCompletionDate().get('dateValue');
      if (cDate === void 0 || cDate === "" || cDate === null) {
        cDate = "fred";
      }
      if (isNaN(cDate)) {
        errors.push({
          attribute: 'completionDate',
          message: "Assay completion date must be set"
        });
      }
      notebook = this.getNotebook().get('stringValue');
      if (notebook === "" || notebook === "unassigned" || notebook === void 0) {
        errors.push({
          attribute: 'notebook',
          message: "Notebook must be set"
        });
      }
      if (errors.length > 0) {
        return errors;
      } else {
        return null;
      }
    };

    BaseEntity.prototype.prepareToSave = function() {
      var rBy, rDate;
      rBy = this.get('recordedBy');
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
          copiedVal = new Value(sv.attributes);
          copiedVal.unset('id');
          copiedVal.unset('lsTransaction');
          return copiedValues.add(copiedVal);
        });
        copiedState.set({
          lsValues: copiedValues
        });
        return copiedStates.add(copiedState);
      });
      copiedEntity.set({
        lsLabels: new LabelList(),
        lsStates: copiedStates,
        recordedBy: "",
        recordedDate: new Date().getTime(),
        version: 0
      });
      copiedEntity.getStatus().set({
        codeValue: "created"
      });
      copiedEntity.getCompletionDate().set({
        dateValue: null
      });
      copiedEntity.getNotebook().set({
        stringValue: ""
      });
      return copiedEntity;
    };

    return BaseEntity;

  })(Backbone.Model);

  window.BaseEntityList = (function(_super) {
    __extends(BaseEntityList, _super);

    function BaseEntityList() {
      return BaseEntityList.__super__.constructor.apply(this, arguments);
    }

    BaseEntityList.prototype.model = BaseEntity;

    return BaseEntityList;

  })(Backbone.Collection);

  window.BaseEntityController = (function(_super) {
    __extends(BaseEntityController, _super);

    function BaseEntityController() {
      this.displayInReadOnlyMode = __bind(this.displayInReadOnlyMode, this);
      this.clearValidationErrorStyles = __bind(this.clearValidationErrorStyles, this);
      this.validationError = __bind(this.validationError, this);
      this.handleSaveClicked = __bind(this.handleSaveClicked, this);
      this.beginSave = __bind(this.beginSave, this);
      this.updateEditable = __bind(this.updateEditable, this);
      this.handleStatusChanged = __bind(this.handleStatusChanged, this);
      this.handleNotebookChanged = __bind(this.handleNotebookChanged, this);
      this.handleCompletionDateIconClicked = __bind(this.handleCompletionDateIconClicked, this);
      this.handleDateChanged = __bind(this.handleDateChanged, this);
      this.handleNameChanged = __bind(this.handleNameChanged, this);
      this.handleCommentsChanged = __bind(this.handleCommentsChanged, this);
      this.handleDescriptionChanged = __bind(this.handleDescriptionChanged, this);
      this.handleShortDescriptionChanged = __bind(this.handleShortDescriptionChanged, this);
      this.handleRecordedByChanged = __bind(this.handleRecordedByChanged, this);
      this.render = __bind(this.render, this);
      return BaseEntityController.__super__.constructor.apply(this, arguments);
    }

    BaseEntityController.prototype.template = _.template($("#BaseEntityView").html());

    BaseEntityController.prototype.events = function() {
      return {
        "change .bv_recordedBy": "handleRecordedByChanged",
        "change .bv_shortDescription": "handleShortDescriptionChanged",
        "change .bv_description": "handleDescriptionChanged",
        "change .bv_comments": "handleCommentsChanged",
        "change .bv_entityName": "handleNameChanged",
        "change .bv_completionDate": "handleDateChanged",
        "click .bv_completionDateIcon": "handleCompletionDateIconClicked",
        "change .bv_notebook": "handleNotebookChanged",
        "change .bv_status": "handleStatusChanged",
        "click .bv_save": "handleSaveClicked"
      };
    };

    BaseEntityController.prototype.initialize = function() {
      if (this.model == null) {
        this.model = new BaseEntity();
      }
      this.model.on('sync', (function(_this) {
        return function() {
          _this.trigger('amClean');
          if (_this.model.get('subclass') == null) {
            _this.model.set({
              subclass: 'entity'
            });
          }
          _this.$('.bv_saving').hide();
          _this.$('.bv_updateComplete').show();
          _this.$('.bv_save').attr('disabled', 'disabled');
          return _this.render();
        };
      })(this));
      this.model.on('change', (function(_this) {
        return function() {
          _this.trigger('amDirty');
          return _this.$('.bv_updateComplete').hide();
        };
      })(this));
      this.errorOwnerName = 'BaseEntityController';
      this.setBindings();
      $(this.el).empty();
      $(this.el).html(this.template());
      this.$('.bv_save').attr('disabled', 'disabled');
      this.setupStatusSelect();
      this.setupRecordedBySelect();
      this.setupTagList();
      return this.model.getStatus().on('change', this.updateEditable);
    };

    BaseEntityController.prototype.render = function() {
      var bestName, subclass;
      if (this.model == null) {
        this.model = new BaseEntity();
      }
      subclass = this.model.get('subclass');
      this.$('.bv_shortDescription').html(this.model.get('shortDescription'));
      bestName = this.model.get('lsLabels').pickBestName();
      if (bestName != null) {
        this.$('.bv_' + subclass + 'Name').val(bestName.get('labelText'));
      }
      this.$('.bv_recordedBy').val(this.model.get('recordedBy'));
      this.$('.bv_' + subclass + 'Code').html(this.model.get('codeName'));
      this.$('.bv_' + subclass + 'Kind').html(this.model.get('lsKind'));
      this.$('.bv_description').html(this.model.getDescription().get('clobValue'));
      this.$('.bv_comments').html(this.model.getComments().get('clobValue'));
      this.$('.bv_completionDate').datepicker();
      this.$('.bv_completionDate').datepicker("option", "dateFormat", "yy-mm-dd");
      if (this.model.getCompletionDate().get('dateValue') != null) {
        this.$('.bv_completionDate').val(UtilityFunctions.prototype.convertMSToYMDDate(this.model.getCompletionDate().get('dateValue')));
      }
      this.$('.bv_notebook').val(this.model.getNotebook().get('stringValue'));
      this.$('.bv_status').val(this.model.getStatus().get('codeValue'));
      if (this.model.isNew()) {
        this.$('.bv_save').html("Save");
      } else {
        this.$('.bv_save').html("Update");
      }
      this.updateEditable();
      return this;
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

    BaseEntityController.prototype.setupRecordedBySelect = function() {
      this.recordedByList = new PickListList();
      this.recordedByList.url = "/api/authors";
      return this.recordedByListController = new PickListSelectController({
        el: this.$('.bv_recordedBy'),
        collection: this.recordedByList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select Scientist"
        }),
        selectedCode: this.model.get('recordedBy')
      });
    };

    BaseEntityController.prototype.setupTagList = function() {
      this.$('.bv_tags').val("");
      this.tagListController = new TagListController({
        el: this.$('.bv_tags'),
        collection: this.model.get('lsTags')
      });
      return this.tagListController.render();
    };

    BaseEntityController.prototype.handleRecordedByChanged = function() {
      this.model.set({
        recordedBy: this.$('.bv_recordedBy').val()
      });
      return this.handleNameChanged();
    };

    BaseEntityController.prototype.handleShortDescriptionChanged = function() {
      var trimmedDesc;
      trimmedDesc = UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_shortDescription'));
      if (trimmedDesc !== "") {
        return this.model.set({
          shortDescription: trimmedDesc
        });
      } else {
        return this.model.set({
          shortDescription: " "
        });
      }
    };

    BaseEntityController.prototype.handleDescriptionChanged = function() {
      return this.model.getDescription().set({
        clobValue: UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_description')),
        recordedBy: this.model.get('recordedBy')
      });
    };

    BaseEntityController.prototype.handleCommentsChanged = function() {
      return this.model.getComments().set({
        clobValue: UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_comments')),
        recordedBy: this.model.get('recordedBy')
      });
    };

    BaseEntityController.prototype.handleNameChanged = function() {
      var newName, subclass;
      subclass = this.model.get('subclass');
      newName = UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_' + subclass + 'Name'));
      this.model.get('lsLabels').setBestName(new Label({
        lsKind: subclass + " name",
        labelText: newName,
        recordedBy: this.model.get('recordedBy')
      }));
      return this.model.trigger('change');
    };

    BaseEntityController.prototype.handleDateChanged = function() {
      this.model.getCompletionDate().set({
        dateValue: UtilityFunctions.prototype.convertYMDDateToMs(UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_completionDate')))
      });
      return this.model.trigger('change');
    };

    BaseEntityController.prototype.handleCompletionDateIconClicked = function() {
      return this.$(".bv_completionDate").datepicker("show");
    };

    BaseEntityController.prototype.handleNotebookChanged = function() {
      this.model.getNotebook().set({
        stringValue: UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_notebook'))
      });
      return this.model.trigger('change');
    };

    BaseEntityController.prototype.handleStatusChanged = function() {
      this.model.getStatus().set({
        codeValue: this.statusListController.getSelectedCode()
      });
      return this.updateEditable();
    };

    BaseEntityController.prototype.updateEditable = function() {
      if (this.model.isEditable()) {
        this.enableAllInputs();
        this.$('.bv_lock').hide();
      } else {
        this.disableAllInputs();
        this.$('.bv_status').removeAttr('disabled');
        this.$('.bv_lock').show();
      }
      if (this.model.isNew()) {
        return this.$('.bv_status').attr("disabled", "disabled");
      } else {
        return this.$('.bv_status').removeAttr("disabled");
      }
    };

    BaseEntityController.prototype.beginSave = function() {
      this.tagListController.handleTagsChanged();
      if (this.model.checkForNewPickListOptions != null) {
        return this.model.checkForNewPickListOptions();
      } else {
        return this.trigger("noEditablePickLists");
      }
    };

    BaseEntityController.prototype.handleSaveClicked = function() {
      this.$('.bv_save').attr('disabled', 'disabled');
      this.tagListController.handleTagsChanged();
      this.model.prepareToSave();
      if (this.model.isNew()) {
        this.$('.bv_updateComplete').html("Save Complete");
      } else {
        this.$('.bv_updateComplete').html("Update Complete");
      }
      this.$('.bv_saving').show();
      return this.model.save();
    };

    BaseEntityController.prototype.validationError = function() {
      BaseEntityController.__super__.validationError.call(this);
      return this.$('.bv_save').attr('disabled', 'disabled');
    };

    BaseEntityController.prototype.clearValidationErrorStyles = function() {
      BaseEntityController.__super__.clearValidationErrorStyles.call(this);
      return this.$('.bv_save').removeAttr('disabled');
    };

    BaseEntityController.prototype.displayInReadOnlyMode = function() {
      this.$(".bv_save").addClass("hide");
      return this.disableAllInputs();
    };

    return BaseEntityController;

  })(AbstractFormController);

}).call(this);
