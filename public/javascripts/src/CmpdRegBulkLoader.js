(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.SdfProperty = (function(superClass) {
    extend(SdfProperty, superClass);

    function SdfProperty() {
      return SdfProperty.__super__.constructor.apply(this, arguments);
    }

    return SdfProperty;

  })(Backbone.Model);

  window.SdfPropertiesList = (function(superClass) {
    extend(SdfPropertiesList, superClass);

    function SdfPropertiesList() {
      return SdfPropertiesList.__super__.constructor.apply(this, arguments);
    }

    SdfPropertiesList.prototype.model = SdfProperty;

    return SdfPropertiesList;

  })(Backbone.Collection);

  window.DbProperty = (function(superClass) {
    extend(DbProperty, superClass);

    function DbProperty() {
      return DbProperty.__super__.constructor.apply(this, arguments);
    }

    return DbProperty;

  })(Backbone.Model);

  window.DbPropertiesList = (function(superClass) {
    extend(DbPropertiesList, superClass);

    function DbPropertiesList() {
      return DbPropertiesList.__super__.constructor.apply(this, arguments);
    }

    DbPropertiesList.prototype.model = DbProperty;

    DbPropertiesList.prototype.getRequired = function() {
      return this.filter(function(prop) {
        return prop.get('required');
      });
    };

    return DbPropertiesList;

  })(Backbone.Collection);

  window.AssignedProperty = (function(superClass) {
    extend(AssignedProperty, superClass);

    function AssignedProperty() {
      this.validate = bind(this.validate, this);
      return AssignedProperty.__super__.constructor.apply(this, arguments);
    }

    AssignedProperty.prototype.defaults = {
      sdfProperty: null,
      dbProperty: "none",
      defaultVal: "",
      required: false
    };

    AssignedProperty.prototype.validate = function(attrs) {
      var errors;
      errors = [];
      if (attrs.required && attrs.dbProperty !== "corporate id" && attrs.defaultVal === "") {
        errors.push({
          attribute: 'defaultVal',
          message: 'A default value must be assigned'
        });
      }
      if (errors.length > 0) {
        return errors;
      } else {
        return null;
      }
    };

    return AssignedProperty;

  })(Backbone.Model);

  window.AssignedPropertiesList = (function(superClass) {
    extend(AssignedPropertiesList, superClass);

    function AssignedPropertiesList() {
      this.checkDuplicates = bind(this.checkDuplicates, this);
      return AssignedPropertiesList.__super__.constructor.apply(this, arguments);
    }

    AssignedPropertiesList.prototype.model = AssignedProperty;

    AssignedPropertiesList.prototype.checkDuplicates = function() {
      var assignedDbProps, currentDbProp, duplicates, i, index, model, ref;
      console.log("check duplicates");
      duplicates = [];
      assignedDbProps = {};
      if (this.length !== 0) {
        for (index = i = 0, ref = this.length - 1; 0 <= ref ? i <= ref : i >= ref; index = 0 <= ref ? ++i : --i) {
          model = this.at(index);
          currentDbProp = model.get('dbProperty');
          console.log(currentDbProp);
          if (currentDbProp !== "none") {
            if (currentDbProp in assignedDbProps) {
              duplicates.push({
                attribute: 'dbProperty:eq(' + index + ')',
                message: "Database property can not be assigned more than once"
              });
              duplicates.push({
                attribute: 'dbProperty:eq(' + assignedDbProps[currentDbProp] + ')',
                message: "Database property can not be assigned more than once"
              });
            } else {
              assignedDbProps[currentDbProp] = index;
            }
          }
        }
      }
      console.log(assignedDbProps);
      console.log(duplicates);
      return duplicates;
    };

    return AssignedPropertiesList;

  })(Backbone.Collection);

  window.DetectSdfPropertiesController = (function(superClass) {
    extend(DetectSdfPropertiesController, superClass);

    function DetectSdfPropertiesController() {
      this.handleTemplateChanged = bind(this.handleTemplateChanged, this);
      this.handleFileRemoved = bind(this.handleFileRemoved, this);
      this.getProperties = bind(this.getProperties, this);
      this.handleFileUploaded = bind(this.handleFileUploaded, this);
      this.setupBrowseFileController = bind(this.setupBrowseFileController, this);
      return DetectSdfPropertiesController.__super__.constructor.apply(this, arguments);
    }

    DetectSdfPropertiesController.prototype.template = _.template($("#DetectSdfPropertiesView").html());

    DetectSdfPropertiesController.prototype.events = function() {
      return {
        "click .bv_readMore": "readMoreRecords",
        "click .bv_readAll": "readAllRecords"
      };
    };

    DetectSdfPropertiesController.prototype.initialize = function() {
      this.numRecords = 100;
      return this.temp = "none";
    };

    DetectSdfPropertiesController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      this.disableInputs();
      return this.setupBrowseFileController();
    };

    DetectSdfPropertiesController.prototype.setupBrowseFileController = function() {
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
      this.browseFileController.on('fileUploader:uploadComplete', this.handleFileUploaded);
      return this.browseFileController.on('fileDeleted', this.handleFileRemoved);
    };

    DetectSdfPropertiesController.prototype.handleFileUploaded = function(fileName) {
      console.log("file uploaded");
      this.fileName = fileName;
      return this.getProperties();
    };

    DetectSdfPropertiesController.prototype.getProperties = function() {
      var sdfInfo;
      this.$('.bv_detectedSdfPropertiesList').html("Loading...");
      this.disableInputs();
      this.$('.bv_deleteFile').attr('disabled', 'disabled');
      sdfInfo = {
        fileName: this.fileName,
        numRecords: this.numRecords,
        template: this.temp
      };
      return $.ajax({
        type: 'POST',
        url: "/api/cmpdRegBulkLoader/readSDF",
        data: sdfInfo,
        success: (function(_this) {
          return function(response) {
            console.log("successful read of SDF");
            _this.handlePropertiesDetected(response);
            return _this.$('.bv_deleteFile').removeAttr('disabled');
          };
        })(this),
        error: (function(_this) {
          return function(err) {
            return _this.serviceReturn = null;
          };
        })(this),
        dataType: 'json'
      });
    };

    DetectSdfPropertiesController.prototype.handlePropertiesDetected = function(response) {
      console.log("handle properties detected");
      console.log(response);
      console.log(this.numRecords);
      return this.trigger('propsDetected', response);
    };

    DetectSdfPropertiesController.prototype.handleFileRemoved = function() {
      console.log("sdf file removed");
      this.disableInputs();
      this.$('.bv_detectedSdfPropertiesList').html("");
      this.fileName = null;
      this.numRecords = 100;
      this.$('.bv_recordsRead').html(0);
      return this.trigger('resetAssignProps');
    };

    DetectSdfPropertiesController.prototype.showSdfProperties = function(sdfPropsList) {
      var newLine, props;
      this.$('.bv_recordsRead').html(this.numRecords);
      console.log("show SDF props");
      console.log(sdfPropsList);
      newLine = "&#13;&#10;";
      props = "";
      sdfPropsList.each(function(prop) {
        console.log(prop.get('name'));
        if (props === "") {
          return props = prop.get('name');
        } else {
          return props += newLine + prop.get('name');
        }
      });
      if (props === "") {
        props = "No SDF Properties Detected";
      }
      this.$('.bv_detectedSdfPropertiesList').html(props);
      this.$('.bv_readMore').removeAttr('disabled');
      return this.$('.bv_readAll').removeAttr('disabled');
    };

    DetectSdfPropertiesController.prototype.disableInputs = function() {
      this.$('.bv_readMore').attr('disabled', 'disabled');
      return this.$('.bv_readAll').attr('disabled', 'disabled');
    };

    DetectSdfPropertiesController.prototype.readMoreRecords = function() {
      this.numRecords += 100;
      return this.getProperties();
    };

    DetectSdfPropertiesController.prototype.readAllRecords = function() {
      return this.getProperties();
    };

    DetectSdfPropertiesController.prototype.handleTemplateChanged = function(template) {
      this.temp = template;
      if ((this.fileName != null) && this.fileName !== null) {
        return this.getProperties();
      }
    };

    return DetectSdfPropertiesController;

  })(Backbone.View);

  window.AssignedPropertyController = (function(superClass) {
    extend(AssignedPropertyController, superClass);

    function AssignedPropertyController() {
      this.clear = bind(this.clear, this);
      this.render = bind(this.render, this);
      return AssignedPropertyController.__super__.constructor.apply(this, arguments);
    }

    AssignedPropertyController.prototype.template = _.template($("#AssignedPropertyView").html());

    AssignedPropertyController.prototype.className = "form-inline";

    AssignedPropertyController.prototype.events = {
      "change .bv_dbProperty": "handleDbPropertyChanged",
      "keyup .bv_defaultVal": "handleDefaultValChanged",
      "click .bv_deleteProperty": "clear"
    };

    AssignedPropertyController.prototype.initialize = function() {
      if (this.model == null) {
        this.model = new AssignedProperty();
      }
      this.errorOwnerName = 'AssignedPropertyController';
      this.setBindings();
      this.model.on("destroy", this.remove, this);
      if (this.options.dbPropertiesList != null) {
        return this.dbPropertiesList = this.options.dbPropertiesList;
      } else {
        return this.dbPropertiesList = new DbPropertiesList();
      }
    };

    AssignedPropertyController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template(this.model.attributes));
      this.$('.bv_sdfProperty').html(this.model.get('sdfProperty'));
      this.setupDbPropertiesSelect();
      this.$('.bv_defaultVal').val(this.model.get('defaultVal'));
      console.log("dbProp");
      console.log(this.model.get('dbProperty'));
      if (this.model.get('dbProperty') === "none") {
        console.log("disabling");
        this.$('.bv_defaultVal').attr('disabled', 'disabled');
      }
      return this;
    };

    AssignedPropertyController.prototype.setupDbPropertiesSelect = function() {
      var formattedDbProperties;
      formattedDbProperties = this.formatDbSelectOptions();
      return this.dbPropertiesListController = new PickListSelectController({
        el: this.$('.bv_dbProperty'),
        collection: formattedDbProperties,
        insertFirstOption: new PickList({
          code: "none",
          name: "None"
        }),
        selectedCode: this.model.get('dbProperty'),
        autoFetch: false
      });
    };

    AssignedPropertyController.prototype.formatDbSelectOptions = function() {
      var formattedOptions;
      formattedOptions = new PickListList();
      this.dbPropertiesList.each(function(dbProp) {
        var code, name, newOption;
        code = dbProp.get('name');
        if (dbProp.get('required')) {
          name = code + "*";
        } else {
          name = code;
        }
        newOption = new PickList({
          code: code,
          name: name
        });
        return formattedOptions.add(newOption);
      });
      return formattedOptions;
    };

    AssignedPropertyController.prototype.handleDbPropertyChanged = function() {
      var dbProp, propInfo;
      console.log("handle db prop changed");
      dbProp = this.dbPropertiesListController.getSelectedCode();
      console.log(dbProp);
      if (dbProp === "none" || dbProp === "corporate id") {
        this.$('.bv_defaultVal').attr('disabled', 'disabled');
      } else {
        this.$('.bv_defaultVal').removeAttr('disabled');
      }
      propInfo = this.dbPropertiesList.findWhere({
        name: dbProp
      });
      if (propInfo.get('required')) {
        this.model.set({
          required: true
        });
      }
      this.model.set({
        dbProperty: dbProp
      });
      return this.trigger('assignedDbPropChanged');
    };

    AssignedPropertyController.prototype.handleDefaultValChanged = function() {
      return this.model.set({
        defaultVal: UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_defaultVal'))
      });
    };

    AssignedPropertyController.prototype.clear = function() {
      return this.model.destroy();
    };

    return AssignedPropertyController;

  })(AbstractFormController);

  window.AssignedPropertiesListController = (function(superClass) {
    extend(AssignedPropertiesListController, superClass);

    function AssignedPropertiesListController() {
      this.addNewProperty = bind(this.addNewProperty, this);
      this.render = bind(this.render, this);
      return AssignedPropertiesListController.__super__.constructor.apply(this, arguments);
    }

    AssignedPropertiesListController.prototype.template = _.template($("#AssignedPropertiesListView").html());

    AssignedPropertiesListController.prototype.events = {
      "click .bv_addDbProperty": "addNewProperty"
    };

    AssignedPropertiesListController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      this.collection.each((function(_this) {
        return function(prop) {
          return _this.addOneProperty(prop, false);
        };
      })(this));
      return this;
    };

    AssignedPropertiesListController.prototype.addNewProperty = function() {
      var newModel;
      newModel = new AssignedProperty();
      this.collection.add(newModel);
      this.addOneProperty(newModel, true);
      return newModel.trigger('amDirty');
    };

    AssignedPropertiesListController.prototype.addOneProperty = function(prop, canDelete) {
      var apc;
      console.log("add one prop");
      console.log(this.dbPropertiesList);
      apc = new AssignedPropertyController({
        model: prop,
        dbPropertiesList: this.dbPropertiesList
      });
      apc.on('assignedDbPropChanged', (function(_this) {
        return function() {
          return _this.trigger('assignedDbPropChanged');
        };
      })(this));
      this.$('.bv_propInfo').append(apc.render().el);
      if (canDelete) {
        return apc.$('.bv_deleteProperty').show();
      }
    };

    return AssignedPropertiesListController;

  })(AbstractFormController);

  window.AssignSdfPropertiesController = (function(superClass) {
    extend(AssignSdfPropertiesController, superClass);

    function AssignSdfPropertiesController() {
      this.showNameTemplateError = bind(this.showNameTemplateError, this);
      this.clearValidationErrorStyles = bind(this.clearValidationErrorStyles, this);
      this.isValid = bind(this.isValid, this);
      this.handleOverwriteRadioSelectChanged = bind(this.handleOverwriteRadioSelectChanged, this);
      return AssignSdfPropertiesController.__super__.constructor.apply(this, arguments);
    }

    AssignSdfPropertiesController.prototype.template = _.template($("#AssignSdfPropertiesView").html());

    AssignSdfPropertiesController.prototype.events = {
      "change .bv_useTemplate": "handleTemplateChanged",
      "change .bv_saveTemplate": "handleSaveTemplateCheckboxChanged",
      "keyup .bv_templateName": "handleNameTemplateChanged",
      "change .bv_overwrite": "handleOverwriteRadioSelectChanged",
      "click .bv_regCmpds": "handleRegCmpdsClicked"
    };

    AssignSdfPropertiesController.prototype.initialize = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      this.setupTemplateSelect();
      return this.setupAssignedPropertiesListController();
    };

    AssignSdfPropertiesController.prototype.setupTemplateSelect = function() {
      this.templateList = new PickListList();
      this.templateList.url = "/api/codetables/properties/templates";
      return this.templateListController = new PickListSelectController({
        el: this.$('.bv_useTemplate'),
        collection: this.templateList,
        insertFirstOption: new PickList({
          code: "none",
          name: "None"
        }),
        selectedCode: "none"
      });
    };

    AssignSdfPropertiesController.prototype.setupAssignedPropertiesListController = function() {
      this.assignedPropertiesListController = new AssignedPropertiesListController({
        el: this.$('.bv_assignedPropertiesList'),
        collection: new AssignedPropertiesList()
      });
      this.assignedPropertiesListController.on('assignedDbPropChanged', (function(_this) {
        return function() {
          return _this.showUnassignedDbProperties();
        };
      })(this));
      return this.assignedPropertiesListController.render();
    };

    AssignSdfPropertiesController.prototype.createPropertyCollections = function(properties) {
      console.log("handle props detected in app controller");
      console.log(properties);
      console.log(properties.sdfProperties);
      this.sdfPropertiesList = new SdfPropertiesList(properties.sdfProperties);
      this.dbPropertiesList = new DbPropertiesList(properties.dbProperties);
      this.assignedPropertiesList = new AssignedPropertiesList(properties.autoMagicProperties);
      this.assignedPropertiesList.on('change', (function(_this) {
        return function() {
          return _this.isValid();
        };
      })(this));
      this.addUnassignedSdfProperties();
      this.assignedPropertiesListController.collection = this.assignedPropertiesList;
      this.assignedPropertiesListController.dbPropertiesList = this.dbPropertiesList;
      this.assignedPropertiesListController.render();
      this.showUnassignedDbProperties();
      this.$('.bv_addDbProperty').removeAttr('disabled');
      return this.isValid();
    };

    AssignSdfPropertiesController.prototype.addUnassignedSdfProperties = function() {
      console.log("add unassigned sdf props");
      console.log(this.sdfPropertiesList);
      console.log(this.assignedPropertiesList);
      return this.sdfPropertiesList.each((function(_this) {
        return function(sdfProp) {
          var newAssignedProp, sdfProperty;
          sdfProperty = sdfProp.get('name');
          if (_this.assignedPropertiesList.findWhere({
            sdfProperty: sdfProperty
          }) == null) {
            newAssignedProp = new AssignedProperty({
              dbProperty: "none",
              required: false,
              sdfProperty: sdfProperty
            });
            return _this.assignedPropertiesList.add(newAssignedProp);
          }
        };
      })(this));
    };

    AssignSdfPropertiesController.prototype.handleTemplateChanged = function() {
      var template;
      template = this.templateListController.getSelectedCode();
      return this.trigger('templateChanged', template);
    };

    AssignSdfPropertiesController.prototype.handleSaveTemplateCheckboxChanged = function() {
      var currentTempName, saveTemplateChecked;
      console.log("checkbox changed");
      saveTemplateChecked = this.$('.bv_saveTemplate').is(":checked");
      console.log(saveTemplateChecked);
      if (saveTemplateChecked) {
        this.$('.bv_templateName').removeAttr('disabled');
        currentTempName = this.templateListController.getSelectedCode();
        console.log(currentTempName);
        if (currentTempName === "none") {
          this.$('.bv_templateName').val("");
        } else {
          this.$('.bv_templateName').val(currentTempName);
        }
      } else {
        this.$('.bv_templateName').val("");
        this.$('.bv_templateName').attr('disabled', 'disabled');
      }
      this.$('.bv_templateName').keyup();
      return this.isValid();
    };

    AssignSdfPropertiesController.prototype.handleNameTemplateChanged = function() {
      var tempName;
      tempName = UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_templateName'));
      console.log("new TempName");
      console.log(tempName);
      if (this.templateList.findWhere({
        name: tempName
      }) != null) {
        this.$('.bv_overwriteMessage').html(tempName + " already exists. Overwrite?");
        this.$('.bv_overwriteWarning').show();
        this.$('input[name="bv_overwrite"][value="no"]').prop('checked', true);
        return this.$('.bv_overwrite').change();
      } else {
        this.$('.bv_overwriteWarning').hide();
        return this.hideNameTemplateError();
      }
    };

    AssignSdfPropertiesController.prototype.handleOverwriteRadioSelectChanged = function() {
      console.log("radio select changed");
      return this.isValid();
    };

    AssignSdfPropertiesController.prototype.showUnassignedDbProperties = function() {
      var i, len, name, newLine, prop, reqDbProp, unassignedDbProps;
      console.log("show unassigned db props");
      reqDbProp = this.dbPropertiesList.getRequired();
      unassignedDbProps = "";
      newLine = "&#13;&#10;";
      for (i = 0, len = reqDbProp.length; i < len; i++) {
        prop = reqDbProp[i];
        name = prop.get('name');
        if (this.assignedPropertiesList.findWhere({
          dbProperty: name
        }) == null) {
          if (unassignedDbProps === "") {
            unassignedDbProps = name;
          } else {
            unassignedDbProps += newLine + name;
          }
        }
      }
      return this.$('.bv_unassignedProperties').html(unassignedDbProps);
    };

    AssignSdfPropertiesController.prototype.isValid = function() {
      var duplicates, overwrite, saveTemplateChecked, validCheck;
      this.clearValidationErrorStyles();
      validCheck = true;
      this.assignedPropertiesListController.collection.each(function(model) {
        var validModel;
        validModel = model.isValid();
        if (validModel === false) {
          return validCheck = false;
        }
      });
      duplicates = this.assignedPropertiesListController.collection.checkDuplicates();
      if (duplicates.length > 1) {
        this.showDbPropErrors(duplicates);
        validCheck = false;
      }
      saveTemplateChecked = this.$('.bv_saveTemplate').is(":checked");
      if (saveTemplateChecked && this.$('.bv_overwriteWarning').is(":visible") && this.$('input[name="bv_overwrite"]:checked').val() === "no") {
        console.log("need unique template name");
        overwrite = this.$('input[name="bv_overwrite"]:checked').val();
        if (overwrite === "yes") {
          this.hideNameTemplateError();
        } else {
          this.showNameTemplateError('The template name should be unique');
          validCheck = false;
        }
      }
      if (validCheck) {
        this.$('.bv_regCmpds').removeAttr('disabled');
      } else {
        this.$('.bv_regCmpds').attr('disabled', 'disabled');
      }
      return validCheck;
    };

    AssignSdfPropertiesController.prototype.showDbPropErrors = function(duplicates) {
      var err, i, len, results;
      results = [];
      for (i = 0, len = duplicates.length; i < len; i++) {
        err = duplicates[i];
        this.$('.bv_group_' + err.attribute).addClass('input_error error');
        this.$('.bv_group_' + err.attribute).attr('data-toggle', 'tooltip');
        this.$('.bv_group_' + err.attribute).attr('data-placement', 'bottom');
        this.$('.bv_group_' + err.attribute).attr('data-original-title', err.message);
        results.push(this.$("[data-toggle=tooltip]").tooltip());
      }
      return results;
    };

    AssignSdfPropertiesController.prototype.clearValidationErrorStyles = function() {
      var errorElms;
      errorElms = this.$('.input_error');
      this.trigger('clearErrors', this.errorOwnerName);
      return _.each(errorElms, (function(_this) {
        return function(ee) {
          $(ee).removeAttr('data-toggle');
          $(ee).removeAttr('data-placement');
          $(ee).removeAttr('title');
          $(ee).removeAttr('data-original-title');
          return $(ee).removeClass('input_error error');
        };
      })(this));
    };

    AssignSdfPropertiesController.prototype.showNameTemplateError = function(errMessage) {
      console.log("show name template error");
      this.$('.bv_group_templateName').addClass('input_error error');
      this.$('.bv_group_templateName').attr('data-toggle', 'tooltip');
      this.$('.bv_group_templateName').attr('data-placement', 'bottom');
      this.$('.bv_group_templateName').attr('data-original-title', errMessage);
      return this.$("[data-toggle=tooltip]").tooltip();
    };

    AssignSdfPropertiesController.prototype.hideNameTemplateError = function() {
      console.log("clear name template error");
      this.$('.bv_group_templateName').removeAttr('data-toggle');
      this.$('.bv_group_templateName').removeAttr('data-placement');
      this.$('.bv_group_templateName').removeAttr('title');
      this.$('.bv_group_templateName').removeAttr('data-original-title');
      return this.$('.bv_group_templateName').removeClass('input_error error');
    };

    AssignSdfPropertiesController.prototype.handleRegCmpdsClicked = function() {
      console.log("register compounds");
      console.log(this.assignedPropertiesListController.collection.models);
      return $.ajax({
        type: 'POST',
        url: "/api/cmpdRegBulkLoader",
        data: {
          properties: JSON.stringify(this.assignedPropertiesListController.collection.models)
        },
        success: (function(_this) {
          return function(response) {
            return _this.trigger('saveComplete', response);
          };
        })(this),
        error: (function(_this) {
          return function(err) {
            return _this.serviceReturn = null;
          };
        })(this),
        dataType: 'json'
      });
    };

    return AssignSdfPropertiesController;

  })(Backbone.View);

  window.BulkRegCmpdsController = (function(superClass) {
    extend(BulkRegCmpdsController, superClass);

    function BulkRegCmpdsController() {
      this.setupAssignSdfPropertiesController = bind(this.setupAssignSdfPropertiesController, this);
      return BulkRegCmpdsController.__super__.constructor.apply(this, arguments);
    }

    BulkRegCmpdsController.prototype.template = _.template($("#BulkRegCmpdsView").html());

    BulkRegCmpdsController.prototype.initialize = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      this.disableAllInputs();
      this.setupDetectSdfPropertiesController();
      return this.setupAssignSdfPropertiesController();
    };

    BulkRegCmpdsController.prototype.setupDetectSdfPropertiesController = function() {
      this.detectSdfPropertiesController = new DetectSdfPropertiesController({
        el: this.$('.bv_detectSdfProperties')
      });
      this.detectSdfPropertiesController.on('propsDetected', (function(_this) {
        return function(properties) {
          _this.assignSdfPropertiesController.createPropertyCollections(properties);
          _this.detectSdfPropertiesController.showSdfProperties(_this.assignSdfPropertiesController.sdfPropertiesList);
          _this.$('.bv_assignProperties').show();
          _this.$('.bv_saveOptions').show();
          return _this.$('.bv_regCmpds').show();
        };
      })(this));
      this.detectSdfPropertiesController.on('resetAssignProps', (function(_this) {
        return function() {
          if (_this.assignSdfPropertiesController != null) {
            _this.assignSdfPropertiesController.undelegateEvents();
          }
          return _this.setupAssignSdfPropertiesController();
        };
      })(this));
      return this.detectSdfPropertiesController.render();
    };

    BulkRegCmpdsController.prototype.setupAssignSdfPropertiesController = function() {
      console.log("setupAssignSdfPropertiesController");
      this.assignSdfPropertiesController = new AssignSdfPropertiesController({
        el: this.$('.bv_assignSdfProperties')
      });
      this.assignSdfPropertiesController.on('templateChanged', (function(_this) {
        return function(template) {
          return _this.detectSdfPropertiesController.handleTemplateChanged(template);
        };
      })(this));
      return this.assignSdfPropertiesController.on('saveComplete', (function(_this) {
        return function(saveSummary) {
          return _this.trigger('saveComplete', saveSummary);
        };
      })(this));
    };

    BulkRegCmpdsController.prototype.disableAllInputs = function() {
      this.$('input').attr('disabled', 'disabled');
      this.$('button').attr('disabled', 'disabled');
      this.$('select').attr('disabled', 'disabled');
      return this.$("textarea").attr('disabled', 'disabled');
    };

    return BulkRegCmpdsController;

  })(Backbone.View);

  window.BulkRegCmpdsSummaryController = (function(superClass) {
    extend(BulkRegCmpdsSummaryController, superClass);

    function BulkRegCmpdsSummaryController() {
      return BulkRegCmpdsSummaryController.__super__.constructor.apply(this, arguments);
    }

    BulkRegCmpdsSummaryController.prototype.template = _.template($("#BulkRegCmpdsSummaryView").html());

    BulkRegCmpdsSummaryController.prototype.events = {
      "click .bv_loadAnother": "handleLoadAnotherSDF",
      "click .bv_downloadSummary": "handleDownloadSummary"
    };

    BulkRegCmpdsSummaryController.prototype.initialize = function() {
      $(this.el).empty();
      return $(this.el).html(this.template());
    };

    BulkRegCmpdsSummaryController.prototype.handleLoadAnotherSDF = function() {
      return this.trigger('loadAnother');
    };

    return BulkRegCmpdsSummaryController;

  })(Backbone.View);

  window.CmpdRegBulkLoaderAppController = (function(superClass) {
    extend(CmpdRegBulkLoaderAppController, superClass);

    function CmpdRegBulkLoaderAppController() {
      return CmpdRegBulkLoaderAppController.__super__.constructor.apply(this, arguments);
    }

    CmpdRegBulkLoaderAppController.prototype.template = _.template($("#CmpdRegBulkLoaderAppView").html());

    CmpdRegBulkLoaderAppController.prototype.events = {
      "click .bv_test": "handleTest"
    };

    CmpdRegBulkLoaderAppController.prototype.initialize = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      $(this.el).addClass('CmpdRegBulkLoaderAppController');
      return this.setupBulkRegCmpdsController();
    };

    CmpdRegBulkLoaderAppController.prototype.handleTest = function() {
      return console.log("test passed");
    };

    CmpdRegBulkLoaderAppController.prototype.setupBulkRegCmpdsController = function() {
      this.regCmpdsController = new BulkRegCmpdsController({
        el: this.$('.bv_bulkReg')
      });
      return this.regCmpdsController.on('saveComplete', (function(_this) {
        return function() {
          console.log("SAVE complete");
          _this.$('.bv_bulkReg').hide();
          return _this.setupBulkRegCmpdsSummaryController();
        };
      })(this));
    };

    CmpdRegBulkLoaderAppController.prototype.setupBulkRegCmpdsSummaryController = function() {
      this.regCmpdsSummaryController = new BulkRegCmpdsSummaryController({
        el: this.$('.bv_bulkRegSummary')
      });
      return this.regCmpdsSummaryController.on('loadAnother', (function(_this) {
        return function() {
          if (_this.regCmpdsController != null) {
            _this.regCmpdsController.undelegateEvents();
          }
          _this.setupBulkRegCmpdsController();
          _this.$('.bv_bulkRegSummary').hide();
          return _this.$('.bv_bulkReg').show();
        };
      })(this));
    };

    return CmpdRegBulkLoaderAppController;

  })(Backbone.View);

}).call(this);
