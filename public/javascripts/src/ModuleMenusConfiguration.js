(function() {
  window.ModuleMenusConfiguration = [
    {
      isHeader: true,
      menuName: "Load Data"
    }, {
      isHeader: false,
      menuName: "Load Experiment",
      mainControllerClassName: "GenericDataParserController"
    }, {
      isHeader: false,
      menuName: "Analyze FLIPR Data",
      mainControllerClassName: "PrimaryScreenExperimentController",
      autoLaunchName: "flipr_screening_assay"
    }, {
      isHeader: false,
      menuName: "Experiment Browser",
      mainControllerClassName: "ExperimentBrowserController"
    }, {
      isHeader: true,
      menuName: "Inventory"
    }, {
      isHeader: false,
      menuName: "Load Containers From SDF",
      mainControllerClassName: "BulkLoadContainersFromSDFController"
    }, {
      isHeader: false,
      menuName: "Load Sample Transfer Log",
      mainControllerClassName: "BulkLoadSampleTransfersController"
    }
  ];

}).call(this);
