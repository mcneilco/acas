(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.ProjectSearch = (function(superClass) {
    extend(ProjectSearch, superClass);

    function ProjectSearch() {
      return ProjectSearch.__super__.constructor.apply(this, arguments);
    }

    ProjectSearch.prototype.defaults = {
      protocolCode: null,
      projectCode: null
    };

    return ProjectSearch;

  })(Backbone.Model);

  window.ProjectSearch = (function(superClass) {
    extend(ProjectSearch, superClass);

    function ProjectSearch() {
      return ProjectSearch.__super__.constructor.apply(this, arguments);
    }

    ProjectSearch.prototype.defaults = {
      protocolCode: null,
      projectCode: null
    };

    return ProjectSearch;

  })(Backbone.Model);

  window.ProjectSimpleSearchController = (function(superClass) {
    extend(ProjectSimpleSearchController, superClass);

    function ProjectSimpleSearchController() {
      this.doSearch = bind(this.doSearch, this);
      this.handleDoSearchClicked = bind(this.handleDoSearchClicked, this);
      this.updateProjectSearchTerm = bind(this.updateProjectSearchTerm, this);
      this.render = bind(this.render, this);
      return ProjectSimpleSearchController.__super__.constructor.apply(this, arguments);
    }

    ProjectSimpleSearchController.prototype.template = _.template($("#ProjectSimpleSearchView").html());

    ProjectSimpleSearchController.prototype.genericSearchUrl = "/api/genericSearch/projects/";

    ProjectSimpleSearchController.prototype.initialize = function() {
      this.includeDuplicateAndEdit = this.options.includeDuplicateAndEdit;
      this.searchUrl = "";
      if (this.includeDuplicateAndEdit) {
        return this.searchUrl = this.genericSearchUrl;
      } else {
        return this.searchUrl = this.codeNameSearchUrl;
      }
    };

    ProjectSimpleSearchController.prototype.events = {
      'keyup .bv_projectSearchTerm': 'updateProjectSearchTerm',
      'click .bv_doSearch': 'handleDoSearchClicked'
    };

    ProjectSimpleSearchController.prototype.render = function() {
      $(this.el).empty();
      return $(this.el).html(this.template());
    };

    ProjectSimpleSearchController.prototype.updateProjectSearchTerm = function(e) {
      var ENTER_KEY, projectSearchTerm;
      ENTER_KEY = 13;
      projectSearchTerm = $.trim(this.$(".bv_projectSearchTerm").val());
      if (projectSearchTerm !== "") {
        this.$(".bv_doSearch").attr("disabled", false);
        if (e.keyCode === ENTER_KEY) {
          $(':focus').blur();
          return this.handleDoSearchClicked();
        }
      } else {
        return this.$(".bv_doSearch").attr("disabled", true);
      }
    };

    ProjectSimpleSearchController.prototype.handleDoSearchClicked = function() {
      var projectSearchTerm;
      $(".bv_projectTableController").addClass("hide");
      $(".bv_errorOccurredPerformingSearch").addClass("hide");
      projectSearchTerm = $.trim(this.$(".bv_projectSearchTerm").val());
      $(".bv_exptSearchTerm").val("");
      if (projectSearchTerm !== "") {
        $(".bv_noMatchingProjectsFoundMessage").addClass("hide");
        $(".bv_projectBrowserSearchInstructions").addClass("hide");
        $(".bv_searchProjectsStatusIndicator").removeClass("hide");
        if (!window.conf.browser.enableSearchAll && projectSearchTerm === "*") {
          return $(".bv_moreSpecificProjectSearchNeeded").removeClass("hide");
        } else {
          $(".bv_searchingProjectsMessage").removeClass("hide");
          $(".bv_exptSearchTerm").html(projectSearchTerm);
          $(".bv_moreSpecificProjectSearchNeeded").addClass("hide");
          return this.doSearch(projectSearchTerm);
        }
      }
    };

    ProjectSimpleSearchController.prototype.doSearch = function(projectSearchTerm) {
      this.$(".bv_projectSearchTerm").attr("disabled", true);
      this.$(".bv_doSearch").attr("disabled", true);
      this.trigger('find');
      if (projectSearchTerm !== "") {
        return $.ajax({
          type: 'GET',
          url: this.searchUrl + projectSearchTerm,
          dataType: "json",
          data: {
            testMode: false,
            lsType: "project",
            lsKind: "project"
          },
          success: (function(_this) {
            return function(project) {
              return _this.trigger("searchReturned", project);
            };
          })(this),
          error: (function(_this) {
            return function(result) {
              return _this.trigger("searchReturned", null);
            };
          })(this),
          complete: (function(_this) {
            return function() {
              _this.$(".bv_projectSearchTerm").attr("disabled", false);
              return _this.$(".bv_doSearch").attr("disabled", false);
            };
          })(this)
        });
      }
    };

    return ProjectSimpleSearchController;

  })(AbstractFormController);

  window.ProjectRowSummaryController = (function(superClass) {
    extend(ProjectRowSummaryController, superClass);

    function ProjectRowSummaryController() {
      this.render = bind(this.render, this);
      this.handleClick = bind(this.handleClick, this);
      return ProjectRowSummaryController.__super__.constructor.apply(this, arguments);
    }

    ProjectRowSummaryController.prototype.tagName = 'tr';

    ProjectRowSummaryController.prototype.className = 'dataTableRow';

    ProjectRowSummaryController.prototype.events = {
      "click": "handleClick"
    };

    ProjectRowSummaryController.prototype.handleClick = function() {
      this.trigger("gotClick", this.model);
      $(this.el).closest("table").find("tr").removeClass("info");
      return $(this.el).addClass("info");
    };

    ProjectRowSummaryController.prototype.initialize = function() {
      return this.template = _.template($('#ProjectRowSummaryView').html());
    };

    ProjectRowSummaryController.prototype.render = function() {
      var projLeaders, projectBestName, projectLeadersValues, startDate, toDisplay;
      projectBestName = this.model.get('lsLabels').pickBestName();
      if (projectBestName) {
        projectBestName = this.model.get('lsLabels').pickBestName().get('labelText');
      }
      startDate = this.model.get('start date').get('value');
      if (startDate != null) {
        startDate = moment(startDate).format("YYYY-MM-DD");
      } else {
        startDate = "";
      }
      projectLeadersValues = this.model.getProjectLeaders();
      projLeaders = "";
      _.each(projectLeadersValues, (function(_this) {
        return function(leader) {
          if (projLeaders !== "") {
            projLeaders += ", ";
          }
          return projLeaders += leader.get('codeValue');
        };
      })(this));
      toDisplay = {
        projectCode: this.model.get('codeName'),
        projectName: projectBestName,
        projectLeaders: projLeaders,
        startDate: startDate,
        status: this.model.get('project status').get('value')
      };
      $(this.el).html(this.template(toDisplay));
      return this;
    };

    return ProjectRowSummaryController;

  })(Backbone.View);

  window.ProjectSummaryTableController = (function(superClass) {
    extend(ProjectSummaryTableController, superClass);

    function ProjectSummaryTableController() {
      this.render = bind(this.render, this);
      this.selectedRowChanged = bind(this.selectedRowChanged, this);
      return ProjectSummaryTableController.__super__.constructor.apply(this, arguments);
    }

    ProjectSummaryTableController.prototype.initialize = function() {};

    ProjectSummaryTableController.prototype.selectedRowChanged = function(row) {
      return this.trigger("selectedRowUpdated", row);
    };

    ProjectSummaryTableController.prototype.render = function() {
      this.template = _.template($('#ProjectSummaryTableView').html());
      $(this.el).html(this.template);
      if (this.collection.models.length === 0) {
        $(".bv_noMatchingProjectsFoundMessage").removeClass("hide");
      } else {
        $(".bv_noMatchingProjectsFoundMessage").addClass("hide");
        this.collection.each((function(_this) {
          return function(proj) {
            var prsc;
            prsc = new ProjectRowSummaryController({
              model: proj
            });
            prsc.on("gotClick", _this.selectedRowChanged);
            return _this.$("tbody").append(prsc.render().el);
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

    return ProjectSummaryTableController;

  })(Backbone.View);

  window.ProjectBrowserController = (function(superClass) {
    extend(ProjectBrowserController, superClass);

    function ProjectBrowserController() {
      this.render = bind(this.render, this);
      this.destroyProjectSummaryTable = bind(this.destroyProjectSummaryTable, this);
      this.handleDuplicateProjectClicked = bind(this.handleDuplicateProjectClicked, this);
      this.handleEditProjectClicked = bind(this.handleEditProjectClicked, this);
      this.handleCancelDeleteClicked = bind(this.handleCancelDeleteClicked, this);
      this.handleConfirmDeleteProjectClicked = bind(this.handleConfirmDeleteProjectClicked, this);
      this.handleDeleteProjectClicked = bind(this.handleDeleteProjectClicked, this);
      this.selectedProjectUpdated = bind(this.selectedProjectUpdated, this);
      this.setupProjectSummaryTable = bind(this.setupProjectSummaryTable, this);
      return ProjectBrowserController.__super__.constructor.apply(this, arguments);
    }

    ProjectBrowserController.prototype.includeDuplicateAndEdit = true;

    ProjectBrowserController.prototype.events = {
      "click .bv_deleteProject": "handleDeleteProjectClicked",
      "click .bv_editProject": "handleEditProjectClicked",
      "click .bv_duplicateProject": "handleDuplicateProjectClicked",
      "click .bv_confirmDeleteProjectButton": "handleConfirmDeleteProjectClicked",
      "click .bv_cancelDelete": "handleCancelDeleteClicked"
    };

    ProjectBrowserController.prototype.initialize = function() {
      var template;
      template = _.template($("#ProjectBrowserView").html(), {
        includeDuplicateAndEdit: this.includeDuplicateAndEdit
      });
      $(this.el).empty();
      $(this.el).html(template);
      this.searchController = new ProjectSimpleSearchController({
        model: new ProjectSearch(),
        el: this.$('.bv_projectSearchController'),
        includeDuplicateAndEdit: this.includeDuplicateAndEdit
      });
      this.searchController.render();
      this.searchController.on("searchReturned", this.setupProjectSummaryTable);
      return this.$('.bv_queryToolDisplayName').html(window.conf.service.result.viewer.displayName);
    };

    ProjectBrowserController.prototype.setupProjectSummaryTable = function(projects) {
      this.destroyProjectSummaryTable();
      $(".bv_searchingProjectsMessage").addClass("hide");
      if (projects === null) {
        return this.$(".bv_errorOccurredPerformingSearch").removeClass("hide");
      } else if (projects.length === 0) {
        this.$(".bv_noMatchingProjectsFoundMessage").removeClass("hide");
        return this.$(".bv_projectTableController").html("");
      } else {
        $(".bv_searchProjectsStatusIndicator").addClass("hide");
        this.$(".bv_projectTableController").removeClass("hide");
        this.projectSummaryTable = new ProjectSummaryTableController({
          collection: new ProjectList(projects)
        });
        this.projectSummaryTable.on("selectedRowUpdated", this.selectedProjectUpdated);
        return $(".bv_projectTableController").html(this.projectSummaryTable.render().el);
      }
    };

    ProjectBrowserController.prototype.selectedProjectUpdated = function(project) {
      this.trigger("selectedProjectUpdated");
      this.projectController = new ProjectController({
        model: new Project(project.attributes),
        readOnly: true
      });
      $('.bv_projectController').html(this.projectController.render().el);
      $(".bv_projectController").removeClass("hide");
      $(".bv_projectControllerContainer").removeClass("hide");
      if (project.get('project status').get('value') === "deleted") {
        this.$('.bv_deleteProject').hide();
        return this.$('.bv_editProject').hide();
      } else {
        this.$('.bv_editProject').show();
        return this.$('.bv_deleteProject').show();
      }
    };

    ProjectBrowserController.prototype.handleDeleteProjectClicked = function() {
      this.$(".bv_projectCodeName").html(this.projectController.model.get("codeName"));
      this.$(".bv_deleteButtons").removeClass("hide");
      this.$(".bv_okayButton").addClass("hide");
      this.$(".bv_errorDeletingProjectMessage").addClass("hide");
      this.$(".bv_deleteWarningMessage").removeClass("hide");
      this.$(".bv_deletingStatusIndicator").addClass("hide");
      this.$(".bv_projectDeletedSuccessfullyMessage").addClass("hide");
      $(".bv_confirmDeleteProject").removeClass("hide");
      return $('.bv_confirmDeleteProject').modal({
        keyboard: false,
        backdrop: true
      });
    };

    ProjectBrowserController.prototype.handleConfirmDeleteProjectClicked = function() {
      this.$(".bv_deleteWarningMessage").addClass("hide");
      this.$(".bv_deletingStatusIndicator").removeClass("hide");
      this.$(".bv_deleteButtons").addClass("hide");
      return $.ajax({
        url: "/api/projects/" + (this.projectController.model.get("id")),
        type: 'DELETE',
        success: (function(_this) {
          return function(result) {
            _this.$(".bv_okayButton").removeClass("hide");
            _this.$(".bv_deletingStatusIndicator").addClass("hide");
            _this.$(".bv_projectDeletedSuccessfullyMessage").removeClass("hide");
            return _this.searchController.handleDoSearchClicked();
          };
        })(this),
        error: (function(_this) {
          return function(result) {
            _this.$(".bv_okayButton").removeClass("hide");
            _this.$(".bv_deletingStatusIndicator").addClass("hide");
            return _this.$(".bv_errorDeletingProjectMessage").removeClass("hide");
          };
        })(this)
      });
    };

    ProjectBrowserController.prototype.handleCancelDeleteClicked = function() {
      return this.$(".bv_confirmDeleteProject").modal('hide');
    };

    ProjectBrowserController.prototype.handleEditProjectClicked = function() {
      return window.open("/entity/edit/codeName/" + (this.projectController.model.get("codeName")), '_blank');
    };

    ProjectBrowserController.prototype.handleDuplicateProjectClicked = function() {
      var projectKind;
      projectKind = this.projectController.model.get('lsKind');
      if (projectKind === "Bio Activity") {
        return window.open("/entity/copy/primary_screen_project/" + (this.projectController.model.get("codeName")), '_blank');
      } else {
        return window.open("/entity/copy/project/" + (this.projectController.model.get("codeName")), '_blank');
      }
    };

    ProjectBrowserController.prototype.destroyProjectSummaryTable = function() {
      if (this.projectSummaryTable != null) {
        this.projectSummaryTable.remove();
      }
      if (this.projectController != null) {
        this.projectController.remove();
      }
      $(".bv_projectController").addClass("hide");
      $(".bv_projectControllerContainer").addClass("hide");
      return $(".bv_noMatchingProjectsFoundMessage").addClass("hide");
    };

    ProjectBrowserController.prototype.render = function() {
      return this;
    };

    return ProjectBrowserController;

  })(Backbone.View);

}).call(this);
