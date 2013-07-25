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
      menuName: "Annotate Batches with File",
      mainControllerClassName: "DocForBatchesController",
      routes: [
        {
          routePath: "annotateBatches",
          routeCallBackName: "loadNewDoc"
        }, {
          routePath: "annotateBatches:docId",
          routeCallBackName: "loadExistingDoc"
        }
      ]
    }
  ];

}).call(this);
