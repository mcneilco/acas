(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.PrimaryAnalysisRead = (function(_super) {
    __extends(PrimaryAnalysisRead, _super);

    function PrimaryAnalysisRead() {
      this.triggerAmDirty = __bind(this.triggerAmDirty, this);
      this.validate = __bind(this.validate, this);
      return PrimaryAnalysisRead.__super__.constructor.apply(this, arguments);
    }

    PrimaryAnalysisRead.prototype.defaults = {
      readPosition: null,
      readName: "unassigned",
      activity: false
    };

    PrimaryAnalysisRead.prototype.validate = function(attrs) {
      var errors;
      errors = [];
      if (_.isNaN(attrs.readPosition) || attrs.readPosition === "" || attrs.readPosition === null) {
        errors.push({
          attribute: 'readPosition',
          message: "Read position must be a number"
        });
      }
      if (attrs.readName === "unassigned" || attrs.readName === "") {
        errors.push({
          attribute: 'readName',
          message: "Read name must be assigned"
        });
      }
      if (errors.length > 0) {
        return errors;
      } else {
        return null;
      }
    };

    PrimaryAnalysisRead.prototype.triggerAmDirty = function() {
      return this.trigger('amDirty', this);
    };

    return PrimaryAnalysisRead;

  })(Backbone.Model);

  window.TransformationRule = (function(_super) {
    __extends(TransformationRule, _super);

    function TransformationRule() {
      this.triggerAmDirty = __bind(this.triggerAmDirty, this);
      return TransformationRule.__super__.constructor.apply(this, arguments);
    }

    TransformationRule.prototype.defaults = {
      transformationRule: "unassigned"
    };

    TransformationRule.prototype.validate = function(attrs) {
      var errors;
      errors = [];
      if (attrs.transformationRule === "unassigned") {
        errors.push({
          attribute: 'transformationRule',
          message: "Transformation Rule must be assigned"
        });
      }
      if (errors.length > 0) {
        return errors;
      } else {
        return null;
      }
    };

    TransformationRule.prototype.triggerAmDirty = function() {
      return this.trigger('amDirty', this);
    };

    return TransformationRule;

  })(Backbone.Model);

  window.PrimaryAnalysisReadList = (function(_super) {
    __extends(PrimaryAnalysisReadList, _super);

    function PrimaryAnalysisReadList() {
      this.validateCollection = __bind(this.validateCollection, this);
      return PrimaryAnalysisReadList.__super__.constructor.apply(this, arguments);
    }

    PrimaryAnalysisReadList.prototype.model = PrimaryAnalysisRead;

    PrimaryAnalysisReadList.prototype.validateCollection = function(matchReadName) {
      var currentReadName, error, index, indivModelErrors, model, modelErrors, usedReadNames, _i, _j, _len, _ref;
      modelErrors = [];
      usedReadNames = {};
      if (this.length !== 0) {
        for (index = _i = 0, _ref = this.length - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; index = 0 <= _ref ? ++_i : --_i) {
          model = this.at(index);
          indivModelErrors = model.validate(model.attributes);
          if (indivModelErrors !== null) {
            for (_j = 0, _len = indivModelErrors.length; _j < _len; _j++) {
              error = indivModelErrors[_j];
              if (!(matchReadName && error.attribute === 'readPosition')) {
                modelErrors.push({
                  attribute: error.attribute + ':eq(' + index + ')',
                  message: error.message
                });
              }
            }
          }
          currentReadName = model.get('readName');
          if (currentReadName in usedReadNames) {
            modelErrors.push({
              attribute: 'readName:eq(' + index + ')',
              message: "Read name can not be chosen more than once"
            });
            modelErrors.push({
              attribute: 'readName:eq(' + usedReadNames[currentReadName] + ')',
              message: "Read name can not be chosen more than once"
            });
          } else {
            usedReadNames[currentReadName] = index;
          }
        }
      }
      return modelErrors;
    };

    return PrimaryAnalysisReadList;

  })(Backbone.Collection);

  window.TransformationRuleList = (function(_super) {
    __extends(TransformationRuleList, _super);

    function TransformationRuleList() {
      this.validateCollection = __bind(this.validateCollection, this);
      return TransformationRuleList.__super__.constructor.apply(this, arguments);
    }

    TransformationRuleList.prototype.model = TransformationRule;

    TransformationRuleList.prototype.validateCollection = function() {
      var currentRule, error, index, indivModelErrors, model, modelErrors, usedRules, _i, _j, _len, _ref;
      modelErrors = [];
      usedRules = {};
      if (this.length !== 0) {
        for (index = _i = 0, _ref = this.length - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; index = 0 <= _ref ? ++_i : --_i) {
          model = this.at(index);
          indivModelErrors = model.validate(model.attributes);
          if (indivModelErrors !== null) {
            for (_j = 0, _len = indivModelErrors.length; _j < _len; _j++) {
              error = indivModelErrors[_j];
              modelErrors.push({
                attribute: error.attribute + ':eq(' + index + ')',
                message: error.message
              });
            }
          }
          currentRule = model.get('transformationRule');
          if (currentRule in usedRules) {
            modelErrors.push({
              attribute: 'transformationRule:eq(' + index + ')',
              message: "Transformation Rules can not be chosen more than once"
            });
            modelErrors.push({
              attribute: 'transformationRule:eq(' + usedRules[currentRule] + ')',
              message: "Transformation Rules can not be chosen more than once"
            });
          } else {
            usedRules[currentRule] = index;
          }
        }
      }
      return modelErrors;
    };

    return TransformationRuleList;

  })(Backbone.Collection);

  window.PrimaryScreenAnalysisParameters = (function(_super) {
    __extends(PrimaryScreenAnalysisParameters, _super);

    function PrimaryScreenAnalysisParameters() {
      this.parse = __bind(this.parse, this);
      return PrimaryScreenAnalysisParameters.__super__.constructor.apply(this, arguments);
    }

    PrimaryScreenAnalysisParameters.prototype.defaults = function() {
      return {
        instrumentReader: "unassigned",
        signalDirectionRule: "unassigned",
        aggregateBy: "unassigned",
        aggregationMethod: "unassigned",
        normalizationRule: "unassigned",
        assayVolume: null,
        transferVolume: null,
        dilutionFactor: null,
        hitEfficacyThreshold: null,
        hitSDThreshold: null,
        positiveControl: new Backbone.Model(),
        negativeControl: new Backbone.Model(),
        vehicleControl: new Backbone.Model(),
        agonistControl: new Backbone.Model(),
        thresholdType: null,
        volumeType: "dilution",
        htsFormat: false,
        autoHitSelection: false,
        matchReadName: true,
        primaryAnalysisReadList: new PrimaryAnalysisReadList(),
        transformationRuleList: new TransformationRuleList()
      };
    };

    PrimaryScreenAnalysisParameters.prototype.initialize = function() {
      return this.set(this.parse(this.attributes));
    };

    PrimaryScreenAnalysisParameters.prototype.parse = function(resp) {
      if (resp.positiveControl != null) {
        if (!(resp.positiveControl instanceof Backbone.Model)) {
          resp.positiveControl = new Backbone.Model(resp.positiveControl);
        }
        resp.positiveControl.on('change', (function(_this) {
          return function() {
            return _this.trigger('change');
          };
        })(this));
      }
      if (resp.negativeControl != null) {
        if (!(resp.negativeControl instanceof Backbone.Model)) {
          resp.negativeControl = new Backbone.Model(resp.negativeControl);
        }
        resp.negativeControl.on('change', (function(_this) {
          return function() {
            return _this.trigger('change');
          };
        })(this));
      }
      if (resp.vehicleControl != null) {
        if (!(resp.vehicleControl instanceof Backbone.Model)) {
          resp.vehicleControl = new Backbone.Model(resp.vehicleControl);
        }
        resp.vehicleControl.on('change', (function(_this) {
          return function() {
            return _this.trigger('change');
          };
        })(this));
      }
      if (resp.agonistControl != null) {
        if (!(resp.agonistControl instanceof Backbone.Model)) {
          resp.agonistControl = new Backbone.Model(resp.agonistControl);
        }
        resp.agonistControl.on('change', (function(_this) {
          return function() {
            return _this.trigger('change');
          };
        })(this));
      }
      if (resp.primaryAnalysisReadList != null) {
        if (!(resp.primaryAnalysisReadList instanceof PrimaryAnalysisReadList)) {
          resp.primaryAnalysisReadList = new PrimaryAnalysisReadList(resp.primaryAnalysisReadList);
        }
        resp.primaryAnalysisReadList.on('change', (function(_this) {
          return function() {
            return _this.trigger('change');
          };
        })(this));
        resp.primaryAnalysisReadList.on('amDirty', (function(_this) {
          return function() {
            return _this.trigger('amDirty');
          };
        })(this));
      }
      if (resp.transformationRuleList != null) {
        if (!(resp.transformationRuleList instanceof TransformationRuleList)) {
          resp.transformationRuleList = new TransformationRuleList(resp.transformationRuleList);
        }
        resp.transformationRuleList.on('change', (function(_this) {
          return function() {
            return _this.trigger('change');
          };
        })(this));
        resp.transformationRuleList.on('amDirty', (function(_this) {
          return function() {
            return _this.trigger('amDirty');
          };
        })(this));
      }
      return resp;
    };

    PrimaryScreenAnalysisParameters.prototype.validate = function(attrs) {
      var agonistControl, agonistControlConc, errors, negativeControl, negativeControlConc, positiveControl, positiveControlConc, readErrors, transformationErrors;
      errors = [];
      readErrors = this.get('primaryAnalysisReadList').validateCollection(attrs.matchReadName);
      errors.push.apply(errors, readErrors);
      transformationErrors = this.get('transformationRuleList').validateCollection();
      errors.push.apply(errors, transformationErrors);
      positiveControl = this.get('positiveControl').get('batchCode');
      if (positiveControl === "" || positiveControl === void 0) {
        errors.push({
          attribute: 'positiveControlBatch',
          message: "Positive control batch muct be set"
        });
      }
      positiveControlConc = this.get('positiveControl').get('concentration');
      if (_.isNaN(positiveControlConc) || positiveControlConc === void 0 || positiveControlConc === null || positiveControlConc === "") {
        errors.push({
          attribute: 'positiveControlConc',
          message: "Positive control conc must be set"
        });
      }
      negativeControl = this.get('negativeControl').get('batchCode');
      if (negativeControl === "" || negativeControl === void 0) {
        errors.push({
          attribute: 'negativeControlBatch',
          message: "Negative control batch must be set"
        });
      }
      negativeControlConc = this.get('negativeControl').get('concentration');
      if (_.isNaN(negativeControlConc) || negativeControlConc === void 0 || negativeControlConc === null || negativeControlConc === "") {
        errors.push({
          attribute: 'negativeControlConc',
          message: "Negative control conc must be set"
        });
      }
      agonistControl = this.get('agonistControl').get('batchCode');
      agonistControlConc = this.get('agonistControl').get('concentration');
      if ((agonistControl !== "" && agonistControl !== void 0) || (agonistControlConc !== "" && agonistControlConc !== void 0)) {
        if (agonistControl === "" || agonistControl === void 0 || agonistControl === null) {
          errors.push({
            attribute: 'agonistControlBatch',
            message: "Agonist control batch must be set"
          });
        }
        if (_.isNaN(agonistControlConc) || agonistControlConc === void 0 || agonistControlConc === "" || agonistControlConc === null) {
          errors.push({
            attribute: 'agonistControlConc',
            message: "Agonist control conc must be set"
          });
        }
      }
      if (attrs.signalDirectionRule === "unassigned" || attrs.signalDirectionRule === "") {
        errors.push({
          attribute: 'signalDirectionRule',
          message: "Signal Direction Rule must be assigned"
        });
      }
      if ((attrs.aggregateBy === "unassigned" || attrs.aggregateBy === "") && (attrs.aggregationMethod === "unassigned" || attrs.aggregationMethod === "")) {
        errors.push({
          attribute: 'aggregateByGroup',
          message: "Aggregate By and Aggregation Method must be assigned"
        });
      } else {
        if (attrs.aggregateBy === "unassigned" || attrs.aggregateBy === "") {
          errors.push({
            attribute: 'aggregateByGroup',
            message: "Aggregate By must be assigned"
          });
        }
        if (attrs.aggregationMethod === "unassigned" || attrs.aggregationMethod === "") {
          errors.push({
            attribute: 'aggregateByGroup',
            message: "Aggregation method must be assigned"
          });
        }
      }
      if (attrs.normalizationRule === "unassigned" || attrs.normalizationRule === "") {
        errors.push({
          attribute: 'normalizationRule',
          message: "Normalization rule must be assigned"
        });
      }
      if (attrs.autoHitSelection) {
        if (attrs.thresholdType === "sd" && _.isNaN(attrs.hitSDThreshold)) {
          errors.push({
            attribute: 'hitSDThreshold',
            message: "SD threshold must be assigned"
          });
        }
        if (attrs.thresholdType === "efficacy" && _.isNaN(attrs.hitEfficacyThreshold)) {
          errors.push({
            attribute: 'hitEfficacyThreshold',
            message: "Efficacy threshold must be assigned"
          });
        }
      }
      if (_.isNaN(attrs.assayVolume)) {
        errors.push({
          attribute: 'assayVolume',
          message: "Assay volume must be assigned"
        });
      }
      if ((attrs.assayVolume === "" || attrs.assayVolume === null) && (attrs.transferVolume !== "" && attrs.transferVolume !== null)) {
        errors.push({
          attribute: 'assayVolume',
          message: "Assay volume must be assigned"
        });
      }
      if (attrs.volumeType === "dilution" && _.isNaN(attrs.dilutionFactor)) {
        errors.push({
          attribute: 'dilutionFactor',
          message: "Dilution factor must be a number"
        });
      }
      if (attrs.volumeType === "transfer" && _.isNaN(attrs.transferVolume)) {
        errors.push({
          attribute: 'transferVolume',
          message: "Transfer volume must be assigned"
        });
      }
      if (errors.length > 0) {
        return errors;
      } else {
        return null;
      }
    };

    PrimaryScreenAnalysisParameters.prototype.autocalculateVolumes = function() {
      var assayVolume, dilutionFactor, transferVolume;
      dilutionFactor = this.get('dilutionFactor');
      transferVolume = this.get('transferVolume');
      assayVolume = this.get('assayVolume');
      if (this.get('volumeType') === 'dilution') {
        if (isNaN(dilutionFactor) || dilutionFactor === "" || dilutionFactor === 0 || isNaN(assayVolume) || assayVolume === "") {
          transferVolume = "";
        } else {
          transferVolume = assayVolume / dilutionFactor;
        }
        this.set({
          transferVolume: transferVolume
        });
        return transferVolume;
      } else {
        if (isNaN(transferVolume) || transferVolume === "" || transferVolume === 0 || isNaN(assayVolume) || assayVolume === "") {
          dilutionFactor = "";
        } else {
          dilutionFactor = assayVolume / transferVolume;
        }
        this.set({
          dilutionFactor: dilutionFactor
        });
        return dilutionFactor;
      }
    };

    return PrimaryScreenAnalysisParameters;

  })(Backbone.Model);

  window.PrimaryScreenExperiment = (function(_super) {
    __extends(PrimaryScreenExperiment, _super);

    function PrimaryScreenExperiment() {
      return PrimaryScreenExperiment.__super__.constructor.apply(this, arguments);
    }

    PrimaryScreenExperiment.prototype.initialize = function() {
      PrimaryScreenExperiment.__super__.initialize.call(this);
      return this.set({
        lsKind: "flipr screening assay"
      });
    };

    PrimaryScreenExperiment.prototype.getDryRunStatus = function() {
      var status;
      status = this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "experiment metadata", "codeValue", "dry run status");
      if (!status.has('codeValue')) {
        status.set({
          codeValue: "not started"
        });
        status.set({
          codeType: "dry run"
        });
        status.set({
          codeKind: "status"
        });
        status.set({
          codeOrigin: "acas ddict"
        });
      }
      return status;
    };

    PrimaryScreenExperiment.prototype.getDryRunResultHTML = function() {
      var result;
      result = this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "experiment metadata", "clobValue", "dry run result html");
      if (!result.has('clobValue')) {
        result.set({
          clobValue: ""
        });
      }
      return result;
    };

    PrimaryScreenExperiment.prototype.getAnalysisStatus = function() {
      var status;
      status = this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "experiment metadata", "codeValue", "analysis status");
      if (!status.has('codeValue')) {
        status.set({
          codeValue: "not started"
        });
      }
      return status;
    };

    PrimaryScreenExperiment.prototype.getAnalysisResultHTML = function() {
      var result;
      result = this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "experiment metadata", "clobValue", "analysis result html");
      if (!result.has('clobValue')) {
        result.set({
          clobValue: ""
        });
      }
      return result;
    };

    PrimaryScreenExperiment.prototype.getModelFitStatus = function() {
      var status;
      status = this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "experiment metadata", "codeValue", "model fit status");
      if (!status.has('codeValue')) {
        status.set({
          codeValue: "not started"
        });
      }
      return status;
    };

    PrimaryScreenExperiment.prototype.getModelFitResultHTML = function() {
      var result;
      result = this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "experiment metadata", "clobValue", "model fit result html");
      if (!result.has('clobValue')) {
        result.set({
          clobValue: ""
        });
      }
      return result;
    };

    return PrimaryScreenExperiment;

  })(Experiment);

  window.PrimaryAnalysisReadController = (function(_super) {
    __extends(PrimaryAnalysisReadController, _super);

    function PrimaryAnalysisReadController() {
      this.clear = __bind(this.clear, this);
      this.updateModel = __bind(this.updateModel, this);
      this.render = __bind(this.render, this);
      return PrimaryAnalysisReadController.__super__.constructor.apply(this, arguments);
    }

    PrimaryAnalysisReadController.prototype.template = _.template($("#PrimaryAnalysisReadView").html());

    PrimaryAnalysisReadController.prototype.tagName = "div";

    PrimaryAnalysisReadController.prototype.className = "form-inline";

    PrimaryAnalysisReadController.prototype.events = {
      "change .bv_readPosition": "attributeChanged",
      "change .bv_readName": "attributeChanged",
      "click .bv_activity": "attributeChanged",
      "click .bv_delete": "clear"
    };

    PrimaryAnalysisReadController.prototype.initialize = function() {
      this.errorOwnerName = 'PrimaryAnalysisReadController';
      this.setBindings();
      return this.model.on("destroy", this.remove, this);
    };

    PrimaryAnalysisReadController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template(this.model.attributes));
      this.setUpReadNameSelect();
      return this;
    };

    PrimaryAnalysisReadController.prototype.setUpReadNameSelect = function() {
      this.readNameList = new PickListList();
      this.readNameList.url = "/api/codetables/reader data/read name";
      return this.readNameListController = new PickListSelectController({
        el: this.$('.bv_readName'),
        collection: this.readNameList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select Read Name"
        }),
        selectedCode: this.model.get('readName')
      });
    };

    PrimaryAnalysisReadController.prototype.setUpReadPosition = function(matchReadNameChecked) {
      if (matchReadNameChecked) {
        return this.$('.bv_readPosition').attr('disabled', 'disabled');
      } else {
        return this.$('.bv_readPosition').removeAttr('disabled');
      }
    };

    PrimaryAnalysisReadController.prototype.updateModel = function() {
      var activity;
      activity = this.$('.bv_activity').is(":checked");
      this.model.set({
        readPosition: parseInt(UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_readPosition'))),
        readName: this.readNameListController.getSelectedCode(),
        activity: activity
      });
      this.model.triggerAmDirty();
      return this.trigger('updateState');
    };

    PrimaryAnalysisReadController.prototype.clear = function() {
      this.model.destroy();
      return this.model.triggerAmDirty();
    };

    return PrimaryAnalysisReadController;

  })(AbstractFormController);

  window.TransformationRuleController = (function(_super) {
    __extends(TransformationRuleController, _super);

    function TransformationRuleController() {
      this.clear = __bind(this.clear, this);
      this.updateModel = __bind(this.updateModel, this);
      this.render = __bind(this.render, this);
      return TransformationRuleController.__super__.constructor.apply(this, arguments);
    }

    TransformationRuleController.prototype.template = _.template($("#TransformationRuleView").html());

    TransformationRuleController.prototype.events = {
      "change .bv_transformationRule": "attributeChanged",
      "click .bv_deleteRule": "clear"
    };

    TransformationRuleController.prototype.initialize = function() {
      this.errorOwnerName = 'TransformationRuleController';
      this.setBindings();
      return this.model.on("destroy", this.remove, this);
    };

    TransformationRuleController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template(this.model.attributes));
      this.setUpTransformationRuleSelect();
      return this;
    };

    TransformationRuleController.prototype.updateModel = function() {
      this.model.set({
        transformationRule: this.transformationListController.getSelectedCode()
      });
      this.model.triggerAmDirty();
      return this.trigger('updateState');
    };

    TransformationRuleController.prototype.setUpTransformationRuleSelect = function() {
      this.transformationList = new PickListList();
      this.transformationList.url = "/api/codetables/analysis parameter/transformation";
      return this.transformationListController = new PickListSelectController({
        el: this.$('.bv_transformationRule'),
        collection: this.transformationList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select Transformation Rule"
        }),
        selectedCode: this.model.get('transformationRule')
      });
    };

    TransformationRuleController.prototype.clear = function() {
      return this.model.destroy();
    };

    return TransformationRuleController;

  })(AbstractFormController);

  window.PrimaryAnalysisReadListController = (function(_super) {
    __extends(PrimaryAnalysisReadListController, _super);

    function PrimaryAnalysisReadListController() {
      this.checkActivity = __bind(this.checkActivity, this);
      this.matchReadNameChanged = __bind(this.matchReadNameChanged, this);
      this.addNewRead = __bind(this.addNewRead, this);
      this.render = __bind(this.render, this);
      this.initialize = __bind(this.initialize, this);
      return PrimaryAnalysisReadListController.__super__.constructor.apply(this, arguments);
    }

    PrimaryAnalysisReadListController.prototype.template = _.template($("#PrimaryAnalysisReadListView").html());

    PrimaryAnalysisReadListController.prototype.matchReadNameChecked = true;

    PrimaryAnalysisReadListController.prototype.events = {
      "click .bv_addReadButton": "addNewRead"
    };

    PrimaryAnalysisReadListController.prototype.initialize = function() {
      this.collection.on('remove', this.checkActivity);
      return this.collection.on('remove', (function(_this) {
        return function() {
          return _this.collection.trigger('change');
        };
      })(this));
    };

    PrimaryAnalysisReadListController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      this.collection.each((function(_this) {
        return function(read) {
          return _this.addOneRead(read);
        };
      })(this));
      if (this.collection.length === 0) {
        this.addNewRead(true);
      }
      this.checkActivity();
      return this;
    };

    PrimaryAnalysisReadListController.prototype.addNewRead = function(skipAmDirtyTrigger) {
      var newModel;
      newModel = new PrimaryAnalysisRead();
      this.collection.add(newModel);
      this.addOneRead(newModel);
      if (this.collection.length === 1) {
        this.checkActivity();
      }
      if (skipAmDirtyTrigger !== true) {
        return newModel.triggerAmDirty();
      }
    };

    PrimaryAnalysisReadListController.prototype.addOneRead = function(read) {
      var parc;
      parc = new PrimaryAnalysisReadController({
        model: read
      });
      this.$('.bv_readInfo').append(parc.render().el);
      parc.setUpReadPosition(this.matchReadNameChecked);
      return parc.on('updateState', (function(_this) {
        return function() {
          return _this.trigger('updateState');
        };
      })(this));
    };

    PrimaryAnalysisReadListController.prototype.matchReadNameChanged = function(matchReadName) {
      this.matchReadNameChecked = matchReadName;
      if (this.matchReadNameChecked) {
        this.$('.bv_readPosition').val('');
        this.$('.bv_readPosition').attr('disabled', 'disabled');
        return this.collection.each((function(_this) {
          return function(read) {
            return read.set({
              readPosition: ''
            });
          };
        })(this));
      } else {
        return this.$('.bv_readPosition').removeAttr('disabled');
      }
    };

    PrimaryAnalysisReadListController.prototype.checkActivity = function() {
      var activitySet, index, _results;
      index = this.collection.length - 1;
      activitySet = false;
      _results = [];
      while (index >= 0 && activitySet === false) {
        if (this.collection.at(index).get('activity') === true) {
          activitySet = true;
        }
        if (index === 0) {
          this.$('.bv_activity:eq(0)').attr('checked', 'checked');
          this.collection.at(index).set({
            activity: true
          });
        }
        _results.push(index = index - 1);
      }
      return _results;
    };

    return PrimaryAnalysisReadListController;

  })(AbstractFormController);

  window.TransformationRuleListController = (function(_super) {
    __extends(TransformationRuleListController, _super);

    function TransformationRuleListController() {
      this.checkNumberOfRules = __bind(this.checkNumberOfRules, this);
      this.addNewRule = __bind(this.addNewRule, this);
      this.render = __bind(this.render, this);
      this.initialize = __bind(this.initialize, this);
      return TransformationRuleListController.__super__.constructor.apply(this, arguments);
    }

    TransformationRuleListController.prototype.template = _.template($("#TransformationRuleListView").html());

    TransformationRuleListController.prototype.events = {
      "click .bv_addTransformationButton": "addNewRule"
    };

    TransformationRuleListController.prototype.initialize = function() {
      this.collection.on('remove', this.checkNumberOfRules);
      this.collection.on('remove', (function(_this) {
        return function() {
          return _this.collection.trigger('amDirty');
        };
      })(this));
      return this.collection.on('remove', (function(_this) {
        return function() {
          return _this.collection.trigger('change');
        };
      })(this));
    };

    TransformationRuleListController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      this.collection.each((function(_this) {
        return function(rule) {
          return _this.addOneRule(rule);
        };
      })(this));
      if (this.collection.length === 0) {
        this.addNewRule(true);
      }
      return this;
    };

    TransformationRuleListController.prototype.addNewRule = function(skipAmDirtyTrigger) {
      var newModel;
      newModel = new TransformationRule();
      this.collection.add(newModel);
      this.addOneRule(newModel);
      if (skipAmDirtyTrigger !== true) {
        return newModel.triggerAmDirty();
      }
    };

    TransformationRuleListController.prototype.addOneRule = function(rule) {
      var trc;
      trc = new TransformationRuleController({
        model: rule
      });
      this.$('.bv_transformationInfo').append(trc.render().el);
      return trc.on('updateState', (function(_this) {
        return function() {
          return _this.trigger('updateState');
        };
      })(this));
    };

    TransformationRuleListController.prototype.checkNumberOfRules = function() {
      if (this.collection.length === 0) {
        return this.addNewRule();
      }
    };

    return TransformationRuleListController;

  })(AbstractFormController);

  window.PrimaryScreenAnalysisParametersController = (function(_super) {
    __extends(PrimaryScreenAnalysisParametersController, _super);

    function PrimaryScreenAnalysisParametersController() {
      this.handleMatchReadNameChanged = __bind(this.handleMatchReadNameChanged, this);
      this.handleVolumeTypeChanged = __bind(this.handleVolumeTypeChanged, this);
      this.handleAutoHitSelectionChanged = __bind(this.handleAutoHitSelectionChanged, this);
      this.handleThresholdTypeChanged = __bind(this.handleThresholdTypeChanged, this);
      this.handleDilutionFactorChanged = __bind(this.handleDilutionFactorChanged, this);
      this.handleTransferVolumeChanged = __bind(this.handleTransferVolumeChanged, this);
      this.handleAssayVolumeChanged = __bind(this.handleAssayVolumeChanged, this);
      this.updateModel = __bind(this.updateModel, this);
      this.render = __bind(this.render, this);
      return PrimaryScreenAnalysisParametersController.__super__.constructor.apply(this, arguments);
    }

    PrimaryScreenAnalysisParametersController.prototype.template = _.template($("#PrimaryScreenAnalysisParametersView").html());

    PrimaryScreenAnalysisParametersController.prototype.autofillTemplate = _.template($("#PrimaryScreenAnalysisParametersAutofillView").html());

    PrimaryScreenAnalysisParametersController.prototype.events = {
      "change .bv_instrumentReader": "attributeChanged",
      "change .bv_signalDirectionRule": "attributeChanged",
      "change .bv_aggregateBy": "attributeChanged",
      "change .bv_aggregationMethod": "attributeChanged",
      "change .bv_normalizationRule": "attributeChanged",
      "change .bv_assayVolume": "handleAssayVolumeChanged",
      "change .bv_dilutionFactor": "handleDilutionFactorChanged",
      "change .bv_transferVolume": "handleTransferVolumeChanged",
      "change .bv_hitEfficacyThreshold": "attributeChanged",
      "change .bv_hitSDThreshold": "attributeChanged",
      "change .bv_positiveControlBatch": "attributeChanged",
      "change .bv_positiveControlConc": "attributeChanged",
      "change .bv_negativeControlBatch": "attributeChanged",
      "change .bv_negativeControlConc": "attributeChanged",
      "change .bv_vehicleControlBatch": "attributeChanged",
      "change .bv_agonistControlBatch": "attributeChanged",
      "change .bv_agonistControlConc": "attributeChanged",
      "change .bv_thresholdTypeEfficacy": "handleThresholdTypeChanged",
      "change .bv_thresholdTypeSD": "handleThresholdTypeChanged",
      "change .bv_volumeTypeTransfer": "handleVolumeTypeChanged",
      "change .bv_volumeTypeDilution": "handleVolumeTypeChanged",
      "change .bv_autoHitSelection": "handleAutoHitSelectionChanged",
      "change .bv_htsFormat": "attributeChanged",
      "click .bv_matchReadName": "handleMatchReadNameChanged"
    };

    PrimaryScreenAnalysisParametersController.prototype.initialize = function() {
      this.errorOwnerName = 'PrimaryScreenAnalysisParametersController';
      PrimaryScreenAnalysisParametersController.__super__.initialize.call(this);
      this.model.bind('amDirty', (function(_this) {
        return function() {
          return _this.trigger('amDirty', _this);
        };
      })(this));
      this.setupInstrumentReaderSelect();
      this.setupSignalDirectionSelect();
      this.setupAggregateBySelect();
      this.setupAggregationMethodSelect();
      return this.setupNormalizationSelect();
    };

    PrimaryScreenAnalysisParametersController.prototype.render = function() {
      this.$('.bv_autofillSection').empty();
      this.$('.bv_autofillSection').html(this.autofillTemplate(this.model.attributes));
      this.setupInstrumentReaderSelect();
      this.setupSignalDirectionSelect();
      this.setupAggregateBySelect();
      this.setupAggregationMethodSelect();
      this.setupNormalizationSelect();
      this.handleAutoHitSelectionChanged(true);
      this.setupReadListController();
      this.setupTransformationRuleListController();
      this.handleMatchReadNameChanged(true);
      return this;
    };

    PrimaryScreenAnalysisParametersController.prototype.setupInstrumentReaderSelect = function() {
      this.instrumentList = new PickListList();
      this.instrumentList.url = "/api/codetables/equipment/instrument reader";
      return this.instrumentListController = new PickListSelectController({
        el: this.$('.bv_instrumentReader'),
        collection: this.instrumentList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select Instrument"
        }),
        selectedCode: this.model.get('instrumentReader')
      });
    };

    PrimaryScreenAnalysisParametersController.prototype.setupSignalDirectionSelect = function() {
      this.signalDirectionList = new PickListList();
      this.signalDirectionList.url = "/api/codetables/analysis parameter/signal direction";
      return this.signalDirectionListController = new PickListSelectController({
        el: this.$('.bv_signalDirectionRule'),
        collection: this.signalDirectionList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select Signal Direction"
        }),
        selectedCode: this.model.get('signalDirectionRule')
      });
    };

    PrimaryScreenAnalysisParametersController.prototype.setupAggregateBySelect = function() {
      this.aggregateByList = new PickListList();
      this.aggregateByList.url = "/api/codetables/analysis parameter/aggregate by";
      return this.aggregateByListController = new PickListSelectController({
        el: this.$('.bv_aggregateBy'),
        collection: this.aggregateByList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select"
        }),
        selectedCode: this.model.get('aggregateBy')
      });
    };

    PrimaryScreenAnalysisParametersController.prototype.setupAggregationMethodSelect = function() {
      this.aggregationMethodList = new PickListList();
      this.aggregationMethodList.url = "/api/codetables/analysis parameter/aggregation method";
      return this.aggregationMethodListController = new PickListSelectController({
        el: this.$('.bv_aggregationMethod'),
        collection: this.aggregationMethodList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select"
        }),
        selectedCode: this.model.get('aggregationMethod')
      });
    };

    PrimaryScreenAnalysisParametersController.prototype.setupNormalizationSelect = function() {
      this.normalizationList = new PickListList();
      this.normalizationList.url = "/api/codetables/analysis parameter/normalization method";
      return this.normalizationListController = new PickListSelectController({
        el: this.$('.bv_normalizationRule'),
        collection: this.normalizationList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select Rule"
        }),
        selectedCode: this.model.get('normalizationRule')
      });
    };

    PrimaryScreenAnalysisParametersController.prototype.setupReadListController = function() {
      this.readListController = new PrimaryAnalysisReadListController({
        el: this.$('.bv_readList'),
        collection: this.model.get('primaryAnalysisReadList')
      });
      this.readListController.render();
      return this.readListController.on('updateState', (function(_this) {
        return function() {
          return _this.trigger('updateState');
        };
      })(this));
    };

    PrimaryScreenAnalysisParametersController.prototype.setupTransformationRuleListController = function() {
      this.transformationRuleListController = new TransformationRuleListController({
        el: this.$('.bv_transformationList'),
        collection: this.model.get('transformationRuleList')
      });
      this.transformationRuleListController.render();
      return this.transformationRuleListController.on('updateState', (function(_this) {
        return function() {
          return _this.trigger('updateState');
        };
      })(this));
    };

    PrimaryScreenAnalysisParametersController.prototype.updateModel = function() {
      var htsFormat;
      htsFormat = this.$('.bv_htsFormat').is(":checked");
      this.model.set({
        instrumentReader: this.instrumentListController.getSelectedCode(),
        signalDirectionRule: this.signalDirectionListController.getSelectedCode(),
        aggregateBy: this.aggregateByListController.getSelectedCode(),
        aggregationMethod: this.aggregationMethodListController.getSelectedCode(),
        normalizationRule: this.normalizationListController.getSelectedCode(),
        hitEfficacyThreshold: parseFloat(UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_hitEfficacyThreshold'))),
        hitSDThreshold: parseFloat(UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_hitSDThreshold'))),
        assayVolume: UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_assayVolume')),
        transferVolume: UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_transferVolume')),
        dilutionFactor: UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_dilutionFactor')),
        htsFormat: htsFormat
      });
      if (this.model.get('assayVolume') !== "") {
        this.model.set({
          assayVolume: parseFloat(UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_assayVolume')))
        });
      }
      if (this.model.get('transferVolume') !== "") {
        this.model.set({
          transferVolume: parseFloat(UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_transferVolume')))
        });
      }
      if (this.model.get('dilutionFactor') !== "") {
        this.model.set({
          dilutionFactor: parseFloat(UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_dilutionFactor')))
        });
      }
      this.model.get('positiveControl').set({
        batchCode: UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_positiveControlBatch')),
        concentration: parseFloat(UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_positiveControlConc')))
      });
      this.model.get('negativeControl').set({
        batchCode: UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_negativeControlBatch')),
        concentration: parseFloat(UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_negativeControlConc')))
      });
      this.model.get('vehicleControl').set({
        batchCode: UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_vehicleControlBatch')),
        concentration: null
      });
      this.model.get('agonistControl').set({
        batchCode: UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_agonistControlBatch')),
        concentration: UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_agonistControlConc'))
      });
      if (this.model.get('agonistControl').get('concentration') !== "") {
        this.model.get('agonistControl').set({
          concentration: parseFloat(UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_agonistControlConc')))
        });
      }
      return this.trigger('updateState');
    };

    PrimaryScreenAnalysisParametersController.prototype.handleAssayVolumeChanged = function() {
      var volumeType;
      this.attributeChanged();
      volumeType = this.$("input[name='bv_volumeType']:checked").val();
      if (volumeType === "dilution") {
        return this.handleDilutionFactorChanged();
      } else {
        return this.handleTransferVolumeChanged();
      }
    };

    PrimaryScreenAnalysisParametersController.prototype.handleTransferVolumeChanged = function() {
      var dilutionFactor;
      this.attributeChanged();
      dilutionFactor = this.model.autocalculateVolumes();
      return this.$('.bv_dilutionFactor').val(dilutionFactor);
    };

    PrimaryScreenAnalysisParametersController.prototype.handleDilutionFactorChanged = function() {
      var transferVolume;
      this.attributeChanged();
      transferVolume = this.model.autocalculateVolumes();
      this.$('.bv_transferVolume').val(transferVolume);
      if (transferVolume === "" || transferVolume === null) {
        return this.$('.bv_dilutionFactor').val(this.model.get('dilutionFactor'));
      }
    };

    PrimaryScreenAnalysisParametersController.prototype.handleThresholdTypeChanged = function() {
      var thresholdType;
      thresholdType = this.$("input[name='bv_thresholdType']:checked").val();
      this.model.set({
        thresholdType: thresholdType
      });
      if (thresholdType === "efficacy") {
        this.$('.bv_hitSDThreshold').attr('disabled', 'disabled');
        this.$('.bv_hitEfficacyThreshold').removeAttr('disabled');
      } else {
        this.$('.bv_hitEfficacyThreshold').attr('disabled', 'disabled');
        this.$('.bv_hitSDThreshold').removeAttr('disabled');
      }
      return this.attributeChanged();
    };

    PrimaryScreenAnalysisParametersController.prototype.handleAutoHitSelectionChanged = function(skipUpdate) {
      var autoHitSelection;
      autoHitSelection = this.$('.bv_autoHitSelection').is(":checked");
      this.model.set({
        autoHitSelection: autoHitSelection
      });
      if (autoHitSelection) {
        this.$('.bv_thresholdControls').show();
      } else {
        this.$('.bv_thresholdControls').hide();
      }
      if (skipUpdate !== true) {
        return this.attributeChanged();
      }
    };

    PrimaryScreenAnalysisParametersController.prototype.handleVolumeTypeChanged = function() {
      var volumeType;
      volumeType = this.$("input[name='bv_volumeType']:checked").val();
      this.model.set({
        volumeType: volumeType
      });
      if (volumeType === "transfer") {
        this.$('.bv_dilutionFactor').attr('disabled', 'disabled');
        this.$('.bv_transferVolume').removeAttr('disabled');
      } else {
        this.$('.bv_transferVolume').attr('disabled', 'disabled');
        this.$('.bv_dilutionFactor').removeAttr('disabled');
      }
      if (this.model.get('transferVolume') === "" || this.model.get('assayVolume') === "") {
        this.handleDilutionFactorChanged();
      }
      return this.attributeChanged();
    };

    PrimaryScreenAnalysisParametersController.prototype.handleMatchReadNameChanged = function(skipUpdate) {
      var matchReadName;
      matchReadName = this.$('.bv_matchReadName').is(":checked");
      this.model.set({
        matchReadName: matchReadName
      });
      this.readListController.matchReadNameChanged(matchReadName);
      if (skipUpdate !== true) {
        return this.attributeChanged();
      }
    };

    return PrimaryScreenAnalysisParametersController;

  })(AbstractParserFormController);

  window.AbstractUploadAndRunPrimaryAnalsysisController = (function(_super) {
    __extends(AbstractUploadAndRunPrimaryAnalsysisController, _super);

    function AbstractUploadAndRunPrimaryAnalsysisController() {
      this.validateParseFile = __bind(this.validateParseFile, this);
      this.loadAnother = __bind(this.loadAnother, this);
      this.backToUpload = __bind(this.backToUpload, this);
      this.handleSaveReturnSuccess = __bind(this.handleSaveReturnSuccess, this);
      this.handleValidationReturnSuccess = __bind(this.handleValidationReturnSuccess, this);
      this.handleMSFormInvalid = __bind(this.handleMSFormInvalid, this);
      this.handleMSFormValid = __bind(this.handleMSFormValid, this);
      return AbstractUploadAndRunPrimaryAnalsysisController.__super__.constructor.apply(this, arguments);
    }

    AbstractUploadAndRunPrimaryAnalsysisController.prototype.initialize = function() {
      this.allowedFileTypes = ['zip'];
      this.loadReportFile = true;
      AbstractUploadAndRunPrimaryAnalsysisController.__super__.initialize.call(this);
      this.$('.bv_reportFileDirections').html('To upload an <b>optional well flagging file</b>, click the "Browse Files…" button and select a file.');
      return this.$('.bv_attachReportCheckboxText').html('Attach optional well flagging file');
    };

    AbstractUploadAndRunPrimaryAnalsysisController.prototype.completeInitialization = function() {
      this.analysisParameterController.on('valid', this.handleMSFormValid);
      this.analysisParameterController.on('invalid', this.handleMSFormInvalid);
      this.analysisParameterController.on('notifyError', this.notificationController.addNotification);
      this.analysisParameterController.on('clearErrors', this.notificationController.clearAllNotificiations);
      this.analysisParameterController.on('amDirty', (function(_this) {
        return function() {
          return _this.trigger('amDirty');
        };
      })(this));
      this.analyzedPreviously = this.options.analyzedPreviously;
      this.analysisParameterController.render();
      if (this.analyzedPreviously) {
        this.$('.bv_loadAnother').html("Re-Analyze");
      }
      return this.handleMSFormInvalid();
    };

    AbstractUploadAndRunPrimaryAnalsysisController.prototype.handleMSFormValid = function() {
      if (this.parseFileUploaded) {
        return this.handleFormValid();
      }
    };

    AbstractUploadAndRunPrimaryAnalsysisController.prototype.handleMSFormInvalid = function() {
      return this.handleFormInvalid();
    };

    AbstractUploadAndRunPrimaryAnalsysisController.prototype.handleFormValid = function() {
      if (this.analysisParameterController.isValid()) {
        return AbstractUploadAndRunPrimaryAnalsysisController.__super__.handleFormValid.call(this);
      }
    };

    AbstractUploadAndRunPrimaryAnalsysisController.prototype.handleValidationReturnSuccess = function(json) {
      var resultStatus;
      AbstractUploadAndRunPrimaryAnalsysisController.__super__.handleValidationReturnSuccess.call(this, json);
      if (!json.hasError) {
        resultStatus = "Dry Run Results: Success";
        if (json.hasWarning) {
          resultStatus += " but with warnings";
        }
      } else {
        resultStatus = "Dry Run Results: Failed";
      }
      this.$('.bv_resultStatus').html(resultStatus);
      this.analysisParameterController.disableAllInputs();
      return console.log;
    };

    AbstractUploadAndRunPrimaryAnalsysisController.prototype.handleSaveReturnSuccess = function(json) {
      AbstractUploadAndRunPrimaryAnalsysisController.__super__.handleSaveReturnSuccess.call(this, json);
      this.$('.bv_loadAnother').html("Re-Analyze");
      return this.trigger('analysis-completed');
    };

    AbstractUploadAndRunPrimaryAnalsysisController.prototype.backToUpload = function() {
      AbstractUploadAndRunPrimaryAnalsysisController.__super__.backToUpload.call(this);
      this.$('.bv_resultStatus').html("Upload Data and Analyze");
      return this.$('.bv_resultStatus').show();
    };

    AbstractUploadAndRunPrimaryAnalsysisController.prototype.loadAnother = function() {
      if (this.analyzedPreviously) {
        if (!confirm("Re-analyzing the data will delete the previously saved results.")) {
          return;
        }
      }
      AbstractUploadAndRunPrimaryAnalsysisController.__super__.loadAnother.call(this);
      this.$('.bv_resultStatus').html("Upload Data and Analyze");
      return this.$('.bv_resultStatus').show();
    };

    AbstractUploadAndRunPrimaryAnalsysisController.prototype.showFileSelectPhase = function() {
      AbstractUploadAndRunPrimaryAnalsysisController.__super__.showFileSelectPhase.call(this);
      this.$('.bv_resultStatus').show();
      if (this.analysisParameterController != null) {
        return this.analysisParameterController.enableAllInputs();
      }
    };

    AbstractUploadAndRunPrimaryAnalsysisController.prototype.showFileUploadCompletePhase = function() {
      this.analyzedPreviously = true;
      return AbstractUploadAndRunPrimaryAnalsysisController.__super__.showFileUploadCompletePhase.call(this);
    };

    AbstractUploadAndRunPrimaryAnalsysisController.prototype.disableAll = function() {
      this.analysisParameterController.disableAllInputs();
      this.$('.bv_htmlSummary').hide();
      this.$('.bv_fileUploadWrapper').hide();
      this.$('.bv_nextControlContainer').hide();
      this.$('.bv_saveControlContainer').hide();
      this.$('.bv_completeControlContainer').hide();
      return this.$('.bv_notifications').hide();
    };

    AbstractUploadAndRunPrimaryAnalsysisController.prototype.enableAll = function() {
      this.analysisParameterController.enableAllInputs();
      return this.showFileSelectPhase();
    };

    AbstractUploadAndRunPrimaryAnalsysisController.prototype.validateParseFile = function() {
      this.analysisParameterController.updateModel();
      if (!!this.analysisParameterController.isValid()) {
        this.additionalData = {
          inputParameters: JSON.stringify(this.analysisParameterController.model),
          primaryAnalysisExperimentId: this.experimentId,
          testMode: false
        };
        return AbstractUploadAndRunPrimaryAnalsysisController.__super__.validateParseFile.call(this);
      }
    };

    AbstractUploadAndRunPrimaryAnalsysisController.prototype.setUser = function(user) {
      return this.userName = user;
    };

    AbstractUploadAndRunPrimaryAnalsysisController.prototype.setExperimentId = function(expId) {
      return this.experimentId = expId;
    };

    return AbstractUploadAndRunPrimaryAnalsysisController;

  })(BasicFileValidateAndSaveController);

  window.UploadAndRunPrimaryAnalsysisController = (function(_super) {
    __extends(UploadAndRunPrimaryAnalsysisController, _super);

    function UploadAndRunPrimaryAnalsysisController() {
      return UploadAndRunPrimaryAnalsysisController.__super__.constructor.apply(this, arguments);
    }

    UploadAndRunPrimaryAnalsysisController.prototype.initialize = function() {
      this.fileProcessorURL = "/api/primaryAnalysis/runPrimaryAnalysis";
      this.errorOwnerName = 'UploadAndRunPrimaryAnalsysisController';
      this.allowedFileTypes = ['zip'];
      this.maxFileSize = 200000000;
      this.loadReportFile = false;
      UploadAndRunPrimaryAnalsysisController.__super__.initialize.call(this);
      this.$('.bv_moduleTitle').hide();
      this.analysisParameterController = new PrimaryScreenAnalysisParametersController({
        model: this.options.paramsFromExperiment,
        el: this.$('.bv_additionalValuesForm')
      });
      return this.completeInitialization();
    };

    return UploadAndRunPrimaryAnalsysisController;

  })(AbstractUploadAndRunPrimaryAnalsysisController);

  window.PrimaryScreenAnalysisController = (function(_super) {
    __extends(PrimaryScreenAnalysisController, _super);

    function PrimaryScreenAnalysisController() {
      this.handleStatusChanged = __bind(this.handleStatusChanged, this);
      this.handleAnalysisComplete = __bind(this.handleAnalysisComplete, this);
      this.handleExperimentSaved = __bind(this.handleExperimentSaved, this);
      this.setExperimentSaved = __bind(this.setExperimentSaved, this);
      this.checkStatus = __bind(this.checkStatus, this);
      this.render = __bind(this.render, this);
      return PrimaryScreenAnalysisController.__super__.constructor.apply(this, arguments);
    }

    PrimaryScreenAnalysisController.prototype.template = _.template($("#PrimaryScreenAnalysisView").html());

    PrimaryScreenAnalysisController.prototype.initialize = function() {
      this.model.on("sync", this.handleExperimentSaved);
      this.model.getStatus().on('change', this.handleStatusChanged);
      this.dataAnalysisController = null;
      $(this.el).empty();
      $(this.el).html(this.template());
      if (this.model.isNew()) {
        return this.setExperimentNotSaved();
      } else {
        this.setExperimentSaved();
        return this.setupDataAnalysisController(this.options.uploadAndRunControllerName);
      }
    };

    PrimaryScreenAnalysisController.prototype.render = function() {
      return this.showExistingResults();
    };

    PrimaryScreenAnalysisController.prototype.showExistingResults = function() {
      var analysisStatus, dryRunStatus, statusId;
      dryRunStatus = this.model.getDryRunStatus();
      if (dryRunStatus !== null) {
        dryRunStatus = dryRunStatus.get('codeValue');
      } else {
        dryRunStatus = "not started";
      }
      analysisStatus = this.model.getAnalysisStatus();
      if (analysisStatus !== null) {
        analysisStatus = analysisStatus.get('codeValue');
      } else {
        analysisStatus = "not started";
      }
      console.log(dryRunStatus);
      console.log(analysisStatus);
      if (dryRunStatus === "running") {
        if (analysisStatus === "running") {
          console.log("warning message");
          return this.showWarningStatus(dryRunStatus, analysisStatus);
        } else {
          console.log("validate status drop down modal progress bar");
          console.log("progress bar shown");
          statusId = this.model.getDryRunStatus().get('id');
          this.trigger("dryRunRunning");
          return this.checkStatus(statusId, "dryRun");
        }
      } else if (analysisStatus === "running") {
        if (dryRunStatus === "not started") {
          console.log("warning message");
          return this.showWarningStatus(dryRunStatus, analysisStatus);
        } else {
          console.log("save status drop down modal progress bar");
          statusId = this.model.getAnalysisStatus().get('id');
          this.trigger('analysisRunning');
          return this.checkStatus(statusId, "analysis");
        }
      } else if (analysisStatus === "complete" || analysisStatus === "failed") {
        return this.showAnalysisResults(analysisStatus);
      } else {
        if (dryRunStatus === "not started") {
          console.log("upload data page - hide bv_htmlSummary, csvPreviewContainer, bv_saveControlContainer, bv_completeControlContainer");
          return this.showUploadWrapper();
        } else {
          console.log("update bv_resultStatus with the dryRun status, fill bv_htmlSummary with dry run result html");
          return this.showDryRunResults(dryRunStatus);
        }
      }
    };

    PrimaryScreenAnalysisController.prototype.showWarningStatus = function(dryRunStatus, analysisStatus) {
      var resultHTML, resultStatus;
      resultStatus = "An error has occurred. Dry Run: " + dryRunStatus + ". Analysis: " + analysisStatus + ".";
      resultHTML = "An error has occurred.";
      this.trigger("warning");
      this.$('.bv_resultStatus').html(resultStatus);
      return this.$('.bv_htmlSummary').html(resultHTML);
    };

    PrimaryScreenAnalysisController.prototype.checkStatus = function(statusId, analysisStep) {
      console.log("checking status");
      console.log(this.model);
      console.log(statusId);
      return $.ajax({
        type: 'GET',
        url: "/api/experiments/values/" + statusId,
        dataType: 'json',
        error: function(err) {
          return alert('Error - Could not get requested status value.');
        },
        success: (function(_this) {
          return function(json) {
            var resultHTML, resultStatus, status, statusValue;
            if (json.length === 0) {
              return alert('Success but could not get requested status value.');
            } else {
              console.log("json");
              console.log(json);
              statusValue = new Value(json);
              console.log(statusValue);
              status = statusValue.get('codeValue');
              if (status === "running") {
                setTimeout(_this.checkStatus(statusId, analysisStep), 5000);
                console.log("still running");
                if (analysisStep === "dryRun") {
                  resultStatus = "Dry Run Results: Dry run in progress.";
                  resultHTML = "";
                } else {
                  resultStatus = "Upload Results: Upload in progress.";
                  resultHTML = _this.model.getDryRunResultHTML().get('clobValue');
                }
                _this.$('.bv_resultStatus').html(resultStatus);
                _this.$('.bv_htmlSummary').html(resultHTML);
                if (_this.dataAnalysisController != null) {
                  return _this.dataAnalysisController.showFileUploadPhase();
                }
              } else {
                console.log("done running");
                console.log(status);
                if (analysisStep === "dryRun") {
                  console.log("should hide validate bar and show dry run results");
                  _this.trigger("dryRunDone");
                  return _this.showDryRunResults(status);
                } else {
                  console.log("should hide upload bar and show analysis results");
                  _this.trigger("analysisDone");
                  return _this.showAnalysisResults(status);
                }
              }
            }
          };
        })(this)
      });
    };

    PrimaryScreenAnalysisController.prototype.showAnalysisResults = function(analysisStatus) {
      var resultHTML, resultStatus;
      if (analysisStatus === "complete") {
        console.log("saved data page, fill bv_htmlSummary with analysis result html clobValue, show re-analyze button");
        resultStatus = "Upload Results: Success";
      } else {
        console.log("failed page, fill bv_htmlSummary with analyisis clob, show re-analyze button");
        resultStatus = "Upload Results: Failed due to errors";
      }
      resultHTML = this.model.getAnalysisResultHTML().get('clobValue');
      if (this.dataAnalysisController != null) {
        console.log("show analysis reults - upload complete phase");
        this.dataAnalysisController.showFileUploadCompletePhase();
      }
      this.$('.bv_resultStatus').html(resultStatus);
      return this.$('.bv_htmlSummary').html(resultHTML);
    };

    PrimaryScreenAnalysisController.prototype.showDryRunResults = function(dryRunStatus) {
      var resultHTML, resultStatus;
      console.log("show dry run results");
      if (dryRunStatus === "complete") {
        resultStatus = "Dry Run Results: Success";
      } else {
        resultStatus = "Dry Run Results: Failed";
      }
      resultHTML = this.model.getDryRunResultHTML().get('clobValue');
      if (this.dataAnalysisController != null) {
        this.dataAnalysisController.parseFileUploaded = true;
        this.dataAnalysisController.filePassedValidation = true;
        this.dataAnalysisController.showFileUploadPhase();
        this.dataAnalysisController.handleFormValid();
      }
      this.$('.bv_resultStatus').html(resultStatus);
      return this.$('.bv_htmlSummary').html(resultHTML);
    };

    PrimaryScreenAnalysisController.prototype.showUploadWrapper = function() {
      var resultHTML, resultStatus;
      resultStatus = "Upload Data and Analyze";
      resultHTML = "";
      this.$('.bv_resultStatus').html(resultStatus);
      return this.$('.bv_htmlSummary').html(resultHTML);
    };

    PrimaryScreenAnalysisController.prototype.setExperimentNotSaved = function() {
      this.$('.bv_fileUploadWrapper').hide();
      this.$('.bv_resultsContainer').hide();
      return this.$('.bv_saveExperimentToAnalyze').show();
    };

    PrimaryScreenAnalysisController.prototype.setExperimentSaved = function() {
      this.$('.bv_saveExperimentToAnalyze').hide();
      return this.$('.bv_fileUploadWrapper').show();
    };

    PrimaryScreenAnalysisController.prototype.handleExperimentSaved = function() {
      console.log("handle experiment saved");
      this.setExperimentSaved();
      if (this.dataAnalysisController == null) {
        console.log("no data analysis controller");
        this.setupDataAnalysisController(this.options.uploadAndRunControllerName);
      }
      return this.model.getStatus().on('change', this.handleStatusChanged);
    };

    PrimaryScreenAnalysisController.prototype.handleAnalysisComplete = function() {
      this.$('.bv_resultsContainer').hide();
      return this.trigger('analysis-completed');
    };

    PrimaryScreenAnalysisController.prototype.handleStatusChanged = function() {
      if (this.dataAnalysisController !== null) {
        if (this.model.isEditable()) {
          return this.dataAnalysisController.enableAll();
        } else {
          return this.dataAnalysisController.disableAll();
        }
      }
    };

    PrimaryScreenAnalysisController.prototype.setupDataAnalysisController = function(dacClassName) {
      var newArgs;
      newArgs = {
        el: this.$('.bv_fileUploadWrapper'),
        paramsFromExperiment: this.model.getAnalysisParameters(),
        analyzedPreviously: this.model.getAnalysisStatus().get('codeValue') !== "not started"
      };
      this.dataAnalysisController = new window[dacClassName](newArgs);
      this.dataAnalysisController.setUser(window.AppLaunchParams.loginUserName);
      this.dataAnalysisController.setExperimentId(this.model.id);
      this.dataAnalysisController.on('analysis-completed', this.handleAnalysisComplete);
      this.dataAnalysisController.on('amDirty', (function(_this) {
        return function() {
          return _this.trigger('amDirty');
        };
      })(this));
      this.dataAnalysisController.on('amClean', (function(_this) {
        return function() {
          return _this.trigger('amClean');
        };
      })(this));
      return this.showExistingResults();
    };

    return PrimaryScreenAnalysisController;

  })(Backbone.View);

  window.AbstractPrimaryScreenExperimentController = (function(_super) {
    __extends(AbstractPrimaryScreenExperimentController, _super);

    function AbstractPrimaryScreenExperimentController() {
      this.handleProtocolAttributesCopied = __bind(this.handleProtocolAttributesCopied, this);
      this.handleExperimentSaved = __bind(this.handleExperimentSaved, this);
      this.completeInitialization = __bind(this.completeInitialization, this);
      return AbstractPrimaryScreenExperimentController.__super__.constructor.apply(this, arguments);
    }

    AbstractPrimaryScreenExperimentController.prototype.template = _.template($("#PrimaryScreenExperimentView").html());

    AbstractPrimaryScreenExperimentController.prototype.initialize = function() {
      if (this.model != null) {
        return this.completeInitialization();
      } else {
        if (window.AppLaunchParams.moduleLaunchParams != null) {
          if (window.AppLaunchParams.moduleLaunchParams.moduleName === this.moduleLaunchName) {
            return $.ajax({
              type: 'GET',
              url: "/api/experiments/codename/" + window.AppLaunchParams.moduleLaunchParams.code,
              dataType: 'json',
              error: function(err) {
                alert('Could not get experiment for code in this URL, creating new one');
                return this.completeInitialization();
              },
              success: (function(_this) {
                return function(json) {
                  var exp, lsKind;
                  if (json.length === 0) {
                    alert('Could not get experiment for code in this URL, creating new one');
                  } else {
                    lsKind = json[0].lsKind;
                    if (lsKind === "flipr screening assay") {
                      exp = new PrimaryScreenExperiment(json[0]);
                      exp.set(exp.parse(exp.attributes));
                      if (window.AppLaunchParams.moduleLaunchParams.copy) {
                        _this.model = exp.duplicateEntity();
                      } else {
                        _this.model = exp;
                      }
                    } else {
                      alert('Could not get primary screen experiment for code in this URL. Creating new primary screen experiment');
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

    AbstractPrimaryScreenExperimentController.prototype.completeInitialization = function() {
      if (this.model == null) {
        this.model = new PrimaryScreenExperiment();
      }
      $(this.el).html(this.template());
      this.model.on('sync', this.handleExperimentSaved);
      this.experimentBaseController = new ExperimentBaseController({
        model: this.model,
        el: this.$('.bv_experimentBase'),
        protocolFilter: this.protocolFilter,
        protocolKindFilter: this.protocolKindFilter
      });
      this.experimentBaseController.on('amDirty', (function(_this) {
        return function() {
          return _this.trigger('amDirty');
        };
      })(this));
      this.experimentBaseController.on('amClean', (function(_this) {
        return function() {
          return _this.trigger('amClean');
        };
      })(this));
      this.analysisController = new PrimaryScreenAnalysisController({
        model: this.model,
        el: this.$('.bv_primaryScreenDataAnalysis'),
        uploadAndRunControllerName: this.uploadAndRunControllerName
      });
      this.analysisController.on('amDirty', (function(_this) {
        return function() {
          return _this.trigger('amDirty');
        };
      })(this));
      this.analysisController.on('amClean', (function(_this) {
        return function() {
          return _this.trigger('amClean');
        };
      })(this));
      this.analysisController.on('warning', (function(_this) {
        return function() {
          return _this.showWarningModal();
        };
      })(this));
      this.analysisController.on('dryRunRunning', (function(_this) {
        return function() {
          return _this.showValidateProgressBar();
        };
      })(this));
      this.analysisController.on('dryRunDone', (function(_this) {
        return function() {
          return _this.hideValidateProgressBar();
        };
      })(this));
      this.analysisController.on('analysisRunning', (function(_this) {
        return function() {
          return _this.showSaveProgressBar();
        };
      })(this));
      this.analysisController.on('analysisDone', (function(_this) {
        return function() {
          return _this.hideSaveProgressBar();
        };
      })(this));
      this.setupModelFitController(this.modelFitControllerName);
      this.analysisController.on('analysis-completed', (function(_this) {
        return function() {
          return _this.modelFitController.primaryAnalysisCompleted();
        };
      })(this));
      this.model.on("protocol_attributes_copied", this.handleProtocolAttributesCopied);
      this.experimentBaseController.render();
      this.analysisController.render();
      return this.modelFitController.render();
    };

    AbstractPrimaryScreenExperimentController.prototype.setupModelFitController = function(modelFitControllerName) {
      var newArgs;
      newArgs = {
        model: this.model,
        el: this.$('.bv_doseResponseAnalysis')
      };
      this.modelFitController = new window[modelFitControllerName](newArgs);
      this.modelFitController.on('amDirty', (function(_this) {
        return function() {
          return _this.trigger('amDirty');
        };
      })(this));
      return this.modelFitController.on('amClean', (function(_this) {
        return function() {
          return _this.trigger('amClean');
        };
      })(this));
    };

    AbstractPrimaryScreenExperimentController.prototype.handleExperimentSaved = function() {
      return this.analysisController.render();
    };

    AbstractPrimaryScreenExperimentController.prototype.handleProtocolAttributesCopied = function() {
      return this.analysisController.render();
    };

    AbstractPrimaryScreenExperimentController.prototype.showWarningModal = function() {
      var analysisResult, analysisStatus, dryRunResult, dryRunStatus;
      console.log("should show warning message");
      this.$('a[href="#tab3"]').tab('show');
      dryRunStatus = this.model.getDryRunStatus().get('codeValue');
      dryRunResult = this.model.getDryRunResultHTML().get('clobValue');
      analysisStatus = this.model.getAnalysisStatus().get('codeValue');
      analysisResult = this.model.getAnalysisResultHTML().get('clobValue');
      console.log(dryRunStatus);
      console.log(analysisStatus);
      this.$('.bv_dryRunStatus').html("Dry Run Status: " + dryRunStatus);
      this.$('.bv_dryRunResult').html("Dry Run Result HTML: " + dryRunResult);
      this.$('.bv_analysisStatus').html("Analysis Status: " + analysisStatus);
      this.$('.bv_analysisResult').html("Analysis Result HTML: " + analysisResult);
      this.$('.bv_invalidAnalysisStates').modal({
        backdrop: "static"
      });
      this.$('.bv_invalidAnalysisStates').modal("show");
      this.$('.bv_fileUploadWrapper .bv_fileUploadWrapper').hide();
      return this.$('.bv_fileUploadWrapper .bv_flowControl').hide();
    };

    AbstractPrimaryScreenExperimentController.prototype.showValidateProgressBar = function() {
      console.log("should show validate progress bar");
      this.$('a[href="#tab3"]').tab('show');
      this.$('.bv_validateStatusDropDown').modal({
        backdrop: "static"
      });
      return this.$('.bv_validateStatusDropDown').modal("show");
    };

    AbstractPrimaryScreenExperimentController.prototype.showSaveProgressBar = function() {
      console.log("should show save progress bar");
      this.$('a[href="#tab3"]').tab('show');
      this.$('.bv_saveStatusDropDown').modal({
        backdrop: "static"
      });
      return this.$('.bv_saveStatusDropDown').modal("show");
    };

    AbstractPrimaryScreenExperimentController.prototype.hideValidateProgressBar = function() {
      console.log("should hide validate progress bar");
      return this.$('.bv_validateStatusDropDown').modal("hide");
    };

    AbstractPrimaryScreenExperimentController.prototype.hideSaveProgressBar = function() {
      console.log("should hide save progress bar");
      return this.$('.bv_saveStatusDropDown').modal("hide");
    };

    return AbstractPrimaryScreenExperimentController;

  })(Backbone.View);

  window.PrimaryScreenExperimentController = (function(_super) {
    __extends(PrimaryScreenExperimentController, _super);

    function PrimaryScreenExperimentController() {
      return PrimaryScreenExperimentController.__super__.constructor.apply(this, arguments);
    }

    PrimaryScreenExperimentController.prototype.uploadAndRunControllerName = "UploadAndRunPrimaryAnalsysisController";

    PrimaryScreenExperimentController.prototype.modelFitControllerName = "DoseResponseAnalysisController";

    PrimaryScreenExperimentController.prototype.protocolFilter = "?protocolName=FLIPR";

    PrimaryScreenExperimentController.prototype.protocolKindFilter = "?protocolKind=flipr screening assay";

    PrimaryScreenExperimentController.prototype.moduleLaunchName = "flipr_screening_assay";

    return PrimaryScreenExperimentController;

  })(AbstractPrimaryScreenExperimentController);

}).call(this);
