(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.ExperimentSearch = (function(superClass) {
    extend(ExperimentSearch, superClass);

    function ExperimentSearch() {
      return ExperimentSearch.__super__.constructor.apply(this, arguments);
    }

    ExperimentSearch.prototype.defaults = {
      protocolCode: null,
      experimentCode: null
    };

    return ExperimentSearch;

  })(Backbone.Model);

  window.ExperimentSearchController = (function(superClass) {
    extend(ExperimentSearchController, superClass);

    function ExperimentSearchController() {
      this.setupExperimentSummaryTable = bind(this.setupExperimentSummaryTable, this);
      this.selectedExperimentUpdated = bind(this.selectedExperimentUpdated, this);
      this.doGenericExperimentSearch = bind(this.doGenericExperimentSearch, this);
      this.handleFindClicked = bind(this.handleFindClicked, this);
      this.updateExperimentCode = bind(this.updateExperimentCode, this);
      this.updateModel = bind(this.updateModel, this);
      this.render = bind(this.render, this);
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

  window.ExperimentSearch = (function(superClass) {
    extend(ExperimentSearch, superClass);

    function ExperimentSearch() {
      return ExperimentSearch.__super__.constructor.apply(this, arguments);
    }

    ExperimentSearch.prototype.defaults = {
      protocolCode: null,
      experimentCode: null
    };

    return ExperimentSearch;

  })(Backbone.Model);

  window.ExperimentSimpleSearchController = (function(superClass) {
    extend(ExperimentSimpleSearchController, superClass);

    function ExperimentSimpleSearchController() {
      this.doSearch = bind(this.doSearch, this);
      this.handleDoSearchClicked = bind(this.handleDoSearchClicked, this);
      this.updateExperimentSearchTerm = bind(this.updateExperimentSearchTerm, this);
      this.render = bind(this.render, this);
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
      $(".bv_exptSearchTerm").val("");
      if (experimentSearchTerm !== "") {
        $(".bv_noMatchingExperimentsFoundMessage").addClass("hide");
        $(".bv_experimentBrowserSearchInstructions").addClass("hide");
        $(".bv_searchExperimentsStatusIndicator").removeClass("hide");
        if (!window.conf.browser.enableSearchAll && experimentSearchTerm === "*") {
          return $(".bv_moreSpecificExperimentSearchNeeded").removeClass("hide");
        } else {
          $(".bv_searchingExperimentsMessage").removeClass("hide");
          $(".bv_exptSearchTerm").html(experimentSearchTerm);
          $(".bv_moreSpecificExperimentSearchNeeded").addClass("hide");
          return this.doSearch(experimentSearchTerm);
        }
      }
    };

    ExperimentSimpleSearchController.prototype.doSearch = function(experimentSearchTerm) {
      this.$(".bv_experimentSearchTerm").attr("disabled", true);
      this.$(".bv_doSearch").attr("disabled", true);
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
          })(this),
          complete: (function(_this) {
            return function() {
              _this.$(".bv_experimentSearchTerm").attr("disabled", false);
              return _this.$(".bv_doSearch").attr("disabled", false);
            };
          })(this)
        });
      }
    };

    return ExperimentSimpleSearchController;

  })(AbstractFormController);

  window.ExperimentRowSummaryController = (function(superClass) {
    extend(ExperimentRowSummaryController, superClass);

    function ExperimentRowSummaryController() {
      this.render = bind(this.render, this);
      this.handleClick = bind(this.handleClick, this);
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
      var date, experimentBestName, project, protocolBestName, ref, toDisplay;
      date = this.model.getCompletionDate();
      if (date.isNew()) {
        date = "not recorded";
      } else {
        date = UtilityFunctions.prototype.convertMSToYMDDate(date.get('dateValue'));
      }
      experimentBestName = this.model.get('lsLabels').pickBestName();
      if (experimentBestName) {
        experimentBestName = this.model.get('lsLabels').pickBestName().get('labelText');
      }
      protocolBestName = this.model.get('protocol').get('lsLabels').pickBestName();
      if (protocolBestName) {
        protocolBestName = this.model.get('protocol').get('lsLabels').pickBestName().get('labelText');
      }
      toDisplay = {
        experimentName: experimentBestName,
        experimentCode: this.model.get('codeName'),
        protocolCode: this.model.get('protocol').get("codeName"),
        protocolName: protocolBestName,
        scientist: this.model.getScientist().get('codeValue'),
        status: this.model.getStatus().get("codeValue"),
        analysisStatus: this.model.getAnalysisStatus().get("codeValue"),
        completionDate: date
      };
      $(this.el).html(this.template(toDisplay));
      if (!((((ref = window.conf.save) != null ? ref.project : void 0) != null) && window.conf.save.project.toLowerCase() === "false")) {
        project = this.model.getProjectCode().get('codeValue');
        this.$('.bv_protocolName').after("<td class='bv_project'>" + project + "</td>");
      }
      return this;
    };

    return ExperimentRowSummaryController;

  })(Backbone.View);

  window.ExperimentSummaryTableController = (function(superClass) {
    extend(ExperimentSummaryTableController, superClass);

    function ExperimentSummaryTableController() {
      this.render = bind(this.render, this);
      this.selectedRowChanged = bind(this.selectedRowChanged, this);
      return ExperimentSummaryTableController.__super__.constructor.apply(this, arguments);
    }

    ExperimentSummaryTableController.prototype.initialize = function() {};

    ExperimentSummaryTableController.prototype.selectedRowChanged = function(row) {
      return this.trigger("selectedRowUpdated", row);
    };

    ExperimentSummaryTableController.prototype.render = function() {
      var ref;
      this.template = _.template($('#ExperimentSummaryTableView').html());
      $(this.el).html(this.template);
      if (!((((ref = window.conf.save) != null ? ref.project : void 0) != null) && window.conf.save.project.toLowerCase() === "false")) {
        this.$('.bv_protocolNameHeader').after('<th style="width: 175px;">Project</th>');
      }
      if (this.collection.models.length === 0) {
        $(".bv_noMatchingExperimentsFoundMessage").removeClass("hide");
      } else {
        $(".bv_noMatchingExperimentsFoundMessage").addClass("hide");
        this.collection.each((function(_this) {
          return function(exp) {
            var ersc, hideStatusesList, ref1;
            hideStatusesList = null;
            if (((ref1 = window.conf.entity) != null ? ref1.hideStatuses : void 0) != null) {
              hideStatusesList = window.conf.entity.hideStatuses;
            }
            if (!((hideStatusesList != null) && hideStatusesList.length > 0 && hideStatusesList.indexOf(exp.getStatus().get('codeValue')) > -1 && !(UtilityFunctions.prototype.testUserHasRole(window.AppLaunchParams.loginUser, ["admin"])))) {
              ersc = new ExperimentRowSummaryController({
                model: exp
              });
              ersc.on("gotClick", _this.selectedRowChanged);
              return _this.$("tbody").append(ersc.render().el);
            }
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

  window.ExperimentBrowserController = (function(superClass) {
    extend(ExperimentBrowserController, superClass);

    function ExperimentBrowserController() {
      this.render = bind(this.render, this);
      this.destroyExperimentSummaryTable = bind(this.destroyExperimentSummaryTable, this);
      this.formatOpenInQueryToolButton = bind(this.formatOpenInQueryToolButton, this);
      this.handleOpenInQueryToolClicked = bind(this.handleOpenInQueryToolClicked, this);
      this.handleDuplicateExperimentClicked = bind(this.handleDuplicateExperimentClicked, this);
      this.handleEditExperimentClicked = bind(this.handleEditExperimentClicked, this);
      this.handleCancelDeleteClicked = bind(this.handleCancelDeleteClicked, this);
      this.handleConfirmDeleteExperimentClicked = bind(this.handleConfirmDeleteExperimentClicked, this);
      this.handleDeleteExperimentClicked = bind(this.handleDeleteExperimentClicked, this);
      this.selectedExperimentUpdated = bind(this.selectedExperimentUpdated, this);
      this.setupExperimentSummaryTable = bind(this.setupExperimentSummaryTable, this);
      return ExperimentBrowserController.__super__.constructor.apply(this, arguments);
    }

    ExperimentBrowserController.prototype.includeDuplicateAndEdit = true;

    ExperimentBrowserController.prototype.events = {
      "click .bv_deleteExperiment": "handleDeleteExperimentClicked",
      "click .bv_editExperiment": "handleEditExperimentClicked",
      "click .bv_duplicateExperiment": "handleDuplicateExperimentClicked",
      "click .bv_confirmDeleteExperimentButton": "handleConfirmDeleteExperimentClicked",
      "click .bv_cancelDelete": "handleCancelDeleteClicked",
      "click .bv_openInQueryToolButton": "handleOpenInQueryToolClicked"
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
      return this.searchController.on("searchReturned", this.setupExperimentSummaryTable);
    };

    ExperimentBrowserController.prototype.setupExperimentSummaryTable = function(experiments) {
      this.destroyExperimentSummaryTable();
      $(".bv_searchingExperimentsMessage").addClass("hide");
      if (experiments === null) {
        return this.$(".bv_errorOccurredPerformingSearch").removeClass("hide");
      } else if (experiments.length === 0) {
        this.$(".bv_noMatchingExperimentsFoundMessage").removeClass("hide");
        return this.$(".bv_experimentTableController").html("");
      } else {
        $(".bv_searchExperimentsStatusIndicator").addClass("hide");
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
      if (experiment.get('lsKind') === "Bio Activity") {
        this.experimentController = new ExperimentBaseController({
          protocolKindFilter: "?protocolKind=Bio Activity",
          model: new PrimaryScreenExperiment(experiment.attributes),
          readOnly: true
        });
      } else {
        this.experimentController = new ExperimentBaseController({
          model: new Experiment(experiment.attributes),
          readOnly: true
        });
      }
      $('.bv_experimentBaseController').html(this.experimentController.render().el);
      $(".bv_experimentBaseController").removeClass("hide");
      $(".bv_experimentBaseControllerContainer").removeClass("hide");
      if (experiment.getStatus().get('codeValue') === "deleted") {
        this.$('.bv_deleteExperiment').hide();
        return this.$('.bv_editExperiment').hide();
      } else {
        this.formatOpenInQueryToolButton();
        if (this.canEdit()) {
          this.$('.bv_editExperiment').show();
        } else {
          this.$('.bv_editExperiment').hide();
        }
        if (this.canDelete()) {
          return this.$('.bv_deleteExperiment').show();
        } else {
          return this.$('.bv_deleteExperiment').hide();
        }
      }
    };

    ExperimentBrowserController.prototype.canEdit = function() {
      var i, len, ref, ref1, role, rolesToTest;
      if (this.experimentController.model.getScientist().get('codeValue') === "unassigned") {
        return true;
      } else {
        if (((ref = window.conf.entity) != null ? ref.editingRoles : void 0) != null) {
          rolesToTest = [];
          ref1 = window.conf.entity.editingRoles.split(",");
          for (i = 0, len = ref1.length; i < len; i++) {
            role = ref1[i];
            if (role === 'entityScientist') {
              if (window.AppLaunchParams.loginUserName === this.experimentController.model.getScientist().get('codeValue')) {
                return true;
              }
            } else {
              rolesToTest.push($.trim(role));
            }
          }
          if (rolesToTest.length === 0) {
            return false;
          }
          if (!UtilityFunctions.prototype.testUserHasRole(window.AppLaunchParams.loginUser, rolesToTest)) {
            return false;
          }
        }
        return true;
      }
    };

    ExperimentBrowserController.prototype.canDelete = function() {
      var i, len, ref, ref1, role, rolesToTest;
      if (((ref = window.conf.entity) != null ? ref.deletingRoles : void 0) != null) {
        rolesToTest = [];
        ref1 = window.conf.entity.deletingRoles.split(",");
        for (i = 0, len = ref1.length; i < len; i++) {
          role = ref1[i];
          if (role === 'entityScientist') {
            if (window.AppLaunchParams.loginUserName === this.experimentController.model.getScientist().get('codeValue')) {
              return true;
            }
          } else {
            rolesToTest.push($.trim(role));
          }
        }
        if (rolesToTest.length === 0) {
          return false;
        }
        if (!UtilityFunctions.prototype.testUserHasRole(window.AppLaunchParams.loginUser, rolesToTest)) {
          return false;
        }
      }
      return true;
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
        url: "/api/experiments/" + (this.experimentController.model.get("id")),
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
      if (experimentKind === "Bio Activity") {
        return window.open("/entity/copy/primary_screen_experiment/" + (this.experimentController.model.get("codeName")), '_blank');
      } else {
        return window.open("/entity/copy/experiment_base/" + (this.experimentController.model.get("codeName")), '_blank');
      }
    };

    ExperimentBrowserController.prototype.handleOpenInQueryToolClicked = function() {
      if (!this.$('.bv_openInQueryToolButton').hasClass('dropdown-toggle')) {
        return window.open("/openExptInQueryTool?experiment=" + (this.experimentController.model.get("codeName")), '_blank');
      }
    };

    ExperimentBrowserController.prototype.formatOpenInQueryToolButton = function() {
      var configuredViewers, href, i, len, results, viewer, viewerName;
      this.$('.bv_viewerOptions').empty();
      configuredViewers = window.conf.service.result.viewer.configuredViewers;
      if (configuredViewers != null) {
        configuredViewers = configuredViewers.split(",");
      }
      if ((configuredViewers != null) && configuredViewers.length > 1) {
        results = [];
        for (i = 0, len = configuredViewers.length; i < len; i++) {
          viewer = configuredViewers[i];
          viewerName = $.trim(viewer);
          href = "'/openExptInQueryTool?tool=" + viewerName + "&experiment=" + (this.experimentController.model.get("codeName")) + "','_blank'";
          if (this.experimentController.model.getStatus().get('codeValue') !== "approved" && viewerName === "LiveDesign") {
            results.push(this.$('.bv_viewerOptions').append('<li class="disabled"><a href=' + href + ' target="_blank">' + viewerName + '</a></li>'));
          } else {
            results.push(this.$('.bv_viewerOptions').append('<li><a href=' + href + ' target="_blank">' + viewerName + '</a></li>'));
          }
        }
        return results;
      } else {
        this.$('.bv_openInQueryToolButton').removeAttr('data-toggle', 'dropdown');
        this.$('.bv_openInQueryToolButton').removeClass('dropdown-toggle');
        this.$('.bv_openInQueryToolButton .caret').hide();
        this.$('.bv_openInQueryToolButton').html("Open In " + window.conf.service.result.viewer.displayName);
        return this.$('.bv_openInQueryTool').removeClass("btn-group");
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
      return $(".bv_noMatchingExperimentsFoundMessage").addClass("hide");
    };

    ExperimentBrowserController.prototype.render = function() {
      return this;
    };

    return ExperimentBrowserController;

  })(Backbone.View);

  window.ExperimentDetailController = (function(superClass) {
    extend(ExperimentDetailController, superClass);

    function ExperimentDetailController() {
      this.render = bind(this.render, this);
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
