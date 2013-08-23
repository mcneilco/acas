(function() {
  var _ref, _ref1,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.Label = (function(_super) {
    __extends(Label, _super);

    function Label() {
      _ref = Label.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Label.prototype.defaults = {
      lsType: "name",
      lsKind: '',
      labelText: '',
      ignored: false,
      preferred: false,
      recordedDate: "",
      recordedBy: "",
      physicallyLabled: false,
      imageFile: null
    };

    return Label;

  })(Backbone.Model);

  window.LabelList = (function(_super) {
    __extends(LabelList, _super);

    function LabelList() {
      _ref1 = LabelList.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    LabelList.prototype.model = Label;

    LabelList.prototype.getCurrent = function() {
      return this.filter(function(lab) {
        return !(lab.get('ignored'));
      });
    };

    LabelList.prototype.getNames = function() {
      return _.filter(this.getCurrent(), function(lab) {
        return lab.get('lsType') === "name";
      });
    };

    LabelList.prototype.getPreferred = function() {
      return _.filter(this.getCurrent(), function(lab) {
        return lab.get('preferred');
      });
    };

    LabelList.prototype.pickBestLabel = function() {
      var bestLabel, current, names, preferred;

      preferred = this.getPreferred();
      if (preferred.length > 0) {
        bestLabel = _.max(preferred, function(lab) {
          var rd;

          rd = lab.get('recordedDate');
          if (rd === "") {
            return rd;
          } else {
            return -1;
          }
        });
      } else {
        names = this.getNames();
        if (names.length > 0) {
          bestLabel = _.max(names, function(lab) {
            var rd;

            rd = lab.get('recordedDate');
            if (rd === "") {
              return rd;
            } else {
              return -1;
            }
          });
        } else {
          current = this.getCurrent();
          bestLabel = _.max(current, function(lab) {
            var rd;

            rd = lab.get('recordedDate');
            if (rd === "") {
              return rd;
            } else {
              return -1;
            }
          });
        }
      }
      return bestLabel;
    };

    LabelList.prototype.pickBestName = function() {
      var bestLabel, preferredNames;

      preferredNames = _.filter(this.getCurrent(), function(lab) {
        return lab.get('preferred') && (lab.get('lsType') === "name");
      });
      bestLabel = _.max(preferredNames, function(lab) {
        var rd;

        rd = lab.get('recordedDate');
        if (rd === "") {
          return rd;
        } else {
          return -1;
        }
      });
      return bestLabel;
    };

    LabelList.prototype.setBestName = function(label) {
      var currentName;

      label.set({
        lsType: 'name',
        preferred: true,
        ignored: false
      });
      currentName = this.pickBestName();
      if (currentName != null) {
        if (currentName.isNew()) {
          return currentName.set({
            labelText: label.get('labelText'),
            recordedBy: label.get('recordedBy'),
            recordedDate: label.get('recordedDate')
          });
        } else {
          currentName.set({
            ignored: true
          });
          return this.add(label);
        }
      } else {
        return this.add(label);
      }
    };

    return LabelList;

  })(Backbone.Collection);

}).call(this);
