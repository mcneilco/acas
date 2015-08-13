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
      return this.trigger('requestAdvancedMode', $.trim(this.$('.bv_gidListString').val()), this.aggregate);
    };

    return GeneIDQueryInputController;

  })(Backbone.View);

  window.GeneIDQueryResultController = (function(superClass) {
    extend(GeneIDQueryResultController, superClass);

    function GeneIDQueryResultController() {
      this.handleAddDataClicked = bind(this.handleAddDataClicked, this);
      this.showCSVFileLink = bind(this.showCSVFileLink, this);
      this.handleDownloadCSVClicked = bind(this.handleDownloadCSVClicked, this);
      this.modifyTableEntities = bind(this.modifyTableEntities, this);
      this.render = bind(this.render, this);
      return GeneIDQueryResultController.__super__.constructor.apply(this, arguments);
    }

    GeneIDQueryResultController.prototype.template = _.template($("#GeneIDQueryResultView").html());

    GeneIDQueryResultController.prototype.events = {
      "click .bv_downloadCSV": "handleDownloadCSVClicked",
      "click .bv_addData": "handleAddDataClicked"
    };

    GeneIDQueryResultController.prototype.render = function() {
      var sortingType;
      $(this.el).empty();
      $(this.el).html(this.template());
      if (this.model.get('data').iTotalRecords > 0) {
        this.$('.bv_noResultsFound').hide();
        this.setupHeaders();
        sortingType = String(window.conf.sar.sorting);
        console.log(sortingType);
        this.$('.bv_resultTable').dataTable({
          aaData: this.model.get('data').aaData,
          aoColumns: this.model.get('data').aoColumns,
          bDeferRender: true,
          bProcessing: true,
          aoColumnDefs: [
            {
              sType: sortingType,
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
        this.displayName = this.model.get('data').displayName;
        console.log("displayName is " + this.displayName);
        if (this.displayName != null) {
          $.get("/api/sarRender/title/" + this.displayName, (function(_this) {
            return function(json) {
              return _this.$('th.referenceCode').html(json.title);
            };
          })(this));
        }
        this.modifyTableEntities();
        this.$('.bv_resultTable').on("draw", this.modifyTableEntities);
      } else {
        this.$('.bv_resultTable').hide();
        this.$('.bv_noResultsFound').show();
        this.$('.bv_gidDownloadCSV').hide();
        this.$('.bv_addData').hide();
      }
      return this;
    };

    GeneIDQueryResultController.prototype.modifyTableEntities = function() {
      return this.$('td.referenceCode').each(function() {
        return $.ajax({
          type: 'POST',
          url: "api/sarRender/render",
          dataType: 'json',
          data: {
            displayName: this.displayName,
            referenceCode: $(this).html()
          },
          success: (function(_this) {
            return function(json) {
              $(_this).html(json.html);
              return $(_this).removeClass("referenceCode");
            };
          })(this)
        });
      });
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

    GeneIDQueryResultController.prototype.handleAddDataClicked = function() {
      return this.trigger('addDataRequested');
    };

    return GeneIDQueryResultController;

  })(Backbone.View);

  window.GeneIDQuerySearchController = (function(superClass) {
    extend(GeneIDQuerySearchController, superClass);

    function GeneIDQuerySearchController() {
      this.handleShowHideExperiments = bind(this.handleShowHideExperiments, this);
      this.handleDownLoadCSVRequested = bind(this.handleDownLoadCSVRequested, this);
      this.setShowResultsMode = bind(this.setShowResultsMode, this);
      this.setQueryOnlyMode = bind(this.setQueryOnlyMode, this);
      this.handleSearchReturn = bind(this.handleSearchReturn, this);
      this.handleGetExperimentsReturn = bind(this.handleGetExperimentsReturn, this);
      this.refCodesToSearchStr = bind(this.refCodesToSearchStr, this);
      this.handleEntitySearchReturn = bind(this.handleEntitySearchReturn, this);
      this.handleSearchRequested = bind(this.handleSearchRequested, this);
      this.requestFilterExperiments = bind(this.requestFilterExperiments, this);
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
      this.queryInputController.on('requestAdvancedMode', this.requestFilterExperiments);
      this.queryInputController.render();
      this.setQueryOnlyMode();
      return this.dataAdded = false;
    };

    GeneIDQuerySearchController.prototype.requestFilterExperiments = function(searchStr, aggregate) {
      return this.trigger('requestAdvancedMode', searchStr, aggregate);
    };

    GeneIDQuerySearchController.prototype.handleSearchRequested = function(searchStr) {
      this.lastSearch = searchStr;
      this.$('.bv_searchStatusDropDown').modal({
        backdrop: "static"
      });
      this.$('.bv_searchStatusDropDown').modal("show");
      return this.fromSearchtoCodes();
    };

    GeneIDQuerySearchController.prototype.fromSearchtoCodes = function() {
      var j, len, results1, searchString, searchTerms, term;
      this.counter = 0;
      searchString = this.lastSearch;
      searchTerms = searchString.split(/[^A-Za-z0-9_-]/);
      this.numTerms = searchTerms.length;
      this.searchResults = [];
      results1 = [];
      for (j = 0, len = searchTerms.length; j < len; j++) {
        term = searchTerms[j];
        results1.push($.ajax({
          type: 'POST',
          url: "api/entitymeta/searchForEntities",
          dataType: 'json',
          data: {
            requestText: term
          },
          success: this.handleEntitySearchReturn,
          error: (function(_this) {
            return function(err) {
              return _this.serviceReturn = null;
            };
          })(this)
        }));
      }
      return results1;
    };

    GeneIDQuerySearchController.prototype.handleEntitySearchReturn = function(json) {
      var j, len, ref, result;
      this.counter = this.counter + 1;
      if (json.results.length > 0) {
        console.log("found a match for term " + json.results[0].requestText);
        ref = json.results;
        for (j = 0, len = ref.length; j < len; j++) {
          result = ref[j];
          this.searchResults.push({
            displayName: result.displayName,
            referenceCode: result.referenceCode
          });
        }
      }
      if (this.counter >= this.numTerms) {
        console.log("All searches returned, going to filter");
        return this.filterOnDisplayName();
      }
    };

    GeneIDQuerySearchController.prototype.filterOnDisplayName = function() {
      var displayNames, jsonSearch;
      displayNames = _.uniq(_.pluck(this.searchResults, "displayName"));
      if (displayNames.length <= 1) {
        this.displayName = displayNames[0];
        this.lastSearch = _.pluck(this.searchResults, "referenceCode").join(" ");
        console.log("all search terms from same type/kind, going to get experiments");
        return this.getAllExperimentNames();
      } else {
        this.$('.bv_searchStatusDropDown').modal("hide");
        jsonSearch = {
          results: this.searchResults
        };
        this.entityController = new ChooseEntityTypeController({
          el: this.$('.bv_chooseEntityView'),
          model: new Backbone.Model(jsonSearch)
        });
        this.entityController.on('entitySelected', this.refCodesToSearchStr);
        return console.log("multiple entity types found");
      }
    };

    GeneIDQuerySearchController.prototype.refCodesToSearchStr = function(displayName) {
      this.displayName = displayName;
      console.log("chosen entityType is " + displayName);
      this.lastSearch = _.pluck(_.where(this.searchResults, {
        displayName: displayName
      }), "referenceCode").join(" ");
      return this.getAllExperimentNames();
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
      var data, experimentCodeList, expt, j, len;
      data = json.results.experimentData;
      experimentCodeList = [];
      for (j = 0, len = data.length; j < len; j++) {
        expt = data[j];
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

    GeneIDQuerySearchController.prototype.handleSearchReturn = function(json) {
      this.$('.bv_searchStatusDropDown').modal("hide");
      this.resultsJson = json.results;
      this.resultsJson.data.displayName = this.displayName;
      if (!this.dataAdded) {
        this.resultController = new GeneIDQueryResultController({
          model: new Backbone.Model(json.results),
          el: $('.bv_resultsView')
        });
        this.resultController.on('downLoadCSVRequested', this.handleDownLoadCSVRequested);
        this.resultController.on('addDataRequested', this.handleShowHideExperiments);
      } else {
        this.searchCodes = json.results.batchCodes.join();
        this.experimentList = json.results.experimentCodeList;
        this.resultController.model.clear().set(json.results);
      }
      this.resultController.render();
      $('.bv_searchForm').appendTo('.bv_searchNavbar');
      this.$('.bv_addData').html("Show/Hide Data");
      this.$('.bv_gidDownloadCSV').addClass('bv_gidDownloadCSVSimple');
      this.$('.bv_addDataRequest').addClass('bv_addDataRequestSimple');
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

    GeneIDQuerySearchController.prototype.handleShowHideExperiments = function() {
      if (!this.dataAdded) {
        this.dataAdded = true;
        this.addData = new ShowHideExpts({
          model: new Backbone.Model(this.resultsJson),
          el: this.$('.bv_resultsView')
        });
        return this.addData.on('requestResults', this.handleSearchReturn);
      } else {
        this.addData.model.clear().set(this.resultsJson);
        return this.addData.render();
      }
    };

    return GeneIDQuerySearchController;

  })(Backbone.View);

  window.ShowHideExpts = (function(superClass) {
    extend(ShowHideExpts, superClass);

    function ShowHideExpts() {
      this.handleAddDataReturn = bind(this.handleAddDataReturn, this);
      this.handleSelectionChanged = bind(this.handleSelectionChanged, this);
      this.handleSearchClear = bind(this.handleSearchClear, this);
      this.handleAggregationChanged = bind(this.handleAggregationChanged, this);
      this.handleGetAddDataTreeReturn = bind(this.handleGetAddDataTreeReturn, this);
      return ShowHideExpts.__super__.constructor.apply(this, arguments);
    }

    ShowHideExpts.prototype.template = _.template($("#AddDataView").html());

    ShowHideExpts.prototype.events = {
      "click .bv_searchClear": "handleSearchClear",
      "click .bv_addDataTree": "handleSelectionChanged",
      "click .bv_displayResults": "handleDisplayResuts",
      "click .bv_aggregation_true": "handleAggregationChanged",
      "click .bv_aggregation_false": "handleAggregationChanged"
    };

    ShowHideExpts.prototype.initialize = function() {
      $(this.el).append(this.template());
      return this.render();
    };

    ShowHideExpts.prototype.render = function() {
      this.$('.bv_searchStatusDropDown').modal({
        backdrop: "static"
      });
      this.$('.bv_searchStatusDropDown').modal("show");
      return this.getBatchCodes();
    };

    ShowHideExpts.prototype.getBatchCodes = function() {
      var allBatchCodes, data;
      data = this.model.get('data');
      allBatchCodes = [];
      $(data.aaData).each(function(key, value) {
        return allBatchCodes.push(value.geneId);
      });
      this.allBatchCodes = allBatchCodes;
      return this.gotoShowTree();
    };

    ShowHideExpts.prototype.gotoShowTree = function() {
      return $.ajax({
        type: 'POST',
        url: "api/getGeneExperiments",
        dataType: 'json',
        data: {
          geneIDs: this.allBatchCodes
        },
        success: this.handleGetAddDataTreeReturn,
        error: (function(_this) {
          return function(err) {
            return _this.serviceReturn = null;
          };
        })(this)
      });
    };

    ShowHideExpts.prototype.handleGetAddDataTreeReturn = function(json) {
      var results;
      this.$('.bv_searchStatusDropDown').modal("hide");
      if (!this.$('.bv_addDataModal').length) {
        $(this.el).append(this.template());
      }
      this.$('.bv_addDataModal').modal({
        backdrop: "static"
      });
      this.$('.bv_addDataModal').modal("show");
      this.$('.bv_aggregation_true').prop("disabled", false);
      this.$('.bv_aggregation_false').prop("disabled", false);
      if (json.results.experimentData.length > 0) {
        results = json.results.experimentData;
        return this.setupTree(results);
      }
    };

    ShowHideExpts.prototype.setupTree = function(results) {
      var expts, to;
      this.$('.bv_addDataTree').jstree({
        core: {
          data: results
        },
        search: {
          fuzzy: false
        },
        plugins: ["checkbox", "search"]
      });
      this.$('.bv_addDataTree').bind("hover_node.jstree", function(e, data) {
        return $(e.target).attr("title", data.node.original.description);
      });
      to = false;
      this.$(".bv_searchVal").keyup((function(_this) {
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
      this.aggregate = this.model.get("aggregate");
      if (this.aggregate) {
        $(".bv_aggregation_true").prop("checked", true);
      }
      expts = this.model.get("experimentCodeList");
      this.exptLength = expts.length;
      return this.$(".bv_addDataTree").jstree('select_node', expts);
    };

    ShowHideExpts.prototype.handleAggregationChanged = function() {
      this.aggregate = this.$("input[name='bv_aggregation']:checked").val();
      if (this.$('.bv_addDataTree').jstree('get_selected').length > 0) {
        return this.$('.bv_displayResults').prop("disabled", false);
      }
    };

    ShowHideExpts.prototype.handleSearchClear = function() {
      return this.$('.bv_searchVal').val("");
    };

    ShowHideExpts.prototype.getSelectedExperiments = function() {
      return this.$('.bv_addDataTree').jstree('get_selected');
    };

    ShowHideExpts.prototype.handleSelectionChanged = function() {
      this.selected = this.getSelectedExperiments();
      if (this.$('.bv_addDataTree').jstree('get_selected').length > 0) {
        return this.$('.bv_displayResults').prop("disabled", false);
      } else {
        return this.$('.bv_displayResults').prop("disabled", true);
      }
    };

    ShowHideExpts.prototype.getQueryParams = function() {
      var queryParams;
      return queryParams = {
        batchCodes: this.allBatchCodes.join(),
        experimentCodeList: this.selected,
        searchFilters: this.model.get("searchFilters"),
        aggregate: this.aggregate
      };
    };

    ShowHideExpts.prototype.handleDisplayResuts = function() {
      this.$('.bv_searchStatusDropDown').modal({
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
        success: this.handleAddDataReturn,
        error: (function(_this) {
          return function(err) {
            return _this.serviceReturn = null;
          };
        })(this)
      });
    };

    ShowHideExpts.prototype.handleAddDataReturn = function(json) {
      return this.trigger('requestResults', json);
    };

    return ShowHideExpts;

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
      var currentExpt, j, kind, kinds, len;
      currentExpt = this.getSelectedExperiment();
      kinds = _.pluck(currentExpt.get('valueKinds'), 'lsKind');
      this.$('.bv_kind').empty();
      for (j = 0, len = kinds.length; j < len; j++) {
        kind = kinds[j];
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
      this.handleAddDataRequested = bind(this.handleAddDataRequested, this);
      this.handleDownLoadCSVRequested = bind(this.handleDownLoadCSVRequested, this);
      this.handleSearchReturn = bind(this.handleSearchReturn, this);
      this.handleGetExperimentSearchAttributesReturn = bind(this.handleGetExperimentSearchAttributesReturn, this);
      this.handleGetGeneExperimentsReturn = bind(this.handleGetGeneExperimentsReturn, this);
      this.refCodesToSearchStr = bind(this.refCodesToSearchStr, this);
      this.handleEntitySearchReturn = bind(this.handleEntitySearchReturn, this);
      this.handleNextClicked = bind(this.handleNextClicked, this);
      return AdvancedExperimentResultsQueryController.__super__.constructor.apply(this, arguments);
    }

    AdvancedExperimentResultsQueryController.prototype.template = _.template($("#AdvancedExperimentResultsQueryView").html());

    AdvancedExperimentResultsQueryController.prototype.initialize = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      this.dataAdded = false;
      this.$('.bv_getExperimentsView').hide();
      this.$('.bv_getFiltersView').hide();
      this.$('.bv_advResultsView').hide();
      this.$('.bv_noExperimentsFound').hide();
      return this.fromSearchtoCodes();
    };

    AdvancedExperimentResultsQueryController.prototype.handleNextClicked = function() {
      switch (this.nextStep) {
        case 'fromExptTreeToFilters':
          return this.fromExptTreeToFilters();
        case 'fromFiltersToResults':
          return this.fromFiltersToResults();
        case 'gotoRestart':
          return this.trigger('requestRestartAdvancedQuery');
      }
    };

    AdvancedExperimentResultsQueryController.prototype.fromSearchtoCodes = function() {
      var j, len, results1, searchString, searchTerms, term;
      this.counter = 0;
      searchString = this.model.get('searchStr');
      searchTerms = searchString.split(/[^A-Za-z0-9_-]/);
      this.numTerms = searchTerms.length;
      this.searchResults = [];
      this.$('.bv_searchStatusDropDown').modal({
        backdrop: "static"
      });
      this.$('.bv_searchStatusDropDown').modal("show");
      results1 = [];
      for (j = 0, len = searchTerms.length; j < len; j++) {
        term = searchTerms[j];
        results1.push($.ajax({
          type: 'POST',
          url: "api/entitymeta/searchForEntities",
          dataType: 'json',
          data: {
            requestText: term
          },
          success: this.handleEntitySearchReturn,
          error: (function(_this) {
            return function(err) {
              return _this.serviceReturn = null;
            };
          })(this)
        }));
      }
      return results1;
    };

    AdvancedExperimentResultsQueryController.prototype.handleEntitySearchReturn = function(json) {
      var j, len, ref, result;
      this.counter = this.counter + 1;
      if (json.results.length > 0) {
        console.log("found a match for term " + json.results[0].requestText);
        ref = json.results;
        for (j = 0, len = ref.length; j < len; j++) {
          result = ref[j];
          this.searchResults.push({
            displayName: result.displayName,
            referenceCode: result.referenceCode
          });
        }
      }
      if (this.counter >= this.numTerms) {
        console.log("All searches returned, going to filter");
        return this.filterOnDisplayName();
      }
    };

    AdvancedExperimentResultsQueryController.prototype.filterOnDisplayName = function() {
      var displayNames, jsonSearch;
      displayNames = _.uniq(_.pluck(this.searchResults, "displayName"));
      if (displayNames.length <= 1) {
        this.displayName = displayNames[0];
        this.searchCodes = _.pluck(this.searchResults, "referenceCode").join(" ");
        console.log("all search terms from same type/kind, going to get experiments");
        return this.fromCodesToExptTree();
      } else {
        this.$('.bv_searchStatusDropDown').modal("hide");
        jsonSearch = {
          results: this.searchResults
        };
        this.entityController = new ChooseEntityTypeController({
          el: this.$('.bv_chooseEntityView'),
          model: new Backbone.Model(jsonSearch)
        });
        return this.entityController.on('entitySelected', this.refCodesToSearchStr);
      }
    };

    AdvancedExperimentResultsQueryController.prototype.refCodesToSearchStr = function(displayName) {
      this.displayName = displayName;
      console.log("chosen entityType is " + displayName);
      this.searchCodes = _.pluck(_.where(this.searchResults, {
        displayName: displayName
      }), "referenceCode").join(" ");
      return this.fromCodesToExptTree();
    };

    AdvancedExperimentResultsQueryController.prototype.fromCodesToExptTree = function() {
      console.log("search Codes is:" + this.searchCodes);
      if (this.searchCodes == null) {
        this.searchCodes = this.model.get('searchStr');
      }
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
      this.trigger('nextToFilterOnVals');
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

    AdvancedExperimentResultsQueryController.prototype.handleResultsClicked = function() {
      this.$('.bv_getExperimentsView').hide();
      this.trigger('nextToGotoResults');
      this.experimentList = this.etc.getSelectedExperiments();
      return this.fromFiltersToResults();
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
      this.trigger('nextToGotoResults');
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
      var noFilters, queryParams, searchFilters;
      noFilters = {
        booleanFilter: "and",
        advancedFilter: ""
      };
      searchFilters = this.erfc != null ? this.erfc.getSearchFilters() : noFilters;
      return queryParams = {
        batchCodes: this.searchCodes,
        experimentCodeList: this.experimentList,
        searchFilters: searchFilters,
        aggregate: this.model.get('aggregate')
      };
    };

    AdvancedExperimentResultsQueryController.prototype.fromFiltersToResults = function() {
      this.$('.bv_searchStatusDropDown').modal({
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
      this.resultsJson = json.results;
      this.resultsJson.data.displayName = this.displayName;
      if (!this.dataAdded) {
        this.resultController = new GeneIDQueryResultController({
          model: new Backbone.Model(json.results),
          el: $('.bv_advResultsView')
        });
        this.resultController.on('downLoadCSVRequested', this.handleDownLoadCSVRequested);
        this.resultController.on('addDataRequested', this.handleAddDataRequested);
      } else {
        this.searchCodes = json.results.batchCodes.join();
        this.experimentList = json.results.experimentCodeList;
        this.resultController.model.clear().set(json.results);
      }
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

    AdvancedExperimentResultsQueryController.prototype.handleAddDataRequested = function() {
      if (!this.dataAdded) {
        this.dataAdded = true;
        this.addData = new AddDataToReport({
          model: new Backbone.Model(this.resultsJson),
          el: this.$('.bv_addDataView')
        });
        return this.addData.on('requestResults', this.handleSearchReturn);
      } else {
        this.addData.model.clear().set(this.resultsJson);
        return this.addData.render();
      }
    };

    return AdvancedExperimentResultsQueryController;

  })(Backbone.View);

  window.ChooseEntityTypeController = (function(superClass) {
    extend(ChooseEntityTypeController, superClass);

    function ChooseEntityTypeController() {
      return ChooseEntityTypeController.__super__.constructor.apply(this, arguments);
    }

    ChooseEntityTypeController.prototype.template = _.template($("#ChooseEntityTypeView").html());

    ChooseEntityTypeController.prototype.events = {
      "click .bv_continue": "handleContinue",
      "click .bv_entityTypeRadio": "handleSelectionChanged"
    };

    ChooseEntityTypeController.prototype.initialize = function() {
      var button, entityTypes, j, len, type;
      $(this.el).empty();
      $(this.el).append(this.template());
      entityTypes = _.uniq(_.pluck(this.model.get('results'), 'displayName'));
      console.log("entities are " + entityTypes);
      for (j = 0, len = entityTypes.length; j < len; j++) {
        type = entityTypes[j];
        button = this.$('.entityTypeRadio').clone().removeClass('entityTypeRadio');
        button.contents().attr("value", type).html(type);
        button.appendTo('.entityTypes');
      }
      this.$('.entityTypeRadio').remove();
      return this.render();
    };

    ChooseEntityTypeController.prototype.render = function() {
      this.$('.bv_chooseEntityTypeModal').modal({
        backdrop: "static"
      });
      return this.$('.bv_chooseEntityTypeModal').modal("show");
    };

    ChooseEntityTypeController.prototype.handleSelectionChanged = function() {
      this.$('.bv_continue').prop("disabled", false);
      return this.displayName = this.$("input[name='bv_entityType']:checked").val();
    };

    ChooseEntityTypeController.prototype.handleContinue = function() {
      return this.trigger('entitySelected', this.displayName);
    };

    return ChooseEntityTypeController;

  })(Backbone.View);

  window.AddDataToReport = (function(superClass) {
    extend(AddDataToReport, superClass);

    function AddDataToReport() {
      this.handleAddDataReturn = bind(this.handleAddDataReturn, this);
      this.handleSelectionChanged = bind(this.handleSelectionChanged, this);
      this.handleSearchClear = bind(this.handleSearchClear, this);
      this.handleGetAddDataTreeReturn = bind(this.handleGetAddDataTreeReturn, this);
      return AddDataToReport.__super__.constructor.apply(this, arguments);
    }

    AddDataToReport.prototype.template = _.template($("#AddDataView").html());

    AddDataToReport.prototype.events = {
      "click .bv_searchClear": "handleSearchClear",
      "click .bv_addDataTree": "handleSelectionChanged",
      "click .bv_displayResults": "handleDisplayResuts"
    };

    AddDataToReport.prototype.initialize = function() {
      $(this.el).empty();
      $(this.el).append(this.template());
      return this.render();
    };

    AddDataToReport.prototype.render = function() {
      this.$('.bv_searchStatusDropDown').modal({
        backdrop: "static"
      });
      this.$('.bv_searchStatusDropDown').modal("show");
      return this.getBatchCodes();
    };

    AddDataToReport.prototype.getBatchCodes = function() {
      var allBatchCodes, data;
      data = this.model.get('data');
      allBatchCodes = [];
      $(data.aaData).each(function(key, value) {
        return allBatchCodes.push(value.geneId);
      });
      this.allBatchCodes = allBatchCodes;
      return this.gotoShowTree();
    };

    AddDataToReport.prototype.gotoShowTree = function() {
      return $.ajax({
        type: 'POST',
        url: "api/getGeneExperiments",
        dataType: 'json',
        data: {
          geneIDs: this.allBatchCodes
        },
        success: this.handleGetAddDataTreeReturn,
        error: (function(_this) {
          return function(err) {
            return _this.serviceReturn = null;
          };
        })(this)
      });
    };

    AddDataToReport.prototype.handleGetAddDataTreeReturn = function(json) {
      var results;
      this.$('.bv_searchStatusDropDown').modal("hide");
      if (!this.$('.bv_addDataModal').length) {
        $(this.el).append(this.template());
      }
      this.$('.bv_addDataModal').modal({
        backdrop: "static"
      });
      this.$('.bv_addDataModal').modal("show");
      if (json.results.experimentData.length > 0) {
        results = json.results.experimentData;
        return this.setupTree(results);
      }
    };

    AddDataToReport.prototype.setupTree = function(results) {
      var aggregate, expts, i, j, len, parents, to;
      this.$('.bv_addDataTree').jstree({
        core: {
          data: results
        },
        search: {
          fuzzy: false
        },
        plugins: ["checkbox", "search"]
      });
      this.$('.bv_addDataTree').bind("hover_node.jstree", function(e, data) {
        return $(e.target).attr("title", data.node.original.description);
      });
      to = false;
      this.$(".bv_searchVal").keyup((function(_this) {
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
      aggregate = this.model.get("aggregate");
      if (aggregate) {
        $(".bv_aggregation_true").prop("checked", true);
      }
      expts = this.model.get("experimentCodeList");
      this.exptLength = expts.length;
      this.$(".bv_addDataTree").jstree('open_node', expts);
      this.$(".bv_addDataTree").jstree('select_node', expts);
      this.$(".bv_addDataTree").jstree('disable_node', expts);
      parents = [];
      for (j = 0, len = expts.length; j < len; j++) {
        i = expts[j];
        if (this.$(".bv_addDataTree").jstree('is_leaf', i)) {
          parents.push(this.$(".bv_addDataTree").jstree('get_parent', i));
        }
      }
      return this.$(".bv_addDataTree").jstree('disable_node', parents);
    };

    AddDataToReport.prototype.handleSearchClear = function() {
      return this.$('.bv_searchVal').val("");
    };

    AddDataToReport.prototype.getSelectedExperiments = function() {
      return this.$('.bv_addDataTree').jstree('get_selected');
    };

    AddDataToReport.prototype.handleSelectionChanged = function() {
      this.selected = this.getSelectedExperiments();
      if (this.selected.length > this.exptLength) {
        return this.$('.bv_displayResults').prop("disabled", false);
      } else {
        return this.$('.bv_displayResults').prop("disabled", true);
      }
    };

    AddDataToReport.prototype.getQueryParams = function() {
      var queryParams;
      return queryParams = {
        batchCodes: this.allBatchCodes.join(),
        experimentCodeList: this.selected,
        searchFilters: this.model.get("searchFilters"),
        aggregate: this.model.get("aggregate")
      };
    };

    AddDataToReport.prototype.handleDisplayResuts = function() {
      this.$('.bv_searchStatusDropDown').modal({
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
        success: this.handleAddDataReturn,
        error: (function(_this) {
          return function(err) {
            return _this.serviceReturn = null;
          };
        })(this)
      });
    };

    AddDataToReport.prototype.handleAddDataReturn = function(json) {
      return this.trigger('requestResults', json);
    };

    return AddDataToReport;

  })(Backbone.View);

  window.GeneIDQueryAppController = (function(superClass) {
    extend(GeneIDQueryAppController, superClass);

    function GeneIDQueryAppController() {
      this.handleHelpClicked = bind(this.handleHelpClicked, this);
      this.handleCancelClicked = bind(this.handleCancelClicked, this);
      this.handleResultsClicked = bind(this.handleResultsClicked, this);
      this.handleNextClicked = bind(this.handleNextClicked, this);
      this.startAdvancedQueryWizard = bind(this.startAdvancedQueryWizard, this);
      this.startBasicQueryWizard = bind(this.startBasicQueryWizard, this);
      return GeneIDQueryAppController.__super__.constructor.apply(this, arguments);
    }

    GeneIDQueryAppController.prototype.template = _.template($("#GeneIDQueryAppView").html());

    GeneIDQueryAppController.prototype.events = {
      "click .bv_next": "handleNextClicked",
      "click .bv_toResults": "handleResultsClicked",
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
      return this.aerqc.on('requestAdvancedMode', this.startAdvancedQueryWizard);
    };

    GeneIDQueryAppController.prototype.startAdvancedQueryWizard = function(searchStr, aggregate) {
      var searchParams;
      console.log("The search text is: " + searchStr + "\n Aggregate is: " + aggregate);
      searchParams = {
        searchStr: searchStr,
        aggregate: aggregate
      };
      this.$('.bv_next').html("Next");
      this.$('.bv_next').removeAttr('disabled');
      this.$('.bv_addData').hide();
      this.$('.bv_advancedQueryContainer').addClass('gidAdvancedQueryContainerPadding');
      this.$('.bv_controlButtonContainer').addClass('gidAdvancedSearchButtons');
      this.$('.bv_controlButtonContainer').removeClass('gidAdvancedSearchButtonsResultsView');
      this.$('.bv_controlButtonContainer').removeClass('gidAdvancedSearchButtonsNewQuery');
      this.aerqc = new AdvancedExperimentResultsQueryController({
        el: this.$('.bv_advancedQueryView'),
        model: new Backbone.Model(searchParams)
      });
      this.aerqc.on('enableNext', (function(_this) {
        return function() {
          _this.$('.bv_next').removeAttr('disabled');
          return _this.$('.bv_toResults').removeAttr('disabled');
        };
      })(this));
      this.aerqc.on('disableNext', (function(_this) {
        return function() {
          _this.$('.bv_next').attr('disabled', 'disabled');
          return _this.$('.bv_toResults').attr('disabled', 'disabled');
        };
      })(this));
      this.aerqc.on('nextToFilterOnVals', (function(_this) {
        return function() {
          return _this.$('.bv_next').html("Filter on Values");
        };
      })(this));
      this.aerqc.on('nextToGotoResults', (function(_this) {
        return function() {
          _this.$('.bv_next').html("Go to Results");
          _this.$('.bv_toResults').hide();
          _this.$('.gidAdvancedSearchButtons').addClass('gidAdvancedSearchButtonsStepThree');
          return _this.$('.gidAdvancedSearchButtons').removeClass('gidAdvancedSearchButtonsNewQuery');
        };
      })(this));
      this.aerqc.on('requestShowResultsMode', (function(_this) {
        return function() {
          _this.$('.bv_next').html("New Query");
          _this.$('.bv_addData').show();
          _this.$('.bv_advancedQueryContainer').removeClass('gidAdvancedQueryContainerPadding');
          _this.$('.bv_controlButtonContainer').removeClass('gidAdvancedSearchButtons');
          return _this.$('.bv_controlButtonContainer').addClass('gidAdvancedSearchButtonsResultsView');
        };
      })(this));
      this.aerqc.on('requestRestartAdvancedQuery', (function(_this) {
        return function() {
          _this.$('.bv_toResults').show();
          _this.$('.gidAdvancedSearchButtonsResultsView').removeClass('gidAdvancedSearchButtonsStepThree');
          _this.$('.gidAdvancedSearchButtonsResultsView').addClass('gidAdvancedSearchButtonsNewQuery');
          return _this.startBasicQueryWizard();
        };
      })(this));
      this.aerqc.on('changeNextToNewQuery', (function(_this) {
        return function() {
          _this.$('.bv_next').html("New Query");
          _this.$('.bv_toResults').hide();
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

    GeneIDQueryAppController.prototype.handleResultsClicked = function() {
      if (this.aerqc != null) {
        return this.aerqc.handleResultsClicked();
      }
    };

    GeneIDQueryAppController.prototype.handleCancelClicked = function() {
      this.$('.bv_toResults').show();
      this.$('.gidAdvancedSearchButtonsResultsView').removeClass('gidAdvancedSearchButtonsStepThree');
      this.$('.gidAdvancedSearchButtonsResultsView').addClass('gidAdvancedSearchButtonsNewQuery');
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
