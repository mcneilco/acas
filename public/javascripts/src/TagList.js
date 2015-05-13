(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.Tag = (function(superClass) {
    extend(Tag, superClass);

    function Tag() {
      return Tag.__super__.constructor.apply(this, arguments);
    }

    Tag.prototype.defaults = {
      tagText: ""
    };

    return Tag;

  })(Backbone.Model);

  window.TagList = (function(superClass) {
    extend(TagList, superClass);

    function TagList() {
      return TagList.__super__.constructor.apply(this, arguments);
    }

    TagList.prototype.model = Tag;

    return TagList;

  })(Backbone.Collection);

  window.TagListController = (function(superClass) {
    extend(TagListController, superClass);

    function TagListController() {
      this.handleTagsChanged = bind(this.handleTagsChanged, this);
      this.render = bind(this.render, this);
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
      var i, len, t, tagStrings, tempTags;
      tagStrings = this.$el.tagsinput('items');
      tempTags = [];
      for (i = 0, len = tagStrings.length; i < len; i++) {
        t = tagStrings[i];
        tempTags.push({
          tagText: t
        });
      }
      return this.collection.set(tempTags);
    };

    return TagListController;

  })(Backbone.View);

}).call(this);
