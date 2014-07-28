(function() {
  (function(exports) {
    exports.primaryAnalysisReads = [
      {
        readOrder: 11,
        readName: "luminescence",
        matchReadName: true
      }, {
        readOrder: 12,
        readName: "fluorescence",
        matchReadName: true
      }, {
        readOrder: 13,
        readName: "other read name",
        matchReadName: false
      }
    ];
    exports.primaryScreenAnalysisParameters = {
      positiveControl: {
        batchCode: "CMPD-12345678-01",
        concentration: 10,
        concentrationUnits: "uM"
      },
      negativeControl: {
        batchCode: "CMPD-87654321-01",
        concentration: 1,
        concentrationUnits: "uM"
      },
      agonistControl: {
        batchCode: "CMPD-87654399-01",
        concentration: 250753.77,
        concentrationUnits: "uM"
      },
      vehicleControl: {
        batchCode: "CMPD-00000001-01",
        concentration: null,
        concentrationUnits: null
      },
      instrumentReader: "flipr",
      signalDirectionRule: "increasing signal (highest = 100%)",
      aggregateBy1: "compound batch concentration",
      aggregateBy2: "median",
      transformationRule: "(maximum-minimum)/minimum",
      normalizationRule: "plate order",
      hitEfficacyThreshold: 42,
      hitSDThreshold: 5.0,
      thresholdType: "sd",
      transferVolume: 12,
      dilutionFactor: 21,
      volumeType: "dilution",
      assayVolume: 24,
      autoHitSelection: false,
      primaryAnalysisReadList: exports.primaryAnalysisReads
    };
    exports.instrumentReaderCodes = [
      {
        code: "flipr",
        name: "FLIPR",
        ignored: false
      }
    ];
    exports.signalDirectionCodes = [
      {
        code: "increasing signal (highest = 100%)",
        name: "Increasing Signal (highest = 100%)",
        ignored: false
      }
    ];
    exports.aggregateBy1Codes = [
      {
        code: "compound batch concentration",
        name: "Compound Batch Concentration",
        ignored: false
      }
    ];
    exports.aggregateBy2Codes = [
      {
        code: "median",
        name: "Median",
        ignored: false
      }
    ];
    exports.transformationCodes = [
      {
        code: "(maximum-minimum)/minimum",
        name: "(Max-Min)/Min",
        ignored: false
      }
    ];
    exports.normalizationCodes = [
      {
        code: "plate order",
        name: "Plate Order",
        ignored: false
      }, {
        code: "none",
        name: "None",
        ignored: false
      }
    ];
    return exports.readNameCodes = [
      {
        code: "luminescence",
        name: "Luminescence",
        ignored: false
      }
    ];
  })((typeof process === "undefined" || !process.versions ? window.primaryScreenTestJSON = window.primaryScreenTestJSON || {} : exports));

}).call(this);
