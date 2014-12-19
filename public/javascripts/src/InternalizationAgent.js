(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.InternalizationAgentParent = (function(_super) {
    __extends(InternalizationAgentParent, _super);

    function InternalizationAgentParent() {
      return InternalizationAgentParent.__super__.constructor.apply(this, arguments);
    }

    InternalizationAgentParent.prototype.className = "internalization agent parent";

    InternalizationAgentParent.prototype.initialize = function() {
      this.set({
        lsType: "parent",
        lsKind: "internalization agent"
      });
      return InternalizationAgentParent.__super__.initialize.call(this);
    };

    InternalizationAgentParent.prototype.lsProperties = {
      defaultLabels: [
        {
          key: 'internalization agent name',
          type: 'name',
          kind: 'internalization agent name',
          preferred: true
        }
      ],
      defaultValues: [
        {
          key: 'internalization agent type',
          stateType: "parent attributes",
          stateKind: 'internalization agent parent attributes',
          type: 'codeValue',
          kind: 'internalization agent type'
        }, {
          key: 'conjugation type',
          stateType: 'parent attributes',
          stateKind: 'internalization agent parent attributes',
          type: 'codeValue',
          kind: 'conjugation type'
        }, {
          key: 'conjugation site',
          stateType: 'parent attributes',
          stateKind: 'internalization agent parent attributes',
          type: 'codeValue',
          kind: 'conjugation site'
        }, {
          key: 'protein aa sequence',
          stateType: 'parent attributes',
          stateKind: 'internalization agent parent attributes',
          type: 'stringValue',
          kind: 'protein aa sequence'
        }, {
          key: 'scientist',
          stateType: 'parent attributes',
          stateKind: 'internalization agent parent attributes',
          type: 'stringValue',
          kind: 'scientist'
        }, {
          key: 'notebook',
          stateType: 'parent attributes',
          stateKind: 'internalization agent parent attributes',
          type: 'stringValue',
          kind: 'notebook'
        }, {
          key: 'completion date',
          stateType: 'parent attributes',
          stateKind: 'internalization agent parent attributes',
          type: 'dateValue',
          kind: 'completion date'
        }
      ]
    };

    return InternalizationAgentParent;

  })(Thing);

}).call(this);
