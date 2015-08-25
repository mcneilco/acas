(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.ProtocolSearch = (function(superClass) {
    extend(ProtocolSearch, superClass);

    function ProtocolSearch() {
      return ProtocolSearch.__super__.constructor.apply(this, arguments);
    }

    ProtocolSearch.prototype.defaults = {
      protocolCode: null
    };

    return ProtocolSearch;

  })(Backbone.Model);

  window.ProtocolSimpleSearchController = (function(superClass) {
    extend(ProtocolSimpleSearchController, superClass);

    function ProtocolSimpleSearchController() {
      this.doSearch = bind(this.doSearch, this);
      this.handleDoSearchClicked = bind(this.handleDoSearchClicked, this);
      this.updateProtocolSearchTerm = bind(this.updateProtocolSearchTerm, this);
      this.render = bind(this.render, this);
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
      $(".bv_protSearchTerm").val("");
      if (protocolSearchTerm !== "") {
        $(".bv_noMatchesFoundMessage").addClass("hide");
        $(".bv_protocolBrowserSearchInstructions").addClass("hide");
        $(".bv_searchProtocolsStatusIndicator").removeClass("hide");
        if (!window.conf.browser.enableSearchAll && protocolSearchTerm === "*") {
          return $(".bv_moreSpecificProtocolSearchNeeded").removeClass("hide");
        } else {
          $(".bv_searchingProtocolsMessage").removeClass("hide");
          $(".bv_protSearchTerm").html(protocolSearchTerm);
          $(".bv_moreSpecificProtocolSearchNeeded").addClass("hide");
          return this.doSearch(protocolSearchTerm);
        }
      }
    };

    ProtocolSimpleSearchController.prototype.doSearch = function(protocolSearchTerm) {
      this.trigger('find');
      this.$(".bv_protocolSearchTerm").attr("disabled", true);
      this.$(".bv_doSearch").attr("disabled", true);
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
          })(this),
          complete: (function(_this) {
            return function() {
              _this.$(".bv_protocolSearchTerm").attr("disabled", false);
              return _this.$(".bv_doSearch").attr("disabled", false);
            };
          })(this)
        });
      }
    };

    return ProtocolSimpleSearchController;

  })(AbstractFormController);

  window.ProtocolRowSummaryController = (function(superClass) {
    extend(ProtocolRowSummaryController, superClass);

    function ProtocolRowSummaryController() {
      this.render = bind(this.render, this);
      this.handleClick = bind(this.handleClick, this);
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
      var date, toDisplay;
      date = this.model.getCreationDate();
      if (date.isNew()) {
        date = "not recorded";
      } else {
        date = UtilityFunctions.prototype.convertMSToYMDDate(date.get('dateValue'));
      }
      toDisplay = {
        protocolName: this.model.get('lsLabels').pickBestName().get('labelText'),
        protocolCode: this.model.get('codeName'),
        protocolKind: this.model.get('lsKind'),
        scientist: this.model.getScientist().get('codeValue'),
        assayStage: this.model.getAssayStage().get("codeValue"),
        status: this.model.getStatus().get("codeValue"),
        experimentCount: this.model.get('experimentCount'),
        creationDate: date
      };
      $(this.el).html(this.template(toDisplay));
      return this;
    };

    return ProtocolRowSummaryController;

  })(Backbone.View);

  window.ProtocolSummaryTableController = (function(superClass) {
    extend(ProtocolSummaryTableController, superClass);

    function ProtocolSummaryTableController() {
      this.render = bind(this.render, this);
      this.selectedRowChanged = bind(this.selectedRowChanged, this);
      return ProtocolSummaryTableController.__super__.constructor.apply(this, arguments);
    }

    ProtocolSummaryTableController.prototype.initialize = function() {};

    ProtocolSummaryTableController.prototype.selectedRowChanged = function(row) {
      return this.trigger("selectedRowUpdated", row);
    };

    ProtocolSummaryTableController.prototype.render = function() {
      this.template = _.template($('#ProtocolSummaryTableView').html());
      $(this.el).html(this.template);
      if (this.collection.models.length === 0) {
        this.$(".bv_noMatchesFoundMessage").removeClass("hide");
      } else {
        this.$(".bv_noMatchesFoundMessage").addClass("hide");
        this.collection.each((function(_this) {
          return function(prot) {
            hideStatusesList;
            var hideStatusesList, prsc, ref;
            if (((ref = window.conf.entity) != null ? ref.hideStatuses : void 0) != null) {
              hideStatusesList = window.conf.entity.hideStatuses;
            }
            if (!((hideStatusesList != null) && hideStatusesList.length > 0 && hideStatusesList.indexOf(prot.getStatus().get('codeValue')) > -1 && !UtilityFunctions.prototype.testUserHasRole(window.AppLaunchParams.loginUser, ["admin"]))) {
              prsc = new ProtocolRowSummaryController({
                model: prot
              });
              prsc.on("gotClick", _this.selectedRowChanged);
              return _this.$("tbody").append(prsc.render().el);
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

    return ProtocolSummaryTableController;

  })(Backbone.View);

  window.ProtocolBrowserController = (function(superClass) {
    extend(ProtocolBrowserController, superClass);

    function ProtocolBrowserController() {
      this.render = bind(this.render, this);
      this.destroyProtocolSummaryTable = bind(this.destroyProtocolSummaryTable, this);
      this.handleCreateExperimentClicked = bind(this.handleCreateExperimentClicked, this);
      this.handleDuplicateProtocolClicked = bind(this.handleDuplicateProtocolClicked, this);
      this.handleEditProtocolClicked = bind(this.handleEditProtocolClicked, this);
      this.handleCancelDeleteClicked = bind(this.handleCancelDeleteClicked, this);
      this.handleConfirmDeleteProtocolClicked = bind(this.handleConfirmDeleteProtocolClicked, this);
      this.handleDeleteProtocolClicked = bind(this.handleDeleteProtocolClicked, this);
      this.selectedProtocolUpdated = bind(this.selectedProtocolUpdated, this);
      this.setupProtocolSummaryTable = bind(this.setupProtocolSummaryTable, this);
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
      return this.searchController.on("searchReturned", this.setupProtocolSummaryTable);
    };

    ProtocolBrowserController.prototype.setupProtocolSummaryTable = function(protocols) {
      this.destroyProtocolSummaryTable();
      $(".bv_searchingProtocolsMessage").addClass("hide");
      if (protocols === null) {
        return this.$(".bv_errorOccurredPerformingSearch").removeClass("hide");
      } else if (protocols.length === 0) {
        this.$(".bv_noMatchesFoundMessage").removeClass("hide");
        return this.$(".bv_protocolTableController").html("");
      } else {
        $(".bv_searchProtocolsStatusIndicator").addClass("hide");
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
          model: new PrimaryScreenProtocol(protocol.attributes),
          readOnly: true
        });
      } else {
        this.protocolController = new ProtocolBaseController({
          model: protocol,
          readOnly: true
        });
      }
      $('.bv_protocolBaseController').html(this.protocolController.render().el);
      $(".bv_protocolBaseController").removeClass("hide");
      $(".bv_protocolBaseControllerContainer").removeClass("hide");
      if (protocol.getStatus().get('codeValue') === "deleted") {
        this.$('.bv_deleteProtocol').hide();
        this.$('.bv_editProtocol').hide();
        return this.$('.bv_duplicateProtocol').hide();
      } else {
        this.$('.bv_editProtocol').show();
        this.$('.bv_duplicateProtocol').show();
        return this.$('.bv_deleteProtocol').show();
      }
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
        url: "/api/protocols/browser/" + (this.protocolController.model.get("id")),
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
