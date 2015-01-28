(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.SpacerParent = (function(_super) {
    __extends(SpacerParent, _super);

    function SpacerParent() {
      return SpacerParent.__super__.constructor.apply(this, arguments);
    }

    SpacerParent.prototype.urlRoot = "/api/spacerParents";

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

    return SpacerParent;

  })(AbstractBaseComponentParent);

  window.SpacerBatch = (function(_super) {
    __extends(SpacerBatch, _super);

    function SpacerBatch() {
      return SpacerBatch.__super__.constructor.apply(this, arguments);
    }

    SpacerBatch.prototype.urlRoot = "/api/spacerBatches";

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
        console.log("create new model in initialize");
        this.model = new SpacerParent();
      }
      this.errorOwnerName = 'SpacerParentController';
      return SpacerParentController.__super__.initialize.call(this);
    };

    SpacerParentController.prototype.render = function() {
      if (this.model == null) {
        this.model = new SpacerParent();
      }
      SpacerParentController.__super__.render.call(this);
      this.$('.bv_molecularWeight').val(this.model.get('molecular weight').get('value'));
      return this.setupStructuralFileController();
    };

    SpacerParentController.prototype.setupStructuralFileController = function() {
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

    SpacerParentController.prototype.handleFileUpload = function(nameOnServer) {
      console.log("file uploaded");
      this.model.get("structural file").set("value", nameOnServer);
      console.log(this.model);
      return this.trigger('amDirty');
    };

    SpacerParentController.prototype.handleFileRemoved = function() {
      console.log("file removed");
      this.model.get("structural file").set("value", "");
      return console.log(this.model);
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
        console.log("create new model in initialize");
        this.model = new SpacerBatch();
      }
      this.errorOwnerName = 'SpacerBatchController';
      return SpacerBatchController.__super__.initialize.call(this);
    };

    SpacerBatchController.prototype.render = function() {
      if (this.model == null) {
        console.log("create new model");
        this.model = new SpacerBatch();
      }
      SpacerBatchController.__super__.render.call(this);
      return this.$('.bv_purity').val(this.model.get('purity').get('value'));
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
      return SpacerBatchSelectController.__super__.constructor.apply(this, arguments);
    }

    SpacerBatchSelectController.prototype.setupBatchRegForm = function(batch) {
      var model;
      if (batch != null) {
        model = batch;
      } else {
        model = new SpacerBatch();
      }
      this.batchController = new SpacerBatchController({
        model: model,
        el: this.$('.bv_batchRegForm')
      });
      return SpacerBatchSelectController.__super__.setupBatchRegForm.call(this);
    };

    SpacerBatchSelectController.prototype.handleSelectedBatchChanged = function() {
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
            return this.batchController.model = new SpacerBatch();
          },
          success: (function(_this) {
            return function(json) {
              var pb;
              if (json.length === 0) {
                return alert('Could not get selected batch, creating new one');
              } else {
                pb = new SpacerBatch(json);
                pb.set(pb.parse(pb.attributes));
                return _this.setupBatchRegForm(pb);
              }
            };
          })(this)
        });
      }
    };

    return SpacerBatchSelectController;

  })(AbstractBaseComponentBatchSelectController);

  window.SpacerController = (function(_super) {
    __extends(SpacerController, _super);

    function SpacerController() {
      this.completeInitialization = __bind(this.completeInitialization, this);
      return SpacerController.__super__.constructor.apply(this, arguments);
    }

    SpacerController.prototype.moduleLaunchName = "spacer";

    SpacerController.prototype.initialize = function() {
      if (this.model != null) {
        return this.completeInitialization();
      } else {
        if (window.AppLaunchParams.moduleLaunchParams != null) {
          if (window.AppLaunchParams.moduleLaunchParams.moduleName === this.moduleLaunchName) {
            return $.ajax({
              type: 'GET',
              url: "/api/spacerParents/codeName/" + window.AppLaunchParams.moduleLaunchParams.code,
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
                    cbp = new SpacerParent(json);
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

    SpacerController.prototype.completeInitialization = function() {
      if (this.model == null) {
        this.model = new SpacerParent();
      }
      SpacerController.__super__.completeInitialization.call(this);
      return this.$('.bv_registrationTitle').html("Spacer Parent/Batch Registration");
    };

    SpacerController.prototype.setupParentController = function() {
      console.log("set up spacer parent controller");
      console.log(this.model);
      this.parentController = new SpacerParentController({
        model: this.model,
        el: this.$('.bv_parent')
      });
      return SpacerController.__super__.setupParentController.call(this);
    };

    SpacerController.prototype.setupBatchSelectController = function() {
      this.batchSelectController = new SpacerBatchSelectController({
        el: this.$('.bv_batch'),
        parentCodeName: this.model.get('codeName')
      });
      return SpacerController.__super__.setupBatchSelectController.call(this);
    };

    return SpacerController;

  })(AbstractBaseComponentController);

}).call(this);
