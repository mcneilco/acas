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
      return AssignedProperty.__super__.constructor.apply(this, arguments);
    }

    AssignedProperty.prototype.defaults = {
      sdfProperty: null,
      dbProperty: "none",
      defaultVal: "",
      required: false
    };

    AssignedProperty.prototype.validateProject = function() {
      var projectError;
      projectError = [];
      if (this.get('required') && this.get('dbProperty') === "Project" && this.get('defaultVal') === "unassigned") {
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
      if (saltEquiv != null) {
        if (saltId != null) {
          if (saltId.get('defaultVal') === "") {
            errors.push({
              attribute: 'defaultVal:eq(' + this.indexOf(saltId) + ')',
              message: "Salt equivalent requires default value for salt type/id property"
            });
          }
        }
        if (saltType != null) {
          if (saltType.get('defaultVal') === "") {
            errors.push({
              attribute: 'defaultVal:eq(' + this.indexOf(saltType) + ')',
              message: "Salt equivalent requires default value for salt type/id property"
            });
          }
        }
      }
      return errors;
    };

    return AssignedPropertiesList;

  })(Backbone.Collection);

  window.BulkLoadFile = (function(superClass) {
    extend(BulkLoadFile, superClass);

    function BulkLoadFile() {
      return BulkLoadFile.__super__.constructor.apply(this, arguments);
    }

    return BulkLoadFile;

  })(Backbone.Model);

  window.BulkLoadFileList = (function(superClass) {
    extend(BulkLoadFileList, superClass);

    function BulkLoadFileList() {
      return BulkLoadFileList.__super__.constructor.apply(this, arguments);
    }

    BulkLoadFileList.prototype.model = BulkLoadFile;

    return BulkLoadFileList;

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
      this.mappings = new AssignedPropertiesList();
      this.project = "unassigned";
      return this.fileName = null;
    };

    DetectSdfPropertiesController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      this.disableInputs();
      return this.setupBrowseFileController();
    };

    DetectSdfPropertiesController.prototype.setupBrowseFileController = function() {
      this.browseFileController = new LSFileChooserController({
        el: this.$('.bv_browseSdfFile'),
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
      this.trigger('fileChanged', this.fileName);
      return this.getProperties();
    };

    DetectSdfPropertiesController.prototype.getProperties = function() {
      var mappings, sdfInfo, templateName;
      this.$('.bv_detectedSdfPropertiesList').html("Loading...");
      this.disableInputs();
      this.$('.bv_deleteFile').attr('disabled', 'disabled');
      if (this.mappings instanceof Backbone.Collection) {
        mappings = this.mappings.toJSON();
      } else {
        mappings = this.mappings;
      }
      if (this.tempName === "none") {
        templateName = null;
      } else {
        templateName = this.tempName;
      }
      sdfInfo = {
        fileName: this.fileName,
        numRecords: this.numRecords,
        templateName: templateName,
        mappings: mappings,
        userName: window.AppLaunchParams.loginUser.username
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
            _this.handleReadError(err);
            return _this.serviceReturn = null;
          };
        })(this),
        dataType: 'json'
      });
    };

    DetectSdfPropertiesController.prototype.handlePropertiesDetected = function(response) {
      if (response === "Error") {
        return this.handleReadError(response);
      } else {
        return this.trigger('propsDetected', response);
      }
    };

    DetectSdfPropertiesController.prototype.handleReadError = function(err) {
      this.$('.bv_detectedSdfPropertiesList').addClass('readError');
      return this.$('.bv_detectedSdfPropertiesList').html("An error occurred reading the SD file. Please retry upload or contact an administrator.");
    };

    DetectSdfPropertiesController.prototype.handleFileRemoved = function() {
      this.disableInputs();
      this.$('.bv_detectedSdfPropertiesList').html("");
      this.fileName = null;
      this.numRecords = 100;
      this.$('.bv_recordsRead').html(0);
      this.trigger('resetAssignProps');
      return this.trigger('fileChanged', this.fileName);
    };

    DetectSdfPropertiesController.prototype.updatePropertiesRead = function(sdfPropsList, numRecordsRead) {
      var newLine, props;
      this.$('.bv_detectedSdfPropertiesList').removeClass('readError');
      if (this.numRecords === -1 || (this.numRecords > numRecordsRead)) {
        this.numRecords = numRecordsRead;
      } else {
        this.$('.bv_readMore').removeAttr('disabled');
        this.$('.bv_readAll').removeAttr('disabled');
      }
      this.$('.bv_recordsRead').html(this.numRecords);
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
        if (code.toLowerCase().indexOf("date") > -1) {
          name += " (YYYY-MM-DD or MM-DD-YYYY)";
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
      this.model.destroy();
      return this.trigger('modelRemoved');
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
      apc.on('modelRemoved', (function(_this) {
        return function() {
          return _this.collection.trigger('change');
        };
      })(this));
      if (!(window.conf.cmpdReg.showProjectSelect && prop.get('dbProperty') === "Project")) {
        this.$('.bv_propInfo').append(apc.render().el);
      }
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
      this.handleFileDateIconClicked = bind(this.handleFileDateIconClicked, this);
      return AssignSdfPropertiesController.__super__.constructor.apply(this, arguments);
    }

    AssignSdfPropertiesController.prototype.template = _.template($("#AssignSdfPropertiesView").html());

    AssignSdfPropertiesController.prototype.events = {
      "change .bv_dbProject": "handleDbProjectChanged",
      "keyup .bv_fileDate": "handleFileDateChanged",
      "change .bv_fileDate": "handleFileDateChanged",
      "click .bv_fileDateIcon": "handleFileDateIconClicked",
      "change .bv_useTemplate": "handleTemplateChanged",
      "change .bv_saveTemplate": "handleSaveTemplateCheckboxChanged",
      "keyup .bv_templateName": "handleNameTemplateChanged",
      "change .bv_overwrite": "handleOverwriteRadioSelectChanged",
      "click .bv_regCmpds": "handleRegCmpdsClicked"
    };

    AssignSdfPropertiesController.prototype.initialize = function() {
      this.fileName = null;
      $(this.el).empty();
      $(this.el).html(this.template());
      this.getAndFormatTemplateOptions();
      if (window.conf.cmpdReg.showFileDate) {
        this.$('.bv_group_fileDate').show();
        this.fileDate = null;
        this.$('.bv_fileDate').datepicker();
        this.$('.bv_fileDate').datepicker("option", "dateFormat", "yy-mm-dd");
      } else {
        this.$('.bv_group_fileDate').hide();
      }
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
            code: temp.get('templateName'),
            name: temp.get('templateName'),
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
      this.assignedPropertiesList = new AssignedPropertiesList(properties.bulkLoadProperties);
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

    AssignSdfPropertiesController.prototype.handleFileChanged = function(newFileName) {
      return this.fileName = newFileName;
    };

    AssignSdfPropertiesController.prototype.handleDbProjectChanged = function() {
      var project;
      project = this.projectListController.getSelectedCode();
      this.isValid();
      return this.trigger('projectChanged', project);
    };

    AssignSdfPropertiesController.prototype.handleFileDateChanged = function() {
      if (UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_fileDate')) === "") {
        this.fileDate = null;
      } else {
        this.fileDate = UtilityFunctions.prototype.convertYMDDateToMs(UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_fileDate')));
      }
      return this.isValid();
    };

    AssignSdfPropertiesController.prototype.handleFileDateIconClicked = function() {
      return this.$(".bv_fileDate").datepicker("show");
    };

    AssignSdfPropertiesController.prototype.handleTemplateChanged = function() {
      var mappings, templateName;
      templateName = this.templateListController.getSelectedCode();
      if (templateName === "none") {
        mappings = new AssignedPropertiesList();
      } else {
        mappings = new AssignedPropertiesList(JSON.parse(this.templates.findWhere({
          templateName: templateName
        }).get('jsonTemplate')));
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
      if ((this.assignedPropertiesList.findWhere({
        dbProperty: 'salt id'
      }) != null) || (this.assignedPropertiesList.findWhere({
        dbProperty: 'salt type'
      }) != null)) {
        if (this.assignedPropertiesList.findWhere({
          dbProperty: 'salt equivalents'
        }) == null) {
          unassignedDbProps += newLine + 'salt equivalents (required for salt type/id)';
        }
      }
      if (this.assignedPropertiesList.findWhere({
        dbProperty: 'salt equivalents'
      }) != null) {
        if (!((this.assignedPropertiesList.findWhere({
          dbProperty: 'salt id'
        }) != null) || (this.assignedPropertiesList.findWhere({
          dbProperty: 'salt type'
        }) != null))) {
          unassignedDbProps += newLine + 'salt id/type (required for salt equivalents)';
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
      if (window.conf.cmpdReg.showFileDate) {
        otherErrors.push.apply(otherErrors, this.getFileDateErrors());
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
        this.$('.bv_regCmpds').removeAttr('disabled');
      } else {
        this.$('.bv_regCmpds').attr('disabled', 'disabled');
      }
      return validCheck;
    };

    AssignSdfPropertiesController.prototype.getProjectErrors = function() {
      var projectError;
      projectError = [];
      if (this.projectListController.getSelectedCode() === "unassigned" || this.projectListController.getSelectedCode() === null) {
        projectError.push({
          attribute: 'dbProject',
          message: 'Project must be selected'
        });
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

    AssignSdfPropertiesController.prototype.getFileDateErrors = function() {
      var fileDateErrors;
      fileDateErrors = [];
      if (_.isNaN(this.fileDate) && this.fileDate !== null) {
        fileDateErrors.push({
          attribute: 'fileDate',
          message: "File date must be a valid date"
        });
      }
      return fileDateErrors;
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
      var saveTemplateChecked;
      this.$('.bv_regCmpds').attr('disabled', 'disabled');
      this.$('.bv_registering').show();
      saveTemplateChecked = this.$('.bv_saveTemplate').is(":checked");
      if (saveTemplateChecked) {
        return this.saveTemplate();
      } else {
        return this.registerCompounds();
      }
    };

    AssignSdfPropertiesController.prototype.saveTemplate = function() {
      var dataToPost, templateName;
      templateName = UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_templateName'));
      dataToPost = {
        templateName: templateName,
        jsonTemplate: JSON.stringify(this.assignedPropertiesListController.collection.models),
        recordedBy: window.AppLaunchParams.loginUser.username,
        ignored: false
      };
      return $.ajax({
        type: 'POST',
        url: "/api/cmpdRegBulkLoader/saveTemplate",
        data: dataToPost,
        success: (function(_this) {
          return function(response) {
            if (response.id != null) {
              return _this.registerCompounds();
            } else {
              return _this.handleSaveTemplateError();
            }
          };
        })(this),
        error: (function(_this) {
          return function(err) {
            _this.serviceReturn = null;
            return _this.handleSaveTemplateError();
          };
        })(this),
        dataType: 'json'
      });
    };

    AssignSdfPropertiesController.prototype.handleSaveTemplateError = function() {
      this.$('.bv_registering').hide();
      this.$('.bv_saveErrorModal').modal('show');
      this.$('.bv_saveErrorTitle').html("Error: Template Not Saved");
      return this.$('.bv_errorMessage').html("An error occurred while trying to save the template. The compounds have not been registered yet. Please try again or contact an administrator.");
    };

    AssignSdfPropertiesController.prototype.registerCompounds = function() {
      var dataToPost;
      dataToPost = {
        fileName: this.fileName,
        mappings: JSON.parse(JSON.stringify(this.assignedPropertiesListController.collection.models)),
        userName: window.AppLaunchParams.loginUser.username
      };
      if (window.conf.cmpdReg.showFileDate) {
        dataToPost.fileDate = this.fileDate;
      }
      return $.ajax({
        type: 'POST',
        url: "/api/cmpdRegBulkLoader/registerCmpds",
        data: dataToPost,
        timeout: 6000000,
        success: (function(_this) {
          return function(response) {
            _this.$('.bv_registering').hide();
            if (response === "Error") {
              return _this.handleRegisterCmpdsError();
            } else {
              return _this.trigger('saveComplete', response);
            }
          };
        })(this),
        error: (function(_this) {
          return function(err) {
            _this.serviceReturn = null;
            return _this.handleRegisterCmpdsError();
          };
        })(this),
        dataType: 'json'
      });
    };

    AssignSdfPropertiesController.prototype.handleRegisterCmpdsError = function() {
      this.$('.bv_registering').hide();
      this.$('.bv_saveErrorModal').modal('show');
      this.$('.bv_saveErrorTitle').html("Error: Compounds Not Registered");
      return this.$('.bv_errorMessage').html("An error occurred while trying to register the compounds. Please try again or contact an administrator.");
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
      this.detectSdfPropertiesController.on('fileChanged', (function(_this) {
        return function(newFileName) {
          return _this.assignSdfPropertiesController.handleFileChanged(newFileName);
        };
      })(this));
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
      var err, i, len, ref;
      this.$('.bv_templateWarning').hide();
      this.$('.bv_templateWarning').html("");
      ref = properties.errors;
      for (i = 0, len = ref.length; i < len; i++) {
        err = ref[i];
        if (err["level"] === "warning") {
          this.$('.bv_templateWarning').append('<div class="alert" style="margin-left: 105px;margin-right: 100px;width: 550px;margin-top: 10px;margin-bottom: 0px;">' + err["message"] + '</div>');
          this.$('.bv_templateWarning').show();
        }
      }
      this.assignSdfPropertiesController.createPropertyCollections(properties);
      this.detectSdfPropertiesController.mappings = this.assignSdfPropertiesController.assignedPropertiesList;
      this.detectSdfPropertiesController.updatePropertiesRead(this.assignSdfPropertiesController.sdfPropertiesList, properties.numRecordsRead);
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
      "click .bv_loadAnother": "handleLoadAnotherSDF"
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

    return BulkRegCmpdsSummaryController;

  })(Backbone.View);

  window.FileRowSummaryController = (function(superClass) {
    extend(FileRowSummaryController, superClass);

    function FileRowSummaryController() {
      this.render = bind(this.render, this);
      this.handleClick = bind(this.handleClick, this);
      return FileRowSummaryController.__super__.constructor.apply(this, arguments);
    }

    FileRowSummaryController.prototype.tagName = 'tr';

    FileRowSummaryController.prototype.className = 'dataTableRow';

    FileRowSummaryController.prototype.events = {
      "click": "handleClick"
    };

    FileRowSummaryController.prototype.handleClick = function() {
      this.trigger("gotClick", this.model);
      $(this.el).closest("table").find("tr").removeClass("info");
      return $(this.el).addClass("info");
    };

    FileRowSummaryController.prototype.initialize = function() {
      return this.template = _.template($('#FileRowSummaryView').html());
    };

    FileRowSummaryController.prototype.render = function() {
      var fileDate, toDisplay;
      fileDate = this.model.get('fileDate');
      if (fileDate === null) {
        fileDate = "";
      } else {
        fileDate = UtilityFunctions.prototype.convertMSToYMDDate(fileDate);
      }
      toDisplay = {
        fileName: this.model.get('fileName'),
        loadDate: fileDate,
        loadUser: this.model.get('recordedBy')
      };
      $(this.el).html(this.template(toDisplay));
      return this;
    };

    return FileRowSummaryController;

  })(Backbone.View);

  window.FileSummaryTableController = (function(superClass) {
    extend(FileSummaryTableController, superClass);

    function FileSummaryTableController() {
      this.render = bind(this.render, this);
      this.selectedRowChanged = bind(this.selectedRowChanged, this);
      return FileSummaryTableController.__super__.constructor.apply(this, arguments);
    }

    FileSummaryTableController.prototype.selectedRowChanged = function(row) {
      return this.trigger("selectedRowUpdated", row);
    };

    FileSummaryTableController.prototype.render = function() {
      this.template = _.template($('#FileSummaryTableView').html());
      $(this.el).html(this.template);
      if (this.collection.models.length === 0) {
        $(".bv_noFilesFoundMessage").removeClass("hide");
      } else {
        $(".bv_noFilesFoundMessage").addClass("hide");
        this.collection.each((function(_this) {
          return function(file) {
            var frsc;
            frsc = new FileRowSummaryController({
              model: file
            });
            frsc.on("gotClick", _this.selectedRowChanged);
            return _this.$("tbody").append(frsc.render().el);
          };
        })(this));
        this.$("table").dataTable({
          oLanguage: {
            sSearch: "Filter results: "
          }
        });
      }
      return this;
    };

    return FileSummaryTableController;

  })(Backbone.View);

  window.PurgeFilesController = (function(superClass) {
    extend(PurgeFilesController, superClass);

    function PurgeFilesController() {
      this.handlePurgeSuccess = bind(this.handlePurgeSuccess, this);
      this.selectedFileUpdated = bind(this.selectedFileUpdated, this);
      return PurgeFilesController.__super__.constructor.apply(this, arguments);
    }

    PurgeFilesController.prototype.template = _.template($("#PurgeFilesView").html());

    PurgeFilesController.prototype.events = {
      "click .bv_purgeFileBtn": "handlePurgeFileBtnClicked",
      "click .bv_cancelPurge": "handleCancelBtnClicked",
      "click .bv_confirmPurgeFileButton": "handleConfirmPurgeFileBtnClicked",
      "click .bv_okay": "handleOkayClicked"
    };

    PurgeFilesController.prototype.initialize = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      this.$('.bv_purgeFileBtn').attr('disabled', 'disabled');
      this.$('.bv_purgeSummaryWrapper').hide();
      this.fileInfoToPurge = null;
      this.fileNameToPurge = null;
      return this.getFiles();
    };

    PurgeFilesController.prototype.getFiles = function() {
      return $.ajax({
        type: 'GET',
        url: "/api/cmpdRegBulkLoader/getFilesToPurge",
        dataType: "json",
        success: (function(_this) {
          return function(response) {
            return _this.setupFileSummaryTable(response);
          };
        })(this),
        error: (function(_this) {
          return function(err) {
            return _this.handleGetFilesError();
          };
        })(this)
      });
    };

    PurgeFilesController.prototype.setupFileSummaryTable = function(files) {
      if (files.length === 0) {
        $('.bv_fileTableController').addClass("well");
        $('.bv_fileTableController').html("No files to purge");
        return $('.bv_purgeFileBtn').hide();
      } else {
        this.fileSummaryTable = new FileSummaryTableController({
          collection: new BulkLoadFileList(files)
        });
        this.fileSummaryTable.on("selectedRowUpdated", this.selectedFileUpdated);
        return $(".bv_fileTableController").html(this.fileSummaryTable.render().el);
      }
    };

    PurgeFilesController.prototype.handleGetFilesError = function() {
      $('.bv_fileTableController').addClass("well");
      $('.bv_fileTableController').html("An error occurred when getting files to purge. Please try refreshing the page or contact an administrator.");
      return $('.bv_purgeFileBtn').hide();
    };

    PurgeFilesController.prototype.selectedFileUpdated = function(file) {
      this.fileInfoToPurge = file;
      this.fileNameToPurge = file.get('fileName');
      return this.$('.bv_purgeFileBtn').removeAttr('disabled');
    };

    PurgeFilesController.prototype.handlePurgeFileBtnClicked = function() {
      var fileInfo;
      this.$('.bv_purgeFileBtn').attr('disabled', 'disabled');
      this.$('.bv_purgeSummaryWrapper').hide();
      this.$('.bv_purging').hide();
      this.$('.bv_purgeButtons').show();
      this.$('.bv_dependencyCheckModal').modal({
        backdrop: 'static'
      });
      fileInfo = {
        fileInfo: JSON.parse(JSON.stringify(this.fileInfoToPurge))
      };
      return $.ajax({
        type: 'POST',
        url: "/api/cmpdRegBulkLoader/checkFileDependencies",
        data: fileInfo,
        dataType: 'json',
        success: (function(_this) {
          return function(response) {
            if (response.canPurge) {
              _this.$('.bv_showDependenciesTitle').html("Confirm Purge");
              _this.$('.bv_cancelPurge').show();
              _this.$('.bv_confirmPurgeFileButton').show();
              _this.$('.bv_okay').hide();
            } else {
              _this.$('.bv_showDependenciesTitle').html("Can Not Purge");
              _this.$('.bv_cancelPurge').hide();
              _this.$('.bv_confirmPurgeFileButton').hide();
              _this.$('.bv_okay').show();
            }
            _this.$('.bv_dependenciesSummary').html(response.summary);
            _this.$('.bv_dependencyCheckModal').modal("hide");
            return _this.$('.bv_showDependenciesModal').modal({
              backdrop: 'static'
            });
          };
        })(this),
        error: (function(_this) {
          return function(err) {
            _this.serviceReturn = null;
            _this.$('.bv_dependencyCheckModal').modal("hide");
            _this.$('.bv_dependenciesCheckErrorModal').modal('show');
            return _this.$('.bv_dependenciesCheckError').html("There has been an error checking the dependencies. Please try again or contact an administrator.");
          };
        })(this)
      });
    };

    PurgeFilesController.prototype.handleCancelBtnClicked = function() {
      return this.$('.bv_showDependenciesModal').modal("hide");
    };

    PurgeFilesController.prototype.handleConfirmPurgeFileBtnClicked = function() {
      var fileInfo;
      this.$('.bv_purgeButtons').hide();
      this.$('.bv_purging').show();
      fileInfo = {
        fileInfo: JSON.parse(JSON.stringify(this.fileInfoToPurge))
      };
      return $.ajax({
        type: 'POST',
        url: "/api/cmpdRegBulkLoader/purgeFile",
        data: fileInfo,
        dataType: 'json',
        success: (function(_this) {
          return function(response) {
            _this.$('.bv_purging').hide();
            if (response.success) {
              return _this.handlePurgeSuccess(response);
            } else {
              return _this.handlePurgeError();
            }
          };
        })(this),
        error: (function(_this) {
          return function(err) {
            _this.serviceReturn = null;
            return _this.handlePurgeError();
          };
        })(this)
      });
    };

    PurgeFilesController.prototype.handleOkayClicked = function() {
      return this.$('.bv_showDependenciesModal').modal("hide");
    };

    PurgeFilesController.prototype.handlePurgeSuccess = function(response) {
      var downloadUrl;
      this.$('.bv_showDependenciesModal').modal("hide");
      this.$('.bv_purgeSummary').html(response.summary);
      downloadUrl = window.conf.datafiles.downloadurl.prefix + "cmpdreg_bulkload/" + response.fileName;
      this.$('.bv_purgedFileName').attr("href", downloadUrl);
      this.$('.bv_purgedFileName').html(response.fileName);
      this.$('.bv_purgeSummaryWrapper').show();
      this.fileInfoToPurge = null;
      this.fileNameToPurge = null;
      return this.getFiles();
    };

    PurgeFilesController.prototype.handlePurgeError = function() {
      this.$('.bv_purgeSummary').html("An error occurred purging the file: " + this.fileNameToPurge + " .Please try again or contact an administrator.");
      this.$('.bv_purgeSummaryWrapper').show();
      this.fileInfoToPurge = null;
      this.fileNameToPurge = null;
      return this.getFiles();
    };

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
      "click .bv_purgeFileDropdown": "handlePurgeFileDropdownSelected"
    };

    CmpdRegBulkLoaderAppController.prototype.initialize = function() {
      var projectName, ref;
      $(this.el).empty();
      $(this.el).html(this.template());
      $(this.el).addClass('CmpdRegBulkLoaderAppController');
      if (((ref = window.conf.cmpdReg) != null ? ref.projectName : void 0) != null) {
        projectName = window.conf.cmpdReg.projectName;
        this.$('.bv_headerName').html("BULK COMPOUND REGISTRATION: Project " + projectName);
      } else {
        this.$('.bv_headerName').html("BULK COMPOUND REGISTRATION");
      }
      this.$('.bv_loginUserFirstName').html(window.AppLaunchParams.loginUser.firstName);
      this.$('.bv_loginUserLastName').html(window.AppLaunchParams.loginUser.lastName);
      if (UtilityFunctions.prototype.testUserHasRole(window.AppLaunchParams.loginUser, ["admin"])) {
        this.$('.bv_adminDropdownWrapper').show();
      } else {
        this.$('.bv_adminDropdownWrapper').hide();
      }
      this.$('.bv_searchNavOption').hide();
      return this.setupBulkRegCmpdsController();
    };

    CmpdRegBulkLoaderAppController.prototype.handleBulkRegDropdownSelected = function() {
      if (!this.$('.bv_bulkReg').is(':visible')) {
        this.$('.bv_bulkReg').show();
        this.setupBulkRegCmpdsController();
        this.$('.bv_bulkRegSummary').hide();
        this.$('.bv_purgeFiles').hide();
      }
      return this.$('.bv_registerDropdown').dropdown('toggle');
    };

    CmpdRegBulkLoaderAppController.prototype.handlePurgeFileDropdownSelected = function() {
      if (!this.$('.bv_purgeFiles').is(':visible')) {
        this.$('.bv_bulkReg').hide();
        this.$('.bv_bulkRegSummary').hide();
        this.$('.bv_purgeFiles').show();
        this.setupPurgeFilesController();
      }
      return this.$('.bv_adminDropdown').dropdown('toggle');
    };

    CmpdRegBulkLoaderAppController.prototype.setupBulkRegCmpdsController = function() {
      this.regCmpdsController = new BulkRegCmpdsController({
        el: this.$('.bv_bulkReg')
      });
      return this.regCmpdsController.on('saveComplete', (function(_this) {
        return function(summary) {
          var downloadUrl;
          _this.$('.bv_bulkReg').hide();
          _this.$('.bv_bulkRegSummary').show();
          _this.setupBulkRegCmpdsSummaryController(summary[0]);
          downloadUrl = window.conf.datafiles.downloadurl.prefix + "cmpdreg_bulkload/" + summary[1];
          return _this.$('.bv_downloadSummary').attr("href", downloadUrl);
        };
      })(this));
    };

    CmpdRegBulkLoaderAppController.prototype.setupBulkRegCmpdsSummaryController = function(summary) {
      if (this.regCmpdsSummaryController != null) {
        this.regCmpdsSummaryController.undelegateEvents();
      }
      this.regCmpdsSummaryController = new BulkRegCmpdsSummaryController({
        el: this.$('.bv_bulkRegSummary'),
        summaryHTML: summary['summary']
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
      if (this.purgeFilesController != null) {
        this.purgeFilesController.undelegateEvents();
      }
      return this.purgeFilesController = new PurgeFilesController({
        el: this.$('.bv_purgeFiles')
      });
    };

    return CmpdRegBulkLoaderAppController;

  })(Backbone.View);

}).call(this);
