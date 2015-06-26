(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

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

  window.ExcelInsertCompoundPropertiesController = (function(superClass) {
    extend(ExcelInsertCompoundPropertiesController, superClass);

    function ExcelInsertCompoundPropertiesController() {
      this.handleInsertPropertiesClicked = bind(this.handleInsertPropertiesClicked, this);
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
      return this.$el.html(this.template());
    };

    ExcelInsertCompoundPropertiesController.prototype.handleGetPropertiesClicked = function() {
      logger.log("got Get Properties Clicked");
      return Office.context.document.getSelectedDataAsync('matrix', (function(_this) {
        return function(result) {
          if (result.status === 'succeeded') {
            logger.log("Fetched data");
            return _this.fetchPreferred(result.value);
          } else {
            return logger.log(result.error.name + ': ' + result.error.name);
          }
        };
      })(this));
    };

    ExcelInsertCompoundPropertiesController.prototype.handleInsertPropertiesClicked = function() {
      return this.insertTable(this.outputArray);
    };

    ExcelInsertCompoundPropertiesController.prototype.insertTable = function(dataArray) {
      logger.log(dataArray);
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

    ExcelInsertCompoundPropertiesController.prototype.fetchPreferred = function(inputArray) {
      var i, len, req, request;
      logger.log("starting addPreferred");
      logger.log(inputArray);
      request = {
        requests: []
      };
      for (i = 0, len = inputArray.length; i < len; i++) {
        req = inputArray[i];
        request.requests.push({
          requestName: req[0]
        });
      }
      return $.ajax({
        type: 'POST',
        url: "/api/preferredBatchId",
        data: request,
        dataType: 'json',
        success: (function(_this) {
          return function(json) {
            logger.log("got preferred id response");
            return _this.fetchPreferredRetun(json);
          };
        })(this),
        error: (function(_this) {
          return function(err) {
            return console.log('got ajax error fetching preferred ids');
          };
        })(this)
      });
    };

    ExcelInsertCompoundPropertiesController.prototype.fetchPreferredRetun = function(json) {
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

    ExcelInsertCompoundPropertiesController.prototype.fetchCompoundProperties = function() {
      var request;
      request = {
        properties: ["HEAVY_ATOM_COUNT", "MONOISOTOPIC_MASS"],
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
            return console.log('got ajax error fetching compound properties');
          };
        })(this)
      });
    };

    ExcelInsertCompoundPropertiesController.prototype.fetchCompoundPropertiesReturn = function(json) {
      logger.log(json.resultCSV);
      return this.outputArray = this.convertCSVToMatrix(json.resultCSV);
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
