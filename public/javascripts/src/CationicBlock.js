(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.CationicBlockParent = (function(_super) {
    __extends(CationicBlockParent, _super);

    function CationicBlockParent() {
      return CationicBlockParent.__super__.constructor.apply(this, arguments);
    }

    CationicBlockParent.prototype.urlRoot = "/api/cationicBlockParents";

    CationicBlockParent.prototype.initialize = function() {
      this.set({
        lsType: "parent",
        lsKind: "cationic block"
      });
      return CationicBlockParent.__super__.initialize.call(this);
    };

    CationicBlockParent.prototype.lsProperties = {
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
          codeOrigin: window.conf.scientistCodeOrigin
        }, {
          key: 'completion date',
          stateType: 'metadata',
          stateKind: 'cationic block parent',
          type: 'dateValue',
          kind: 'completion date'
        }, {
          key: 'notebook',
          stateType: 'metadata',
          stateKind: 'cationic block parent',
          type: 'stringValue',
          kind: 'notebook'
        }, {
          key: 'structural file',
          stateType: 'metadata',
          stateKind: 'cationic block parent',
          type: 'fileValue',
          kind: 'structural file'
        }
      ]
    };

    return CationicBlockParent;

  })(AbstractBaseComponentParent);

  window.CationicBlockBatch = (function(_super) {
    __extends(CationicBlockBatch, _super);

    function CationicBlockBatch() {
      return CationicBlockBatch.__super__.constructor.apply(this, arguments);
    }

    CationicBlockBatch.prototype.urlRoot = "/api/cationicBlockBatches";

    CationicBlockBatch.prototype.initialize = function() {
      this.set({
        lsType: "batch",
        lsKind: "cationic block"
      });
      return CationicBlockBatch.__super__.initialize.call(this);
    };

    CationicBlockBatch.prototype.lsProperties = {
      defaultLabels: [],
      defaultValues: [
        {
          key: 'scientist',
          stateType: 'metadata',
          stateKind: 'cationic block batch',
          type: 'codeValue',
          kind: 'scientist',
          codeOrigin: window.conf.scientistCodeOrigin
        }, {
          key: 'completion date',
          stateType: 'metadata',
          stateKind: 'cationic block batch',
          type: 'dateValue',
          kind: 'completion date'
        }, {
          key: 'notebook',
          stateType: 'metadata',
          stateKind: 'cationic block batch',
          type: 'stringValue',
          kind: 'notebook'
        }, {
          key: 'source',
          stateType: 'metadata',
          stateKind: 'cationic block batch',
          type: 'codeValue',
          kind: 'source',
          value: 'Avidity',
          codeType: 'component',
          codeKind: 'source',
          codeOrigin: 'ACAS DDICT'
        }, {
          key: 'source id',
          stateType: 'metadata',
          stateKind: 'cationic block batch',
          type: 'stringValue',
          kind: 'source id'
        }, {
          key: 'molecular weight',
          stateType: 'metadata',
          stateKind: 'cationic block batch',
          type: 'numericValue',
          kind: 'molecular weight',
          unitType: 'molecular weight',
          unitKind: 'g/mol'
        }, {
          key: 'purity',
          stateType: 'metadata',
          stateKind: 'cationic block batch',
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

    CationicBlockBatch.prototype.validate = function(attrs) {
      var errors, mw, purity;
      errors = [];
      errors.push.apply(errors, CationicBlockBatch.__super__.validate.call(this, attrs));
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

    return CationicBlockBatch;

  })(AbstractBaseComponentBatch);

  window.CationicBlockParentController = (function(_super) {
    __extends(CationicBlockParentController, _super);

    function CationicBlockParentController() {
      this.updateModel = __bind(this.updateModel, this);
      this.handleFileRemoved = __bind(this.handleFileRemoved, this);
      this.handleFileUpload = __bind(this.handleFileUpload, this);
      this.render = __bind(this.render, this);
      return CationicBlockParentController.__super__.constructor.apply(this, arguments);
    }

    CationicBlockParentController.prototype.additionalParentAttributesTemplate = _.template($("#CationicBlockParentView").html());

    CationicBlockParentController.prototype.initialize = function() {
      if (this.model == null) {
        console.log("create new model in initialize");
        this.model = new CationicBlockParent();
      }
      this.errorOwnerName = 'CationicBlockParentController';
      return CationicBlockParentController.__super__.initialize.call(this);
    };

    CationicBlockParentController.prototype.render = function() {
      if (this.model == null) {
        this.model = new CationicBlockParent();
      }
      CationicBlockParentController.__super__.render.call(this);
      return this.setupStructuralFileController();
    };

    CationicBlockParentController.prototype.setupStructuralFileController = function() {
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

    CationicBlockParentController.prototype.handleFileUpload = function(nameOnServer) {
      console.log("file uploaded");
      this.model.get("structural file").set("value", nameOnServer);
      console.log(this.model);
      return this.trigger('amDirty');
    };

    CationicBlockParentController.prototype.handleFileRemoved = function() {
      console.log("file removed");
      this.model.get("structural file").set("value", "");
      return console.log(this.model);
    };

    CationicBlockParentController.prototype.updateModel = function() {
      this.model.get("cationic block name").set("labelText", UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_parentName')));
      return CationicBlockParentController.__super__.updateModel.call(this);
    };

    return CationicBlockParentController;

  })(AbstractBaseComponentParentController);

  window.CationicBlockBatchController = (function(_super) {
    __extends(CationicBlockBatchController, _super);

    function CationicBlockBatchController() {
      this.updateModel = __bind(this.updateModel, this);
      this.render = __bind(this.render, this);
      return CationicBlockBatchController.__super__.constructor.apply(this, arguments);
    }

    CationicBlockBatchController.prototype.additionalBatchAttributesTemplate = _.template($("#CationicBlockBatchView").html());

    CationicBlockBatchController.prototype.events = function() {
      return _(CationicBlockBatchController.__super__.events.call(this)).extend({
        "keyup .bv_molecularWeight": "attributeChanged",
        "keyup .bv_purity": "attributeChanged"
      });
    };

    CationicBlockBatchController.prototype.initialize = function() {
      if (this.model == null) {
        console.log("create new model in initialize");
        this.model = new CationicBlockBatch();
      }
      this.errorOwnerName = 'CationicBlockBatchController';
      return CationicBlockBatchController.__super__.initialize.call(this);
    };

    CationicBlockBatchController.prototype.render = function() {
      if (this.model == null) {
        console.log("create new model");
        this.model = new CationicBlockBatch();
      }
      CationicBlockBatchController.__super__.render.call(this);
      this.$('.bv_molecularWeight').val(this.model.get('molecular weight').get('value'));
      return this.$('.bv_purity').val(this.model.get('purity').get('value'));
    };

    CationicBlockBatchController.prototype.updateModel = function() {
      this.model.get("molecular weight").set("value", parseFloat(UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_molecularWeight'))));
      this.model.get("purity").set("value", parseFloat(UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_purity'))));
      return CationicBlockBatchController.__super__.updateModel.call(this);
    };

    return CationicBlockBatchController;

  })(AbstractBaseComponentBatchController);

  window.CationicBlockBatchSelectController = (function(_super) {
    __extends(CationicBlockBatchSelectController, _super);

    function CationicBlockBatchSelectController() {
      this.handleSelectedBatchChanged = __bind(this.handleSelectedBatchChanged, this);
      return CationicBlockBatchSelectController.__super__.constructor.apply(this, arguments);
    }

    CationicBlockBatchSelectController.prototype.setupBatchRegForm = function(batch) {
      var model;
      if (batch != null) {
        console.log("batch exists");
        model = batch;
      } else {
        console.log("batch doesn't exist");
        model = new CationicBlockBatch();
      }
      this.batchController = new CationicBlockBatchController({
        model: model,
        el: this.$('.bv_batchRegForm')
      });
      return CationicBlockBatchSelectController.__super__.setupBatchRegForm.call(this);
    };

    CationicBlockBatchSelectController.prototype.handleSelectedBatchChanged = function() {
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
            return this.batchController.model = new CationicBlockBatch();
          },
          success: (function(_this) {
            return function(json) {
              var pb;
              if (json.length === 0) {
                return alert('Could not get selected batch, creating new one');
              } else {
                pb = new CationicBlockBatch(json);
                pb.set(pb.parse(pb.attributes));
                return _this.setupBatchRegForm(pb);
              }
            };
          })(this)
        });
      }
    };

    return CationicBlockBatchSelectController;

  })(AbstractBaseComponentBatchSelectController);

  window.CationicBlockController = (function(_super) {
    __extends(CationicBlockController, _super);

    function CationicBlockController() {
      this.completeInitialization = __bind(this.completeInitialization, this);
      return CationicBlockController.__super__.constructor.apply(this, arguments);
    }

    CationicBlockController.prototype.moduleLaunchName = "cationic_block";

    CationicBlockController.prototype.initialize = function() {
      if (this.model != null) {
        return this.completeInitialization();
      } else {
        if (window.AppLaunchParams.moduleLaunchParams != null) {
          if (window.AppLaunchParams.moduleLaunchParams.moduleName === this.moduleLaunchName) {
            return $.ajax({
              type: 'GET',
              url: "/api/cationicBlockParents/codeName/" + window.AppLaunchParams.moduleLaunchParams.code,
              dataType: 'json',
              error: function(err) {
                alert('Could not get parent for code in this URL, creating new one');
                console.log("ci 1");
                return this.completeInitialization();
              },
              success: (function(_this) {
                return function(json) {
                  var cbp;
                  if (json.length === 0) {
                    console.log("ci 2");
                    alert('Could not get parent for code in this URL, creating new one');
                  } else {
                    cbp = new CationicBlockParent(json);
                    cbp.set(cbp.parse(cbp.attributes));
                    _this.model = cbp;
                    console.log("ci 3");
                  }
                  return _this.completeInitialization();
                };
              })(this)
            });
          } else {
            console.log("ci 4");
            return this.completeInitialization();
          }
        } else {
          console.log("ci 5");
          return this.completeInitialization();
        }
      }
    };

    CationicBlockController.prototype.completeInitialization = function() {
      if (this.model == null) {
        this.model = new CationicBlockParent();
      }
      CationicBlockController.__super__.completeInitialization.call(this);
      return this.$('.bv_registrationTitle').html("Cationic Block Parent/Batch Registration");
    };

    CationicBlockController.prototype.setupParentController = function() {
      console.log("set up cationic block parent controller");
      console.log(this.model);
      this.parentController = new CationicBlockParentController({
        model: this.model,
        el: this.$('.bv_parent')
      });
      return CationicBlockController.__super__.setupParentController.call(this);
    };

    CationicBlockController.prototype.setupBatchSelectController = function() {
      this.batchSelectController = new CationicBlockBatchSelectController({
        el: this.$('.bv_batch'),
        parentCodeName: this.model.get('codeName')
      });
      return CationicBlockController.__super__.setupBatchSelectController.call(this);
    };

    return CationicBlockController;

  })(AbstractBaseComponentController);

}).call(this);
