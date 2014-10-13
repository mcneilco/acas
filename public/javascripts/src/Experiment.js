(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.Experiment = (function(_super) {
    __extends(Experiment, _super);

    function Experiment() {
      this.fixCompositeClasses = __bind(this.fixCompositeClasses, this);
      this.parse = __bind(this.parse, this);
      return Experiment.__super__.constructor.apply(this, arguments);
    }

    Experiment.prototype.urlRoot = "/api/experiments";

    Experiment.prototype.defaults = function() {
      return _(Experiment.__super__.defaults.call(this)).extend({
        protocol: null,
        analysisGroups: new AnalysisGroupList()
      });
    };

    Experiment.prototype.initialize = function() {
      this.set({
        subclass: "experiment"
      });
      return Experiment.__super__.initialize.call(this);
    };

    Experiment.prototype.parse = function(resp) {
      if (resp.lsLabels != null) {
        if (!(resp.lsLabels instanceof LabelList)) {
          resp.lsLabels = new LabelList(resp.lsLabels);
          resp.lsLabels.on('change', (function(_this) {
            return function() {
              return _this.trigger('change');
            };
          })(this));
        }
      }
      if (resp.lsStates != null) {
        if (!(resp.lsStates instanceof StateList)) {
          resp.lsStates = new StateList(resp.lsStates);
          resp.lsStates.on('change', (function(_this) {
            return function() {
              return _this.trigger('change');
            };
          })(this));
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
      if (!(resp.lsTags instanceof TagList)) {
        resp.lsTags = new TagList(resp.lsTags);
        resp.lsTags.on('change', (function(_this) {
          return function() {
            return _this.trigger('change');
          };
        })(this));
      }
      return resp;
    };

    Experiment.prototype.fixCompositeClasses = function() {
      Experiment.__super__.fixCompositeClasses.call(this);
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

    Experiment.prototype.copyProtocolAttributes = function(protocol) {
      var completionDate, estates, notebook, project, pstates;
      notebook = this.getNotebook().get('stringValue');
      completionDate = this.getCompletionDate().get('dateValue');
      project = this.getProjectCode().get('codeValue');
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
          if (!(sv.get('lsKind') === "notebook" || sv.get('lsKind') === "project" || sv.get('lsKind') === "completion date")) {
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
        lsKind: protocol.get('lsKind'),
        protocol: protocol,
        shortDescription: protocol.get('shortDescription'),
        lsStates: estates
      });
      this.getNotebook().set({
        stringValue: notebook
      });
      this.getCompletionDate().set({
        dateValue: completionDate
      });
      this.getProjectCode().set({
        codeValue: project
      });
      this.setupCompositeChangeTriggers();
      this.trigger('change');
      this.trigger("protocol_attributes_copied");
    };

    Experiment.prototype.validate = function(attrs) {
      var bestName, cDate, errors, nameError, notebook, projectCode;
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
          attribute: 'protocolCode',
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
      if (errors.length > 0) {
        return errors;
      } else {
        return null;
      }
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

    Experiment.prototype.getAnalysisStatus = function() {
      var metadataKind, status;
      metadataKind = this.get('subclass') + " metadata";
      status = this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", metadataKind, "stringValue", "analysis status");
      if (status.get('stringValue') === void 0 || status.get('stringValue') === "") {
        status.set({
          stringValue: "created"
        });
      }
      return status;
    };

    return Experiment;

  })(BaseEntity);

  window.ExperimentList = (function(_super) {
    __extends(ExperimentList, _super);

    function ExperimentList() {
      return ExperimentList.__super__.constructor.apply(this, arguments);
    }

    ExperimentList.prototype.model = Experiment;

    return ExperimentList;

  })(Backbone.Collection);

  window.ExperimentBaseController = (function(_super) {
    __extends(ExperimentBaseController, _super);

    function ExperimentBaseController() {
      this.displayInReadOnlyMode = __bind(this.displayInReadOnlyMode, this);
      this.updateEditable = __bind(this.updateEditable, this);
      this.handleUseProtocolParametersClicked = __bind(this.handleUseProtocolParametersClicked, this);
      this.handleProjectCodeChanged = __bind(this.handleProjectCodeChanged, this);
      this.handleProtocolCodeChanged = __bind(this.handleProtocolCodeChanged, this);
      this.render = __bind(this.render, this);
      return ExperimentBaseController.__super__.constructor.apply(this, arguments);
    }

    ExperimentBaseController.prototype.template = _.template($("#ExperimentBaseView").html());

    ExperimentBaseController.prototype.events = function() {
      return _(ExperimentBaseController.__super__.events.call(this)).extend({
        "change .bv_experimentName": "handleNameChanged",
        "click .bv_useProtocolParameters": "handleUseProtocolParametersClicked",
        "change .bv_protocolCode": "handleProtocolCodeChanged",
        "change .bv_projectCode": "handleProjectCodeChanged"
      });
    };

    ExperimentBaseController.prototype.initialize = function() {
      ExperimentBaseController.__super__.initialize.call(this);
      this.errorOwnerName = 'ExperimentBaseController';
      this.setBindings();
      this.setupProtocolSelect(this.options.protocolFilter);
      return this.setupProjectSelect();
    };

    ExperimentBaseController.prototype.render = function() {
      if (this.model.get('protocol') !== null) {
        this.$('.bv_protocolCode').val(this.model.get('protocol').get('codeName'));
      }
      this.$('.bv_projectCode').val(this.model.getProjectCode().get('codeValue'));
      this.setUseProtocolParametersDisabledState();
      ExperimentBaseController.__super__.render.call(this);
      return this;
    };

    ExperimentBaseController.prototype.setupProtocolSelect = function(protocolFilter) {
      var protocolCode, protocolKindFilter;
      if (typeof protocolKindFilter === "undefined" || protocolKindFilter === null) {
        protocolKindFilter = "";
      }
      if (this.model.get('protocol') !== null) {
        protocolCode = this.model.get('protocol').get('codeName');
      } else {
        protocolCode = "unassigned";
      }
      this.protocolList = new PickListList();
      this.protocolList.url = "/api/protocolCodes/" + protocolFilter;
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

    ExperimentBaseController.prototype.setupStatusSelect = function() {
      this.statusList = new PickListList();
      this.statusList.url = "/api/dataDict/experimentMetadata/experiment status";
      return this.statusListController = new PickListSelectController({
        el: this.$('.bv_status'),
        collection: this.statusList,
        selectedCode: this.model.getStatus().get('stringValue')
      });
    };

    ExperimentBaseController.prototype.setupTagList = function() {
      this.$('.bv_tags').val("");
      this.tagListController = new TagListController({
        el: this.$('.bv_tags'),
        collection: this.model.get('lsTags')
      });
      return this.tagListController.render();
    };

    ExperimentBaseController.prototype.setUseProtocolParametersDisabledState = function() {
      if ((!this.model.isNew()) || (this.model.get('protocol') === null) || (this.protocolListController.getSelectedCode() === "")) {
        return this.$('.bv_useProtocolParameters').attr("disabled", "disabled");
      } else {
        return this.$('.bv_useProtocolParameters').removeAttr("disabled");
      }
    };

    ExperimentBaseController.prototype.getFullProtocol = function() {
      if (this.model.get('protocol') !== null) {
        if (this.model.get('protocol').isStub()) {
          return this.model.get('protocol').fetch({
            success: (function(_this) {
              return function() {
                var newProtName;
                newProtName = _this.model.get('protocol').get('lsLabels').pickBestLabel().get('labelText');
                _this.setUseProtocolParametersDisabledState();
                if (!!_this.model.isNew()) {
                  return _this.handleUseProtocolParametersClicked();
                }
              };
            })(this)
          });
        } else {
          this.setUseProtocolParametersDisabledState();
          if (!!this.model.isNew()) {
            return this.handleUseProtocolParametersClicked();
          }
        }
      }
    };

    ExperimentBaseController.prototype.handleProtocolCodeChanged = function() {
      var code;
      code = this.protocolListController.getSelectedCode();
      if (code === "" || code === "unassigned") {
        this.model.set({
          'protocol': null
        });
        return this.setUseProtocolParametersDisabledState();
      } else {
        return $.ajax({
          type: 'GET',
          url: "/api/protocols/codename/" + code,
          success: (function(_this) {
            return function(json) {
              if (json.length === 0) {
                return alert("Could not find selected protocol in database, please get help");
              } else {
                _this.model.set({
                  protocol: new Protocol(json[0])
                });
                return _this.getFullProtocol();
              }
            };
          })(this),
          error: function(err) {
            return alert('got ajax error from api/protocols/codename/ in Exeriment.coffee');
          },
          dataType: 'json'
        });
      }
    };

    ExperimentBaseController.prototype.handleProjectCodeChanged = function() {
      return this.model.getProjectCode().set({
        codeValue: this.projectListController.getSelectedCode()
      });
    };

    ExperimentBaseController.prototype.handleUseProtocolParametersClicked = function() {
      this.model.copyProtocolAttributes(this.model.get('protocol'));
      return this.render();
    };

    ExperimentBaseController.prototype.updateEditable = function() {
      ExperimentBaseController.__super__.updateEditable.call(this);
      if (this.model.isNew()) {
        return this.$('.bv_protocolCode').removeAttr("disabled");
      } else {
        return this.$('.bv_protocolCode').attr("disabled", "disabled");
      }
    };

    ExperimentBaseController.prototype.displayInReadOnlyMode = function() {
      this.$(".bv_save").addClass("hide");
      return this.disableAllInputs();
    };

    return ExperimentBaseController;

  })(BaseEntityController);

}).call(this);
