(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.AssignedProperty = (function(superClass) {
    extend(AssignedProperty, superClass);

    function AssignedProperty() {
      return AssignedProperty.__super__.constructor.apply(this, arguments);
    }

    AssignedProperty.prototype.defaults = {
      sdfProp: "sdfProp",
      dbProp: "unassigned",
      defaultVal: ""
    };

    return AssignedProperty;

  })(Backbone.Model);

  window.AssignedPropertiesList = (function(superClass) {
    extend(AssignedPropertiesList, superClass);

    function AssignedPropertiesList() {
      return AssignedPropertiesList.__super__.constructor.apply(this, arguments);
    }

    AssignedPropertiesList.prototype.model = AssignedProperty;

    return AssignedPropertiesList;

  })(Backbone.Collection);

  window.AssignedPropController = (function(superClass) {
    extend(AssignedPropController, superClass);

    function AssignedPropController() {
      this.clear = bind(this.clear, this);
      this.render = bind(this.render, this);
      return AssignedPropController.__super__.constructor.apply(this, arguments);
    }

    AssignedPropController.prototype.template = _.template($("#AssignedPropView").html());

    AssignedPropController.prototype.className = "form-inline";

    AssignedPropController.prototype.events = {
      "click .bv_deleteProp": "clear"
    };

    AssignedPropController.prototype.initialize = function() {
      if (this.model == null) {
        this.model = new AssignedProperty();
      }
      this.errorOwnerName = 'AssignedPropController';
      this.setBindings();
      return this.model.on("destroy", this.remove, this);
    };

    AssignedPropController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template(this.model.attributes));
      this.$('.bv_sdfProp').html(this.model.get('sdfProp'));
      this.setupDbPropSelect();
      this.$('.bv_defaultVal').val(this.model.get('defaultVal'));
      return this;
    };

    AssignedPropController.prototype.setupDbPropSelect = function() {
      this.dbPropList = new PickListList();
      this.dbPropList.url = "/api/codetables/properties/database";
      return this.dbPropListController = new PickListSelectController({
        el: this.$('.bv_dbProp'),
        collection: this.dbPropList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select Database Property"
        }),
        selectedCode: this.model.get('dbProp')
      });
    };

    AssignedPropController.prototype.clear = function() {
      return this.model.destroy();
    };

    return AssignedPropController;

  })(AbstractFormController);

  window.AssignedPropListController = (function(superClass) {
    extend(AssignedPropListController, superClass);

    function AssignedPropListController() {
      this.addNewProp = bind(this.addNewProp, this);
      this.render = bind(this.render, this);
      this.initialize = bind(this.initialize, this);
      return AssignedPropListController.__super__.constructor.apply(this, arguments);
    }

    AssignedPropListController.prototype.template = _.template($("#AssignedPropListView").html());

    AssignedPropListController.prototype.events = {
      "click .bv_addDbProp": "addNewProp"
    };

    AssignedPropListController.prototype.initialize = function() {};

    AssignedPropListController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      this.collection.each((function(_this) {
        return function(prop) {
          return _this.addOneProp(prop);
        };
      })(this));
      return this;
    };

    AssignedPropListController.prototype.addNewProp = function() {
      var newModel;
      newModel = new AssignedProperty();
      this.collection.add(newModel);
      this.addOneProp(newModel);
      return newModel.trigger('amDirty');
    };

    AssignedPropListController.prototype.addOneProp = function(prop) {
      var apc;
      apc = new AssignedPropController({
        model: prop
      });
      return this.$('.bv_propInfo').append(apc.render().el);
    };

    return AssignedPropListController;

  })(Backbone.View);

  window.CmpdRegBulkLoaderAppController = (function(superClass) {
    extend(CmpdRegBulkLoaderAppController, superClass);

    function CmpdRegBulkLoaderAppController() {
      this.handleFileUpload = bind(this.handleFileUpload, this);
      this.setupBrowseFileController = bind(this.setupBrowseFileController, this);
      return CmpdRegBulkLoaderAppController.__super__.constructor.apply(this, arguments);
    }

    CmpdRegBulkLoaderAppController.prototype.template = _.template($("#CmpdRegBulkLoaderAppView").html());

    CmpdRegBulkLoaderAppController.prototype.initialize = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      $(this.el).addClass('CmpdRegBulkLoaderAppController');
      this.disableAllInputs();
      this.setupBrowseFileController();
      return this.setupAssignedPropListController();
    };

    CmpdRegBulkLoaderAppController.prototype.setupBrowseFileController = function() {
      this.browseFileController = new LSFileChooserController({
        el: this.$('.bv_browseFile'),
        formId: 'fieldBlah',
        maxNumberOfFiles: 1,
        requiresValidation: false,
        url: UtilityFunctions.prototype.getFileServiceURL(),
        allowedFileTypes: ['sdf']
      });
      this.browseFileController.on('amDirty', (function(_this) {
        return function() {
          return _this.trigger('amDirty');
        };
      })(this));
      this.browseFileController.on('amClean', (function(_this) {
        return function() {
          return _this.trigger('amClean');
        };
      })(this));
      this.browseFileController.render();
      this.browseFileController.on('fileUploader:uploadComplete', this.handleFileUpload);
      return this.browseFileController.on('fileDeleted', this.handleFileRemoved);
    };

    CmpdRegBulkLoaderAppController.prototype.handleFileUpload = function(nameOnServer, data) {
      console.log("file uploaded");
      return this.enableAllEditableInputs();
    };

    CmpdRegBulkLoaderAppController.prototype.setupAssignedPropListController = function() {
      this.assignedPropListController = new AssignedPropListController({
        el: this.$('.bv_assignedPropList'),
        collection: new AssignedPropertiesList()
      });
      return this.assignedPropListController.render();
    };

    CmpdRegBulkLoaderAppController.prototype.disableAllInputs = function() {
      this.$('input').attr('disabled', 'disabled');
      this.$('button').attr('disabled', 'disabled');
      this.$('select').attr('disabled', 'disabled');
      return this.$("textarea").attr('disabled', 'disabled');
    };

    CmpdRegBulkLoaderAppController.prototype.enableAllEditableInputs = function() {
      this.$('.bv_defaultVal').removeAttr('disabled');
      this.$('select').removeAttr('disabled');
      this.$('button').removeAttr('disabled');
      return this.$('.bv_regCmpds').attr('disabled', 'disabled');
    };

    return CmpdRegBulkLoaderAppController;

  })(Backbone.View);

}).call(this);
