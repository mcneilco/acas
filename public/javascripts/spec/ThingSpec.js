(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  describe('Thing testing', function() {
    beforeEach(function() {
      window.siRNA = (function(_super) {
        __extends(siRNA, _super);

        function siRNA() {
          return siRNA.__super__.constructor.apply(this, arguments);
        }

        siRNA.prototype.className = "siRNA";

        siRNA.prototype.lsProperties = {
          defaultLabels: [
            {
              key: 'name',
              type: 'name',
              kind: 'name',
              preferred: true
            }, {
              key: 'corpName',
              type: 'name',
              kind: 'corpName',
              preferred: false
            }, {
              key: 'barcode',
              type: 'barcode',
              kind: 'barcode',
              preferred: false
            }
          ],
          defaultValues: [
            {
              key: 'sequenceValue',
              stateType: 'descriptors',
              stateKind: 'unique attributes',
              type: 'stringValue',
              kind: 'sequence',
              value: "test"
            }, {
              key: 'massValue',
              stateType: 'descriptors',
              stateKind: 'other attributes',
              type: 'numberValue',
              kind: 'mass',
              units: 'mg'
            }, {
              key: 'analysisParameters',
              stateType: 'meta',
              stateKind: 'experiment meta',
              type: 'compositeObjectClob',
              kind: 'AnalysisParameters'
            }
          ],
          defaultValueArrays: [
            {
              key: 'temperatureValueArray',
              stateType: 'measurements',
              stateKind: 'stateVsTime',
              type: 'numberValue',
              kind: 'temperature',
              units: 'C'
            }, {
              key: 'timeValueArray',
              stateType: 'measurements',
              stateKind: 'stateVsTime',
              type: 'dateValue',
              kind: 'time'
            }
          ]
        };

        return siRNA;

      })(Thing);
      return this.siRNA = new siRNA();
    });
    describe('Instantiation - defaultLabels', function() {
      it('should create a list of lsLabels based on the defaultLabels defined in Child Object', function() {
        var lsLabels;
        lsLabels = this.siRNA.get("lsLabels");
        expect(lsLabels).toBeDefined();
        return expect(lsLabels.length).toEqual(3);
      });
      it('should create model attributes for each element in defaultLabels', function() {
        return expect(this.siRNA.get("corpName")).toBeDefined();
      });
      it('should reference the lsLabel model objects stored in lsLabels as top level model attributes', function() {
        var corpNameLabel;
        this.siRNA.get("corpName").set("labelText", "newCorpName");
        corpNameLabel = this.siRNA.get("lsLabels").getLabelByTypeAndKind("name", "corpName")[0];
        return expect(corpNameLabel.get("labelText")).toEqual(this.siRNA.get("corpName").get("labelText"));
      });
      it('should remove the top level label references when sync() is called', function() {
        expect(this.siRNA.get("corpName")).toBeDefined();
        this.siRNA.sync();
        return expect(this.siRNA.get("corpName")).toBeUndefined();
      });
      return it('should create top level label references when parse() is called / when the object is re-hyrdrated', function() {
        var newLabelText;
        newLabelText = "this is a new label";
        this.siRNA.get("corpName").set("labelText", newLabelText);
        expect(this.siRNA.get("corpName")).toBeDefined();
        this.siRNA.sync();
        expect(this.siRNA.get("corpName")).toBeUndefined();
        this.siRNA.parse();
        expect(this.siRNA.get("corpName")).toBeDefined();
        expect(this.siRNA.get("corpName").get("labelText")).toEqual(newLabelText);
        return console.log(this.siRNA);
      });
    });
    return describe('Instantiation - defaultStates', function() {
      it('should create a list of lsStates based on the defaultValues defined in Child Object', function() {
        var lsStates;
        lsStates = this.siRNA.get("lsStates");
        expect(lsStates).toBeDefined();
        return expect(lsStates.length).toEqual(3);
      });
      it('should create a list of lsValues in the appropriate state based on the defaultValues', function() {
        var lsStates, lsValues;
        lsStates = this.siRNA.get('lsStates').getStatesByTypeAndKind("descriptors", "unique attributes");
        lsValues = lsStates[0].get('lsValues');
        expect(lsValues).toBeDefined();
        return expect(lsValues.length).toEqual(1);
      });
      it('should create model attributes for each element in defaultValues', function() {
        return expect(this.siRNA.get("sequenceValue")).toBeDefined();
      });
      it('should reference the lsStates model objects stored in lsStates as top level model attributes', function() {
        var sequenceStateValue;
        console.log("sequence value before change");
        console.log(this.siRNA.get("sequenceValue"));
        this.siRNA.get("sequenceValue").set("value", "newSequenceValue");
        console.log("after changing sequence value");
        console.log(this.siRNA.get('lsStates').getStatesByTypeAndKind("descriptors", "unique attributes"));
        console.log(this.siRNA.get("lsStates").getStatesByTypeAndKind("descriptors", "unique attributes"));
        sequenceStateValue = this.siRNA.get('lsStates').getStateValueByTypeAndKind("descriptors", "unique attributes", "stringValue", "sequence");
        console.log("sequenceStateValue");
        console.log(sequenceStateValue);
        expect(sequenceStateValue.get("stringValue")).toEqual(this.siRNA.get("sequenceValue").get("value"));
        console.log(this.siRNA);
        return console.log(this.siRNA.get("sequenceValue").get("stringValue"));
      });
      it('should remove the top level lsStates model object references when sync() is called', function() {
        expect(this.siRNA.get("sequenceValue")).toBeDefined();
        this.siRNA.sync();
        return expect(this.siRNA.get("sequenceValue")).toBeUndefined();
      });
      return it('should create top level lsStates model object references when parse() is called / when the object is re-hyrdrated', function() {
        var newSequenceValue;
        newSequenceValue = "this is a new sequence value";
        this.siRNA.get("sequenceValue").set("value", newSequenceValue);
        expect(this.siRNA.get("sequenceValue")).toBeDefined();
        this.siRNA.sync();
        expect(this.siRNA.get("sequenceValue")).toBeUndefined();
        this.siRNA.parse();
        expect(this.siRNA.get("sequenceValue")).toBeDefined();
        expect(this.siRNA.get("sequenceValue").get("value")).toEqual(newSequenceValue);
        return console.log(this.siRNA);
      });
    });
  });

}).call(this);
