(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.ProtocolSearch = (function(_super) {
    __extends(ProtocolSearch, _super);

    function ProtocolSearch() {
      return ProtocolSearch.__super__.constructor.apply(this, arguments);
    }

    ProtocolSearch.prototype.defaults = {
      protocolCode: null
    };

    return ProtocolSearch;

  })(Backbone.Model);

  window.ProtocolSimpleSearchController = (function(_super) {
    __extends(ProtocolSimpleSearchController, _super);

    function ProtocolSimpleSearchController() {
      this.doSearch = __bind(this.doSearch, this);
      this.handleDoSearchClicked = __bind(this.handleDoSearchClicked, this);
      this.updateProtocolSearchTerm = __bind(this.updateProtocolSearchTerm, this);
      this.render = __bind(this.render, this);
      return ProtocolSimpleSearchController.__super__.constructor.apply(this, arguments);
    }

    ProtocolSimpleSearchController.prototype.template = _.template($("#ProtocolSimpleSearchView").html());

    ProtocolSimpleSearchController.prototype.genericSearchUrl = "/api/protocols/genericSearch/";

    ProtocolSimpleSearchController.prototype.codeNameSearchUrl = "/api/protocols/codename/";

    ProtocolSimpleSearchController.prototype.initialize = function() {
      return this.searchUrl = this.genericSearchUrl;
    };

    ProtocolSimpleSearchController.prototype.events = {
      'keyup .bv_protocolSearchTerm': 'updateProtocolSearchTerm',
      'click .bv_doSearch': 'handleDoSearchClicked'
    };

    ProtocolSimpleSearchController.prototype.render = function() {
      $(this.el).empty();
      return $(this.el).html(this.template());
    };

    ProtocolSimpleSearchController.prototype.updateProtocolSearchTerm = function(e) {
      var ENTER_KEY, protocolSearchTerm;
      ENTER_KEY = 13;
      protocolSearchTerm = $.trim(this.$(".bv_protocolSearchTerm").val());
      if (protocolSearchTerm !== "") {
        this.$(".bv_doSearch").attr("disabled", false);
        if (e.keyCode === ENTER_KEY) {
          $(':focus').blur();
          return this.handleDoSearchClicked();
        }
      } else {
        return this.$(".bv_doSearch").attr("disabled", true);
      }
    };

    ProtocolSimpleSearchController.prototype.handleDoSearchClicked = function() {
      var protocolSearchTerm;
      $(".bv_protocolTableController").addClass("hide");
      $(".bv_errorOccurredPerformingSearch").addClass("hide");
      protocolSearchTerm = $.trim(this.$(".bv_protocolSearchTerm").val());
      $(".bv_searchTerm").val("");
      if (protocolSearchTerm !== "") {
        if (this.$(".bv_clearSearchIcon").hasClass("hide")) {
          this.$(".bv_protocolSearchTerm").attr("disabled", true);
          this.$(".bv_doSearchIcon").addClass("hide");
          this.$(".bv_clearSearchIcon").removeClass("hide");
          $(".bv_searchingMessage").removeClass("hide");
          $(".bv_protocolBrowserSearchInstructions").addClass("hide");
          $(".bv_searchTerm").html(protocolSearchTerm);
          return this.doSearch(protocolSearchTerm);
        } else {
          this.$(".bv_protocolSearchTerm").val("");
          this.$(".bv_protocolSearchTerm").attr("disabled", false);
          this.$(".bv_clearSearchIcon").addClass("hide");
          this.$(".bv_doSearchIcon").removeClass("hide");
          $(".bv_searchingMessage").addClass("hide");
          $(".bv_protocolBrowserSearchInstructions").removeClass("hide");
          $(".bv_searchStatusIndicator").removeClass("hide");
          this.updateProtocolSearchTerm();
          return this.trigger("resetSearch");
        }
      }
    };

    ProtocolSimpleSearchController.prototype.doSearch = function(protocolSearchTerm) {
      this.trigger('find');
      if (protocolSearchTerm !== "") {
        return $.ajax({
          type: 'GET',
          url: this.searchUrl + protocolSearchTerm,
          dataType: "json",
          data: {
            testMode: false
          },
          success: (function(_this) {
            return function(protocol) {
              return _this.trigger("searchReturned", protocol);
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

    return ProtocolSimpleSearchController;

  })(AbstractFormController);

  window.ProtocolRowSummaryController = (function(_super) {
    __extends(ProtocolRowSummaryController, _super);

    function ProtocolRowSummaryController() {
      this.render = __bind(this.render, this);
      this.handleClick = __bind(this.handleClick, this);
      return ProtocolRowSummaryController.__super__.constructor.apply(this, arguments);
    }

    ProtocolRowSummaryController.prototype.tagName = 'tr';

    ProtocolRowSummaryController.prototype.className = 'dataTableRow';

    ProtocolRowSummaryController.prototype.events = {
      "click": "handleClick"
    };

    ProtocolRowSummaryController.prototype.handleClick = function() {
      this.trigger("gotClick", this.model);
      $(this.el).closest("table").find("tr").removeClass("info");
      return $(this.el).addClass("info");
    };

    ProtocolRowSummaryController.prototype.initialize = function() {
      return this.template = _.template($('#ProtocolRowSummaryView').html());
    };

    ProtocolRowSummaryController.prototype.render = function() {
      var toDisplay;
      toDisplay = {
        protocolName: this.model.get('lsLabels').pickBestName().get('labelText'),
        protocolCode: this.model.get('codeName'),
        protocolKind: this.model.get('lsKind'),
        recordedBy: this.model.get('recordedBy'),
        assayStage: this.model.getAssayStage().get("codeValue"),
        status: this.model.getStatus().get("codeValue"),
        experimentCount: this.model.get('experimentCount'),
        recordedDate: this.model.get("recordedDate")
      };
      $(this.el).html(this.template(toDisplay));
      return this;
    };

    return ProtocolRowSummaryController;

  })(Backbone.View);

  window.ProtocolSummaryTableController = (function(_super) {
    __extends(ProtocolSummaryTableController, _super);

    function ProtocolSummaryTableController() {
      this.render = __bind(this.render, this);
      this.selectedRowChanged = __bind(this.selectedRowChanged, this);
      return ProtocolSummaryTableController.__super__.constructor.apply(this, arguments);
    }

    ProtocolSummaryTableController.prototype.initialize = function() {};

    ProtocolSummaryTableController.prototype.selectedRowChanged = function(row) {
      return this.trigger("selectedRowUpdated", row);
    };

    ProtocolSummaryTableController.prototype.render = function() {
      this.template = _.template($('#ProtocolSummaryTableView').html());
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
            prsc = new ProtocolRowSummaryController({
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

    return ProtocolSummaryTableController;

  })(Backbone.View);

  window.ProtocolBrowserController = (function(_super) {
    __extends(ProtocolBrowserController, _super);

    function ProtocolBrowserController() {
      this.render = __bind(this.render, this);
      this.destroyProtocolSummaryTable = __bind(this.destroyProtocolSummaryTable, this);
      this.handleCreateExperimentClicked = __bind(this.handleCreateExperimentClicked, this);
      this.handleDuplicateProtocolClicked = __bind(this.handleDuplicateProtocolClicked, this);
      this.handleEditProtocolClicked = __bind(this.handleEditProtocolClicked, this);
      this.handleCancelDeleteClicked = __bind(this.handleCancelDeleteClicked, this);
      this.handleConfirmDeleteProtocolClicked = __bind(this.handleConfirmDeleteProtocolClicked, this);
      this.handleDeleteProtocolClicked = __bind(this.handleDeleteProtocolClicked, this);
      this.selectedProtocolUpdated = __bind(this.selectedProtocolUpdated, this);
      this.setupProtocolSummaryTable = __bind(this.setupProtocolSummaryTable, this);
      return ProtocolBrowserController.__super__.constructor.apply(this, arguments);
    }

    ProtocolBrowserController.prototype.events = {
      "click .bv_deleteProtocol": "handleDeleteProtocolClicked",
      "click .bv_editProtocol": "handleEditProtocolClicked",
      "click .bv_duplicateProtocol": "handleDuplicateProtocolClicked",
      "click .bv_createExperiment": "handleCreateExperimentClicked",
      "click .bv_confirmDeleteProtocolButton": "handleConfirmDeleteProtocolClicked",
      "click .bv_cancelDelete": "handleCancelDeleteClicked"
    };

    ProtocolBrowserController.prototype.initialize = function() {
      var template;
      template = _.template($("#ProtocolBrowserView").html());
      $(this.el).empty();
      $(this.el).html(template);
      this.searchController = new ProtocolSimpleSearchController({
        model: new ProtocolSearch(),
        el: this.$('.bv_protocolSearchController')
      });
      this.searchController.render();
      this.searchController.on("searchReturned", this.setupProtocolSummaryTable);
      return this.searchController.on("resetSearch", this.destroyProtocolSummaryTable);
    };

    ProtocolBrowserController.prototype.setupProtocolSummaryTable = function(protocols) {
      $(".bv_searchingMessage").addClass("hide");
      if (protocols === null) {
        return this.$(".bv_errorOccurredPerformingSearch").removeClass("hide");
      } else if (protocols.length === 0) {
        this.$(".bv_noMatchesFoundMessage").removeClass("hide");
        return this.$(".bv_protocolTableController").html("");
      } else {
        $(".bv_searchStatusIndicator").addClass("hide");
        this.$(".bv_protocolTableController").removeClass("hide");
        this.protocolSummaryTable = new ProtocolSummaryTableController({
          collection: new ProtocolList(protocols)
        });
        this.protocolSummaryTable.on("selectedRowUpdated", this.selectedProtocolUpdated);
        return $(".bv_protocolTableController").html(this.protocolSummaryTable.render().el);
      }
    };

    ProtocolBrowserController.prototype.selectedProtocolUpdated = function(protocol) {
      this.trigger("selectedProtocolUpdated");
      if (protocol.get('lsKind') === "Bio Activity") {
        this.protocolController = new PrimaryScreenProtocolController({
          model: new PrimaryScreenProtocol(protocol.attributes)
        });
      } else {
        this.protocolController = new ProtocolBaseController({
          model: protocol
        });
      }
      $('.bv_protocolBaseController').html(this.protocolController.render().el);
      this.protocolController.displayInReadOnlyMode();
      $(".bv_protocolBaseController").removeClass("hide");
      return $(".bv_protocolBaseControllerContainer").removeClass("hide");
    };

    ProtocolBrowserController.prototype.handleDeleteProtocolClicked = function() {
      this.$(".bv_protocolCodeName").html(this.protocolController.model.get("codeName"));
      this.$(".bv_deleteButtons").removeClass("hide");
      this.$(".bv_okayButton").addClass("hide");
      this.$(".bv_errorDeletingProtocolMessage").addClass("hide");
      this.$(".bv_deleteWarningMessage").removeClass("hide");
      this.$(".bv_deletingStatusIndicator").addClass("hide");
      this.$(".bv_protocolDeletedSuccessfullyMessage").addClass("hide");
      $(".bv_confirmDeleteProtocol").removeClass("hide");
      return $('.bv_confirmDeleteProtocol').modal({
        keyboard: false,
        backdrop: true
      });
    };

    ProtocolBrowserController.prototype.handleConfirmDeleteProtocolClicked = function() {
      this.$(".bv_deleteWarningMessage").addClass("hide");
      this.$(".bv_deletingStatusIndicator").removeClass("hide");
      this.$(".bv_deleteButtons").addClass("hide");
      return $.ajax({
        url: "api/protocols/browser/" + (this.protocolController.model.get("id")),
        type: 'DELETE',
        success: (function(_this) {
          return function(result) {
            _this.$(".bv_okayButton").removeClass("hide");
            _this.$(".bv_deletingStatusIndicator").addClass("hide");
            _this.$(".bv_protocolDeletedSuccessfullyMessage").removeClass("hide");
            return _this.searchController.handleDoSearchClicked();
          };
        })(this),
        error: (function(_this) {
          return function(result) {
            _this.$(".bv_okayButton").removeClass("hide");
            _this.$(".bv_deletingStatusIndicator").addClass("hide");
            return _this.$(".bv_errorDeletingProtocolMessage").removeClass("hide");
          };
        })(this)
      });
    };

    ProtocolBrowserController.prototype.handleCancelDeleteClicked = function() {
      return this.$(".bv_confirmDeleteProtocol").modal('hide');
    };

    ProtocolBrowserController.prototype.handleEditProtocolClicked = function() {
      return window.open("/entity/edit/codeName/" + (this.protocolController.model.get("codeName")), '_blank');
    };

    ProtocolBrowserController.prototype.handleDuplicateProtocolClicked = function() {
      var protocolKind;
      protocolKind = this.protocolController.model.get('lsKind');
      if (protocolKind === "Bio Activity") {
        return window.open("/entity/copy/primary_screen_protocol/" + (this.protocolController.model.get("codeName")), '_blank');
      } else {
        return window.open("/entity/copy/protocol_base/" + (this.protocolController.model.get("codeName")), '_blank');
      }
    };

    ProtocolBrowserController.prototype.handleCreateExperimentClicked = function() {
      var protocolKind;
      protocolKind = this.protocolController.model.get('lsKind');
      if (protocolKind === "Bio Activity") {
        return window.open("/primary_screen_experiment/createFrom/" + (this.protocolController.model.get("codeName")), '_blank');
      } else {
        return window.open("/experiment_base/createFrom/" + (this.protocolController.model.get("codeName")), '_blank');
      }
    };

    ProtocolBrowserController.prototype.destroyProtocolSummaryTable = function() {
      if (this.protocolSummaryTable != null) {
        this.protocolSummaryTable.remove();
      }
      if (this.protocolController != null) {
        this.protocolController.remove();
      }
      $(".bv_protocolBaseController").addClass("hide");
      $(".bv_protocolBaseControllerContainer").addClass("hide");
      return $(".bv_noMatchesFoundMessage").addClass("hide");
    };

    ProtocolBrowserController.prototype.render = function() {
      return this;
    };

    return ProtocolBrowserController;

  })(Backbone.View);

}).call(this);
