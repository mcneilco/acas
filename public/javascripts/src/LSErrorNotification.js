(function() {
  var _ref, _ref1, _ref10, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8, _ref9,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.LSNotificationMessageModel = (function(_super) {
    __extends(LSNotificationMessageModel, _super);

    function LSNotificationMessageModel() {
      _ref = LSNotificationMessageModel.__super__.constructor.apply(this, arguments);
      return _ref;
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
      _ref1 = LSNotificatioMessageCollection.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    LSNotificatioMessageCollection.prototype.model = LSNotificationMessageModel;

    return LSNotificatioMessageCollection;

  })(Backbone.Collection);

  window.LSAbstractNotificationCounterController = (function(_super) {
    __extends(LSAbstractNotificationCounterController, _super);

    function LSAbstractNotificationCounterController() {
      _ref2 = LSAbstractNotificationCounterController.__super__.constructor.apply(this, arguments);
      return _ref2;
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
      _ref3 = LSErrorNotificationCounterController.__super__.constructor.apply(this, arguments);
      return _ref3;
    }

    LSErrorNotificationCounterController.prototype.templateTypeId = '#LSErrorNotificationCount';

    LSErrorNotificationCounterController.prototype.messageString = 'error';

    return LSErrorNotificationCounterController;

  })(window.LSAbstractNotificationCounterController);

  window.LSWarningNotificationCounterController = (function(_super) {
    __extends(LSWarningNotificationCounterController, _super);

    function LSWarningNotificationCounterController() {
      _ref4 = LSWarningNotificationCounterController.__super__.constructor.apply(this, arguments);
      return _ref4;
    }

    LSWarningNotificationCounterController.prototype.templateTypeId = '#LSWarningNotificationCount';

    LSWarningNotificationCounterController.prototype.messageString = 'warning';

    return LSWarningNotificationCounterController;

  })(window.LSAbstractNotificationCounterController);

  window.LSInfoNotificationCounterController = (function(_super) {
    __extends(LSInfoNotificationCounterController, _super);

    function LSInfoNotificationCounterController() {
      _ref5 = LSInfoNotificationCounterController.__super__.constructor.apply(this, arguments);
      return _ref5;
    }

    LSInfoNotificationCounterController.prototype.templateTypeId = '#LSInfoNotificationCount';

    LSInfoNotificationCounterController.prototype.messageString = 'status update';

    return LSInfoNotificationCounterController;

  })(window.LSAbstractNotificationCounterController);

  window.LSMessageController = (function(_super) {
    __extends(LSMessageController, _super);

    function LSMessageController() {
      _ref6 = LSMessageController.__super__.constructor.apply(this, arguments);
      return _ref6;
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
      _ref7 = LSErrorController.__super__.constructor.apply(this, arguments);
      return _ref7;
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
      _ref8 = LSWarningController.__super__.constructor.apply(this, arguments);
      return _ref8;
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
      _ref9 = LSInfoController.__super__.constructor.apply(this, arguments);
      return _ref9;
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
      this.toggleShowNotificationMessages = __bind(this.toggleShowNotificationMessages, this);
      _ref10 = LSNotificationController.__super__.constructor.apply(this, arguments);
      return _ref10;
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
        el: '.bv_errorNotificationMessages',
        badgeEl: this.$('.bv_errorNotificationCountContainer'),
        notificationsList: this.errorList
      });
      this.warningList = new LSNotificatioMessageCollection;
      this.warningController = new LSWarningController({
        el: '.bv_warningNotificationMessages',
        badgeEl: this.$('.bv_warningNotificationCountContainer'),
        notificationsList: this.warningList
      });
      this.infoList = new LSNotificatioMessageCollection;
      return this.infoController = new LSInfoController({
        el: '.bv_infoNotificationMessages',
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
      var _this = this;
      return _.each(notes, function(note) {
        note.owner = owner;
        return _this.addNotification(note);
      });
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
