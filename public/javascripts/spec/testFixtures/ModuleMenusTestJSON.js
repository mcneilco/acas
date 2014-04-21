(function() {
  (function(exports) {
    return exports.testMenuItems = [
      {
        isHeader: true,
        menuName: "Test Header"
      }, {
        isHeader: false,
        menuName: "Test Launcher 1",
        mainControllerClassName: "controllerClassName1"
      }, {
        isHeader: false,
        menuName: "Test Launcher 2",
        mainControllerClassName: "controllerClassName2"
      }, {
        isHeader: false,
        menuName: "Test Launcher 3",
        mainControllerClassName: "controllerClassName3"
      }, {
        isHeader: false,
        menuName: "Analyze FLIPR Data",
        mainControllerClassName: "PrimaryScreenExperimentController",
        autoLaunchName: "flipr_screening_assay"
      }, {
        isHeader: false,
        menuName: "Load Experiment",
        mainControllerClassName: "GenericDataParserController",
        requireUserRoles: ["admin", "loadData"]
      }
    ];
  })((typeof process === "undefined" || !process.versions ? window.moduleMenusTestJSON = window.moduleMenusTestJSON || {} : exports));

}).call(this);
