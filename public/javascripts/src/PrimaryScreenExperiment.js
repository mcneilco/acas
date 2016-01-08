(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.PrimaryAnalysisRead = (function(superClass) {
    extend(PrimaryAnalysisRead, superClass);

    function PrimaryAnalysisRead() {
      this.validate = bind(this.validate, this);
      return PrimaryAnalysisRead.__super__.constructor.apply(this, arguments);
    }

    PrimaryAnalysisRead.prototype.defaults = {
      readNumber: 1,
      readPosition: "",
      readName: "unassigned",
      activity: false
    };

    PrimaryAnalysisRead.prototype.validate = function(attrs) {
      var errors;
      errors = [];
      if ((_.isNaN(attrs.readPosition) || attrs.readPosition === "" || attrs.readPosition === null || attrs.readPosition === void 0) && attrs.readName.slice(0, 5) !== "Calc:") {
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

    return PrimaryAnalysisRead;

  })(Backbone.Model);

  window.TransformationRule = (function(superClass) {
    extend(TransformationRule, superClass);

    function TransformationRule() {
      this.validate = bind(this.validate, this);
      return TransformationRule.__super__.constructor.apply(this, arguments);
    }

    TransformationRule.prototype.defaults = {
      transformationRule: "unassigned"
    };

    TransformationRule.prototype.validate = function(attrs) {
      var errors;
      errors = [];
      if (attrs.transformationRule === "unassigned" || attrs.transformationRule === null) {
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

    return TransformationRule;

  })(Backbone.Model);

  window.PrimaryAnalysisReadList = (function(superClass) {
    extend(PrimaryAnalysisReadList, superClass);

    function PrimaryAnalysisReadList() {
      this.validateCollection = bind(this.validateCollection, this);
      return PrimaryAnalysisReadList.__super__.constructor.apply(this, arguments);
    }

    PrimaryAnalysisReadList.prototype.model = PrimaryAnalysisRead;

    PrimaryAnalysisReadList.prototype.validateCollection = function(matchReadName) {
      var currentReadName, error, i, index, indivModelErrors, j, len, model, modelErrors, ref, usedReadNames;
      modelErrors = [];
      usedReadNames = {};
      if (this.length !== 0) {
        for (index = i = 0, ref = this.length - 1; 0 <= ref ? i <= ref : i >= ref; index = 0 <= ref ? ++i : --i) {
          model = this.at(index);
          indivModelErrors = model.validate(model.attributes);
          if (indivModelErrors !== null) {
            for (j = 0, len = indivModelErrors.length; j < len; j++) {
              error = indivModelErrors[j];
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

  window.TransformationRuleList = (function(superClass) {
    extend(TransformationRuleList, superClass);

    function TransformationRuleList() {
      this.validateCollection = bind(this.validateCollection, this);
      return TransformationRuleList.__super__.constructor.apply(this, arguments);
    }

    TransformationRuleList.prototype.model = TransformationRule;

    TransformationRuleList.prototype.validateCollection = function() {
      var currentRule, error, i, index, indivModelErrors, j, len, model, modelErrors, ref, usedRules;
      modelErrors = [];
      usedRules = {};
      if (this.length !== 0) {
        for (index = i = 0, ref = this.length - 1; 0 <= ref ? i <= ref : i >= ref; index = 0 <= ref ? ++i : --i) {
          model = this.at(index);
          indivModelErrors = model.validate(model.attributes);
          if (indivModelErrors !== null) {
            for (j = 0, len = indivModelErrors.length; j < len; j++) {
              error = indivModelErrors[j];
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

  window.PrimaryScreenAnalysisParameters = (function(superClass) {
    extend(PrimaryScreenAnalysisParameters, superClass);

    function PrimaryScreenAnalysisParameters() {
      this.validate = bind(this.validate, this);
      this.parse = bind(this.parse, this);
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
        htsFormat: true,
        autoHitSelection: false,
        matchReadName: false,
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
      var agonistControl, agonistControlConc, errors, negativeControl, negativeControlConc, positiveControl, positiveControlConc, readErrors, transformationErrors, vehicleControl;
      errors = [];
      readErrors = this.get('primaryAnalysisReadList').validateCollection(attrs.matchReadName);
      errors.push.apply(errors, readErrors);
      transformationErrors = this.get('transformationRuleList').validateCollection();
      errors.push.apply(errors, transformationErrors);
      positiveControl = this.get('positiveControl').get('batchCode');
      if (positiveControl === "" || positiveControl === void 0 || positiveControl === "invalid" || positiveControl === null) {
        errors.push({
          attribute: 'positiveControlBatch',
          message: "A registered batch number must be provided."
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
      if (negativeControl === "" || negativeControl === void 0 || negativeControl === "invalid" || negativeControl === null) {
        errors.push({
          attribute: 'negativeControlBatch',
          message: "A registered batch number must be provided."
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
      if ((agonistControl !== "" && agonistControl !== void 0 && agonistControl !== null) || (agonistControlConc !== "" && agonistControlConc !== void 0 && agonistControlConc !== null)) {
        if (agonistControl === "" || agonistControl === void 0 || agonistControl === null || agonistControl === "invalid") {
          errors.push({
            attribute: 'agonistControlBatch',
            message: "A registered batch number must be provided."
          });
        }
        if (_.isNaN(agonistControlConc) || agonistControlConc === void 0 || agonistControlConc === "" || agonistControlConc === null) {
          errors.push({
            attribute: 'agonistControlConc',
            message: "Agonist control conc must be set"
          });
        }
      }
      vehicleControl = this.get('vehicleControl').get('batchCode');
      if (vehicleControl === "invalid") {
        errors.push({
          attribute: 'vehicleControlBatch',
          message: "A registered batch number must be provided."
        });
      }
      if (attrs.instrumentReader === "unassigned" || attrs.instrumentReader === null) {
        errors.push({
          attribute: 'instrumentReader',
          message: "Instrument Reader must be assigned"
        });
      }
      if (attrs.signalDirectionRule === "unassigned" || attrs.signalDirectionRule === null) {
        errors.push({
          attribute: 'signalDirectionRule',
          message: "Signal Direction Rule must be assigned"
        });
      }
      if (attrs.aggregateBy === "unassigned" || attrs.aggregateBy === null) {
        errors.push({
          attribute: 'aggregateBy',
          message: "Aggregate By must be assigned"
        });
      }
      if (attrs.aggregationMethod === "unassigned" || attrs.aggregationMethod === null) {
        errors.push({
          attribute: 'aggregationMethod',
          message: "Aggregation method must be assigned"
        });
      }
      if (attrs.normalizationRule === "unassigned" || attrs.normalizationRule === null) {
        errors.push({
          attribute: 'normalizationRule',
          message: "Normalization rule must be assigned"
        });
      }
      if (attrs.autoHitSelection) {
        if (attrs.thresholdType === "sd" && _.isNaN(attrs.hitSDThreshold)) {
          errors.push({
            attribute: 'hitSDThreshold',
            message: "SD threshold must be a number"
          });
        }
        if (attrs.thresholdType === "efficacy" && _.isNaN(attrs.hitEfficacyThreshold)) {
          errors.push({
            attribute: 'hitEfficacyThreshold',
            message: "Efficacy threshold must be a number"
          });
        }
      }
      if (_.isNaN(attrs.assayVolume)) {
        errors.push({
          attribute: 'assayVolume',
          message: "Assay volume must be a number"
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
          message: "Transfer volume must be a number"
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

  window.PrimaryScreenExperiment = (function(superClass) {
    extend(PrimaryScreenExperiment, superClass);

    function PrimaryScreenExperiment() {
      return PrimaryScreenExperiment.__super__.constructor.apply(this, arguments);
    }

    PrimaryScreenExperiment.prototype.initialize = function() {
      PrimaryScreenExperiment.__super__.initialize.call(this);
      this.set({
        lsType: "Biology"
      });
      return this.set({
        lsKind: "Bio Activity"
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
          codeOrigin: "ACAS DDICT"
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

    PrimaryScreenExperiment.prototype.getModelFitType = function() {
      var type;
      type = this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "experiment metadata", "codeValue", "model fit type");
      if (!type.has('codeValue')) {
        type.set({
          codeValue: "unassigned"
        });
        type.set({
          codeType: "model fit"
        });
        type.set({
          codeKind: "type"
        });
        type.set({
          codeOrigin: "ACAS DDICT"
        });
      }
      return type;
    };

    return PrimaryScreenExperiment;

  })(Experiment);

  window.PrimaryAnalysisReadController = (function(superClass) {
    extend(PrimaryAnalysisReadController, superClass);

    function PrimaryAnalysisReadController() {
      this.handleActivityChanged = bind(this.handleActivityChanged, this);
      this.handleReadNameChanged = bind(this.handleReadNameChanged, this);
      this.updateModel = bind(this.updateModel, this);
      this.render = bind(this.render, this);
      return PrimaryAnalysisReadController.__super__.constructor.apply(this, arguments);
    }

    PrimaryAnalysisReadController.prototype.template = _.template($("#PrimaryAnalysisReadView").html());

    PrimaryAnalysisReadController.prototype.tagName = "div";

    PrimaryAnalysisReadController.prototype.className = "form-inline";

    PrimaryAnalysisReadController.prototype.events = {
      "keyup .bv_readPosition": "attributeChanged",
      "change .bv_readName": "handleReadNameChanged",
      "click .bv_activity": "handleActivityChanged",
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
      this.$('.bv_readNumber').html('R' + this.model.get('readNumber'));
      this.setUpReadNameSelect();
      this.hideReadPosition(this.model.get('readName'));
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

    PrimaryAnalysisReadController.prototype.hideReadPosition = function(readName) {
      var isCalculatedRead;
      isCalculatedRead = readName.slice(0, 5) === "Calc:";
      if (isCalculatedRead === true) {
        this.$('.bv_readPosition').val('');
        this.$('.bv_readPosition').hide();
        return this.$('.bv_readPositionHolder').show();
      } else {
        this.$('.bv_readPosition').show();
        return this.$('.bv_readPositionHolder').hide();
      }
    };

    PrimaryAnalysisReadController.prototype.setUpReadPosition = function(matchReadNameChecked) {
      if (matchReadNameChecked) {
        return this.$('.bv_readPosition').attr('disabled', 'disabled');
      } else {
        return this.$('.bv_readPosition').removeAttr('disabled');
      }
    };

    PrimaryAnalysisReadController.prototype.updateModel = function() {
      this.model.set({
        readPosition: parseInt(UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_readPosition')))
      });
      return this.trigger('updateState');
    };

    PrimaryAnalysisReadController.prototype.handleReadNameChanged = function() {
      var readName;
      readName = this.readNameListController.getSelectedCode();
      this.hideReadPosition(readName);
      this.model.set({
        readName: readName
      });
      return this.attributeChanged();
    };

    PrimaryAnalysisReadController.prototype.handleActivityChanged = function() {
      var activity;
      activity = this.$('.bv_activity').is(":checked");
      this.model.set({
        activity: activity
      });
      this.attributeChanged();
      return this.trigger('updateAllActivities');
    };

    return PrimaryAnalysisReadController;

  })(AbstractFormController);

  window.TransformationRuleController = (function(superClass) {
    extend(TransformationRuleController, superClass);

    function TransformationRuleController() {
      this.clear = bind(this.clear, this);
      this.updateModel = bind(this.updateModel, this);
      this.render = bind(this.render, this);
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
      this.model.destroy();
      return this.attributeChanged();
    };

    return TransformationRuleController;

  })(AbstractFormController);

  window.PrimaryAnalysisReadListController = (function(superClass) {
    extend(PrimaryAnalysisReadListController, superClass);

    function PrimaryAnalysisReadListController() {
      this.updateAllActivities = bind(this.updateAllActivities, this);
      this.renumberReads = bind(this.renumberReads, this);
      this.checkActivity = bind(this.checkActivity, this);
      this.matchReadNameChanged = bind(this.matchReadNameChanged, this);
      this.addNewRead = bind(this.addNewRead, this);
      this.render = bind(this.render, this);
      this.initialize = bind(this.initialize, this);
      return PrimaryAnalysisReadListController.__super__.constructor.apply(this, arguments);
    }

    PrimaryAnalysisReadListController.prototype.template = _.template($("#PrimaryAnalysisReadListView").html());

    PrimaryAnalysisReadListController.prototype.matchReadNameChecked = false;

    PrimaryAnalysisReadListController.prototype.nextReadNumber = 1;

    PrimaryAnalysisReadListController.prototype.events = {
      "click .bv_addReadButton": "addNewRead"
    };

    PrimaryAnalysisReadListController.prototype.initialize = function() {
      this.collection.on('remove', this.checkActivity);
      this.collection.on('remove', this.renumberReads);
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
        return newModel.trigger('amDirty');
      }
    };

    PrimaryAnalysisReadListController.prototype.addOneRead = function(read) {
      var parc;
      read.set({
        readNumber: this.nextReadNumber
      });
      this.nextReadNumber++;
      parc = new PrimaryAnalysisReadController({
        model: read
      });
      this.$('.bv_readInfo').append(parc.render().el);
      parc.setUpReadPosition(this.matchReadNameChecked);
      parc.on('updateState', (function(_this) {
        return function() {
          return _this.trigger('updateState');
        };
      })(this));
      return parc.on('updateAllActivities', this.updateAllActivities);
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
      var activitySet, index, results1;
      index = this.collection.length - 1;
      activitySet = false;
      results1 = [];
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
        results1.push(index = index - 1);
      }
      return results1;
    };

    PrimaryAnalysisReadListController.prototype.renumberReads = function() {
      var index, readNumber, results1;
      this.nextReadNumber = 1;
      index = 0;
      results1 = [];
      while (index < this.collection.length) {
        readNumber = 'R' + this.nextReadNumber.toString();
        this.collection.at(index).set({
          readNumber: this.nextReadNumber
        });
        this.$('.bv_readNumber:eq(' + index + ')').html(readNumber);
        index++;
        results1.push(this.nextReadNumber++);
      }
      return results1;
    };

    PrimaryAnalysisReadListController.prototype.updateAllActivities = function() {
      var activity, index, results1;
      index = this.collection.length - 1;
      results1 = [];
      while (index >= 0) {
        activity = this.$('.bv_activity:eq(' + index + ')').is(":checked");
        this.collection.at(index).set({
          activity: activity
        });
        results1.push(index--);
      }
      return results1;
    };

    return PrimaryAnalysisReadListController;

  })(AbstractFormController);

  window.TransformationRuleListController = (function(superClass) {
    extend(TransformationRuleListController, superClass);

    function TransformationRuleListController() {
      this.checkNumberOfRules = bind(this.checkNumberOfRules, this);
      this.addNewRule = bind(this.addNewRule, this);
      this.render = bind(this.render, this);
      this.initialize = bind(this.initialize, this);
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
        return newModel.trigger('amDirty');
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

  window.PrimaryScreenAnalysisParametersController = (function(superClass) {
    extend(PrimaryScreenAnalysisParametersController, superClass);

    function PrimaryScreenAnalysisParametersController() {
      this.handleMatchReadNameChanged = bind(this.handleMatchReadNameChanged, this);
      this.handleVolumeTypeChanged = bind(this.handleVolumeTypeChanged, this);
      this.handleAutoHitSelectionChanged = bind(this.handleAutoHitSelectionChanged, this);
      this.handleThresholdTypeChanged = bind(this.handleThresholdTypeChanged, this);
      this.handleDilutionFactorChanged = bind(this.handleDilutionFactorChanged, this);
      this.handleTransferVolumeChanged = bind(this.handleTransferVolumeChanged, this);
      this.handleAssayVolumeChanged = bind(this.handleAssayVolumeChanged, this);
      this.handlePreferredBatchIdReturn = bind(this.handlePreferredBatchIdReturn, this);
      this.updateModel = bind(this.updateModel, this);
      this.render = bind(this.render, this);
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
      "keyup .bv_assayVolume": "handleAssayVolumeChanged",
      "keyup .bv_dilutionFactor": "handleDilutionFactorChanged",
      "keyup .bv_transferVolume": "handleTransferVolumeChanged",
      "keyup .bv_hitEfficacyThreshold": "attributeChanged",
      "keyup .bv_hitSDThreshold": "attributeChanged",
      "keyup .bv_positiveControlBatch": "handlePositiveControlBatchChanged",
      "keyup .bv_positiveControlConc": "attributeChanged",
      "keyup .bv_negativeControlBatch": "handleNegativeControlBatchChanged",
      "keyup .bv_negativeControlConc": "attributeChanged",
      "keyup .bv_vehicleControlBatch": "handleVehicleControlBatchChanged",
      "keyup .bv_agonistControlBatch": "handleAgonistControlBatchChanged",
      "keyup .bv_agonistControlConc": "attributeChanged",
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
      this.$("[data-toggle=popover]").popover();
      this.$("body").tooltip({
        selector: '.bv_popover'
      });
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
          name: "Select Aggregate By"
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
          name: "Select Aggregation Method"
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
          name: "Select Normalization Rule"
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
        concentration: parseFloat(UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_positiveControlConc')))
      });
      this.model.get('negativeControl').set({
        concentration: parseFloat(UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_negativeControlConc')))
      });
      this.model.get('vehicleControl').set({
        concentration: null
      });
      this.model.get('agonistControl').set({
        concentration: UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_agonistControlConc'))
      });
      if (this.model.get('agonistControl').get('concentration') !== "") {
        this.model.get('agonistControl').set({
          concentration: parseFloat(UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_agonistControlConc')))
        });
      }
      return this.trigger('updateState');
    };

    PrimaryScreenAnalysisParametersController.prototype.handlePositiveControlBatchChanged = function() {
      var batchCode;
      batchCode = UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_positiveControlBatch'));
      return this.getPreferredBatchId(batchCode, 'positiveControl');
    };

    PrimaryScreenAnalysisParametersController.prototype.handleNegativeControlBatchChanged = function() {
      var batchCode;
      batchCode = UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_negativeControlBatch'));
      return this.getPreferredBatchId(batchCode, 'negativeControl');
    };

    PrimaryScreenAnalysisParametersController.prototype.handleAgonistControlBatchChanged = function() {
      var batchCode;
      batchCode = UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_agonistControlBatch'));
      return this.getPreferredBatchId(batchCode, 'agonistControl');
    };

    PrimaryScreenAnalysisParametersController.prototype.handleVehicleControlBatchChanged = function() {
      var batchCode;
      batchCode = UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_vehicleControlBatch'));
      return this.getPreferredBatchId(batchCode, 'vehicleControl');
    };

    PrimaryScreenAnalysisParametersController.prototype.getPreferredBatchId = function(batchId, control) {
      if (batchId === "") {
        this.model.get(control).set({
          batchCode: ""
        });
        this.attributeChanged();
      } else {
        this.requestData = {
          requests: [
            {
              requestName: batchId
            }
          ]
        };
        return $.ajax({
          type: 'POST',
          url: "/api/preferredBatchId",
          data: this.requestData,
          success: (function(_this) {
            return function(json) {
              return _this.handlePreferredBatchIdReturn(json, control);
            };
          })(this),
          error: (function(_this) {
            return function(err) {
              return _this.serviceReturn = null;
            };
          })(this),
          dataType: 'json'
        });
      }
    };

    PrimaryScreenAnalysisParametersController.prototype.handlePreferredBatchIdReturn = function(json, control) {
      var preferredName, requestName, results;
      if (json.results != null) {
        results = json.results[0];
        preferredName = results.preferredName;
        requestName = results.requestName;
        if (preferredName === requestName) {
          this.model.get(control).set({
            batchCode: preferredName
          });
        } else if (preferredName === "") {
          this.model.get(control).set({
            batchCode: "invalid"
          });
        } else {
          this.$('.bv_' + control + 'Batch').val(preferredName);
          this.model.get(control).set({
            batchCode: preferredName
          });
        }
        return this.attributeChanged();
      }
    };

    PrimaryScreenAnalysisParametersController.prototype.handleAssayVolumeChanged = function() {
      var volumeType;
      this.attributeChanged();
      volumeType = this.$("input[name='bv_volumeType']:checked").val();
      if (volumeType === "dilution") {
        return this.handleDilutionFactorChanged(true);
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

    PrimaryScreenAnalysisParametersController.prototype.handleDilutionFactorChanged = function(indirectChange) {
      var transferVolume;
      this.attributeChanged();
      transferVolume = this.model.autocalculateVolumes();
      this.$('.bv_transferVolume').val(transferVolume);
      if (indirectChange === true) {
        if (transferVolume === "" || transferVolume === null) {
          return this.$('.bv_dilutionFactor').val(this.model.get('dilutionFactor'));
        }
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

    PrimaryScreenAnalysisParametersController.prototype.handleVolumeTypeChanged = function(skipUpdate) {
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
        this.handleDilutionFactorChanged(true);
      }
      if (skipUpdate !== true) {
        return this.attributeChanged();
      }
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

    PrimaryScreenAnalysisParametersController.prototype.enableAllInputs = function() {
      PrimaryScreenAnalysisParametersController.__super__.enableAllInputs.call(this);
      if (this.$('.bv_matchReadName').is(":checked")) {
        this.$('.bv_readPosition').attr('disabled', 'disabled');
      }
      this.$('.bv_loadAnother').prop('disabled', false);
      if (this.model.get('volumeType') === "transfer") {
        return this.$('.bv_dilutionFactor').attr('disabled', 'disabled');
      } else {
        return this.$('.bv_transferVolume').attr('disabled', 'disabled');
      }
    };

    return PrimaryScreenAnalysisParametersController;

  })(AbstractParserFormController);

  window.AbstractUploadAndRunPrimaryAnalsysisController = (function(superClass) {
    extend(AbstractUploadAndRunPrimaryAnalsysisController, superClass);

    function AbstractUploadAndRunPrimaryAnalsysisController() {
      this.validateParseFile = bind(this.validateParseFile, this);
      this.enableFields = bind(this.enableFields, this);
      this.disableAll = bind(this.disableAll, this);
      this.loadAnother = bind(this.loadAnother, this);
      this.backToUpload = bind(this.backToUpload, this);
      this.handleSaveReturnSuccess = bind(this.handleSaveReturnSuccess, this);
      this.handleValidationReturnSuccess = bind(this.handleValidationReturnSuccess, this);
      this.handleMSFormInvalid = bind(this.handleMSFormInvalid, this);
      this.handleMSFormValid = bind(this.handleMSFormValid, this);
      return AbstractUploadAndRunPrimaryAnalsysisController.__super__.constructor.apply(this, arguments);
    }

    AbstractUploadAndRunPrimaryAnalsysisController.prototype.initialize = function() {
      this.allowedFileTypes = ['zip'];
      this.loadReportFile = true;
      AbstractUploadAndRunPrimaryAnalsysisController.__super__.initialize.call(this);
      this.$('.bv_resultStatus').html("Upload Data and Analyze");
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
      return this.analysisParameterController.disableAllInputs();
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

    AbstractUploadAndRunPrimaryAnalsysisController.prototype.disableAllInputs = function() {
      return this.analysisParameterController.disableAllInputs();
    };

    AbstractUploadAndRunPrimaryAnalsysisController.prototype.disableAll = function() {
      this.analysisParameterController.disableAllInputs();
      this.$('.bv_next').attr('disabled', 'disabled');
      this.$('.bv_next').prop('disabled', true);
      this.$('.bv_back').attr('disabled', 'disabled');
      this.$('.bv_back').prop('disabled', true);
      this.$('.bv_loadAnother').removeAttr('disabled');
      return this.$('.bv_loadAnother').attr('disabled', 'disabled');
    };

    AbstractUploadAndRunPrimaryAnalsysisController.prototype.enableFields = function() {
      this.$('.bv_back').removeAttr('disabled');
      this.$('.bv_back').prop('disabled', false);
      this.$('.bv_next').removeAttr('disabled');
      this.$('.bv_next').prop('disabled', false);
      if (this.$('.bv_outerContainer .bv_flowControl .bv_nextControlContainer').css('display') !== 'none') {
        return this.analysisParameterController.enableAllInputs();
      } else {
        if (this.analysisParameterController.model.isValid()) {
          this.$('.bv_loadAnother').removeAttr('disabled');
          return this.$('.bv_loadAnother').prop('disabled', false);
        } else {
          this.$('.bv_loadAnother').removeAttr('disabled');
          return this.$('.bv_loadAnother').attr('disabled', 'disabled');
        }
      }
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

    AbstractUploadAndRunPrimaryAnalsysisController.prototype.updateAnalysisParamModel = function(model) {
      this.analysisParameterController.model = model.getAnalysisParameters();
      return this.analysisParameterController.render();
    };

    return AbstractUploadAndRunPrimaryAnalsysisController;

  })(BasicFileValidateAndSaveController);

  window.UploadAndRunPrimaryAnalsysisController = (function(superClass) {
    extend(UploadAndRunPrimaryAnalsysisController, superClass);

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

  window.PrimaryScreenAnalysisController = (function(superClass) {
    extend(PrimaryScreenAnalysisController, superClass);

    function PrimaryScreenAnalysisController() {
      this.handleAnalysisParamsChanged = bind(this.handleAnalysisParamsChanged, this);
      this.handleStatusChanged = bind(this.handleStatusChanged, this);
      this.handleAnalysisComplete = bind(this.handleAnalysisComplete, this);
      this.handleExperimentSaved = bind(this.handleExperimentSaved, this);
      this.setExperimentSaved = bind(this.setExperimentSaved, this);
      this.showUpdatedModel = bind(this.showUpdatedModel, this);
      this.checkStatus = bind(this.checkStatus, this);
      this.render = bind(this.render, this);
      return PrimaryScreenAnalysisController.__super__.constructor.apply(this, arguments);
    }

    PrimaryScreenAnalysisController.prototype.template = _.template($("#PrimaryScreenAnalysisView").html());

    PrimaryScreenAnalysisController.prototype.initialize = function() {
      this.model.on("saveSuccess", this.handleExperimentSaved);
      this.model.on('statusChanged', this.handleStatusChanged);
      this.model.on('changeProtocolParams', this.handleAnalysisParamsChanged);
      this.dataAnalysisController = null;
      $(this.el).empty();
      $(this.el).html(this.template());
      if (this.model.isNew()) {
        return this.setExperimentNotSaved();
      } else {
        this.setExperimentSaved();
        this.setupDataAnalysisController(this.options.uploadAndRunControllerName);
        return this.checkForSourceFile();
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
      if (dryRunStatus === "running") {
        if (analysisStatus === "running") {
          return this.showWarningStatus(dryRunStatus, analysisStatus);
        } else {
          statusId = this.model.getDryRunStatus().get('id');
          this.trigger("dryRunRunning");
          return this.checkStatus(statusId, "dryRun");
        }
      } else if (analysisStatus === "running") {
        if (dryRunStatus === "not started") {
          return this.showWarningStatus(dryRunStatus, analysisStatus);
        } else {
          statusId = this.model.getAnalysisStatus().get('id');
          this.trigger('analysisRunning');
          return this.checkStatus(statusId, "analysis");
        }
      } else if (analysisStatus === "complete" || analysisStatus === "failed") {
        return this.showAnalysisResults(analysisStatus);
      } else {
        if (dryRunStatus === "not started") {
          return this.showUploadWrapper();
        } else {
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
              statusValue = new Value(json);
              status = statusValue.get('codeValue');
              if (status === "running") {
                setTimeout(_this.checkStatus, 5000, statusId, analysisStep);
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
                return _this.showUpdatedModel(function() {
                  return _this.showUpdatedStatus(analysisStep);
                });
              }
            }
          };
        })(this)
      });
    };

    PrimaryScreenAnalysisController.prototype.showUpdatedModel = function(callback) {
      return $.ajax({
        type: 'GET',
        url: "/api/experiments/codename/" + this.model.get('codeName'),
        dataType: 'json',
        error: function(err) {
          return alert('Could not get experiment for codeName of the model');
        },
        success: (function(_this) {
          return function(json) {
            var exp;
            if (json.length === 0) {
              return alert('Could not get experiment for codeName of the model');
            } else {
              exp = new PrimaryScreenExperiment(json);
              exp.set(exp.parse(exp.attributes));
              _this.model = exp;
              _this.dataAnalysisController.updateAnalysisParamModel(_this.model);
              return callback.call();
            }
          };
        })(this)
      });
    };

    PrimaryScreenAnalysisController.prototype.showUpdatedStatus = function(analysisStep) {
      if (analysisStep === "dryRun") {
        this.trigger("dryRunDone");
        return this.showDryRunResults(this.model.getDryRunStatus().get('codeValue'));
      } else {
        this.trigger("analysisDone");
        return this.showAnalysisResults(this.model.getAnalysisStatus().get('codeValue'));
      }
    };

    PrimaryScreenAnalysisController.prototype.showAnalysisResults = function(analysisStatus) {
      var resultHTML, resultStatus;
      if (analysisStatus === "complete") {
        resultStatus = "Upload Results: Success";
      } else {
        resultStatus = "Upload Results: Failed due to errors";
      }
      resultHTML = this.model.getAnalysisResultHTML().get('clobValue');
      if (this.dataAnalysisController != null) {
        this.dataAnalysisController.showFileUploadCompletePhase();
        this.dataAnalysisController.disableAllInputs();
      }
      this.$('.bv_resultStatus').html(resultStatus);
      return this.$('.bv_htmlSummary').html(resultHTML);
    };

    PrimaryScreenAnalysisController.prototype.showDryRunResults = function(dryRunStatus) {
      var resultHTML, resultStatus;
      resultHTML = this.model.getDryRunResultHTML().get('clobValue');
      if (this.dataAnalysisController != null) {
        this.dataAnalysisController.parseFileUploaded = true;
        this.dataAnalysisController.filePassedValidation = true;
        this.dataAnalysisController.showFileUploadPhase();
        this.dataAnalysisController.handleFormValid();
        this.dataAnalysisController.disableAllInputs();
      }
      if (dryRunStatus === "complete") {
        resultStatus = "Dry Run Results: Success";
      } else {
        resultStatus = "Dry Run Results: Failed";
        this.$('.bv_save').attr('disabled', 'disabled');
        this.$('.bv_save').prop('disabled', true);
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
      this.setExperimentSaved();
      if (this.dataAnalysisController == null) {
        return this.setupDataAnalysisController(this.options.uploadAndRunControllerName);
      }
    };

    PrimaryScreenAnalysisController.prototype.handleAnalysisComplete = function() {
      this.$('.bv_resultsContainer').hide();
      return this.trigger('analysis-completed');
    };

    PrimaryScreenAnalysisController.prototype.handleStatusChanged = function() {
      if (this.dataAnalysisController !== null) {
        if (this.model.isEditable()) {
          return this.dataAnalysisController.enableFields();
        } else {
          this.dataAnalysisController.disableAll();
          this.$('.bv_loadAnother').attr('disabled', 'disabled');
          return this.$('.bv_loadAnother').prop('disabled', true);
        }
      }
    };

    PrimaryScreenAnalysisController.prototype.handleAnalysisParamsChanged = function() {
      if (this.dataAnalysisController != null) {
        this.dataAnalysisController.undelegateEvents();
      }
      this.setupDataAnalysisController(this.options.uploadAndRunControllerName);
      this.setExperimentNotSaved();
      return this.$('.bv_saveExperimentToAnalyze').html("Analysis parameters have changed. To analyze data, save the experiment first.");
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
      return this.dataAnalysisController.on('amClean', (function(_this) {
        return function() {
          return _this.trigger('amClean');
        };
      })(this));
    };

    PrimaryScreenAnalysisController.prototype.checkForSourceFile = function() {
      var sourceFile, sourceFileValue;
      console.log("check for source file");
      sourceFile = this.model.getSourceFile();
      if (sourceFile != null) {
        console.log(sourceFile.get('fileValue'));
        sourceFileValue = sourceFile.get('fileValue');
        this.dataAnalysisController.$('.bv_fileChooserContainer').html('<div style="margin-top:5px;"><a style="margin-left:20px;" href="' + window.conf.datafiles.downloadurl.prefix + sourceFileValue + '">' + sourceFileValue + '</a><button type="button" class="btn btn-danger bv_deleteSavedSourceFile pull-right" style="margin-bottom:20px;margin-right:20px;">Delete</button></div>');
        this.dataAnalysisController.handleParseFileUploaded(sourceFile.get('fileValue'));
        return this.dataAnalysisController.$('.bv_deleteSavedSourceFile').on('click', (function(_this) {
          return function() {
            _this.dataAnalysisController.parseFileController.render();
            return _this.dataAnalysisController.handleParseFileRemoved();
          };
        })(this));
      }
    };

    return PrimaryScreenAnalysisController;

  })(Backbone.View);

  window.AbstractPrimaryScreenExperimentController = (function(superClass) {
    extend(AbstractPrimaryScreenExperimentController, superClass);

    function AbstractPrimaryScreenExperimentController() {
      this.updateModelFitTab = bind(this.updateModelFitTab, this);
      this.fetchModel = bind(this.fetchModel, this);
      this.reinitialize = bind(this.reinitialize, this);
      this.handleStatusChanged = bind(this.handleStatusChanged, this);
      this.handleProtocolAttributesCopied = bind(this.handleProtocolAttributesCopied, this);
      this.handleExperimentSaved = bind(this.handleExperimentSaved, this);
      this.completeInitialization = bind(this.completeInitialization, this);
      return AbstractPrimaryScreenExperimentController.__super__.constructor.apply(this, arguments);
    }

    AbstractPrimaryScreenExperimentController.prototype.template = _.template($("#PrimaryScreenExperimentView").html());

    AbstractPrimaryScreenExperimentController.prototype.initialize = function() {
      if (this.model != null) {
        return this.completeInitialization();
      } else {
        if (window.AppLaunchParams.moduleLaunchParams != null) {
          if (window.AppLaunchParams.moduleLaunchParams.moduleName === this.moduleLaunchName) {
            if (window.AppLaunchParams.moduleLaunchParams.createFromOtherEntity) {
              this.createExperimentFromProtocol(window.AppLaunchParams.moduleLaunchParams.code);
              return this.completeInitialization();
            } else {
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
                      lsKind = json.lsKind;
                      if (lsKind === "Bio Activity") {
                        exp = new PrimaryScreenExperiment(json);
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
            }
          } else {
            return this.completeInitialization();
          }
        } else {
          return this.completeInitialization();
        }
      }
    };

    AbstractPrimaryScreenExperimentController.prototype.createExperimentFromProtocol = function(code) {
      this.model = new PrimaryScreenExperiment();
      this.model.set({
        protocol: new PrimaryScreenProtocol({
          codeName: code
        })
      });
      this.setupExperimentBaseController();
      return this.experimentBaseController.getAndSetProtocol(code, true);
    };

    AbstractPrimaryScreenExperimentController.prototype.completeInitialization = function() {
      if (this.model == null) {
        this.model = new PrimaryScreenExperiment();
      }
      $(this.el).html(this.template());
      this.setupExperimentBaseController();
      this.model.on('sync', this.handleExperimentSaved);
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
          return _this.fetchModel();
        };
      })(this));
      this.model.on("protocol_attributes_copied", this.handleProtocolAttributesCopied);
      this.model.on('statusChanged', this.handleStatusChanged);
      this.experimentBaseController.render();
      this.analysisController.render();
      this.modelFitController.render();
      return this.$('.bv_cancel').attr('disabled', 'disabled');
    };

    AbstractPrimaryScreenExperimentController.prototype.setupExperimentBaseController = function() {
      if (this.experimentBaseController != null) {
        this.experimentBaseController.remove();
      }
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
      return this.experimentBaseController.on('reinitialize', this.reinitialize);
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
      if (this.model.get('subclass') == null) {
        this.model.set({
          subclass: 'experiment'
        });
      }
      return this.analysisController.render();
    };

    AbstractPrimaryScreenExperimentController.prototype.handleProtocolAttributesCopied = function() {
      return this.analysisController.render();
    };

    AbstractPrimaryScreenExperimentController.prototype.handleStatusChanged = function() {
      this.analysisController.handleStatusChanged();
      return this.modelFitController.handleModelStatusChanged();
    };

    AbstractPrimaryScreenExperimentController.prototype.showWarningModal = function() {
      var analysisResult, analysisStatus, dryRunResult, dryRunStatus;
      this.$('a[href="#tab3"]').tab('show');
      dryRunStatus = this.model.getDryRunStatus().get('codeValue');
      dryRunResult = this.model.getDryRunResultHTML().get('clobValue');
      analysisStatus = this.model.getAnalysisStatus().get('codeValue');
      analysisResult = this.model.getAnalysisResultHTML().get('clobValue');
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
      this.$('a[href="#tab3"]').tab('show');
      this.$('.bv_validateStatusDropDown').modal({
        backdrop: "static"
      });
      return this.$('.bv_validateStatusDropDown').modal("show");
    };

    AbstractPrimaryScreenExperimentController.prototype.showSaveProgressBar = function() {
      this.$('a[href="#tab3"]').tab('show');
      this.$('.bv_saveStatusDropDown').modal({
        backdrop: "static"
      });
      return this.$('.bv_saveStatusDropDown').modal("show");
    };

    AbstractPrimaryScreenExperimentController.prototype.hideValidateProgressBar = function() {
      return this.$('.bv_validateStatusDropDown').modal("hide");
    };

    AbstractPrimaryScreenExperimentController.prototype.hideSaveProgressBar = function() {
      return this.$('.bv_saveStatusDropDown').modal("hide");
    };

    AbstractPrimaryScreenExperimentController.prototype.reinitialize = function() {
      this.model = null;
      return this.completeInitialization();
    };

    AbstractPrimaryScreenExperimentController.prototype.fetchModel = function() {
      return $.ajax({
        type: 'GET',
        url: "/api/experiments/codeName/" + this.model.get('codeName'),
        success: (function(_this) {
          return function(json) {
            _this.model = new PrimaryScreenExperiment(json);
            return _this.updateModelFitTab();
          };
        })(this),
        error: (function(_this) {
          return function(err) {
            return alert('Could not get experiment with this codeName');
          };
        })(this),
        dataType: 'json'
      });
    };

    AbstractPrimaryScreenExperimentController.prototype.updateModelFitTab = function() {
      this.modelFitController.model = this.model;
      this.modelFitController.testReadyForFit();
      this.$('.bv_resultsContainer').hide();
      return this.modelFitController.render();
    };

    return AbstractPrimaryScreenExperimentController;

  })(Backbone.View);

  window.PrimaryScreenExperimentController = (function(superClass) {
    extend(PrimaryScreenExperimentController, superClass);

    function PrimaryScreenExperimentController() {
      return PrimaryScreenExperimentController.__super__.constructor.apply(this, arguments);
    }

    PrimaryScreenExperimentController.prototype.uploadAndRunControllerName = "UploadAndRunPrimaryAnalsysisController";

    PrimaryScreenExperimentController.prototype.modelFitControllerName = "DoseResponseAnalysisController";

    PrimaryScreenExperimentController.prototype.protocolKindFilter = "?protocolKind=Bio Activity";

    PrimaryScreenExperimentController.prototype.moduleLaunchName = "primary_screen_experiment";

    return PrimaryScreenExperimentController;

  })(AbstractPrimaryScreenExperimentController);

}).call(this);
