(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.LSNotificationMessageModel = (function(_super) {
    __extends(LSNotificationMessageModel, _super);

    function LSNotificationMessageModel() {
      return LSNotificationMessageModel.__super__.constructor.apply(this, arguments);
    }

    LSNotificationMessageModel.prototype.defaults = {
      content: '',
      owner: 'system',
      message: '',
      errorLevel: 'error'
    };

    return LSNotificationMessageModel;

  })(Backbone.Model);

  window.LSNotificatioMessageCollection = (function(_super) {
    __extends(LSNotificatioMessageCollection, _super);

    function LSNotificatioMessageCollection() {
      return LSNotificatioMessageCollection.__super__.constructor.apply(this, arguments);
    }

    LSNotificatioMessageCollection.prototype.model = LSNotificationMessageModel;

    return LSNotificatioMessageCollection;

  })(Backbone.Collection);

  window.LSAbstractNotificationCounterController = (function(_super) {
    __extends(LSAbstractNotificationCounterController, _super);

    function LSAbstractNotificationCounterController() {
      return LSAbstractNotificationCounterController.__super__.constructor.apply(this, arguments);
    }

    LSAbstractNotificationCounterController.prototype.templateTypeId = null;

    LSAbstractNotificationCounterController.prototype.tagName = 'span';

    LSAbstractNotificationCounterController.prototype.count = null;

    LSAbstractNotificationCounterController.prototype.container = null;

    LSAbstractNotificationCounterController.prototype.notificationsList = null;

    LSAbstractNotificationCounterController.prototype.initialize = function() {
      _.bindAll(this, 'render');
      this.notificationsList = this.options.notificationsList;
      this.notificationsList.bind('add remove', this.render);
      return this.container = this.options.container;
    };

    LSAbstractNotificationCounterController.prototype.render = function() {
      var counterPopoverText, template;
      template = _.template($(this.templateTypeId).html(), {
        count: this.notificationsList.length
      });
      $(this.el).html(template);
      counterPopoverText = "" + this.notificationsList.length + " " + this.messageString;
      if (this.notificationsList.length !== 1) {
        counterPopoverText += "s";
      }
      this.$('.bv_notificationsCount').tooltip({
        title: counterPopoverText
      });
      return this;
    };

    return LSAbstractNotificationCounterController;

  })(Backbone.View);

  window.LSErrorNotificationCounterController = (function(_super) {
    __extends(LSErrorNotificationCounterController, _super);

    function LSErrorNotificationCounterController() {
      return LSErrorNotificationCounterController.__super__.constructor.apply(this, arguments);
    }

    LSErrorNotificationCounterController.prototype.templateTypeId = '#LSErrorNotificationCount';

    LSErrorNotificationCounterController.prototype.messageString = 'error';

    return LSErrorNotificationCounterController;

  })(window.LSAbstractNotificationCounterController);

  window.LSWarningNotificationCounterController = (function(_super) {
    __extends(LSWarningNotificationCounterController, _super);

    function LSWarningNotificationCounterController() {
      return LSWarningNotificationCounterController.__super__.constructor.apply(this, arguments);
    }

    LSWarningNotificationCounterController.prototype.templateTypeId = '#LSWarningNotificationCount';

    LSWarningNotificationCounterController.prototype.messageString = 'warning';

    return LSWarningNotificationCounterController;

  })(window.LSAbstractNotificationCounterController);

  window.LSInfoNotificationCounterController = (function(_super) {
    __extends(LSInfoNotificationCounterController, _super);

    function LSInfoNotificationCounterController() {
      return LSInfoNotificationCounterController.__super__.constructor.apply(this, arguments);
    }

    LSInfoNotificationCounterController.prototype.templateTypeId = '#LSInfoNotificationCount';

    LSInfoNotificationCounterController.prototype.messageString = 'status update';

    return LSInfoNotificationCounterController;

  })(window.LSAbstractNotificationCounterController);

  window.LSMessageController = (function(_super) {
    __extends(LSMessageController, _super);

    function LSMessageController() {
      return LSMessageController.__super__.constructor.apply(this, arguments);
    }

    LSMessageController.prototype.message = null;

    LSMessageController.prototype.alertType = null;

    LSMessageController.prototype.tagName = 'div';

    LSMessageController.prototype.initialize = function() {
      _.bindAll(this, 'render');
      this.message = this.options.message;
      return this.alertType = this.options.alertType;
    };

    LSMessageController.prototype.render = function() {
      var template;
      template = _.template($(this.alertType).html(), {
        message: this.message
      });
      $(this.el).html(template);
      return this;
    };

    return LSMessageController;

  })(Backbone.View);

  window.LSErrorController = (function(_super) {
    __extends(LSErrorController, _super);

    function LSErrorController() {
      return LSErrorController.__super__.constructor.apply(this, arguments);
    }

    LSErrorController.prototype.countController = null;

    LSErrorController.prototype.notificationsList = null;

    LSErrorController.prototype.badgeEl = null;

    LSErrorController.prototype.initialize = function() {
      _.bindAll(this, 'render');
      this.notificationsList = this.options.notificationsList;
      this.notificationsList.bind('add remove reset', this.render);
      this.badgeEl = this.options.badgeEl;
      this.countController = new LSErrorNotificationCounterController({
        el: this.badgeEl,
        notificationsList: this.notificationsList
      });
      return this.countController.render();
    };

    LSErrorController.prototype.render = function() {
      var self;
      $(this.el).empty();
      this.countController.render();
      self = this;
      return this.notificationsList.each(function(notification) {
        return $(self.el).append(new LSMessageController({
          alertType: "#LSErrorNotificationMessage",
          message: notification.get('content')
        }).render().el);
      });
    };

    return LSErrorController;

  })(Backbone.View);

  window.LSWarningController = (function(_super) {
    __extends(LSWarningController, _super);

    function LSWarningController() {
      return LSWarningController.__super__.constructor.apply(this, arguments);
    }

    LSWarningController.prototype.countController = null;

    LSWarningController.prototype.notificationsList = null;

    LSWarningController.prototype.badgeEl = null;

    LSWarningController.prototype.initialize = function() {
      _.bindAll(this, 'render');
      this.notificationsList = this.options.notificationsList;
      this.notificationsList.bind('add remove reset', this.render);
      this.badgeEl = this.options.badgeEl;
      this.countController = new LSWarningNotificationCounterController({
        el: this.badgeEl,
        notificationsList: this.notificationsList
      });
      return this.countController.render();
    };

    LSWarningController.prototype.render = function() {
      var self;
      $(this.el).empty();
      self = this;
      this.countController.render();
      return this.notificationsList.each(function(notification) {
        return $(self.el).append(new LSMessageController({
          alertType: "#LSWarningNotificationMessage",
          message: notification.get('content')
        }).render().el);
      });
    };

    return LSWarningController;

  })(Backbone.View);

  window.LSInfoController = (function(_super) {
    __extends(LSInfoController, _super);

    function LSInfoController() {
      return LSInfoController.__super__.constructor.apply(this, arguments);
    }

    LSInfoController.prototype.countController = null;

    LSInfoController.prototype.notificationsList = null;

    LSInfoController.prototype.badgeEl = null;

    LSInfoController.prototype.initialize = function() {
      _.bindAll(this, 'render');
      this.notificationsList = this.options.notificationsList;
      this.notificationsList.bind('add remove reset', this.render);
      this.badgeEl = this.options.badgeEl;
      this.countController = new LSInfoNotificationCounterController({
        el: this.badgeEl,
        notificationsList: this.notificationsList
      });
      return this.countController.render();
    };

    LSInfoController.prototype.render = function() {
      var self;
      $(this.el).empty();
      self = this;
      this.countController.render();
      return this.notificationsList.each(function(notification) {
        return $(self.el).append(new LSMessageController({
          alertType: "#LSInfoNotificationMessage",
          message: notification.get('content')
        }).render().el);
      });
    };

    return LSInfoController;

  })(Backbone.View);

  window.LSNotificationController = (function(_super) {
    __extends(LSNotificationController, _super);

    function LSNotificationController() {
      this.clearAllNotificiations = __bind(this.clearAllNotificiations, this);
      this.toggleShowNotificationMessages = __bind(this.toggleShowNotificationMessages, this);
      return LSNotificationController.__super__.constructor.apply(this, arguments);
    }

    LSNotificationController.prototype.errorController = null;

    LSNotificationController.prototype.warningController = null;

    LSNotificationController.prototype.infoController = null;

    LSNotificationController.prototype.errorList = null;

    LSNotificationController.prototype.warningList = null;

    LSNotificationController.prototype.infoList = null;

    LSNotificationController.prototype.showPreview = true;

    LSNotificationController.prototype.events = {
      'click .bv_notificationCountContainer': 'toggleShowNotificationMessages'
    };

    LSNotificationController.prototype.initialize = function() {
      _.bindAll(this, 'render', 'addError', 'getErrorCount', 'getWarningCount', 'getInfoCount', 'addNotification', 'hideMessagePreview', 'hmp');
      if (this.options.showPreview != null) {
        this.showPreview = this.options.showPreview;
      }
      this.render();
      this.errorList = new LSNotificatioMessageCollection;
      this.errorController = new LSErrorController({
        el: this.$('.bv_errorNotificationMessages'),
        badgeEl: this.$('.bv_errorNotificationCountContainer'),
        notificationsList: this.errorList
      });
      this.warningList = new LSNotificatioMessageCollection;
      this.warningController = new LSWarningController({
        el: this.$('.bv_warningNotificationMessages'),
        badgeEl: this.$('.bv_warningNotificationCountContainer'),
        notificationsList: this.warningList
      });
      this.infoList = new LSNotificatioMessageCollection;
      return this.infoController = new LSInfoController({
        el: this.$('.bv_infoNotificationMessages'),
        badgeEl: this.$('.bv_infoNotificationCountContainer'),
        notificationsList: this.infoList
      });
    };

    LSNotificationController.prototype.addNotification = function(notification) {
      this.$('.bv_notificationMessagePreview').html(notification.message);
      switch (notification.errorLevel) {
        case "error":
          return this.addError(notification.message);
        case "warning":
          return this.addWarning(notification.message);
        case "info":
          return this.addInfo(notification.message);
      }
    };

    LSNotificationController.prototype.addNotifications = function(owner, notes) {
      return _.each(notes, (function(_this) {
        return function(note) {
          note.owner = owner;
          return _this.addNotification(note);
        };
      })(this));
    };

    LSNotificationController.prototype.addError = function(message) {
      this.$('.bv_notificationMessagePreview').hide();
      this.$('.bv_notificationMessagePreview').html(message);
      if (this.showPreview) {
        this.$('.bv_notificationMessagePreview').show("slide", this.hideMessagePreview);
      }
      return this.errorController.notificationsList.add(new LSNotificationMessageModel({
        content: message
      }));
    };

    LSNotificationController.prototype.getErrorCount = function() {
      return this.errorController.notificationsList.size();
    };

    LSNotificationController.prototype.addWarning = function(message) {
      this.$('.bv_notificationMessagePreview').hide();
      this.$('.bv_notificationMessagePreview').html(message);
      if (this.showPreview) {
        this.$('.bv_notificationMessagePreview').show("slide", this.hideMessagePreview);
      }
      return this.warningController.notificationsList.add(new LSNotificationMessageModel({
        content: message
      }));
    };

    LSNotificationController.prototype.getWarningCount = function() {
      return this.warningController.notificationsList.size();
    };

    LSNotificationController.prototype.addInfo = function(message) {
      var self;
      self = this;
      this.$('.bv_notificationMessagePreview').hide();
      this.$('.bv_notificationMessagePreview').html(message);
      if (this.showPreview) {
        this.$('.bv_notificationMessagePreview').show("slide", this.hideMessagePreview);
      }
      return this.infoController.notificationsList.add(new LSNotificationMessageModel({
        content: message
      }));
    };

    LSNotificationController.prototype.hideMessagePreview = function() {
      return setTimeout(this.hmp, 5000);
    };

    LSNotificationController.prototype.hmp = function() {
      return this.$(".bv_notificationMessagePreview").fadeOut();
    };

    LSNotificationController.prototype.toggleShowNotificationMessages = function() {
      return this.$('.bv_notificationMessages').toggle();
    };

    LSNotificationController.prototype.getInfoCount = function() {
      return this.infoController.notificationsList.size();
    };

    LSNotificationController.prototype.clearAllNotificiations = function() {
      this.infoList.reset();
      this.warningList.reset();
      return this.errorList.reset();
    };

    LSNotificationController.prototype.render = function() {
      var template;
      $(this.el).empty;
      template = _.template($("#LSNotificationView").html());
      $(this.el).html(template);
      this.$('.bv_notificationCountContainer').tooltip({
        title: 'click to expand notification messages'
      });
      return this;
    };

    return LSNotificationController;

  })(Backbone.View);

}).call(this);
