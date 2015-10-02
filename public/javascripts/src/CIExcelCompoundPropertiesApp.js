(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  if (true) {
    window.Office.initialize = function(reason) {
      return $(document).ready(function() {
        window.logger = new ExcelAppLogger({
          el: $('.bv_log')
        });
        logger.render();
        window.insertCompoundPropertiesController = new ExcelInsertCompoundPropertiesController({
          el: $('.bv_excelInsertCompoundPropertiesView')
        });
        return insertCompoundPropertiesController.render();
      });
    };
  } else {
    window.onload = function() {
      window.logger = new ExcelAppLogger({
        el: $('.bv_log')
      });
      logger.render();
      window.insertCompoundPropertiesController = new ExcelInsertCompoundPropertiesController({
        el: $('.bv_excelInsertCompoundPropertiesView')
      });
      return insertCompoundPropertiesController.render();
    };
  }

  window.Attributes = (function(superClass) {
    extend(Attributes, superClass);

    function Attributes() {
      return Attributes.__super__.constructor.apply(this, arguments);
    }

    Attributes.prototype.defaults = {
      insertColumnHeaders: true,
      includeRequestedID: false
    };

    return Attributes;

  })(Backbone.Model);

  window.AttributesController = (function(superClass) {
    extend(AttributesController, superClass);

    function AttributesController() {
      this.getIncludeRequestedID = bind(this.getIncludeRequestedID, this);
      this.getInsertColumnHeaders = bind(this.getInsertColumnHeaders, this);
      this.handleIncludeRequestedID = bind(this.handleIncludeRequestedID, this);
      this.handleInsertColumnHeaders = bind(this.handleInsertColumnHeaders, this);
      this.render = bind(this.render, this);
      return AttributesController.__super__.constructor.apply(this, arguments);
    }

    AttributesController.prototype.initialize = function() {
      return this.template = _.template($("#AttributesControllerView").html());
    };

    AttributesController.prototype.events = function() {
      return {
        'change .bv_insertColumnHeaders': 'handleInsertColumnHeaders',
        'change .bv_includeRequestedID': 'handleIncludeRequestedID'
      };
    };

    AttributesController.prototype.render = function() {
      this.$el.empty();
      this.model = new Attributes();
      return this.$el.html(this.template(this.model.attributes));
    };

    AttributesController.prototype.handleInsertColumnHeaders = function() {
      return this.model.set('insertColumnHeaders', this.$('.bv_insertColumnHeaders').is(":checked"));
    };

    AttributesController.prototype.handleIncludeRequestedID = function() {
      return this.model.set('includeRequestedID', this.$('.bv_includeRequestedID').is(":checked"));
    };

    AttributesController.prototype.getInsertColumnHeaders = function() {
      return this.model.get('insertColumnHeaders');
    };

    AttributesController.prototype.getIncludeRequestedID = function() {
      return this.model.get('includeRequestedID');
    };

    return AttributesController;

  })(Backbone.View);

  window.PropertyDescriptor = (function(superClass) {
    extend(PropertyDescriptor, superClass);

    function PropertyDescriptor() {
      return PropertyDescriptor.__super__.constructor.apply(this, arguments);
    }

    return PropertyDescriptor;

  })(Backbone.Model);

  window.PropertyDescriptorController = (function(superClass) {
    extend(PropertyDescriptorController, superClass);

    function PropertyDescriptorController() {
      return PropertyDescriptorController.__super__.constructor.apply(this, arguments);
    }

    PropertyDescriptorController.prototype.initialize = function() {
      return this.template = _.template($("#PropertyDescriptorControllerView").html());
    };

    PropertyDescriptorController.prototype.events = function() {
      return {
        'change .bv_propertyDescriptorCheckbox': 'handleDescriptorCheckboxChanged'
      };
    };

    PropertyDescriptorController.prototype.render = function() {
      this.$el.empty();
      this.model.set('isChecked', false);
      this.$el.html(this.template(this.model.attributes));
      this.$('.bv_descriptorLabel').text(this.model.get('valueDescriptor').prettyName);
      this.$('.bv_descriptorLabel').attr('title', this.model.get('valueDescriptor').description);
      return this;
    };

    PropertyDescriptorController.prototype.handleDescriptorCheckboxChanged = function() {
      var checked;
      checked = this.$('.bv_propertyDescriptorCheckbox').is(":checked");
      this.model.set('isChecked', checked);
      if (checked) {
        return this.trigger('checked');
      } else {
        return this.trigger('unchecked');
      }
    };

    return PropertyDescriptorController;

  })(Backbone.View);

  window.PropertyDescriptorList = (function(superClass) {
    extend(PropertyDescriptorList, superClass);

    function PropertyDescriptorList() {
      return PropertyDescriptorList.__super__.constructor.apply(this, arguments);
    }

    PropertyDescriptorList.prototype.model = PropertyDescriptor;

    return PropertyDescriptorList;

  })(Backbone.Collection);

  window.PropertyDescriptorListController = (function(superClass) {
    extend(PropertyDescriptorListController, superClass);

    function PropertyDescriptorListController() {
      return PropertyDescriptorListController.__super__.constructor.apply(this, arguments);
    }

    PropertyDescriptorListController.prototype.events = {
      'click .bv_checkAll': 'handleCheckAllClicked',
      'click .bv_invert': 'handleInvertSelectionClicked',
      'click .bv_uncheckAll': 'handleUncheckAllClicked'
    };

    PropertyDescriptorListController.prototype.initialize = function() {
      this.title = this.options.title;
      this.template = _.template($("#PropertyDescriptorListControllerView").html());
      this.collection = new PropertyDescriptorList();
      this.propertyControllersList = [];
      this.collection.url = this.options.url;
      return this.collection.fetch({
        success: (function(_this) {
          return function() {
            _this.collection.each(function(propertyDescriptor) {
              return _this.addPropertyDescriptor(propertyDescriptor);
            });
            return _this.trigger('ready');
          };
        })(this),
        error: (function(_this) {
          return function() {
            return logger.log('error fetching property descriptors from route: ' + _this.collection.url);
          };
        })(this)
      });
    };

    PropertyDescriptorListController.prototype.render = function() {
      this.$el.empty();
      this.$el.html(this.template());
      this.$('.propertyDescriptorListControllerTitle').html(this.title);
      this.propertyControllersList.forEach((function(_this) {
        return function(pdc) {
          return _this.$('.bv_propertyDescriptorList').append(pdc.render().el);
        };
      })(this));
      return this;
    };

    PropertyDescriptorListController.prototype.handleCheckAllClicked = function() {
      return this.propertyControllersList.forEach(function(pdc) {
        if (!pdc.model.get('isChecked')) {
          return pdc.$('.bv_propertyDescriptorCheckbox').click();
        }
      });
    };

    PropertyDescriptorListController.prototype.handleInvertSelectionClicked = function() {
      return this.propertyControllersList.forEach(function(pdc) {
        return pdc.$('.bv_propertyDescriptorCheckbox').click();
      });
    };

    PropertyDescriptorListController.prototype.handleUncheckAllClicked = function() {
      return this.propertyControllersList.forEach(function(pdc) {
        if (pdc.model.get('isChecked')) {
          return pdc.$('.bv_propertyDescriptorCheckbox').click();
        }
      });
    };

    PropertyDescriptorListController.prototype.getSelectedProperties = function(callback) {
      var selectedProperties, selectedProps;
      selectedProperties = this.collection.where({
        isChecked: true
      });
      selectedProps = {
        names: [],
        prettyNames: []
      };
      selectedProperties.forEach(function(selectedProperty) {
        selectedProps.names.push(selectedProperty.get('valueDescriptor').name);
        return selectedProps.prettyNames.push(selectedProperty.get('valueDescriptor').prettyName);
      });
      return callback(selectedProps);
    };

    PropertyDescriptorListController.prototype.addPropertyDescriptor = function(propertyDescriptor) {
      var pdc;
      pdc = new PropertyDescriptorController({
        model: propertyDescriptor
      });
      pdc.on('checked', (function(_this) {
        return function() {
          return _this.trigger('checked');
        };
      })(this));
      pdc.on('unchecked', (function(_this) {
        return function() {
          return _this.trigger('unchecked');
        };
      })(this));
      return this.propertyControllersList.push(pdc);
    };

    return PropertyDescriptorListController;

  })(Backbone.View);

  window.ExcelInsertCompoundPropertiesController = (function(superClass) {
    extend(ExcelInsertCompoundPropertiesController, superClass);

    function ExcelInsertCompoundPropertiesController() {
      this.fetchCompoundPropertiesReturn = bind(this.fetchCompoundPropertiesReturn, this);
      this.handleInsertPropertiesClicked = bind(this.handleInsertPropertiesClicked, this);
      this.parseInputArray = bind(this.parseInputArray, this);
      this.setErrorStatus = bind(this.setErrorStatus, this);
      this.setPropertyLookUpStatus = bind(this.setPropertyLookUpStatus, this);
      this.validate = bind(this.validate, this);
      this.handleGetPropertiesClicked = bind(this.handleGetPropertiesClicked, this);
      this.render = bind(this.render, this);
      return ExcelInsertCompoundPropertiesController.__super__.constructor.apply(this, arguments);
    }

    ExcelInsertCompoundPropertiesController.prototype.events = {
      'click .bv_getProperties': 'handleGetPropertiesClicked',
      'click .bv_insertProperties': 'handleInsertPropertiesClicked'
    };

    ExcelInsertCompoundPropertiesController.prototype.initialize = function() {
      return this.template = _.template($("#ExcelInsertCompoundPropertiesView").html());
    };

    ExcelInsertCompoundPropertiesController.prototype.render = function() {
      this.$el.empty();
      this.$el.html(this.template());
      this.attributesController = new AttributesController({
        el: $('.bv_attributes')
      });
      this.attributesController.render();
      this.batchPropertyDescriptorListController = new PropertyDescriptorListController({
        el: $('.bv_batchProperties'),
        title: 'Batch Properties',
        url: '/api/compound/batch/property/descriptors'
      });
      this.numberOfDescriptorsChecked = 0;
      this.batchPropertyDescriptorListController.on('ready', this.batchPropertyDescriptorListController.render);
      this.batchPropertyDescriptorListController.on('checked', (function(_this) {
        return function() {
          _this.numberOfDescriptorsChecked = _this.numberOfDescriptorsChecked + 1;
          return _this.validate();
        };
      })(this));
      this.batchPropertyDescriptorListController.on('unchecked', (function(_this) {
        return function() {
          _this.numberOfDescriptorsChecked = _this.numberOfDescriptorsChecked - 1;
          return _this.validate();
        };
      })(this));
      this.parentPropertyDescriptorListController = new PropertyDescriptorListController({
        el: $('.bv_parentProperties'),
        title: 'Parent Properties',
        url: '/api/compound/parent/property/descriptors'
      });
      this.parentPropertyDescriptorListController.on('ready', this.parentPropertyDescriptorListController.render);
      this.parentPropertyDescriptorListController.on('checked', (function(_this) {
        return function() {
          _this.numberOfDescriptorsChecked = _this.numberOfDescriptorsChecked + 1;
          return _this.validate();
        };
      })(this));
      this.parentPropertyDescriptorListController.on('unchecked', (function(_this) {
        return function() {
          _this.numberOfDescriptorsChecked = _this.numberOfDescriptorsChecked - 1;
          return _this.validate();
        };
      })(this));
      this.$("[data-toggle=popover]").popover({
        html: true,
        content: '1. Choose Properties to look up.<br /> 2. Select input IDs in workbook.<br /> 3. Click <button class="btn btn-xs btn-primary">Get Properties</button><br /> 4. Select a cell at the upper-left corner where you want the Properties to be inserted.<br /> 5. Click <button class="btn btn-xs btn-primary">Insert Properties</button>'
      });
      return Office.context.document.addHandlerAsync(Office.EventType.DocumentSelectionChanged, (function(_this) {
        return function() {
          return _this.validate();
        };
      })(this));
    };

    ExcelInsertCompoundPropertiesController.prototype.handleGetPropertiesClicked = function() {
      return Office.context.document.getSelectedDataAsync('matrix', (function(_this) {
        return function(result) {
          if (result.status === 'succeeded') {
            return _this.parseInputArray(result.value);
          } else {
            return logger.log(result.error.name + ': ' + result.error.name);
          }
        };
      })(this));
    };

    ExcelInsertCompoundPropertiesController.prototype.validate = function() {
      if (this.numberOfDescriptorsChecked === 0) {
        this.$('.bv_getProperties').attr('disabled', 'disabled');
        return this.setErrorStatus('Please check atleast one property');
      } else {
        return Office.context.document.getSelectedDataAsync('matrix', (function(_this) {
          return function(result) {
            var error, errorMessage, i, inputArray, len, req, request;
            if (result.status === 'succeeded') {
              inputArray = result.value;
              error = false;
              if (inputArray != null) {
                request = [];
                for (i = 0, len = inputArray.length; i < len; i++) {
                  req = inputArray[i];
                  if (req.length > 1) {
                    error = true;
                    errorMessage = 'Select a single column';
                    break;
                  } else {
                    request.push(req[0]);
                  }
                }
                if (!error && request.join("") === "") {
                  error = true;
                  errorMessage = 'Please select non-empty cells';
                }
              }
              if (error) {
                _this.$('.bv_getProperties').attr('disabled', 'disabled');
                return _this.setErrorStatus(errorMessage);
              } else {
                _this.$('.bv_getProperties').removeAttr('disabled');
                return _this.setErrorStatus('');
              }
            }
          };
        })(this));
      }
    };

    ExcelInsertCompoundPropertiesController.prototype.setPropertyLookUpStatus = function(status) {
      return this.$('.bv_propertyLookUpStatus').html(status);
    };

    ExcelInsertCompoundPropertiesController.prototype.setErrorStatus = function(status) {
      this.$('.bv_errorStatus').html(status);
      if (status === "" | this.$('.bv_propertyLookUpStatus').html() === "Data ready to insert" | this.$('.bv_propertyLookUpStatus').html() === "Fetching data...") {
        return this.$('.bv_errorStatus').addClass('hide');
      } else {
        return this.$('.bv_errorStatus').removeClass('hide');
      }
    };

    ExcelInsertCompoundPropertiesController.prototype.parseInputArray = function(inputArray) {
      var error, i, len, req, request;
      error = false;
      if (inputArray != null) {
        request = [];
        for (i = 0, len = inputArray.length; i < len; i++) {
          req = inputArray[i];
          if (req.length > 1) {
            error = true;
            this.setErrorStatus('Select a single column');
            break;
          } else {
            request.push(req[0]);
          }
        }
      }
      if (!error) {
        return this.getPropertiesAndRequestData(request);
      }
    };

    ExcelInsertCompoundPropertiesController.prototype.handleInsertPropertiesClicked = function() {
      return this.insertTable(this.outputArray);
    };

    ExcelInsertCompoundPropertiesController.prototype.insertTable = function(dataArray) {
      return Office.context.document.setSelectedDataAsync(dataArray, {
        coercionType: 'matrix'
      }, (function(_this) {
        return function(result) {
          if (result.status !== 'succeeded') {
            return logger.log(result.error.name + ':' + result.error.message);
          }
        };
      })(this));
    };

    ExcelInsertCompoundPropertiesController.prototype.getPropertiesAndRequestData = function(request) {
      var entityIdStringLines;
      this.$('.bv_insertProperties').attr('disabled', 'disabled');
      this.$('.bv_getProperties').attr('disabled', 'disabled');
      this.setPropertyLookUpStatus("Fetching data...");
      entityIdStringLines = request.join("\n");
      return this.getSelectedProperties((function(_this) {
        return function(selectedProperties) {
          return _this.getPreferredIDAndProperties(entityIdStringLines, selectedProperties);
        };
      })(this));
    };

    ExcelInsertCompoundPropertiesController.prototype.fetchPreferredReturn = function(json) {
      var i, len, prefName, ref, res;
      this.preferredIds = [];
      ref = json.results;
      for (i = 0, len = ref.length; i < len; i++) {
        res = ref[i];
        prefName = res.preferredName === "" ? "not found" : res.preferredName;
        this.preferredIds.push(prefName);
      }
      return this.fetchCompoundProperties();
    };

    ExcelInsertCompoundPropertiesController.prototype.getSelectedProperties = function(callback) {
      return this.parentPropertyDescriptorListController.getSelectedProperties((function(_this) {
        return function(parentProperties) {
          return _this.batchPropertyDescriptorListController.getSelectedProperties(function(batchProperties) {
            var selectedProperties;
            selectedProperties = [];
            selectedProperties = {
              parentNames: parentProperties.names,
              parentPrettyNames: parentProperties.prettyNames,
              batchNames: batchProperties.names,
              batchPrettyNames: batchProperties.prettyNames
            };
            return callback(selectedProperties);
          });
        };
      })(this));
    };

    ExcelInsertCompoundPropertiesController.prototype.getPreferredIDAndProperties = function(entityIdStringLines, selectedProperties) {
      var req;
      req = {
        entityIdStringLines: entityIdStringLines,
        selectedProperties: selectedProperties,
        includeRequestedName: this.attributesController.getIncludeRequestedID(),
        insertColumnHeaders: this.attributesController.getInsertColumnHeaders()
      };
      return $.ajax({
        type: 'POST',
        url: "/excelApps/getPreferredIDAndProperties",
        timeout: 180000,
        data: req,
        success: (function(_this) {
          return function(csv) {
            return _this.fetchCompoundPropertiesReturn(csv);
          };
        })(this),
        error: (function(_this) {
          return function(jqXHR, textStatus) {
            _this.setPropertyLookUpStatus("Error fetching data");
            logger.log(textStatus);
            logger.log(JSON.stringify(jqXHR));
            _this.$('.bv_insertProperties').removeAttr('disabled');
            return _this.$('.bv_getProperties').removeAttr('disabled');
          };
        })(this)
      });
    };

    ExcelInsertCompoundPropertiesController.prototype.fetchCompoundPropertiesReturn = function(csv) {
      this.outputArray = this.convertCSVToMatrix(csv);
      this.setPropertyLookUpStatus("Data ready to insert");
      this.$('.bv_insertProperties').removeAttr('disabled');
      return this.$('.bv_getProperties').removeAttr('disabled');
    };

    ExcelInsertCompoundPropertiesController.prototype.convertCSVToMatrix = function(csv) {
      var i, len, lines, outMatrix, row;
      outMatrix = [];
      lines = csv.split('\n').slice(0, -1);
      for (i = 0, len = lines.length; i < len; i++) {
        row = lines[i];
        outMatrix.push(row.split('\t'));
      }
      return outMatrix;
    };

    return ExcelInsertCompoundPropertiesController;

  })(Backbone.View);

  window.ExcelAppLogger = (function(superClass) {
    extend(ExcelAppLogger, superClass);

    function ExcelAppLogger() {
      this.handleClearLogClicked = bind(this.handleClearLogClicked, this);
      this.render = bind(this.render, this);
      return ExcelAppLogger.__super__.constructor.apply(this, arguments);
    }

    ExcelAppLogger.prototype.events = {
      'click .bv_clearLog': 'handleClearLogClicked'
    };

    ExcelAppLogger.prototype.initialize = function() {
      return this.template = _.template($("#ExcelAppLoggerView").html());
    };

    ExcelAppLogger.prototype.render = function() {
      this.$el.empty();
      return this.$el.html(this.template());
    };

    ExcelAppLogger.prototype.log = function(logstr) {
      return this.$('.bv_logEntries').append("<div>" + logstr + "</div>");
    };

    ExcelAppLogger.prototype.handleClearLogClicked = function() {
      return this.$('.bv_logEntries').empty();
    };

    return ExcelAppLogger;

  })(Backbone.View);

}).call(this);
