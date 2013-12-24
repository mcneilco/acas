(function() {
  (function(exports) {
    return exports.primaryScreenAnalysisParameters = {
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
        concentration: 2,
        concentrationUnits: "uM"
      },
      vehicleControl: {
        batchCode: "CMPD-00000001-01",
        concentration: null,
        concentrationUnits: null
      },
      transformationRule: "(maximum-minimum)/minimum",
      normalizationRule: "plate order",
      hitEfficacyThreshold: 42,
      hitSDThreshold: 5.0,
      thresholdType: "sd"
    };
  })((typeof process === "undefined" || !process.versions ? window.primaryScreenTestJSON = window.primaryScreenTestJSON || {} : exports));

}).call(this);
