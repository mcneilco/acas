(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.ComponentList = (function(_super) {
    __extends(ComponentList, _super);

    function ComponentList() {
      return ComponentList.__super__.constructor.apply(this, arguments);
    }

    ComponentList.prototype.model = function(attrs, options) {
      var component, lsKind;
      lsKind = attrs.lsKind;
      lsKind = lsKind.replace(/(^|[^a-z0-9-])([a-z])/g, function(m, m1, m2, p) {
        return m1 + m2.toUpperCase();
      });
      lsKind = lsKind.replace(/\s/g, '');
      component = lsKind + "Batch";
      return new window[component](attrs);
    };

    return ComponentList;

  })(Backbone.Collection);

  window.ComponentSearch = (function(_super) {
    __extends(ComponentSearch, _super);

    function ComponentSearch() {
      return ComponentSearch.__super__.constructor.apply(this, arguments);
    }

    ComponentSearch.prototype.defaults = {
      componentCode: null
    };

    return ComponentSearch;

  })(Backbone.Model);

  window.ComponentSimpleSearchController = (function(_super) {
    __extends(ComponentSimpleSearchController, _super);

    function ComponentSimpleSearchController() {
      this.doSearch = __bind(this.doSearch, this);
      this.handleDoSearchClicked = __bind(this.handleDoSearchClicked, this);
      this.updateComponentSearchTerm = __bind(this.updateComponentSearchTerm, this);
      this.render = __bind(this.render, this);
      return ComponentSimpleSearchController.__super__.constructor.apply(this, arguments);
    }

    ComponentSimpleSearchController.prototype.template = _.template($("#ComponentSimpleSearchView").html());

    ComponentSimpleSearchController.prototype.genericSearchUrl = "/api/components/genericSearch/";

    ComponentSimpleSearchController.prototype.codeNameSearchUrl = "/api/components/codename/";

    ComponentSimpleSearchController.prototype.initialize = function() {
      return this.searchUrl = this.genericSearchUrl;
    };

    ComponentSimpleSearchController.prototype.events = {
      'keyup .bv_componentSearchTerm': 'updateComponentSearchTerm',
      'click .bv_doSearch': 'handleDoSearchClicked'
    };

    ComponentSimpleSearchController.prototype.render = function() {
      $(this.el).empty();
      return $(this.el).html(this.template());
    };

    ComponentSimpleSearchController.prototype.updateComponentSearchTerm = function(e) {
      var ENTER_KEY, componentSearchTerm;
      ENTER_KEY = 13;
      componentSearchTerm = $.trim(this.$(".bv_componentSearchTerm").val());
      if (componentSearchTerm !== "") {
        this.$(".bv_doSearch").attr("disabled", false);
        if (e.keyCode === ENTER_KEY) {
          $(':focus').blur();
          return this.handleDoSearchClicked();
        }
      } else {
        return this.$(".bv_doSearch").attr("disabled", true);
      }
    };

    ComponentSimpleSearchController.prototype.handleDoSearchClicked = function() {
      var componentSearchTerm;
      $(".bv_componentTableController").addClass("hide");
      $(".bv_errorOccurredPerformingSearch").addClass("hide");
      componentSearchTerm = $.trim(this.$(".bv_componentSearchTerm").val());
      $(".bv_searchTerm").val("");
      if (componentSearchTerm !== "") {
        if (this.$(".bv_clearSearchIcon").hasClass("hide")) {
          this.$(".bv_componentSearchTerm").attr("disabled", true);
          this.$(".bv_doSearchIcon").addClass("hide");
          this.$(".bv_clearSearchIcon").removeClass("hide");
          $(".bv_searchingMessage").removeClass("hide");
          $(".bv_componentBrowserSearchInstructions").addClass("hide");
          $(".bv_searchTerm").html(componentSearchTerm);
          return this.doSearch(componentSearchTerm);
        } else {
          this.$(".bv_componentSearchTerm").val("");
          this.$(".bv_componentSearchTerm").attr("disabled", false);
          this.$(".bv_clearSearchIcon").addClass("hide");
          this.$(".bv_doSearchIcon").removeClass("hide");
          $(".bv_searchingMessage").addClass("hide");
          $(".bv_componentBrowserSearchInstructions").removeClass("hide");
          $(".bv_searchStatusIndicator").removeClass("hide");
          this.updateComponentSearchTerm();
          return this.trigger("resetSearch");
        }
      }
    };

    ComponentSimpleSearchController.prototype.doSearch = function(componentSearchTerm) {
      this.trigger('find');
      if (componentSearchTerm !== "") {
        return $.ajax({
          type: 'GET',
          url: this.searchUrl + componentSearchTerm,
          dataType: "json",
          data: {
            testMode: false
          },
          success: (function(_this) {
            return function(component) {
              return _this.trigger("searchReturned", component);
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

    return ComponentSimpleSearchController;

  })(AbstractFormController);

  window.ComponentRowSummaryController = (function(_super) {
    __extends(ComponentRowSummaryController, _super);

    function ComponentRowSummaryController() {
      this.render = __bind(this.render, this);
      this.handleClick = __bind(this.handleClick, this);
      return ComponentRowSummaryController.__super__.constructor.apply(this, arguments);
    }

    ComponentRowSummaryController.prototype.tagName = 'tr';

    ComponentRowSummaryController.prototype.className = 'dataTableRow';

    ComponentRowSummaryController.prototype.events = {
      "click": "handleClick"
    };

    ComponentRowSummaryController.prototype.handleClick = function() {
      this.trigger("gotClick", this.model);
      $(this.el).closest("table").find("tr").removeClass("info");
      return $(this.el).addClass("info");
    };

    ComponentRowSummaryController.prototype.initialize = function() {
      return this.template = _.template($('#ComponentRowSummaryView').html());
    };

    ComponentRowSummaryController.prototype.render = function() {
      var lsKind, toDisplay;
      lsKind = this.model.get('lsKind');
      toDisplay = {
        componentName: this.model.get('lsLabels').pickBestName().get('labelText'),
        componentCode: this.model.get('codeName'),
        componentKind: this.model.get('lsKind'),
        scientist: this.model.get('scientist').get('value'),
        completionDate: this.model.get('completion date').get('value')
      };
      $(this.el).html(this.template(toDisplay));
      return this;
    };

    return ComponentRowSummaryController;

  })(Backbone.View);

  window.ComponentSummaryTableController = (function(_super) {
    __extends(ComponentSummaryTableController, _super);

    function ComponentSummaryTableController() {
      this.render = __bind(this.render, this);
      this.selectedRowChanged = __bind(this.selectedRowChanged, this);
      return ComponentSummaryTableController.__super__.constructor.apply(this, arguments);
    }

    ComponentSummaryTableController.prototype.initialize = function() {};

    ComponentSummaryTableController.prototype.selectedRowChanged = function(row) {
      return this.trigger("selectedRowUpdated", row);
    };

    ComponentSummaryTableController.prototype.render = function() {
      this.template = _.template($('#ComponentSummaryTableView').html());
      $(this.el).html(this.template);
      console.dir(this.collection);
      window.fooSearchResults = this.collection;
      if (this.collection.models.length === 0) {
        this.$(".bv_noMatchesFoundMessage").removeClass("hide");
      } else {
        this.$(".bv_noMatchesFoundMessage").addClass("hide");
        this.collection.each((function(_this) {
          return function(prot) {
            var prsc;
            prsc = new ComponentRowSummaryController({
              model: prot
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

    return ComponentSummaryTableController;

  })(Backbone.View);

  window.ComponentBrowserController = (function(_super) {
    __extends(ComponentBrowserController, _super);

    function ComponentBrowserController() {
      this.render = __bind(this.render, this);
      this.destroyComponentSummaryTable = __bind(this.destroyComponentSummaryTable, this);
      this.handleDuplicateParentClicked = __bind(this.handleDuplicateParentClicked, this);
      this.handleEditComponentClicked = __bind(this.handleEditComponentClicked, this);
      this.handleCancelDeleteClicked = __bind(this.handleCancelDeleteClicked, this);
      this.handleConfirmDeleteComponentClicked = __bind(this.handleConfirmDeleteComponentClicked, this);
      this.handleDeleteComponentClicked = __bind(this.handleDeleteComponentClicked, this);
      this.setupComponentController = __bind(this.setupComponentController, this);
      this.selectedComponentUpdated = __bind(this.selectedComponentUpdated, this);
      this.setupComponentSummaryTable = __bind(this.setupComponentSummaryTable, this);
      return ComponentBrowserController.__super__.constructor.apply(this, arguments);
    }

    ComponentBrowserController.prototype.events = {
      "click .bv_deleteComponent": "handleDeleteComponentClicked",
      "click .bv_editComponent": "handleEditComponentClicked",
      "click .bv_duplicateParent": "handleDuplicateParentClicked",
      "click .bv_confirmDeleteComponentButton": "handleConfirmDeleteComponentClicked",
      "click .bv_cancelDelete": "handleCancelDeleteClicked"
    };

    ComponentBrowserController.prototype.initialize = function() {
      var template;
      template = _.template($("#ComponentBrowserView").html());
      $(this.el).empty();
      $(this.el).html(template);
      this.searchController = new ComponentSimpleSearchController({
        model: new ComponentSearch(),
        el: this.$('.bv_componentSearchController')
      });
      this.searchController.render();
      this.searchController.on("searchReturned", this.setupComponentSummaryTable);
      return this.searchController.on("resetSearch", this.destroyComponentSummaryTable);
    };

    ComponentBrowserController.prototype.setupComponentSummaryTable = function(components) {
      $(".bv_searchingMessage").addClass("hide");
      if (components === null) {
        return this.$(".bv_errorOccurredPerformingSearch").removeClass("hide");
      } else if (components.length === 0) {
        this.$(".bv_noMatchesFoundMessage").removeClass("hide");
        return this.$(".bv_componentTableController").html("");
      } else {
        $(".bv_searchStatusIndicator").addClass("hide");
        this.$(".bv_componentTableController").removeClass("hide");
        this.componentSummaryTable = new ComponentSummaryTableController({
          collection: new ComponentList(components)
        });
        this.componentSummaryTable.on("selectedRowUpdated", this.selectedComponentUpdated);
        return $(".bv_componentTableController").html(this.componentSummaryTable.render().el);
      }
    };

    ComponentBrowserController.prototype.selectedComponentUpdated = function(batchModel) {
      return this.getSelectedComponentParent(batchModel);
    };

    ComponentBrowserController.prototype.getSelectedComponentParent = function(batchModel) {
      var batchCodeName, camelCaseLsKind, lsKind, parentCodeName;
      lsKind = batchModel.get('lsKind');
      lsKind = lsKind.replace(/(^|[^a-z0-9-])([a-z])/g, function(m, m1, m2, p) {
        return m1 + m2.toUpperCase();
      });
      lsKind = lsKind.replace(/\s/g, '');
      camelCaseLsKind = lsKind.charAt(0).toLowerCase() + lsKind.slice(1);
      batchCodeName = batchModel.get('codeName');
      parentCodeName = batchCodeName.split("-")[0];
      return $.ajax({
        type: 'GET',
        url: "/api/" + camelCaseLsKind + "Parents/codename/" + parentCodeName,
        dataType: 'json',
        error: function(err) {
          return alert('Could not get parent component');
        },
        success: (function(_this) {
          return function(json) {
            var parentModel;
            if (json.length === 0) {
              alert('Could not get parent for code in this URL, creating new one');
            } else {
              parentModel = new window[lsKind + "Parent"](json);
              parentModel.set(parentModel.parse(parentModel.attributes));
            }
            return _this.setupComponentController(lsKind, parentModel, batchCodeName, batchModel);
          };
        })(this)
      });
    };

    ComponentBrowserController.prototype.setupComponentController = function(lsKind, parentModel, batchCodeName, batchModel) {
      this.componentController = new window[lsKind + "Controller"]({
        model: parentModel,
        batchCodeName: batchCodeName,
        batchModel: batchModel,
        readOnly: true
      });
      $('.bv_componentController').html(this.componentController.render().el);
      $(".bv_componentController").removeClass("hide");
      return $(".bv_componentControllerContainer").removeClass("hide");
    };

    ComponentBrowserController.prototype.handleDeleteComponentClicked = function() {
      this.$(".bv_componentCodeName").html(this.componentController.model.get("codeName"));
      this.$(".bv_deleteButtons").removeClass("hide");
      this.$(".bv_okayButton").addClass("hide");
      this.$(".bv_errorDeletingComponentMessage").addClass("hide");
      this.$(".bv_deleteWarningMessage").removeClass("hide");
      this.$(".bv_deletingStatusIndicator").addClass("hide");
      this.$(".bv_componentDeletedSuccessfullyMessage").addClass("hide");
      $(".bv_confirmDeleteComponent").removeClass("hide");
      return $('.bv_confirmDeleteComponent').modal({
        keyboard: false,
        backdrop: true
      });
    };

    ComponentBrowserController.prototype.handleConfirmDeleteComponentClicked = function() {
      this.$(".bv_deleteWarningMessage").addClass("hide");
      this.$(".bv_deletingStatusIndicator").removeClass("hide");
      this.$(".bv_deleteButtons").addClass("hide");
      return $.ajax({
        url: "api/components/browser/" + (this.componentController.model.get("id")),
        type: 'DELETE',
        success: (function(_this) {
          return function(result) {
            _this.$(".bv_okayButton").removeClass("hide");
            _this.$(".bv_deletingStatusIndicator").addClass("hide");
            _this.$(".bv_componentDeletedSuccessfullyMessage").removeClass("hide");
            return _this.searchController.handleDoSearchClicked();
          };
        })(this),
        error: (function(_this) {
          return function(result) {
            _this.$(".bv_okayButton").removeClass("hide");
            _this.$(".bv_deletingStatusIndicator").addClass("hide");
            return _this.$(".bv_errorDeletingComponentMessage").removeClass("hide");
          };
        })(this)
      });
    };

    ComponentBrowserController.prototype.handleCancelDeleteClicked = function() {
      return this.$(".bv_confirmDeleteComponent").modal('hide');
    };

    ComponentBrowserController.prototype.handleEditComponentClicked = function() {
      return window.open("/entity/edit/codeName/" + this.componentController.batchCodeName, '_blank');
    };

    ComponentBrowserController.prototype.handleDuplicateParentClicked = function() {
      var componentKind;
      componentKind = this.componentController.model.get('lsKind');
      if (componentKind === "cationic block") {
        return window.open("/entity/copy/cationic_block/" + (this.componentController.model.get("codeName")), '_blank');
      } else if (componentKind === "linker small molecule") {
        return window.open("/entity/copy/linker_small_molecule/" + (this.componentController.model.get("codeName")), '_blank');
      } else if (componentKind === "protein") {
        return window.open("/entity/copy/protein/" + (this.componentController.model.get("codeName")), '_blank');
      } else if (componentKind === "spacer") {
        return window.open("/entity/copy/spacer/" + (this.componentController.model.get("codeName")), '_blank');
      }
    };

    ComponentBrowserController.prototype.destroyComponentSummaryTable = function() {
      if (this.componentSummaryTable != null) {
        this.componentSummaryTable.remove();
      }
      if (this.componentController != null) {
        this.componentController.remove();
      }
      $(".bv_componentController").addClass("hide");
      $(".bv_componentControllerContainer").addClass("hide");
      return $(".bv_noMatchesFoundMessage").addClass("hide");
    };

    ComponentBrowserController.prototype.render = function() {
      return this;
    };

    return ComponentBrowserController;

  })(Backbone.View);

}).call(this);
