(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.GeneID = (function(_super) {
    __extends(GeneID, _super);

    function GeneID() {
      return GeneID.__super__.constructor.apply(this, arguments);
    }

    GeneID.prototype.defaults = {
      gid: null
    };

    return GeneID;

  })(Backbone.Model);

  window.GeneIDList = (function(_super) {
    __extends(GeneIDList, _super);

    function GeneIDList() {
      return GeneIDList.__super__.constructor.apply(this, arguments);
    }

    GeneIDList.prototype.model = GeneID;

    GeneIDList.prototype.addGIDsFromString = function(listStr) {
      var gid, gids, _i, _len, _results;
      if ($.trim(listStr) !== "") {
        gids = listStr.split(",");
        _results = [];
        for (_i = 0, _len = gids.length; _i < _len; _i++) {
          gid = gids[_i];
          _results.push(this.add(new GeneID({
            gid: $.trim(gid)
          })));
        }
        return _results;
      }
    };

    return GeneIDList;

  })(Backbone.Collection);

  window.GeneIDQueryInputController = (function(_super) {
    __extends(GeneIDQueryInputController, _super);

    function GeneIDQueryInputController() {
      this.handleSearchClicked = __bind(this.handleSearchClicked, this);
      this.handleKeyInInputField = __bind(this.handleKeyInInputField, this);
      this.handleInputFieldChanged = __bind(this.handleInputFieldChanged, this);
      this.render = __bind(this.render, this);
      return GeneIDQueryInputController.__super__.constructor.apply(this, arguments);
    }

    GeneIDQueryInputController.prototype.template = _.template($("#GeneIDQueryInputView").html());

    GeneIDQueryInputController.prototype.events = {
      "click .bv_search": "handleSearchClicked",
      "change .bv_gidListString": "handleInputFieldChanged",
      "keydown .bv_gidListString": "handleKeyInInputField"
    };

    GeneIDQueryInputController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      this.$('.bv_search').attr('disabled', 'disabled');
      this.$('.bv_gidACASBadgeTop').hide();
      return this;
    };

    GeneIDQueryInputController.prototype.updateGIDsFromField = function() {
      this.collection.reset();
      return this.collection.addGIDsFromString(this.$('.bv_gidListString').val());
    };

    GeneIDQueryInputController.prototype.handleInputFieldChanged = function(e) {
      this.updateGIDsFromField();
      if (this.collection.length === 0) {
        return this.$('.bv_search').attr('disabled', 'disabled');
      } else {
        return this.$('.bv_search').removeAttr('disabled');
      }
    };

    GeneIDQueryInputController.prototype.handleKeyInInputField = function(e) {
      if (e.keyCode === 13) {
        return this.handleSearchClicked();
      }
    };

    GeneIDQueryInputController.prototype.handleSearchClicked = function() {
      this.updateGIDsFromField();
      return this.trigger('search-requested');
    };

    return GeneIDQueryInputController;

  })(Backbone.View);

  window.GeneIDQueryResultController = (function(_super) {
    __extends(GeneIDQueryResultController, _super);

    function GeneIDQueryResultController() {
      this.render = __bind(this.render, this);
      return GeneIDQueryResultController.__super__.constructor.apply(this, arguments);
    }

    GeneIDQueryResultController.prototype.template = _.template($("#GeneIDQueryResultView").html());

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
      _.each(this.model.get('data').groupHeaders, (function(_this) {
        return function(header) {
          return _this.$('.bv_experimentNamesHeader').append('<th colspan="' + header.numberOfColumns + '">' + header.titleText + '</th>');
        };
      })(this));
      return _.each(this.model.get('data').aoColumns, (function(_this) {
        return function(header) {
          return _this.$('.bv_columnNamesHeader').append('<th>placeholder</th>');
        };
      })(this));
    };

    return GeneIDQueryResultController;

  })(Backbone.View);

  window.GeneIDQuerySearchController = (function(_super) {
    __extends(GeneIDQuerySearchController, _super);

    function GeneIDQuerySearchController() {
      this.setShowResultsMode = __bind(this.setShowResultsMode, this);
      this.setQueryOnlyMode = __bind(this.setQueryOnlyMode, this);
      this.handleSearchReturn = __bind(this.handleSearchReturn, this);
      this.handleSearchRequested = __bind(this.handleSearchRequested, this);
      this.render = __bind(this.render, this);
      return GeneIDQuerySearchController.__super__.constructor.apply(this, arguments);
    }

    GeneIDQuerySearchController.prototype.template = _.template($("#GeneIDQuerySearchView").html());

    GeneIDQuerySearchController.prototype.initialize = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      this.queryInputController = new GeneIDQueryInputController({
        collection: new GeneIDList(),
        el: this.$('.bv_inputView')
      });
      this.queryInputController.on('search-requested', this.handleSearchRequested);
      this.queryInputController.render();
      return this.setQueryOnlyMode();
    };

    GeneIDQuerySearchController.prototype.render = function() {
      return this;
    };

    GeneIDQuerySearchController.prototype.handleSearchRequested = function() {
      return $.ajax({
        type: 'POST',
        url: "api/geneDataQuery",
        data: {
          geneIDs: this.queryInputController.collection.toJSON(),
          maxRowsToReturn: 10000,
          user: window.AppLaunchParams.loginUserName
        },
        success: this.handleSearchReturn,
        error: (function(_this) {
          return function(err) {
            console.log('got ajax error');
            return _this.serviceReturn = null;
          };
        })(this),
        dataType: 'json'
      });
    };

    GeneIDQuerySearchController.prototype.handleSearchReturn = function(json) {
      this.resultController = new GeneIDQueryResultController({
        model: new Backbone.Model(json.results),
        el: $('.bv_resultsView')
      });
      this.resultController.render();
      $('.bv_searchForm').appendTo('.bv_toolbar');
      this.$('.bv_gidSearchStart').hide();
      this.$('.bv_gidACASBadge').hide();
      this.$('.bv_gidACASBadgeTop').show();
      this.$('.bv_gidNavAdvancedSearchButton').removeClass('gidNavAdvancedSearchButtonBottom');
      this.$('.bv_gidNavHelpButton').addClass('pull-right');
      this.$('.bv_gidNavAdvancedSearchButton').addClass('gidNavAdvancedSearchButtonTop');
      this.$('.bv_toolbar').removeClass('gidNavWellBottom');
      this.$('.bv_toolbar').addClass('gidNavWellTop');
      this.$('.bv_group_toolbar').removeClass('navbar-fixed-bottom');
      this.$('.bv_group_toolbar').addClass('navbar-fixed-top');
      return this.setShowResultsMode();
    };

    GeneIDQuerySearchController.prototype.setQueryOnlyMode = function() {
      return this.$('.bv_resultsView').hide();
    };

    GeneIDQuerySearchController.prototype.setShowResultsMode = function() {
      return this.$('.bv_resultsView').show();
    };

    return GeneIDQuerySearchController;

  })(Backbone.View);

  window.ExperimentTreeController = (function(_super) {
    __extends(ExperimentTreeController, _super);

    function ExperimentTreeController() {
      this.handleSearchClear = __bind(this.handleSearchClear, this);
      this.render = __bind(this.render, this);
      return ExperimentTreeController.__super__.constructor.apply(this, arguments);
    }

    ExperimentTreeController.prototype.template = _.template($("#ExperimentTreeView").html());

    ExperimentTreeController.prototype.events = {
      "click .bv_searchClear": "handleSearchClear"
    };

    ExperimentTreeController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      this.setupTree();
      return this;
    };

    ExperimentTreeController.prototype.setupTree = function() {
      var to;
      this.$('.bv_tree').jstree({
        core: {
          data: this.model.get('experimentData')
        },
        plugins: ["checkbox", "search"]
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
      return ExperimentResultFilterTermController.__super__.constructor.apply(this, arguments);
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
      return this.model.on("destroy", this.remove, this);
    };

    ExperimentResultFilterTermController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      this.filterOptions.each((function(_this) {
        return function(expt) {
          var code;
          code = expt.get('experimentCode');
          return _this.$('.bv_experiment').append('<option val="' + code + '">' + code + '</option>');
        };
      })(this));
      this.setKindOptions();
      this.setOperatorOptions();
      return this;
    };

    ExperimentResultFilterTermController.prototype.setKindOptions = function() {
      var currentExpt, kind, kinds, _i, _len, _results;
      currentExpt = this.getSelectedExperiment();
      kinds = _.pluck(currentExpt.get('valueKinds'), 'lsKind');
      this.$('.bv_kind').empty();
      _results = [];
      for (_i = 0, _len = kinds.length; _i < _len; _i++) {
        kind = kinds[_i];
        _results.push(this.$('.bv_kind').append('<option val="' + kind + '">' + kind + '</option>'));
      }
      return _results;
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
      return ExperimentResultFilterTermListController.__super__.constructor.apply(this, arguments);
    }

    ExperimentResultFilterTermListController.prototype.template = _.template($("#ExperimentResultFilterTermListView").html());

    ExperimentResultFilterTermListController.prototype.events = {
      "click .bv_addTerm": "addOne"
    };

    ExperimentResultFilterTermListController.prototype.initialize = function() {
      return this.filterOptions = this.options.filterOptions;
    };

    ExperimentResultFilterTermListController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      this.addOne();
      return this;
    };

    ExperimentResultFilterTermListController.prototype.addOne = function() {
      var erftc, newModel;
      newModel = new Backbone.Model();
      this.collection.add(newModel);
      erftc = new ExperimentResultFilterTermController({
        model: newModel,
        filterOptions: this.filterOptions
      });
      this.$('.bv_filterTerms').append(erftc.render().el);
      return this.on("updateFilterModels", erftc.updateModel);
    };

    ExperimentResultFilterTermListController.prototype.updateCollection = function() {
      return this.trigger("updateFilterModels");
    };

    return ExperimentResultFilterTermListController;

  })(Backbone.View);

  window.GeneIDQueryAppController = (function(_super) {
    __extends(GeneIDQueryAppController, _super);

    function GeneIDQueryAppController() {
      this.handleGetExperimentSearchAttributesReturn = __bind(this.handleGetExperimentSearchAttributesReturn, this);
      this.handleGetGeneExperimentsReturn = __bind(this.handleGetGeneExperimentsReturn, this);
      return GeneIDQueryAppController.__super__.constructor.apply(this, arguments);
    }

    GeneIDQueryAppController.prototype.template = _.template($("#GeneIDQueryAppView").html());

    GeneIDQueryAppController.prototype.initialize = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      return $.ajax({
        type: 'POST',
        url: "api/getExperimentSearchAttributes",
        dataType: 'json',
        data: {
          experimentCodes: ["EXPT-00000398", "EXPT-00000396", "EXPT-00000398"]
        },
        success: this.handleGetExperimentSearchAttributesReturn,
        error: (function(_this) {
          return function(err) {
            console.log('got ajax error');
            return _this.serviceReturn = null;
          };
        })(this)
      });
    };

    GeneIDQueryAppController.prototype.handleGetGeneExperimentsReturn = function(json) {
      this.etc = new ExperimentTreeController({
        el: this.$('.bv_exptTreeView'),
        model: new Backbone.Model(json.results)
      });
      return this.etc.render();
    };

    GeneIDQueryAppController.prototype.handleGetExperimentSearchAttributesReturn = function(json) {
      this.etc = new ExperimentResultFilterTermListController({
        el: this.$('.bv_attributeFilterView'),
        collection: new Backbone.Collection(),
        filterOptions: new Backbone.Collection(json.results.experiments)
      });
      return this.etc.render();
    };

    return GeneIDQueryAppController;

  })(Backbone.View);

}).call(this);
