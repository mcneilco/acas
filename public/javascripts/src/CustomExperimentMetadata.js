(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.CustomMetadataValueController = (function(superClass) {
    extend(CustomMetadataValueController, superClass);

    function CustomMetadataValueController() {
      this.handleValueChanged = bind(this.handleValueChanged, this);
      this.handleValueInputChanged = bind(this.handleValueInputChanged, this);
      return CustomMetadataValueController.__super__.constructor.apply(this, arguments);
    }

    CustomMetadataValueController.prototype.template = _.template($("#CustomExperimentMetaDataValueView").html());

    CustomMetadataValueController.prototype.events = function() {
      return {
        "change .bv_value": "handleValueInputChanged"
      };
    };

    CustomMetadataValueController.prototype.initialize = function() {
      this.experiment = this.options.experiment;
      return this.lsType = this.model.get('lsType');
    };

    CustomMetadataValueController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      this.$('.bv_label').text(this.model.get('lsKind'));
      this.$('.bv_value').val(this.model.get(this.lsType));
      return this;
    };

    CustomMetadataValueController.prototype.handleValueInputChanged = function() {
      var value;
      value = UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_value'));
      return this.handleValueChanged(value);
    };

    CustomMetadataValueController.prototype.handleValueChanged = function(value) {
      var currentVal;
      currentVal = this.experiment.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "custom experiment metadata", this.model.get('lsType'), this.model.get('lsKind'));
      if (!currentVal.isNew()) {
        currentVal.set({
          ignored: true
        });
        currentVal = this.experiment.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "custom experiment metadata", this.model.get('lsType'), this.model.get('lsKind'));
      }
      currentVal.set(currentVal.get('lsType'), value);
      currentVal.set('codeType', this.model.get('codeType'));
      currentVal.set('codeKind', this.model.get('codeKind'));
      currentVal.set('codeOrigin', this.model.get('codeOrigin'));
      this.model = currentVal;
      return this;
    };

    return CustomMetadataValueController;

  })(Backbone.View);

  window.CustomMetadataClobValueController = (function(superClass) {
    extend(CustomMetadataClobValueController, superClass);

    function CustomMetadataClobValueController() {
      return CustomMetadataClobValueController.__super__.constructor.apply(this, arguments);
    }

    CustomMetadataClobValueController.prototype.template = _.template($("#CustomExperimentMetaDataClobValueView").html());

    return CustomMetadataClobValueController;

  })(CustomMetadataValueController);

  window.CustomMetadataCodeValueController = (function(superClass) {
    extend(CustomMetadataCodeValueController, superClass);

    function CustomMetadataCodeValueController() {
      return CustomMetadataCodeValueController.__super__.constructor.apply(this, arguments);
    }

    CustomMetadataCodeValueController.prototype.template = _.template($("#CustomExperimentMetaDataCodeValueView").html());

    CustomMetadataCodeValueController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      this.$('.bv_label').text(this.model.get('lsKind'));
      this.valueList = new PickListList();
      this.valueList.url = "/api/codetables/" + (this.model.get('codeType')) + "/" + (this.model.get('codeKind'));
      console.log(this.model.get('codeValue'));
      console.log(this.valueList);
      this.valueListController = new PickListSelectController({
        el: this.$('.bv_value'),
        collection: this.valueList,
        selectedCode: this.model.get('codeValue')
      });
      return this;
    };

    return CustomMetadataCodeValueController;

  })(CustomMetadataValueController);

  window.CustomMetadataNumericValueController = (function(superClass) {
    extend(CustomMetadataNumericValueController, superClass);

    function CustomMetadataNumericValueController() {
      return CustomMetadataNumericValueController.__super__.constructor.apply(this, arguments);
    }

    CustomMetadataNumericValueController.prototype.template = _.template($("#CustomExperimentMetaDataNumericValueView").html());

    CustomMetadataNumericValueController.prototype.events = function() {
      return {
        "keyup .bv_value": "handleValueInputChanged"
      };
    };

    return CustomMetadataNumericValueController;

  })(CustomMetadataValueController);

  window.CustomMetadataStringValueController = (function(superClass) {
    extend(CustomMetadataStringValueController, superClass);

    function CustomMetadataStringValueController() {
      return CustomMetadataStringValueController.__super__.constructor.apply(this, arguments);
    }

    CustomMetadataStringValueController.prototype.template = _.template($("#CustomExperimentMetaDataStringValueView").html());

    CustomMetadataStringValueController.prototype.events = function() {
      return {
        "keyup .bv_value": "handleValueInputChanged"
      };
    };

    return CustomMetadataStringValueController;

  })(CustomMetadataValueController);

  window.CustomMetadataURLValueController = (function(superClass) {
    extend(CustomMetadataURLValueController, superClass);

    function CustomMetadataURLValueController() {
      return CustomMetadataURLValueController.__super__.constructor.apply(this, arguments);
    }

    CustomMetadataURLValueController.prototype.template = _.template($("#CustomExperimentMetaDataURLValueView").html());

    CustomMetadataURLValueController.prototype.events = function() {
      return {
        "keyup .bv_value": "handleValueInputChanged",
        "click .bv_link_btn": "handleLinkButtonClicked"
      };
    };

    CustomMetadataURLValueController.prototype.handleLinkButtonClicked = function() {
      var url;
      url = UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_value'));
      return window.open(url);
    };

    return CustomMetadataURLValueController;

  })(CustomMetadataValueController);

  window.CustomExperimentMetadataListController = (function(superClass) {
    extend(CustomExperimentMetadataListController, superClass);

    function CustomExperimentMetadataListController() {
      this.getRenderValues = bind(this.getRenderValues, this);
      this.getGuiDescriptor = bind(this.getGuiDescriptor, this);
      this.render = bind(this.render, this);
      return CustomExperimentMetadataListController.__super__.constructor.apply(this, arguments);
    }

    CustomExperimentMetadataListController.prototype.template = _.template($("#CustomExperimentMetaDataListView").html());

    CustomExperimentMetadataListController.prototype.initialize = function() {
      var customExperimentMetaDataState, customExperimentMetaDataStateArray, experimentStates;
      experimentStates = this.model.get('lsStates');
      customExperimentMetaDataStateArray = experimentStates.getStatesByTypeAndKind("metadata", "custom experiment metadata");
      customExperimentMetaDataState = customExperimentMetaDataStateArray[0];
      this.lsState = customExperimentMetaDataState;
      return this.toRender = this.getRenderValues();
    };

    CustomExperimentMetadataListController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      return this.toRender.each((function(_this) {
        return function(value) {
          var customExperimentMetaDataValueControllerType, customMetadataValueController, type;
          type = value.get('lsType');
          customExperimentMetaDataValueControllerType = (function() {
            switch (type) {
              case "clobValue":
                return CustomMetadataClobValueController;
              case "codeValue":
                return CustomMetadataCodeValueController;
              case "numericValue":
                return CustomMetadataNumericValueController;
              case "stringValue":
                return CustomMetadataStringValueController;
              case "urlValue":
                return CustomMetadataURLValueController;
            }
          })();
          customMetadataValueController = new customExperimentMetaDataValueControllerType({
            model: value,
            experiment: _this.model
          });
          return _this.$('.bv_custom_metadata').append(customMetadataValueController.render().el);
        };
      })(this));
    };

    CustomExperimentMetadataListController.prototype.getGuiDescriptor = function() {
      var guiDescriptor, guiDescriptorValue;
      guiDescriptorValue = this.model.get('lsStates').getStateValueByTypeAndKind("metadata", "custom experiment metadata gui", "clobValue", "GUI descriptor");
      guiDescriptor = new Backbone.Collection(JSON.parse(guiDescriptorValue.get('clobValue')));
      return guiDescriptor;
    };

    CustomExperimentMetadataListController.prototype.getRenderValues = function() {
      var guiDescriptor, toRender, values;
      values = this.lsState.get('lsValues');
      guiDescriptor = this.getGuiDescriptor();
      values.comparator = (function(_this) {
        return function(value) {
          var order;
          order = guiDescriptor.filter(function(v) {
            return v.get('lsType') === value.get('lsType') && v.get('lsKind') === value.get('lsKind');
          });
          return order[0].get('displayOrder');
        };
      })(this);
      values.sort();
      values.comparator = void 0;
      toRender = values.filter(function(value) {
        return !value.get('ignored');
      });
      toRender = new Backbone.Collection(toRender);
      return toRender;
    };

    return CustomExperimentMetadataListController;

  })(Backbone.View);

}).call(this);
