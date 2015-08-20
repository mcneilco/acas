(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.Protocol = (function(superClass) {
    extend(Protocol, superClass);

    function Protocol() {
      this.duplicateEntity = bind(this.duplicateEntity, this);
      this.parse = bind(this.parse, this);
      return Protocol.__super__.constructor.apply(this, arguments);
    }

    Protocol.prototype.urlRoot = "/api/protocols";

    Protocol.prototype.initialize = function() {
      this.set({
        subclass: "protocol"
      });
      return Protocol.__super__.initialize.call(this);
    };

    Protocol.prototype.parse = function(resp) {
      if (resp === "not unique protocol name" || resp === '"not unique protocol name"') {
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

    Protocol.prototype.getCreationDate = function() {
      return this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "protocol metadata", "dateValue", "creation date");
    };

    Protocol.prototype.getAssayTreeRule = function() {
      var assayTreeRule;
      assayTreeRule = this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "protocol metadata", "stringValue", "assay tree rule");
      if (assayTreeRule.get('stringValue') === void 0) {
        assayTreeRule.set({
          stringValue: ""
        });
      }
      return assayTreeRule;
    };

    Protocol.prototype.getAssayStage = function() {
      var assayStage;
      assayStage = this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "protocol metadata", "codeValue", "assay stage");
      if (assayStage.get('codeValue') === void 0 || assayStage.get('codeValue') === "" || assayStage.get('codeValue') === null) {
        assayStage.set({
          codeValue: "unassigned"
        });
        assayStage.set({
          codeType: "assay"
        });
        assayStage.set({
          codeKind: "stage"
        });
        assayStage.set({
          codeOrigin: "ACAS DDICT"
        });
      }
      return assayStage;
    };

    Protocol.prototype.getAssayPrinciple = function() {
      var assayPrinciple;
      assayPrinciple = this.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "protocol metadata", "clobValue", "assay principle");
      if (assayPrinciple.get('clobValue') === void 0) {
        assayPrinciple.set({
          clobValue: ""
        });
      }
      return assayPrinciple;
    };

    Protocol.prototype.validate = function(attrs) {
      var assayTreeRule, cDate, errors;
      errors = [];
      errors.push.apply(errors, Protocol.__super__.validate.call(this, attrs));
      if (attrs.subclass != null) {
        cDate = this.getCreationDate().get('dateValue');
        if (cDate === void 0 || cDate === "" || cDate === null) {
          cDate = "fred";
        }
        if (isNaN(cDate)) {
          errors.push({
            attribute: 'creationDate',
            message: "Date must be set"
          });
        }
      }
      assayTreeRule = this.getAssayTreeRule().get('stringValue');
      if (!(assayTreeRule === "" || assayTreeRule === void 0 || assayTreeRule === null)) {
        if (assayTreeRule.charAt([0]) !== "/") {
          errors.push({
            attribute: 'assayTreeRule',
            message: "Assay tree rule must start with '/'"
          });
        } else if (assayTreeRule.charAt([assayTreeRule.length - 1]) === "/") {
          errors.push({
            attribute: 'assayTreeRule',
            message: "Assay tree rule should not end with '/'"
          });
        }
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

    Protocol.prototype.duplicateEntity = function() {
      var copiedEntity;
      copiedEntity = Protocol.__super__.duplicateEntity.call(this);
      copiedEntity.getCreationDate().set({
        dateValue: null
      });
      return copiedEntity;
    };

    return Protocol;

  })(BaseEntity);

  window.ProtocolList = (function(superClass) {
    extend(ProtocolList, superClass);

    function ProtocolList() {
      return ProtocolList.__super__.constructor.apply(this, arguments);
    }

    ProtocolList.prototype.model = Protocol;

    return ProtocolList;

  })(Backbone.Collection);

  window.ProtocolBaseController = (function(superClass) {
    extend(ProtocolBaseController, superClass);

    function ProtocolBaseController() {
      this.handleAssayTreeRuleChanged = bind(this.handleAssayTreeRuleChanged, this);
      this.handleAssayPrincipleChanged = bind(this.handleAssayPrincipleChanged, this);
      this.handleAssayStageChanged = bind(this.handleAssayStageChanged, this);
      this.handleCreationDateIconClicked = bind(this.handleCreationDateIconClicked, this);
      this.handleCreationDateChanged = bind(this.handleCreationDateChanged, this);
      this.handleCancelDeleteClicked = bind(this.handleCancelDeleteClicked, this);
      this.handleConfirmDeleteProtocolClicked = bind(this.handleConfirmDeleteProtocolClicked, this);
      this.handleCloseProtocolModal = bind(this.handleCloseProtocolModal, this);
      this.handleDeleteStatusChosen = bind(this.handleDeleteStatusChosen, this);
      this.modelSyncCallback = bind(this.modelSyncCallback, this);
      this.render = bind(this.render, this);
      this.completeInitialization = bind(this.completeInitialization, this);
      this.initialize = bind(this.initialize, this);
      return ProtocolBaseController.__super__.constructor.apply(this, arguments);
    }

    ProtocolBaseController.prototype.template = _.template($("#ProtocolBaseView").html());

    ProtocolBaseController.prototype.moduleLaunchName = "protocol_base";

    ProtocolBaseController.prototype.events = function() {
      return _(ProtocolBaseController.__super__.events.call(this)).extend({
        "keyup .bv_protocolName": "handleNameChanged",
        "keyup .bv_assayTreeRule": "handleAssayTreeRuleChanged",
        "change .bv_assayStage": "handleAssayStageChanged",
        "keyup .bv_assayPrinciple": "handleAssayPrincipleChanged",
        "change .bv_creationDate": "handleCreationDateChanged",
        "click .bv_creationDateIcon": "handleCreationDateIconClicked",
        "click .bv_closeDeleteProtocolModal": "handleCloseProtocolModal",
        "click .bv_confirmDeleteProtocolButton": "handleConfirmDeleteProtocolClicked",
        "click .bv_cancelDelete": "handleCancelDeleteClicked"
      });
    };

    ProtocolBaseController.prototype.initialize = function() {
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
                  var lsKind, prot;
                  if (json.length === 0) {
                    alert('Could not get protocol for code in this URL, creating new one');
                  } else {
                    lsKind = json.lsKind;
                    if (lsKind === "default") {
                      prot = new Protocol(json);
                      prot.set(prot.parse(prot.attributes));
                      if (window.AppLaunchParams.moduleLaunchParams.copy) {
                        _this.model = prot.duplicateEntity();
                      } else {
                        _this.model = prot;
                      }
                    } else {
                      alert('Could not get protocol for code in this URL. Creating new protocol');
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

    ProtocolBaseController.prototype.completeInitialization = function() {
      if (this.model == null) {
        this.model = new Protocol();
      }
      this.errorOwnerName = 'ProtocolBaseController';
      this.setBindings();
      if (this.options.readOnly != null) {
        this.readOnly = this.options.readOnly;
      } else {
        this.readOnly = false;
      }
      $(this.el).empty();
      $(this.el).html(this.template(this.model.attributes));
      if (window.conf.protocol.hideAssayTreeRule) {
        this.$('.bv_group_assayTreeRule').hide();
      } else {
        this.$('.bv_group_assayTreeRule').show();
      }
      this.model.on('notUniqueName', (function(_this) {
        return function() {
          _this.$('.bv_protocolSaveFailed').modal('show');
          $('.bv_closeSaveFailedModal').removeAttr('disabled');
          _this.$('.bv_saveFailed').show();
          return $('.bv_protocolSaveFailed').on('hidden', function() {
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
      this.setUpAssayStageSelect();
      this.setupAttachFileListController();
      this.render();
      this.listenTo(this.model, 'sync', this.modelSyncCallback);
      this.listenTo(this.model, 'change', this.modelChangeCallback);
      return this.model.getStatus().on('change', this.updateEditable);
    };

    ProtocolBaseController.prototype.render = function() {
      if (this.model == null) {
        this.model = new Protocol();
      }
      this.setUpAssayStageSelect();
      this.$('.bv_creationDate').datepicker();
      this.$('.bv_creationDate').datepicker("option", "dateFormat", "yy-mm-dd");
      if (this.model.getCreationDate().get('dateValue') != null) {
        this.$('.bv_creationDate').val(UtilityFunctions.prototype.convertMSToYMDDate(this.model.getCreationDate().get('dateValue')));
      }
      this.$('.bv_assayTreeRule').val(this.model.getAssayTreeRule().get('stringValue'));
      this.$('.bv_assayPrinciple').val(this.model.getAssayPrinciple().get('clobValue'));
      ProtocolBaseController.__super__.render.call(this);
      return this;
    };

    ProtocolBaseController.prototype.modelSyncCallback = function() {
      if (this.model.get('subclass') == null) {
        this.model.set({
          subclass: 'protocol'
        });
      }
      this.$('.bv_saving').hide();
      if (this.$('.bv_saveFailed').is(":visible") || this.$('.bv_cancelComplete').is(":visible")) {
        this.$('.bv_updateComplete').hide();
        this.trigger('amDirty');
      } else {
        this.$('.bv_updateComplete').show();
      }
      if (this.model.get('lsKind') !== "default") {
        this.$('.bv_newEntity').hide();
        this.$('.bv_cancel').hide();
        this.$('.bv_save').hide();
      }
      this.trigger('amClean');
      this.render();
      if (this.model.get('lsType') === "default") {
        return this.setupAttachFileListController();
      }
    };

    ProtocolBaseController.prototype.setUpAssayStageSelect = function() {
      this.assayStageList = new PickListList();
      this.assayStageList.url = "/api/codetables/assay/stage";
      return this.assayStageListController = new PickListSelectController({
        el: this.$('.bv_assayStage'),
        collection: this.assayStageList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select Assay Stage"
        }),
        selectedCode: this.model.getAssayStage().get('codeValue')
      });
    };

    ProtocolBaseController.prototype.handleDeleteStatusChosen = function() {
      this.$(".bv_deleteButtons").removeClass("hide");
      this.$(".bv_okayButton").addClass("hide");
      this.$(".bv_errorDeletingProtocolMessage").addClass("hide");
      this.$(".bv_deleteWarningMessage").removeClass("hide");
      this.$(".bv_deletingStatusIndicator").addClass("hide");
      this.$(".bv_experimentDeletedSuccessfullyMessage").addClass("hide");
      this.$(".bv_confirmDeleteProtocolModal").removeClass("hide");
      return this.$('.bv_confirmDeleteProtocolModal').modal({
        backdrop: 'static'
      });
    };

    ProtocolBaseController.prototype.handleCloseProtocolModal = function() {
      return this.statusListController.setSelectedCode(this.model.getStatus().get('codeValue'));
    };

    ProtocolBaseController.prototype.handleConfirmDeleteProtocolClicked = function() {
      this.$(".bv_deleteWarningMessage").addClass("hide");
      this.$(".bv_deletingStatusIndicator").removeClass("hide");
      this.$(".bv_deleteButtons").addClass("hide");
      this.$(".bv_protocolCodeName").html(this.model.get('codeName'));
      return $.ajax({
        url: "/api/protocols/browser/" + (this.model.get("id")),
        type: 'DELETE',
        success: (function(_this) {
          return function(result) {
            _this.$(".bv_okayButton").removeClass("hide");
            _this.$(".bv_deletingStatusIndicator").addClass("hide");
            _this.$(".bv_protocolDeletedSuccessfullyMessage").removeClass("hide");
            _this.handleValueChanged("Status", "deleted");
            _this.updateEditable();
            return _this.trigger('amClean');
          };
        })(this),
        error: (function(_this) {
          return function(result) {
            _this.$(".bv_okayButton").removeClass("hide");
            _this.$(".bv_deletingStatusIndicator").addClass("hide");
            return _this.$(".bv_errorDeletingProtocolMessage").removeClass("hide");
          };
        })(this)
      });
    };

    ProtocolBaseController.prototype.handleCancelDeleteClicked = function() {
      this.$(".bv_confirmDeleteProtocolModal").modal('hide');
      return this.statusListController.setSelectedCode(this.model.getStatus().get('codeValue'));
    };

    ProtocolBaseController.prototype.handleCreationDateChanged = function() {
      var value;
      value = UtilityFunctions.prototype.convertYMDDateToMs(UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_creationDate')));
      return this.handleValueChanged("CreationDate", value);
    };

    ProtocolBaseController.prototype.handleCreationDateIconClicked = function() {
      return this.$(".bv_creationDate").datepicker("show");
    };

    ProtocolBaseController.prototype.handleAssayStageChanged = function() {
      var value;
      value = this.assayStageListController.getSelectedCode();
      return this.handleValueChanged("AssayStage", value);
    };

    ProtocolBaseController.prototype.handleAssayPrincipleChanged = function() {
      var value;
      value = UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_assayPrinciple'));
      return this.handleValueChanged("AssayPrinciple", value);
    };

    ProtocolBaseController.prototype.handleAssayTreeRuleChanged = function() {
      var value;
      value = UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_assayTreeRule'));
      return this.handleValueChanged("AssayTreeRule", value);
    };

    return ProtocolBaseController;

  })(BaseEntityController);

}).call(this);
