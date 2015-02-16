(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.LinkerSmallMoleculeParent = (function(_super) {
    __extends(LinkerSmallMoleculeParent, _super);

    function LinkerSmallMoleculeParent() {
      this.duplicate = __bind(this.duplicate, this);
      return LinkerSmallMoleculeParent.__super__.constructor.apply(this, arguments);
    }

    LinkerSmallMoleculeParent.prototype.urlRoot = "/api/things/parent/linker small molecule";

    LinkerSmallMoleculeParent.prototype.className = "LinkerSmallMoleculeParent";

    LinkerSmallMoleculeParent.prototype.initialize = function() {
      this.set({
        lsType: "parent",
        lsKind: "linker small molecule"
      });
      return LinkerSmallMoleculeParent.__super__.initialize.call(this);
    };

    LinkerSmallMoleculeParent.prototype.lsProperties = {
      defaultLabels: [
        {
          key: 'linker small molecule name',
          type: 'name',
          kind: 'linker small molecule',
          preferred: true
        }
      ],
      defaultValues: [
        {
          key: 'scientist',
          stateType: 'metadata',
          stateKind: 'linker small molecule parent',
          type: 'codeValue',
          kind: 'scientist',
          codeOrigin: window.conf.scientistCodeOrigin
        }, {
          key: 'completion date',
          stateType: 'metadata',
          stateKind: 'linker small molecule parent',
          type: 'dateValue',
          kind: 'completion date'
        }, {
          key: 'notebook',
          stateType: 'metadata',
          stateKind: 'linker small molecule parent',
          type: 'stringValue',
          kind: 'notebook'
        }, {
          key: 'molecular weight',
          stateType: 'metadata',
          stateKind: 'linker small molecule parent',
          type: 'numericValue',
          kind: 'molecular weight',
          unitType: 'molecular weight',
          unitKind: 'g/mol'
        }, {
          key: 'structural file',
          stateType: 'metadata',
          stateKind: 'linker small molecule parent',
          type: 'fileValue',
          kind: 'structural file'
        }, {
          key: 'batch number',
          stateType: 'metadata',
          stateKind: 'linker small molecule parent',
          type: 'numericValue',
          kind: 'batch number',
          value: 0
        }
      ]
    };

    LinkerSmallMoleculeParent.prototype.validate = function(attrs) {
      var errors, mw;
      errors = [];
      errors.push.apply(errors, LinkerSmallMoleculeParent.__super__.validate.call(this, attrs));
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

    LinkerSmallMoleculeParent.prototype.duplicate = function() {
      var copiedThing;
      copiedThing = LinkerSmallMoleculeParent.__super__.duplicate.call(this);
      copiedThing.get("linker small molecule name").set("labelText", "");
      return copiedThing;
    };

    return LinkerSmallMoleculeParent;

  })(AbstractBaseComponentParent);

  window.LinkerSmallMoleculeBatch = (function(_super) {
    __extends(LinkerSmallMoleculeBatch, _super);

    function LinkerSmallMoleculeBatch() {
      return LinkerSmallMoleculeBatch.__super__.constructor.apply(this, arguments);
    }

    LinkerSmallMoleculeBatch.prototype.urlRoot = "/api/things/batch/linker small molecule";

    LinkerSmallMoleculeBatch.prototype.initialize = function() {
      this.set({
        lsType: "batch",
        lsKind: "linker small molecule"
      });
      return LinkerSmallMoleculeBatch.__super__.initialize.call(this);
    };

    LinkerSmallMoleculeBatch.prototype.lsProperties = {
      defaultLabels: [],
      defaultValues: [
        {
          key: 'scientist',
          stateType: 'metadata',
          stateKind: 'linker small molecule batch',
          type: 'codeValue',
          kind: 'scientist',
          codeOrigin: window.conf.scientistCodeOrigin
        }, {
          key: 'completion date',
          stateType: 'metadata',
          stateKind: 'linker small molecule batch',
          type: 'dateValue',
          kind: 'completion date'
        }, {
          key: 'notebook',
          stateType: 'metadata',
          stateKind: 'linker small molecule batch',
          type: 'stringValue',
          kind: 'notebook'
        }, {
          key: 'source',
          stateType: 'metadata',
          stateKind: 'linker small molecule batch',
          type: 'codeValue',
          kind: 'source',
          value: 'Avidity',
          codeType: 'component',
          codeKind: 'source',
          codeOrigin: 'ACAS DDICT'
        }, {
          key: 'source id',
          stateType: 'metadata',
          stateKind: 'linker small molecule batch',
          type: 'stringValue',
          kind: 'source id'
        }, {
          key: 'purity',
          stateType: 'metadata',
          stateKind: 'linker small molecule batch',
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

    LinkerSmallMoleculeBatch.prototype.validate = function(attrs) {
      var errors, purity;
      errors = [];
      errors.push.apply(errors, LinkerSmallMoleculeBatch.__super__.validate.call(this, attrs));
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

    return LinkerSmallMoleculeBatch;

  })(AbstractBaseComponentBatch);

  window.LinkerSmallMoleculeParentController = (function(_super) {
    __extends(LinkerSmallMoleculeParentController, _super);

    function LinkerSmallMoleculeParentController() {
      this.updateModel = __bind(this.updateModel, this);
      this.handleFileRemoved = __bind(this.handleFileRemoved, this);
      this.handleFileUpload = __bind(this.handleFileUpload, this);
      this.render = __bind(this.render, this);
      return LinkerSmallMoleculeParentController.__super__.constructor.apply(this, arguments);
    }

    LinkerSmallMoleculeParentController.prototype.additionalParentAttributesTemplate = _.template($("#LinkerSmallMoleculeParentView").html());

    LinkerSmallMoleculeParentController.prototype.events = function() {
      return _(LinkerSmallMoleculeParentController.__super__.events.call(this)).extend({
        "keyup .bv_molecularWeight": "attributeChanged"
      });
    };

    LinkerSmallMoleculeParentController.prototype.initialize = function() {
      if (this.model == null) {
        this.model = new LinkerSmallMoleculeParent();
      }
      this.errorOwnerName = 'LinkerSmallMoleculeParentController';
      return LinkerSmallMoleculeParentController.__super__.initialize.call(this);
    };

    LinkerSmallMoleculeParentController.prototype.render = function() {
      if (this.model == null) {
        this.model = new LinkerSmallMoleculeParent();
      }
      this.$('.bv_molecularWeight').val(this.model.get('molecular weight').get('value'));
      this.setupStructuralFileController();
      LinkerSmallMoleculeParentController.__super__.render.call(this);
      return this;
    };

    LinkerSmallMoleculeParentController.prototype.setupStructuralFileController = function() {
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

    LinkerSmallMoleculeParentController.prototype.handleFileUpload = function(nameOnServer) {
      this.model.get("structural file").set("value", nameOnServer);
      return this.trigger('amDirty');
    };

    LinkerSmallMoleculeParentController.prototype.handleFileRemoved = function() {
      return this.model.get("structural file").set("value", null);
    };

    LinkerSmallMoleculeParentController.prototype.updateModel = function() {
      this.model.get("linker small molecule name").set("labelText", UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_parentName')));
      this.model.get("molecular weight").set("value", parseFloat(UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_molecularWeight'))));
      return LinkerSmallMoleculeParentController.__super__.updateModel.call(this);
    };

    return LinkerSmallMoleculeParentController;

  })(AbstractBaseComponentParentController);

  window.LinkerSmallMoleculeBatchController = (function(_super) {
    __extends(LinkerSmallMoleculeBatchController, _super);

    function LinkerSmallMoleculeBatchController() {
      this.updateModel = __bind(this.updateModel, this);
      this.render = __bind(this.render, this);
      return LinkerSmallMoleculeBatchController.__super__.constructor.apply(this, arguments);
    }

    LinkerSmallMoleculeBatchController.prototype.additionalBatchAttributesTemplate = _.template($("#LinkerSmallMoleculeBatchView").html());

    LinkerSmallMoleculeBatchController.prototype.events = function() {
      return _(LinkerSmallMoleculeBatchController.__super__.events.call(this)).extend({
        "keyup .bv_purity": "attributeChanged"
      });
    };

    LinkerSmallMoleculeBatchController.prototype.initialize = function() {
      if (this.model == null) {
        this.model = new LinkerSmallMoleculeBatch();
      }
      this.errorOwnerName = 'LinkerSmallMoleculeBatchController';
      return LinkerSmallMoleculeBatchController.__super__.initialize.call(this);
    };

    LinkerSmallMoleculeBatchController.prototype.render = function() {
      if (this.model == null) {
        this.model = new LinkerSmallMoleculeBatch();
      }
      this.$('.bv_purity').val(this.model.get('purity').get('value'));
      return LinkerSmallMoleculeBatchController.__super__.render.call(this);
    };

    LinkerSmallMoleculeBatchController.prototype.updateModel = function() {
      this.model.get("purity").set("value", parseFloat(UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_purity'))));
      return LinkerSmallMoleculeBatchController.__super__.updateModel.call(this);
    };

    return LinkerSmallMoleculeBatchController;

  })(AbstractBaseComponentBatchController);

  window.LinkerSmallMoleculeBatchSelectController = (function(_super) {
    __extends(LinkerSmallMoleculeBatchSelectController, _super);

    function LinkerSmallMoleculeBatchSelectController() {
      this.handleSelectedBatchChanged = __bind(this.handleSelectedBatchChanged, this);
      this.setupBatchRegForm = __bind(this.setupBatchRegForm, this);
      return LinkerSmallMoleculeBatchSelectController.__super__.constructor.apply(this, arguments);
    }

    LinkerSmallMoleculeBatchSelectController.prototype.setupBatchRegForm = function() {
      if (this.batchModel === void 0 || this.batchModel === "new batch" || this.batchModel === null) {
        this.batchModel = new LinkerSmallMoleculeBatch();
      }
      return LinkerSmallMoleculeBatchSelectController.__super__.setupBatchRegForm.call(this);
    };

    LinkerSmallMoleculeBatchSelectController.prototype.handleSelectedBatchChanged = function() {
      this.batchCodeName = this.batchListController.getSelectedCode();
      this.batchModel = this.batchList.findWhere({
        codeName: this.batchCodeName
      });
      return this.setupBatchRegForm();
    };

    return LinkerSmallMoleculeBatchSelectController;

  })(AbstractBaseComponentBatchSelectController);

  window.LinkerSmallMoleculeController = (function(_super) {
    __extends(LinkerSmallMoleculeController, _super);

    function LinkerSmallMoleculeController() {
      this.setupBatchSelectController = __bind(this.setupBatchSelectController, this);
      this.setupParentController = __bind(this.setupParentController, this);
      this.completeInitialization = __bind(this.completeInitialization, this);
      return LinkerSmallMoleculeController.__super__.constructor.apply(this, arguments);
    }

    LinkerSmallMoleculeController.prototype.moduleLaunchName = "linker_small_molecule";

    LinkerSmallMoleculeController.prototype.initialize = function() {
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
              url: "/api/things/parent/linker small molecule/codename/" + launchCode,
              dataType: 'json',
              error: function(err) {
                alert('Could not get parent for code in this URL, creating new one');
                return this.completeInitialization();
              },
              success: (function(_this) {
                return function(json) {
                  var lsmp;
                  if (json.length === 0) {
                    alert('Could not get parent for code in this URL, creating new one');
                  } else {
                    lsmp = new LinkerSmallMoleculeParent(json);
                    lsmp.set(lsmp.parse(lsmp.attributes));
                    if (window.AppLaunchParams.moduleLaunchParams.copy) {
                      _this.model = lsmp.duplicate();
                    } else {
                      _this.model = lsmp;
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

    LinkerSmallMoleculeController.prototype.completeInitialization = function() {
      if (this.model == null) {
        this.model = new LinkerSmallMoleculeParent();
      }
      LinkerSmallMoleculeController.__super__.completeInitialization.call(this);
      return this.$('.bv_registrationTitle').html("Linker Small Molecule Parent/Batch Registration");
    };

    LinkerSmallMoleculeController.prototype.setupParentController = function() {
      this.parentController = new LinkerSmallMoleculeParentController({
        model: this.model,
        el: this.$('.bv_parent'),
        readOnly: this.readOnly
      });
      return LinkerSmallMoleculeController.__super__.setupParentController.call(this);
    };

    LinkerSmallMoleculeController.prototype.setupBatchSelectController = function() {
      this.batchSelectController = new LinkerSmallMoleculeBatchSelectController({
        el: this.$('.bv_batch'),
        parentCodeName: this.model.get('codeName'),
        batchCodeName: this.batchCodeName,
        batchModel: this.batchModel,
        readOnly: this.readOnly,
        lsKind: "linker small molecule"
      });
      return LinkerSmallMoleculeController.__super__.setupBatchSelectController.call(this);
    };

    return LinkerSmallMoleculeController;

  })(AbstractBaseComponentController);

}).call(this);
