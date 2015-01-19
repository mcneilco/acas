(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.Experiment = (function(_super) {
    __extends(Experiment, _super);

    function Experiment() {
      this.duplicateEntity = __bind(this.duplicateEntity, this);
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
      if (resp === "not unique experiment name") {
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
        }
        resp.lsTags.on('change', (function(_this) {
          return function() {
            return _this.trigger('change');
          };
        })(this));
        return resp;
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
        if (st.get('lsKind') === "experiment metadata") {
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
        }
      });
      this.set({
        lsKind: protocol.get('lsKind'),
        protocol: protocol,
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
      this.trigger('change');
      this.trigger("protocol_attributes_copied");
    };

    Experiment.prototype.validate = function(attrs) {
      var cDate, errors, projectCode;
      errors = [];
      errors.push.apply(errors, Experiment.__super__.validate.call(this, attrs));
      if (attrs.protocol === null) {
        errors.push({
          attribute: 'protocolCode',
          message: "Protocol must be set"
        });
      }
      if (attrs.subclass != null) {
        projectCode = this.getProjectCode().get('codeValue');
        if (projectCode === "" || projectCode === "unassigned" || projectCode === void 0) {
          errors.push({
            attribute: 'projectCode',
            message: "Project must be set"
          });
        }
        cDate = this.getCompletionDate().get('dateValue');
        if (cDate === void 0 || cDate === "" || cDate === null) {
          cDate = "fred";
        }
        if (isNaN(cDate)) {
          errors.push({
            attribute: 'completionDate',
            message: "Assay completion date must be set"
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
          codeValue: "created"
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
      this.updateEditable = __bind(this.updateEditable, this);
      this.handleCompletionDateIconClicked = __bind(this.handleCompletionDateIconClicked, this);
      this.handleDateChanged = __bind(this.handleDateChanged, this);
      this.handleUseProtocolParametersClicked = __bind(this.handleUseProtocolParametersClicked, this);
      this.handleProjectCodeChanged = __bind(this.handleProjectCodeChanged, this);
      this.handleProtocolCodeChanged = __bind(this.handleProtocolCodeChanged, this);
      this.render = __bind(this.render, this);
      return ExperimentBaseController.__super__.constructor.apply(this, arguments);
    }

    ExperimentBaseController.prototype.template = _.template($("#ExperimentBaseView").html());

    ExperimentBaseController.prototype.moduleLaunchName = "experiment_base";

    ExperimentBaseController.prototype.events = function() {
      return _(ExperimentBaseController.__super__.events.call(this)).extend({
        "change .bv_experimentName": "handleNameChanged",
        "click .bv_useProtocolParameters": "handleUseProtocolParametersClicked",
        "change .bv_protocolCode": "handleProtocolCodeChanged",
        "change .bv_projectCode": "handleProjectCodeChanged",
        "change .bv_completionDate": "handleDateChanged",
        "click .bv_completionDateIcon": "handleCompletionDateIconClicked"
      });
    };

    ExperimentBaseController.prototype.initialize = function() {
      if (this.model != null) {
        return this.completeInitialization();
      } else {
        if (window.AppLaunchParams.moduleLaunchParams != null) {
          if (window.AppLaunchParams.moduleLaunchParams.moduleName === this.moduleLaunchName) {
            if (window.AppLaunchParams.moduleLaunchParams.createFromOtherEntity) {
              console.log("create from other entity");
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
                      lsKind = json[0].lsKind;
                      if (lsKind === "default") {
                        expt = new Experiment(json[0]);
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
      return this.getAndSetProtocol(code);
    };

    ExperimentBaseController.prototype.completeInitialization = function() {
      if (this.model == null) {
        this.model = new Experiment();
      }
      this.errorOwnerName = 'ExperimentBaseController';
      this.setBindings();
      $(this.el).empty();
      $(this.el).html(this.template(this.model.attributes));
      this.model.on('saveFailed', (function(_this) {
        return function() {
          _this.$('.bv_experimentSaveFailed').modal('show');
          _this.$('.bv_saveFailed').show();
          return _this.$('.bv_experimentSaveFailed').on('hide.bs.modal', function() {
            return _this.$('.bv_saveFailed').hide();
          });
        };
      })(this));
      this.model.on('sync', (function(_this) {
        return function() {
          if (_this.model.get('subclass') == null) {
            _this.model.set({
              subclass: 'experiment'
            });
          }
          _this.$('.bv_saving').hide();
          _this.$('.bv_save').attr('disabled', 'disabled');
          if (_this.$('.bv_saveFailed').is(":visible")) {
            _this.$('.bv_updateComplete').hide();
            _this.trigger('amDirty');
          } else {
            _this.$('.bv_updateComplete').show();
            _this.trigger('amClean');
          }
          return _this.render();
        };
      })(this));
      this.model.on('change', (function(_this) {
        return function() {
          _this.trigger('amDirty');
          return _this.$('.bv_updateComplete').hide();
        };
      })(this));
      this.$('.bv_save').attr('disabled', 'disabled');
      this.setupStatusSelect();
      this.setupRecordedBySelect();
      this.setupTagList();
      this.model.getStatus().on('change', this.updateEditable);
      this.setupProtocolSelect(this.options.protocolFilter, this.options.protocolKindFilter);
      this.setupProjectSelect();
      this.render();
      return console.log(this.model);
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
      return this;
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
      this.protocolListController = new PickListSelectController({
        el: this.$('.bv_protocolCode'),
        collection: this.protocolList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select Protocol"
        }),
        selectedCode: protocolCode
      });
      console.log("protocol list in set up ");
      return console.log(this.protocolListController.collection);
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
      return this.getAndSetProtocol(code);
    };

    ExperimentBaseController.prototype.getAndSetProtocol = function(code) {
      console.log("getprotocol");
      console.log(code);
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
                return alert("Could not find selected protocol in database");
              } else {
                _this.model.set({
                  protocol: new Protocol(json[0])
                });
                return _this.getFullProtocol();
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

    ExperimentBaseController.prototype.handleProjectCodeChanged = function() {
      this.model.getProjectCode().set({
        codeValue: this.projectListController.getSelectedCode()
      });
      return this.model.trigger('change');
    };

    ExperimentBaseController.prototype.handleUseProtocolParametersClicked = function() {
      this.model.copyProtocolAttributes(this.model.get('protocol'));
      return this.render();
    };

    ExperimentBaseController.prototype.handleDateChanged = function() {
      this.model.getCompletionDate().set({
        dateValue: UtilityFunctions.prototype.convertYMDDateToMs(UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_completionDate')))
      });
      return this.model.trigger('change');
    };

    ExperimentBaseController.prototype.handleCompletionDateIconClicked = function() {
      return this.$(".bv_completionDate").datepicker("show");
    };

    ExperimentBaseController.prototype.updateEditable = function() {
      ExperimentBaseController.__super__.updateEditable.call(this);
      if (this.model.isNew()) {
        return this.$('.bv_protocolCode').removeAttr("disabled");
      } else {
        return this.$('.bv_protocolCode').attr("disabled", "disabled");
      }
    };

    return ExperimentBaseController;

  })(BaseEntityController);

}).call(this);
