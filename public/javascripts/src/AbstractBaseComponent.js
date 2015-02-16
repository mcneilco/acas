(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.AbstractBaseComponentParent = (function(_super) {
    __extends(AbstractBaseComponentParent, _super);

    function AbstractBaseComponentParent() {
      this.duplicate = __bind(this.duplicate, this);
      return AbstractBaseComponentParent.__super__.constructor.apply(this, arguments);
    }

    AbstractBaseComponentParent.prototype.validate = function(attrs) {
      var bestName, cDate, errors, nameError, notebook, scientist;
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
          attribute: 'parentName',
          message: "Name must be set"
        });
      }
      if (!this.isNew()) {
        if (attrs.scientist != null) {
          scientist = attrs.scientist.get('value');
          if (scientist === "" || scientist === "unassigned" || scientist === void 0 || scientist === null) {
            errors.push({
              attribute: 'scientist',
              message: "Scientist must be set"
            });
          }
        }
        if (attrs["completion date"] != null) {
          cDate = attrs["completion date"].get('value');
          if (cDate === void 0 || cDate === "" || cDate === null) {
            cDate = "fred";
          }
          if (isNaN(cDate)) {
            errors.push({
              attribute: 'completionDate',
              message: "Date must be set"
            });
          }
        }
        if (attrs.notebook != null) {
          notebook = attrs.notebook.get('value');
          if (notebook === "" || notebook === void 0 || notebook === null) {
            errors.push({
              attribute: 'notebook',
              message: "Notebook must be set"
            });
          }
        }
      }
      if (errors.length > 0) {
        return errors;
      } else {
        return null;
      }
    };

    AbstractBaseComponentParent.prototype.prepareToSave = function() {
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
      return this.get('lsStates').each(function(state) {
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
    };

    AbstractBaseComponentParent.prototype.duplicate = function() {
      var copiedThing;
      copiedThing = AbstractBaseComponentParent.__super__.duplicate.call(this);
      copiedThing.get("batch number").set({
        value: 0
      });
      return copiedThing;
    };

    return AbstractBaseComponentParent;

  })(Thing);

  window.AbstractBaseComponentBatch = (function(_super) {
    __extends(AbstractBaseComponentBatch, _super);

    function AbstractBaseComponentBatch() {
      return AbstractBaseComponentBatch.__super__.constructor.apply(this, arguments);
    }

    AbstractBaseComponentBatch.prototype.validate = function(attrs) {
      var amountMade, cDate, errors, location, notebook, scientist, source;
      errors = [];
      if (attrs.scientist != null) {
        scientist = attrs.scientist.get('value');
        if (scientist === "" || scientist === "unassigned" || scientist === void 0 || scientist === null) {
          errors.push({
            attribute: 'scientist',
            message: "Scientist must be set"
          });
        }
      }
      if (attrs["completion date"] != null) {
        cDate = attrs["completion date"].get('value');
        if (cDate === null || cDate === "") {
          cDate = "fred";
        }
        if (isNaN(cDate)) {
          errors.push({
            attribute: 'completionDate',
            message: "Date must be set"
          });
        }
      }
      if (attrs.source != null) {
        source = attrs.source.get('value');
        if (source === "unassigned" || source === void 0 || source === null) {
          errors.push({
            attribute: 'source',
            message: "Source must be set"
          });
        }
      }
      if (attrs.notebook != null) {
        notebook = attrs.notebook.get('value');
        if (notebook === "" || notebook === void 0 || notebook === null) {
          errors.push({
            attribute: 'notebook',
            message: "Notebook must be set"
          });
        }
      }
      if (attrs["amount made"] != null) {
        amountMade = attrs["amount made"].get('value');
        if (amountMade === "" || amountMade === void 0 || isNaN(amountMade) || amountMade === null) {
          errors.push({
            attribute: 'amountMade',
            message: "Amount must be set"
          });
        }
        if (isNaN(amountMade)) {
          errors.push({
            attribute: 'amountMade',
            message: "Amount must be a number"
          });
        }
      }
      if (attrs.location != null) {
        location = attrs.location.get('value');
        if (location === "" || location === void 0 || location === null) {
          errors.push({
            attribute: 'location',
            message: "Location must be set"
          });
        }
      }
      if (errors.length > 0) {
        return errors;
      } else {
        return null;
      }
    };

    AbstractBaseComponentBatch.prototype.prepareToSave = function() {
      var rBy, rDate;
      rBy = this.get('recordedBy');
      rDate = new Date().getTime();
      this.set({
        recordedDate: rDate
      });
      return this.get('lsStates').each(function(state) {
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
    };

    return AbstractBaseComponentBatch;

  })(Thing);

  window.AbstractBaseComponentParentController = (function(_super) {
    __extends(AbstractBaseComponentParentController, _super);

    function AbstractBaseComponentParentController() {
      this.updateBatchNumber = __bind(this.updateBatchNumber, this);
      this.displayInReadOnlyMode = __bind(this.displayInReadOnlyMode, this);
      this.handleUpdateParent = __bind(this.handleUpdateParent, this);
      this.handleValidateReturn = __bind(this.handleValidateReturn, this);
      this.clearValidationErrorStyles = __bind(this.clearValidationErrorStyles, this);
      this.validationError = __bind(this.validationError, this);
      this.updateModel = __bind(this.updateModel, this);
      this.handleCompletionDateIconClicked = __bind(this.handleCompletionDateIconClicked, this);
      this.modelChangeCallback = __bind(this.modelChangeCallback, this);
      this.modelSaveCallback = __bind(this.modelSaveCallback, this);
      this.render = __bind(this.render, this);
      this.initialize = __bind(this.initialize, this);
      return AbstractBaseComponentParentController.__super__.constructor.apply(this, arguments);
    }

    AbstractBaseComponentParentController.prototype.template = _.template($("#AbstractBaseComponentParentView").html());

    AbstractBaseComponentParentController.prototype.events = function() {
      return {
        "keyup .bv_parentName": "attributeChanged",
        "change .bv_scientist": "attributeChanged",
        "keyup .bv_completionDate": "attributeChanged",
        "click .bv_completionDateIcon": "handleCompletionDateIconClicked",
        "keyup .bv_notebook": "attributeChanged",
        "click .bv_updateParent": "handleUpdateParent"
      };
    };

    AbstractBaseComponentParentController.prototype.initialize = function() {
      this.setBindings();
      if (this.options.readOnly != null) {
        this.readOnly = this.options.readOnly;
      } else {
        this.readOnly = false;
      }
      this.listenTo(this.model, 'sync', this.modelSaveCallback);
      this.listenTo(this.model, 'change', this.modelChangeCallback);
      $(this.el).empty();
      $(this.el).html(this.template());
      if (this.componentPickerTemplate != null) {
        this.setupComponentPickerController();
      }
      if (this.additionalParentAttributesTemplate != null) {
        this.$('.bv_additionalParentAttributes').html(this.additionalParentAttributesTemplate());
      }
      return this.setupScientistSelect();
    };

    AbstractBaseComponentParentController.prototype.render = function() {
      var bestName, codeName;
      codeName = this.model.get('codeName');
      this.$('.bv_parentCode').val(codeName);
      this.$('.bv_parentCode').html(codeName);
      bestName = this.model.get('lsLabels').pickBestName();
      if (bestName != null) {
        this.$('.bv_parentName').val(bestName.get('labelText'));
      }
      this.$('.bv_scientist').val(this.model.get('scientist').get('value'));
      this.$('.bv_completionDate').datepicker();
      this.$('.bv_completionDate').datepicker("option", "dateFormat", "yy-mm-dd");
      if (this.model.get('completion date').get('value') != null) {
        this.$('.bv_completionDate').val(UtilityFunctions.prototype.convertMSToYMDDate(this.model.get('completion date').get('value')));
      }
      this.$('.bv_notebook').val(this.model.get('notebook').get('value'));
      if (this.model.isNew()) {
        this.$('.bv_scientist').attr('disabled', 'disabled');
        this.$('.bv_completionDate').attr('disabled', 'disabled');
        this.$('.bv_notebook').attr('disabled', 'disabled');
        this.$('.bv_completionDateIcon').on("click", function() {
          return false;
        });
      } else {
        this.$('.bv_scientist').removeAttr('disabled');
        this.$('.bv_completionDate').removeAttr('disabled');
        this.$('.bv_notebook').removeAttr('disabled');
        this.$('.bv_completionDateIcon').on("click", function() {
          return true;
        });
      }
      if (this.readOnly === true) {
        this.displayInReadOnlyMode();
      }
      return this;
    };

    AbstractBaseComponentParentController.prototype.modelSaveCallback = function(method, model) {
      this.$('.bv_updateParent').show();
      this.$('.bv_updateParent').attr('disabled', 'disabled');
      this.$('.bv_updateParentComplete').show();
      this.$('.bv_updatingParent').hide();
      this.trigger('amClean');
      this.trigger('parentSaved');
      return this.render();
    };

    AbstractBaseComponentParentController.prototype.modelChangeCallback = function(method, model) {
      this.trigger('amDirty');
      return this.$('.bv_updateParentComplete').hide();
    };

    AbstractBaseComponentParentController.prototype.setupComponentPickerController = function() {
      this.componentPickerController = new ComponentPickerController({
        el: this.$('.bv_componentPicker')
      });
      this.componentPickerController.on('amDirty', (function(_this) {
        return function() {
          return _this.trigger('amDirty');
        };
      })(this));
      this.componentPickerController.on('amClean', (function(_this) {
        return function() {
          return _this.trigger('amClean');
        };
      })(this));
      return this.componentPickerController.render();
    };

    AbstractBaseComponentParentController.prototype.setupScientistSelect = function() {
      var defaultOption;
      if (this.model.isNew()) {
        defaultOption = "Filled from first batch";
      } else {
        defaultOption = "Select Scientist";
      }
      this.scientistList = new PickListList();
      this.scientistList.url = "/api/authors";
      return this.scientistListController = new PickListSelectController({
        el: this.$('.bv_scientist'),
        collection: this.scientistList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: defaultOption
        }),
        selectedCode: this.model.get('scientist').get('value')
      });
    };

    AbstractBaseComponentParentController.prototype.handleCompletionDateIconClicked = function() {
      return this.$(".bv_completionDate").datepicker("show");
    };

    AbstractBaseComponentParentController.prototype.updateModel = function() {
      console.log("update abc parent model");
      this.model.get("scientist").set("value", this.scientistListController.getSelectedCode());
      this.model.get("notebook").set("value", UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_notebook')));
      return this.model.get("completion date").set("value", UtilityFunctions.prototype.convertYMDDateToMs(UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_completionDate'))));
    };

    AbstractBaseComponentParentController.prototype.validationError = function() {
      AbstractBaseComponentParentController.__super__.validationError.call(this);
      return this.$('.bv_updateParent').attr('disabled', 'disabled');
    };

    AbstractBaseComponentParentController.prototype.clearValidationErrorStyles = function() {
      AbstractBaseComponentParentController.__super__.clearValidationErrorStyles.call(this);
      return this.$('.bv_updateParent').removeAttr('disabled');
    };

    AbstractBaseComponentParentController.prototype.validateParentName = function() {
      var lsKind, name;
      this.$('.bv_updateParent').attr('disabled', 'disabled');
      lsKind = this.model.get('lsKind');
      name = [this.model.get(lsKind + ' name').get('labelText')];
      return $.ajax({
        type: 'POST',
        url: "/api/validateName/" + lsKind,
        data: {
          requestName: name
        },
        success: (function(_this) {
          return function(response) {
            return _this.handleValidateReturn(response);
          };
        })(this),
        error: (function(_this) {
          return function(err) {
            return _this.serviceReturn = null;
          };
        })(this),
        dataType: 'json'
      });
    };

    AbstractBaseComponentParentController.prototype.handleValidateReturn = function(validNewLabel) {
      if (validNewLabel === true) {
        return this.handleUpdateParent();
      } else {
        return alert('The requested parent name has already been registered. Please choose a new parent name.');
      }
    };

    AbstractBaseComponentParentController.prototype.handleUpdateParent = function() {
      this.model.reformatBeforeSaving();
      this.$('.bv_updatingParent').show();
      this.$('.bv_updateParentComplete').html('Update Complete.');
      this.$('.bv_updateParent').attr('disabled', 'disabled');
      return this.model.save();
    };

    AbstractBaseComponentParentController.prototype.displayInReadOnlyMode = function() {
      this.$(".bv_updateParent").hide();
      this.$('button').attr('disabled', 'disabled');
      this.$(".bv_completionDateIcon").addClass("uneditable-input");
      this.$(".bv_completionDateIcon").on("click", function() {
        return false;
      });
      return this.disableAllInputs();
    };

    AbstractBaseComponentParentController.prototype.updateBatchNumber = function() {
      return this.model.fetch({
        success: console.log(this.model)
      });
    };

    return AbstractBaseComponentParentController;

  })(AbstractFormController);

  window.AbstractBaseComponentBatchController = (function(_super) {
    __extends(AbstractBaseComponentBatchController, _super);

    function AbstractBaseComponentBatchController() {
      this.displayInReadOnlyMode = __bind(this.displayInReadOnlyMode, this);
      this.isValid = __bind(this.isValid, this);
      this.saveAnalyticalMethod = __bind(this.saveAnalyticalMethod, this);
      this.handleSaveBatch = __bind(this.handleSaveBatch, this);
      this.clearValidationErrorStyles = __bind(this.clearValidationErrorStyles, this);
      this.validationError = __bind(this.validationError, this);
      this.updateModel = __bind(this.updateModel, this);
      this.handleCompletionDateIconClicked = __bind(this.handleCompletionDateIconClicked, this);
      this.setupAttachFileListController = __bind(this.setupAttachFileListController, this);
      this.modelChangeCallback = __bind(this.modelChangeCallback, this);
      this.modelSaveCallback = __bind(this.modelSaveCallback, this);
      this.render = __bind(this.render, this);
      return AbstractBaseComponentBatchController.__super__.constructor.apply(this, arguments);
    }

    AbstractBaseComponentBatchController.prototype.template = _.template($("#AbstractBaseComponentBatchView").html());

    AbstractBaseComponentBatchController.prototype.events = function() {
      return {
        "change .bv_scientist": "attributeChanged",
        "keyup .bv_completionDate": "attributeChanged",
        "click .bv_completionDateIcon": "handleCompletionDateIconClicked",
        "change .bv_source": "attributeChanged",
        "keyup .bv_sourceId": "attributeChanged",
        "keyup .bv_notebook": "attributeChanged",
        "keyup .bv_amountMade": "attributeChanged",
        "keyup .bv_location": "attributeChanged",
        "click .bv_saveBatch": "handleSaveBatch"
      };
    };

    AbstractBaseComponentBatchController.prototype.initialize = function() {
      this.setBindings();
      this.parentCodeName = this.options.parentCodeName;
      this.listenTo(this.model, 'sync', this.modelSaveCallback);
      this.listenTo(this.model, 'change', this.modelChangeCallback);
      $(this.el).empty();
      $(this.el).html(this.template());
      if (this.additionalBatchAttributesTemplate != null) {
        this.$('.bv_additionalBatchAttributes').html(this.additionalBatchAttributesTemplate());
      }
      this.setupScientistSelect();
      this.setupSourceSelect();
      return this.setupAttachFileListController();
    };

    AbstractBaseComponentBatchController.prototype.render = function() {
      this.$('.bv_batchCode').val(this.model.get('codeName'));
      this.$('.bv_batchCode').html(this.model.get('codeName'));
      this.$('.bv_scientist').val(this.model.get('scientist').get('value'));
      this.$('.bv_completionDate').datepicker();
      this.$('.bv_completionDate').datepicker("option", "dateFormat", "yy-mm-dd");
      if (this.model.get('completion date').get('value') != null) {
        this.$('.bv_completionDate').val(UtilityFunctions.prototype.convertMSToYMDDate(this.model.get('completion date').get('value')));
      } else {
        this.$('.bv_completionDate').val("");
      }
      this.$('.bv_source').val(this.model.get('source').get('value'));
      this.$('.bv_sourceId').val(this.model.get('source id').get('value'));
      this.$('.bv_notebook').val(this.model.get('notebook').get('value'));
      this.$('.bv_amountMade').val(this.model.get('amount made').get('value'));
      this.$('.bv_location').val(this.model.get('location').get('value'));
      if (this.model.isNew()) {
        this.$('.bv_saveBatch').html("Save Batch");
      } else {
        this.$('.bv_saveBatch').html("Update Batch");
      }
      this.trigger('renderComplete');
      if (this.parentCodeName === void 0) {
        this.$('.bv_saveBatch').hide();
      } else {
        this.$('.bv_saveBatch').show();
      }
      return this;
    };

    AbstractBaseComponentBatchController.prototype.modelSaveCallback = function(method, model) {
      this.$('.bv_saveBatch').show();
      this.$('.bv_saveBatch').attr('disabled', 'disabled');
      this.$('.bv_savingBatch').hide();
      this.render();
      this.trigger('amClean');
      return this.trigger('batchSaved');
    };

    AbstractBaseComponentBatchController.prototype.modelChangeCallback = function(method, model) {
      this.trigger('amDirty');
      return this.$('.bv_saveBatchComplete').hide();
    };

    AbstractBaseComponentBatchController.prototype.setupScientistSelect = function() {
      this.scientistList = new PickListList();
      this.scientistList.url = "/api/authors";
      return this.scientistListController = new PickListSelectController({
        el: this.$('.bv_scientist'),
        collection: this.scientistList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select Scientist"
        }),
        selectedCode: this.model.get('scientist').get('value')
      });
    };

    AbstractBaseComponentBatchController.prototype.setupSourceSelect = function() {
      this.sourceList = new PickListList();
      this.sourceList.url = "/api/codetables/component/source";
      return this.sourceListController = new PickListSelectController({
        el: this.$('.bv_source'),
        collection: this.sourceList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select Source"
        }),
        selectedCode: this.model.get('source').get('value')
      });
    };

    AbstractBaseComponentBatchController.prototype.setupAttachFileListController = function() {
      return $.ajax({
        type: 'GET',
        url: "/api/codetables/analytical method/file type",
        dataType: 'json',
        error: function(err) {
          return alert('Could not get list of analytical file types');
        },
        success: (function(_this) {
          return function(json) {
            var attachFileList;
            if (json.length === 0) {
              return alert('Got empty list of analytical file types');
            } else {
              _this.analyticalMethodFileTypesJSON = json;
              attachFileList = _this.model.getAnalyticalFiles(json);
              return _this.finishSetupAttachFileListController(attachFileList);
            }
          };
        })(this)
      });
    };

    AbstractBaseComponentBatchController.prototype.finishSetupAttachFileListController = function(attachFileList) {
      this.attachFileListController = new AttachFileListController({
        autoAddAttachFileModel: false,
        el: this.$('.bv_attachFileList'),
        collection: attachFileList,
        firstOptionName: "Select Method",
        allowedFileTypes: ['pdf'],
        fileTypeListURL: "/api/codetables/analytical method/file type"
      });
      this.attachFileListController.on('amDirty', (function(_this) {
        return function() {
          return _this.trigger('amDirty');
        };
      })(this));
      this.attachFileListController.on('amClean', (function(_this) {
        return function() {
          return _this.trigger('amClean');
        };
      })(this));
      this.attachFileListController.on('renderComplete', (function(_this) {
        return function() {
          return _this.trigger('renderComplete');
        };
      })(this));
      return this.attachFileListController.render();
    };

    AbstractBaseComponentBatchController.prototype.handleCompletionDateIconClicked = function() {
      return this.$(".bv_completionDate").datepicker("show");
    };

    AbstractBaseComponentBatchController.prototype.updateModel = function() {
      this.model.get("scientist").set("value", this.scientistListController.getSelectedCode());
      this.model.get("source").set("value", this.sourceListController.getSelectedCode());
      this.model.get("source id").set("value", UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_sourceId')));
      this.model.get("notebook").set("value", UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_notebook')));
      this.model.get("completion date").set("value", UtilityFunctions.prototype.convertYMDDateToMs(UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_completionDate'))));
      this.model.get("amount made").set("value", parseFloat(UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_amountMade'))));
      return this.model.get("location").set("value", UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_location')));
    };

    AbstractBaseComponentBatchController.prototype.validationError = function() {
      AbstractBaseComponentBatchController.__super__.validationError.call(this);
      return this.$('.bv_saveBatch').attr('disabled', 'disabled');
    };

    AbstractBaseComponentBatchController.prototype.clearValidationErrorStyles = function() {
      AbstractBaseComponentBatchController.__super__.clearValidationErrorStyles.call(this);
      return this.$('.bv_saveBatch').removeAttr('disabled');
    };

    AbstractBaseComponentBatchController.prototype.handleSaveBatch = function() {
      this.$('.bv_savingBatch').show();
      this.saveAnalyticalMethod();
      this.model.prepareToSave();
      this.model.reformatBeforeSaving();
      if (this.model.isNew() === true) {
        this.model.urlRoot = this.model.urlRoot + "/" + this.parentCodeName;
      } else {
        this.model.urlRoot = this.model.get('urlRoot');
      }
      this.$('.bv_saveBatch').attr('disabled', 'disabled');
      return this.model.save();
    };

    AbstractBaseComponentBatchController.prototype.saveAnalyticalMethod = function() {
      var analyticalMethodValue, fileType, fileValue, matchedModel, _i, _len, _ref, _results;
      console.log("save analytical method");
      console.log(this.model);
      _ref = this.analyticalMethodFileTypesJSON;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        fileType = _ref[_i];
        console.log(this.attachFileListController.collection);
        console.log(fileType);
        matchedModel = this.attachFileListController.collection.findWhere({
          fileType: fileType.code
        });
        analyticalMethodValue = this.model.get('lsStates').getOrCreateValueByTypeAndKind("metadata", this.model.get('lsKind') + " batch", "fileValue", fileType.code);
        if (matchedModel === void 0) {
          console.log("no matched model");
          _results.push(analyticalMethodValue.set({
            fileValue: ""
          }));
        } else {
          console.log("matched model");
          fileValue = matchedModel.get('fileValue');
          console.log(fileValue);
          _results.push(analyticalMethodValue.set({
            fileValue: fileValue
          }));
        }
      }
      return _results;
    };

    AbstractBaseComponentBatchController.prototype.isValid = function() {
      var validCheck;
      validCheck = AbstractBaseComponentBatchController.__super__.isValid.call(this);
      if (this.attachFileListController != null) {
        if (this.attachFileListController.isValid() === true) {
          return validCheck;
        } else {
          return false;
        }
      } else {
        return validCheck;
      }
    };

    AbstractBaseComponentBatchController.prototype.displayInReadOnlyMode = function() {
      this.$(".bv_saveBatch").addClass("hide");
      this.$('button').attr('disabled', 'disabled');
      this.$(".bv_completionDateIcon").addClass("uneditable-input");
      this.$(".bv_completionDateIcon").on("click", function() {
        return false;
      });
      return this.disableAllInputs();
    };

    return AbstractBaseComponentBatchController;

  })(AbstractFormController);

  window.AbstractBaseComponentBatchSelectController = (function(_super) {
    __extends(AbstractBaseComponentBatchSelectController, _super);

    function AbstractBaseComponentBatchSelectController() {
      this.displayInReadOnlyMode = __bind(this.displayInReadOnlyMode, this);
      this.checkDisplayMode = __bind(this.checkDisplayMode, this);
      this.setupBatchRegForm = __bind(this.setupBatchRegForm, this);
      this.finishBatchSetup = __bind(this.finishBatchSetup, this);
      this.translateIntoPickListFormat = __bind(this.translateIntoPickListFormat, this);
      this.setupBatchSelect = __bind(this.setupBatchSelect, this);
      this.initialize = __bind(this.initialize, this);
      return AbstractBaseComponentBatchSelectController.__super__.constructor.apply(this, arguments);
    }

    AbstractBaseComponentBatchSelectController.prototype.template = _.template($("#AbstractBaseComponentBatchSelectView").html());

    AbstractBaseComponentBatchSelectController.prototype.events = function() {
      return {
        "change .bv_batchList": "handleSelectedBatchChanged"
      };
    };

    AbstractBaseComponentBatchSelectController.prototype.initialize = function() {
      this.parentCodeName = this.options.parentCodeName;
      if (this.options.batchCodeName != null) {
        this.batchCodeName = this.options.batchCodeName;
      } else {
        this.batchCodeName = "new batch";
      }
      if (this.options.readOnly != null) {
        this.readOnly = this.options.readOnly;
      } else {
        this.readOnly = false;
      }
      $(this.el).empty();
      $(this.el).html(this.template());
      return this.setupBatchSelect();
    };

    AbstractBaseComponentBatchSelectController.prototype.setupBatchSelect = function() {
      if (this.setupBatch == null) {
        this.setupBatch = true;
      }
      this.batchList = new PickListList();
      this.batchList.url = "/api/batches/" + this.options.lsKind + "/parentCodeName/" + this.parentCodeName;
      return $.ajax({
        type: 'GET',
        url: this.batchList.url,
        dataType: 'json',
        error: function(err) {
          return alert('Could not get batch list');
        },
        success: (function(_this) {
          return function(json) {
            _this.batchList = new ComponentList(json);
            return _this.translateIntoPickListFormat();
          };
        })(this)
      });
    };

    AbstractBaseComponentBatchSelectController.prototype.translateIntoPickListFormat = function() {
      var codes;
      codes = new PickListList;
      this.batchList.each((function(_this) {
        return function(batch) {
          var batchOption;
          batchOption = new PickList({
            code: batch.get('codeName'),
            name: batch.get('codeName'),
            ignored: batch.get('ignored')
          });
          return codes.add(batchOption);
        };
      })(this));
      this.batchListOptions = codes;
      return this.finishBatchSetup();
    };

    AbstractBaseComponentBatchSelectController.prototype.finishBatchSetup = function() {
      this.batchListController = new PickListSelectController({
        el: this.$('.bv_batchList'),
        collection: this.batchListOptions,
        insertFirstOption: new PickList({
          code: "new batch",
          name: "Register New Batch"
        }),
        selectedCode: this.batchCodeName,
        autoFetch: false
      });
      this.batchListController.render();
      if (this.setupBatch === true) {
        if (this.batchModel === void 0) {
          return this.handleSelectedBatchChanged();
        } else {
          return this.setupBatchRegForm();
        }
      } else {
        return this.setupBatch = true;
      }
    };

    AbstractBaseComponentBatchSelectController.prototype.setupBatchRegForm = function() {
      var lsKind;
      lsKind = this.batchModel.get('lsKind');
      lsKind = lsKind.replace(/(^|[^a-z0-9-])([a-z])/g, function(m, m1, m2, p) {
        return m1 + m2.toUpperCase();
      });
      lsKind = lsKind.replace(/\s/g, '');
      if (this.batchController != null) {
        this.batchController.undelegateEvents();
      }
      this.batchController = new window[lsKind + "BatchController"]({
        model: this.batchModel,
        el: this.$('.bv_batchRegForm'),
        parentCodeName: this.parentCodeName,
        readOnly: this.readOnly
      });
      this.batchController.on('amDirty', (function(_this) {
        return function() {
          return _this.trigger('amDirty');
        };
      })(this));
      this.batchController.on('amClean', (function(_this) {
        return function() {
          return _this.trigger('amClean');
        };
      })(this));
      this.batchController.on('batchSaved', (function(_this) {
        return function() {
          _this.batchCodeName = _this.batchController.model.get('codeName');
          _this.batchModel = _this.batchController.model;
          _this.setupBatch = false;
          _this.setupBatchSelect();
          _this.$('.bv_saveBatchComplete').show();
          return _this.trigger('batchSaved');
        };
      })(this));
      this.batchController.on('renderComplete', (function(_this) {
        return function() {
          return _this.checkDisplayMode();
        };
      })(this));
      this.batchController.render();
      if (this.setupBatch === false) {
        this.$('.bv_saveBatchComplete').show();
        this.setupBatch = true;
      }
      this.$('.bv_saveBatch').attr('disabled', 'disabled');
      if (this.batchController.model.isNew()) {
        this.$('.bv_saveBatch').html("Save Batch");
        return this.$('.bv_saveBatchComplete').html("Save Complete");
      } else {
        this.$('.bv_saveBatch').html("Update Batch");
        return this.$('.bv_saveBatchComplete').html("Update Complete");
      }
    };

    AbstractBaseComponentBatchSelectController.prototype.checkIfFirstBatch = function() {
      return this.batchListController.collection.length === 1;
    };

    AbstractBaseComponentBatchSelectController.prototype.checkDisplayMode = function() {
      if (this.readOnly === true) {
        return this.displayInReadOnlyMode();
      }
    };

    AbstractBaseComponentBatchSelectController.prototype.displayInReadOnlyMode = function() {
      this.$('.bv_batchList').attr('disabled', 'disabled');
      if (this.batchController != null) {
        return this.batchController.displayInReadOnlyMode();
      }
    };

    return AbstractBaseComponentBatchSelectController;

  })(Backbone.View);

  window.AbstractBaseComponentController = (function(_super) {
    __extends(AbstractBaseComponentController, _super);

    function AbstractBaseComponentController() {
      this.saveFirstBatch = __bind(this.saveFirstBatch, this);
      this.saveNewParentAttributes = __bind(this.saveNewParentAttributes, this);
      this.handleSaveClicked = __bind(this.handleSaveClicked, this);
      this.handleValidateReturn = __bind(this.handleValidateReturn, this);
      this.handleBatchSaved = __bind(this.handleBatchSaved, this);
      this.setupBatchSelectController = __bind(this.setupBatchSelectController, this);
      this.completeInitialization = __bind(this.completeInitialization, this);
      return AbstractBaseComponentController.__super__.constructor.apply(this, arguments);
    }

    AbstractBaseComponentController.prototype.template = _.template($("#AbstractBaseComponentView").html());

    AbstractBaseComponentController.prototype.events = function() {
      return {
        "click .bv_save": "validateParentName"
      };
    };

    AbstractBaseComponentController.prototype.completeInitialization = function() {
      $(this.el).html(this.template());
      if (this.batchCodeName == null) {
        if (this.options.batchCodeName != null) {
          this.batchCodeName = this.options.batchCodeName;
        } else {
          this.batchCodeName = "new batch";
        }
      }
      if (this.readOnly == null) {
        if (this.options.readOnly != null) {
          this.readOnly = this.options.readOnly;
        } else {
          this.readOnly = false;
        }
      }
      if (this.batchModel == null) {
        if (this.options.batchModel != null) {
          this.batchModel = this.options.batchModel;
        } else {
          this.batchModel = null;
        }
      }
      this.setupParentController();
      this.setupBatchSelectController();
      this.$('.bv_save').attr('disabled', 'disabled');
      if (this.parentController.model.isNew()) {
        this.$('.bv_updateParent').hide();
        return this.$('.bv_saveBatch').hide();
      } else {
        this.$('.bv_save').hide();
        this.$('.bv_updateParent').show();
        return this.$('.bv_saveBatch').show();
      }
    };

    AbstractBaseComponentController.prototype.setupParentController = function() {
      this.parentController.on('amDirty', (function(_this) {
        return function() {
          _this.checkFormValid();
          return _this.trigger('amDirty');
        };
      })(this));
      this.parentController.on('amClean', (function(_this) {
        return function() {
          return _this.trigger('amClean');
        };
      })(this));
      this.parentController.on('parentSaved', (function(_this) {
        return function() {
          return _this.handleParentSaved();
        };
      })(this));
      this.parentController.render();
      this.$('.bv_updateParent').attr('disabled', 'disabled');
      return this.firstSave = this.parentController.model.isNew();
    };

    AbstractBaseComponentController.prototype.handleParentSaved = function() {
      if (this.firstSave === true) {
        this.$('.bv_saveParentComplete').show();
        return this.firstSave = false;
      } else {
        this.$('.bv_saveParentComplete').hide();
        return this.$('.bv_saveFirstBatchComplete').hide();
      }
    };

    AbstractBaseComponentController.prototype.setupBatchSelectController = function() {
      this.batchSelectController.on('amDirty', (function(_this) {
        return function() {
          _this.trigger('amDirty');
          return _this.checkFormValid();
        };
      })(this));
      this.batchSelectController.on('amClean', (function(_this) {
        return function() {
          return _this.trigger('amClean');
        };
      })(this));
      this.batchSelectController.on('batchSaved', (function(_this) {
        return function() {
          _this.handleBatchSaved();
          return _this.parentController.updateBatchNumber();
        };
      })(this));
      return this.batchSelectController.render();
    };

    AbstractBaseComponentController.prototype.handleBatchSaved = function() {
      if (this.batchSelectController.checkIfFirstBatch() === true) {
        this.$('.bv_saveFirstBatchComplete').show();
      } else {
        this.$('.bv_saveFirstBatchComplete').hide();
        this.$('.bv_saveParentComplete').hide();
      }
      this.$('.bv_saveBatch').show();
      return this.$('.bv_saving').hide();
    };

    AbstractBaseComponentController.prototype.checkFormValid = function() {
      if (this.parentController.isValid() && this.batchSelectController.batchController.isValid()) {
        return this.$('.bv_save').removeAttr('disabled');
      } else {
        return this.$('.bv_save').attr('disabled', 'disabled');
      }
    };

    AbstractBaseComponentController.prototype.validateParentName = function() {
      var lsKind, name;
      this.$('.bv_save').attr('disabled', 'disabled');
      lsKind = this.model.get('lsKind');
      name = [this.model.get(lsKind + ' name').get('labelText')];
      return $.ajax({
        type: 'POST',
        url: "/api/validateName/" + lsKind,
        data: {
          requestName: name
        },
        success: (function(_this) {
          return function(response) {
            return _this.handleValidateReturn(response);
          };
        })(this),
        error: (function(_this) {
          return function(err) {
            return _this.serviceReturn = null;
          };
        })(this),
        dataType: 'json'
      });
    };

    AbstractBaseComponentController.prototype.handleValidateReturn = function(validNewLabel) {
      if (validNewLabel === true) {
        return this.handleSaveClicked();
      } else {
        return alert('The requested parent name has already been registered. Please choose a new parent name.');
      }
    };

    AbstractBaseComponentController.prototype.handleSaveClicked = function() {
      this.saveNewParentAttributes();
      this.parentController.model.prepareToSave();
      this.$('.bv_save').hide();
      this.$('.bv_saving').show();
      this.parentController.model.reformatBeforeSaving();
      this.$('.bv_updateParentComplete').html("Save Complete");
      return this.parentController.model.save(this.parentController.model.attributes, {
        success: this.saveFirstBatch
      });
    };

    AbstractBaseComponentController.prototype.saveNewParentAttributes = function() {
      var cDate, notebook, scientist;
      scientist = this.batchSelectController.batchController.model.get('scientist').get('value');
      cDate = this.batchSelectController.batchController.model.get('completion date').get('value');
      notebook = this.batchSelectController.batchController.model.get('notebook').get('value');
      this.parentController.model.get('scientist').set('value', scientist);
      this.parentController.model.get('completion date').set('value', cDate);
      return this.parentController.model.get('notebook').set('value', notebook);
    };

    AbstractBaseComponentController.prototype.saveFirstBatch = function(json) {
      var batchDataToPost;
      this.batchSelectController.batchController.saveAnalyticalMethod();
      this.batchSelectController.batchController.model.prepareToSave();
      this.batchSelectController.batchController.model.reformatBeforeSaving();
      this.$('.bv_saveBatch').html("Save Batch");
      batchDataToPost = this.batchSelectController.batchController.model;
      this.parentCodeName = this.parentController.model.get('codeName');
      this.batchSelectController.parentCodeName = this.parentCodeName;
      batchDataToPost.urlRoot = batchDataToPost.urlRoot + "/" + this.parentCodeName;
      return this.batchSelectController.batchController.model.save();
    };

    return AbstractBaseComponentController;

  })(Backbone.View);

}).call(this);
