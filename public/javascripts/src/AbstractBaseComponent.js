(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.AbstractBaseComponentParent = (function(_super) {
    __extends(AbstractBaseComponentParent, _super);

    function AbstractBaseComponentParent() {
      return AbstractBaseComponentParent.__super__.constructor.apply(this, arguments);
    }

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

    return AbstractBaseComponentParent;

  })(Thing);

  window.AbstractBaseComponentBatch = (function(_super) {
    __extends(AbstractBaseComponentBatch, _super);

    function AbstractBaseComponentBatch() {
      return AbstractBaseComponentBatch.__super__.constructor.apply(this, arguments);
    }

    AbstractBaseComponentBatch.prototype.validate = function(attrs) {
      var amount, cDate, errors, location, notebook;
      errors = [];
      if (_.isNaN(attrs.recordedDate)) {
        errors.push({
          attribute: 'recordedDate',
          message: "Recorded date must be set"
        });
      }
      if (attrs.recordedBy === "" || attrs.recordedBy === "unassigned") {
        errors.push({
          attribute: 'recordedBy',
          message: "Scientist must be set"
        });
      }
      if (attrs["completion date"] != null) {
        cDate = attrs["completion date"].get('value');
        if (cDate === void 0 || cDate === "") {
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
        if (notebook === "" || notebook === void 0) {
          errors.push({
            attribute: 'notebook',
            message: "Notebook must be set"
          });
        }
      }
      if (attrs.amount != null) {
        amount = attrs.amount.get('value');
        if (amount === "" || amount === void 0 || isNaN(amount)) {
          errors.push({
            attribute: 'amount',
            message: "Amount must be set"
          });
        }
      }
      if (attrs.location != null) {
        location = attrs.location.get('value');
        if (location === "" || location === void 0) {
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
      this.handleUpdateParent = __bind(this.handleUpdateParent, this);
      this.clearValidationErrorStyles = __bind(this.clearValidationErrorStyles, this);
      this.validationError = __bind(this.validationError, this);
      this.updateModel = __bind(this.updateModel, this);
      this.handleCompletionDateIconClicked = __bind(this.handleCompletionDateIconClicked, this);
      this.render = __bind(this.render, this);
      return AbstractBaseComponentParentController.__super__.constructor.apply(this, arguments);
    }

    AbstractBaseComponentParentController.prototype.template = _.template($("#AbstractBaseComponentParentView").html());

    AbstractBaseComponentParentController.prototype.events = function() {
      return {
        "keyup .bv_parentName": "attributeChanged",
        "change .bv_recordedBy": "attributeChanged",
        "keyup .bv_completionDate": "attributeChanged",
        "click .bv_completionDateIcon": "handleCompletionDateIconClicked",
        "keyup .bv_notebook": "attributeChanged",
        "click .bv_updateParent": "handleUpdateParent"
      };
    };

    AbstractBaseComponentParentController.prototype.initialize = function() {
      console.log("initialize parent controller");
      this.setBindings();
      this.listenTo(this.model, 'sync', this.modelSaveCallback);
      this.listenTo(this.model, 'change', this.modelChangeCallback);
      $(this.el).empty();
      $(this.el).html(this.template());
      console.log("autofill template?");
      console.log(this.additionalParentAttributesTemplate != null);
      if (this.additionalParentAttributesTemplate != null) {
        this.$('.bv_additionalParentAttributes').html(this.additionalParentAttributesTemplate());
      }
      return this.setupRecordedBySelect();
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
      this.$('.bv_recordedBy').val(this.model.get('recordedBy'));
      console.log(this.model.get('recordedBy'));
      this.$('.bv_completionDate').datepicker();
      this.$('.bv_completionDate').datepicker("option", "dateFormat", "yy-mm-dd");
      if (this.model.get('completion date').get('value') != null) {
        this.$('.bv_completionDate').val(UtilityFunctions.prototype.convertMSToYMDDate(this.model.get('completion date').get('value')));
      }
      this.$('.bv_notebook').val(this.model.get('notebook').get('value'));
      if (this.model.isNew()) {
        console.log("model is new");
        this.$('.bv_recordedBy').attr('disabled', 'disabled');
        this.$('.bv_completionDate').attr('disabled', 'disabled');
        this.$('.bv_notebook').attr('disabled', 'disabled');
        this.$('.bv_completionDateIcon').on("click", function() {
          return false;
        });
      }
      return this;
    };

    AbstractBaseComponentParentController.prototype.modelSaveCallback = function(method, model) {
      console.log("sync in parent controller");
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

    AbstractBaseComponentParentController.prototype.setupRecordedBySelect = function() {
      var defaultOption;
      console.log("setup recorded by");
      console.log(this.model.get('recordedBy'));
      if (this.model.isNew()) {
        defaultOption = "Filled from first batch";
      } else {
        defaultOption = "Select Scientist";
      }
      this.recordedByList = new PickListList();
      this.recordedByList.url = "/api/authors";
      return this.recordedByListController = new PickListSelectController({
        el: this.$('.bv_recordedBy'),
        collection: this.recordedByList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: defaultOption
        }),
        selectedCode: this.model.get('recordedBy')
      });
    };

    AbstractBaseComponentParentController.prototype.handleCompletionDateIconClicked = function() {
      return this.$(".bv_completionDate").datepicker("show");
    };

    AbstractBaseComponentParentController.prototype.updateModel = function() {
      this.model.set({
        recordedBy: this.$('.bv_recordedBy').val()
      });
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

    AbstractBaseComponentParentController.prototype.handleUpdateParent = function() {
      console.log("handle update parent");
      this.model.reformatBeforeSaving();
      this.$('.bv_updatingParent').show();
      this.$('.bv_updateParentComplete').html('Update Complete.');
      return this.model.save();
    };

    return AbstractBaseComponentParentController;

  })(AbstractFormController);

  window.AbstractBaseComponentBatchController = (function(_super) {
    __extends(AbstractBaseComponentBatchController, _super);

    function AbstractBaseComponentBatchController() {
      this.handleSaveBatch = __bind(this.handleSaveBatch, this);
      this.clearValidationErrorStyles = __bind(this.clearValidationErrorStyles, this);
      this.validationError = __bind(this.validationError, this);
      this.updateModel = __bind(this.updateModel, this);
      this.handleCompletionDateIconClicked = __bind(this.handleCompletionDateIconClicked, this);
      this.setupAttachFileListController = __bind(this.setupAttachFileListController, this);
      this.render = __bind(this.render, this);
      return AbstractBaseComponentBatchController.__super__.constructor.apply(this, arguments);
    }

    AbstractBaseComponentBatchController.prototype.template = _.template($("#AbstractBaseComponentBatchView").html());

    AbstractBaseComponentBatchController.prototype.events = function() {
      return {
        "change .bv_recordedBy": "attributeChanged",
        "keyup .bv_completionDate": "attributeChanged",
        "click .bv_completionDateIcon": "handleCompletionDateIconClicked",
        "keyup .bv_notebook": "attributeChanged",
        "keyup .bv_amount": "attributeChanged",
        "keyup .bv_location": "attributeChanged",
        "click .bv_saveBatch": "handleSaveBatch"
      };
    };

    AbstractBaseComponentBatchController.prototype.initialize = function() {
      console.log("initialize batch controller");
      this.setBindings();
      this.listenTo(this.model, 'sync', this.modelSaveCallback);
      this.listenTo(this.model, 'change', this.modelChangeCallback);
      $(this.el).empty();
      $(this.el).html(this.template());
      console.log(this.additionalBatchAttributesTemplate != null);
      if (this.additionalBatchAttributesTemplate != null) {
        this.$('.bv_additionalBatchAttributes').html(this.additionalBatchAttributesTemplate());
      }
      this.setupRecordedBySelect();
      return this.setupAttachFileListController();
    };

    AbstractBaseComponentBatchController.prototype.render = function() {
      this.$('.bv_batchCode').val(this.model.get('codeName'));
      this.$('.bv_batchCode').html(this.model.get('codeName'));
      this.$('.bv_recordedBy').val(this.model.get('recordedBy'));
      this.$('.bv_completionDate').datepicker();
      this.$('.bv_completionDate').datepicker("option", "dateFormat", "yy-mm-dd");
      if (this.model.get('completion date').get('value') != null) {
        this.$('.bv_completionDate').val(UtilityFunctions.prototype.convertMSToYMDDate(this.model.get('completion date').get('value')));
      } else {
        this.$('.bv_completionDate').val("");
      }
      this.$('.bv_notebook').val(this.model.get('notebook').get('value'));
      this.$('.bv_amount').val(this.model.get('amount').get('value'));
      this.$('.bv_location').val(this.model.get('location').get('value'));
      return this;
    };

    AbstractBaseComponentBatchController.prototype.modelSaveCallback = function(method, model) {
      console.log("sync in batch controller");
      this.$('.bv_saveBatch').show();
      this.$('.bv_saveBatch').attr('disabled', 'disabled');
      this.$('.bv_saveBatchComplete').show();
      this.$('.bv_savingBatch').hide();
      this.trigger('amClean');
      this.trigger('batchSaved');
      return this.render();
    };

    AbstractBaseComponentBatchController.prototype.modelChangeCallback = function(method, model) {
      this.trigger('amDirty');
      return this.$('.bv_saveBatchComplete').hide();
    };

    AbstractBaseComponentBatchController.prototype.setupRecordedBySelect = function() {
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

    AbstractBaseComponentBatchController.prototype.setupAttachFileListController = function() {
      return $.ajax({
        type: 'GET',
        url: "/api/dataDict/analytical method/file type",
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
              console.log("success");
              console.log(json);
              attachFileList = _this.model.getAnalyticalFiles(json);
              return _this.finishSetupAttachFileListController(attachFileList);
            }
          };
        })(this)
      });
    };

    AbstractBaseComponentBatchController.prototype.finishSetupAttachFileListController = function(attachFileList) {
      console.log(attachFileList);
      console.log("finish set up attach file list controller");
      this.attachFileListController = new AttachFileListController({
        el: this.$('.bv_attachFileList'),
        collection: attachFileList
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
      return this.attachFileListController.render();
    };

    AbstractBaseComponentBatchController.prototype.handleCompletionDateIconClicked = function() {
      return this.$(".bv_completionDate").datepicker("show");
    };

    AbstractBaseComponentBatchController.prototype.updateModel = function() {
      console.log("update batch model");
      this.model.set({
        recordedBy: this.$('.bv_recordedBy').val()
      });
      this.model.get("notebook").set("value", UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_notebook')));
      this.model.get("completion date").set("value", UtilityFunctions.prototype.convertYMDDateToMs(UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_completionDate'))));
      this.model.get("amount").set("value", parseFloat(UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_amount'))));
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
      console.log("handle save batch");
      this.model.reformatBeforeSaving();
      this.$('.bv_savingBatch').show();
      console.log(this.model);
      console.log(this.model.get('id'));
      return this.model.save();
    };

    return AbstractBaseComponentBatchController;

  })(AbstractFormController);

  window.AbstractBaseComponentBatchSelectController = (function(_super) {
    __extends(AbstractBaseComponentBatchSelectController, _super);

    function AbstractBaseComponentBatchSelectController() {
      this.setupBatchRegForm = __bind(this.setupBatchRegForm, this);
      return AbstractBaseComponentBatchSelectController.__super__.constructor.apply(this, arguments);
    }

    AbstractBaseComponentBatchSelectController.prototype.template = _.template($("#AbstractBaseComponentBatchSelectView").html());

    AbstractBaseComponentBatchSelectController.prototype.events = function() {
      return {
        "keyup .bv_batchList": "handleSelectedBatchChanged"
      };
    };

    AbstractBaseComponentBatchSelectController.prototype.initialize = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      this.setupBatchSelect();
      this.setupBatchRegForm();
      return this.parentCodeName = this.options.parentCodeName;
    };

    AbstractBaseComponentBatchSelectController.prototype.setupBatchSelect = function() {
      console.log("setup Batch Select");
      this.batchList = new PickListList();
      this.batchList.url = "/api/batches/parentCodename/" + this.parentCodeName;
      return this.batchListController = new PickListSelectController({
        el: this.$('.bv_batchList'),
        collection: this.batchList,
        insertFirstOption: new PickList({
          code: "new batch",
          name: "Register New Batch"
        }),
        selectedCode: "new batch"
      });
    };

    AbstractBaseComponentBatchSelectController.prototype.setupBatchRegForm = function(batch) {
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
          console.log("batch adn batch select trigger");
          _this.setupBatchSelect();
          _this.batchListController.setSelectedCode(_this.batchController.model.get('codeName'));
          return _this.trigger('batchSaved');
        };
      })(this));
      this.batchController.render();
      this.$('.bv_saveBatch').attr('disabled', 'disabled');
      console.log("is model new?");
      if (this.batchController.model.isNew()) {
        this.$('.bv_saveBatch').html("Save Batch");
        return this.$('.bv_saveBatchComplete').html("Save Complete");
      } else {
        this.$('.bv_saveBatch').html("Update Batch");
        return this.$('.bv_saveBatchComplete').html("Update Complete");
      }
    };

    AbstractBaseComponentBatchSelectController.prototype.checkIfFirstBatch = function() {
      console.log("checkIfFirstBatch");
      return this.batchListController.collection.length === 1;
    };

    return AbstractBaseComponentBatchSelectController;

  })(Backbone.View);

  window.AbstractBaseComponentController = (function(_super) {
    __extends(AbstractBaseComponentController, _super);

    function AbstractBaseComponentController() {
      this.saveNewParentAttributes = __bind(this.saveNewParentAttributes, this);
      this.handleBatchSaved = __bind(this.handleBatchSaved, this);
      this.completeInitialization = __bind(this.completeInitialization, this);
      return AbstractBaseComponentController.__super__.constructor.apply(this, arguments);
    }

    AbstractBaseComponentController.prototype.template = _.template($("#AbstractBaseComponentView").html());

    AbstractBaseComponentController.prototype.events = function() {
      return {
        "click .bv_save": "handleSaveClicked"
      };
    };

    AbstractBaseComponentController.prototype.completeInitialization = function() {
      $(this.el).html(this.template());
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
      console.log("rendered parent controller");
      this.$('.bv_updateParent').attr('disabled', 'disabled');
      return this.firstSave = this.parentController.model.isNew();
    };

    AbstractBaseComponentController.prototype.handleParentSaved = function() {
      if (this.firstSave) {
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
          return _this.handleBatchSaved();
        };
      })(this));
      return this.batchSelectController.render();
    };

    AbstractBaseComponentController.prototype.handleBatchSaved = function() {
      console.log("first batch saved	");
      if (this.batchSelectController.checkIfFirstBatch()) {
        this.$('.bv_saveFirstBatchComplete').show();
      } else {
        this.$('.bv_saveFirstBatchComplete').hide();
        this.$('.bv_saveParent').hide();
      }
      return this.$('.bv_saving').hide();
    };

    AbstractBaseComponentController.prototype.checkFormValid = function() {
      if (this.parentController.isValid() && this.batchSelectController.batchController.isValid()) {
        return this.$('.bv_save').removeAttr('disabled');
      } else {
        return this.$('.bv_save').attr('disabled', 'disabled');
      }
    };

    AbstractBaseComponentController.prototype.handleSaveClicked = function() {
      console.log("save clicked");
      this.saveNewParentAttributes();
      this.parentController.model.prepareToSave();
      this.batchSelectController.batchController.model.prepareToSave();
      this.$('.bv_save').hide();
      this.$('.bv_saving').show();
      this.parentController.model.reformatBeforeSaving();
      this.batchSelectController.batchController.model.reformatBeforeSaving();
      console.log(this.parentController.model);
      this.$('.bv_updateParentComplete').html("Save Complete");
      this.$('.bv_saveBatch').html("Save Batch");
      this.parentController.model.save();
      return this.batchSelectController.batchController.model.save();
    };

    AbstractBaseComponentController.prototype.saveNewParentAttributes = function() {
      var cDate, notebook, recordedBy;
      recordedBy = this.batchSelectController.batchController.model.get('recordedBy');
      cDate = this.batchSelectController.batchController.model.get('completion date').get('value');
      notebook = this.batchSelectController.batchController.model.get('notebook').get('value');
      this.parentController.model.set('recordedBy', recordedBy);
      this.parentController.model.get('completion date').set('value', cDate);
      return this.parentController.model.get('notebook').set('value', notebook);
    };

    return AbstractBaseComponentController;

  })(Backbone.View);

}).call(this);
