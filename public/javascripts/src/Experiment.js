(function() {
  var _ref, _ref1, _ref2,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.Experiment = (function(_super) {
    __extends(Experiment, _super);

    function Experiment() {
      this.fixCompositeClasses = __bind(this.fixCompositeClasses, this);
      this.parse = __bind(this.parse, this);
      _ref = Experiment.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Experiment.prototype.urlRoot = "/api/experiments";

    Experiment.prototype.defaults = {
      lsType: "default",
      lsKind: "default",
      recordedBy: "",
      recordedDate: null,
      shortDescription: "",
      lsLabels: new LabelList(),
      lsStates: new StateList(),
      protocol: null,
      analysisGroups: new AnalysisGroupList()
    };

    Experiment.prototype.initialize = function() {
      this.fixCompositeClasses();
      return this.setupCompositeChangeTriggers();
    };

    Experiment.prototype.parse = function(resp) {
      var _this = this;
      if (resp.lsLabels != null) {
        if (!(resp.lsLabels instanceof LabelList)) {
          resp.lsLabels = new LabelList(resp.lsLabels);
          resp.lsLabels.on('change', function() {
            return _this.trigger('change');
          });
        }
      }
      if (resp.lsStates != null) {
        if (!(resp.lsStates instanceof StateList)) {
          resp.lsStates = new StateList(resp.lsStates);
          resp.lsStates.on('change', function() {
            return _this.trigger('change');
          });
        }
      }
      if (resp.analysisGroups != null) {
        if (!(resp.analysisGroups instanceof AnalysisGroupList)) {
          resp.analysisGroups = new AnalysisGroupList(resp.analysisGroups);
        }
      }
      if (resp.protocol != null) {
        if (!(resp.protocol instanceof Protocol)) {
          resp.protocol = new Protocol(resp.protocol);
        }
      }
      return resp;
    };

    Experiment.prototype.fixCompositeClasses = function() {
      if (this.has('lsLabels')) {
        if (!(this.get('lsLabels') instanceof LabelList)) {
          this.set({
            lsLabels: new LabelList(this.get('lsLabels'))
          });
        }
      }
      if (this.has('lsStates')) {
        if (!(this.get('lsStates') instanceof StateList)) {
          this.set({
            lsStates: new StateList(this.get('lsStates'))
          });
        }
      }
      if (this.has('analysisGroups')) {
        if (!(this.get('analysisGroups') instanceof AnalysisGroupList)) {
          this.set({
            analysisGroups: new AnalysisGroupList(this.get('analysisGroups'))
          });
        }
      }
      if (this.get('protocol') !== null) {
        if (!(this.get('protocol') instanceof Backbone.Model)) {
          return this.set({
            protocol: new Protocol(this.get('protocol'))
          });
        }
      }
    };

    Experiment.prototype.setupCompositeChangeTriggers = function() {
      var _this = this;
      this.get('lsLabels').on('change', function() {
        return _this.trigger('change');
      });
      return this.get('lsStates').on('change', function() {
        return _this.trigger('change');
      });
    };

    Experiment.prototype.copyProtocolAttributes = function(protocol) {
      var estates, pstates;
      estates = new StateList();
      pstates = protocol.get('lsStates');
      pstates.each(function(st) {
        var estate, evals, svals;
        estate = new State(_.clone(st.attributes));
        estate.unset('id');
        estate.unset('lsTransaction');
        estate.unset('lsValues');
        evals = new ValueList();
        svals = st.get('lsValues');
        svals.each(function(sv) {
          var evalue;
          if (!(sv.get('lsKind') === "notebook" || sv.get('lsKind') === "project")) {
            evalue = new Value(sv.attributes);
            evalue.unset('id');
            evalue.unset('lsTransaction');
            return evals.add(evalue);
          }
        });
        estate.set({
          lsValues: evals
        });
        return estates.add(estate);
      });
      this.set({
        kind: protocol.get('lsKind'),
        protocol: protocol,
        shortDescription: protocol.get('shortDescription'),
        lsStates: estates
      });
      this.trigger("protocol_attributes_copied");
    };

    Experiment.prototype.validate = function(attrs) {
      var bestName, errors, nameError, notebook, projectCode;
      errors = [];
      bestName = attrs.lsLabels.pickBestName();
      nameError = false;
      if (bestName != null) {
        nameError = true;
        if (bestName.get('labelText') !== "") {
          nameError = false;
        }
      }
      if (nameError) {
        errors.push({
          attribute: 'experimentName',
          message: "Experiment name must be set"
        });
      }
      if (_.isNaN(attrs.recordedDate)) {
        errors.push({
          attribute: 'recordedDate',
          message: "Experiment date must be set"
        });
      }
      if (attrs.recordedBy === "") {
        errors.push({
          attribute: 'recordedBy',
          message: "Scientist must be set"
        });
      }
      if (attrs.protocol === null) {
        errors.push({
          attribute: 'protocol',
          message: "Protocol must be set"
        });
      }
      notebook = this.getNotebook().get('stringValue');
      if (notebook === "" || notebook === "unassigned" || notebook === void 0) {
        errors.push({
          attribute: 'notebook',
          message: "Notebook must be set"
        });
      }
      projectCode = this.getProjectCode().get('codeValue');
      if (projectCode === "" || projectCode === "unassigned" || projectCode === void 0) {
        errors.push({
          attribute: 'projectCode',
          message: "Project must be set"
        });
      }
      if (errors.length > 0) {
        return errors;
      } else {
        return null;
      }
    };

    Experiment.prototype.getDescription = function() {
      return this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "experiment metadata", "stringValue", "description");
    };

    Experiment.prototype.getNotebook = function() {
      return this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "experiment metadata", "stringValue", "notebook");
    };

    Experiment.prototype.getProjectCode = function() {
      var projectCodeValue;
      projectCodeValue = this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "experiment metadata", "codeValue", "project");
      if (projectCodeValue.get('codeValue') === void 0 || projectCodeValue.get('codeValue') === "") {
        projectCodeValue.set({
          codeValue: "unassigned"
        });
      }
      return projectCodeValue;
    };

    Experiment.prototype.getControlStates = function() {
      return this.get('lsStates').getStatesByTypeAndKind("metadata", "experiment controls");
    };

    Experiment.prototype.getControlType = function(type) {
      var controls, matched;
      controls = this.getControlStates();
      matched = controls.filter(function(cont) {
        var vals;
        vals = cont.getValuesByTypeAndKind("stringValue", "control type");
        return vals[0].get('stringValue') === type;
      });
      return matched;
    };

    return Experiment;

  })(Backbone.Model);

  window.ExperimentList = (function(_super) {
    __extends(ExperimentList, _super);

    function ExperimentList() {
      _ref1 = ExperimentList.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    ExperimentList.prototype.model = Experiment;

    return ExperimentList;

  })(Backbone.Collection);

  window.ExperimentBaseController = (function(_super) {
    __extends(ExperimentBaseController, _super);

    function ExperimentBaseController() {
      this.handleUseProtocolParametersClicked = __bind(this.handleUseProtocolParametersClicked, this);
      this.handleProtocolCodeChanged = __bind(this.handleProtocolCodeChanged, this);
      this.handleRecordDateIconClicked = __bind(this.handleRecordDateIconClicked, this);
      this.handleDateChanged = __bind(this.handleDateChanged, this);
      this.handleNameChanged = __bind(this.handleNameChanged, this);
      this.handleDescriptionChanged = __bind(this.handleDescriptionChanged, this);
      this.handleShortDescriptionChanged = __bind(this.handleShortDescriptionChanged, this);
      this.handleRecordedByChanged = __bind(this.handleRecordedByChanged, this);
      this.render = __bind(this.render, this);
      _ref2 = ExperimentBaseController.__super__.constructor.apply(this, arguments);
      return _ref2;
    }

    ExperimentBaseController.prototype.template = _.template($("#ExperimentBaseView").html());

    ExperimentBaseController.prototype.events = {
      "change .bv_recordedBy": "handleRecordedByChanged",
      "change .bv_shortDescription": "handleShortDescriptionChanged",
      "change .bv_description": "handleDescriptionChanged",
      "change .bv_experimentName": "handleNameChanged",
      "change .bv_recordedDate": "handleDateChanged",
      "click .bv_useProtocolParameters": "handleUseProtocolParametersClicked",
      "change .bv_protocolCode": "handleProtocolCodeChanged",
      "click .bv_recordDateIcon": "handleRecordDateIconClicked"
    };

    ExperimentBaseController.prototype.initialize = function() {
      this.model.on('sync', this.render);
      this.errorOwnerName = 'ExperimentBaseController';
      this.setBindings();
      $(this.el).empty();
      $(this.el).html(this.template());
      this.setupProtocolSelect();
      return this.setupProjectSelect();
    };

    ExperimentBaseController.prototype.render = function() {
      var bestName, date;
      if (this.model.get('protocol') !== null) {
        this.$('.bv_protocolCode').val(this.model.get('protocol').get('codeName'));
      }
      this.$('.bv_projectCode').val(this.model.getProjectCode().get('codeValue'));
      this.$('.bv_shortDescription').html(this.model.get('shortDescription'));
      this.$('.bv_description').html(this.model.get('description'));
      bestName = this.model.get('lsLabels').pickBestName();
      if (bestName != null) {
        this.$('.bv_experimentName').val(bestName.get('labelText'));
      }
      this.$('.bv_recordedBy').val(this.model.get('recordedBy'));
      this.$('.bv_experimentCode').html(this.model.get('codeName'));
      this.getAndShowProtocolName();
      this.setUseProtocolParametersDisabledState();
      this.$('.bv_recordedDate').datepicker();
      this.$('.bv_recordedDate').datepicker("option", "dateFormat", "yy-mm-dd");
      if (this.model.get('recordedDate') !== null) {
        date = new Date(this.model.get('recordedDate'));
        this.$('.bv_recordedDate').val(date.getFullYear() + '-' + date.getMonth() + '-' + date.getDate());
      }
      this.$('.bv_description').html(this.model.getDescription().get('stringValue'));
      this.$('.bv_notebook').val(this.model.getNotebook().get('stringValue'));
      return this;
    };

    ExperimentBaseController.prototype.setupProtocolSelect = function() {
      var protocolCode;
      if (this.model.get('protocol') !== null) {
        protocolCode = this.model.get('protocol').get('codeName');
      } else {
        protocolCode = "unassigned";
      }
      this.protocolList = new PickListList();
      this.protocolList.url = "/api/protocolCodes/filter/FLIPR";
      return this.protocolListController = new PickListSelectController({
        el: this.$('.bv_protocolCode'),
        collection: this.protocolList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select Protocol"
        }),
        selectedCode: protocolCode
      });
    };

    ExperimentBaseController.prototype.setupProjectSelect = function() {
      this.projectList = new PickListList();
      this.projectList.url = "/api/projects";
      return this.projectListController = new PickListSelectController({
        el: this.$('.bv_projectCode'),
        collection: this.projectList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select Project"
        }),
        selectedCode: this.model.getProjectCode().get('codeValue')
      });
    };

    ExperimentBaseController.prototype.setUseProtocolParametersDisabledState = function() {
      if ((!this.model.isNew()) || (this.model.get('protocol') === null) || (this.$('.bv_protocolCode').val() === "")) {
        return this.$('.bv_useProtocolParameters').attr("disabled", "disabled");
      } else {
        return this.$('.bv_useProtocolParameters').removeAttr("disabled");
      }
    };

    ExperimentBaseController.prototype.getAndShowProtocolName = function() {
      var _this = this;
      if (this.model.get('protocol') !== null) {
        if (this.model.get('protocol').isStub()) {
          return this.model.get('protocol').fetch({
            success: function() {
              var newProtName;
              newProtName = _this.model.get('protocol').get('lsLabels').pickBestLabel().get('labelText');
              _this.updateProtocolNameField(newProtName);
              return _this.setUseProtocolParametersDisabledState();
            }
          });
        } else {
          this.updateProtocolNameField(this.model.get('protocol').get('lsLabels').pickBestLabel().get('labelText'));
          return this.setUseProtocolParametersDisabledState();
        }
      } else {
        return this.updateProtocolNameField("no protocol selected yet");
      }
    };

    ExperimentBaseController.prototype.updateProtocolNameField = function(protocolName) {
      return this.$('.bv_protocolName').html(protocolName);
    };

    ExperimentBaseController.prototype.handleRecordedByChanged = function() {
      this.model.set({
        recordedBy: this.$('.bv_recordedBy').val()
      });
      return this.handleNameChanged();
    };

    ExperimentBaseController.prototype.handleShortDescriptionChanged = function() {
      return this.model.set({
        shortDescription: this.getTrimmedInput('.bv_shortDescription')
      });
    };

    ExperimentBaseController.prototype.handleDescriptionChanged = function() {
      return this.model.getDescription().set({
        stringValue: $.trim(this.$('.bv_description').val()),
        recordedBy: this.model.get('recordedBy')
      });
    };

    ExperimentBaseController.prototype.handleNameChanged = function() {
      var newName;
      newName = this.getTrimmedInput('.bv_experimentName');
      return this.model.get('lsLabels').setBestName(new Label({
        labelKind: "experiment name",
        labelText: newName,
        recordedBy: this.model.get('recordedBy'),
        recordedDate: this.model.get('recordedDate')
      }));
    };

    ExperimentBaseController.prototype.handleDateChanged = function() {
      this.model.set({
        recordedDate: this.convertYMDDateToMs(this.getTrimmedInput('.bv_recordedDate'))
      });
      return this.handleNameChanged();
    };

    ExperimentBaseController.prototype.handleRecordDateIconClicked = function() {
      return $(".bv_recordedDate").datepicker("show");
    };

    ExperimentBaseController.prototype.handleProtocolCodeChanged = function() {
      var code,
        _this = this;
      code = this.$('.bv_protocolCode').val();
      if (code === "" || code === "unassigned") {
        this.model.set({
          'protocol': null
        });
        this.getAndShowProtocolName();
        return this.setUseProtocolParametersDisabledState();
      } else {
        return $.ajax({
          type: 'GET',
          url: "/api/protocols/codename/" + code,
          success: function(json) {
            if (json.length === 0) {
              return _this.updateProtocolNameField("could not find selected protocol in database");
            } else {
              _this.model.set({
                protocol: new Protocol(json[0])
              });
              return _this.getAndShowProtocolName();
            }
          },
          error: function(err) {
            return alert('got ajax error from api/protocols/codename/ in Exeriment.coffee');
          },
          dataType: 'json'
        });
      }
    };

    ExperimentBaseController.prototype.handleUseProtocolParametersClicked = function() {
      this.model.copyProtocolAttributes(this.model.get('protocol'));
      return this.render();
    };

    return ExperimentBaseController;

  })(AbstractFormController);

}).call(this);
