(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.Protocol = (function(_super) {
    __extends(Protocol, _super);

    function Protocol() {
      this.duplicateEntity = __bind(this.duplicateEntity, this);
      return Protocol.__super__.constructor.apply(this, arguments);
    }

    Protocol.prototype.urlRoot = "/api/protocols";

    Protocol.prototype.initialize = function() {
      this.set({
        subclass: "protocol"
      });
      return Protocol.__super__.initialize.call(this);
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
      this.handleAssayTreeRuleChanged = __bind(this.handleAssayTreeRuleChanged, this);
      this.handleAssayPrincipleChanged = __bind(this.handleAssayPrincipleChanged, this);
      this.handleAssayStageChanged = __bind(this.handleAssayStageChanged, this);
      this.handleCreationDateIconClicked = __bind(this.handleCreationDateIconClicked, this);
      this.handleCreationDateChanged = __bind(this.handleCreationDateChanged, this);
      this.render = __bind(this.render, this);
      return ProtocolBaseController.__super__.constructor.apply(this, arguments);
    }

    ProtocolBaseController.prototype.template = _.template($("#ProtocolBaseView").html());

    ProtocolBaseController.prototype.moduleLaunchName = "protocol_base";

    ProtocolBaseController.prototype.events = function() {
      return _(ProtocolBaseController.__super__.events.call(this)).extend({
        "change .bv_protocolName": "handleNameChanged",
        "change .bv_assayTreeRule": "handleAssayTreeRuleChanged",
        "change .bv_assayStage": "handleAssayStageChanged",
        "change .bv_assayPrinciple": "handleAssayPrincipleChanged",
        "change .bv_creationDate": "handleCreationDateChanged",
        "click .bv_creationDateIcon": "handleCreationDateIconClicked"
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
      $(this.el).empty();
      $(this.el).html(this.template(this.model.attributes));
      this.model.on('sync', (function(_this) {
        return function() {
          if (_this.model.get('subclass') == null) {
            _this.model.set({
              subclass: 'protocol'
            });
          }
          _this.$('.bv_saving').hide();
          _this.$('.bv_updateComplete').show();
          _this.render();
          return _this.trigger('amClean');
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
      this.setupScientistSelect();
      this.setupTagList();
      this.setUpAssayStageSelect();
      this.model.getStatus().on('change', this.updateEditable);
      return this.trigger('amClean');
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

    ProtocolBaseController.prototype.handleCreationDateChanged = function() {
      this.model.getCreationDate().set({
        dateValue: UtilityFunctions.prototype.convertYMDDateToMs(UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_creationDate'))),
        recordedBy: window.AppLaunchParams.loginUser.username,
        recordedDate: new Date().getTime()
      });
      return this.model.trigger('change');
    };

    ProtocolBaseController.prototype.handleCreationDateIconClicked = function() {
      return this.$(".bv_creationDate").datepicker("show");
    };

    ProtocolBaseController.prototype.handleAssayStageChanged = function() {
      this.model.getAssayStage().set({
        codeValue: this.assayStageListController.getSelectedCode(),
        recordedBy: window.AppLaunchParams.loginUser.username,
        recordedDate: new Date().getTime()
      });
      return this.trigger('change');
    };

    ProtocolBaseController.prototype.handleAssayPrincipleChanged = function() {
      return this.model.getAssayPrinciple().set({
        clobValue: UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_assayPrinciple')),
        recordedBy: window.AppLaunchParams.loginUser.username,
        recordedDate: new Date().getTime()
      });
    };

    ProtocolBaseController.prototype.handleAssayTreeRuleChanged = function() {
      return this.model.getAssayTreeRule().set({
        stringValue: UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_assayTreeRule')),
        recordedBy: window.AppLaunchParams.loginUser.username,
        recordedDate: new Date().getTime()
      });
    };

    return ProtocolBaseController;

  })(BaseEntityController);

}).call(this);
