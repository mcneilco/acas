(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.AddComponent = (function(_super) {
    __extends(AddComponent, _super);

    function AddComponent() {
      return AddComponent.__super__.constructor.apply(this, arguments);
    }

    AddComponent.prototype.defaults = function() {
      return {
        componentType: "unassigned"
      };
    };

    return AddComponent;

  })(Backbone.Model);

  window.ComponentCodeName = (function(_super) {
    __extends(ComponentCodeName, _super);

    function ComponentCodeName() {
      return ComponentCodeName.__super__.constructor.apply(this, arguments);
    }

    ComponentCodeName.prototype.defaults = function() {
      return {
        componentType: "",
        componentCodeName: "unassigned"
      };
    };

    ComponentCodeName.prototype.validate = function(attrs) {
      var errors;
      errors = [];
      if (attrs.componentCodeName === "unassigned" || attrs.componentCodeName === "") {
        errors.push({
          attribute: 'componentCodeName',
          message: "ID must be selected"
        });
      }
      if (errors.length > 0) {
        return errors;
      } else {
        return null;
      }
    };

    return ComponentCodeName;

  })(Backbone.Model);

  window.ComponentCodeNamesList = (function(_super) {
    __extends(ComponentCodeNamesList, _super);

    function ComponentCodeNamesList() {
      return ComponentCodeNamesList.__super__.constructor.apply(this, arguments);
    }

    ComponentCodeNamesList.prototype.model = ComponentCodeName;

    return ComponentCodeNamesList;

  })(Backbone.Collection);

  window.AddComponentController = (function(_super) {
    __extends(AddComponentController, _super);

    function AddComponentController() {
      this.updateModel = __bind(this.updateModel, this);
      this.render = __bind(this.render, this);
      return AddComponentController.__super__.constructor.apply(this, arguments);
    }

    AddComponentController.prototype.template = _.template($("#AddComponentView").html());

    AddComponentController.prototype.events = {
      "change .bv_addComponentSelect": "updateModel",
      "click .bv_addComponentButton": "handleAddComponentClicked"
    };

    AddComponentController.prototype.initialize = function() {
      if (this.model == null) {
        return this.model = new AddComponent();
      }
    };

    AddComponentController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      this.setUpAddComponentSelect();
      return this;
    };

    AddComponentController.prototype.updateModel = function() {
      this.model.set({
        componentType: this.componentTypeListController.getSelectedCode()
      });
      return this.trigger('amDirty');
    };

    AddComponentController.prototype.setUpAddComponentSelect = function() {
      this.componentTypeList = new PickListList();
      this.componentTypeList.url = "/api/dataDict/subcomponents/internalization agent";
      return this.componentTypeListController = new PickListSelectController({
        el: this.$('.bv_addComponentSelect'),
        collection: this.componentTypeList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select Component"
        }),
        selectedCode: this.model.get('componentType')
      });
    };

    AddComponentController.prototype.handleAddComponentClicked = function() {
      return this.trigger('addComponent');
    };

    return AddComponentController;

  })(Backbone.View);

  window.ComponentCodeNameController = (function(_super) {
    __extends(ComponentCodeNameController, _super);

    function ComponentCodeNameController() {
      this.clear = __bind(this.clear, this);
      this.updateModel = __bind(this.updateModel, this);
      this.render = __bind(this.render, this);
      return ComponentCodeNameController.__super__.constructor.apply(this, arguments);
    }

    ComponentCodeNameController.prototype.template = _.template($("#ComponentCodeNameView").html());

    ComponentCodeNameController.prototype.events = {
      "change .bv_componentCodeName": "attributeChanged",
      "click .bv_deleteComponent": "clear"
    };

    ComponentCodeNameController.prototype.initialize = function() {
      if (this.model == null) {
        this.model = new ComponentCodeName();
      }
      this.errorOwnerName = 'ComponentCodeNameController';
      this.setBindings();
      return this.model.on("destroy", this.remove, this);
    };

    ComponentCodeNameController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      this.$('.bv_componentType').html(this.model.get('componentType'));
      this.setUpComponentCodeNameSelect();
      return this;
    };

    ComponentCodeNameController.prototype.updateModel = function() {
      return this.model.set({
        componentCodeName: this.componentCodeNameListController.getSelectedCode()
      });
    };

    ComponentCodeNameController.prototype.setUpComponentCodeNameSelect = function() {
      this.componentCodeNameList = new PickListList();
      this.componentCodeNameList.url = "/api/dataDict/codeNames/" + this.model.get('componentType').toLowerCase();
      return this.componentCodeNameListController = new PickListSelectController({
        el: this.$('.bv_componentCodeName'),
        collection: this.componentCodeNameList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select Component ID"
        }),
        selectedCode: this.model.get('componentCodeName')
      });
    };

    ComponentCodeNameController.prototype.clear = function() {
      return this.model.destroy();
    };

    return ComponentCodeNameController;

  })(AbstractFormController);

  window.ComponentCodeNamesListController = (function(_super) {
    __extends(ComponentCodeNamesListController, _super);

    function ComponentCodeNamesListController() {
      this.addNewComponentSelect = __bind(this.addNewComponentSelect, this);
      this.render = __bind(this.render, this);
      return ComponentCodeNamesListController.__super__.constructor.apply(this, arguments);
    }

    ComponentCodeNamesListController.prototype.template = _.template($("#ComponentCodeNamesListView").html());

    ComponentCodeNamesListController.prototype.initialize = function() {
      if (this.collection == null) {
        return this.collection = new ComponentCodeNamesList();
      }
    };

    ComponentCodeNamesListController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      this.collection.each((function(_this) {
        return function(component) {
          return _this.addComponentSelect(component);
        };
      })(this));
      return this;
    };

    ComponentCodeNamesListController.prototype.addNewComponentSelect = function(componentType) {
      var newModel;
      newModel = new ComponentCodeName({
        componentType: componentType
      });
      this.collection.add(newModel);
      return this.addComponentSelect(newModel);
    };

    ComponentCodeNamesListController.prototype.addComponentSelect = function(component) {
      var ccnc;
      ccnc = new ComponentCodeNameController({
        model: component
      });
      return this.$('.bv_componentInfo').append(ccnc.render().el);
    };

    return ComponentCodeNamesListController;

  })(AbstractFormController);

  window.ComponentPickerController = (function(_super) {
    __extends(ComponentPickerController, _super);

    function ComponentPickerController() {
      return ComponentPickerController.__super__.constructor.apply(this, arguments);
    }

    ComponentPickerController.prototype.template = _.template($("#ComponentPickerView").html());

    ComponentPickerController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      this.setupAddComponentController();
      this.setupComponentCodeNamesListController();
      return this;
    };

    ComponentPickerController.prototype.setupAddComponentController = function() {
      this.addComponentController = new AddComponentController({
        model: new AddComponent(),
        el: this.$('.bv_addComponentWrapper')
      });
      this.addComponentController.on('amDirty', (function(_this) {
        return function() {
          return _this.trigger('amDirty');
        };
      })(this));
      this.addComponentController.on('amClean', (function(_this) {
        return function() {
          return _this.trigger('amClean');
        };
      })(this));
      this.addComponentController.on('addComponent', (function(_this) {
        return function() {
          return _this.addNewComponentCodeNameController();
        };
      })(this));
      return this.addComponentController.render();
    };

    ComponentPickerController.prototype.setupComponentCodeNamesListController = function() {
      this.codeNamesListController = new ComponentCodeNamesListController({
        collection: new ComponentCodeNamesList(),
        el: this.$('.bv_codeNamesListWrapper')
      });
      this.codeNamesListController.on('amDirty', (function(_this) {
        return function() {
          return _this.trigger('amDirty');
        };
      })(this));
      this.codeNamesListController.on('amClean', (function(_this) {
        return function() {
          return _this.trigger('amClean');
        };
      })(this));
      return this.codeNamesListController.render();
    };

    ComponentPickerController.prototype.addNewComponentCodeNameController = function() {
      var componentType;
      console.log("addNewComponentCodeNameController");
      componentType = this.addComponentController.componentTypeListController.getSelectedCode();
      if (componentType !== "unassigned") {
        return this.codeNamesListController.addNewComponentSelect(this.addComponentController.componentTypeListController.getSelectedCode());
      }
    };

    return ComponentPickerController;

  })(Backbone.View);

}).call(this);
