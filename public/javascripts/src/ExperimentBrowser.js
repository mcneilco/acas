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
        experimentCode: UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_experimentCode'))
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
              return _this.setupExperimentSummaryTable(experiments);
            };
          })(this)
        });
      }
    };


    /*$.get("/api/experiments/protocolCodename/#{protocolCode}", ( experiments ) =>
    		@setupExperimentSummaryTable experiments
    	)
     */


    /*
    	$.get( "/api/ExperimentsForProtocol", ( experiments ) =>
    		@setupExperimentSummaryTable experiments
    	)
     */

    ExperimentSearchController.prototype.doGenericExperimentSearch = function(searchTerm) {
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
      $(".bv_experimentTableController").removeClass("hide");
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

    ExperimentSimpleSearchController.prototype.genericSearchUrl = "/api/experiments/genericSearch/";

    ExperimentSimpleSearchController.prototype.codeNameSearchUrl = "/api/experiments/codename/";

    ExperimentSimpleSearchController.prototype.initialize = function() {
      this.includeDuplicateAndEdit = this.options.includeDuplicateAndEdit;
      this.searchUrl = "";
      if (this.includeDuplicateAndEdit) {
        return this.searchUrl = this.genericSearchUrl;
      } else {
        return this.searchUrl = this.codeNameSearchUrl;
      }
    };

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
      $(".bv_experimentTableController").addClass("hide");
      $(".bv_errorOccurredPerformingSearch").addClass("hide");
      experimentSearchTerm = $.trim(this.$(".bv_experimentSearchTerm").val());
      $(".bv_searchTerm").val("");
      if (experimentSearchTerm !== "") {
        if (this.$(".bv_clearSearchIcon").hasClass("hide")) {
          this.$(".bv_experimentSearchTerm").attr("disabled", true);
          this.$(".bv_doSearchIcon").addClass("hide");
          this.$(".bv_clearSearchIcon").removeClass("hide");
          $(".bv_searchingMessage").removeClass("hide");
          $(".bv_experimentBrowserSearchInstructions").addClass("hide");
          $(".bv_searchTerm").html(experimentSearchTerm);
          return this.doSearch(experimentSearchTerm);
        } else {
          this.$(".bv_experimentSearchTerm").val("");
          this.$(".bv_experimentSearchTerm").attr("disabled", false);
          this.$(".bv_clearSearchIcon").addClass("hide");
          this.$(".bv_doSearchIcon").removeClass("hide");
          $(".bv_searchingMessage").addClass("hide");
          $(".bv_experimentBrowserSearchInstructions").removeClass("hide");
          $(".bv_searchStatusIndicator").removeClass("hide");
          this.updateExperimentSearchTerm();
          return this.trigger("resetSearch");
        }
      }
    };

    ExperimentSimpleSearchController.prototype.doSearch = function(experimentSearchTerm) {
      this.trigger('find');
      if (experimentSearchTerm !== "") {
        return $.ajax({
          type: 'GET',
          url: this.searchUrl + experimentSearchTerm,
          dataType: "json",
          data: {
            testMode: false
          },
          success: (function(_this) {
            return function(experiment) {
              return _this.trigger("searchReturned", experiment);
            };
          })(this),
          error: (function(_this) {
            return function(result) {
              return _this.trigger("searchReturned", null);
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
        protocolName: this.model.get('protocol').get("codeName"),
        recordedBy: this.model.get('recordedBy'),
        status: this.model.getStatus().get("codeValue"),
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
      window.fooSearchResults = this.collection;
      if (this.collection.models.length === 0) {
        this.$(".bv_noMatchesFoundMessage").removeClass("hide");
      } else {
        this.$(".bv_noMatchesFoundMessage").addClass("hide");
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
        this.$("table").dataTable({
          oLanguage: {
            sSearch: "Filter results: "
          }
        });
      }
      return this;
    };

    return ExperimentSummaryTableController;

  })(Backbone.View);

  window.ExperimentBrowserController = (function(_super) {
    __extends(ExperimentBrowserController, _super);

    function ExperimentBrowserController() {
      this.render = __bind(this.render, this);
      this.destroyExperimentSummaryTable = __bind(this.destroyExperimentSummaryTable, this);
      this.handleDuplicateExperimentClicked = __bind(this.handleDuplicateExperimentClicked, this);
      this.handleEditExperimentClicked = __bind(this.handleEditExperimentClicked, this);
      this.handleCancelDeleteClicked = __bind(this.handleCancelDeleteClicked, this);
      this.handleConfirmDeleteExperimentClicked = __bind(this.handleConfirmDeleteExperimentClicked, this);
      this.handleDeleteExperimentClicked = __bind(this.handleDeleteExperimentClicked, this);
      this.selectedExperimentUpdated = __bind(this.selectedExperimentUpdated, this);
      this.setupExperimentSummaryTable = __bind(this.setupExperimentSummaryTable, this);
      return ExperimentBrowserController.__super__.constructor.apply(this, arguments);
    }

    ExperimentBrowserController.prototype.includeDuplicateAndEdit = true;

    ExperimentBrowserController.prototype.events = {
      "click .bv_deleteExperiment": "handleDeleteExperimentClicked",
      "click .bv_editExperiment": "handleEditExperimentClicked",
      "click .bv_duplicateExperiment": "handleDuplicateExperimentClicked",
      "click .bv_confirmDeleteExperimentButton": "handleConfirmDeleteExperimentClicked",
      "click .bv_cancelDelete": "handleCancelDeleteClicked"
    };

    ExperimentBrowserController.prototype.initialize = function() {
      var template;
      template = _.template($("#ExperimentBrowserView").html(), {
        includeDuplicateAndEdit: this.includeDuplicateAndEdit
      });
      $(this.el).empty();
      $(this.el).html(template);
      this.searchController = new ExperimentSimpleSearchController({
        model: new ExperimentSearch(),
        el: this.$('.bv_experimentSearchController'),
        includeDuplicateAndEdit: this.includeDuplicateAndEdit
      });
      this.searchController.render();
      this.searchController.on("searchReturned", this.setupExperimentSummaryTable);
      return this.searchController.on("resetSearch", this.destroyExperimentSummaryTable);
    };

    ExperimentBrowserController.prototype.setupExperimentSummaryTable = function(experiments) {
      $(".bv_searchingMessage").addClass("hide");
      if (experiments === null) {
        return this.$(".bv_errorOccurredPerformingSearch").removeClass("hide");
      } else if (experiments.length === 0) {
        this.$(".bv_noMatchesFoundMessage").removeClass("hide");
        return this.$(".bv_experimentTableController").html("");
      } else {
        $(".bv_searchStatusIndicator").addClass("hide");
        this.$(".bv_experimentTableController").removeClass("hide");
        this.experimentSummaryTable = new ExperimentSummaryTableController({
          collection: new ExperimentList(experiments)
        });
        this.experimentSummaryTable.on("selectedRowUpdated", this.selectedExperimentUpdated);
        return $(".bv_experimentTableController").html(this.experimentSummaryTable.render().el);
      }
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
      this.$(".bv_experimentCodeName").html(this.experimentController.model.get("codeName"));
      this.$(".bv_deleteButtons").removeClass("hide");
      this.$(".bv_okayButton").addClass("hide");
      this.$(".bv_errorDeletingExperimentMessage").addClass("hide");
      this.$(".bv_deleteWarningMessage").removeClass("hide");
      this.$(".bv_deletingStatusIndicator").addClass("hide");
      this.$(".bv_experimentDeletedSuccessfullyMessage").addClass("hide");
      $(".bv_confirmDeleteExperiment").removeClass("hide");
      return $('.bv_confirmDeleteExperiment').modal({
        keyboard: false,
        backdrop: true
      });
    };

    ExperimentBrowserController.prototype.handleConfirmDeleteExperimentClicked = function() {
      this.$(".bv_deleteWarningMessage").addClass("hide");
      this.$(".bv_deletingStatusIndicator").removeClass("hide");
      this.$(".bv_deleteButtons").addClass("hide");
      return $.ajax({
        url: "api/experiments/" + (this.experimentController.model.get("id")),
        type: 'DELETE',
        success: (function(_this) {
          return function(result) {
            _this.$(".bv_okayButton").removeClass("hide");
            _this.$(".bv_deletingStatusIndicator").addClass("hide");
            _this.$(".bv_experimentDeletedSuccessfullyMessage").removeClass("hide");
            return _this.searchController.handleDoSearchClicked();
          };
        })(this),
        error: (function(_this) {
          return function(result) {
            _this.$(".bv_okayButton").removeClass("hide");
            _this.$(".bv_deletingStatusIndicator").addClass("hide");
            return _this.$(".bv_errorDeletingExperimentMessage").removeClass("hide");
          };
        })(this)
      });
    };

    ExperimentBrowserController.prototype.handleCancelDeleteClicked = function() {
      return this.$(".bv_confirmDeleteExperiment").modal('hide');
    };

    ExperimentBrowserController.prototype.handleEditExperimentClicked = function() {
      return window.open("/entity/edit/codeName/" + (this.experimentController.model.get("codeName")), '_blank');
    };

    ExperimentBrowserController.prototype.handleDuplicateExperimentClicked = function() {
      var experimentKind;
      experimentKind = this.experimentController.model.get('lsKind');
      if (experimentKind === "flipr screening assay") {
        return window.open("/entity/copy/flipr_screening_assay/" + (this.experimentController.model.get("codeName")), '_blank');
      } else {
        return window.open("/entity/copy/experiment_base/" + (this.experimentController.model.get("codeName")), '_blank');
      }
    };

    ExperimentBrowserController.prototype.destroyExperimentSummaryTable = function() {
      if (this.experimentSummaryTable != null) {
        this.experimentSummaryTable.remove();
      }
      if (this.experimentController != null) {
        this.experimentController.remove();
      }
      $(".bv_experimentBaseController").addClass("hide");
      $(".bv_experimentBaseControllerContainer").addClass("hide");
      return $(".bv_noMatchesFoundMessage").addClass("hide");
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
