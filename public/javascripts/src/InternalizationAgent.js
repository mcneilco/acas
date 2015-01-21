(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.InternalizationAgentParent = (function(_super) {
    __extends(InternalizationAgentParent, _super);

    function InternalizationAgentParent() {
      return InternalizationAgentParent.__super__.constructor.apply(this, arguments);
    }

    InternalizationAgentParent.prototype.urlRoot = "/api/internalizationAgentParents";

    InternalizationAgentParent.prototype.initialize = function() {
      this.set({
        lsType: "parent",
        lsKind: "internalization agent"
      });
      return InternalizationAgentParent.__super__.initialize.call(this);
    };

    InternalizationAgentParent.prototype.lsProperties = {
      defaultLabels: [
        {
          key: 'internalization agent name',
          type: 'name',
          kind: 'internalization agent',
          preferred: true
        }
      ],
      defaultValues: [
        {
          key: 'completion date',
          stateType: 'metadata',
          stateKind: 'internalization agent parent',
          type: 'dateValue',
          kind: 'completion date'
        }, {
          key: 'notebook',
          stateType: 'metadata',
          stateKind: 'internalization agent parent',
          type: 'stringValue',
          kind: 'notebook'
        }, {
          key: 'conjugation type',
          stateType: 'metadata',
          stateKind: 'internalization agent parent',
          type: 'codeValue',
          kind: 'conjugation type',
          codeType: 'internalization agent',
          codeKind: 'conjugation type',
          codeOrigin: 'ACAS DDICT'
        }, {
          key: 'conjugation site',
          stateType: 'metadata',
          stateKind: 'internalization agent parent',
          type: 'codeValue',
          kind: 'conjugation site',
          codeType: 'internalization agent',
          codeKind: 'conjugation site',
          codeOrigin: 'ACAS DDICT'
        }
      ]
    };

    InternalizationAgentParent.prototype.validate = function(attrs) {
      var conjugationSite, conjugationType, errors;
      errors = [];
      errors.push.apply(errors, InternalizationAgentParent.__super__.validate.call(this, attrs));
      if (attrs["conjugation type"] != null) {
        conjugationType = attrs["conjugation type"].get('value');
        if (conjugationType === "unassigned" || conjugationType === "" || conjugationType === void 0) {
          errors.push({
            attribute: 'conjugationType',
            message: "Conjugation type must be set"
          });
        }
      }
      if (attrs["conjugation site"] != null) {
        conjugationSite = attrs["conjugation site"].get('value');
        if (conjugationSite === "unassigned" || conjugationSite === "" || conjugationSite === void 0) {
          errors.push({
            attribute: 'conjugationSite',
            message: "Conjugation site must be set"
          });
        }
      }
      if (errors.length > 0) {
        return errors;
      } else {
        return null;
      }
    };

    return InternalizationAgentParent;

  })(AbstractBaseComponentParent);

  window.InternalizationAgentBatch = (function(_super) {
    __extends(InternalizationAgentBatch, _super);

    function InternalizationAgentBatch() {
      return InternalizationAgentBatch.__super__.constructor.apply(this, arguments);
    }

    InternalizationAgentBatch.prototype.urlRoot = "/api/internalizationAgentBatches";

    InternalizationAgentBatch.prototype.initialize = function() {
      this.set({
        lsType: "batch",
        lsKind: "internalization agent"
      });
      return InternalizationAgentBatch.__super__.initialize.call(this);
    };

    InternalizationAgentBatch.prototype.lsProperties = {
      defaultLabels: [],
      defaultValues: [
        {
          key: 'completion date',
          stateType: 'metadata',
          stateKind: 'internalization agent batch',
          type: 'dateValue',
          kind: 'completion date'
        }, {
          key: 'notebook',
          stateType: 'metadata',
          stateKind: 'internalization agent batch',
          type: 'stringValue',
          kind: 'notebook'
        }, {
          key: 'source',
          stateType: 'metadata',
          stateKind: 'internalization agent batch',
          type: 'codeValue',
          kind: 'source',
          value: 'Avidity',
          codeType: 'component',
          codeKind: 'source',
          codeOrigin: 'ACAS DDICT'
        }, {
          key: 'source id',
          stateType: 'metadata',
          stateKind: 'internalization agent batch',
          type: 'stringValue',
          kind: 'source id'
        }, {
          key: 'molecular weight',
          stateType: 'metadata',
          stateKind: 'internalization agent batch',
          type: 'numericValue',
          kind: 'molecular weight',
          unitType: 'molecular weight',
          unitKind: 'kDa'
        }, {
          key: 'purity',
          stateType: 'metadata',
          stateKind: 'internalization agent batch',
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

    InternalizationAgentBatch.prototype.validate = function(attrs) {
      var errors, mw, purity;
      errors = [];
      errors.push.apply(errors, InternalizationAgentBatch.__super__.validate.call(this, attrs));
      if (attrs["molecular weight"] != null) {
        mw = attrs["molecular weight"].get('value');
        if (mw === "" || mw === void 0 || isNaN(mw)) {
          errors.push({
            attribute: 'molecularWeight',
            message: "Molecular weight must be set"
          });
        }
      }
      if (attrs.purity != null) {
        purity = attrs.purity.get('value');
        if (purity === "" || purity === void 0 || isNaN(purity)) {
          errors.push({
            attribute: 'purity',
            message: "Purity must be set"
          });
        }
      }
      if (errors.length > 0) {
        return errors;
      } else {
        return null;
      }
    };

    return InternalizationAgentBatch;

  })(AbstractBaseComponentBatch);

  window.InternalizationAgentParentController = (function(_super) {
    __extends(InternalizationAgentParentController, _super);

    function InternalizationAgentParentController() {
      this.updateModel = __bind(this.updateModel, this);
      this.render = __bind(this.render, this);
      return InternalizationAgentParentController.__super__.constructor.apply(this, arguments);
    }

    InternalizationAgentParentController.prototype.componentPickerTemplate = _.template($("#ComponentPickerView").html());

    InternalizationAgentParentController.prototype.additionalParentAttributesTemplate = _.template($("#InternalizationAgentParentView").html());

    InternalizationAgentParentController.prototype.events = function() {
      return _(InternalizationAgentParentController.__super__.events.call(this)).extend({
        "change .bv_conjugationType": "attributeChanged",
        "change .bv_conjugationSite": "attributeChanged"
      });
    };

    InternalizationAgentParentController.prototype.initialize = function() {
      if (this.model == null) {
        console.log("create new model in initialize");
        this.model = new InternalizationAgentParent();
      }
      this.errorOwnerName = 'InternalizationAgentParentController';
      InternalizationAgentParentController.__super__.initialize.call(this);
      this.setupConjugationType();
      this.setupConjugationSite();
      this.$('.bv_parentName').attr('placeholder', 'Autofilled');
      return this.$('.bv_parentName').attr('disabled', 'disabled');
    };

    InternalizationAgentParentController.prototype.render = function() {
      if (this.model == null) {
        this.model = new InternalizationAgentParent();
      }
      InternalizationAgentParentController.__super__.render.call(this);
      this.$('.bv_conjugationType').val(this.model.get('conjugation type').get('value'));
      this.$('.bv_conjugationSite').val(this.model.get('conjugation site').get('value'));
      console.log("render model");
      return console.log(this.model);
    };

    InternalizationAgentParentController.prototype.updateModel = function() {
      this.model.get("internalization agent name").set("labelText", UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_parentName')));
      this.model.get("conjugation type").set("value", this.conjugationTypeListController.getSelectedCode());
      this.model.get("conjugation site").set("value", this.conjugationSiteListController.getSelectedCode());
      return InternalizationAgentParentController.__super__.updateModel.call(this);
    };

    InternalizationAgentParentController.prototype.setupConjugationType = function() {
      console.log("setup type");
      this.conjugationTypeList = new PickListList();
      this.conjugationTypeList.url = "/api/dataDict/internalization agent/conjugation type";
      this.conjugationTypeListController = new PickListSelectController({
        el: this.$('.bv_conjugationType'),
        collection: this.conjugationTypeList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select Conjugation Type"
        }),
        selectedCode: this.model.get('conjugation type').get('value')
      });
      return console.log(this.model.get('conjugation type').get('value'));
    };

    InternalizationAgentParentController.prototype.setupConjugationSite = function() {
      console.log("setup site");
      this.conjugationSiteList = new PickListList();
      this.conjugationSiteList.url = "/api/dataDict/internalization agent/conjugation site";
      this.conjugationSiteListController = new PickListSelectController({
        el: this.$('.bv_conjugationSite'),
        collection: this.conjugationSiteList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select Conjugation Site"
        }),
        selectedCode: this.model.get('conjugation site').get('value')
      });
      return console.log(this.model.get('conjugation site').get('value'));
    };

    return InternalizationAgentParentController;

  })(AbstractBaseComponentParentController);

  window.InternalizationAgentBatchController = (function(_super) {
    __extends(InternalizationAgentBatchController, _super);

    function InternalizationAgentBatchController() {
      this.updateModel = __bind(this.updateModel, this);
      this.render = __bind(this.render, this);
      return InternalizationAgentBatchController.__super__.constructor.apply(this, arguments);
    }

    InternalizationAgentBatchController.prototype.additionalBatchAttributesTemplate = _.template($("#InternalizationAgentBatchView").html());

    InternalizationAgentBatchController.prototype.events = function() {
      return _(InternalizationAgentBatchController.__super__.events.call(this)).extend({
        "keyup .bv_molecularWeight": "attributeChanged",
        "keyup .bv_purity": "attributeChanged"
      });
    };

    InternalizationAgentBatchController.prototype.initialize = function() {
      if (this.model == null) {
        console.log("create new model in initialize");
        this.model = new InternalizationAgentBatch();
      }
      this.errorOwnerName = 'InternalizationAgentBatchController';
      return InternalizationAgentBatchController.__super__.initialize.call(this);
    };

    InternalizationAgentBatchController.prototype.render = function() {
      if (this.model == null) {
        console.log("create new model");
        this.model = new InternalizationAgentBatch();
      }
      InternalizationAgentBatchController.__super__.render.call(this);
      this.$('.bv_molecularWeight').val(this.model.get('molecular weight').get('value'));
      return this.$('.bv_purity').val(this.model.get('purity').get('value'));
    };

    InternalizationAgentBatchController.prototype.updateModel = function() {
      this.model.get("molecular weight").set("value", parseFloat(UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_molecularWeight'))));
      this.model.get("purity").set("value", parseFloat(UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_purity'))));
      return InternalizationAgentBatchController.__super__.updateModel.call(this);
    };

    return InternalizationAgentBatchController;

  })(AbstractBaseComponentBatchController);

  window.InternalizationAgentBatchSelectController = (function(_super) {
    __extends(InternalizationAgentBatchSelectController, _super);

    function InternalizationAgentBatchSelectController() {
      this.handleSelectedBatchChanged = __bind(this.handleSelectedBatchChanged, this);
      return InternalizationAgentBatchSelectController.__super__.constructor.apply(this, arguments);
    }

    InternalizationAgentBatchSelectController.prototype.setupBatchRegForm = function(batch) {
      var model;
      if (batch != null) {
        model = batch;
      } else {
        model = new InternalizationAgentBatch();
      }
      this.batchController = new InternalizationAgentBatchController({
        model: model,
        el: this.$('.bv_batchRegForm')
      });
      return InternalizationAgentBatchSelectController.__super__.setupBatchRegForm.call(this);
    };

    InternalizationAgentBatchSelectController.prototype.handleSelectedBatchChanged = function() {
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
            return this.batchController.model = new InternalizationAgentBatch();
          },
          success: (function(_this) {
            return function(json) {
              var pb;
              if (json.length === 0) {
                return alert('Could not get selected batch, creating new one');
              } else {
                pb = new InternalizationAgentBatch(json);
                pb.set(pb.parse(pb.attributes));
                return _this.setupBatchRegForm(pb);
              }
            };
          })(this)
        });
      }
    };

    return InternalizationAgentBatchSelectController;

  })(AbstractBaseComponentBatchSelectController);

  window.InternalizationAgentController = (function(_super) {
    __extends(InternalizationAgentController, _super);

    function InternalizationAgentController() {
      this.completeInitialization = __bind(this.completeInitialization, this);
      return InternalizationAgentController.__super__.constructor.apply(this, arguments);
    }

    InternalizationAgentController.prototype.moduleLaunchName = "internalization_agent";

    InternalizationAgentController.prototype.initialize = function() {
      if (this.model != null) {
        return this.completeInitialization();
      } else {
        if (window.AppLaunchParams.moduleLaunchParams != null) {
          if (window.AppLaunchParams.moduleLaunchParams.moduleName === this.moduleLaunchName) {
            return $.ajax({
              type: 'GET',
              url: "/api/internalizationAgentParents/codeName/" + window.AppLaunchParams.moduleLaunchParams.code,
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
                    cbp = new InternalizationAgentParent(json[0]);
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

    InternalizationAgentController.prototype.completeInitialization = function() {
      if (this.model == null) {
        this.model = new InternalizationAgentParent();
      }
      InternalizationAgentController.__super__.completeInitialization.call(this);
      return this.$('.bv_registrationTitle').html("InternalizationAgent Parent/Batch Registration");
    };

    InternalizationAgentController.prototype.setupParentController = function() {
      console.log("set up internalization agent parent controller");
      console.log(this.model);
      this.parentController = new InternalizationAgentParentController({
        model: this.model,
        el: this.$('.bv_parent')
      });
      return InternalizationAgentController.__super__.setupParentController.call(this);
    };

    InternalizationAgentController.prototype.setupBatchSelectController = function() {
      this.batchSelectController = new InternalizationAgentBatchSelectController({
        el: this.$('.bv_batch'),
        parentCodeName: this.model.get('codeName')
      });
      return InternalizationAgentController.__super__.setupBatchSelectController.call(this);
    };

    return InternalizationAgentController;

  })(AbstractBaseComponentController);

}).call(this);
