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

    Experiment.prototype.defaults = {
      lsType: "default",
      lsKind: "default",
      recordedBy: "",
      recordedDate: new Date().getTime(),
      shortDescription: " ",
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
          this.set({
            protocol: new Protocol(this.get('protocol'))
          });
        }
      }
      if (this.get('lsTags') !== null) {
        if (!(this.get('lsTags') instanceof TagList)) {
          return this.set({
            lsTags: new TagList(this.get('lsTags'))
          });
        }
      }
    };

    Experiment.prototype.setupCompositeChangeTriggers = function() {
      this.get('lsLabels').on('change', (function(_this) {
        return function() {
          return _this.trigger('change');
        };
      })(this));
      this.get('lsStates').on('change', (function(_this) {
        return function() {
          return _this.trigger('change');
        };
      })(this));
      return this.get('lsTags').on('change', (function(_this) {
        return function() {
          return _this.trigger('change');
        };
      })(this));
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
        kind: protocol.get('lsKind'),
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
      }
      if (errors.length > 0) {
        return errors;
      } else {
        return null;
      }
    };

    Experiment.prototype.prepareToSave = function() {
      var rBy, rDate;
      rBy = this.get('recordedBy');
      rDate = new Date().getTime();
      this.set({
        recordedDate: rDate
      });
      this.get('lsLabels').each(function(lab) {
        if (lab.get('recordedBy') === "") {
          lab.set({
            recordedBy: rBy
          });
        }
        if (lab.get('recordedDate') === null) {
          return lab.set({
            recordedDate: rDate
          });
        }
      });
      return this.get('lsStates').each(function(state) {
        if (state.get('recordedBy') === "") {
          state.set({
            recordedBy: rBy
          });
        }
        if (state.get('recordedDate') === null) {
          state.set({
            recordedDate: rDate
          });
        }
        return state.get('lsValues').each(function(val) {
          if (val.get('recordedBy') === "") {
            val.set({
              recordedBy: rBy
            });
          }
          if (val.get('recordedDate') === null) {
            return val.set({
              recordedDate: rDate
            });
          }
        });
      });
    };

    Experiment.prototype.getDescription = function() {
      var description;
      description = this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "experiment metadata", "clobValue", "description");
      if (description.get('clobValue') === void 0 || description.get('clobValue') === "") {
        description.set({
          clobValue: ""
        });
      }
      return description;
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

    Experiment.prototype.getCompletionDate = function() {
      return this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "experiment metadata", "dateValue", "completion date");
    };

    Experiment.prototype.getStatus = function() {
      var status;
      status = this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "experiment metadata", "stringValue", "status");
      if (status.get('stringValue') === void 0 || status.get('stringValue') === "") {
        status.set({
          stringValue: "Created"
        });
      }
      return status;
    };

    Experiment.prototype.getAnalysisStatus = function() {
      var status;
      status = this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "experiment metadata", "stringValue", "analysis status");
      if (status.get('stringValue') === void 0 || status.get('stringValue') === "") {
        status.set({
          stringValue: "Created"
        });
      }
      return status;
    };

    Experiment.prototype.isEditable = function() {
      var status;
      status = this.getStatus().get('stringValue');
      switch (status) {
        case "Created":
          return true;
        case "Started":
          return true;
        case "Complete":
          return true;
        case "Finalized":
          return false;
        case "Rejected":
          return false;
      }
      return true;
    };

    return Experiment;

  })(Backbone.Model);

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
      this.clearValidationErrorStyles = __bind(this.clearValidationErrorStyles, this);
      this.validationError = __bind(this.validationError, this);
      this.handleSaveClicked = __bind(this.handleSaveClicked, this);
      this.displayInReadOnlyMode = __bind(this.displayInReadOnlyMode, this);
      this.updateEditable = __bind(this.updateEditable, this);
      this.handleStatusChanged = __bind(this.handleStatusChanged, this);
      this.handleUseProtocolParametersClicked = __bind(this.handleUseProtocolParametersClicked, this);
      this.handleNotebookChanged = __bind(this.handleNotebookChanged, this);
      this.handleProjectCodeChanged = __bind(this.handleProjectCodeChanged, this);
      this.handleProtocolCodeChanged = __bind(this.handleProtocolCodeChanged, this);
      this.handleCompletionDateIconClicked = __bind(this.handleCompletionDateIconClicked, this);
      this.handleDateChanged = __bind(this.handleDateChanged, this);
      this.handleNameChanged = __bind(this.handleNameChanged, this);
      this.handleDescriptionChanged = __bind(this.handleDescriptionChanged, this);
      this.handleShortDescriptionChanged = __bind(this.handleShortDescriptionChanged, this);
      this.handleRecordedByChanged = __bind(this.handleRecordedByChanged, this);
      this.render = __bind(this.render, this);
      return ExperimentBaseController.__super__.constructor.apply(this, arguments);
    }

    ExperimentBaseController.prototype.template = _.template($("#ExperimentBaseView").html());

    ExperimentBaseController.prototype.events = {
      "change .bv_recordedBy": "handleRecordedByChanged",
      "change .bv_shortDescription": "handleShortDescriptionChanged",
      "change .bv_description": "handleDescriptionChanged",
      "change .bv_experimentName": "handleNameChanged",
      "change .bv_completionDate": "handleDateChanged",
      "click .bv_useProtocolParameters": "handleUseProtocolParametersClicked",
      "change .bv_protocolCode": "handleProtocolCodeChanged",
      "change .bv_projectCode": "handleProjectCodeChanged",
      "change .bv_notebook": "handleNotebookChanged",
      "change .bv_status": "handleStatusChanged",
      "click .bv_completionDateIcon": "handleCompletionDateIconClicked",
      "click .bv_save": "handleSaveClicked"
    };

    ExperimentBaseController.prototype.initialize = function() {
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
      this.errorOwnerName = 'ExperimentBaseController';
      this.setBindings();
      $(this.el).empty();
      $(this.el).html(this.template());
      this.$('.bv_save').attr('disabled', 'disabled');
      this.setupProtocolSelect(this.options.protocolFilter);
      this.setupProjectSelect();
      this.setupTagList();
      return this.model.getStatus().on('change', this.updateEditable);
    };

    ExperimentBaseController.prototype.render = function() {
      var bestName;
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
      this.setUseProtocolParametersDisabledState();
      this.$('.bv_completionDate').datepicker();
      this.$('.bv_completionDate').datepicker("option", "dateFormat", "yy-mm-dd");
      if (this.model.getCompletionDate().get('dateValue') != null) {
        this.$('.bv_completionDate').val(this.convertMSToYMDDate(this.model.getCompletionDate().get('dateValue')));
      }
      this.$('.bv_description').html(this.model.getDescription().get('clobValue'));
      this.$('.bv_notebook').val(this.model.getNotebook().get('stringValue'));
      this.$('.bv_status').val(this.model.getStatus().get('stringValue'));
      if (this.model.isNew()) {
        this.$('.bv_save').html("Save");
      } else {
        this.$('.bv_save').html("Update");
      }
      this.updateEditable();
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

    ExperimentBaseController.prototype.setupTagList = function() {
      this.$('.bv_tags').val("");
      this.tagListController = new TagListController({
        el: this.$('.bv_tags'),
        collection: this.model.get('lsTags')
      });
      return this.tagListController.render();
    };

    ExperimentBaseController.prototype.setUseProtocolParametersDisabledState = function() {
      if ((!this.model.isNew()) || (this.model.get('protocol') === null) || (this.$('.bv_protocolCode').val() === "")) {
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

    ExperimentBaseController.prototype.handleRecordedByChanged = function() {
      this.model.set({
        recordedBy: this.$('.bv_recordedBy').val()
      });
      return this.handleNameChanged();
    };

    ExperimentBaseController.prototype.handleShortDescriptionChanged = function() {
      var trimmedDesc;
      trimmedDesc = this.getTrimmedInput('.bv_shortDescription');
      if (trimmedDesc !== "") {
        return this.model.set({
          shortDescription: trimmedDesc
        });
      } else {
        return this.model.set({
          shortDescription: " "
        });
      }
    };

    ExperimentBaseController.prototype.handleDescriptionChanged = function() {
      return this.model.getDescription().set({
        clobValue: this.getTrimmedInput('.bv_description'),
        recordedBy: this.model.get('recordedBy')
      });
    };

    ExperimentBaseController.prototype.handleNameChanged = function() {
      var newName;
      newName = this.getTrimmedInput('.bv_experimentName');
      this.model.get('lsLabels').setBestName(new Label({
        lsKind: "experiment name",
        labelText: newName,
        recordedBy: this.model.get('recordedBy')
      }));
      return this.model.trigger('change');
    };

    ExperimentBaseController.prototype.handleDateChanged = function() {
      return this.model.getCompletionDate().set({
        dateValue: this.convertYMDDateToMs(this.getTrimmedInput('.bv_completionDate'))
      });
    };

    ExperimentBaseController.prototype.handleCompletionDateIconClicked = function() {
      return $(".bv_completionDate").datepicker("show");
    };

    ExperimentBaseController.prototype.handleProtocolCodeChanged = function() {
      var code;
      code = this.$('.bv_protocolCode').val();
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
        codeValue: this.$('.bv_projectCode').val()
      });
    };

    ExperimentBaseController.prototype.handleNotebookChanged = function() {
      return this.model.getNotebook().set({
        stringValue: this.getTrimmedInput('.bv_notebook')
      });
    };

    ExperimentBaseController.prototype.handleUseProtocolParametersClicked = function() {
      this.model.copyProtocolAttributes(this.model.get('protocol'));
      return this.render();
    };

    ExperimentBaseController.prototype.handleStatusChanged = function() {
      this.model.getStatus().set({
        stringValue: this.getTrimmedInput('.bv_status')
      });
      return this.updateEditable();
    };

    ExperimentBaseController.prototype.updateEditable = function() {
      if (this.model.isEditable()) {
        this.enableAllInputs();
        this.$('.bv_lock').hide();
      } else {
        this.disableAllInputs();
        this.$('.bv_status').removeAttr('disabled');
        this.$('.bv_lock').show();
      }
      if (this.model.isNew()) {
        this.$('.bv_protocolCode').removeAttr("disabled");
        return this.$('.bv_status').attr("disabled", "disabled");
      } else {
        this.$('.bv_protocolCode').attr("disabled", "disabled");
        return this.$('.bv_status').removeAttr("disabled");
      }
    };

    ExperimentBaseController.prototype.displayInReadOnlyMode = function() {
      this.$(".bv_save").addClass("hide");
      return this.disableAllInputs();
    };

    ExperimentBaseController.prototype.handleSaveClicked = function() {
      this.tagListController.handleTagsChanged();
      this.model.prepareToSave();
      if (this.model.isNew()) {
        this.$('.bv_updateComplete').html("Save Complete");
      } else {
        this.$('.bv_updateComplete').html("Update Complete");
      }
      this.$('.bv_saving').show();
      return this.model.save();
    };

    ExperimentBaseController.prototype.validationError = function() {
      ExperimentBaseController.__super__.validationError.call(this);
      return this.$('.bv_save').attr('disabled', 'disabled');
    };

    ExperimentBaseController.prototype.clearValidationErrorStyles = function() {
      ExperimentBaseController.__super__.clearValidationErrorStyles.call(this);
      return this.$('.bv_save').removeAttr('disabled');
    };

    return ExperimentBaseController;

  })(AbstractFormController);

}).call(this);
