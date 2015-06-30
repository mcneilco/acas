(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

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

  window.Attributes = (function(superClass) {
    extend(Attributes, superClass);

    function Attributes() {
      return Attributes.__super__.constructor.apply(this, arguments);
    }

    Attributes.prototype.defaults = {
      insertColumnHeaders: true,
      includeRequestedID: true
    };

    return Attributes;

  })(Backbone.Model);

  window.AttributesController = (function(superClass) {
    extend(AttributesController, superClass);

    function AttributesController() {
      this.render = bind(this.render, this);
      return AttributesController.__super__.constructor.apply(this, arguments);
    }

    AttributesController.prototype.initialize = function() {
      return this.template = _.template($("#AttributesControllerView").html());
    };

    AttributesController.prototype.render = function() {
      this.$el.empty();
      this.attributes = new Attributes();
      return this.$el.html(this.template(this.attributes.attributes));
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
      return this.model.set('isChecked', this.$('.bv_propertyDescriptorCheckbox').is(":checked"));
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

    PropertyDescriptorListController.prototype.getSelectedProperties = function() {
      var selectedProperties, selectedPropertyNames;
      selectedProperties = this.collection.where({
        isChecked: true
      });
      selectedPropertyNames = [];
      selectedProperties.forEach(function(selectedProperty) {
        return selectedPropertyNames.push(selectedProperty.get('valueDescriptor').name);
      });
      return selectedPropertyNames;
    };

    PropertyDescriptorListController.prototype.addPropertyDescriptor = function(propertyDescriptor) {
      var pdc;
      pdc = new PropertyDescriptorController({
        model: propertyDescriptor
      });
      return this.propertyControllersList.push(pdc);
    };

    return PropertyDescriptorListController;

  })(Backbone.View);

  window.ExcelInsertCompoundPropertiesController = (function(superClass) {
    extend(ExcelInsertCompoundPropertiesController, superClass);

    function ExcelInsertCompoundPropertiesController() {
      this.handleInsertPropertiesClicked = bind(this.handleInsertPropertiesClicked, this);
      this.parseInputArray = bind(this.parseInputArray, this);
      this.setErrorStatus = bind(this.setErrorStatus, this);
      this.setPropertyLookUpStatus = bind(this.setPropertyLookUpStatus, this);
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
      this.batchPropertyDescriptorListController.on('ready', this.batchPropertyDescriptorListController.render);
      this.parentPropertyDescriptorListController = new PropertyDescriptorListController({
        el: $('.bv_parentProperties'),
        title: 'Parent Properties',
        url: '/api/compound/parent/property/descriptors'
      });
      this.parentPropertyDescriptorListController.on('ready', this.parentPropertyDescriptorListController.render);
      this.$("[data-toggle=popover]").popover({
        html: true,
        content: '1. Choose Properties to look up.<br /> 2. Select input IDs in workbook.<br /> 3. Click <button class="btn btn-xs btn-primary">Get Properties</button><br /> 4. Select a cell at the upper-left corner where you want the Properties to be inserted.<br /> 5. Click <button class="btn btn-xs btn-primary">Insert Properties</button>'
      });
      return Office.context.document.addHandlerAsync(Office.EventType.DocumentSelectionChanged, (function(_this) {
        return function() {
          return _this.setErrorStatus("");
        };
      })(this));
    };

    ExcelInsertCompoundPropertiesController.prototype.handleGetPropertiesClicked = function() {
      logger.log("Get Properties Clicked");
      logger.log(this.setPropertyLookUpStatus);
      this.setPropertyLookUpStatus("Loading...");
      return Office.context.document.getSelectedDataAsync('matrix', (function(_this) {
        return function(result) {
          if (result.status === 'succeeded') {
            logger.log("Fetched data");
            return _this.parseInputArray(result.value);
          } else {
            return logger.log(result.error.name + ': ' + result.error.name);
          }
        };
      })(this));
    };

    ExcelInsertCompoundPropertiesController.prototype.setPropertyLookUpStatus = function(status) {
      return this.$('.bv_propertyLookUpStatus').html(status);
    };

    ExcelInsertCompoundPropertiesController.prototype.setErrorStatus = function(status) {
      this.setPropertyLookUpStatus('');
      this.$('.bv_errorStatus').html(status);
      if (status === "") {
        return this.$('.bv_errorStatus').addClass('hide');
      } else {
        return this.$('.bv_errorStatus').removeClass('hide');
      }
    };

    ExcelInsertCompoundPropertiesController.prototype.parseInputArray = function(inputArray) {
      var error, i, len, req, request;
      error = false;
      if (inputArray != null) {
        request = {
          requests: []
        };
        for (i = 0, len = inputArray.length; i < len; i++) {
          req = inputArray[i];
          if (req.length > 1) {
            error = true;
            this.setErrorStatus('Select a single column');
            break;
          } else {
            request.requests.push({
              requestName: req[0]
            });
          }
        }
      }
      if (!error) {
        return this.fetchPreferred(request);
      }
    };

    ExcelInsertCompoundPropertiesController.prototype.showError = function(error) {};

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

    ExcelInsertCompoundPropertiesController.prototype.fetchPreferred = function(request) {
      this.setPropertyLookUpStatus("Fetching preferred ids...");
      logger.log("starting addPreferred");
      return $.ajax({
        type: 'POST',
        url: "/api/preferredBatchId",
        data: request,
        dataType: 'json',
        success: (function(_this) {
          return function(json) {
            logger.log("got preferred id response");
            return _this.fetchPreferredReturn(json);
          };
        })(this),
        error: (function(_this) {
          return function(err) {
            _this.setErrorStatus("Error fetching preferred ids");
            return logger.log('got ajax error fetching preferred ids');
          };
        })(this)
      });
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

    ExcelInsertCompoundPropertiesController.prototype.getSelectedProperties = function() {
      var selectedParentProperties;
      selectedParentProperties = [];
      selectedParentProperties.parent = this.parentPropertyDescriptorListController.getSelectedProperties();
      selectedParentProperties.batch = this.batchPropertyDescriptorListController.getSelectedProperties();
      return selectedParentProperties;
    };

    ExcelInsertCompoundPropertiesController.prototype.fetchCompoundProperties = function() {
      var request, selectedProperties;
      this.setPropertyLookUpStatus("Fetching properties...");
      selectedProperties = this.getSelectedProperties();
      request = {
        properties: selectedProperties.parent,
        entityIdStringLines: this.preferredIds.join('\n')
      };
      return $.ajax({
        type: 'POST',
        url: "/api/testedEntities/properties",
        data: request,
        dataType: 'json',
        success: (function(_this) {
          return function(json) {
            logger.log("got compound property response");
            return _this.fetchCompoundPropertiesReturn(json);
          };
        })(this),
        error: (function(_this) {
          return function(err) {
            _this.setErrorStatus("Error fetching properties");
            return logger.log('got ajax error fetching properties');
          };
        })(this)
      });
    };

    ExcelInsertCompoundPropertiesController.prototype.fetchCompoundPropertiesReturn = function(json) {
      logger.log(json.resultCSV);
      this.outputArray = this.convertCSVToMatrix(json.resultCSV);
      return this.setPropertyLookUpStatus("Data ready to insert...");
    };

    ExcelInsertCompoundPropertiesController.prototype.convertCSVToMatrix = function(csv) {
      var i, len, lines, outMatrix, row;
      outMatrix = [];
      lines = csv.split('\n').slice(0, -1);
      logger.log(lines.length);
      for (i = 0, len = lines.length; i < len; i++) {
        row = lines[i];
        outMatrix.push(row.split(','));
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
