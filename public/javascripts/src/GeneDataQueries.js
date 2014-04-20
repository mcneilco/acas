(function() {
  var _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.GeneIDQueryInputController = (function(_super) {
    __extends(GeneIDQueryInputController, _super);

    function GeneIDQueryInputController() {
      this.handleAdvanceModeRequested = __bind(this.handleAdvanceModeRequested, this);
      this.handleSearchClicked = __bind(this.handleSearchClicked, this);
      this.handleKeyInInputField = __bind(this.handleKeyInInputField, this);
      this.handleInputFieldChanged = __bind(this.handleInputFieldChanged, this);
      this.render = __bind(this.render, this);
      _ref = GeneIDQueryInputController.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    GeneIDQueryInputController.prototype.template = _.template($("#GeneIDQueryInputView").html());

    GeneIDQueryInputController.prototype.events = {
      "click .bv_search": "handleSearchClicked",
      "click .bv_gidNavAdvancedSearchButton": "handleAdvanceModeRequested",
      "keyup .bv_gidListString": "handleInputFieldChanged",
      "keydown .bv_gidListString": "handleKeyInInputField"
    };

    GeneIDQueryInputController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      this.$('.bv_search').attr('disabled', 'disabled');
      this.$('.bv_gidACASBadgeTop').hide();
      this.$('.bv_searchNavbar').hide();
      return this;
    };

    GeneIDQueryInputController.prototype.handleInputFieldChanged = function() {
      if ($.trim(this.$('.bv_gidListString').val()).length > 1) {
        return this.$('.bv_search').removeAttr('disabled');
      } else {
        return this.$('.bv_search').attr('disabled', 'disabled');
      }
    };

    GeneIDQueryInputController.prototype.handleKeyInInputField = function(e) {
      if (e.keyCode === 13) {
        return this.handleSearchClicked();
      }
    };

    GeneIDQueryInputController.prototype.handleSearchClicked = function() {
      return this.trigger('search-requested', $.trim(this.$('.bv_gidListString').val()));
    };

    GeneIDQueryInputController.prototype.handleAdvanceModeRequested = function() {
      return this.trigger('requestAdvancedMode');
    };

    return GeneIDQueryInputController;

  })(Backbone.View);

  window.GeneIDQueryResultController = (function(_super) {
    __extends(GeneIDQueryResultController, _super);

    function GeneIDQueryResultController() {
      this.showCSVFileLink = __bind(this.showCSVFileLink, this);
      this.handleDownloadCSVClicked = __bind(this.handleDownloadCSVClicked, this);
      this.render = __bind(this.render, this);
      _ref1 = GeneIDQueryResultController.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    GeneIDQueryResultController.prototype.template = _.template($("#GeneIDQueryResultView").html());

    GeneIDQueryResultController.prototype.events = {
      "click .bv_downloadCSV": "handleDownloadCSVClicked"
    };

    GeneIDQueryResultController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      if (this.model.get('data').iTotalRecords > 0) {
        this.$('.bv_noResultsFound').hide();
        this.setupHeaders();
        this.$('.bv_resultTable').dataTable({
          aaData: this.model.get('data').aaData,
          aoColumns: this.model.get('data').aoColumns,
          bDeferRender: true,
          bProcessing: true
        });
      } else {
        this.$('.bv_resultTable').hide();
        this.$('.bv_noResultsFound').show();
      }
      return this;
    };

    GeneIDQueryResultController.prototype.setupHeaders = function() {
      var _this = this;
      _.each(this.model.get('data').groupHeaders, function(header) {
        return _this.$('.bv_experimentNamesHeader').append('<th colspan="' + header.numberOfColumns + '">' + header.titleText + '</th>');
      });
      return _.each(this.model.get('data').aoColumns, function(header) {
        return _this.$('.bv_columnNamesHeader').append('<th>placeholder</th>');
      });
    };

    GeneIDQueryResultController.prototype.handleDownloadCSVClicked = function() {
      this.$('.bv_searchStatusDropDown').modal({
        backdrop: "static"
      });
      this.$('.bv_searchStatusDropDown').modal("show");
      return this.trigger('downLoadCSVRequested');
    };

    GeneIDQueryResultController.prototype.showCSVFileLink = function(json) {
      this.$('.bv_searchStatusDropDown').modal("hide");
      this.$('.bv_resultFileLink').attr('href', json.fileURL);
      return this.$('.bv_csvFileLinkModal').modal({
        show: true
      });
    };

    return GeneIDQueryResultController;

  })(Backbone.View);

  window.GeneIDQuerySearchController = (function(_super) {
    __extends(GeneIDQuerySearchController, _super);

    function GeneIDQuerySearchController() {
      this.handleDownLoadCSVRequested = __bind(this.handleDownLoadCSVRequested, this);
      this.setShowResultsMode = __bind(this.setShowResultsMode, this);
      this.setQueryOnlyMode = __bind(this.setQueryOnlyMode, this);
      this.handleSearchReturn = __bind(this.handleSearchReturn, this);
      this.handleSearchRequested = __bind(this.handleSearchRequested, this);
      _ref2 = GeneIDQuerySearchController.__super__.constructor.apply(this, arguments);
      return _ref2;
    }

    GeneIDQuerySearchController.prototype.template = _.template($("#GeneIDQuerySearchView").html());

    GeneIDQuerySearchController.prototype.lastSearch = "";

    GeneIDQuerySearchController.prototype.initialize = function() {
      var _this = this;
      $(this.el).empty();
      $(this.el).html(this.template());
      this.queryInputController = new GeneIDQueryInputController({
        el: this.$('.bv_inputView')
      });
      this.queryInputController.on('search-requested', this.handleSearchRequested);
      this.queryInputController.on('requestAdvancedMode', function() {
        return _this.trigger('requestAdvancedMode');
      });
      this.queryInputController.render();
      return this.setQueryOnlyMode();
    };

    GeneIDQuerySearchController.prototype.handleSearchRequested = function(searchStr) {
      var _this = this;
      this.lastSearch = searchStr;
      this.$('.bv_searchStatusDropDown').modal;
      ({
        backdrop: "static"
      });
      this.$('.bv_searchStatusDropDown').modal("show");
      return $.ajax({
        type: 'POST',
        url: "api/geneDataQuery",
        data: {
          geneIDs: searchStr,
          maxRowsToReturn: 10000,
          user: window.AppLaunchParams.loginUserName
        },
        success: this.handleSearchReturn,
        error: function(err) {
          console.log('got ajax error');
          return _this.serviceReturn = null;
        },
        dataType: 'json'
      });
    };

    GeneIDQuerySearchController.prototype.handleSearchReturn = function(json) {
      this.$('.bv_searchStatusDropDown').modal("hide");
      this.resultController = new GeneIDQueryResultController({
        model: new Backbone.Model(json.results),
        el: $('.bv_resultsView')
      });
      this.resultController.render();
      this.resultController.on('downLoadCSVRequested', this.handleDownLoadCSVRequested);
      $('.bv_searchForm').appendTo('.bv_searchNavbar');
      this.$('.bv_gidSearchStart').hide();
      this.$('.bv_gidACASBadge').hide();
      this.$('.bv_gidACASBadgeTop').show();
      this.$('.bv_gidNavAdvancedSearchButton').removeClass('gidAdvancedNavSearchButtonStart');
      this.$('.bv_gidNavAdvancedSearchButton').addClass('gidAdvancedNavSearchButtonTop');
      this.$('.bv_searchNavbar').show();
      return this.setShowResultsMode();
    };

    GeneIDQuerySearchController.prototype.setQueryOnlyMode = function() {
      return this.$('.bv_resultsView').hide();
    };

    GeneIDQuerySearchController.prototype.setShowResultsMode = function() {
      return this.$('.bv_resultsView').show();
    };

    GeneIDQuerySearchController.prototype.handleDownLoadCSVRequested = function() {
      var _this = this;
      return $.ajax({
        type: 'POST',
        url: "api/geneDataQuery?format=csv",
        dataType: 'json',
        data: {
          geneIDs: this.lastSearch,
          maxRowsToReturn: 10000,
          user: window.AppLaunchParams.loginUserName
        },
        success: this.resultController.showCSVFileLink,
        error: function(err) {
          console.log('got ajax error');
          return _this.serviceReturn = null;
        }
      });
    };

    return GeneIDQuerySearchController;

  })(Backbone.View);

  window.ExperimentTreeController = (function(_super) {
    __extends(ExperimentTreeController, _super);

    function ExperimentTreeController() {
      this.handleSelectionChanged = __bind(this.handleSelectionChanged, this);
      this.handleSearchClear = __bind(this.handleSearchClear, this);
      this.render = __bind(this.render, this);
      _ref3 = ExperimentTreeController.__super__.constructor.apply(this, arguments);
      return _ref3;
    }

    ExperimentTreeController.prototype.template = _.template($("#ExperimentTreeView").html());

    ExperimentTreeController.prototype.events = {
      "click .bv_searchClear": "handleSearchClear",
      "click .bv_tree": "handleSelectionChanged"
    };

    ExperimentTreeController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      this.trigger('disableNext');
      this.setupTree();
      return this;
    };

    ExperimentTreeController.prototype.setupTree = function() {
      var to,
        _this = this;
      this.$('.bv_tree').jstree({
        core: {
          data: this.model.get('experimentData')
        },
        search: {
          fuzzy: false
        },
        plugins: ["checkbox", "search"]
      });
      to = false;
      return this.$(".bv_searchVal").keyup(function() {
        if (to) {
          clearTimeout(to);
        }
        to = setTimeout(function() {
          var v;
          v = this.$(".bv_searchVal").val();
          this.$(".bv_tree").jstree(true).search(v);
        }, 250);
      });
    };

    ExperimentTreeController.prototype.handleSearchClear = function() {
      return this.$('.bv_searchVal').val("");
    };

    ExperimentTreeController.prototype.getSelectedExperiments = function() {
      return this.$('.bv_tree').jstree('get_selected');
    };

    ExperimentTreeController.prototype.handleSelectionChanged = function() {
      var selected;
      selected = this.getSelectedExperiments();
      if (selected.length > 0) {
        return this.trigger('enableNext');
      } else {
        return this.trigger('disableNext');
      }
    };

    return ExperimentTreeController;

  })(Backbone.View);

  window.ExperimentResultFilterTermController = (function(_super) {
    __extends(ExperimentResultFilterTermController, _super);

    function ExperimentResultFilterTermController() {
      this.clear = __bind(this.clear, this);
      this.updateModel = __bind(this.updateModel, this);
      this.setOperatorOptions = __bind(this.setOperatorOptions, this);
      this.setKindOptions = __bind(this.setKindOptions, this);
      this.render = __bind(this.render, this);
      _ref4 = ExperimentResultFilterTermController.__super__.constructor.apply(this, arguments);
      return _ref4;
    }

    ExperimentResultFilterTermController.prototype.template = _.template($("#ExperimentResultFilterTermView").html());

    ExperimentResultFilterTermController.prototype.tagName = "div";

    ExperimentResultFilterTermController.prototype.className = "form-inline";

    ExperimentResultFilterTermController.prototype.events = {
      "change .bv_experiment": "setKindOptions",
      "change .bv_kind": "setOperatorOptions",
      "click .bv_delete": "clear"
    };

    ExperimentResultFilterTermController.prototype.initialize = function() {
      this.filterOptions = this.options.filterOptions;
      this.model.set({
        termName: this.options.termName
      });
      return this.model.on("destroy", this.remove, this);
    };

    ExperimentResultFilterTermController.prototype.render = function() {
      var _this = this;
      $(this.el).empty();
      $(this.el).html(this.template());
      this.$('.bv_termName').html(this.model.get('termName'));
      this.filterOptions.each(function(expt) {
        var code, ename;
        code = expt.get('experimentCode');
        ename = expt.get('experimentName');
        return _this.$('.bv_experiment').append('<option value="' + code + '">' + ename + '</option>');
      });
      this.setKindOptions();
      this.setOperatorOptions();
      return this;
    };

    ExperimentResultFilterTermController.prototype.setKindOptions = function() {
      var currentExpt, kind, kinds, _i, _len;
      currentExpt = this.getSelectedExperiment();
      kinds = _.pluck(currentExpt.get('valueKinds'), 'lsKind');
      this.$('.bv_kind').empty();
      for (_i = 0, _len = kinds.length; _i < _len; _i++) {
        kind = kinds[_i];
        this.$('.bv_kind').append('<option value="' + kind + '">' + kind + '</option>');
      }
      return this.setOperatorOptions();
    };

    ExperimentResultFilterTermController.prototype.setOperatorOptions = function() {
      switch (this.getSelectedValueType()) {
        case "numericValue":
          this.$('.bv_operator_number').addClass('bv_operator').show();
          this.$('.bv_operator_bool').removeClass('bv_operator').hide();
          this.$('.bv_operator_string').removeClass('bv_operator').hide();
          return this.$('.bv_filterValue').show();
        case "booleanValue":
          this.$('.bv_operator_number').removeClass('bv_operator').hide();
          this.$('.bv_operator_bool').addClass('bv_operator').show();
          this.$('.bv_operator_string').removeClass('bv_operator').hide();
          return this.$('.bv_filterValue').hide();
        case "stringValue":
          this.$('.bv_operator_number').removeClass('bv_operator').hide();
          this.$('.bv_operator_bool').removeClass('bv_operator').hide();
          this.$('.bv_operator_string').addClass('bv_operator').show();
          return this.$('.bv_filterValue').show();
      }
    };

    ExperimentResultFilterTermController.prototype.getSelectedExperiment = function() {
      var currentExpt, exptCode;
      exptCode = this.$('.bv_experiment').val();
      currentExpt = this.filterOptions.filter(function(expt) {
        return expt.get('experimentCode') === exptCode;
      });
      return currentExpt[0];
    };

    ExperimentResultFilterTermController.prototype.getSelectedValueType = function() {
      var currentAttr, currentExpt, kind;
      currentExpt = this.getSelectedExperiment();
      kind = this.$('.bv_kind').val();
      currentAttr = _.filter(currentExpt.get('valueKinds'), function(k) {
        return k.lsKind === kind;
      });
      return currentAttr[0].lsType;
    };

    ExperimentResultFilterTermController.prototype.updateModel = function() {
      return this.model.set({
        experimentCode: this.$('.bv_experiment').val(),
        lsKind: this.$('.bv_kind').val(),
        lsType: this.getSelectedValueType(),
        operator: this.$('.bv_operator').val(),
        filterValue: $.trim(this.$('.bv_filterValue').val())
      });
    };

    ExperimentResultFilterTermController.prototype.clear = function() {
      return this.model.destroy();
    };

    return ExperimentResultFilterTermController;

  })(Backbone.View);

  window.ExperimentResultFilterTermListController = (function(_super) {
    __extends(ExperimentResultFilterTermListController, _super);

    function ExperimentResultFilterTermListController() {
      this.addOne = __bind(this.addOne, this);
      this.render = __bind(this.render, this);
      _ref5 = ExperimentResultFilterTermListController.__super__.constructor.apply(this, arguments);
      return _ref5;
    }

    ExperimentResultFilterTermListController.prototype.template = _.template($("#ExperimentResultFilterTermListView").html());

    ExperimentResultFilterTermListController.prototype.events = {
      "click .bv_addTerm": "addOne"
    };

    ExperimentResultFilterTermListController.prototype.TERM_NUMBER_PREFIX = "Q";

    ExperimentResultFilterTermListController.prototype.initialize = function() {
      this.filterOptions = this.options.filterOptions;
      return this.nextTermNumber = 1;
    };

    ExperimentResultFilterTermListController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      return this;
    };

    ExperimentResultFilterTermListController.prototype.addOne = function() {
      var erftc, newModel;
      newModel = new Backbone.Model();
      this.collection.add(newModel);
      erftc = new ExperimentResultFilterTermController({
        model: newModel,
        filterOptions: this.filterOptions,
        termName: this.TERM_NUMBER_PREFIX + this.nextTermNumber++
      });
      this.$('.bv_filterTerms').append(erftc.render().el);
      return this.on("updateFilterModels", erftc.updateModel);
    };

    ExperimentResultFilterTermListController.prototype.updateCollection = function() {
      return this.trigger("updateFilterModels");
    };

    return ExperimentResultFilterTermListController;

  })(Backbone.View);

  window.ExperimentResultFilterController = (function(_super) {
    __extends(ExperimentResultFilterController, _super);

    function ExperimentResultFilterController() {
      this.handleBooleanFilterChanged = __bind(this.handleBooleanFilterChanged, this);
      this.render = __bind(this.render, this);
      _ref6 = ExperimentResultFilterController.__super__.constructor.apply(this, arguments);
      return _ref6;
    }

    ExperimentResultFilterController.prototype.template = _.template($("#ExperimentResultFilterView").html());

    ExperimentResultFilterController.prototype.events = {
      "click .bv_booleanFilter_and": "handleBooleanFilterChanged",
      "click .bv_booleanFilter_or": "handleBooleanFilterChanged",
      "click .bv_booleanFilter_advanced": "handleBooleanFilterChanged"
    };

    ExperimentResultFilterController.prototype.initialize = function() {
      return this.filterOptions = this.options.filterOptions;
    };

    ExperimentResultFilterController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      this.erftlc = new ExperimentResultFilterTermListController({
        el: this.$('.bv_filterTermList'),
        collection: new Backbone.Collection(),
        filterOptions: this.filterOptions
      });
      this.erftlc.render();
      this.handleBooleanFilterChanged();
      return this;
    };

    ExperimentResultFilterController.prototype.getSearchFilters = function() {
      var filtersAtters;
      this.erftlc.updateCollection();
      filtersAtters = {
        booleanFilter: this.$("input[name='bv_booleanFilter']:checked").val(),
        advancedFilter: $.trim(this.$('.bv_advancedBooleanFilter').val()),
        filters: this.erftlc.collection.toJSON()
      };
      return filtersAtters;
    };

    ExperimentResultFilterController.prototype.handleBooleanFilterChanged = function() {
      if (this.$("input[name='bv_booleanFilter']:checked").val() === 'advanced') {
        return this.$('.bv_advancedBoolContainer').show();
      } else {
        return this.$('.bv_advancedBoolContainer').hide();
      }
    };

    return ExperimentResultFilterController;

  })(Backbone.View);

  window.AdvancedExperimentResultsQueryController = (function(_super) {
    __extends(AdvancedExperimentResultsQueryController, _super);

    function AdvancedExperimentResultsQueryController() {
      this.handleDownLoadCSVRequested = __bind(this.handleDownLoadCSVRequested, this);
      this.handleSearchReturn = __bind(this.handleSearchReturn, this);
      this.handleGetExperimentSearchAttributesReturn = __bind(this.handleGetExperimentSearchAttributesReturn, this);
      this.handleGetGeneExperimentsReturn = __bind(this.handleGetGeneExperimentsReturn, this);
      this.handleNextClicked = __bind(this.handleNextClicked, this);
      _ref7 = AdvancedExperimentResultsQueryController.__super__.constructor.apply(this, arguments);
      return _ref7;
    }

    AdvancedExperimentResultsQueryController.prototype.template = _.template($("#AdvancedExperimentResultsQueryView").html());

    AdvancedExperimentResultsQueryController.prototype.initialize = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      return this.gotoStepGetCodes();
    };

    AdvancedExperimentResultsQueryController.prototype.handleNextClicked = function() {
      switch (this.nextStep) {
        case 'fromCodesToExptTree':
          return this.fromCodesToExptTree();
        case 'fromExptTreeToFilters':
          return this.fromExptTreeToFilters();
        case 'fromFiltersToResults':
          return this.fromFiltersToResults();
        case 'gotoRestart':
          return this.trigger('requestRestartAdvancedQuery');
      }
    };

    AdvancedExperimentResultsQueryController.prototype.gotoStepGetCodes = function() {
      this.nextStep = 'fromCodesToExptTree';
      this.$('.bv_getCodesView').show();
      this.$('.bv_getExperimentsView').hide();
      this.$('.bv_getFiltersView').hide();
      this.$('.bv_advResultsView').hide();
      this.$('.bv_cancel').html('Cancel');
      return this.$('.bv_noExperimentsFound').hide();
    };

    AdvancedExperimentResultsQueryController.prototype.fromCodesToExptTree = function() {
      var _this = this;
      this.searchCodes = $.trim(this.$('.bv_codesField').val());
      this.$('.bv_searchStatusDropDown').modal({
        backdrop: "static"
      });
      this.$('.bv_searchStatusDropDown').modal("show");
      return $.ajax({
        type: 'POST',
        url: "api/getGeneExperiments",
        dataType: 'json',
        data: {
          geneIDs: this.searchCodes
        },
        success: this.handleGetGeneExperimentsReturn,
        error: function(err) {
          console.log('got ajax error trying to get experiment tree');
          return _this.serviceReturn = null;
        }
      });
    };

    AdvancedExperimentResultsQueryController.prototype.handleGetGeneExperimentsReturn = function(json) {
      var _this = this;
      this.$('.bv_searchStatusDropDown').modal("hide");
      if (json.results.experimentData.length > 0) {
        this.etc = new ExperimentTreeController({
          el: this.$('.bv_getExperimentsView'),
          model: new Backbone.Model(json.results)
        });
        this.etc.on('enableNext', function() {
          return _this.trigger('enableNext');
        });
        this.etc.on('disableNext', function() {
          return _this.trigger('disableNext');
        });
        this.etc.render();
        this.$('.bv_getCodesView').hide();
        this.$('.bv_getExperimentsView').show();
        return this.nextStep = 'fromExptTreeToFilters';
      } else {
        this.$('.bv_noExperimentsFound').show();
        this.trigger('changeNextToNewQuery');
        return this.nextStep = 'gotoRestart';
      }
    };

    AdvancedExperimentResultsQueryController.prototype.fromExptTreeToFilters = function() {
      var _this = this;
      this.experimentList = this.etc.getSelectedExperiments();
      this.$('.bv_searchStatusDropDown').modal;
      ({
        backdrop: "static"
      });
      this.$('.bv_searchStatusDropDown').modal("show");
      return $.ajax({
        type: 'POST',
        url: "api/getExperimentSearchAttributes",
        dataType: 'json',
        data: {
          experimentCodes: this.experimentList
        },
        success: this.handleGetExperimentSearchAttributesReturn,
        error: function(err) {
          console.log('got ajax error');
          return _this.serviceReturn = null;
        }
      });
    };

    AdvancedExperimentResultsQueryController.prototype.handleGetExperimentSearchAttributesReturn = function(json) {
      this.$('.bv_searchStatusDropDown').modal("hide");
      this.erfc = new ExperimentResultFilterController({
        el: this.$('.bv_getFiltersView'),
        filterOptions: new Backbone.Collection(json.results.experiments)
      });
      this.erfc.render();
      this.$('.bv_getExperimentsView').hide();
      this.$('.bv_getFiltersView').show();
      return this.nextStep = 'fromFiltersToResults';
    };

    AdvancedExperimentResultsQueryController.prototype.getQueryParams = function() {
      var queryParams;
      return queryParams = {
        batchCodes: this.searchCodes,
        experimentCodeList: this.experimentList,
        searchFilters: this.erfc.getSearchFilters()
      };
    };

    AdvancedExperimentResultsQueryController.prototype.fromFiltersToResults = function() {
      var _this = this;
      this.$('.bv_searchStatusDropDown').modal;
      ({
        backdrop: "static"
      });
      this.$('.bv_searchStatusDropDown').modal("show");
      return $.ajax({
        type: 'POST',
        url: "api/geneDataQueryAdvanced",
        dataType: 'json',
        data: {
          queryParams: this.getQueryParams(),
          maxRowsToReturn: 10000,
          user: window.AppLaunchParams.loginUserName
        },
        success: this.handleSearchReturn,
        error: function(err) {
          console.log('got ajax error');
          return _this.serviceReturn = null;
        }
      });
    };

    AdvancedExperimentResultsQueryController.prototype.handleSearchReturn = function(json) {
      this.$('.bv_searchStatusDropDown').modal("hide");
      this.resultController = new GeneIDQueryResultController({
        model: new Backbone.Model(json.results),
        el: $('.bv_advResultsView')
      });
      this.resultController.on('downLoadCSVRequested', this.handleDownLoadCSVRequested);
      this.resultController.render();
      this.$('.bv_getFiltersView').hide();
      this.$('.bv_advResultsView').show();
      this.nextStep = 'gotoRestart';
      return this.trigger('requestShowResultsMode');
    };

    AdvancedExperimentResultsQueryController.prototype.handleDownLoadCSVRequested = function() {
      var _this = this;
      return $.ajax({
        type: 'POST',
        url: "api/geneDataQueryAdvanced?format=csv",
        dataType: 'json',
        data: {
          queryParams: this.getQueryParams(),
          maxRowsToReturn: 10000,
          user: window.AppLaunchParams.loginUserName
        },
        success: this.resultController.showCSVFileLink,
        error: function(err) {
          console.log('got ajax error');
          return _this.serviceReturn = null;
        }
      });
    };

    return AdvancedExperimentResultsQueryController;

  })(Backbone.View);

  window.GeneIDQueryAppController = (function(_super) {
    __extends(GeneIDQueryAppController, _super);

    function GeneIDQueryAppController() {
      this.handleHelpClicked = __bind(this.handleHelpClicked, this);
      this.handleCancelClicked = __bind(this.handleCancelClicked, this);
      this.handleNextClicked = __bind(this.handleNextClicked, this);
      this.startAdvanceedQueryWizard = __bind(this.startAdvanceedQueryWizard, this);
      this.startBasicQueryWizard = __bind(this.startBasicQueryWizard, this);
      _ref8 = GeneIDQueryAppController.__super__.constructor.apply(this, arguments);
      return _ref8;
    }

    GeneIDQueryAppController.prototype.template = _.template($("#GeneIDQueryAppView").html());

    GeneIDQueryAppController.prototype.events = {
      "click .bv_next": "handleNextClicked",
      "click .bv_cancel": "handleCancelClicked",
      "click .bv_gidNavHelpButton": "handleHelpClicked"
    };

    GeneIDQueryAppController.prototype.initialize = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      $(this.el).addClass('GeneIDQueryAppController');
      return this.startBasicQueryWizard();
    };

    GeneIDQueryAppController.prototype.startBasicQueryWizard = function() {
      var _this = this;
      this.aerqc = new GeneIDQuerySearchController({
        el: this.$('.bv_basicQueryView')
      });
      this.aerqc.render();
      this.$('.bv_advancedQueryContainer').hide();
      this.$('.bv_advancedQueryNavbar').hide();
      this.$('.bv_basicQueryView').show();
      return this.aerqc.on('requestAdvancedMode', function() {
        return _this.startAdvanceedQueryWizard();
      });
    };

    GeneIDQueryAppController.prototype.startAdvanceedQueryWizard = function() {
      var _this = this;
      this.$('.bv_next').html("Next");
      this.$('.bv_next').removeAttr('disabled');
      this.$('.bv_advancedQueryContainer').addClass('gidAdvancedQueryContainerPadding');
      this.$('.bv_controlButtonContainer').addClass('gidAdvancedSearchButtons');
      this.$('.bv_controlButtonContainer').removeClass('gidAdvancedSearchButtonsResultsView');
      this.$('.bv_controlButtonContainer').removeClass('gidAdvancedSearchButtonsNewQuery');
      this.aerqc = new AdvancedExperimentResultsQueryController({
        el: this.$('.bv_advancedQueryView')
      });
      this.aerqc.on('enableNext', function() {
        return _this.$('.bv_next').removeAttr('disabled');
      });
      this.aerqc.on('disableNext', function() {
        return _this.$('.bv_next').attr('disabled', 'disabled');
      });
      this.aerqc.on('requestShowResultsMode', function() {
        _this.$('.bv_next').html("New Query");
        _this.$('.bv_advancedQueryContainer').removeClass('gidAdvancedQueryContainerPadding');
        _this.$('.bv_controlButtonContainer').removeClass('gidAdvancedSearchButtons');
        return _this.$('.bv_controlButtonContainer').addClass('gidAdvancedSearchButtonsResultsView');
      });
      this.aerqc.on('requestRestartAdvancedQuery', function() {
        return _this.startAdvanceedQueryWizard();
      });
      this.aerqc.on('changeNextToNewQuery', function() {
        _this.$('.bv_next').html("New Query");
        _this.$('.bv_controlButtonContainer').removeClass('gidAdvancedSearchButtons');
        return _this.$('.bv_controlButtonContainer').addClass('gidAdvancedSearchButtonsNewQuery');
      });
      this.aerqc.render();
      this.$('.bv_basicQueryView').hide();
      this.$('.bv_advancedQueryContainer').show();
      return this.$('.bv_advancedQueryNavbar').show();
    };

    GeneIDQueryAppController.prototype.handleNextClicked = function() {
      if (this.aerqc != null) {
        return this.aerqc.handleNextClicked();
      }
    };

    GeneIDQueryAppController.prototype.handleCancelClicked = function() {
      return this.startBasicQueryWizard();
    };

    GeneIDQueryAppController.prototype.handleHelpClicked = function() {
      this.$('.bv_helpModal').modal({
        backdrop: "static"
      });
      return this.$('.bv_helpModal').modal("show");
    };

    return GeneIDQueryAppController;

  })(Backbone.View);

}).call(this);
