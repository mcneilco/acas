(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.SpacerParent = (function(_super) {
    __extends(SpacerParent, _super);

    function SpacerParent() {
      this.duplicate = __bind(this.duplicate, this);
      return SpacerParent.__super__.constructor.apply(this, arguments);
    }

    SpacerParent.prototype.urlRoot = "/api/things/parent/spacer";

    SpacerParent.prototype.className = "SpacerParent";

    SpacerParent.prototype.initialize = function() {
      this.set({
        lsType: "parent",
        lsKind: "spacer"
      });
      return SpacerParent.__super__.initialize.call(this);
    };

    SpacerParent.prototype.lsProperties = {
      defaultLabels: [
        {
          key: 'spacer name',
          type: 'name',
          kind: 'spacer',
          preferred: true
        }
      ],
      defaultValues: [
        {
          key: 'scientist',
          stateType: 'metadata',
          stateKind: 'spacer parent',
          type: 'codeValue',
          kind: 'scientist',
          codeOrigin: window.conf.scientistCodeOrigin
        }, {
          key: 'completion date',
          stateType: 'metadata',
          stateKind: 'spacer parent',
          type: 'dateValue',
          kind: 'completion date'
        }, {
          key: 'notebook',
          stateType: 'metadata',
          stateKind: 'spacer parent',
          type: 'stringValue',
          kind: 'notebook'
        }, {
          key: 'molecular weight',
          stateType: 'metadata',
          stateKind: 'spacer parent',
          type: 'numericValue',
          kind: 'molecular weight',
          unitType: 'molecular weight',
          unitKind: 'g/mol'
        }, {
          key: 'structural file',
          stateType: 'metadata',
          stateKind: 'spacer parent',
          type: 'fileValue',
          kind: 'structural file'
        }, {
          key: 'batch number',
          stateType: 'metadata',
          stateKind: 'spacer parent',
          type: 'numericValue',
          kind: 'batch number',
          value: 0
        }
      ]
    };

    SpacerParent.prototype.validate = function(attrs) {
      var errors, mw;
      errors = [];
      errors.push.apply(errors, SpacerParent.__super__.validate.call(this, attrs));
      if (attrs["molecular weight"] != null) {
        mw = attrs["molecular weight"].get('value');
        if (mw === "" || mw === void 0) {
          errors.push({
            attribute: 'molecularWeight',
            message: "Molecular weight must be set"
          });
        }
        if (isNaN(mw)) {
          errors.push({
            attribute: 'molecularWeight',
            message: "Molecular weight must be a number"
          });
        }
      }
      if (errors.length > 0) {
        return errors;
      } else {
        return null;
      }
    };

    SpacerParent.prototype.duplicate = function() {
      var copiedThing;
      copiedThing = SpacerParent.__super__.duplicate.call(this);
      copiedThing.get("spacer name").set("labelText", "");
      return copiedThing;
    };

    return SpacerParent;

  })(AbstractBaseComponentParent);

  window.SpacerBatch = (function(_super) {
    __extends(SpacerBatch, _super);

    function SpacerBatch() {
      return SpacerBatch.__super__.constructor.apply(this, arguments);
    }

    SpacerBatch.prototype.urlRoot = "/api/things/batch/spacer";

    SpacerBatch.prototype.initialize = function() {
      this.set({
        lsType: "batch",
        lsKind: "spacer"
      });
      return SpacerBatch.__super__.initialize.call(this);
    };

    SpacerBatch.prototype.lsProperties = {
      defaultLabels: [],
      defaultValues: [
        {
          key: 'scientist',
          stateType: 'metadata',
          stateKind: 'spacer batch',
          type: 'codeValue',
          kind: 'scientist',
          codeOrigin: window.conf.scientistCodeOrigin
        }, {
          key: 'completion date',
          stateType: 'metadata',
          stateKind: 'spacer batch',
          type: 'dateValue',
          kind: 'completion date'
        }, {
          key: 'notebook',
          stateType: 'metadata',
          stateKind: 'spacer batch',
          type: 'stringValue',
          kind: 'notebook'
        }, {
          key: 'source',
          stateType: 'metadata',
          stateKind: 'spacer batch',
          type: 'codeValue',
          kind: 'source',
          value: 'Avidity',
          codeType: 'component',
          codeKind: 'source',
          codeOrigin: 'ACAS DDICT'
        }, {
          key: 'source id',
          stateType: 'metadata',
          stateKind: 'spacer batch',
          type: 'stringValue',
          kind: 'source id'
        }, {
          key: 'purity',
          stateType: 'metadata',
          stateKind: 'spacer batch',
          type: 'numericValue',
          kind: 'purity',
          unitType: 'percentage',
          unitKind: '% purity'
        }, {
          key: 'amount made',
          stateType: 'metadata',
          stateKind: 'inventory',
          type: 'numericValue',
          kind: 'amount made',
          unitType: 'mass',
          unitKind: 'g'
        }, {
          key: 'location',
          stateType: 'metadata',
          stateKind: 'inventory',
          type: 'stringValue',
          kind: 'location'
        }
      ]
    };

    SpacerBatch.prototype.validate = function(attrs) {
      var errors, purity;
      errors = [];
      errors.push.apply(errors, SpacerBatch.__super__.validate.call(this, attrs));
      if (attrs.purity != null) {
        purity = attrs.purity.get('value');
        if (purity === "" || purity === void 0) {
          errors.push({
            attribute: 'purity',
            message: "Purity must be set"
          });
        }
        if (isNaN(purity)) {
          errors.push({
            attribute: 'purity',
            message: "Purity must be a number"
          });
        }
      }
      if (errors.length > 0) {
        return errors;
      } else {
        return null;
      }
    };

    return SpacerBatch;

  })(AbstractBaseComponentBatch);

  window.SpacerParentController = (function(_super) {
    __extends(SpacerParentController, _super);

    function SpacerParentController() {
      this.updateModel = __bind(this.updateModel, this);
      this.handleFileRemoved = __bind(this.handleFileRemoved, this);
      this.handleFileUpload = __bind(this.handleFileUpload, this);
      this.render = __bind(this.render, this);
      return SpacerParentController.__super__.constructor.apply(this, arguments);
    }

    SpacerParentController.prototype.additionalParentAttributesTemplate = _.template($("#SpacerParentView").html());

    SpacerParentController.prototype.events = function() {
      return _(SpacerParentController.__super__.events.call(this)).extend({
        "keyup .bv_molecularWeight": "attributeChanged"
      });
    };

    SpacerParentController.prototype.initialize = function() {
      if (this.model == null) {
        this.model = new SpacerParent();
      }
      this.errorOwnerName = 'SpacerParentController';
      return SpacerParentController.__super__.initialize.call(this);
    };

    SpacerParentController.prototype.render = function() {
      if (this.model == null) {
        this.model = new SpacerParent();
      }
      this.$('.bv_molecularWeight').val(this.model.get('molecular weight').get('value'));
      this.setupStructuralFileController();
      return SpacerParentController.__super__.render.call(this);
    };

    SpacerParentController.prototype.setupStructuralFileController = function() {
      this.structuralFileController = new LSFileChooserController({
        el: this.$('.bv_structuralFile'),
        formId: 'fieldBlah',
        maxNumberOfFiles: 1,
        requiresValidation: false,
        url: UtilityFunctions.prototype.getFileServiceURL(),
        allowedFileTypes: ['sdf', 'mol'],
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

    SpacerParentController.prototype.handleFileUpload = function(nameOnServer) {
      this.model.get("structural file").set("value", nameOnServer);
      return this.trigger('amDirty');
    };

    SpacerParentController.prototype.handleFileRemoved = function() {
      return this.model.get("structural file").set("value", null);
    };

    SpacerParentController.prototype.updateModel = function() {
      this.model.get("spacer name").set("labelText", UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_parentName')));
      this.model.get("molecular weight").set("value", parseFloat(UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_molecularWeight'))));
      return SpacerParentController.__super__.updateModel.call(this);
    };

    return SpacerParentController;

  })(AbstractBaseComponentParentController);

  window.SpacerBatchController = (function(_super) {
    __extends(SpacerBatchController, _super);

    function SpacerBatchController() {
      this.updateModel = __bind(this.updateModel, this);
      this.render = __bind(this.render, this);
      return SpacerBatchController.__super__.constructor.apply(this, arguments);
    }

    SpacerBatchController.prototype.additionalBatchAttributesTemplate = _.template($("#SpacerBatchView").html());

    SpacerBatchController.prototype.events = function() {
      return _(SpacerBatchController.__super__.events.call(this)).extend({
        "keyup .bv_purity": "attributeChanged"
      });
    };

    SpacerBatchController.prototype.initialize = function() {
      if (this.model == null) {
        this.model = new SpacerBatch();
      }
      this.errorOwnerName = 'SpacerBatchController';
      return SpacerBatchController.__super__.initialize.call(this);
    };

    SpacerBatchController.prototype.render = function() {
      if (this.model == null) {
        this.model = new SpacerBatch();
      }
      this.$('.bv_purity').val(this.model.get('purity').get('value'));
      return SpacerBatchController.__super__.render.call(this);
    };

    SpacerBatchController.prototype.updateModel = function() {
      this.model.get("purity").set("value", parseFloat(UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_purity'))));
      return SpacerBatchController.__super__.updateModel.call(this);
    };

    return SpacerBatchController;

  })(AbstractBaseComponentBatchController);

  window.SpacerBatchSelectController = (function(_super) {
    __extends(SpacerBatchSelectController, _super);

    function SpacerBatchSelectController() {
      this.handleSelectedBatchChanged = __bind(this.handleSelectedBatchChanged, this);
      this.setupBatchRegForm = __bind(this.setupBatchRegForm, this);
      return SpacerBatchSelectController.__super__.constructor.apply(this, arguments);
    }

    SpacerBatchSelectController.prototype.setupBatchRegForm = function() {
      if (this.batchModel === void 0 || this.batchModel === "new batch" || this.batchModel === null) {
        this.batchModel = new SpacerBatch();
      }
      return SpacerBatchSelectController.__super__.setupBatchRegForm.call(this);
    };

    SpacerBatchSelectController.prototype.handleSelectedBatchChanged = function() {
      this.batchCodeName = this.batchListController.getSelectedCode();
      this.batchModel = this.batchList.findWhere({
        codeName: this.batchCodeName
      });
      return this.setupBatchRegForm();
    };

    return SpacerBatchSelectController;

  })(AbstractBaseComponentBatchSelectController);

  window.SpacerController = (function(_super) {
    __extends(SpacerController, _super);

    function SpacerController() {
      this.setupBatchSelectController = __bind(this.setupBatchSelectController, this);
      this.setupParentController = __bind(this.setupParentController, this);
      this.completeInitialization = __bind(this.completeInitialization, this);
      return SpacerController.__super__.constructor.apply(this, arguments);
    }

    SpacerController.prototype.moduleLaunchName = "spacer";

    SpacerController.prototype.initialize = function() {
      var launchCode;
      if (this.model != null) {
        return this.completeInitialization();
      } else {
        if (window.AppLaunchParams.moduleLaunchParams != null) {
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
              url: "/api/things/parent/spacer/codename/" + launchCode,
              dataType: 'json',
              error: function(err) {
                alert('Could not get parent for code in this URL, creating new one');
                return this.completeInitialization();
              },
              success: (function(_this) {
                return function(json) {
                  var sp;
                  if (json.length === 0) {
                    alert('Could not get parent for code in this URL, creating new one');
                  } else {
                    sp = new SpacerParent(json);
                    sp.set(sp.parse(sp.attributes));
                    if (window.AppLaunchParams.moduleLaunchParams.copy) {
                      _this.model = sp.duplicate();
                    } else {
                      _this.model = sp;
                    }
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

    SpacerController.prototype.completeInitialization = function() {
      if (this.model == null) {
        this.model = new SpacerParent();
      }
      SpacerController.__super__.completeInitialization.call(this);
      return this.$('.bv_registrationTitle').html("Spacer Parent/Batch Registration");
    };

    SpacerController.prototype.setupParentController = function() {
      this.parentController = new SpacerParentController({
        model: this.model,
        el: this.$('.bv_parent'),
        readOnly: this.readOnly
      });
      return SpacerController.__super__.setupParentController.call(this);
    };

    SpacerController.prototype.setupBatchSelectController = function() {
      this.batchSelectController = new SpacerBatchSelectController({
        el: this.$('.bv_batch'),
        parentCodeName: this.model.get('codeName'),
        batchCodeName: this.batchCodeName,
        batchModel: this.batchModel,
        readOnly: this.readOnly,
        lsKind: "spacer"
      });
      return SpacerController.__super__.setupBatchSelectController.call(this);
    };

    return SpacerController;

  })(AbstractBaseComponentController);

}).call(this);
