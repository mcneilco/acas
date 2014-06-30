(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.ExperimentSearch = (function(_super) {
    __extends(ExperimentSearch, _super);

    function ExperimentSearch() {
      return ExperimentSearch.__super__.constructor.apply(this, arguments);
    }

    ExperimentSearch.prototype.defaults = {
      protocolCode: null,
      experimentCode: null
    };

    return ExperimentSearch;

  })(Backbone.Model);

  window.ExperimentSearchController = (function(_super) {
    __extends(ExperimentSearchController, _super);

    function ExperimentSearchController() {
      this.setupExperimentSummaryTable = __bind(this.setupExperimentSummaryTable, this);
      this.selectedExperimentUpdated = __bind(this.selectedExperimentUpdated, this);
      this.doGenericExperimentSearch = __bind(this.doGenericExperimentSearch, this);
      this.handleFindClicked = __bind(this.handleFindClicked, this);
      this.updateExperimentCode = __bind(this.updateExperimentCode, this);
      this.updateModel = __bind(this.updateModel, this);
      this.render = __bind(this.render, this);
      return ExperimentSearchController.__super__.constructor.apply(this, arguments);
    }

    ExperimentSearchController.prototype.template = _.template($("#ExperimentSearchView").html());

    ExperimentSearchController.prototype.events = {
      'change .bv_protocolName': 'updateModel',
      'change .bv_experimentCode': 'updateModel',
      'keyup .bv_experimentCode': 'updateExperimentCode',
      'click .bv_find': 'handleFindClicked'
    };

    ExperimentSearchController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      return this.setupProtocolSelect();
    };

    ExperimentSearchController.prototype.updateModel = function() {
      return this.model.set({
        protocolCode: this.$('.bv_protocolName').val(),
        experimentCode: this.getTrimmedInput('.bv_experimentCode')
      });
    };

    ExperimentSearchController.prototype.updateExperimentCode = function() {
      var experimentCode;
      experimentCode = $.trim(this.$(".bv_experimentCode").val());
      if (experimentCode !== "") {
        this.$(".bv_protocolKind").prop("disabled", true);
        return this.$(".bv_protocolName").prop("disabled", true);
      } else {
        this.$(".bv_protocolKind").prop("disabled", false);
        return this.$(".bv_protocolName").prop("disabled", false);
      }
    };

    ExperimentSearchController.prototype.handleFindClicked = function() {
      var experimentCode, protocolCode;
      this.trigger('find');
      protocolCode = $(".bv_protocolName").val();
      $(".bv_experimentTableController").html("Searching...");
      experimentCode = $.trim(this.$(".bv_experimentCode").val());
      if (experimentCode !== "") {
        return this.doGenericExperimentSearch(experimentCode);
      } else {
        return $.ajax({
          type: 'GET',
          url: "api/experimentsForProtocol/" + protocolCode,
          data: {
            testMode: false
          },
          success: (function(_this) {
            return function(experiments) {
              window.fooexperiments = experiments;
              return _this.setupExperimentSummaryTable(experiments);
            };
          })(this)
        });
      }

      /*$.get("/api/experiments/protocolCodename/#{protocolCode}", ( experiments ) =>
      			@setupExperimentSummaryTable experiments
      		)
       */

      /*
      		$.get( "/api/ExperimentsForProtocol", ( experiments ) =>
      			@setupExperimentSummaryTable experiments
      		)
       */
    };

    ExperimentSearchController.prototype.doGenericExperimentSearch = function(searchTerm) {
      console.log("doGenericExperimentSearch");
      return $.ajax({
        type: 'GET',
        url: "/api/experiments/genericSearch/" + searchTerm,
        dataType: "json",
        data: {
          testMode: false,
          fullObject: true
        },
        success: (function(_this) {
          return function(experiment) {
            window.fooexperiments = experiment;
            return _this.setupExperimentSummaryTable([experiment]);
          };
        })(this)
      });
    };

    ExperimentSearchController.prototype.setupProtocolSelect = function() {
      this.protocolList = new PickListList();
      this.protocolList.url = "/api/protocolKindCodes/";
      this.protocolListController = new PickListSelectController({
        el: this.$('.bv_protocolKind'),
        collection: this.protocolList,
        insertFirstOption: new PickList({
          code: "any",
          name: "any"
        }),
        selectedCode: null
      });
      this.protocolNameList = new PickListList();
      this.protocolNameList.url = "/api/protocolCodes/";
      this.protocolNameListController = new PickListSelectController({
        el: this.$('.bv_protocolName'),
        collection: this.protocolNameList,
        insertFirstOption: new PickList({
          code: "any",
          name: "any"
        }),
        selectedCode: null
      });
      return $(this.protocolListController.el).on("change", (function(_this) {
        return function() {
          _this.protocolNameList.url = "/api/protocolCodes?protocolKind=" + ($(_this.protocolListController.el).val());
          _this.protocolNameList.reset();
          return _this.protocolNameList.fetch();
        };
      })(this));
    };

    ExperimentSearchController.prototype.selectedExperimentUpdated = function(experiment) {
      var experimentController;
      this.trigger("selectedExperimentUpdated");
      experimentController = new ExperimentBaseController({
        model: experiment,
        el: $('.bv_experimentBaseController')
      });
      experimentController.render();
      return $(".bv_experimentBaseController").show();
    };

    ExperimentSearchController.prototype.setupExperimentSummaryTable = function(experiments) {
      this.experimentSummaryTable = new ExperimentSummaryTableController({
        el: $(".bv_experimentTableController"),
        collection: new ExperimentList(experiments)
      });
      this.experimentSummaryTable.on("selectedRowUpdated", this.selectedExperimentUpdated);
      return this.experimentSummaryTable.render();
    };

    return ExperimentSearchController;

  })(AbstractFormController);

  window.ExperimentSearch = (function(_super) {
    __extends(ExperimentSearch, _super);

    function ExperimentSearch() {
      return ExperimentSearch.__super__.constructor.apply(this, arguments);
    }

    ExperimentSearch.prototype.defaults = {
      protocolCode: null,
      experimentCode: null
    };

    return ExperimentSearch;

  })(Backbone.Model);

  window.ExperimentSimpleSearchController = (function(_super) {
    __extends(ExperimentSimpleSearchController, _super);

    function ExperimentSimpleSearchController() {
      this.doSearch = __bind(this.doSearch, this);
      this.handleDoSearchClicked = __bind(this.handleDoSearchClicked, this);
      this.updateExperimentSearchTerm = __bind(this.updateExperimentSearchTerm, this);
      this.render = __bind(this.render, this);
      return ExperimentSimpleSearchController.__super__.constructor.apply(this, arguments);
    }

    ExperimentSimpleSearchController.prototype.template = _.template($("#ExperimentSimpleSearchView").html());

    ExperimentSimpleSearchController.prototype.events = {
      'keyup .bv_experimentSearchTerm': 'updateExperimentSearchTerm',
      'click .bv_doSearch': 'handleDoSearchClicked'
    };

    ExperimentSimpleSearchController.prototype.render = function() {
      $(this.el).empty();
      return $(this.el).html(this.template());
    };

    ExperimentSimpleSearchController.prototype.updateExperimentSearchTerm = function(e) {
      var ENTER_KEY, experimentSearchTerm;
      ENTER_KEY = 13;
      experimentSearchTerm = $.trim(this.$(".bv_experimentSearchTerm").val());
      if (experimentSearchTerm !== "") {
        this.$(".bv_doSearch").attr("disabled", false);
        if (e.keyCode === ENTER_KEY) {
          $(':focus').blur();
          return this.handleDoSearchClicked();
        }
      } else {
        return this.$(".bv_doSearch").attr("disabled", true);
      }
    };

    ExperimentSimpleSearchController.prototype.handleDoSearchClicked = function() {
      var experimentSearchTerm;
      experimentSearchTerm = $.trim(this.$(".bv_experimentSearchTerm").val());
      if (experimentSearchTerm !== "") {
        if (this.$(".bv_clearSearchIcon").hasClass("hide")) {
          this.$(".bv_experimentSearchTerm").attr("disabled", true);
          this.$(".bv_doSearchIcon").addClass("hide");
          this.$(".bv_clearSearchIcon").removeClass("hide");
          return this.doSearch(experimentSearchTerm);
        } else {
          this.$(".bv_experimentSearchTerm").val("");
          this.$(".bv_experimentSearchTerm").attr("disabled", false);
          this.$(".bv_clearSearchIcon").addClass("hide");
          this.$(".bv_doSearchIcon").removeClass("hide");
          this.updateExperimentSearchTerm();
          return this.trigger("resetSearch");
        }
      }
    };

    ExperimentSimpleSearchController.prototype.doSearch = function(experimentSearchTerm) {
      this.trigger('find');
      $(".bv_experimentTableController").html("Searching...");
      if (experimentSearchTerm !== "") {
        console.log("doGenericExperimentSearch");
        return $.ajax({
          type: 'GET',
          url: "/api/experiments/genericSearch/" + experimentSearchTerm,
          dataType: "json",
          data: {
            testMode: false,
            fullObject: true
          },
          success: (function(_this) {
            return function(experiment) {
              return _this.trigger("searchReturned", [experiment]);
            };
          })(this)
        });
      }
    };

    return ExperimentSimpleSearchController;

  })(AbstractFormController);

  window.ExperimentRowSummaryController = (function(_super) {
    __extends(ExperimentRowSummaryController, _super);

    function ExperimentRowSummaryController() {
      this.render = __bind(this.render, this);
      this.handleClick = __bind(this.handleClick, this);
      return ExperimentRowSummaryController.__super__.constructor.apply(this, arguments);
    }

    ExperimentRowSummaryController.prototype.tagName = 'tr';

    ExperimentRowSummaryController.prototype.className = 'dataTableRow';

    ExperimentRowSummaryController.prototype.events = {
      "click": "handleClick"
    };

    ExperimentRowSummaryController.prototype.handleClick = function() {
      this.trigger("gotClick", this.model);
      $(this.el).closest("table").find("tr").removeClass("info");
      return $(this.el).addClass("info");
    };

    ExperimentRowSummaryController.prototype.initialize = function() {
      return this.template = _.template($('#ExperimentRowSummaryView').html());
    };

    ExperimentRowSummaryController.prototype.render = function() {
      var toDisplay;
      toDisplay = {
        experimentName: this.model.get('lsLabels').pickBestName().get('labelText'),
        experimentCode: this.model.get('codeName'),
        protocolName: this.model.get('protocol').get("preferredName"),
        recordedBy: this.model.get('recordedBy'),
        status: this.model.getStatus().get("stringValue"),
        analysisStatus: this.model.getAnalysisStatus().get("stringValue"),
        recordedDate: this.model.get("recordedDate")
      };
      $(this.el).html(this.template(toDisplay));
      return this;
    };

    return ExperimentRowSummaryController;

  })(Backbone.View);

  window.ExperimentSummaryTableController = (function(_super) {
    __extends(ExperimentSummaryTableController, _super);

    function ExperimentSummaryTableController() {
      this.render = __bind(this.render, this);
      this.selectedRowChanged = __bind(this.selectedRowChanged, this);
      return ExperimentSummaryTableController.__super__.constructor.apply(this, arguments);
    }

    ExperimentSummaryTableController.prototype.initialize = function() {};

    ExperimentSummaryTableController.prototype.selectedRowChanged = function(row) {
      return this.trigger("selectedRowUpdated", row);
    };

    ExperimentSummaryTableController.prototype.render = function() {
      this.template = _.template($('#ExperimentSummaryTableView').html());
      $(this.el).html(this.template);
      console.dir(this.collection);
      this.collection.each((function(_this) {
        return function(exp) {
          var ersc;
          ersc = new ExperimentRowSummaryController({
            model: exp
          });
          ersc.on("gotClick", _this.selectedRowChanged);
          return _this.$("tbody").append(ersc.render().el);
        };
      })(this));
      return this;
    };

    return ExperimentSummaryTableController;

  })(Backbone.View);

  window.ExperimentBrowserController = (function(_super) {
    __extends(ExperimentBrowserController, _super);

    function ExperimentBrowserController() {
      this.render = __bind(this.render, this);
      this.destroyExperimentSummaryTable = __bind(this.destroyExperimentSummaryTable, this);
      this.handleEditExperimentClicked = __bind(this.handleEditExperimentClicked, this);
      this.handleDeleteExperimentClicked = __bind(this.handleDeleteExperimentClicked, this);
      this.selectedExperimentUpdated = __bind(this.selectedExperimentUpdated, this);
      this.setupExperimentSummaryTable = __bind(this.setupExperimentSummaryTable, this);
      return ExperimentBrowserController.__super__.constructor.apply(this, arguments);
    }

    ExperimentBrowserController.prototype.template = _.template($("#ExperimentBrowserView").html());

    ExperimentBrowserController.prototype.events = {
      "click .bv_deleteExperiment": "handleDeleteExperimentClicked",
      "click .bv_editExperiment": "handleEditExperimentClicked"
    };

    ExperimentBrowserController.prototype.initialize = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      this.searchController = new ExperimentSimpleSearchController({
        model: new ExperimentSearch(),
        el: this.$('.bv_experimentSearchController')
      });
      this.searchController.render();
      this.searchController.on("searchReturned", this.setupExperimentSummaryTable);
      return this.searchController.on("resetSearch", this.destroyExperimentSummaryTable);

      /*
      		@searchController = new ExperimentSearchController
      			model: new ExperimentSearch()
      			el: @$('.bv_experimentSearchController')
      		@searchController.render()
       */
    };

    ExperimentBrowserController.prototype.setupExperimentSummaryTable = function(experiments) {
      this.experimentSummaryTable = new ExperimentSummaryTableController({
        collection: new ExperimentList(experiments)
      });
      this.experimentSummaryTable.on("selectedRowUpdated", this.selectedExperimentUpdated);
      $(".bv_experimentTableController").html(this.experimentSummaryTable.render().el);
      return $(".bv_matchingExperimentsHeader").removeClass("hide");
    };

    ExperimentBrowserController.prototype.selectedExperimentUpdated = function(experiment) {
      this.trigger("selectedExperimentUpdated");
      this.experimentController = new ExperimentBaseController({
        model: experiment
      });
      $('.bv_experimentBaseController').html(this.experimentController.render().el);
      this.experimentController.displayInReadOnlyMode();
      $(".bv_experimentBaseController").removeClass("hide");
      return $(".bv_experimentBaseControllerContainer").removeClass("hide");
    };

    ExperimentBrowserController.prototype.handleDeleteExperimentClicked = function() {
      $(".bv_confirmDeleteExperiment").removeClass("hide");
      return $('.bv_confirmDeleteExperiment').modal({
        keyboard: false,
        backdrop: true
      });
    };

    ExperimentBrowserController.prototype.handleEditExperimentClicked = function() {
      return window.open("/api/experiments/edit/" + (this.experimentController.model.get("codeName")), '_blank');
    };

    ExperimentBrowserController.prototype.destroyExperimentSummaryTable = function() {
      this.experimentSummaryTable.remove();
      this.experimentController.remove();
      $(".bv_matchingExperimentsHeader").addClass("hide");
      $(".bv_experimentBaseController").addClass("hide");
      return $(".bv_experimentBaseControllerContainer").addClass("hide");
    };

    ExperimentBrowserController.prototype.render = function() {
      return this;
    };

    return ExperimentBrowserController;

  })(Backbone.View);

  window.ExperimentDetailController = (function(_super) {
    __extends(ExperimentDetailController, _super);

    function ExperimentDetailController() {
      this.render = __bind(this.render, this);
      return ExperimentDetailController.__super__.constructor.apply(this, arguments);
    }

    ExperimentDetailController.prototype.template = _.template($("#ExperimentDetailsView").html());

    ExperimentDetailController.prototype.initialize = function() {
      $(this.el).empty();
      return $(this.el).html(this.template());
    };

    ExperimentDetailController.prototype.render = function() {
      return this;
    };

    return ExperimentDetailController;

  })(Backbone.View);

}).call(this);
