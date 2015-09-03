(function() {
  var isObject, recursivelyIterateAndDisplayValues,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.AdminPanel = (function(superClass) {
    extend(AdminPanel, superClass);

    function AdminPanel() {
      return AdminPanel.__super__.constructor.apply(this, arguments);
    }

    return AdminPanel;

  })(Backbone.Model);

  window.AdminPanelController = (function(superClass) {
    extend(AdminPanelController, superClass);

    function AdminPanelController() {
      this.handleConnectionFailure = bind(this.handleConnectionFailure, this);
      this.handleConnectionSuccess = bind(this.handleConnectionSuccess, this);
      this.showConnectionStatus = bind(this.showConnectionStatus, this);
      this.render = bind(this.render, this);
      return AdminPanelController.__super__.constructor.apply(this, arguments);
    }

    AdminPanelController.prototype.template = _.template($("#AdminPanelView").html());

    AdminPanelController.prototype.initialize = function() {
      this.errorOwnerName = 'AdminPanelController';
      if (this.model == null) {
        this.model = new AdminPanel();
      }
      return this.setBindings();
    };

    AdminPanelController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      this.showConnectionStatus();
      setInterval(this.showConnectionStatus, 5000);
      this.$('.bv_checkConnection').hide();
      recursivelyIterateAndDisplayValues(window.conf);
      return this;
    };

    AdminPanelController.prototype.showConnectionStatus = function() {
      return $.ajax({
        type: 'GET',
        timeout: 2000,
        url: "/api/codetables/user well flags/flag observation",
        success: this.handleConnectionSuccess,
        error: this.handleConnectionFailure
      });
    };

    AdminPanelController.prototype.handleConnectionSuccess = function(data, status) {
      this.$('.bv_connectionStatus').addClass('bv_statusConnected');
      this.$('.bv_connectionStatus').removeClass('bv_statusDisconnected');
      this.$('.bv_connectionStatus').html("connected");
      return this.$('.bv_checkConnection').hide();
    };

    AdminPanelController.prototype.handleConnectionFailure = function() {
      this.$('.bv_connectionStatus').addClass('bv_statusDisconnected');
      this.$('.bv_connectionStatus').removeClass('bv_statusConnected');
      this.$('.bv_connectionStatus').html("disconnected");
      return this.$('.bv_checkConnection').show();
    };

    return AdminPanelController;

  })(AbstractFormController);

  recursivelyIterateAndDisplayValues = function(dict) {
    var keys;
    keys = Object.keys(dict);
    return _.each(keys, function(key) {
      if (isObject(dict[key])) {
        recursivelyIterateAndDisplayValues(dict[key]);
      } else {

      }
      if (typeof dict[key] !== "object") {
        return this.$('.bv_configProperties').append("<b>" + key + ":</b> " + dict[key] + "<br />");
      }
    });
  };

  isObject = function(value) {
    if ((value != null) && (typeof value === "object") && !(Array.isArray(value))) {
      return true;
    } else {
      return false;
    }
  };

}).call(this);
