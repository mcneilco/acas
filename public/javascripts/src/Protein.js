(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.ProteinParent = (function(_super) {
    __extends(ProteinParent, _super);

    function ProteinParent() {
      this.duplicate = __bind(this.duplicate, this);
      return ProteinParent.__super__.constructor.apply(this, arguments);
    }

    ProteinParent.prototype.urlRoot = "/api/proteinParents";

    ProteinParent.prototype.className = "ProteinParent";

    ProteinParent.prototype.initialize = function() {
      this.set({
        lsType: "parent",
        lsKind: "protein"
      });
      return ProteinParent.__super__.initialize.call(this);
    };

    ProteinParent.prototype.lsProperties = {
      defaultLabels: [
        {
          key: 'protein name',
          type: 'name',
          kind: 'protein',
          preferred: true
        }
      ],
      defaultValues: [
        {
          key: 'scientist',
          stateType: 'metadata',
          stateKind: 'protein parent',
          type: 'codeValue',
          kind: 'scientist',
          codeOrigin: window.conf.scientistCodeOrigin
        }, {
          key: 'completion date',
          stateType: 'metadata',
          stateKind: 'protein parent',
          type: 'dateValue',
          kind: 'completion date'
        }, {
          key: 'notebook',
          stateType: 'metadata',
          stateKind: 'protein parent',
          type: 'stringValue',
          kind: 'notebook'
        }, {
          key: 'molecular weight',
          stateType: 'metadata',
          stateKind: 'protein parent',
          type: 'numericValue',
          kind: 'molecular weight',
          unitType: 'molecular weight',
          unitKind: 'g/mol'
        }, {
          key: 'type',
          stateType: 'metadata',
          stateKind: 'protein parent',
          type: 'codeValue',
          kind: 'type',
          codeType: 'protein',
          codeKind: 'type',
          codeOrigin: 'ACAS DDICT'
        }, {
          key: 'aa sequence',
          stateType: 'metadata',
          stateKind: 'protein parent',
          type: 'clobValue',
          kind: 'aa sequence'
        }, {
          key: 'target',
          stateType: 'metadata',
          stateKind: 'protein parent',
          type: 'codeValue',
          kind: 'target'
        }, {
          key: 'batch number',
          stateType: 'metadata',
          stateKind: 'protein parent',
          type: 'numericValue',
          kind: 'batch number',
          value: 0
        }
      ]
    };

    ProteinParent.prototype.validate = function(attrs) {
      var errors, mw, type;
      errors = [];
      errors.push.apply(errors, ProteinParent.__super__.validate.call(this, attrs));
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
      if (attrs.type != null) {
        type = attrs.type.get('value');
        if (type === "unassigned" || type === "" || type === void 0) {
          errors.push({
            attribute: 'type',
            message: "Type must be set"
          });
        }
      }
      if (errors.length > 0) {
        return errors;
      } else {
        return null;
      }
    };

    ProteinParent.prototype.duplicate = function() {
      var copiedThing;
      copiedThing = ProteinParent.__super__.duplicate.call(this);
      copiedThing.get("protein name").set("labelText", "");
      return copiedThing;
    };

    return ProteinParent;

  })(AbstractBaseComponentParent);

  window.ProteinBatch = (function(_super) {
    __extends(ProteinBatch, _super);

    function ProteinBatch() {
      return ProteinBatch.__super__.constructor.apply(this, arguments);
    }

    ProteinBatch.prototype.urlRoot = "/api/proteinBatches";

    ProteinBatch.prototype.initialize = function() {
      this.set({
        lsType: "batch",
        lsKind: "protein"
      });
      return ProteinBatch.__super__.initialize.call(this);
    };

    ProteinBatch.prototype.lsProperties = {
      defaultLabels: [],
      defaultValues: [
        {
          key: 'scientist',
          stateType: 'metadata',
          stateKind: 'protein batch',
          type: 'codeValue',
          kind: 'scientist',
          codeOrigin: window.conf.scientistCodeOrigin
        }, {
          key: 'completion date',
          stateType: 'metadata',
          stateKind: 'protein batch',
          type: 'dateValue',
          kind: 'completion date'
        }, {
          key: 'notebook',
          stateType: 'metadata',
          stateKind: 'protein batch',
          type: 'stringValue',
          kind: 'notebook'
        }, {
          key: 'source',
          stateType: 'metadata',
          stateKind: 'protein batch',
          type: 'codeValue',
          kind: 'source',
          value: 'Avidity',
          codeType: 'component',
          codeKind: 'source',
          codeOrigin: 'ACAS DDICT'
        }, {
          key: 'source id',
          stateType: 'metadata',
          stateKind: 'protein batch',
          type: 'stringValue',
          kind: 'source id'
        }, {
          key: 'purity',
          stateType: 'metadata',
          stateKind: 'protein batch',
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

    ProteinBatch.prototype.validate = function(attrs) {
      var errors, purity;
      errors = [];
      errors.push.apply(errors, ProteinBatch.__super__.validate.call(this, attrs));
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

    return ProteinBatch;

  })(AbstractBaseComponentBatch);

  window.ProteinParentController = (function(_super) {
    __extends(ProteinParentController, _super);

    function ProteinParentController() {
      this.updateModel = __bind(this.updateModel, this);
      this.render = __bind(this.render, this);
      return ProteinParentController.__super__.constructor.apply(this, arguments);
    }

    ProteinParentController.prototype.additionalParentAttributesTemplate = _.template($("#ProteinParentView").html());

    ProteinParentController.prototype.events = function() {
      return _(ProteinParentController.__super__.events.call(this)).extend({
        "keyup .bv_molecularWeight": "attributeChanged",
        "change .bv_type": "attributeChanged",
        "keyup .bv_sequence": "attributeChanged",
        "change .bv_target": "attributeChanged"
      });
    };

    ProteinParentController.prototype.initialize = function() {
      if (this.model == null) {
        this.model = new ProteinParent();
      }
      this.errorOwnerName = 'ProteinParentController';
      ProteinParentController.__super__.initialize.call(this);
      this.setupType();
      return this.setupTarget();
    };

    ProteinParentController.prototype.render = function() {
      if (this.model == null) {
        this.model = new ProteinParent();
      }
      this.$('.bv_molecularWeight').val(this.model.get('molecular weight').get('value'));
      this.$('.bv_type').val(this.model.get('type').get('value'));
      this.$('.bv_sequence').val(this.model.get('aa sequence').get('value'));
      this.$('.bv_target').val(this.model.get('target').get('value'));
      return ProteinParentController.__super__.render.call(this);
    };

    ProteinParentController.prototype.updateModel = function() {
      this.model.get("protein name").set("labelText", UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_parentName')));
      this.model.get("molecular weight").set("value", parseFloat(UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_molecularWeight'))));
      this.model.get("type").set("value", this.typeListController.getSelectedCode());
      this.model.get("aa sequence").set("value", UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_sequence')));
      this.model.get("target").set("value", this.targetListController.getSelectedCode());
      return ProteinParentController.__super__.updateModel.call(this);
    };

    ProteinParentController.prototype.setupType = function() {
      this.typeList = new PickListList();
      this.typeList.url = "/api/codetables/protein/type";
      return this.typeListController = new PickListSelectController({
        el: this.$('.bv_type'),
        collection: this.typeList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select type"
        }),
        selectedCode: this.model.get('type').get('value')
      });
    };

    ProteinParentController.prototype.setupTarget = function() {
      this.targetList = new PickListList();
      this.targetList.url = "/api/codetables/protein/target";
      return this.targetListController = new PickListSelectController({
        el: this.$('.bv_target'),
        collection: this.targetList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select target"
        }),
        selectedCode: this.model.get('target').get('value')
      });
    };

    return ProteinParentController;

  })(AbstractBaseComponentParentController);

  window.ProteinBatchController = (function(_super) {
    __extends(ProteinBatchController, _super);

    function ProteinBatchController() {
      this.updateModel = __bind(this.updateModel, this);
      this.render = __bind(this.render, this);
      return ProteinBatchController.__super__.constructor.apply(this, arguments);
    }

    ProteinBatchController.prototype.additionalBatchAttributesTemplate = _.template($("#ProteinBatchView").html());

    ProteinBatchController.prototype.events = function() {
      return _(ProteinBatchController.__super__.events.call(this)).extend({
        "keyup .bv_purity": "attributeChanged"
      });
    };

    ProteinBatchController.prototype.initialize = function() {
      if (this.model == null) {
        this.model = new ProteinBatch();
      }
      this.errorOwnerName = 'ProteinBatchController';
      return ProteinBatchController.__super__.initialize.call(this);
    };

    ProteinBatchController.prototype.render = function() {
      if (this.model == null) {
        this.model = new ProteinBatch();
      }
      this.$('.bv_purity').val(this.model.get('purity').get('value'));
      return ProteinBatchController.__super__.render.call(this);
    };

    ProteinBatchController.prototype.updateModel = function() {
      this.model.get("purity").set("value", parseFloat(UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_purity'))));
      return ProteinBatchController.__super__.updateModel.call(this);
    };

    return ProteinBatchController;

  })(AbstractBaseComponentBatchController);

  window.ProteinBatchSelectController = (function(_super) {
    __extends(ProteinBatchSelectController, _super);

    function ProteinBatchSelectController() {
      this.handleSelectedBatchChanged = __bind(this.handleSelectedBatchChanged, this);
      this.setupBatchRegForm = __bind(this.setupBatchRegForm, this);
      return ProteinBatchSelectController.__super__.constructor.apply(this, arguments);
    }

    ProteinBatchSelectController.prototype.setupBatchRegForm = function() {
      if (this.batchModel === void 0 || this.batchModel === "new batch" || this.batchModel === null) {
        this.batchModel = new ProteinBatch();
      }
      return ProteinBatchSelectController.__super__.setupBatchRegForm.call(this);
    };

    ProteinBatchSelectController.prototype.handleSelectedBatchChanged = function() {
      this.batchCodeName = this.batchListController.getSelectedCode();
      this.batchModel = this.batchList.findWhere({
        codeName: this.batchCodeName
      });
      return this.setupBatchRegForm();
    };

    return ProteinBatchSelectController;

  })(AbstractBaseComponentBatchSelectController);

  window.ProteinController = (function(_super) {
    __extends(ProteinController, _super);

    function ProteinController() {
      this.setupBatchSelectController = __bind(this.setupBatchSelectController, this);
      this.setupParentController = __bind(this.setupParentController, this);
      this.completeInitialization = __bind(this.completeInitialization, this);
      return ProteinController.__super__.constructor.apply(this, arguments);
    }

    ProteinController.prototype.moduleLaunchName = "protein";

    ProteinController.prototype.initialize = function() {
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
              url: "/api/proteinParents/codename/" + launchCode,
              dataType: 'json',
              error: function(err) {
                alert('Could not get parent for code in this URL, creating new one');
                return this.completeInitialization();
              },
              success: (function(_this) {
                return function(json) {
                  var pp;
                  if (json.length === 0) {
                    alert('Could not get parent for code in this URL, creating new one');
                  } else {
                    pp = new ProteinParent(json);
                    pp.set(pp.parse(pp.attributes));
                    if (window.AppLaunchParams.moduleLaunchParams.copy) {
                      _this.model = pp.duplicate();
                    } else {
                      _this.model = pp;
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

    ProteinController.prototype.completeInitialization = function() {
      if (this.model == null) {
        this.model = new ProteinParent();
      }
      ProteinController.__super__.completeInitialization.call(this);
      return this.$('.bv_registrationTitle').html("Protein Parent/Batch Registration");
    };

    ProteinController.prototype.setupParentController = function() {
      this.parentController = new ProteinParentController({
        model: this.model,
        el: this.$('.bv_parent'),
        readOnly: this.readOnly
      });
      return ProteinController.__super__.setupParentController.call(this);
    };

    ProteinController.prototype.setupBatchSelectController = function() {
      this.batchSelectController = new ProteinBatchSelectController({
        el: this.$('.bv_batch'),
        parentCodeName: this.model.get('codeName'),
        batchCodeName: this.batchCodeName,
        batchModel: this.batchModel,
        readOnly: this.readOnly,
        lsKind: "protein"
      });
      return ProteinController.__super__.setupBatchSelectController.call(this);
    };

    return ProteinController;

  })(AbstractBaseComponentController);

}).call(this);
