(function() {
  var _ref, _ref1, _ref2, _ref3, _ref4, _ref5,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.ExperimentValue = (function(_super) {
    __extends(ExperimentValue, _super);

    function ExperimentValue() {
      _ref = ExperimentValue.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    return ExperimentValue;

  })(Backbone.Model);

  window.ExperimentValueList = (function(_super) {
    __extends(ExperimentValueList, _super);

    function ExperimentValueList() {
      _ref1 = ExperimentValueList.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    ExperimentValueList.prototype.model = ExperimentValue;

    return ExperimentValueList;

  })(Backbone.Collection);

  window.ExperimentState = (function(_super) {
    __extends(ExperimentState, _super);

    function ExperimentState() {
      _ref2 = ExperimentState.__super__.constructor.apply(this, arguments);
      return _ref2;
    }

    ExperimentState.prototype.defaults = {
      experimentValues: new ExperimentValueList()
    };

    ExperimentState.prototype.initialize = function() {
      var _this = this;
      if (this.has('experimentValues')) {
        if (!(this.get('experimentValues') instanceof ExperimentValueList)) {
          this.set({
            experimentValues: new ExperimentValueList(this.get('experimentValues'))
          });
        }
      }
      return this.get('experimentValues').on('change', function() {
        return _this.trigger('change');
      });
    };

    ExperimentState.prototype.parse = function(resp) {
      var _this = this;
      if (resp.experimentValues != null) {
        if (!(resp.experimentValues instanceof ExperimentValueList)) {
          resp.experimentValues = new ExperimentValueList(resp.experimentValues);
          resp.experimentValues.on('change', function() {
            return _this.trigger('change');
          });
        }
      }
      return resp;
    };

    ExperimentState.prototype.getValuesByTypeAndKind = function(type, kind) {
      return this.get('experimentValues').filter(function(value) {
        return (!value.get('ignored')) && (value.get('valueType') === type) && (value.get('valueKind') === kind);
      });
    };

    return ExperimentState;

  })(Backbone.Model);

  window.ExperimentStateList = (function(_super) {
    __extends(ExperimentStateList, _super);

    function ExperimentStateList() {
      _ref3 = ExperimentStateList.__super__.constructor.apply(this, arguments);
      return _ref3;
    }

    ExperimentStateList.prototype.model = ExperimentState;

    ExperimentStateList.prototype.getStatesByTypeAndKind = function(type, kind) {
      return this.filter(function(state) {
        return (!state.get('ignored')) && (state.get('stateType') === type) && (state.get('stateKind') === kind);
      });
    };

    ExperimentStateList.prototype.getStateValueByTypeAndKind = function(stype, skind, vtype, vkind) {
      var states, value, values;
      value = null;
      states = this.getStatesByTypeAndKind(stype, skind);
      if (states.length > 0) {
        values = states[0].getValuesByTypeAndKind(vtype, vkind);
        if (values.length > 0) {
          value = values[0];
        }
      }
      return value;
    };

    return ExperimentStateList;

  })(Backbone.Collection);

  window.Experiment = (function(_super) {
    __extends(Experiment, _super);

    function Experiment() {
      this.fixCompositeClasses = __bind(this.fixCompositeClasses, this);
      this.parse = __bind(this.parse, this);
      _ref4 = Experiment.__super__.constructor.apply(this, arguments);
      return _ref4;
    }

    Experiment.prototype.urlRoot = "/api/experiments";

    Experiment.prototype.defaults = {
      kind: "",
      recordedBy: "",
      recordedDate: null,
      shortDescription: "",
      experimentLabels: new LabelList(),
      experimentStates: new ExperimentStateList(),
      protocol: null,
      analysisGroups: new AnalysisGroupList()
    };

    Experiment.prototype.initialize = function() {
      this.fixCompositeClasses();
      return this.setupCompositeChangeTriggers();
    };

    Experiment.prototype.parse = function(resp) {
      var _this = this;
      if (resp.experimentLabels != null) {
        if (!(resp.experimentLabels instanceof LabelList)) {
          resp.experimentLabels = new LabelList(resp.experimentLabels);
          resp.experimentLabels.on('change', function() {
            return _this.trigger('change');
          });
        }
      }
      if (resp.experimentStates != null) {
        if (!(resp.experimentStates instanceof ExperimentStateList)) {
          resp.experimentStates = new ExperimentStateList(resp.experimentStates);
          resp.experimentStates.on('change', function() {
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
      if (this.has('experimentLabels')) {
        if (!(this.get('experimentLabels') instanceof LabelList)) {
          this.set({
            experimentLabels: new LabelList(this.get('experimentLabels'))
          });
        }
      }
      if (this.has('experimentStates')) {
        if (!(this.get('experimentStates') instanceof ExperimentStateList)) {
          this.set({
            experimentStates: new ExperimentStateList(this.get('experimentStates'))
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
      this.get('experimentLabels').on('change', function() {
        return _this.trigger('change');
      });
      return this.get('experimentStates').on('change', function() {
        return _this.trigger('change');
      });
    };

    Experiment.prototype.copyProtocolAttributes = function(protocol) {
      var estates, pstates;
      estates = new ExperimentStateList();
      pstates = protocol.get('protocolStates');
      pstates.each(function(st) {
        var estate, evals, svals;
        estate = new ExperimentState(_.clone(st.attributes));
        estate.unset('id');
        estate.unset('lsTransaction');
        estate.unset('protocolValues');
        evals = new ExperimentValueList();
        svals = st.get('protocolValues');
        svals.each(function(sv) {
          var evalue;
          evalue = new ProtocolValue(sv.attributes);
          evalue.unset('id');
          evalue.unset('lsTransaction');
          return evals.add(evalue);
        });
        estate.set({
          experimentValues: evals
        });
        return estates.add(estate);
      });
      this.set({
        kind: protocol.get('kind'),
        protocol: protocol,
        shortDescription: protocol.get('shortDescription'),
        experimentStates: estates
      });
      this.trigger("protocol_attributes_copied");
    };

    Experiment.prototype.validate = function(attrs) {
      var bestName, errors, nameError;
      errors = [];
      bestName = attrs.experimentLabels.pickBestName();
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
      if (errors.length > 0) {
        return errors;
      } else {
        return null;
      }
    };

    return Experiment;

  })(Backbone.Model);

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
      _ref5 = ExperimentBaseController.__super__.constructor.apply(this, arguments);
      return _ref5;
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
      return this.setBindings();
    };

    ExperimentBaseController.prototype.render = function() {
      var bestName, date;
      $(this.el).empty();
      $(this.el).html(this.template());
      if (this.model.get('protocol') !== null) {
        this.$('.bv_protocolCode').val(this.model.get('protocol').get('codeName'));
      }
      this.$('.bv_shortDescription').html(this.model.get('shortDescription'));
      this.$('.bv_description').html(this.model.get('description'));
      bestName = this.model.get('experimentLabels').pickBestName();
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
      this.$('.bv_description').html(this.getDescriptionValue());
      return this;
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
              newProtName = _this.model.get('protocol').get('protocolLabels').pickBestLabel().get('labelText');
              _this.updateProtocolNameField(newProtName);
              return _this.setUseProtocolParametersDisabledState();
            }
          });
        } else {
          return this.updateProtocolNameField(this.model.get('protocol').get('protocolLabels').pickBestLabel().get('labelText'));
        }
      } else {
        return this.updateProtocolNameField("no protocol selected yet");
      }
    };

    ExperimentBaseController.prototype.updateProtocolNameField = function(protocolName) {
      return this.$('.bv_protocolName').html(protocolName);
    };

    ExperimentBaseController.prototype.getDescriptionValue = function() {
      var desc, value;
      value = this.model.get('experimentStates').getStateValueByTypeAndKind("metadata", "experiment info", "stringValue", "description");
      desc = "";
      if (value !== null) {
        desc = value.get('stringValue');
      }
      return desc;
    };

    ExperimentBaseController.prototype.handleRecordedByChanged = function() {
      this.model.set({
        recordedBy: this.$('.bv_recordedBy').val()
      });
      return this.handleNameChanged();
    };

    ExperimentBaseController.prototype.handleShortDescriptionChanged = function() {
      return this.model.set({
        shortDescription: this.$('.bv_shortDescription').val().trim()
      });
    };

    ExperimentBaseController.prototype.handleDescriptionChanged = function() {
      return this.model.set({
        description: this.$('.bv_description').val().trim()
      });
    };

    ExperimentBaseController.prototype.handleNameChanged = function() {
      var newName;
      newName = this.$('.bv_experimentName').val().trim();
      return this.model.get('experimentLabels').setBestName(new Label({
        labelKind: "experiment name",
        labelText: newName,
        recordedBy: this.model.get('recordedBy'),
        recordedDate: this.model.get('recordedDate')
      }));
    };

    ExperimentBaseController.prototype.handleDateChanged = function() {
      this.model.set({
        recordedDate: new Date(this.$('.bv_recordedDate').val().trim()).getTime()
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
      if (code === "") {
        this.model.set({
          'protocol': null
        });
        this.getAndShowProtocolName();
        return this.setUseProtocolParametersDisabledState();
      } else {
        return $.ajax({
          type: 'GET',
          url: "api/protocols/codename/" + code,
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
            return console.log('got ajax error');
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
