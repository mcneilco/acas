(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.PrimaryAnalysisRead = (function(_super) {
    __extends(PrimaryAnalysisRead, _super);

    function PrimaryAnalysisRead() {
      this.triggerAmDirty = __bind(this.triggerAmDirty, this);
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
      if (_.isNaN(attrs.readPosition) || attrs.readPosition === "") {
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
      this.fixCompositeClasses = __bind(this.fixCompositeClasses, this);
      return PrimaryScreenAnalysisParameters.__super__.constructor.apply(this, arguments);
    }

    PrimaryScreenAnalysisParameters.prototype.defaults = {
      instrumentReader: "unassigned",
      signalDirectionRule: "unassigned",
      aggregateBy1: "unassigned",
      aggregateBy2: "unassigned",
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
      thresholdType: "sd",
      volumeType: "dilution",
      htsFormat: false,
      autoHitSelection: false,
      matchReadName: true,
      primaryAnalysisReadList: new PrimaryAnalysisReadList(),
      transformationRuleList: new TransformationRuleList()
    };

    PrimaryScreenAnalysisParameters.prototype.initialize = function() {
      return this.fixCompositeClasses();
    };

    PrimaryScreenAnalysisParameters.prototype.fixCompositeClasses = function() {
      if (!(this.get('positiveControl') instanceof Backbone.Model)) {
        this.set({
          positiveControl: new Backbone.Model(this.get('positiveControl'))
        });
      }
      this.get('positiveControl').on("change", (function(_this) {
        return function() {
          return _this.trigger('change');
        };
      })(this));
      if (!(this.get('negativeControl') instanceof Backbone.Model)) {
        this.set({
          negativeControl: new Backbone.Model(this.get('negativeControl'))
        });
      }
      this.get('negativeControl').on("change", (function(_this) {
        return function() {
          return _this.trigger('change');
        };
      })(this));
      if (!(this.get('vehicleControl') instanceof Backbone.Model)) {
        this.set({
          vehicleControl: new Backbone.Model(this.get('vehicleControl'))
        });
      }
      this.get('vehicleControl').on("change", (function(_this) {
        return function() {
          return _this.trigger('change');
        };
      })(this));
      if (!(this.get('agonistControl') instanceof Backbone.Model)) {
        this.set({
          agonistControl: new Backbone.Model(this.get('agonistControl'))
        });
      }
      this.get('agonistControl').on("change", (function(_this) {
        return function() {
          return _this.trigger('change');
        };
      })(this));
      if (!(this.get('primaryAnalysisReadList') instanceof PrimaryAnalysisReadList)) {
        this.set({
          primaryAnalysisReadList: new PrimaryAnalysisReadList(this.get('primaryAnalysisReadList'))
        });
      }
      this.get('primaryAnalysisReadList').on("change", (function(_this) {
        return function() {
          return _this.trigger('change');
        };
      })(this));
      this.get('primaryAnalysisReadList').on("amDirty", (function(_this) {
        return function() {
          return _this.trigger('amDirty');
        };
      })(this));
      if (!(this.get('transformationRuleList') instanceof TransformationRuleList)) {
        this.set({
          transformationRuleList: new TransformationRuleList(this.get('transformationRuleList'))
        });
      }
      this.get('transformationRuleList').on("change", (function(_this) {
        return function() {
          return _this.trigger('change');
        };
      })(this));
      return this.get('transformationRuleList').on("amDirty", (function(_this) {
        return function() {
          return _this.trigger('amDirty');
        };
      })(this));
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
          message: "Positive control batch must be set"
        });
      }
      positiveControlConc = this.get('positiveControl').get('concentration');
      if (_.isNaN(positiveControlConc) || positiveControlConc === void 0) {
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
      if (_.isNaN(negativeControlConc) || negativeControlConc === void 0) {
        errors.push({
          attribute: 'negativeControlConc',
          message: "Negative control conc must be set"
        });
      }
      agonistControl = this.get('agonistControl').get('batchCode');
      agonistControlConc = this.get('agonistControl').get('concentration');
      if (agonistControl !== "" || agonistControlConc !== "") {
        if (agonistControl === "" || agonistControl === void 0) {
          errors.push({
            attribute: 'agonistControlBatch',
            message: "Agonist control batch must be set"
          });
        }
        if (_.isNaN(agonistControlConc) || agonistControlConc === void 0 || agonistControlConc === "") {
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
      if (attrs.aggregateBy1 === "unassigned" || attrs.aggregateBy1 === "") {
        errors.push({
          attribute: 'aggregateBy1',
          message: "Aggregate By1 must be assigned"
        });
      }
      if (attrs.aggregateBy2 === "unassigned" || attrs.aggregateBy2 === "") {
        errors.push({
          attribute: 'aggregateBy2',
          message: "Aggregate By2 must be assigned"
        });
      }
      if (attrs.normalizationRule === "unassigned" || attrs.normalizationRule === "") {
        errors.push({
          attribute: 'normalizationRule',
          message: "Normalization rule must be assigned"
        });
      }
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

    PrimaryScreenExperiment.prototype.getAnalysisParameters = function() {
      var ap;
      ap = this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "experiment metadata", "clobValue", "data analysis parameters");
      if (ap.get('clobValue') != null) {
        return new PrimaryScreenAnalysisParameters($.parseJSON(ap.get('clobValue')));
      } else {
        return new PrimaryScreenAnalysisParameters();
      }
    };

    PrimaryScreenExperiment.prototype.getModelFitParameters = function() {
      var ap;
      ap = this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "experiment metadata", "clobValue", "model fit parameters");
      if (ap.get('clobValue') != null) {
        return $.parseJSON(ap.get('clobValue'));
      } else {
        return {};
      }
    };

    PrimaryScreenExperiment.prototype.getAnalysisStatus = function() {
      var status;
      status = this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "experiment metadata", "stringValue", "analysis status");
      if (!status.has('stringValue')) {
        status.set({
          stringValue: "not started"
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
      status = this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "experiment metadata", "stringValue", "model fit status");
      if (!status.has('stringValue')) {
        status.set({
          stringValue: "not started"
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
      this.readNameList.url = "/api/dataDict/experimentMetadata/read name";
      return this.readNameList = new PickListSelectController({
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
        readPosition: parseInt(this.getTrimmedInput('.bv_readPosition')),
        readName: this.$('.bv_readName').val(),
        activity: activity
      });
      return this.model.triggerAmDirty();
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
        transformationRule: this.$('.bv_transformationRule').val()
      });
      return this.model.triggerAmDirty();
    };

    TransformationRuleController.prototype.setUpTransformationRuleSelect = function() {
      this.transformationList = new PickListList();
      this.transformationList.url = "/api/dataDict/experimentMetadata/transformation";
      return this.transformationList = new PickListSelectController({
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
        this.addNewRead();
      }
      this.checkActivity();
      return this;
    };

    PrimaryAnalysisReadListController.prototype.addNewRead = function() {
      var newModel;
      newModel = new PrimaryAnalysisRead();
      this.collection.add(newModel);
      this.addOneRead(newModel);
      if (this.collection.length === 1) {
        this.checkActivity();
      }
      return newModel.triggerAmDirty();
    };

    PrimaryAnalysisReadListController.prototype.addOneRead = function(read) {
      var parc;
      parc = new PrimaryAnalysisReadController({
        model: read
      });
      this.$('.bv_readInfo').append(parc.render().el);
      return parc.setUpReadPosition(this.matchReadNameChecked);
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
          this.$('.bv_activity:eq(0)').click();
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
        this.addNewRule();
      }
      return this;
    };

    TransformationRuleListController.prototype.addNewRule = function() {
      var newModel;
      newModel = new TransformationRule();
      this.collection.add(newModel);
      this.addOneRule(newModel);
      return newModel.triggerAmDirty();
    };

    TransformationRuleListController.prototype.addOneRule = function(rule) {
      var trc;
      trc = new TransformationRuleController({
        model: rule
      });
      return this.$('.bv_transformationInfo').append(trc.render().el);
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
      "change .bv_aggregateBy1": "attributeChanged",
      "change .bv_aggregateBy2": "attributeChanged",
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
      this.setupAggregateBy1Select();
      this.setupAggregateBy2Select();
      return this.setupNormalizationSelect();
    };

    PrimaryScreenAnalysisParametersController.prototype.render = function() {
      this.$('.bv_autofillSection').empty();
      this.$('.bv_autofillSection').html(this.autofillTemplate(this.model.attributes));
      this.setupInstrumentReaderSelect();
      this.setupSignalDirectionSelect();
      this.setupAggregateBy1Select();
      this.setupAggregateBy2Select();
      this.setupNormalizationSelect();
      this.handleAutoHitSelectionChanged();
      this.setupReadListController();
      this.setupTransformationRuleListController();
      this.handleMatchReadNameChanged();
      this.$("[data-toggle=tooltip]").tooltip();
      return this;
    };

    PrimaryScreenAnalysisParametersController.prototype.setupInstrumentReaderSelect = function() {
      this.instrumentList = new PickListList();
      this.instrumentList.url = "/api/dataDict/experimentMetadata/instrument reader";
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
      this.signalDirectionList.url = "/api/dataDict/experimentMetadata/signal direction";
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

    PrimaryScreenAnalysisParametersController.prototype.setupAggregateBy1Select = function() {
      this.aggregateBy1List = new PickListList();
      this.aggregateBy1List.url = "/api/dataDict/experimentMetadata/aggregate by1";
      return this.aggregateBy1ListController = new PickListSelectController({
        el: this.$('.bv_aggregateBy1'),
        collection: this.aggregateBy1List,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select"
        }),
        selectedCode: this.model.get('aggregateBy1')
      });
    };

    PrimaryScreenAnalysisParametersController.prototype.setupAggregateBy2Select = function() {
      this.aggregateBy2List = new PickListList();
      this.aggregateBy2List.url = "/api/dataDict/experimentMetadata/aggregate by2";
      return this.aggregateBy2ListController = new PickListSelectController({
        el: this.$('.bv_aggregateBy2'),
        collection: this.aggregateBy2List,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select"
        }),
        selectedCode: this.model.get('aggregateBy2')
      });
    };

    PrimaryScreenAnalysisParametersController.prototype.setupNormalizationSelect = function() {
      this.normalizationList = new PickListList();
      this.normalizationList.url = "/api/dataDict/experimentMetadata/normalization";
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
      return this.readListController.render();
    };

    PrimaryScreenAnalysisParametersController.prototype.setupTransformationRuleListController = function() {
      this.transformationRuleListController = new TransformationRuleListController({
        el: this.$('.bv_transformationList'),
        collection: this.model.get('transformationRuleList')
      });
      return this.transformationRuleListController.render();
    };

    PrimaryScreenAnalysisParametersController.prototype.updateModel = function() {
      var htsFormat;
      htsFormat = this.$('.bv_htsFormat').is(":checked");
      this.model.set({
        instrumentReader: this.$('.bv_instrumentReader').val(),
        signalDirectionRule: this.$('.bv_signalDirectionRule').val(),
        aggregateBy1: this.$('.bv_aggregateBy1').val(),
        aggregateBy2: this.$('.bv_aggregateBy2').val(),
        normalizationRule: this.$('.bv_normalizationRule').val(),
        hitEfficacyThreshold: parseFloat(this.getTrimmedInput('.bv_hitEfficacyThreshold')),
        hitSDThreshold: parseFloat(this.getTrimmedInput('.bv_hitSDThreshold')),
        assayVolume: this.getTrimmedInput('.bv_assayVolume'),
        transferVolume: this.getTrimmedInput('.bv_transferVolume'),
        dilutionFactor: this.getTrimmedInput('.bv_dilutionFactor'),
        htsFormat: htsFormat
      });
      if (this.model.get('assayVolume') !== "") {
        this.model.set({
          assayVolume: parseFloat(this.getTrimmedInput('.bv_assayVolume'))
        });
      }
      if (this.model.get('transferVolume') !== "") {
        this.model.set({
          transferVolume: parseFloat(this.getTrimmedInput('.bv_transferVolume'))
        });
      }
      if (this.model.get('dilutionFactor') !== "") {
        this.model.set({
          dilutionFactor: parseFloat(this.getTrimmedInput('.bv_dilutionFactor'))
        });
      }
      this.model.get('positiveControl').set({
        batchCode: this.getTrimmedInput('.bv_positiveControlBatch'),
        concentration: parseFloat(this.getTrimmedInput('.bv_positiveControlConc'))
      });
      this.model.get('negativeControl').set({
        batchCode: this.getTrimmedInput('.bv_negativeControlBatch'),
        concentration: parseFloat(this.getTrimmedInput('.bv_negativeControlConc'))
      });
      this.model.get('vehicleControl').set({
        batchCode: this.getTrimmedInput('.bv_vehicleControlBatch'),
        concentration: null
      });
      this.model.get('agonistControl').set({
        batchCode: this.getTrimmedInput('.bv_agonistControlBatch'),
        concentration: this.getTrimmedInput('.bv_agonistControlConc')
      });
      if (this.model.get('agonistControl').get('concentration') !== "") {
        return this.model.get('agonistControl').set({
          concentration: parseFloat(this.getTrimmedInput('.bv_agonistControlConc'))
        });
      }
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

    PrimaryScreenAnalysisParametersController.prototype.handleAutoHitSelectionChanged = function() {
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
      return this.attributeChanged();
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

    PrimaryScreenAnalysisParametersController.prototype.handleMatchReadNameChanged = function() {
      var matchReadName;
      matchReadName = this.$('.bv_matchReadName').is(":checked");
      this.model.set({
        matchReadName: matchReadName
      });
      this.readListController.matchReadNameChanged(matchReadName);
      return this.attributeChanged();
    };

    return PrimaryScreenAnalysisParametersController;

  })(AbstractParserFormController);

  window.AbstractUploadAndRunPrimaryAnalsysisController = (function(_super) {
    __extends(AbstractUploadAndRunPrimaryAnalsysisController, _super);

    function AbstractUploadAndRunPrimaryAnalsysisController() {
      this.validateParseFile = __bind(this.validateParseFile, this);
      this.handleSaveReturnSuccess = __bind(this.handleSaveReturnSuccess, this);
      this.handleValidationReturnSuccess = __bind(this.handleValidationReturnSuccess, this);
      this.parseAndSave = __bind(this.parseAndSave, this);
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
        this.$('.bv_save').html("Re-Analyze");
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

    AbstractUploadAndRunPrimaryAnalsysisController.prototype.parseAndSave = function() {
      if (this.analyzedPreviously) {
        if (!confirm("Re-analyzing the data will delete the previously saved results")) {
          return;
        }
      }
      return AbstractUploadAndRunPrimaryAnalsysisController.__super__.parseAndSave.call(this);
    };

    AbstractUploadAndRunPrimaryAnalsysisController.prototype.handleValidationReturnSuccess = function(json) {
      AbstractUploadAndRunPrimaryAnalsysisController.__super__.handleValidationReturnSuccess.call(this, json);
      return this.analysisParameterController.disableAllInputs();
    };

    AbstractUploadAndRunPrimaryAnalsysisController.prototype.handleSaveReturnSuccess = function(json) {
      AbstractUploadAndRunPrimaryAnalsysisController.__super__.handleSaveReturnSuccess.call(this, json);
      this.$('.bv_loadAnother').html("Re-Analyze");
      return this.trigger('analysis-completed');
    };

    AbstractUploadAndRunPrimaryAnalsysisController.prototype.showFileSelectPhase = function() {
      AbstractUploadAndRunPrimaryAnalsysisController.__super__.showFileSelectPhase.call(this);
      if (this.analysisParameterController != null) {
        return this.analysisParameterController.enableAllInputs();
      }
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
      this.$('.bv_moduleTitle').html("Upload Data and Analyze");
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
        this.setupDataAnalysisController(this.options.uploadAndRunControllerName);
        return this.setExperimentSaved();
      }
    };

    PrimaryScreenAnalysisController.prototype.render = function() {
      return this.showExistingResults();
    };

    PrimaryScreenAnalysisController.prototype.showExistingResults = function() {
      var analysisStatus, res, resultValue;
      analysisStatus = this.model.getAnalysisStatus();
      if (analysisStatus !== null) {
        analysisStatus = analysisStatus.get('stringValue');
      } else {
        analysisStatus = "not started";
      }
      this.$('.bv_analysisStatus').html(analysisStatus);
      resultValue = this.model.getAnalysisResultHTML();
      if (resultValue !== null) {
        res = resultValue.get('clobValue');
        if (res === "") {
          return this.$('.bv_resultsContainer').hide();
        } else {
          this.$('.bv_analysisResultsHTML').html(res);
          return this.$('.bv_resultsContainer').show();
        }
      }
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
      if (this.dataAnalysisController == null) {
        this.setupDataAnalysisController(this.options.uploadAndRunControllerName);
      }
      this.model.getStatus().on('change', this.handleStatusChanged);
      return this.setExperimentSaved();
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
        analyzedPreviously: this.model.getAnalysisStatus().get('stringValue') !== "not started"
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
                  var exp;
                  if (json.length === 0) {
                    alert('Could not get experiment for code in this URL, creating new one');
                  } else {
                    exp = new PrimaryScreenExperiment(json);
                    exp.fixCompositeClasses();
                    _this.model = exp;
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
        protocolFilter: this.protocolFilter
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
      this.model.on("protocol_attributes_copied", this.handleProtocolAttributesCopied);
      this.experimentBaseController.render();
      return this.analysisController.render();
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

    PrimaryScreenExperimentController.prototype.moduleLaunchName = "flipr_screening_assay";

    return PrimaryScreenExperimentController;

  })(AbstractPrimaryScreenExperimentController);

}).call(this);
