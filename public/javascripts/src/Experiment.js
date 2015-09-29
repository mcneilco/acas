(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.Experiment = (function(superClass) {
    extend(Experiment, superClass);

    function Experiment() {
      this.prepareToSave = bind(this.prepareToSave, this);
      this.duplicateEntity = bind(this.duplicateEntity, this);
      this.copyProtocolAttributes = bind(this.copyProtocolAttributes, this);
      this.parse = bind(this.parse, this);
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
      Experiment.__super__.initialize.call(this);
      if (window.conf.include.project == null) {
        return console.dir("config for client.include.project is not set");
      }
    };

    Experiment.prototype.parse = function(resp) {
      if (resp === "not unique experiment name" || resp === '"not unique experiment name"') {
        this.trigger('notUniqueName');
        return resp;
      } else if (resp === "saveFailed" || resp === '"saveFailed"') {
        this.trigger('saveFailed');
        return resp;
      } else {
        if (resp.lsLabels != null) {
          if (!(resp.lsLabels instanceof LabelList)) {
            resp.lsLabels = new LabelList(resp.lsLabels);
          }
          resp.lsLabels.on('change', (function(_this) {
            return function() {
              return _this.trigger('change');
            };
          })(this));
        }
        if (resp.lsStates != null) {
          if (!(resp.lsStates instanceof StateList)) {
            resp.lsStates = new StateList(resp.lsStates);
          }
          resp.lsStates.on('change', (function(_this) {
            return function() {
              return _this.trigger('change');
            };
          })(this));
        }
        if (resp.analysisGroups != null) {
          if (!(resp.analysisGroups instanceof AnalysisGroupList)) {
            resp.analysisGroups = new AnalysisGroupList(resp.analysisGroups);
          }
          resp.analysisGroups.on('change', (function(_this) {
            return function() {
              return _this.trigger('change');
            };
          })(this));
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
      }
    };

    Experiment.prototype.copyProtocolAttributes = function(protocol) {
      var dap, dapVal, eExptMeta, mfp, mfpVal, mft, mftVal, pExptMeta, pstates;
      pstates = protocol.get('lsStates');
      pExptMeta = pstates.getStatesByTypeAndKind("metadata", "experiment metadata");
      if (pExptMeta.length > 0) {
        eExptMeta = this.get('lsStates').getStatesByTypeAndKind("metadata", "experiment metadata");
        dapVal = eExptMeta[0].getValuesByTypeAndKind("clobValue", "data analysis parameters");
        if (dapVal.length > 0) {
          if (dapVal[0].isNew()) {
            eExptMeta[0].get('lsValues').remove(dapVal[0]);
          } else {
            dapVal[0].set({
              ignored: true
            });
          }
        }
        dap = new Value(_.clone(pstates.getOrCreateValueByTypeAndKind("metadata", "experiment metadata", "clobValue", "data analysis parameters")).attributes);
        dap.unset('id');
        dap.unset('lsTransaction');
        eExptMeta[0].get('lsValues').add(dap);
        mfpVal = eExptMeta[0].getValuesByTypeAndKind("clobValue", "model fit parameters");
        if (mfpVal.length > 0) {
          if (mfpVal[0].isNew()) {
            eExptMeta[0].get('lsValues').remove(mfpVal[0]);
          } else {
            mfpVal[0].set({
              ignored: true
            });
          }
        }
        mfp = new Value(_.clone(pstates.getOrCreateValueByTypeAndKind("metadata", "experiment metadata", "clobValue", "model fit parameters")).attributes);
        mfp.unset('id');
        mfp.unset('lsTransaction');
        eExptMeta[0].get('lsValues').add(mfp);
        mftVal = eExptMeta[0].getValuesByTypeAndKind("codeValue", "model fit type");
        if (mftVal.length > 0) {
          if (mftVal[0].isNew()) {
            eExptMeta[0].get('lsValues').remove(mftVal[0]);
          } else {
            mftVal[0].set({
              ignored: true
            });
          }
        }
        mft = new Value(_.clone(pstates.getOrCreateValueByTypeAndKind("metadata", "experiment metadata", "codeValue", "model fit type")).attributes);
        mft.unset('id');
        mft.unset('lsTransaction');
        eExptMeta[0].get('lsValues').add(mft);
        this.getDryRunStatus().set({
          ignored: true
        });
        this.getDryRunStatus().set({
          codeValue: 'not started'
        });
        this.getDryRunResultHTML().set({
          ignored: true
        });
        this.getDryRunResultHTML().set({
          clobValue: ""
        });
      }
      this.set({
        lsKind: protocol.get('lsKind'),
        protocol: protocol
      });
      this.trigger('change');
      this.trigger("protocol_attributes_copied");
    };

    Experiment.prototype.validate = function(attrs) {
      var bestName, cDate, errors, nameError, notebook, projectCode, reqProject, scientist;
      errors = [];
      bestName = attrs.lsLabels.pickBestName();
      nameError = true;
      if (bestName != null) {
        nameError = true;
        if (bestName.get('labelText') !== "") {
          nameError = false;
        }
        if (bestName.get('labelText') === attrs.codeName) {
          nameError = false;
        }
      } else if (this.isNew() && bestName === void 0) {
        nameError = false;
      }
      if (nameError) {
        errors.push({
          attribute: attrs.subclass + 'Name',
          message: attrs.subclass + " name must be set"
        });
      }
      if (_.isNaN(attrs.recordedDate)) {
        errors.push({
          attribute: 'recordedDate',
          message: attrs.subclass + " date must be set"
        });
      }
      if (attrs.subclass != null) {
        notebook = this.getNotebook().get('stringValue');
        if (notebook === "" || notebook === void 0 || notebook === null) {
          errors.push({
            attribute: 'notebook',
            message: "Notebook must be set"
          });
        }
        scientist = this.getScientist().get('codeValue');
        if (scientist === "unassigned" || scientist === void 0 || scientist === "" || scientist === null) {
          errors.push({
            attribute: 'scientist',
            message: "Scientist must be set"
          });
        }
      }
      if (attrs.protocol === null) {
        errors.push({
          attribute: 'protocolCode',
          message: "Protocol must be set"
        });
      }
      if (attrs.subclass != null) {
        reqProject = window.conf.include.project;
        if (reqProject == null) {
          reqProject = "true";
        }
        reqProject = reqProject.toLowerCase();
        if (reqProject !== "false") {
          projectCode = this.getProjectCode().get('codeValue');
          if (projectCode === "" || projectCode === "unassigned" || projectCode === void 0) {
            errors.push({
              attribute: 'projectCode',
              message: "Project must be set"
            });
          }
        }
        cDate = this.getCompletionDate().get('dateValue');
        if (cDate === void 0 || cDate === "" || cDate === null) {
          cDate = "fred";
        }
        if (isNaN(cDate)) {
          errors.push({
            attribute: 'completionDate',
            meetsage: "Assay completion date must be set"
          });
        }
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
        projectCodeValue.set({
          codeType: "project"
        });
        projectCodeValue.set({
          codeKind: "biology"
        });
        projectCodeValue.set({
          codeOrigin: "ACAS DDICT"
        });
      }
      return projectCodeValue;
    };

    Experiment.prototype.getAnalysisStatus = function() {
      var metadataKind, status;
      metadataKind = this.get('subclass') + " metadata";
      status = this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", metadataKind, "codeValue", "analysis status");
      if (status.get('codeValue') === void 0 || status.get('codeValue') === "") {
        status.set({
          codeValue: "not started"
        });
        status.set({
          codeType: "analysis"
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

    Experiment.prototype.getCompletionDate = function() {
      return this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "experiment metadata", "dateValue", "completion date");
    };

    Experiment.prototype.duplicateEntity = function() {
      var copiedEntity;
      copiedEntity = Experiment.__super__.duplicateEntity.call(this);
      copiedEntity.getCompletionDate().set({
        dateValue: null
      });
      return copiedEntity;
    };

    Experiment.prototype.prepareToSave = function() {
      var expState, i, len, val, value, valuesToDelete;
      valuesToDelete = [
        {
          type: 'codeValue',
          kind: 'analysis status'
        }, {
          type: 'codeValue',
          kind: 'dry run status'
        }, {
          type: 'codeValue',
          kind: 'model fit status'
        }, {
          type: 'clobValue',
          kind: 'data analysis parameters'
        }, {
          type: 'clobValue',
          kind: 'model fit parameters'
        }, {
          type: 'clobValue',
          kind: 'analysis result html'
        }, {
          type: 'clobValue',
          kind: 'dry run result html'
        }, {
          type: 'codeValue',
          kind: 'model fit type'
        }, {
          type: 'clobValue',
          kind: 'model fit result html'
        }, {
          type: 'fileValue',
          kind: 'source file'
        }, {
          type: 'fileValue',
          kind: 'dryrun source file'
        }, {
          type: 'stringValue',
          kind: 'hts format'
        }
      ];
      if (!this.isNew()) {
        expState = this.get('lsStates').getStatesByTypeAndKind("metadata", "experiment metadata")[0];
        for (i = 0, len = valuesToDelete.length; i < len; i++) {
          val = valuesToDelete[i];
          value = expState.getValuesByTypeAndKind(val.type, val.kind)[0];
          if (value != null) {
            if ((val.kind === "data analysis parameters" || val.kind === "model fit parameters" || val.kind === "model fit type" || val.kind === "dry run status" || val.kind === "dry run html") && value.isNew()) {

            } else {
              expState.get('lsValues').remove(value);
            }
          }
        }
      }
      return Experiment.__super__.prepareToSave.call(this);
    };

    return Experiment;

  })(BaseEntity);

  window.ExperimentList = (function(superClass) {
    extend(ExperimentList, superClass);

    function ExperimentList() {
      return ExperimentList.__super__.constructor.apply(this, arguments);
    }

    ExperimentList.prototype.model = Experiment;

    return ExperimentList;

  })(Backbone.Collection);

  window.ExperimentBaseController = (function(superClass) {
    extend(ExperimentBaseController, superClass);

    function ExperimentBaseController() {
      this.displayInReadOnlyMode = bind(this.displayInReadOnlyMode, this);
      this.getNextLabelSequence = bind(this.getNextLabelSequence, this);
      this.handleSaveClicked = bind(this.handleSaveClicked, this);
      this.updateEditable = bind(this.updateEditable, this);
      this.handleCompletionDateIconClicked = bind(this.handleCompletionDateIconClicked, this);
      this.handleDateChanged = bind(this.handleDateChanged, this);
      this.handleUseProtocolParametersClicked = bind(this.handleUseProtocolParametersClicked, this);
      this.handleProjectCodeChanged = bind(this.handleProjectCodeChanged, this);
      this.handleUseNewParams = bind(this.handleUseNewParams, this);
      this.handleKeepOldParams = bind(this.handleKeepOldParams, this);
      this.handleProtocolCodeChanged = bind(this.handleProtocolCodeChanged, this);
      this.handleExptNameChkbxClicked = bind(this.handleExptNameChkbxClicked, this);
      this.handleCancelDeleteClicked = bind(this.handleCancelDeleteClicked, this);
      this.handleConfirmDeleteExperimentClicked = bind(this.handleConfirmDeleteExperimentClicked, this);
      this.handleCloseExperimentModal = bind(this.handleCloseExperimentModal, this);
      this.handleDeleteStatusChosen = bind(this.handleDeleteStatusChosen, this);
      this.modelSyncCallback = bind(this.modelSyncCallback, this);
      this.render = bind(this.render, this);
      return ExperimentBaseController.__super__.constructor.apply(this, arguments);
    }

    ExperimentBaseController.prototype.template = _.template($("#ExperimentBaseView").html());

    ExperimentBaseController.prototype.moduleLaunchName = "experiment_base";

    ExperimentBaseController.prototype.events = function() {
      return _(ExperimentBaseController.__super__.events.call(this)).extend({
        "click .bv_exptNameChkbx": "handleExptNameChkbxClicked",
        "keyup .bv_experimentName": "handleNameChanged",
        "click .bv_useProtocolParameters": "handleUseProtocolParametersClicked",
        "change .bv_protocolCode": "handleProtocolCodeChanged",
        "change .bv_projectCode": "handleProjectCodeChanged",
        "change .bv_completionDate": "handleDateChanged",
        "click .bv_completionDateIcon": "handleCompletionDateIconClicked",
        "click .bv_keepOldParams": "handleKeepOldParams",
        "click .bv_useNewParams": "handleUseNewParams",
        "click .bv_closeDeleteExperimentModal": "handleCloseExperimentModal",
        "click .bv_confirmDeleteExperimentButton": "handleConfirmDeleteExperimentClicked",
        "click .bv_cancelDelete": "handleCancelDeleteClicked"
      });
    };

    ExperimentBaseController.prototype.initialize = function() {
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
                    var expt, lsKind;
                    if (json.length === 0) {
                      alert('Could not get experiment for code in this URL, creating new one');
                    } else {
                      lsKind = json.lsKind;
                      if (lsKind === "default") {
                        expt = new Experiment(json);
                        expt.set(expt.parse(expt.attributes));
                        if (window.AppLaunchParams.moduleLaunchParams.copy) {
                          _this.model = expt.duplicateEntity();
                        } else {
                          _this.model = expt;
                        }
                      } else {
                        alert('Could not get experiment for code in this URL. Creating new experiment');
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

    ExperimentBaseController.prototype.createExperimentFromProtocol = function(code) {
      this.model = new Experiment();
      this.model.set({
        protocol: new Protocol({
          codeName: code
        })
      });
      return this.getAndSetProtocol(code, true);
    };

    ExperimentBaseController.prototype.completeInitialization = function() {
      if (this.model == null) {
        this.model = new Experiment();
      }
      this.errorOwnerName = 'ExperimentBaseController';
      this.setBindings();
      if (this.options.readOnly != null) {
        this.readOnly = this.options.readOnly;
      } else {
        this.readOnly = false;
      }
      $(this.el).empty();
      $(this.el).html(this.template(this.model.attributes));
      this.model.on('notUniqueName', (function(_this) {
        return function() {
          _this.$('.bv_experimentSaveFailed').modal('show');
          _this.$('.bv_closeSaveFailedModal').removeAttr('disabled');
          _this.$('.bv_saveFailed').show();
          return _this.$('.bv_experimentSaveFailed').on('hide.bs.modal', function() {
            return _this.$('.bv_saveFailed').hide();
          });
        };
      })(this));
      this.model.on('saveFailed', (function(_this) {
        return function() {
          return _this.$('.bv_saveFailed').show();
        };
      })(this));
      this.setupStatusSelect();
      this.setupScientistSelect();
      this.setupTagList();
      this.setupProtocolSelect(this.options.protocolFilter, this.options.protocolKindFilter);
      this.setupProjectSelect();
      this.setupAttachFileListController();
      this.render();
      this.listenTo(this.model, 'sync', this.modelSyncCallback);
      this.listenTo(this.model, 'change', this.modelChangeCallback);
      return this.model.getStatus().on('change', this.updateEditable);
    };

    ExperimentBaseController.prototype.render = function() {
      if (this.model == null) {
        this.model = new Experiment();
      }
      if (this.model.get('protocol') !== null) {
        this.$('.bv_protocolCode').val(this.model.get('protocol').get('codeName'));
      }
      this.$('.bv_projectCode').val(this.model.getProjectCode().get('codeValue'));
      this.setUseProtocolParametersDisabledState();
      this.$('.bv_completionDate').datepicker();
      this.$('.bv_completionDate').datepicker("option", "dateFormat", "yy-mm-dd");
      if (this.model.getCompletionDate().get('dateValue') != null) {
        this.$('.bv_completionDate').val(UtilityFunctions.prototype.convertMSToYMDDate(this.model.getCompletionDate().get('dateValue')));
      }
      ExperimentBaseController.__super__.render.call(this);
      if (this.model.isNew()) {
        this.$('.bv_experimentName').attr('disabled', 'disabled');
        this.$('.bv_openInLiveDesignWrapper').hide();
      } else {
        this.setupExptNameChkbx();
        this.$('.bv_openInLiveDesignWrapper').show();
        this.$('.bv_openInLiveDesignLink').attr('href', "/openExptInQueryTool?experiment=" + this.model.get('codeName'));
      }
      return this;
    };

    ExperimentBaseController.prototype.modelSyncCallback = function() {
      if (this.model.get('subclass') == null) {
        this.model.set({
          subclass: 'experiment'
        });
      }
      this.$('.bv_saving').hide();
      this.render();
      if (this.$('.bv_saveFailed').is(":visible") || this.$('.bv_cancelComplete').is(":visible")) {
        this.$('.bv_updateComplete').hide();
        this.trigger('amDirty');
      } else {
        this.$('.bv_updateComplete').show();
        this.trigger('amClean');
        this.model.trigger('saveSuccess');
      }
      return this.setupAttachFileListController();
    };

    ExperimentBaseController.prototype.setupExptNameChkbx = function() {
      var code, name;
      code = this.model.get('codeName');
      if (this.model.get('lsLabels').pickBestName() != null) {
        name = this.model.get('lsLabels').pickBestName().get('labelText');
      } else {
        name = "";
      }
      if (code === name) {
        this.$('.bv_experimentName').attr('disabled', 'disabled');
        return this.$('.bv_exptNameChkbx').attr('checked', 'checked');
      } else {
        return this.$('.bv_exptNameChkbx').removeAttr('checked');
      }
    };

    ExperimentBaseController.prototype.setupProtocolSelect = function(protocolFilter, protocolKindFilter) {
      var protocolCode;
      if (this.model.get('protocol') !== null) {
        protocolCode = this.model.get('protocol').get('codeName');
      } else {
        protocolCode = "unassigned";
      }
      this.protocolList = new PickListList();
      if (protocolFilter != null) {
        this.protocolList.url = "/api/protocolCodes/" + protocolFilter;
      } else if (protocolKindFilter != null) {
        this.protocolList.url = "/api/protocolCodes/" + protocolKindFilter;
      } else {
        this.protocolList.url = "/api/protocolCodes/?protocolKind=default";
      }
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
      var reqProject;
      reqProject = window.conf.include.project;
      if (reqProject != null) {
        if (reqProject.toLowerCase() === "false") {
          this.$('.bv_projectLabel').html("Project");
        }
      }
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
      this.statusList.url = "/api/codetables/experiment/status";
      return this.statusListController = new PickListSelectController({
        el: this.$('.bv_status'),
        collection: this.statusList,
        selectedCode: this.model.getStatus().get('codeValue')
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

    ExperimentBaseController.prototype.handleDeleteStatusChosen = function() {
      this.$(".bv_deleteButtons").removeClass("hide");
      this.$(".bv_okayButton").addClass("hide");
      this.$(".bv_errorDeletingExperimentMessage").addClass("hide");
      this.$(".bv_deleteWarningMessage").removeClass("hide");
      this.$(".bv_deletingStatusIndicator").addClass("hide");
      this.$(".bv_experimentDeletedSuccessfullyMessage").addClass("hide");
      this.$(".bv_confirmDeleteExperimentModal").removeClass("hide");
      return this.$('.bv_confirmDeleteExperimentModal').modal({
        backdrop: 'static'
      });
    };

    ExperimentBaseController.prototype.handleCloseExperimentModal = function() {
      return this.statusListController.setSelectedCode(this.model.getStatus().get('codeValue'));
    };

    ExperimentBaseController.prototype.handleConfirmDeleteExperimentClicked = function() {
      this.$(".bv_deleteWarningMessage").addClass("hide");
      this.$(".bv_deletingStatusIndicator").removeClass("hide");
      this.$(".bv_deleteButtons").addClass("hide");
      this.$(".bv_experimentCodeName").html(this.model.get('codeName'));
      return $.ajax({
        url: "/api/experiments/" + (this.model.get("id")),
        type: 'DELETE',
        success: (function(_this) {
          return function(result) {
            _this.$(".bv_okayButton").removeClass("hide");
            _this.$(".bv_deletingStatusIndicator").addClass("hide");
            _this.$(".bv_experimentDeletedSuccessfullyMessage").removeClass("hide");
            _this.handleValueChanged("Status", "deleted");
            _this.updateEditable();
            return _this.trigger('amClean');
          };
        })(this),
        error: (function(_this) {
          return function(result) {
            _this.$(".bv_okayButton").removeClass("hide");
            _this.$(".bv_deletingStatusIndicator").addClass("hide");
            return _this.$(".bv_errorDeletingExperimentMessage").removeClass("hide");
          };
        })(this)
      });
    };

    ExperimentBaseController.prototype.handleCancelDeleteClicked = function() {
      this.$(".bv_confirmDeleteExperimentModal").modal('hide');
      return this.statusListController.setSelectedCode(this.model.getStatus().get('codeValue'));
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
          return this.handleUseProtocolParametersClicked();
        }
      }
    };

    ExperimentBaseController.prototype.handleExptNameChkbxClicked = function() {
      var checked;
      checked = this.$('.bv_exptNameChkbx').is(":checked");
      if (checked) {
        this.$('.bv_experimentName').attr('disabled', 'disabled');
        this.$('.bv_experimentName').val(this.model.get('codeName'));
        this.handleNameChanged();
        if (this.model.isNew()) {
          return this.model.get('lsLabels').pickBestName().set({
            labelText: void 0
          });
        }
      } else {
        this.$('.bv_experimentName').removeAttr('disabled');
        return this.handleNameChanged();
      }
    };

    ExperimentBaseController.prototype.handleProtocolCodeChanged = function() {
      var analysisStatus, code;
      code = this.protocolListController.getSelectedCode();
      if (this.model.isNew()) {
        this.getAndSetProtocol(code, true);
      }
      if (!this.model.isNew()) {
        if (this.model.get('lsKind') === "default") {
          return this.getAndSetProtocol(code, false);
        } else {
          analysisStatus = this.model.getAnalysisStatus().get('codeValue');
          if (analysisStatus === "not started") {
            this.$('.bv_askChangeProtocolParameters').modal({
              backdrop: 'static'
            });
            return this.$('.bv_askChangeProtocolParameters').modal('show');
          } else {
            this.$('.bv_dontChangeProtocolParameters').modal('show');
            return this.getAndSetProtocol(code, false);
          }
        }
      }
    };

    ExperimentBaseController.prototype.getAndSetProtocol = function(code, setAnalysisParams) {
      if (code === "" || code === "unassigned") {
        this.model.set({
          'protocol': null
        });
        return this.setUseProtocolParametersDisabledState();
      } else {
        this.$('.bv_protocolCode').attr('disabled', 'disabled');
        this.$('.bv_spinner').spin('aligned');
        return $.ajax({
          type: 'GET',
          url: "/api/protocols/codename/" + code,
          success: (function(_this) {
            return function(json) {
              _this.$('.bv_spinner').spin(false);
              _this.$('.bv_protocolCode').removeAttr('disabled');
              if (json.length === 0) {
                return alert("Could not find selected protocol in database");
              } else {
                _this.model.set({
                  protocol: new Protocol(json)
                });
                if (setAnalysisParams) {
                  return _this.getFullProtocol();
                }
              }
            };
          })(this),
          error: function(err) {
            return alert('got ajax error from getting protocol ' + code);
          },
          dataType: 'json'
        });
      }
    };

    ExperimentBaseController.prototype.handleKeepOldParams = function() {
      this.$('.bv_askChangeProtocolParameters').modal('hide');
      return this.getAndSetProtocol(this.protocolListController.getSelectedCode(), false);
    };

    ExperimentBaseController.prototype.handleUseNewParams = function() {
      this.$('.bv_askChangeProtocolParameters').modal('hide');
      return this.getAndSetProtocol(this.protocolListController.getSelectedCode(), true);
    };

    ExperimentBaseController.prototype.handleProjectCodeChanged = function() {
      var value;
      value = this.projectListController.getSelectedCode();
      return this.handleValueChanged("ProjectCode", value);
    };

    ExperimentBaseController.prototype.handleUseProtocolParametersClicked = function() {
      var exptChkbx;
      this.model.copyProtocolAttributes(this.model.get('protocol'));
      exptChkbx = this.$('.bv_exptNameChkbx').attr('checked');
      this.render();
      if (exptChkbx === "checked") {
        this.$('.bv_experimentName').attr('disabled', 'disabled');
      } else {
        this.$('.bv_experimentName').removeAttr('disabled');
      }
      this.model.trigger('change');
      if (!this.model.isNew()) {
        return this.model.trigger('changeProtocolParams');
      }
    };

    ExperimentBaseController.prototype.handleDateChanged = function() {
      var value;
      value = UtilityFunctions.prototype.convertYMDDateToMs(UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_completionDate')));
      return this.handleValueChanged("CompletionDate", value);
    };

    ExperimentBaseController.prototype.handleCompletionDateIconClicked = function() {
      return this.$(".bv_completionDate").datepicker("show");
    };

    ExperimentBaseController.prototype.updateEditable = function() {
      return ExperimentBaseController.__super__.updateEditable.call(this);
    };

    ExperimentBaseController.prototype.handleSaveClicked = function() {
      this.$('.bv_saveFailed').hide();
      if (this.model.isNew() && this.$('.bv_exptNameChkbx').is(":checked")) {
        return this.getNextLabelSequence();
      } else {
        return this.saveEntity();
      }
    };

    ExperimentBaseController.prototype.getNextLabelSequence = function() {
      return $.ajax({
        type: 'POST',
        url: "/api/getNextLabelSequence",
        data: JSON.stringify({
          thingTypeAndKind: "document_experiment",
          labelTypeAndKind: "id_codeName",
          numberOfLabels: 1
        }),
        contentType: 'application/json',
        dataType: 'json',
        success: (function(_this) {
          return function(response) {
            if (response === "getNextLabelSequenceFailed") {
              alert('Error getting the next label sequence');
              return _this.model.trigger('saveFailed');
            } else {
              return _this.addNameAndCode(response[0].autoLabel);
            }
          };
        })(this),
        error: (function(_this) {
          return function(err) {
            alert('could not get next label sequence');
            return _this.serviceReturn = null;
          };
        })(this)
      });
    };

    ExperimentBaseController.prototype.addNameAndCode = function(codeName) {
      this.model.set({
        codeName: codeName
      });
      if (this.model.get('lsLabels').pickBestName() != null) {
        this.model.get('lsLabels').pickBestName().set({
          labelText: codeName
        });
      } else {
        this.model.get('lsLabels').setBestName(new Label({
          lsKind: "experiment name",
          labelText: codeName,
          recordedBy: window.AppLaunchParams.loginUser.username,
          recordedDate: new Date().getTime()
        }));
      }
      return this.saveEntity();
    };

    ExperimentBaseController.prototype.displayInReadOnlyMode = function() {
      ExperimentBaseController.__super__.displayInReadOnlyMode.call(this);
      return this.$('.bv_openInLiveDesignWrapper').hide();
    };

    return ExperimentBaseController;

  })(BaseEntityController);

}).call(this);
