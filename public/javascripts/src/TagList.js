(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.Tag = (function(_super) {
    __extends(Tag, _super);

    function Tag() {
      return Tag.__super__.constructor.apply(this, arguments);
    }

    Tag.prototype.defaults = {
      tagText: ""
    };

    return Tag;

  })(Backbone.Model);

  window.TagList = (function(_super) {
    __extends(TagList, _super);

    function TagList() {
      return TagList.__super__.constructor.apply(this, arguments);
    }

    TagList.prototype.model = Tag;

    return TagList;

  })(Backbone.Collection);

  window.TagListController = (function(_super) {
    __extends(TagListController, _super);

    function TagListController() {
      this.handleTagsChanged = __bind(this.handleTagsChanged, this);
      this.render = __bind(this.render, this);
      return TagListController.__super__.constructor.apply(this, arguments);
    }

    TagListController.prototype.events = {
      'focusout': 'handleTagsChanged'
    };

    TagListController.prototype.render = function() {
      var tagStr;
      this.$el.tagsinput('items');
      tagStr = "";
      this.collection.each((function(_this) {
        return function(tag) {
          return tagStr += tag.get('tagText') + ",";
        };
      })(this));
      this.$el.tagsinput('add', tagStr.slice(0, -1));
      return this;
    };

    TagListController.prototype.handleTagsChanged = function() {
      var t, tagStrings, tempTags, _i, _len;
      tagStrings = this.$el.tagsinput('items');
      tempTags = [];
      for (_i = 0, _len = tagStrings.length; _i < _len; _i++) {
        t = tagStrings[_i];
        tempTags.push({
          tagText: t
        });
      }
      return this.collection.set(tempTags);
    };

    return TagListController;

  })(Backbone.View);

}).call(this);
