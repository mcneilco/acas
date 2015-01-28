(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.LinkerSmallMoleculeParent = (function(_super) {
    __extends(LinkerSmallMoleculeParent, _super);

    function LinkerSmallMoleculeParent() {
      return LinkerSmallMoleculeParent.__super__.constructor.apply(this, arguments);
    }

    LinkerSmallMoleculeParent.prototype.urlRoot = "/api/linkerSmallMoleculeParents";

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
        }
      ]
    };

    LinkerSmallMoleculeParent.prototype.validate = function(attrs) {
      var errors, mw;
      console.log("validate parent");
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
      console.log("parent errors");
      console.log(errors);
      if (errors.length > 0) {
        return errors;
      } else {
        return null;
      }
    };

    return LinkerSmallMoleculeParent;

  })(AbstractBaseComponentParent);

  window.LinkerSmallMoleculeBatch = (function(_super) {
    __extends(LinkerSmallMoleculeBatch, _super);

    function LinkerSmallMoleculeBatch() {
      return LinkerSmallMoleculeBatch.__super__.constructor.apply(this, arguments);
    }

    LinkerSmallMoleculeBatch.prototype.urlRoot = "/api/linkerSmallMoleculeBatches";

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
      console.log("validate batch");
      errors = [];
      errors.push.apply(errors, LinkerSmallMoleculeBatch.__super__.validate.call(this, attrs));
      if (attrs.purity != null) {
        console.log("purity");
        purity = attrs.purity.get('value');
        console.log(purity);
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
      console.log("batch errors");
      console.log(errors);
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
        console.log("create new model in initialize");
        this.model = new LinkerSmallMoleculeParent();
      }
      this.errorOwnerName = 'LinkerSmallMoleculeParentController';
      return LinkerSmallMoleculeParentController.__super__.initialize.call(this);
    };

    LinkerSmallMoleculeParentController.prototype.render = function() {
      if (this.model == null) {
        this.model = new LinkerSmallMoleculeParent();
      }
      LinkerSmallMoleculeParentController.__super__.render.call(this);
      this.$('.bv_molecularWeight').val(this.model.get('molecular weight').get('value'));
      this.setupStructuralFileController();
      return this;
    };

    LinkerSmallMoleculeParentController.prototype.setupStructuralFileController = function() {
      this.structuralFileController = new LSFileChooserController({
        el: this.$('.bv_structuralFile'),
        formId: 'fieldBlah',
        maxNumberOfFiles: 1,
        requiresValidation: false,
        url: UtilityFunctions.prototype.getFileServiceURL(),
        allowedFileTypes: ['sdf', 'mol', 'xlsx'],
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
      console.log("file uploaded");
      this.model.get("structural file").set("value", nameOnServer);
      console.log(this.model);
      return this.trigger('amDirty');
    };

    LinkerSmallMoleculeParentController.prototype.handleFileRemoved = function() {
      console.log("file removed");
      this.model.get("structural file").set("value", "");
      return console.log(this.model);
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
        console.log("create new model in initialize");
        this.model = new LinkerSmallMoleculeBatch();
      }
      this.errorOwnerName = 'LinkerSmallMoleculeBatchController';
      return LinkerSmallMoleculeBatchController.__super__.initialize.call(this);
    };

    LinkerSmallMoleculeBatchController.prototype.render = function() {
      if (this.model == null) {
        console.log("create new model");
        this.model = new LinkerSmallMoleculeBatch();
      }
      LinkerSmallMoleculeBatchController.__super__.render.call(this);
      return this.$('.bv_purity').val(this.model.get('purity').get('value'));
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
      return LinkerSmallMoleculeBatchSelectController.__super__.constructor.apply(this, arguments);
    }

    LinkerSmallMoleculeBatchSelectController.prototype.setupBatchRegForm = function(batch) {
      var model;
      if (batch != null) {
        model = batch;
      } else {
        model = new LinkerSmallMoleculeBatch();
      }
      this.batchController = new LinkerSmallMoleculeBatchController({
        model: model,
        el: this.$('.bv_batchRegForm')
      });
      return LinkerSmallMoleculeBatchSelectController.__super__.setupBatchRegForm.call(this);
    };

    LinkerSmallMoleculeBatchSelectController.prototype.handleSelectedBatchChanged = function() {
      var selectedBatch;
      console.log("handle selected batch changed");
      selectedBatch = this.batchListController.getSelectedCode();
      if (selectedBatch === "new batch" || selectedBatch === null || selectedBatch === void 0) {
        return this.setupBatchRegForm();
      } else {
        return $.ajax({
          type: 'GET',
          url: "/api/batches/codename/" + selectedBatch,
          dataType: 'json',
          error: function(err) {
            alert('Could not get selected batch, creating new one');
            return this.batchController.model = new LinkerSmallMoleculeBatch();
          },
          success: (function(_this) {
            return function(json) {
              var pb;
              if (json.length === 0) {
                return alert('Could not get selected batch, creating new one');
              } else {
                pb = new LinkerSmallMoleculeBatch(json);
                pb.set(pb.parse(pb.attributes));
                return _this.setupBatchRegForm(pb);
              }
            };
          })(this)
        });
      }
    };

    return LinkerSmallMoleculeBatchSelectController;

  })(AbstractBaseComponentBatchSelectController);

  window.LinkerSmallMoleculeController = (function(_super) {
    __extends(LinkerSmallMoleculeController, _super);

    function LinkerSmallMoleculeController() {
      this.completeInitialization = __bind(this.completeInitialization, this);
      return LinkerSmallMoleculeController.__super__.constructor.apply(this, arguments);
    }

    LinkerSmallMoleculeController.prototype.moduleLaunchName = "linker_small_molecule";

    LinkerSmallMoleculeController.prototype.initialize = function() {
      if (this.model != null) {
        return this.completeInitialization();
      } else {
        if (window.AppLaunchParams.moduleLaunchParams != null) {
          if (window.AppLaunchParams.moduleLaunchParams.moduleName === this.moduleLaunchName) {
            return $.ajax({
              type: 'GET',
              url: "/api/linkerSmallMoleculeParents/codeName/" + window.AppLaunchParams.moduleLaunchParams.code,
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
                    _this.model = lsmp;
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
      console.log("set up linker small molecule parent controller");
      console.log(this.model);
      this.parentController = new LinkerSmallMoleculeParentController({
        model: this.model,
        el: this.$('.bv_parent')
      });
      return LinkerSmallMoleculeController.__super__.setupParentController.call(this);
    };

    LinkerSmallMoleculeController.prototype.setupBatchSelectController = function() {
      this.batchSelectController = new LinkerSmallMoleculeBatchSelectController({
        el: this.$('.bv_batch'),
        parentCodeName: this.model.get('codeName')
      });
      return LinkerSmallMoleculeController.__super__.setupBatchSelectController.call(this);
    };

    return LinkerSmallMoleculeController;

  })(AbstractBaseComponentController);

}).call(this);
