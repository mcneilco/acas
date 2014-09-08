(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.Protocol = (function(_super) {
    __extends(Protocol, _super);

    function Protocol() {
      return Protocol.__super__.constructor.apply(this, arguments);
    }

    Protocol.prototype.urlRoot = "/api/protocols";

    Protocol.prototype.defaults = function() {
      return _(Protocol.__super__.defaults.call(this)).extend({
        assayTreeRule: null,
        dnsTargetList: false,
        assayActivity: "unassigned",
        molecularTarget: "unassigned",
        targetOrigin: "unassigned",
        assayType: "unassigned",
        assayTechnology: "unassigned",
        cellLine: "unassigned",
        assayStage: "unassigned",
        maxY: 100,
        minY: 0
      });
    };

    Protocol.prototype.initialize = function() {
      this.set({
        subclass: "protocol"
      });
      return Protocol.__super__.initialize.call(this);
    };

    Protocol.prototype.validate = function(attrs) {
      var bestName, cDate, errors, nameError, notebook;
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
      if (_.isNaN(attrs.maxY)) {
        errors.push({
          attribute: 'maxY',
          message: "maxY must be a number"
        });
      }
      if (_.isNaN(attrs.minY)) {
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

    Protocol.prototype.isStub = function() {
      return this.get('lsLabels').length === 0;
    };

    return Protocol;

  })(BaseEntity);

  window.ProtocolList = (function(_super) {
    __extends(ProtocolList, _super);

    function ProtocolList() {
      return ProtocolList.__super__.constructor.apply(this, arguments);
    }

    ProtocolList.prototype.model = Protocol;

    return ProtocolList;

  })(Backbone.Collection);

  window.ProtocolBaseController = (function(_super) {
    __extends(ProtocolBaseController, _super);

    function ProtocolBaseController() {
      this.handleTargetListChanged = __bind(this.handleTargetListChanged, this);
      this.updateModel = __bind(this.updateModel, this);
      this.render = __bind(this.render, this);
      return ProtocolBaseController.__super__.constructor.apply(this, arguments);
    }

    ProtocolBaseController.prototype.template = _.template($("#ProtocolBaseView").html());

    ProtocolBaseController.prototype.events = function() {
      return _(ProtocolBaseController.__super__.events.call(this)).extend({
        "change .bv_protocolName": "handleNameChanged",
        "change .bv_assayTreeRule": "attributeChanged",
        "click .bv_dnsTargetList": "handleTargetListChanged",
        "change .bv_assayActivity": "attributeChanged",
        "click .bv_addNewAssayActivity": "addNewAssayActivity",
        "change .bv_molecularTarget": "attributeChanged",
        "click .bv_addNewMolecularTarget": "addNewMolecularTarget",
        "change .bv_targetOrigin": "attributeChanged",
        "click .bv_addNewTargetOrigin": "addNewTargetOrigin",
        "change .bv_assayType": "attributeChanged",
        "click .bv_addNewAssayType": "addNewAssayType",
        "change .bv_assayTechnology": "attributeChanged",
        "click .bv_addNewAssayTechnology": "addNewAssayTechnology",
        "change .bv_cellLine": "attributeChanged",
        "click .bv_addNewCellLine": "addNewCellLine",
        "change .bv_assayStage": "attributeChanged",
        "change .bv_maxY": "attributeChanged",
        "change .bv_minY": "attributeChanged"
      });
    };

    ProtocolBaseController.prototype.initialize = function() {
      if (this.model == null) {
        this.model = new Protocol();
      }
      this.model.on('sync', (function(_this) {
        return function() {
          _this.trigger('amClean');
          _this.$('.bv_saving').hide();
          _this.$('.bv_updateComplete').show();
          return _this.render();
        };
      })(this));
      this.model.on('change', (function(_this) {
        return function() {
          _this.trigger('amDirty');
          return _this.$('.bv_updateComplete').hide();
        };
      })(this));
      this.errorOwnerName = 'ProtocolBaseController';
      this.setBindings();
      $(this.el).empty();
      $(this.el).html(this.template(this.model.attributes));
      this.$('.bv_save').attr('disabled', 'disabled');
      this.setupStatusSelect();
      this.setupTagList();
      this.model.getStatus().on('change', this.updateEditable);
      this.setUpAssayActivitySelect();
      this.setUpMolecularTargetSelect();
      this.setUpTargetOriginSelect();
      this.setUpAssayTypeSelect();
      this.setUpAssayTechnologySelect();
      this.setUpCellLineSelect();
      return this.setUpAssayStageSelect();
    };

    ProtocolBaseController.prototype.render = function() {
      this.$('.bv_assayTreeRule').val(this.model.get('assayTreeRule'));
      this.$('.bv_dnsTargetList').val(this.model.get('dnsTargetList'));
      this.$('.bv_maxY').val(this.model.get('maxY'));
      this.$('.bv_minY').val(this.model.get('minY'));
      this.setUpAssayActivitySelect();
      this.setUpMolecularTargetSelect();
      this.setUpTargetOriginSelect();
      this.setUpAssayTypeSelect();
      this.setUpAssayTechnologySelect();
      this.setUpCellLineSelect();
      this.setUpAssayStageSelect();
      this.handleTargetListChanged();
      ProtocolBaseController.__super__.render.call(this);
      return this;
    };

    ProtocolBaseController.prototype.setUpAssayActivitySelect = function() {
      this.assayActivityList = new PickListList();
      this.assayActivityList.url = "/api/dataDict/assayActivityCodes";
      return this.assayActivityList = new PickListSelectController({
        el: this.$('.bv_assayActivity'),
        collection: this.assayActivityList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select Assay Activity"
        }),
        selectedCode: this.model.get('assayActivity')
      });
    };

    ProtocolBaseController.prototype.setUpMolecularTargetSelect = function() {
      this.molecularTargetList = new PickListList();
      this.molecularTargetList.url = "/api/dataDict/molecularTargetCodes";
      return this.molecularTargetList = new PickListSelectController({
        el: this.$('.bv_molecularTarget'),
        collection: this.molecularTargetList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select Molecular Target"
        }),
        selectedCode: this.model.get('molecularTarget')
      });
    };

    ProtocolBaseController.prototype.setUpTargetOriginSelect = function() {
      this.targetOriginList = new PickListList();
      this.targetOriginList.url = "/api/dataDict/targetOriginCodes";
      return this.targetOriginList = new PickListSelectController({
        el: this.$('.bv_targetOrigin'),
        collection: this.targetOriginList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select Target Origin"
        }),
        selectedCode: this.model.get('targetOrigin')
      });
    };

    ProtocolBaseController.prototype.setUpAssayTypeSelect = function() {
      this.assayTypeList = new PickListList();
      this.assayTypeList.url = "/api/dataDict/assayTypeCodes";
      return this.assayTypeList = new PickListSelectController({
        el: this.$('.bv_assayType'),
        collection: this.assayTypeList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select Assay Type"
        }),
        selectedCode: this.model.get('assayType')
      });
    };

    ProtocolBaseController.prototype.setUpAssayTechnologySelect = function() {
      this.assayTechnologyList = new PickListList();
      this.assayTechnologyList.url = "/api/dataDict/assayTechnologyCodes";
      return this.assayTechnologyList = new PickListSelectController({
        el: this.$('.bv_assayTechnology'),
        collection: this.assayTechnologyList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select Assay Technology"
        }),
        selectedCode: this.model.get('assayTechnology')
      });
    };

    ProtocolBaseController.prototype.setUpCellLineSelect = function() {
      this.cellLineList = new PickListList();
      this.cellLineList.url = "/api/dataDict/cellLineCodes";
      return this.cellLineList = new PickListSelectController({
        el: this.$('.bv_cellLine'),
        collection: this.cellLineList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select Cell Line"
        }),
        selectedCode: this.model.get('cellLine')
      });
    };

    ProtocolBaseController.prototype.setUpAssayStageSelect = function() {
      this.assayStageList = new PickListList();
      this.assayStageList.url = "/api/dataDict/assayStageCodes";
      return this.assayStageListController = new PickListSelectController({
        el: this.$('.bv_assayStage'),
        collection: this.assayStageList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select assay stage"
        }),
        selectedCode: this.model.get('assayStage')
      });
    };

    ProtocolBaseController.prototype.updateModel = function() {
      return this.model.set({
        assayTreeRule: this.getTrimmedInput('.bv_assayTreeRule'),
        assayActivity: this.$('.bv_assayActivity').val(),
        molecularTarget: this.$('.bv_molecularTarget').val(),
        targetOrigin: this.$('.bv_targetOrigin').val(),
        assayType: this.$('.bv_assayType').val(),
        assayTechnology: this.$('.bv_assayTechnology').val(),
        cellLine: this.$('.bv_cellLine').val(),
        assayStage: this.$('.bv_assayStage').val(),
        maxY: parseFloat(this.getTrimmedInput('.bv_maxY')),
        minY: parseFloat(this.getTrimmedInput('.bv_minY'))
      });
    };

    ProtocolBaseController.prototype.handleTargetListChanged = function() {
      var dnsTargetList;
      dnsTargetList = this.$('.bv_dnsTargetList').is(":checked");
      this.model.set({
        dnsTargetList: dnsTargetList
      });
      if (dnsTargetList) {
        this.$('.bv_molecularTargetModal').hide();
      } else {
        this.$('.bv_molecularTargetModal').show();
      }
      return this.attributeChanged();
    };

    ProtocolBaseController.prototype.addNewAssayActivity = function() {
      var parameter, pascalCaseParameterName;
      console.log("add new activity clicked");
      parameter = 'assayActivity';
      pascalCaseParameterName = 'AssayActivity';
      return this.addNewParameter(parameter, pascalCaseParameterName);
    };

    ProtocolBaseController.prototype.addNewMolecularTarget = function() {
      var parameter, pascalCaseParameterName;
      console.log("add new activity clicked");
      parameter = 'molecularTarget';
      pascalCaseParameterName = 'MolecularTarget';
      return this.addNewParameter(parameter, pascalCaseParameterName);
    };

    ProtocolBaseController.prototype.addNewTargetOrigin = function() {
      var parameter, pascalCaseParameterName;
      console.log("add new target origin clicked");
      parameter = 'targetOrigin';
      pascalCaseParameterName = 'TargetOrigin';
      return this.addNewParameter(parameter, pascalCaseParameterName);
    };

    ProtocolBaseController.prototype.addNewParameter = function(parameter, pascalCaseParameterName) {
      var newOptionName;
      console.log("add new parameter clicked");
      console.log(pascalCaseParameterName);
      newOptionName = this.$('.bv_new' + pascalCaseParameterName).val();
      console.log(newOptionName);
      if (this.validNewOption(newOptionName, parameter)) {
        console.log("will add new option");
        this.$('.bv_' + parameter).append('<option value=' + newOptionName + '>' + newOptionName + '</option>');
        this.$('#add' + pascalCaseParameterName + 'Modal').modal('hide');
      } else {
        console.log("option already exists");
      }
      this.$('.bv_new' + pascalCaseParameterName).val("");
      this.$('.bv_new' + pascalCaseParameterName + 'Description').val("");
      return this.$('.bv_new' + pascalCaseParameterName + 'Comments').val("");
    };

    ProtocolBaseController.prototype.validNewOption = function(newOptionName, parameter) {
      console.log("validating new option");
      console.log(newOptionName);
      console.log(this.$('.bv_' + parameter + ' option[value=' + newOptionName + ']').length > 0);
      if (this.$('.bv_' + parameter + ' option[value=' + newOptionName + ']').length > 0) {
        return false;
      } else {
        return true;
      }
    };

    return ProtocolBaseController;

  })(BaseEntityController);

}).call(this);
