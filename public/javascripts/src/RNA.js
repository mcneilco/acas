(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.RNAParent = (function(_super) {
    __extends(RNAParent, _super);

    function RNAParent() {
      return RNAParent.__super__.constructor.apply(this, arguments);
    }

    RNAParent.prototype.urlRoot = "/api/rnaParents";

    RNAParent.prototype.initialize = function() {
      this.set({
        lsType: "parent",
        lsKind: "rna"
      });
      return RNAParent.__super__.initialize.call(this);
    };

    RNAParent.prototype.lsProperties = {
      defaultLabels: [
        {
          key: 'rna name',
          type: 'name',
          kind: 'rna',
          preferred: true
        }
      ],
      defaultValues: [
        {
          key: 'completion date',
          stateType: 'metadata',
          stateKind: 'rna parent',
          type: 'dateValue',
          kind: 'completion date'
        }, {
          key: 'notebook',
          stateType: 'metadata',
          stateKind: 'rna parent',
          type: 'stringValue',
          kind: 'notebook'
        }, {
          key: 'target transcript',
          stateType: 'metadata',
          stateKind: 'rna parent',
          type: 'codeValue',
          kind: 'target transcript',
          codeType: 'rna',
          codeKind: 'target transcript',
          codeOrigin: 'ACAS DDICT'
        }, {
          key: 'gene position',
          stateType: 'metadata',
          stateKind: 'rna parent',
          type: 'numericValue',
          kind: 'gene position'
        }, {
          key: 'modification',
          stateType: 'metadata',
          stateKind: 'rna parent',
          type: 'codeValue',
          kind: 'modification',
          codeType: 'rna',
          codeKind: 'modification',
          codeOrigin: 'ACAS DDICT'
        }, {
          key: 'unmodified sequence',
          stateType: 'metadata',
          stateKind: 'rna parent',
          type: 'stringValue',
          kind: 'unmodified sequence'
        }, {
          key: 'modified sequence',
          stateType: 'metadata',
          stateKind: 'rna parent',
          type: 'stringValue',
          kind: 'modified sequence'
        }, {
          key: 'charge density',
          stateType: 'metadata',
          stateKind: 'rna parent',
          type: 'numericValue',
          kind: 'charge density'
        }
      ]
    };

    RNAParent.prototype.validate = function(attrs) {
      var bestName, cDate, conjugationType, errors, gp, modification, ms, nameError, notebook, us;
      errors = [];
      bestName = attrs.lsLabels.pickBestName();
      nameError = true;
      if (bestName != null) {
        nameError = true;
        if (bestName.get('labelText') !== "") {
          nameError = false;
        }
      }
      if (nameError) {
        errors.push({
          attribute: 'parentName',
          message: "Name must be set"
        });
      }
      if (_.isNaN(attrs.recordedDate)) {
        errors.push({
          attribute: 'recordedDate',
          message: "Recorded date must be set"
        });
      }
      if (!this.isNew()) {
        if (attrs.recordedBy === "" || attrs.recordedBy === "unassigned") {
          errors.push({
            attribute: 'recordedBy',
            message: "Scientist must be set"
          });
        }
        if (attrs["completion date"] != null) {
          cDate = attrs["completion date"].get('value');
          if (cDate === void 0 || cDate === "") {
            cDate = "fred";
          }
          if (isNaN(cDate)) {
            errors.push({
              attribute: 'completionDate',
              message: "Date must be set"
            });
          }
        }
        if (attrs.notebook != null) {
          notebook = attrs.notebook.get('value');
          if (notebook === "" || notebook === void 0) {
            errors.push({
              attribute: 'notebook',
              message: "Notebook must be set"
            });
          }
        }
      }
      if (attrs["target transcript"] != null) {
        conjugationType = attrs["target transcript"].get('value');
        if (conjugationType === "unassigned" || conjugationType === "" || conjugationType === void 0) {
          errors.push({
            attribute: 'targetTranscript',
            message: "Target transcript must be set"
          });
        }
      }
      if (attrs["gene position"] != null) {
        gp = attrs["gene position"].get('value');
        if (gp === "" || gp === void 0 || isNaN(gp)) {
          errors.push({
            attribute: 'genePosition',
            message: "Gene position must be set"
          });
        }
      }
      if (attrs["modification"] != null) {
        modification = attrs["modification"].get('value');
        if (modification === "unassigned" || modification === "" || modification === void 0) {
          errors.push({
            attribute: 'modification',
            message: "Modification must be set"
          });
        }
      }
      if (attrs["unmodified sequence"] != null) {
        us = attrs["unmodified sequence"].get('value');
        if (us === "" || us === void 0) {
          errors.push({
            attribute: 'unmodifiedSequence',
            message: "Unmodified sequence must be set"
          });
        }
      }
      if (attrs["modified sequence"] != null) {
        ms = attrs["modified sequence"].get('value');
        if (ms === "" || ms === void 0) {
          errors.push({
            attribute: 'modifiedSequence',
            message: "Modified sequence must be set"
          });
        }
      }
      if (errors.length > 0) {
        return errors;
      } else {
        return null;
      }
    };

    return RNAParent;

  })(AbstractBaseComponentParent);

  window.RNABatch = (function(_super) {
    __extends(RNABatch, _super);

    function RNABatch() {
      return RNABatch.__super__.constructor.apply(this, arguments);
    }

    RNABatch.prototype.urlRoot = "/api/rnaBatches";

    RNABatch.prototype.initialize = function() {
      this.set({
        lsType: "batch",
        lsKind: "rna"
      });
      return RNABatch.__super__.initialize.call(this);
    };

    RNABatch.prototype.lsProperties = {
      defaultLabels: [],
      defaultValues: [
        {
          key: 'completion date',
          stateType: 'metadata',
          stateKind: 'rna batch',
          type: 'dateValue',
          kind: 'completion date'
        }, {
          key: 'notebook',
          stateType: 'metadata',
          stateKind: 'rna batch',
          type: 'stringValue',
          kind: 'notebook'
        }, {
          key: 'stability',
          stateType: 'metadata',
          stateKind: 'rna batch',
          type: 'numericValue',
          kind: 'stability'
        }, {
          key: 'single strand purity',
          stateType: 'metadata',
          stateKind: 'rna batch',
          type: 'numericValue',
          kind: 'single strand purity',
          unitType: 'percentage',
          unitKind: '% purity'
        }, {
          key: 'duplex purity',
          stateType: 'metadata',
          stateKind: 'rna batch',
          type: 'numericValue',
          kind: 'duplex purity',
          unitType: 'percentage',
          unitKind: '% purity'
        }, {
          key: 'amount',
          stateType: 'metadata',
          stateKind: 'inventory',
          type: 'numericValue',
          kind: 'amount',
          unitType: 'mass',
          unitKind: 'g'
        }, {
          key: 'location',
          stateType: 'metadata',
          stateKind: 'inventory',
          type: 'stringValue',
          kind: 'location'
        }
      ]
    };

    RNABatch.prototype.validate = function(attrs) {
      var amount, cDate, dp, errors, location, notebook, ssp, stability;
      errors = [];
      if (_.isNaN(attrs.recordedDate)) {
        errors.push({
          attribute: 'recordedDate',
          message: "Recorded date must be set"
        });
      }
      if (attrs.recordedBy === "" || attrs.recordedBy === "unassigned") {
        errors.push({
          attribute: 'recordedBy',
          message: "Scientist must be set"
        });
      }
      if (attrs["completion date"] != null) {
        cDate = attrs["completion date"].get('value');
        if (cDate === void 0 || cDate === "") {
          cDate = "fred";
        }
        if (isNaN(cDate)) {
          errors.push({
            attribute: 'completionDate',
            message: "Date must be set"
          });
        }
      }
      if (attrs.notebook != null) {
        notebook = attrs.notebook.get('value');
        if (notebook === "" || notebook === void 0) {
          errors.push({
            attribute: 'notebook',
            message: "Notebook must be set"
          });
        }
      }
      if (attrs["stability"] != null) {
        stability = attrs["stability"].get('value');
        if (stability === "" || stability === void 0 || isNaN(stability)) {
          errors.push({
            attribute: 'stability',
            message: "Stability must be set"
          });
        }
      }
      if (attrs["single strand purity"] != null) {
        ssp = attrs["single strand purity"].get('value');
        if (ssp === "" || ssp === void 0 || isNaN(ssp)) {
          errors.push({
            attribute: 'singleStrandPurity',
            message: "singleStrandPurity must be set"
          });
        }
      }
      if (attrs["duplex purity"] != null) {
        dp = attrs["duplex purity"].get('value');
        if (dp === "" || dp === void 0 || isNaN(dp)) {
          errors.push({
            attribute: 'duplexPurity',
            message: "duplexPurity must be set"
          });
        }
      }
      if (attrs.amount != null) {
        amount = attrs.amount.get('value');
        if (amount === "" || amount === void 0 || isNaN(amount)) {
          errors.push({
            attribute: 'amount',
            message: "Amount must be set"
          });
        }
      }
      if (attrs.location != null) {
        location = attrs.location.get('value');
        if (location === "" || location === void 0) {
          errors.push({
            attribute: 'location',
            message: "Location must be set"
          });
        }
      }
      if (errors.length > 0) {
        return errors;
      } else {
        return null;
      }
    };

    return RNABatch;

  })(AbstractBaseComponentBatch);

}).call(this);
