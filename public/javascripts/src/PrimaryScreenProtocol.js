(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.PrimaryScreenProtocol = (function(_super) {
    __extends(PrimaryScreenProtocol, _super);

    function PrimaryScreenProtocol() {
      return PrimaryScreenProtocol.__super__.constructor.apply(this, arguments);
    }

    PrimaryScreenProtocol.prototype.defaults = function() {
      return _(PrimaryScreenProtocol.__super__.defaults.call(this)).extend({
        dnsList: false
      });
    };

    PrimaryScreenProtocol.prototype.initialize = function() {
      PrimaryScreenProtocol.__super__.initialize.call(this);
      return this.setdnsList();
    };

    PrimaryScreenProtocol.prototype.validate = function(attrs) {
      var bestName, cDate, errors, maxY, minY, nameError, notebook;
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
          attribute: 'protocolName',
          message: attrs.subclass + " name must be set"
        });
      }
      if (_.isNaN(attrs.recordedDate)) {
        errors.push({
          attribute: 'recordedDate',
          message: attrs.subclass + " date must be set"
        });
      }
      if (attrs.recordedBy === "") {
        errors.push({
          attribute: 'recordedBy',
          message: "Scientist must be set"
        });
      }
      cDate = this.getCompletionDate().get('dateValue');
      if (cDate === void 0 || cDate === "") {
        cDate = "fred";
      }
      if (isNaN(cDate)) {
        errors.push({
          attribute: 'completionDate',
          message: "Assay completion date must be set"
        });
      }
      notebook = this.getNotebook().get('stringValue');
      if (notebook === "" || notebook === "unassigned" || notebook === void 0) {
        errors.push({
          attribute: 'notebook',
          message: "Notebook must be set"
        });
      }
      maxY = this.getCurveDisplayMax().get('numericValue');
      if (isNaN(maxY)) {
        errors.push({
          attribute: 'maxY',
          message: "maxY must be a number"
        });
      }
      minY = this.getCurveDisplayMin().get('numericValue');
      if (isNaN(minY)) {
        errors.push({
          attribute: 'minY',
          message: "minY must be a number"
        });
      }
      if (errors.length > 0) {
        return errors;
      } else {
        return null;
      }
    };

    PrimaryScreenProtocol.prototype.getPrimaryScreenProtocolParameterCodeValue = function(parameterName) {
      var parameter;
      parameter = this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "screening assay", "codeValue", parameterName);
      if (parameter.get('codeValue') === void 0 || parameter.get('codeValue') === "") {
        parameter.set({
          codeValue: "unassigned"
        });
      }
      if (parameter.get('codeOrigin') === void 0 || parameter.get('codeOrigin') === "") {
        parameter.set({
          codeOrigin: "acas ddict"
        });
      }
      return parameter;
    };

    PrimaryScreenProtocol.prototype.setdnsList = function() {
      var molecularTarget;
      molecularTarget = this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "screening assay", "codeValue", "molecular target");
      if (molecularTarget.get('codeOrigin') === "dns target list") {
        return this.set({
          dnsList: true
        });
      } else {
        return this.set({
          dnsList: false
        });
      }
    };

    PrimaryScreenProtocol.prototype.getCurveDisplayMin = function() {
      var minY;
      minY = this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "screening assay", "numericValue", "curve display min");
      if (minY.get('numericValue') === void 0 || minY.get('numericValue') === "") {
        minY.set({
          numericValue: 0.0
        });
      }
      return minY;
    };

    PrimaryScreenProtocol.prototype.getCurveDisplayMax = function() {
      var maxY;
      maxY = this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "screening assay", "numericValue", "curve display max");
      if (maxY.get('numericValue') === void 0 || maxY.get('numericValue') === "") {
        maxY.set({
          numericValue: 100.0
        });
      }
      return maxY;
    };

    PrimaryScreenProtocol.prototype.getAnalysisParameters = function() {
      var ap;
      ap = this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "protocol metadata", "clobValue", "data analysis parameters");
      if (ap.get('clobValue') != null) {
        return new PrimaryScreenAnalysisParameters($.parseJSON(ap.get('clobValue')));
      } else {
        return new PrimaryScreenAnalysisParameters();
      }
    };

    PrimaryScreenProtocol.prototype.getModelFitParameters = function() {
      var ap;
      ap = this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "protocol metadata", "clobValue", "model fit parameters");
      if (ap.get('clobValue') != null) {
        return $.parseJSON(ap.get('clobValue'));
      } else {
        return {};
      }
    };

    PrimaryScreenProtocol.prototype.getAnalysisStatus = function() {
      var status;
      status = this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "protocol metadata", "stringValue", "analysis status");
      if (!status.has('stringValue')) {
        status.set({
          stringValue: "not started"
        });
      }
      return status;
    };

    PrimaryScreenProtocol.prototype.getAnalysisResultHTML = function() {
      var result;
      result = this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "protocol metadata", "clobValue", "analysis result html");
      if (!result.has('clobValue')) {
        result.set({
          clobValue: ""
        });
      }
      return result;
    };

    PrimaryScreenProtocol.prototype.getModelFitStatus = function() {
      var status;
      status = this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "protocol metadata", "stringValue", "model fit status");
      if (!status.has('stringValue')) {
        status.set({
          stringValue: "not started"
        });
      }
      return status;
    };

    PrimaryScreenProtocol.prototype.getModelFitResultHTML = function() {
      var result;
      result = this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "protocol metadata", "clobValue", "model fit result html");
      if (!result.has('clobValue')) {
        result.set({
          clobValue: ""
        });
      }
      return result;
    };

    return PrimaryScreenProtocol;

  })(Protocol);

  window.AbstractPrimaryScreenProtocolParameterController = (function(_super) {
    __extends(AbstractPrimaryScreenProtocolParameterController, _super);

    function AbstractPrimaryScreenProtocolParameterController() {
      return AbstractPrimaryScreenProtocolParameterController.__super__.constructor.apply(this, arguments);
    }

    AbstractPrimaryScreenProtocolParameterController.prototype.events = {
      "change .bv_parameter": "handleParameterChanged",
      "click .bv_addParameterBtn": "clearModal",
      "click .bv_addNewParameterOption": "addNewParameterOption"
    };

    AbstractPrimaryScreenProtocolParameterController.prototype.handleParameterChanged = function() {
      var splitName;
      splitName = this.parameter.replace(/([A-Z])/g, ' $1');
      splitName = splitName.toLowerCase();
      return this.model.getPrimaryScreenProtocolParameterCodeValue(splitName).set({
        codeValue: this.$('.bv_' + this.parameter).val()
      });
    };

    AbstractPrimaryScreenProtocolParameterController.prototype.clearModal = function() {
      var pascalCaseParameterName;
      pascalCaseParameterName = this.parameter.charAt(0).toUpperCase() + this.parameter.slice(1);
      this.$('.bv_optionAddedMessage').hide();
      this.$('.bv_errorMessage').hide();
      this.$('.bv_new' + pascalCaseParameterName + 'Label').val("");
      this.$('.bv_new' + pascalCaseParameterName + 'Description').val("");
      this.$('.bv_new' + pascalCaseParameterName + 'Comments').val("");
      this.$('.bv_optionAddedMessage').hide();
      return this.$('.bv_errorMessage').hide();
    };

    AbstractPrimaryScreenProtocolParameterController.prototype.addNewParameterOption = function() {
      var newOptionName, pascalCaseParameterName;
      pascalCaseParameterName = this.parameter.charAt(0).toUpperCase() + this.parameter.slice(1);
      newOptionName = (this.$('.bv_new' + pascalCaseParameterName + 'Label').val()).toLowerCase();
      if (this.validNewOption(newOptionName)) {
        this.$('.bv_' + this.parameter).append('<option value=' + newOptionName + '>' + newOptionName + '</option>');
        this.$('.bv_optionAddedMessage').show();
        return this.$('.bv_errorMessage').hide();
      } else {
        this.$('.bv_optionAddedMessage').hide();
        return this.$('.bv_errorMessage').show();
      }
    };

    AbstractPrimaryScreenProtocolParameterController.prototype.validNewOption = function(newOptionName) {
      if (this.$('.bv_' + this.parameter + ' option[value="' + newOptionName + '"]').length > 0) {
        return false;
      } else {
        return true;
      }
    };

    return AbstractPrimaryScreenProtocolParameterController;

  })(Backbone.View);

  window.AssayActivityController = (function(_super) {
    __extends(AssayActivityController, _super);

    function AssayActivityController() {
      return AssayActivityController.__super__.constructor.apply(this, arguments);
    }

    AssayActivityController.prototype.template = _.template($("#AssayActivityView").html());

    AssayActivityController.prototype.events = {
      "change .bv_assayActivity": "handleParameterChanged",
      "click .bv_addAssayActivityBtn": "clearModal",
      "click .bv_addNewAssayActivityOption": "addNewParameterOption"
    };

    AssayActivityController.prototype.initialize = function() {
      this.parameter = "assayActivity";
      return this.setupParameterSelect();
    };

    AssayActivityController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      return this.setupParameterSelect();
    };

    AssayActivityController.prototype.setupParameterSelect = function() {
      this.assayActivityList = new PickListList();
      this.assayActivityList.url = "/api/dataDict/protocolMetadata/assay activity";
      return this.assayActivityListController = new PickListSelectController({
        el: this.$('.bv_assayActivity'),
        collection: this.assayActivityList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select Assay Activity"
        }),
        selectedCode: this.model.getPrimaryScreenProtocolParameterCodeValue('assay activity').get('codeValue')
      });
    };

    return AssayActivityController;

  })(AbstractPrimaryScreenProtocolParameterController);

  window.MolecularTargetController = (function(_super) {
    __extends(MolecularTargetController, _super);

    function MolecularTargetController() {
      return MolecularTargetController.__super__.constructor.apply(this, arguments);
    }

    MolecularTargetController.prototype.template = _.template($("#MolecularTargetView").html());

    MolecularTargetController.prototype.events = {
      "change .bv_molecularTarget": "handleParameterChanged",
      "click .bv_addMolecularTargetBtn": "clearModal",
      "click .bv_addNewMolecularTargetOption": "addNewParameterOption"
    };

    MolecularTargetController.prototype.initialize = function() {
      this.parameter = "molecularTarget";
      return this.setupParameterSelect();
    };

    MolecularTargetController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      return this.setupParameterSelect();
    };

    MolecularTargetController.prototype.setupParameterSelect = function() {
      this.molecularTargetList = new PickListList();
      this.molecularTargetList.url = "/api/dataDict/protocolMetadata/molecular target";
      return this.molecularTargetListController = new PickListSelectController({
        el: this.$('.bv_molecularTarget'),
        collection: this.molecularTargetList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select Molecular Target"
        }),
        selectedCode: this.model.getPrimaryScreenProtocolParameterCodeValue('molecular target').get('codeValue')
      });
    };

    return MolecularTargetController;

  })(AbstractPrimaryScreenProtocolParameterController);

  window.TargetOriginController = (function(_super) {
    __extends(TargetOriginController, _super);

    function TargetOriginController() {
      return TargetOriginController.__super__.constructor.apply(this, arguments);
    }

    TargetOriginController.prototype.template = _.template($("#TargetOriginView").html());

    TargetOriginController.prototype.events = {
      "change .bv_targetOrigin": "handleParameterChanged",
      "click .bv_addTargetOriginBtn": "clearModal",
      "click .bv_addNewTargetOriginOption": "addNewParameterOption"
    };

    TargetOriginController.prototype.initialize = function() {
      this.parameter = "targetOrigin";
      return this.setupParameterSelect();
    };

    TargetOriginController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      return this.setupParameterSelect();
    };

    TargetOriginController.prototype.setupParameterSelect = function() {
      this.targetOriginList = new PickListList();
      this.targetOriginList.url = "/api/dataDict/protocolMetadata/target origin";
      return this.targetOriginListController = new PickListSelectController({
        el: this.$('.bv_targetOrigin'),
        collection: this.targetOriginList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select Target Origin"
        }),
        selectedCode: this.model.getPrimaryScreenProtocolParameterCodeValue('target origin').get('codeValue')
      });
    };

    return TargetOriginController;

  })(AbstractPrimaryScreenProtocolParameterController);

  window.AssayTypeController = (function(_super) {
    __extends(AssayTypeController, _super);

    function AssayTypeController() {
      return AssayTypeController.__super__.constructor.apply(this, arguments);
    }

    AssayTypeController.prototype.template = _.template($("#AssayTypeView").html());

    AssayTypeController.prototype.events = {
      "change .bv_assayType": "handleParameterChanged",
      "click .bv_addAssayTypeBtn": "clearModal",
      "click .bv_addNewAssayTypeOption": "addNewParameterOption"
    };

    AssayTypeController.prototype.initialize = function() {
      this.parameter = "assayType";
      return this.setupParameterSelect();
    };

    AssayTypeController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      return this.setupParameterSelect();
    };

    AssayTypeController.prototype.setupParameterSelect = function() {
      this.assayTypeList = new PickListList();
      this.assayTypeList.url = "/api/dataDict/protocolMetadata/assay type";
      return this.assayTypeListController = new PickListSelectController({
        el: this.$('.bv_assayType'),
        collection: this.assayTypeList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select Assay Type"
        }),
        selectedCode: this.model.getPrimaryScreenProtocolParameterCodeValue('assay type').get('codeValue')
      });
    };

    return AssayTypeController;

  })(AbstractPrimaryScreenProtocolParameterController);

  window.AssayTechnologyController = (function(_super) {
    __extends(AssayTechnologyController, _super);

    function AssayTechnologyController() {
      return AssayTechnologyController.__super__.constructor.apply(this, arguments);
    }

    AssayTechnologyController.prototype.template = _.template($("#AssayTechnologyView").html());

    AssayTechnologyController.prototype.events = {
      "change .bv_assayTechnology": "handleParameterChanged",
      "click .bv_addAssayTechnologyBtn": "clearModal",
      "click .bv_addNewAssayTechnologyOption": "addNewParameterOption"
    };

    AssayTechnologyController.prototype.initialize = function() {
      this.parameter = "assayTechnology";
      return this.setupParameterSelect();
    };

    AssayTechnologyController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      return this.setupParameterSelect();
    };

    AssayTechnologyController.prototype.setupParameterSelect = function() {
      this.assayTechnologyList = new PickListList();
      this.assayTechnologyList.url = "/api/dataDict/protocolMetadata/assay technology";
      return this.assayTechnologyListController = new PickListSelectController({
        el: this.$('.bv_assayTechnology'),
        collection: this.assayTechnologyList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select Assay Technology"
        }),
        selectedCode: this.model.getPrimaryScreenProtocolParameterCodeValue('assay technology').get('codeValue')
      });
    };

    return AssayTechnologyController;

  })(AbstractPrimaryScreenProtocolParameterController);

  window.CellLineController = (function(_super) {
    __extends(CellLineController, _super);

    function CellLineController() {
      return CellLineController.__super__.constructor.apply(this, arguments);
    }

    CellLineController.prototype.template = _.template($("#CellLineView").html());

    CellLineController.prototype.events = {
      "change .bv_cellLine": "handleParameterChanged",
      "click .bv_addCellLineBtn": "clearModal",
      "click .bv_addNewCellLineOption": "addNewParameterOption"
    };

    CellLineController.prototype.initialize = function() {
      this.parameter = "cellLine";
      return this.setupParameterSelect();
    };

    CellLineController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      return this.setupParameterSelect();
    };

    CellLineController.prototype.setupParameterSelect = function() {
      this.cellLineList = new PickListList();
      this.cellLineList.url = "/api/dataDict/protocolMetadata/cell line";
      return this.cellLineListController = new PickListSelectController({
        el: this.$('.bv_cellLine'),
        collection: this.cellLineList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select Cell Line"
        }),
        selectedCode: this.model.getPrimaryScreenProtocolParameterCodeValue('cell line').get('codeValue')
      });
    };

    return CellLineController;

  })(AbstractPrimaryScreenProtocolParameterController);

  window.PrimaryScreenProtocolParametersController = (function(_super) {
    __extends(PrimaryScreenProtocolParametersController, _super);

    function PrimaryScreenProtocolParametersController() {
      this.handleMinYChanged = __bind(this.handleMinYChanged, this);
      this.handleMaxYChanged = __bind(this.handleMaxYChanged, this);
      this.handleAssayStageChanged = __bind(this.handleAssayStageChanged, this);
      this.handleTargetListChanged = __bind(this.handleTargetListChanged, this);
      this.updateModel = __bind(this.updateModel, this);
      this.render = __bind(this.render, this);
      return PrimaryScreenProtocolParametersController.__super__.constructor.apply(this, arguments);
    }

    PrimaryScreenProtocolParametersController.prototype.template = _.template($("#PrimaryScreenProtocolParametersView").html());

    PrimaryScreenProtocolParametersController.prototype.autofillTemplate = _.template($("#PrimaryScreenProtocolParametersAutofillView").html());

    PrimaryScreenProtocolParametersController.prototype.events = {
      "click .bv_dnsTargetListChkbx": "handleTargetListChanged",
      "change .bv_assayStage": "handleAssayStageChanged",
      "change .bv_maxY": "handleMaxYChanged",
      "change .bv_minY": "handleMinYChanged"
    };

    PrimaryScreenProtocolParametersController.prototype.initialize = function() {
      this.errorOwnerName = 'PrimaryScreenProtocolParametersController';
      this.setBindings();
      PrimaryScreenProtocolParametersController.__super__.initialize.call(this);
      return this.setUpAssayStageSelect();
    };

    PrimaryScreenProtocolParametersController.prototype.render = function() {
      this.$el.empty();
      this.$el.html(this.autofillTemplate(this.model.attributes));
      this.$('.bv_dnsTargetListChkbx').val(this.model.get('dnsList'));
      this.$('.bv_maxY').val(this.model.getCurveDisplayMax().get('numericValue'));
      this.$('.bv_minY').val(this.model.getCurveDisplayMin().get('numericValue'));
      this.setUpAssayStageSelect();
      this.handleTargetListChanged();
      PrimaryScreenProtocolParametersController.__super__.render.call(this);
      return this;
    };

    PrimaryScreenProtocolParametersController.prototype.setUpAssayStageSelect = function() {
      this.assayStageList = new PickListList();
      this.assayStageList.url = "/api/dataDict/protocolMetadata/assay stage";
      return this.assayStageListController = new PickListSelectController({
        el: this.$('.bv_assayStage'),
        collection: this.assayStageList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select assay stage"
        }),
        selectedCode: this.model.getPrimaryScreenProtocolParameterCodeValue('assay stage').get('codeValue')
      });
    };

    PrimaryScreenProtocolParametersController.prototype.updateModel = function() {
      return this.model.set({
        assayStage: this.$('.bv_assayStage').val()
      });
    };

    PrimaryScreenProtocolParametersController.prototype.handleTargetListChanged = function() {
      var dnsTargetList;
      dnsTargetList = this.$('.bv_dnsTargetListChkbx').is(":checked");
      this.model.set({
        dnsList: dnsTargetList
      });
      if (dnsTargetList) {
        this.$('.bv_addMolecularTargetBtn').hide();
        this.model.getPrimaryScreenProtocolParameterCodeValue('molecular target').set({
          codeOrigin: "dns target list"
        });
      } else {
        this.$('.bv_addMolecularTargetBtn').show();
        this.model.getPrimaryScreenProtocolParameterCodeValue('molecular target').set({
          codeOrigin: "acas ddict"
        });
      }
      return this.attributeChanged();
    };

    PrimaryScreenProtocolParametersController.prototype.handleAssayStageChanged = function() {
      return this.model.getPrimaryScreenProtocolParameterCodeValue('assay stage').set({
        codeValue: this.$('.bv_assayStage').val()
      });
    };

    PrimaryScreenProtocolParametersController.prototype.handleMaxYChanged = function() {
      this.model.getCurveDisplayMax().set({
        numericValue: this.$('.bv_maxY').val()
      });
      return this.handleModelChange();
    };

    PrimaryScreenProtocolParametersController.prototype.handleMinYChanged = function() {
      this.model.getCurveDisplayMin().set({
        numericValue: this.$('.bv_minY').val()
      });
      return this.handleModelChange();
    };

    return PrimaryScreenProtocolParametersController;

  })(AbstractFormController);

  window.AbstractPrimaryScreenProtocolController = (function(_super) {
    __extends(AbstractPrimaryScreenProtocolController, _super);

    function AbstractPrimaryScreenProtocolController() {
      this.handleProtocolSaved = __bind(this.handleProtocolSaved, this);
      return AbstractPrimaryScreenProtocolController.__super__.constructor.apply(this, arguments);
    }

    AbstractPrimaryScreenProtocolController.prototype.template = _.template($("#PrimaryScreenProtocolView").html());

    AbstractPrimaryScreenProtocolController.prototype.initialize = function() {
      if (this.model != null) {
        return this.completeInitialization();
      } else {
        if (window.AppLaunchParams.moduleLaunchParams != null) {
          if (window.AppLaunchParams.moduleLaunchParams.moduleName === this.moduleLaunchName) {
            return $.ajax({
              type: 'GET',
              url: "/api/protocols/codename/" + window.AppLaunchParams.moduleLaunchParams.code,
              dataType: 'json',
              error: function(err) {
                alert('Could not get protocol for code in this URL, creating new one');
                return this.completeInitialization();
              },
              success: (function(_this) {
                return function(json) {
                  var prot;
                  if (json.length === 0) {
                    alert('Could not get protocol for code in this URL, creating new one');
                  } else {
                    prot = new PrimaryScreenProtocol(json);
                    prot.fixCompositeClasses();
                    _this.model = prot;
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

    AbstractPrimaryScreenProtocolController.prototype.completeInitialization = function() {
      if (this.model == null) {
        this.model = new PrimaryScreenProtocol();
      }
      $(this.el).html(this.template());
      this.model.on('sync', this.handleProtocolSaved);
      this.protocolBaseController = new ProtocolBaseController({
        model: this.model,
        el: this.$('.bv_protocolBase')
      });
      this.protocolBaseController.on('amDirty', (function(_this) {
        return function() {
          return _this.trigger('amDirty');
        };
      })(this));
      this.protocolBaseController.on('amClean', (function(_this) {
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
      this.setupModelFitController(this.modelFitControllerName);
      this.analysisController.on('analysis-completed', (function(_this) {
        return function() {
          return _this.modelFitController.primaryAnalysisCompleted();
        };
      })(this));
      this.protocolBaseController.render();
      this.analysisController.render();
      return this.modelFitController.render();
    };

    AbstractPrimaryScreenProtocolController.prototype.setupModelFitController = function(modelFitControllerName) {
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

    AbstractPrimaryScreenProtocolController.prototype.handleProtocolSaved = function() {
      return this.analysisController.render();
    };

    return AbstractPrimaryScreenProtocolController;

  })(Backbone.View);

  window.PrimaryScreenProtocolController = (function(_super) {
    __extends(PrimaryScreenProtocolController, _super);

    function PrimaryScreenProtocolController() {
      return PrimaryScreenProtocolController.__super__.constructor.apply(this, arguments);
    }

    PrimaryScreenProtocolController.prototype.uploadAndRunControllerName = "UploadAndRunPrimaryAnalsysisController";

    PrimaryScreenProtocolController.prototype.modelFitControllerName = "DoseResponseAnalysisController";

    PrimaryScreenProtocolController.prototype.moduleLaunchName = "primary_screen_protocol";

    PrimaryScreenProtocolController.prototype.initialize = function() {
      PrimaryScreenProtocolController.__super__.initialize.call(this);
      this.setupPrimaryScreenProtocolParametersController();
      this.setupAssayActivityController();
      this.setupMolecularTargetController();
      this.setupTargetOriginController();
      this.setupAssayTypeController();
      this.setupAssayTechnologyController();
      return this.setupCellLineController();
    };

    PrimaryScreenProtocolController.prototype.setupPrimaryScreenProtocolParametersController = function() {
      this.primaryScreenProtocolParametersController = new PrimaryScreenProtocolParametersController({
        model: this.model,
        el: this.$('.bv_autofillSection')
      });
      this.primaryScreenProtocolParametersController.on('amDirty', (function(_this) {
        return function() {
          return _this.trigger('amDirty');
        };
      })(this));
      this.primaryScreenProtocolParametersController.on('amClean', (function(_this) {
        return function() {
          return _this.trigger('amClean');
        };
      })(this));
      return this.primaryScreenProtocolParametersController.render();
    };

    PrimaryScreenProtocolController.prototype.setupAssayActivityController = function() {
      this.assayActivityController = new AssayActivityController({
        model: this.model,
        el: this.$('.bv_assayActivityWrapper')
      });
      return this.assayActivityController.render();
    };

    PrimaryScreenProtocolController.prototype.setupMolecularTargetController = function() {
      this.molecularTargetController = new MolecularTargetController({
        model: this.model,
        el: this.$('.bv_molecularTargetWrapper')
      });
      return this.molecularTargetController.render();
    };

    PrimaryScreenProtocolController.prototype.setupTargetOriginController = function() {
      this.targetOriginController = new TargetOriginController({
        model: this.model,
        el: this.$('.bv_targetOriginWrapper')
      });
      return this.targetOriginController.render();
    };

    PrimaryScreenProtocolController.prototype.setupAssayTypeController = function() {
      this.assayTypeController = new AssayTypeController({
        model: this.model,
        el: this.$('.bv_assayTypeWrapper')
      });
      return this.assayTypeController.render();
    };

    PrimaryScreenProtocolController.prototype.setupAssayTechnologyController = function() {
      this.assayTechnologyController = new AssayTechnologyController({
        model: this.model,
        el: this.$('.bv_assayTechnologyWrapper')
      });
      return this.assayTechnologyController.render();
    };

    PrimaryScreenProtocolController.prototype.setupCellLineController = function() {
      this.cellLineController = new CellLineController({
        model: this.model,
        el: this.$('.bv_cellLineWrapper')
      });
      return this.cellLineController.render();
    };

    return PrimaryScreenProtocolController;

  })(AbstractPrimaryScreenProtocolController);

}).call(this);
