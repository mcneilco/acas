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

    Protocol.prototype.initialize = function() {
      this.set({
        subclass: "protocol"
      });
      return Protocol.__super__.initialize.call(this);
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
      this.handleAssayTreeRuleChanged = __bind(this.handleAssayTreeRuleChanged, this);
      this.handleAssayPrincipleChanged = __bind(this.handleAssayPrincipleChanged, this);
      this.render = __bind(this.render, this);
      return ProtocolBaseController.__super__.constructor.apply(this, arguments);
    }

    ProtocolBaseController.prototype.template = _.template($("#ProtocolBaseView").html());

    ProtocolBaseController.prototype.moduleLaunchName = "protocol_base";

    ProtocolBaseController.prototype.events = function() {
      return _(ProtocolBaseController.__super__.events.call(this)).extend({
        "change .bv_protocolName": "handleNameChanged",
        "change .bv_assayTreeRule": "handleAssayTreeRuleChanged",
        "change .bv_assayPrinciple": "handleAssayPrincipleChanged"
      });
    };

    ProtocolBaseController.prototype.initialize = function() {
      if (this.model != null) {
        console.log("model exists");
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
                    console.log("got json");
                    console.log(json[0]);
                    lsKind = json[0].lsKind;
                    console.log(lsKind);
                    if (lsKind === "default") {
                      console.log(json[0]);
                      prot = new Protocol(json[0]);
                      prot.set(prot.parse(prot.attributes));
                      _this.model = prot;
                      console.log("should have gotten the protocol");
                    } else {
                      alert('Could not get protocol for code in this URL. Creating new protocol');
                    }
                  }
                  return _this.completeInitialization();
                };
              })(this)
            });
          } else {
            console.log("second to last else");
            return this.completeInitialization();
          }
        } else {
          console.log("last else");
          return this.completeInitialization();
        }
      }
    };

    ProtocolBaseController.prototype.completeInitialization = function() {
      console.log("complete initialization");
      if (this.model == null) {
        this.model = new Protocol();
      }
      this.errorOwnerName = 'ProtocolBaseController';
      console.log("setting bindings");
      this.setBindings();
      console.log("done setting bindings");
      $(this.el).empty();
      console.log("empty el");
      $(this.el).html(this.template(this.model.attributes));
      console.log("filling template");
      this.model.on('sync', (function(_this) {
        return function() {
          _this.trigger('amClean');
          _this.$('.bv_saving').hide();
          _this.$('.bv_updateComplete').show();
          _this.$('.bv_save').attr('disabled', 'disabled');
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
      this.setupTagList();
      this.model.getStatus().on('change', this.updateEditable);
      return this.render();
    };

    ProtocolBaseController.prototype.render = function() {
      console.log(this);
      console.log(this.model);
      if (this.model == null) {
        this.model = new Protocol();
        console.log("created new model");
      }
      this.$('.bv_assayTreeRule').val(this.model.getAssayTreeRule().get('stringValue'));
      this.$('.bv_assayPrinciple').val(this.model.getAssayPrinciple().get('clobValue'));
      ProtocolBaseController.__super__.render.call(this);
      return this;
    };

    ProtocolBaseController.prototype.handleAssayPrincipleChanged = function() {
      this.model.getAssayPrinciple().set({
        clobValue: UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_assayPrinciple')),
        recordedBy: this.model.get('recordedBy')
      });
      console.log("handleAssayPrincipleChanged");
      console.log(this.model.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "protocol metadata", "clobValue", "assay principle"));
      return console.log(this.model.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "experiment metadata", "clobValue", "assay principle"));
    };

    ProtocolBaseController.prototype.handleAssayTreeRuleChanged = function() {
      return this.model.getAssayTreeRule().set({
        stringValue: UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_assayTreeRule'))
      });
    };

    return ProtocolBaseController;

  })(BaseEntityController);

}).call(this);
