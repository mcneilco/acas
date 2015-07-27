(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.GeneIDQueryInputController = (function(superClass) {
    extend(GeneIDQueryInputController, superClass);

    function GeneIDQueryInputController() {
      this.handleAdvanceModeRequested = bind(this.handleAdvanceModeRequested, this);
      this.handleSearchClicked = bind(this.handleSearchClicked, this);
      this.handleKeyInInputField = bind(this.handleKeyInInputField, this);
      this.handleAggregationChanged = bind(this.handleAggregationChanged, this);
      this.handleInputFieldChanged = bind(this.handleInputFieldChanged, this);
      this.render = bind(this.render, this);
      return GeneIDQueryInputController.__super__.constructor.apply(this, arguments);
    }

    GeneIDQueryInputController.prototype.template = _.template($("#GeneIDQueryInputView").html());

    GeneIDQueryInputController.prototype.events = {
      "click .bv_search": "handleSearchClicked",
      "click .bv_gidNavAdvancedSearchButton": "handleAdvanceModeRequested",
      "keyup .bv_gidListString": "handleInputFieldChanged",
      "keydown .bv_gidListString": "handleKeyInInputField",
      "click .bv_aggregation_true": "handleAggregationChanged",
      "click .bv_aggregation_false": "handleAggregationChanged"
    };

    GeneIDQueryInputController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      this.$('.bv_search').attr('disabled', 'disabled');
      this.$('.bv_gidACASBadgeTop').hide();
      this.$('.bv_searchNavbar').hide();
      this.handleAggregationChanged();
      return this;
    };

    GeneIDQueryInputController.prototype.handleInputFieldChanged = function() {
      if ($.trim(this.$('.bv_gidListString').val()).length > 1) {
        return this.$('.bv_search').removeAttr('disabled');
      } else {
        return this.$('.bv_search').attr('disabled', 'disabled');
      }
    };

    GeneIDQueryInputController.prototype.handleAggregationChanged = function() {
      return this.aggregate = this.$("input[name='bv_aggregation']:checked").val();
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

  window.GeneIDQueryResultController = (function(superClass) {
    extend(GeneIDQueryResultController, superClass);

    function GeneIDQueryResultController() {
      this.showCSVFileLink = bind(this.showCSVFileLink, this);
      this.handleDownloadCSVClicked = bind(this.handleDownloadCSVClicked, this);
      this.render = bind(this.render, this);
      return GeneIDQueryResultController.__super__.constructor.apply(this, arguments);
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
          bProcessing: true,
          aoColumnDefs: [
            {
              bSortable: false,
              aTargets: [1]
            }, {
              sType: "lsThing",
              aTargets: ["_all"]
            }, {
              fnCreatedCell: (function(_this) {
                return function(nTd, sData, oData, iRow, iCol) {
                  var val;
                  val = _this.model.get('ids')[iRow][iCol];
                  return nTd.setAttribute('id', val);
                };
              })(this),
              aTargets: ["_all"]
            }
          ]
        });
      } else {
        this.$('.bv_resultTable').hide();
        this.$('.bv_noResultsFound').show();
        this.$('.bv_gidDownloadCSV').hide();
      }
      return this;
    };

    GeneIDQueryResultController.prototype.setupHeaders = function() {
      _.each(this.model.get('data').groupHeaders, (function(_this) {
        return function(header) {
          return _this.$('.bv_experimentNamesHeader').append('<th class="bv_headerCell" colspan="' + header.numberOfColumns + '">' + header.titleText + '</th>');
        };
      })(this));
      return _.each(this.model.get('data').aoColumns, (function(_this) {
        return function(header) {
          return _this.$('.bv_columnNamesHeader').append('<th>placeholder</th>');
        };
      })(this));
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

  window.GeneIDQuerySearchController = (function(superClass) {
    extend(GeneIDQuerySearchController, superClass);

    function GeneIDQuerySearchController() {
      this.handleDownLoadCSVRequested = bind(this.handleDownLoadCSVRequested, this);
      this.setShowResultsMode = bind(this.setShowResultsMode, this);
      this.setQueryOnlyMode = bind(this.setQueryOnlyMode, this);
      this.handleSearchReturn = bind(this.handleSearchReturn, this);
      this.handleSearchRequested = bind(this.handleSearchRequested, this);
      this.handleGetExperimentsReturn = bind(this.handleGetExperimentsReturn, this);
      return GeneIDQuerySearchController.__super__.constructor.apply(this, arguments);
    }

    GeneIDQuerySearchController.prototype.template = _.template($("#GeneIDQuerySearchView").html());

    GeneIDQuerySearchController.prototype.lastSearch = "";

    GeneIDQuerySearchController.prototype.initialize = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      this.queryInputController = new GeneIDQueryInputController({
        el: this.$('.bv_inputView')
      });
      this.queryInputController.on('search-requested', this.handleSearchRequested);
      this.queryInputController.on('requestAdvancedMode', (function(_this) {
        return function() {
          return _this.trigger('requestAdvancedMode');
        };
      })(this));
      this.queryInputController.render();
      return this.setQueryOnlyMode();
    };

    GeneIDQuerySearchController.prototype.getAllExperimentNames = function() {
      return $.ajax({
        type: 'POST',
        url: "api/getGeneExperiments",
        dataType: 'json',
        data: {
          geneIDs: this.lastSearch
        },
        success: this.handleGetExperimentsReturn,
        error: (function(_this) {
          return function(err) {
            return _this.serviceReturn = null;
          };
        })(this)
      });
    };

    GeneIDQuerySearchController.prototype.handleGetExperimentsReturn = function(json) {
      var data, experimentCodeList, expt, i, len;
      data = json.results.experimentData;
      experimentCodeList = [];
      for (i = 0, len = data.length; i < len; i++) {
        expt = data[i];
        experimentCodeList.push(expt.id);
      }
      this.codesList = experimentCodeList;
      return this.runRequestedSearch();
    };

    GeneIDQuerySearchController.prototype.getQueryParams = function() {
      var queryParams, searchFilter;
      searchFilter = {
        booleanFilter: "and",
        advancedFilter: ""
      };
      return queryParams = {
        batchCodes: this.lastSearch,
        experimentCodeList: this.codesList,
        searchFilters: searchFilter,
        aggregate: this.queryInputController.aggregate
      };
    };

    GeneIDQuerySearchController.prototype.runRequestedSearch = function() {
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
        error: (function(_this) {
          return function(err) {
            return _this.serviceReturn = null;
          };
        })(this)
      });
    };

    GeneIDQuerySearchController.prototype.handleSearchRequested = function(searchStr) {
      this.lastSearch = searchStr;
      this.$('.bv_searchStatusDropDown').modal({
        backdrop: "static"
      });
      this.$('.bv_searchStatusDropDown').modal("show");
      return this.getAllExperimentNames();
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
        error: (function(_this) {
          return function(err) {
            return _this.serviceReturn = null;
          };
        })(this)
      });
    };

    return GeneIDQuerySearchController;

  })(Backbone.View);

  window.ExperimentTreeController = (function(superClass) {
    extend(ExperimentTreeController, superClass);

    function ExperimentTreeController() {
      this.handleAggregationChanged = bind(this.handleAggregationChanged, this);
      this.handleSelectionChanged = bind(this.handleSelectionChanged, this);
      this.handleSearchClear = bind(this.handleSearchClear, this);
      this.render = bind(this.render, this);
      return ExperimentTreeController.__super__.constructor.apply(this, arguments);
    }

    ExperimentTreeController.prototype.template = _.template($("#ExperimentTreeView").html());

    ExperimentTreeController.prototype.events = {
      "click .bv_searchClear": "handleSearchClear",
      "click .bv_tree": "handleSelectionChanged",
      "click .bv_aggregation_true": "handleAggregationChanged",
      "click .bv_aggregation_false": "handleAggregationChanged"
    };

    ExperimentTreeController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      this.trigger('disableNext');
      this.setupTree();
      this.handleAggregationChanged();
      return this;
    };

    ExperimentTreeController.prototype.setupTree = function() {
      var to;
      this.$('.bv_tree').jstree({
        core: {
          data: this.model.get('experimentData')
        },
        search: {
          fuzzy: false
        },
        plugins: ["checkbox", "search"]
      });
      this.$('.bv_tree').bind("hover_node.jstree", function(e, data) {
        return $(e.target).attr("title", data.node.original.description);
      });
      to = false;
      return this.$(".bv_searchVal").keyup((function(_this) {
        return function() {
          if (to) {
            clearTimeout(to);
          }
          to = setTimeout(function() {
            var v;
            v = this.$(".bv_searchVal").val();
            this.$(".bv_tree").jstree(true).search(v);
          }, 250);
        };
      })(this));
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

    ExperimentTreeController.prototype.handleAggregationChanged = function() {
      return this.aggregate = this.$("input[name='bv_aggregation']:checked").val();
    };

    return ExperimentTreeController;

  })(Backbone.View);

  window.ExperimentResultFilterTerm = (function(superClass) {
    extend(ExperimentResultFilterTerm, superClass);

    function ExperimentResultFilterTerm() {
      return ExperimentResultFilterTerm.__super__.constructor.apply(this, arguments);
    }

    ExperimentResultFilterTerm.prototype.defaults = function() {
      return {
        filterValue: ""
      };
    };

    ExperimentResultFilterTerm.prototype.validate = function(attrs) {
      var errors;
      errors = [];
      if ((attrs.filterValue === "" && attrs.lsType !== 'booleanValue') || (attrs.filterValue === null && attrs.lsType !== 'booleanValue')) {
        errors.push({
          attribute: 'filterValue',
          message: "Filter value must be set"
        });
      }
      if (errors.length > 0) {
        return errors;
      } else {
        return null;
      }
    };

    return ExperimentResultFilterTerm;

  })(Backbone.Model);

  window.ExperimentResultFilterTermList = (function(superClass) {
    extend(ExperimentResultFilterTermList, superClass);

    function ExperimentResultFilterTermList() {
      return ExperimentResultFilterTermList.__super__.constructor.apply(this, arguments);
    }

    ExperimentResultFilterTermList.prototype.model = ExperimentResultFilterTerm;

    ExperimentResultFilterTermList.prototype.validateCollection = function() {
      var modelErrors;
      modelErrors = [];
      this.each((function(_this) {
        return function(model) {
          return modelErrors.push.apply(modelErrors, model.validationError);
        };
      })(this));
      return modelErrors;
    };

    return ExperimentResultFilterTermList;

  })(Backbone.Collection);

  window.ExperimentResultFilterTermController = (function(superClass) {
    extend(ExperimentResultFilterTermController, superClass);

    function ExperimentResultFilterTermController() {
      this.clearValidationErrorStyles = bind(this.clearValidationErrorStyles, this);
      this.validationError = bind(this.validationError, this);
      this.clear = bind(this.clear, this);
      this.updateModel = bind(this.updateModel, this);
      this.setOperatorOptions = bind(this.setOperatorOptions, this);
      this.setKindOptions = bind(this.setKindOptions, this);
      this.render = bind(this.render, this);
      return ExperimentResultFilterTermController.__super__.constructor.apply(this, arguments);
    }

    ExperimentResultFilterTermController.prototype.template = _.template($("#ExperimentResultFilterTermView").html());

    ExperimentResultFilterTermController.prototype.tagName = "div";

    ExperimentResultFilterTermController.prototype.className = "form-inline";

    ExperimentResultFilterTermController.prototype.events = {
      "change .bv_experiment": "setKindOptions",
      "change .bv_kind": "setOperatorOptions",
      "click .bv_delete": "clear",
      "change .bv_filterValue": "attributeChanged"
    };

    ExperimentResultFilterTermController.prototype.initialize = function() {
      this.errorOwnerName = 'ExperimentResultFilterTermController';
      this.setBindings();
      this.filterOptions = this.options.filterOptions;
      this.model.set({
        termName: this.options.termName
      });
      return this.model.on("destroy", this.remove, this);
    };

    ExperimentResultFilterTermController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      this.$('.bv_termName').html(this.model.get('termName'));
      this.filterOptions.each((function(_this) {
        return function(expt) {
          var code, ename;
          code = expt.get('experimentCode');
          ename = expt.get('experimentName');
          return _this.$('.bv_experiment').append('<option value="' + code + '">' + ename + '</option>');
        };
      })(this));
      this.setKindOptions();
      this.setOperatorOptions();
      return this;
    };

    ExperimentResultFilterTermController.prototype.setKindOptions = function() {
      var currentExpt, i, kind, kinds, len;
      currentExpt = this.getSelectedExperiment();
      kinds = _.pluck(currentExpt.get('valueKinds'), 'lsKind');
      this.$('.bv_kind').empty();
      for (i = 0, len = kinds.length; i < len; i++) {
        kind = kinds[i];
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
          this.$('.bv_filterValue').show();
          this.$('.bv_filterValue').val("");
          this.$('.bv_filterValue').change();
          return this.updateModel();
        case "booleanValue":
          this.$('.bv_operator_number').removeClass('bv_operator').hide();
          this.$('.bv_operator_bool').addClass('bv_operator').show();
          this.$('.bv_operator_string').removeClass('bv_operator').hide();
          this.$('.bv_filterValue').hide();
          this.$('.bv_filterValue').val("");
          this.$('.bv_filterValue').change();
          return this.updateModel();
        case "stringValue":
          this.$('.bv_operator_number').removeClass('bv_operator').hide();
          this.$('.bv_operator_bool').removeClass('bv_operator').hide();
          this.$('.bv_operator_string').addClass('bv_operator').show();
          this.$('.bv_filterValue').show();
          this.$('.bv_filterValue').val("");
          this.$('.bv_filterValue').change();
          return this.updateModel();
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
      this.model.destroy();
      return this.trigger('checkCollection');
    };

    ExperimentResultFilterTermController.prototype.validationError = function() {
      ExperimentResultFilterTermController.__super__.validationError.call(this);
      return this.trigger('disableNext');
    };

    ExperimentResultFilterTermController.prototype.clearValidationErrorStyles = function() {
      ExperimentResultFilterTermController.__super__.clearValidationErrorStyles.call(this);
      return this.trigger('enableNext');
    };

    return ExperimentResultFilterTermController;

  })(AbstractFormController);

  window.ExperimentResultFilterTermListController = (function(superClass) {
    extend(ExperimentResultFilterTermListController, superClass);

    function ExperimentResultFilterTermListController() {
      this.checkCollection = bind(this.checkCollection, this);
      this.addOne = bind(this.addOne, this);
      this.render = bind(this.render, this);
      return ExperimentResultFilterTermListController.__super__.constructor.apply(this, arguments);
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
      this.collection.on('change', this.checkCollection);
      return this;
    };

    ExperimentResultFilterTermListController.prototype.addOne = function() {
      var erftc, newModel;
      newModel = new ExperimentResultFilterTerm();
      this.collection.add(newModel);
      erftc = new ExperimentResultFilterTermController({
        model: newModel,
        filterOptions: this.filterOptions,
        termName: this.TERM_NUMBER_PREFIX + this.nextTermNumber++
      });
      this.$('.bv_filterTerms').append(erftc.render().el);
      this.on("updateFilterModels", erftc.updateModel);
      erftc.on('checkCollection', (function(_this) {
        return function() {
          return _this.checkCollection();
        };
      })(this));
      erftc.on('disableNext', (function(_this) {
        return function() {
          return _this.trigger('disableNext');
        };
      })(this));
      erftc.on('enableNext', (function(_this) {
        return function() {
          return _this.trigger('enableNext');
        };
      })(this));
      if (erftc.model.validationError.length > 0) {
        return this.trigger('disableNext');
      } else {
        return this.trigger('enableNext');
      }
    };

    ExperimentResultFilterTermListController.prototype.checkCollection = function() {
      if (this.collection.validateCollection().length > 0) {
        return this.trigger('disableNext');
      } else {
        return this.trigger('enableNext');
      }
    };

    ExperimentResultFilterTermListController.prototype.updateCollection = function() {
      return this.trigger("updateFilterModels");
    };

    return ExperimentResultFilterTermListController;

  })(Backbone.View);

  window.ExperimentResultFilterController = (function(superClass) {
    extend(ExperimentResultFilterController, superClass);

    function ExperimentResultFilterController() {
      this.handleBooleanFilterChanged = bind(this.handleBooleanFilterChanged, this);
      this.render = bind(this.render, this);
      return ExperimentResultFilterController.__super__.constructor.apply(this, arguments);
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
        collection: new ExperimentResultFilterTermList(),
        filterOptions: this.filterOptions
      });
      this.erftlc.render();
      this.erftlc.on('enableNext', (function(_this) {
        return function() {
          return _this.trigger('enableNext');
        };
      })(this));
      this.erftlc.on('disableNext', (function(_this) {
        return function() {
          return _this.trigger('disableNext');
        };
      })(this));
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

  window.AdvancedExperimentResultsQueryController = (function(superClass) {
    extend(AdvancedExperimentResultsQueryController, superClass);

    function AdvancedExperimentResultsQueryController() {
      this.handleDownLoadCSVRequested = bind(this.handleDownLoadCSVRequested, this);
      this.handleSearchReturn = bind(this.handleSearchReturn, this);
      this.handleGetExperimentSearchAttributesReturn = bind(this.handleGetExperimentSearchAttributesReturn, this);
      this.handleGetGeneExperimentsReturn = bind(this.handleGetGeneExperimentsReturn, this);
      this.handleNextClicked = bind(this.handleNextClicked, this);
      return AdvancedExperimentResultsQueryController.__super__.constructor.apply(this, arguments);
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
        error: (function(_this) {
          return function(err) {
            return _this.serviceReturn = null;
          };
        })(this)
      });
    };

    AdvancedExperimentResultsQueryController.prototype.handleGetGeneExperimentsReturn = function(json) {
      this.$('.bv_searchStatusDropDown').modal("hide");
      if (json.results.experimentData.length > 0) {
        this.etc = new ExperimentTreeController({
          el: this.$('.bv_getExperimentsView'),
          model: new Backbone.Model(json.results)
        });
        this.etc.on('enableNext', (function(_this) {
          return function() {
            return _this.trigger('enableNext');
          };
        })(this));
        this.etc.on('disableNext', (function(_this) {
          return function() {
            return _this.trigger('disableNext');
          };
        })(this));
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
        error: (function(_this) {
          return function(err) {
            return _this.serviceReturn = null;
          };
        })(this)
      });
    };

    AdvancedExperimentResultsQueryController.prototype.handleGetExperimentSearchAttributesReturn = function(json) {
      this.$('.bv_searchStatusDropDown').modal("hide");
      this.erfc = new ExperimentResultFilterController({
        el: this.$('.bv_getFiltersView'),
        filterOptions: new Backbone.Collection(json.results.experiments)
      });
      this.erfc.render();
      this.erfc.on('disableNext', (function(_this) {
        return function() {
          return _this.trigger('disableNext');
        };
      })(this));
      this.erfc.on('enableNext', (function(_this) {
        return function() {
          return _this.trigger('enableNext');
        };
      })(this));
      this.$('.bv_getExperimentsView').hide();
      this.$('.bv_getFiltersView').show();
      return this.nextStep = 'fromFiltersToResults';
    };

    AdvancedExperimentResultsQueryController.prototype.getQueryParams = function() {
      var queryParams;
      return queryParams = {
        batchCodes: this.searchCodes,
        experimentCodeList: this.experimentList,
        searchFilters: this.erfc.getSearchFilters(),
        aggregate: this.etc.aggregate
      };
    };

    AdvancedExperimentResultsQueryController.prototype.fromFiltersToResults = function() {
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
        error: (function(_this) {
          return function(err) {
            return _this.serviceReturn = null;
          };
        })(this)
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
        error: (function(_this) {
          return function(err) {
            return _this.serviceReturn = null;
          };
        })(this)
      });
    };

    return AdvancedExperimentResultsQueryController;

  })(Backbone.View);

  window.GeneIDQueryAppController = (function(superClass) {
    extend(GeneIDQueryAppController, superClass);

    function GeneIDQueryAppController() {
      this.handleHelpClicked = bind(this.handleHelpClicked, this);
      this.handleCancelClicked = bind(this.handleCancelClicked, this);
      this.handleNextClicked = bind(this.handleNextClicked, this);
      this.startAdvanceedQueryWizard = bind(this.startAdvanceedQueryWizard, this);
      this.startBasicQueryWizard = bind(this.startBasicQueryWizard, this);
      return GeneIDQueryAppController.__super__.constructor.apply(this, arguments);
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
      this.aerqc = new GeneIDQuerySearchController({
        el: this.$('.bv_basicQueryView')
      });
      this.aerqc.render();
      this.$('.bv_advancedQueryContainer').hide();
      this.$('.bv_advancedQueryNavbar').hide();
      this.$('.bv_basicQueryView').show();
      return this.aerqc.on('requestAdvancedMode', (function(_this) {
        return function() {
          return _this.startAdvanceedQueryWizard();
        };
      })(this));
    };

    GeneIDQueryAppController.prototype.startAdvanceedQueryWizard = function() {
      this.$('.bv_next').html("Next");
      this.$('.bv_next').removeAttr('disabled');
      this.$('.bv_advancedQueryContainer').addClass('gidAdvancedQueryContainerPadding');
      this.$('.bv_controlButtonContainer').addClass('gidAdvancedSearchButtons');
      this.$('.bv_controlButtonContainer').removeClass('gidAdvancedSearchButtonsResultsView');
      this.$('.bv_controlButtonContainer').removeClass('gidAdvancedSearchButtonsNewQuery');
      this.aerqc = new AdvancedExperimentResultsQueryController({
        el: this.$('.bv_advancedQueryView')
      });
      this.aerqc.on('enableNext', (function(_this) {
        return function() {
          return _this.$('.bv_next').removeAttr('disabled');
        };
      })(this));
      this.aerqc.on('disableNext', (function(_this) {
        return function() {
          return _this.$('.bv_next').attr('disabled', 'disabled');
        };
      })(this));
      this.aerqc.on('requestShowResultsMode', (function(_this) {
        return function() {
          _this.$('.bv_next').html("New Query");
          _this.$('.bv_advancedQueryContainer').removeClass('gidAdvancedQueryContainerPadding');
          _this.$('.bv_controlButtonContainer').removeClass('gidAdvancedSearchButtons');
          return _this.$('.bv_controlButtonContainer').addClass('gidAdvancedSearchButtonsResultsView');
        };
      })(this));
      this.aerqc.on('requestRestartAdvancedQuery', (function(_this) {
        return function() {
          return _this.startAdvanceedQueryWizard();
        };
      })(this));
      this.aerqc.on('changeNextToNewQuery', (function(_this) {
        return function() {
          _this.$('.bv_next').html("New Query");
          _this.$('.bv_controlButtonContainer').removeClass('gidAdvancedSearchButtons');
          return _this.$('.bv_controlButtonContainer').addClass('gidAdvancedSearchButtonsNewQuery');
        };
      })(this));
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
