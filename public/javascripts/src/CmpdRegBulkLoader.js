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
      if (attrs.required && attrs.dbProperty !== "corporate id" && attrs.dbProperty !== "project" && attrs.defaultVal === "") {
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

    AssignedProperty.prototype.validateProject = function() {
      var projectError;
      projectError = [];
      if (this.get('required') && this.get('dbProperty') === "project" && this.get('defaultVal') === "unassigned") {
        projectError.push({
          attribute: 'dbProject',
          message: 'Project must be selected'
        });
      }
      return projectError;
    };

    return AssignedProperty;

  })(Backbone.Model);

  window.AssignedPropertiesList = (function(superClass) {
    extend(AssignedPropertiesList, superClass);

    function AssignedPropertiesList() {
      this.checkSaltProperties = bind(this.checkSaltProperties, this);
      this.checkDuplicates = bind(this.checkDuplicates, this);
      return AssignedPropertiesList.__super__.constructor.apply(this, arguments);
    }

    AssignedPropertiesList.prototype.model = AssignedProperty;

    AssignedPropertiesList.prototype.checkDuplicates = function() {
      var assignedDbProps, currentDbProp, duplicates, i, index, model, ref;
      duplicates = [];
      assignedDbProps = {};
      if (this.length !== 0) {
        for (index = i = 0, ref = this.length - 1; 0 <= ref ? i <= ref : i >= ref; index = 0 <= ref ? ++i : --i) {
          model = this.at(index);
          currentDbProp = model.get('dbProperty');
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
      return duplicates;
    };

    AssignedPropertiesList.prototype.checkSaltProperties = function() {
      var errors, saltEquiv, saltId, saltType;
      errors = [];
      saltId = this.findWhere({
        dbProperty: 'salt id'
      });
      saltType = this.findWhere({
        dbProperty: 'salt type'
      });
      saltEquiv = this.findWhere({
        dbProperty: 'salt equivalents'
      });
      if ((saltId != null) || (saltType != null)) {
        if (saltEquiv != null) {
          if (saltEquiv.get('defaultVal') === "") {
            errors.push({
              attribute: 'defaultVal:eq(' + this.indexOf(saltEquiv) + ')',
              message: "Salt type/id requires default value for salt equivalents property"
            });
          }
        }
      }
      return errors;
    };

    return AssignedPropertiesList;

  })(Backbone.Collection);

  window.DetectSdfPropertiesController = (function(superClass) {
    extend(DetectSdfPropertiesController, superClass);

    function DetectSdfPropertiesController() {
      this.handleProjectChanged = bind(this.handleProjectChanged, this);
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
      this.tempName = "none";
      this.mappings = null;
      return this.project = "unassigned";
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
      this.fileName = fileName;
      return this.getProperties();
    };

    DetectSdfPropertiesController.prototype.getProperties = function() {
      var mappings, mappingsCollection, projectProp, sdfInfo;
      this.$('.bv_detectedSdfPropertiesList').html("Loading...");
      this.disableInputs();
      this.$('.bv_deleteFile').attr('disabled', 'disabled');
      mappings = null;
      if (this.mappings instanceof Backbone.Collection) {
        mappings = this.mappings.toJSON();
      } else {
        mappings = this.mappings;
      }
      if (window.conf.cmpdReg.showProjectSelect) {
        mappingsCollection = new Backbone.Collection(mappings);
        projectProp = mappingsCollection.findWhere({
          dbProperty: 'project'
        });
        if (projectProp != null) {
          projectProp.set({
            defaultVal: this.project
          });
          mappings = mappingsCollection.toJSON();
        } else {
          if (mappings === null) {
            mappings = [];
          }
          mappings.push({
            dbProperty: 'project',
            sdfProperty: null,
            required: true,
            defaultVal: this.project
          });
        }
      }
      sdfInfo = {
        fileName: this.fileName,
        numRecords: this.numRecords,
        templateName: this.tempName,
        mappings: mappings
      };
      return $.ajax({
        type: 'POST',
        url: "/api/cmpdRegBulkLoader/readSDF",
        data: sdfInfo,
        success: (function(_this) {
          return function(response) {
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
      return this.trigger('propsDetected', response);
    };

    DetectSdfPropertiesController.prototype.handleFileRemoved = function() {
      this.disableInputs();
      this.$('.bv_detectedSdfPropertiesList').html("");
      this.fileName = null;
      this.numRecords = 100;
      this.$('.bv_recordsRead').html(0);
      return this.trigger('resetAssignProps');
    };

    DetectSdfPropertiesController.prototype.showSdfProperties = function(sdfPropsList) {
      var newLine, props;
      if (this.numRecords === -1) {
        this.$('.bv_recordsRead').html('All');
      } else {
        this.$('.bv_recordsRead').html(this.numRecords);
        this.$('.bv_readMore').removeAttr('disabled');
        this.$('.bv_readAll').removeAttr('disabled');
      }
      newLine = "&#13;&#10;";
      props = "";
      sdfPropsList.each(function(prop) {
        if (props === "") {
          return props = prop.get('name');
        } else {
          return props += newLine + prop.get('name');
        }
      });
      if (props === "") {
        props = "No SDF Properties Detected";
      }
      return this.$('.bv_detectedSdfPropertiesList').html(props);
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
      this.numRecords = -1;
      return this.getProperties();
    };

    DetectSdfPropertiesController.prototype.handleTemplateChanged = function(templateName, mappings) {
      this.tempName = templateName;
      this.mappings = mappings;
      if ((this.fileName != null) && this.fileName !== null) {
        return this.getProperties();
      }
    };

    DetectSdfPropertiesController.prototype.handleProjectChanged = function(projectName) {
      return this.project = projectName;
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
      if (this.model.get('dbProperty') === "none") {
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
      dbProp = this.dbPropertiesListController.getSelectedCode();
      if (dbProp === "none" || dbProp === "corporate id") {
        this.$('.bv_defaultVal').attr('disabled', 'disabled');
      } else {
        this.$('.bv_defaultVal').removeAttr('disabled');
      }
      propInfo = this.dbPropertiesList.findWhere({
        name: dbProp
      });
      if (propInfo != null) {
        if (propInfo.get('required')) {
          this.model.set({
            required: true
          });
        } else {
          this.model.set({
            required: false
          });
        }
      } else {
        this.model.set({
          required: false
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
      this.showValidationErrors = bind(this.showValidationErrors, this);
      this.isValid = bind(this.isValid, this);
      this.handleOverwriteRadioSelectChanged = bind(this.handleOverwriteRadioSelectChanged, this);
      return AssignSdfPropertiesController.__super__.constructor.apply(this, arguments);
    }

    AssignSdfPropertiesController.prototype.template = _.template($("#AssignSdfPropertiesView").html());

    AssignSdfPropertiesController.prototype.events = {
      "change .bv_dbProject": "handleDbProjectChanged",
      "change .bv_useTemplate": "handleTemplateChanged",
      "change .bv_saveTemplate": "handleSaveTemplateCheckboxChanged",
      "keyup .bv_templateName": "handleNameTemplateChanged",
      "change .bv_overwrite": "handleOverwriteRadioSelectChanged",
      "click .bv_regCmpds": "handleRegCmpdsClicked"
    };

    AssignSdfPropertiesController.prototype.initialize = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      this.getAndFormatTemplateOptions();
      if (window.conf.cmpdReg.showProjectSelect) {
        this.setupProjectSelect();
        this.isValid();
      } else {
        this.$('.bv_group_dbProject').hide();
      }
      return this.setupAssignedPropertiesListController();
    };

    AssignSdfPropertiesController.prototype.getAndFormatTemplateOptions = function() {
      return $.ajax({
        type: 'GET',
        url: "/api/cmpdRegBulkLoader/templates/" + window.AppLaunchParams.loginUser.username,
        dataType: 'json',
        success: (function(_this) {
          return function(response) {
            _this.templates = new Backbone.Collection(response);
            return _this.translateIntoPicklistFormat();
          };
        })(this),
        error: (function(_this) {
          return function(err) {
            return _this.serviceReturn = null;
          };
        })(this)
      });
    };

    AssignSdfPropertiesController.prototype.translateIntoPicklistFormat = function() {
      var templatePickList;
      templatePickList = new PickListList();
      this.templates.each((function(_this) {
        return function(temp) {
          var option;
          option = new PickList();
          option.set({
            code: temp.get('template'),
            name: temp.get('template'),
            ignored: temp.get('ignored')
          });
          return templatePickList.add(option);
        };
      })(this));
      return this.setupTemplateSelect(templatePickList);
    };

    AssignSdfPropertiesController.prototype.setupTemplateSelect = function(templatePickList) {
      this.templateList = templatePickList;
      return this.templateListController = new PickListSelectController({
        el: this.$('.bv_useTemplate'),
        collection: this.templateList,
        insertFirstOption: new PickList({
          code: "none",
          name: "None"
        }),
        selectedCode: "none",
        autoFetch: false
      });
    };

    AssignSdfPropertiesController.prototype.setupProjectSelect = function() {
      this.projectList = new PickListList();
      this.projectList.url = "/api/projects";
      return this.projectListController = new PickListSelectController({
        el: this.$('.bv_dbProject'),
        collection: this.projectList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select Project"
        }),
        selectedCode: "unassigned"
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
      this.sdfPropertiesList = new SdfPropertiesList(properties.sdfProperties);
      this.dbPropertiesList = new DbPropertiesList(properties.dbProperties);
      this.assignedPropertiesList = new AssignedPropertiesList(properties.bulkloadProperties);
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
      if (window.conf.cmpdReg.showProjectSelect) {
        this.handleDbProjectChanged();
      }
      return this.isValid();
    };

    AssignSdfPropertiesController.prototype.addUnassignedSdfProperties = function() {
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

    AssignSdfPropertiesController.prototype.handleDbProjectChanged = function() {
      var assignedProjectProp, project, projectProp;
      project = this.projectListController.getSelectedCode();
      if (this.assignedPropertiesList != null) {
        assignedProjectProp = this.assignedPropertiesList.findWhere({
          dbProperty: "project"
        });
        if (assignedProjectProp != null) {
          assignedProjectProp.set({
            defaultVal: project
          });
        } else {
          projectProp = new AssignedProperty({
            sdfProperty: null,
            dbProperty: "project",
            defaultVal: project,
            required: true
          });
          this.assignedPropertiesList.add(projectProp);
        }
      }
      this.isValid();
      return this.trigger('projectChanged', project);
    };

    AssignSdfPropertiesController.prototype.handleTemplateChanged = function() {
      var mappings, templateName;
      templateName = this.templateListController.getSelectedCode();
      if (templateName === "none") {
        mappings = null;
      } else {
        mappings = this.templates.findWhere({
          template: templateName
        }).get('mappings');
      }
      return this.trigger('templateChanged', templateName, mappings);
    };

    AssignSdfPropertiesController.prototype.handleSaveTemplateCheckboxChanged = function() {
      var currentTempName, saveTemplateChecked;
      saveTemplateChecked = this.$('.bv_saveTemplate').is(":checked");
      if (saveTemplateChecked) {
        this.$('.bv_templateName').removeAttr('disabled');
        currentTempName = this.templateListController.getSelectedCode();
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
      if (this.templateList.findWhere({
        name: tempName
      }) != null) {
        this.$('.bv_overwriteMessage').html(tempName + " already exists. Overwrite?");
        this.$('.bv_overwriteWarning').show();
        this.$('input[name="bv_overwrite"][value="no"]').prop('checked', true);
        return this.$('.bv_overwrite').change();
      } else {
        this.$('.bv_overwriteWarning').hide();
        return this.isValid();
      }
    };

    AssignSdfPropertiesController.prototype.handleOverwriteRadioSelectChanged = function() {
      return this.isValid();
    };

    AssignSdfPropertiesController.prototype.showUnassignedDbProperties = function() {
      var i, len, name, newLine, prop, reqDbProp, unassignedDbProps;
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
      if (this.assignedPropertiesList.findWhere({
        dbProperty: 'salt id'
      }) || (this.assignedPropertiesList.findWhere({
        dbProperty: 'salt type'
      }) != null)) {
        if (this.assignedPropertiesList.findWhere({
          dbProperty: 'salt equivalents'
        }) == null) {
          unassignedDbProps += newLine + 'salt equivalents (required for salt type/id)';
        }
      }
      this.$('.bv_unassignedProperties').html(unassignedDbProps);
      return this.isValid();
    };

    AssignSdfPropertiesController.prototype.isValid = function() {
      var otherErrors, validAp, validCheck;
      this.clearValidationErrorStyles();
      validCheck = true;
      validAp = this.validateAssignedProperties();
      if (!validAp) {
        validCheck = false;
      }
      otherErrors = [];
      if (window.conf.cmpdReg.showProjectSelect) {
        otherErrors.push.apply(otherErrors, this.getProjectErrors());
      }
      if (this.assignedPropertiesList != null) {
        otherErrors.push.apply(otherErrors, this.assignedPropertiesList.checkDuplicates());
        otherErrors.push.apply(otherErrors, this.assignedPropertiesList.checkSaltProperties());
      }
      otherErrors.push.apply(otherErrors, this.getTemplateErrors());
      this.showValidationErrors(otherErrors);
      if (this.$('.bv_unassignedProperties').html() !== "") {
        validCheck = false;
      }
      if (otherErrors.length > 0) {
        validCheck = false;
      }
      if (validCheck) {
        return this.$('.bv_regCmpds').removeAttr('disabled');
      } else {
        return this.$('.bv_regCmpds').attr('disabled', 'disabled');
      }
    };

    AssignSdfPropertiesController.prototype.getProjectErrors = function() {
      var projectError, projectProp;
      projectError = [];
      if (this.assignedPropertiesList != null) {
        projectProp = this.assignedPropertiesList.findWhere({
          dbProperty: 'project'
        });
        if (projectProp != null) {
          projectError = projectProp.validateProject();
        }
      } else if (window.conf.cmpdReg.showProjectSelect) {
        if (this.projectListController.getSelectedCode() === "unassigned" || this.projectListController.getSelectedCode() === null) {
          projectError.push({
            attribute: 'dbProject',
            message: 'Project must be selected'
          });
        }
      }
      return projectError;
    };

    AssignSdfPropertiesController.prototype.validateAssignedProperties = function() {
      var validCheck;
      validCheck = true;
      if (this.assignedPropertiesList != null) {
        this.assignedPropertiesList.each((function(_this) {
          return function(model) {
            var validModel;
            validModel = model.isValid();
            if (validModel === false) {
              return validCheck = false;
            }
          };
        })(this));
      }
      return validCheck;
    };

    AssignSdfPropertiesController.prototype.getTemplateErrors = function() {
      var saveTemplateChecked, templateErrors;
      templateErrors = [];
      saveTemplateChecked = this.$('.bv_saveTemplate').is(":checked");
      if (saveTemplateChecked) {
        if (UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_templateName')) === "") {
          templateErrors.push({
            attribute: 'templateName',
            message: 'The template name must be set'
          });
        } else if (this.$('.bv_overwriteWarning').is(":visible") && this.$('input[name="bv_overwrite"]:checked').val() === "no") {
          templateErrors.push({
            attribute: 'templateName',
            message: 'The template name should be unique'
          });
        }
      }
      return templateErrors;
    };

    AssignSdfPropertiesController.prototype.showValidationErrors = function(errors) {
      var err, i, len, results;
      results = [];
      for (i = 0, len = errors.length; i < len; i++) {
        err = errors[i];
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
      this.$('.bv_group_templateName').addClass('input_error error');
      this.$('.bv_group_templateName').attr('data-toggle', 'tooltip');
      this.$('.bv_group_templateName').attr('data-placement', 'bottom');
      this.$('.bv_group_templateName').attr('data-original-title', errMessage);
      return this.$("[data-toggle=tooltip]").tooltip();
    };

    AssignSdfPropertiesController.prototype.handleRegCmpdsClicked = function() {
      var dataToPost, saveTemplateChecked, templateName;
      templateName = null;
      saveTemplateChecked = this.$('.bv_saveTemplate').is(":checked");
      if (saveTemplateChecked) {
        templateName = UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_templateName'));
      }
      dataToPost = {
        templateName: templateName,
        mappings: JSON.stringify(this.assignedPropertiesListController.collection.models),
        recordedBy: window.AppLaunchParams.loginUser.username,
        ignored: false
      };
      return $.ajax({
        type: 'POST',
        url: "/api/cmpdRegBulkLoader",
        data: dataToPost,
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
      this.handleSdfPropertiesDetected = bind(this.handleSdfPropertiesDetected, this);
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
          return _this.handleSdfPropertiesDetected(properties);
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
      this.assignSdfPropertiesController = new AssignSdfPropertiesController({
        el: this.$('.bv_assignSdfProperties')
      });
      this.assignSdfPropertiesController.on('templateChanged', (function(_this) {
        return function(templateName, mappings) {
          return _this.detectSdfPropertiesController.handleTemplateChanged(templateName, mappings);
        };
      })(this));
      this.assignSdfPropertiesController.on('projectChanged', (function(_this) {
        return function(projectName) {
          return _this.detectSdfPropertiesController.handleProjectChanged(projectName);
        };
      })(this));
      return this.assignSdfPropertiesController.on('saveComplete', (function(_this) {
        return function(saveSummary) {
          return _this.trigger('saveComplete', saveSummary);
        };
      })(this));
    };

    BulkRegCmpdsController.prototype.handleSdfPropertiesDetected = function(properties) {
      this.assignSdfPropertiesController.createPropertyCollections(properties);
      this.detectSdfPropertiesController.mappings = this.assignSdfPropertiesController.assignedPropertiesList;
      this.detectSdfPropertiesController.showSdfProperties(this.assignSdfPropertiesController.sdfPropertiesList);
      this.$('.bv_assignProperties').show();
      this.$('.bv_saveOptions').show();
      return this.$('.bv_regCmpds').show();
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
      $(this.el).html(this.template());
      if (this.options.summaryHTML != null) {
        return this.summaryHTML = this.options.summaryHTML;
      } else {
        return this.summaryHTML = "";
      }
    };

    BulkRegCmpdsSummaryController.prototype.render = function() {
      return this.$('.bv_regSummaryHTML').html(this.summaryHTML);
    };

    BulkRegCmpdsSummaryController.prototype.handleLoadAnotherSDF = function() {
      return this.trigger('loadAnother');
    };

    BulkRegCmpdsSummaryController.prototype.handleDownloadSummary = function() {};

    return BulkRegCmpdsSummaryController;

  })(Backbone.View);

  window.PurgeFilesController = (function(superClass) {
    extend(PurgeFilesController, superClass);

    function PurgeFilesController() {
      return PurgeFilesController.__super__.constructor.apply(this, arguments);
    }

    PurgeFilesController.prototype.template = _.template($("#PurgeFilesView").html());

    PurgeFilesController.prototype.events = {
      "click .bv_purgeFile": "handlePurgeFile"
    };

    PurgeFilesController.prototype.initialize = function() {
      $(this.el).empty();
      return $(this.el).html(this.template());
    };

    PurgeFilesController.prototype.handlePurgeFile = function() {};

    return PurgeFilesController;

  })(Backbone.View);

  window.CmpdRegBulkLoaderAppController = (function(superClass) {
    extend(CmpdRegBulkLoaderAppController, superClass);

    function CmpdRegBulkLoaderAppController() {
      return CmpdRegBulkLoaderAppController.__super__.constructor.apply(this, arguments);
    }

    CmpdRegBulkLoaderAppController.prototype.template = _.template($("#CmpdRegBulkLoaderAppView").html());

    CmpdRegBulkLoaderAppController.prototype.events = {
      "click .bv_bulkRegDropdown": "handleBulkRegDropdownSelected",
      "click .bv_purgeFileDropdown": "handlePurgeFileSelected"
    };

    CmpdRegBulkLoaderAppController.prototype.initialize = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      $(this.el).addClass('CmpdRegBulkLoaderAppController');
      this.$('.bv_searchNavOption').hide();
      return this.setupBulkRegCmpdsController();
    };

    CmpdRegBulkLoaderAppController.prototype.handleBulkRegDropdownSelected = function() {
      this.$('.bv_bulkReg').show();
      this.$('.bv_purgeFiles').hide();
      return this.$('.bv_registerDropdown').dropdown('toggle');
    };

    CmpdRegBulkLoaderAppController.prototype.handlePurgeFileSelected = function() {
      this.$('.bv_adminDropdown').dropdown('toggle');
      this.$('.bv_bulkReg').hide();
      this.$('.bv_purgeFiles').show();
      return this.setupPurgeFilesController();
    };

    CmpdRegBulkLoaderAppController.prototype.setupBulkRegCmpdsController = function() {
      this.regCmpdsController = new BulkRegCmpdsController({
        el: this.$('.bv_bulkReg')
      });
      return this.regCmpdsController.on('saveComplete', (function(_this) {
        return function(summary) {
          _this.$('.bv_bulkReg').hide();
          _this.$('.bv_bulkRegSummary').show();
          return _this.setupBulkRegCmpdsSummaryController(summary);
        };
      })(this));
    };

    CmpdRegBulkLoaderAppController.prototype.setupBulkRegCmpdsSummaryController = function(summary) {
      if (this.regCmpdsSummaryController != null) {
        this.regCmpdsSummaryController.undelegateEvents();
      }
      this.regCmpdsSummaryController = new BulkRegCmpdsSummaryController({
        el: this.$('.bv_bulkRegSummary'),
        summaryHTML: summary
      });
      this.regCmpdsSummaryController.render();
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

    CmpdRegBulkLoaderAppController.prototype.setupPurgeFilesController = function() {
      return this.purgeFilesController = new PurgeFilesController({
        el: this.$('.bv_purgeFiles')
      });
    };

    return CmpdRegBulkLoaderAppController;

  })(Backbone.View);

}).call(this);
