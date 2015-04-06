(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.ExampleThing = (function(_super) {
    __extends(ExampleThing, _super);

    function ExampleThing() {
      this.duplicate = __bind(this.duplicate, this);
      return ExampleThing.__super__.constructor.apply(this, arguments);
    }

    ExampleThing.prototype.urlRoot = "/api/things/parent/cationic block";

    ExampleThing.prototype.className = "CationicBlockParent";

    ExampleThing.prototype.initialize = function() {
      this.set({
        lsType: "parent",
        lsKind: "cationic block"
      });
      return ExampleThing.__super__.initialize.call(this);
    };

    ExampleThing.prototype.lsProperties = {
      defaultLabels: [
        {
          key: 'cationic block name',
          type: 'name',
          kind: 'cationic block',
          preferred: true
        }
      ],
      defaultValues: [
        {
          key: 'scientist',
          stateType: 'metadata',
          stateKind: 'cationic block parent',
          type: 'codeValue',
          kind: 'scientist',
          codeOrigin: window.conf.scientistCodeOrigin,
          value: "unassigned"
        }, {
          key: 'completion date',
          stateType: 'metadata',
          stateKind: 'cationic block parent',
          type: 'dateValue',
          kind: 'completion date',
          value: NaN
        }, {
          key: 'notebook',
          stateType: 'metadata',
          stateKind: 'cationic block parent',
          type: 'stringValue',
          kind: 'notebook',
          value: ""
        }, {
          key: 'structural file',
          stateType: 'metadata',
          stateKind: 'cationic block parent',
          type: 'fileValue',
          kind: 'structural file',
          value: ""
        }, {
          key: 'batch number',
          stateType: 'metadata',
          stateKind: 'cationic block parent',
          type: 'numericValue',
          kind: 'batch number',
          value: 0
        }
      ],
      defaultFirstLsThingItx: [],
      defaultSecondLsThingItx: []
    };

    ExampleThing.prototype.validate = function(attrs) {
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
          attribute: 'thingName',
          message: "Name must be set"
        });
      }
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
      if (errors.length > 0) {
        return errors;
      } else {
        return null;
      }
    };

    ExampleThing.prototype.prepareToSave = function() {
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

    ExampleThing.prototype.duplicate = function() {
      var copiedThing;
      copiedThing = ExampleThing.__super__.duplicate.call(this);
      copiedThing.get("batch number").set({
        value: 0
      });
      return copiedThing;
    };

    return ExampleThing;

  })(Thing);

  window.ExampleThingController = (function(_super) {
    __extends(ExampleThingController, _super);

    function ExampleThingController() {
      this.updateBatchNumber = __bind(this.updateBatchNumber, this);
      this.displayInReadOnlyMode = __bind(this.displayInReadOnlyMode, this);
      this.handleUpdateThing = __bind(this.handleUpdateThing, this);
      this.handleValidateReturn = __bind(this.handleValidateReturn, this);
      this.clearValidationErrorStyles = __bind(this.clearValidationErrorStyles, this);
      this.validationError = __bind(this.validationError, this);
      this.updateModel = __bind(this.updateModel, this);
      this.handleDeleteSavedStructuralFile = __bind(this.handleDeleteSavedStructuralFile, this);
      this.handleFileRemoved = __bind(this.handleFileRemoved, this);
      this.handleFileUpload = __bind(this.handleFileUpload, this);
      this.createNewFileChooser = __bind(this.createNewFileChooser, this);
      this.handleCompletionDateIconClicked = __bind(this.handleCompletionDateIconClicked, this);
      this.setupStructuralFileController = __bind(this.setupStructuralFileController, this);
      this.modelChangeCallback = __bind(this.modelChangeCallback, this);
      this.modelSaveCallback = __bind(this.modelSaveCallback, this);
      this.render = __bind(this.render, this);
      this.completeInitialization = __bind(this.completeInitialization, this);
      this.initialize = __bind(this.initialize, this);
      return ExampleThingController.__super__.constructor.apply(this, arguments);
    }

    ExampleThingController.prototype.template = _.template($("#ExampleThingView").html());

    ExampleThingController.prototype.moduleLaunchName = "cationic_block";

    ExampleThingController.prototype.events = function() {
      return {
        "keyup .bv_thingName": "attributeChanged",
        "change .bv_scientist": "attributeChanged",
        "keyup .bv_completionDate": "attributeChanged",
        "click .bv_completionDateIcon": "handleCompletionDateIconClicked",
        "keyup .bv_notebook": "attributeChanged",
        "click .bv_saveThing": "handleUpdateThing",
        "click .bv_deleteSavedFile": "handleDeleteSavedStructuralFile"
      };
    };

    ExampleThingController.prototype.initialize = function() {
      var launchCode;
      if (this.model != null) {
        return this.completeInitialization();
      } else {
        if (window.AppLaunchParams.moduleLaunchParams != null) {
          console.log("has module launch params");
          if (window.AppLaunchParams.moduleLaunchParams.moduleName === this.moduleLaunchName) {
            launchCode = window.AppLaunchParams.moduleLaunchParams.code;
            if (launchCode.indexOf("-") === -1) {
              this.batchCodeName = "new batch";
            } else {
              this.batchCodeName = launchCode;
              launchCode = launchCode.split("-")[0];
            }
            return $.ajax({
              type: 'GET',
              url: "/api/things/parent/cationic block/codename/" + launchCode,
              dataType: 'json',
              error: function(err) {
                alert('Could not get parent for code in this URL, creating new one');
                return this.completeInitialization();
              },
              success: (function(_this) {
                return function(json) {
                  var cbp;
                  if (json.length === 0) {
                    alert('Could not get parent for code in this URL, creating new one');
                  } else {
                    cbp = new ExampleThing(json);
                    cbp.set(cbp.parse(cbp.attributes));
                    _this.model = cbp;
                  }
                  return _this.completeInitialization();
                };
              })(this)
            });
          } else {
            return this.completeInitialization();
          }
        } else {
          return this.completeInitialization();
        }
      }
    };

    ExampleThingController.prototype.completeInitialization = function() {
      if (this.model == null) {
        this.model = new ExampleThing();
      }
      this.errorOwnerName = 'ExampleThingController';
      this.setBindings();
      if (this.options.readOnly != null) {
        this.readOnly = this.options.readOnly;
      } else {
        this.readOnly = false;
      }
      this.listenTo(this.model, 'sync', this.modelSaveCallback);
      this.listenTo(this.model, 'change', this.modelChangeCallback);
      $(this.el).empty();
      $(this.el).html(this.template(this.model.attributes));
      this.setupScientistSelect();
      return this.render();
    };

    ExampleThingController.prototype.render = function() {
      var bestName, codeName, compDate;
      if (this.model == null) {
        this.model = new ExampleThing();
      }
      this.setupStructuralFileController();
      codeName = this.model.get('codeName');
      this.$('.bv_thingCode').val(codeName);
      this.$('.bv_thingCode').html(codeName);
      bestName = this.model.get('lsLabels').pickBestName();
      if (bestName != null) {
        this.$('.bv_thingName').val(bestName.get('labelText'));
      }
      this.$('.bv_scientist').val(this.model.get('scientist').get('value'));
      this.$('.bv_completionDate').datepicker();
      this.$('.bv_completionDate').datepicker("option", "dateFormat", "yy-mm-dd");
      compDate = this.model.get('completion date').get('value');
      if (compDate != null) {
        if (!isNaN(compDate)) {
          this.$('.bv_completionDate').val(UtilityFunctions.prototype.convertMSToYMDDate(this.model.get('completion date').get('value')));
        }
      }
      this.$('.bv_notebook').val(this.model.get('notebook').get('value'));
      if (this.readOnly === true) {
        this.displayInReadOnlyMode();
      }
      this.$('.bv_saveThing').attr('disabled', 'disabled');
      if (this.model.isNew()) {
        this.$('.bv_saveThing').html("Save");
      } else {
        this.$('.bv_saveThing').html("Update");
      }
      return this;
    };

    ExampleThingController.prototype.modelSaveCallback = function(method, model) {
      this.$('.bv_saveThing').show();
      this.$('.bv_saveThing').attr('disabled', 'disabled');
      this.$('.bv_saveThingComplete').show();
      this.$('.bv_updatingThing').hide();
      this.trigger('amClean');
      this.trigger('thingSaved');
      return this.render();
    };

    ExampleThingController.prototype.modelChangeCallback = function(method, model) {
      this.trigger('amDirty');
      return this.$('.bv_saveThingComplete').hide();
    };

    ExampleThingController.prototype.setupStructuralFileController = function() {
      var structuralFileValue;
      structuralFileValue = this.model.get('structural file').get('value');
      if (structuralFileValue === null || structuralFileValue === "" || structuralFileValue === void 0) {
        this.createNewFileChooser();
        return this.$('.bv_deleteSavedFile').hide();
      } else {
        this.$('.bv_structuralFile').html('<a href="' + window.conf.datafiles.downloadurl.prefix + structuralFileValue + '">' + this.model.get('structural file').get('comments') + '</a>');
        return this.$('.bv_deleteSavedFile').show();
      }
    };

    ExampleThingController.prototype.setupScientistSelect = function() {
      var defaultOption;
      defaultOption = "Select Scientist";
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

    ExampleThingController.prototype.handleCompletionDateIconClicked = function() {
      return this.$(".bv_completionDate").datepicker("show");
    };

    ExampleThingController.prototype.createNewFileChooser = function() {
      this.structuralFileController = new LSFileChooserController({
        el: this.$('.bv_structuralFile'),
        formId: 'fieldBlah',
        maxNumberOfFiles: 1,
        requiresValidation: false,
        url: UtilityFunctions.prototype.getFileServiceURL(),
        allowedFileTypes: ['png', 'jpeg'],
        hideDelete: false
      });
      this.structuralFileController.on('amDirty', (function(_this) {
        return function() {
          return _this.trigger('amDirty');
        };
      })(this));
      this.structuralFileController.on('amClean', (function(_this) {
        return function() {
          return _this.trigger('amClean');
        };
      })(this));
      this.structuralFileController.render();
      this.structuralFileController.on('fileUploader:uploadComplete', this.handleFileUpload);
      return this.structuralFileController.on('fileDeleted', this.handleFileRemoved);
    };

    ExampleThingController.prototype.handleFileUpload = function(nameOnServer) {
      var newFileValue;
      newFileValue = this.model.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "cationic block parent", "fileValue", "structural file");
      this.model.set("structural file", newFileValue);
      return this.model.get("structural file").set("value", nameOnServer);
    };

    ExampleThingController.prototype.handleFileRemoved = function() {
      this.model.get("structural file").set("ignored", true);
      return this.model.unset("structural file");
    };

    ExampleThingController.prototype.handleDeleteSavedStructuralFile = function() {
      this.handleFileRemoved();
      this.$('.bv_deleteSavedFile').hide();
      return this.createNewFileChooser();
    };

    ExampleThingController.prototype.updateModel = function() {
      this.model.get("cationic block name").set("labelText", UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_thingName')));
      this.model.get("scientist").set("value", this.scientistListController.getSelectedCode());
      this.model.get("notebook").set("value", UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_notebook')));
      return this.model.get("completion date").set("value", UtilityFunctions.prototype.convertYMDDateToMs(UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_completionDate'))));
    };

    ExampleThingController.prototype.validationError = function() {
      ExampleThingController.__super__.validationError.call(this);
      return this.$('.bv_saveThing').attr('disabled', 'disabled');
    };

    ExampleThingController.prototype.clearValidationErrorStyles = function() {
      ExampleThingController.__super__.clearValidationErrorStyles.call(this);
      return this.$('.bv_saveThing').removeAttr('disabled');
    };

    ExampleThingController.prototype.validateThingName = function() {
      var lsKind, name;
      this.$('.bv_saveThing').attr('disabled', 'disabled');
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

    ExampleThingController.prototype.handleValidateReturn = function(validNewLabel) {
      if (validNewLabel === true) {
        return this.handleUpdateThing();
      } else {
        return alert('The requested thing name has already been registered. Please choose a new thing name.');
      }
    };

    ExampleThingController.prototype.handleUpdateThing = function() {
      this.model.prepareToSave();
      this.model.reformatBeforeSaving();
      this.$('.bv_updatingThing').show();
      this.$('.bv_saveThingComplete').html('Update Complete.');
      this.$('.bv_saveThing').attr('disabled', 'disabled');
      return this.model.save();
    };

    ExampleThingController.prototype.displayInReadOnlyMode = function() {
      this.$(".bv_saveThing").hide();
      this.$('button').attr('disabled', 'disabled');
      this.$(".bv_completionDateIcon").addClass("uneditable-input");
      this.$(".bv_completionDateIcon").on("click", function() {
        return false;
      });
      return this.disableAllInputs();
    };

    ExampleThingController.prototype.updateBatchNumber = function() {
      return this.model.fetch({
        success: console.log(this.model)
      });
    };

    return ExampleThingController;

  })(AbstractFormController);

}).call(this);
