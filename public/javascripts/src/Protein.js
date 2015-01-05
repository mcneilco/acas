(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.ProteinParent = (function(_super) {
    __extends(ProteinParent, _super);

    function ProteinParent() {
      return ProteinParent.__super__.constructor.apply(this, arguments);
    }

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
          key: 'type',
          stateType: 'metadata',
          stateKind: 'protein parent',
          type: 'codeValue',
          kind: 'type'
        }, {
          key: 'aa sequence',
          stateType: 'metadata',
          stateKind: 'protein parent',
          type: 'stringValue',
          kind: 'aa sequence'
        }
      ]
    };

    ProteinParent.prototype.validate = function(attrs) {
      var aaSeq, bestName, cDate, errors, nameError, notebook, type;
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
      if (_.isNaN(attrs.recordedDate)) {
        errors.push({
          attribute: 'recordedDate',
          message: "Recorded date must be set"
        });
      }
      if (!this.isNew()) {
        if (attrs.recordedBy === "" || attrs.recordedBy === "unassigned") {
          errors.push({
            attribute: 'recordedBy',
            message: "Scientist must be set"
          });
        }
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
        notebook = attrs.notebook.get('value');
        if (notebook === "" || notebook === void 0) {
          errors.push({
            attribute: 'notebook',
            message: "Notebook must be set"
          });
        }
      }
      type = attrs.type.get('value');
      if (type === "unassigned" || type === "" || type === void 0) {
        errors.push({
          attribute: 'type',
          message: "Type must be set"
        });
      }
      aaSeq = attrs["aa sequence"].get('value');
      if (aaSeq === "" || aaSeq === void 0) {
        errors.push({
          attribute: 'sequence',
          message: "Protein aa sequence must be set"
        });
      }
      if (errors.length > 0) {
        return errors;
      } else {
        return null;
      }
    };

    return ProteinParent;

  })(AbstractBaseComponentParent);

  window.ProteinBatch = (function(_super) {
    __extends(ProteinBatch, _super);

    function ProteinBatch() {
      return ProteinBatch.__super__.constructor.apply(this, arguments);
    }

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
          key: 'amount',
          stateType: 'metadata',
          stateKind: 'inventory',
          type: 'numericValue',
          kind: 'amount',
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
        "change .bv_type": "attributeChanged",
        "change .bv_sequence": "attributeChanged"
      });
    };

    ProteinParentController.prototype.initialize = function() {
      if (this.model == null) {
        console.log("create new model in initialize");
        this.model = new ProteinParent();
      }
      this.errorOwnerName = 'ProteinParentController';
      ProteinParentController.__super__.initialize.call(this);
      return this.setupType();
    };

    ProteinParentController.prototype.render = function() {
      if (this.model == null) {
        this.model = new ProteinParent();
      }
      ProteinParentController.__super__.render.call(this);
      this.$('.bv_type').val(this.model.get('type').get('value'));
      this.$('.bv_sequence').val(this.model.get('aa sequence').get('value'));
      console.log("render model");
      return console.log(this.model);
    };

    ProteinParentController.prototype.updateModel = function() {
      this.model.get("protein name").set("labelText", UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_parentName')));
      this.model.get("type").set("value", this.typeListController.getSelectedCode());
      this.model.get("aa sequence").set("value", UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_sequence')));
      return ProteinParentController.__super__.updateModel.call(this);
    };

    ProteinParentController.prototype.setupType = function() {
      console.log("setup type");
      this.typeList = new PickListList();
      this.typeList.url = "/api/dataDict/protein/type";
      this.typeListController = new PickListSelectController({
        el: this.$('.bv_type'),
        collection: this.typeList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select type"
        }),
        selectedCode: this.model.get('type').get('value')
      });
      return console.log(this.model.get('type').get('value'));
    };

    return ProteinParentController;

  })(AbstractBaseComponentParentController);

  window.ProteinBatchController = (function(_super) {
    __extends(ProteinBatchController, _super);

    function ProteinBatchController() {
      this.render = __bind(this.render, this);
      return ProteinBatchController.__super__.constructor.apply(this, arguments);
    }

    ProteinBatchController.prototype.initialize = function() {
      if (this.model == null) {
        console.log("create new model in initialize");
        this.model = new ProteinBatch();
      }
      this.errorOwnerName = 'ProteinBatchController';
      return ProteinBatchController.__super__.initialize.call(this);
    };

    ProteinBatchController.prototype.render = function() {
      if (this.model == null) {
        console.log("create new model");
        this.model = new ProteinBatch();
      }
      return ProteinBatchController.__super__.render.call(this);
    };

    return ProteinBatchController;

  })(AbstractBaseComponentBatchController);

  window.ProteinBatchSelectController = (function(_super) {
    __extends(ProteinBatchSelectController, _super);

    function ProteinBatchSelectController() {
      this.handleSelectedBatchChanged = __bind(this.handleSelectedBatchChanged, this);
      return ProteinBatchSelectController.__super__.constructor.apply(this, arguments);
    }

    ProteinBatchSelectController.prototype.setupBatchRegForm = function(batch) {
      var model;
      if (batch != null) {
        model = batch;
      } else {
        model = new ProteinBatch();
      }
      this.batchController = new ProteinBatchController({
        model: model,
        el: this.$('.bv_batchRegForm')
      });
      return ProteinBatchSelectController.__super__.setupBatchRegForm.call(this);
    };

    ProteinBatchSelectController.prototype.handleSelectedBatchChanged = function() {
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
            return this.batchController.model = new ProteinBatch();
          },
          success: (function(_this) {
            return function(json) {
              var pb;
              if (json.length === 0) {
                return alert('Could not get selected batch, creating new one');
              } else {
                pb = new ProteinBatch(json);
                pb.set(pb.parse(pb.attributes));
                return _this.setupBatchRegForm(pb);
              }
            };
          })(this)
        });
      }
    };

    return ProteinBatchSelectController;

  })(AbstractBaseComponentBatchSelectController);

  window.ProteinController = (function(_super) {
    __extends(ProteinController, _super);

    function ProteinController() {
      this.completeInitialization = __bind(this.completeInitialization, this);
      return ProteinController.__super__.constructor.apply(this, arguments);
    }

    ProteinController.prototype.moduleLaunchName = "protein";

    ProteinController.prototype.initialize = function() {
      if (this.model != null) {
        return this.completeInitialization();
      } else {
        if (window.AppLaunchParams.moduleLaunchParams != null) {
          if (window.AppLaunchParams.moduleLaunchParams.moduleName === this.moduleLaunchName) {
            return $.ajax({
              type: 'GET',
              url: "/api/proteinParents/codeName/" + window.AppLaunchParams.moduleLaunchParams.code,
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
                    cbp = new ProteinParent(json[0]);
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

    ProteinController.prototype.completeInitialization = function() {
      if (this.model == null) {
        this.model = new ProteinParent();
      }
      ProteinController.__super__.completeInitialization.call(this);
      return this.$('.bv_registrationTitle').html("Protein Parent/Batch Registration");
    };

    ProteinController.prototype.setupParentController = function() {
      console.log("set up protein parent controller");
      console.log(this.model);
      this.parentController = new ProteinParentController({
        model: this.model,
        el: this.$('.bv_parent')
      });
      return ProteinController.__super__.setupParentController.call(this);
    };

    ProteinController.prototype.setupBatchSelectController = function() {
      this.batchSelectController = new ProteinBatchSelectController({
        el: this.$('.bv_batch'),
        parentCodeName: this.model.get('codeName')
      });
      return ProteinController.__super__.setupBatchSelectController.call(this);
    };

    return ProteinController;

  })(AbstractBaseComponentController);

}).call(this);
