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
      menuName: "Load Full PK Experiment",
      mainControllerClassName: "FullPKParserController"
    }, {
      isHeader: false,
      menuName: "Load Micro Solubility Experiment",
      mainControllerClassName: "MicroSolParserController"
    }, {
      isHeader: false,
      menuName: "Load PAMPA Experiment",
      mainControllerClassName: "PampaParserController"
    }, {
      isHeader: false,
      menuName: "Load Met. Stab. Experiment",
      mainControllerClassName: "MetStabParserController"
    }
  ];

}).call(this);
