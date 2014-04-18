window.ModuleMenusConfiguration =
	[
		isHeader: true
		menuName: "Load Data"
	,
		isHeader: false
		menuName: "Load Experiment"
		mainControllerClassName: "GenericDataParserController"
	,
		#{isHeader: false, menuName: "Annotate Batches with File", mainControllerClassName: "DocForBatchesController"}
		isHeader: false
		menuName: "Analyze FLIPR Data"
		mainControllerClassName: "PrimaryScreenExperimentController"
		autoLaunchName:"flipr_screening_assay"
	,
		#{isHeader: false, menuName: "Annotate Batches with File", mainControllerClassName: "DocForBatchesController"}
		isHeader: false
		menuName: "Analyze KD Data"
		mainControllerClassName: "DNSKDPrimaryScreenExperimentController"
		autoLaunchName:"dnskd_screening_assay"
	,
		isHeader: true
		menuName: "Inventory"
	,
		isHeader: false
		menuName: "Load Containers From SDF"
		mainControllerClassName: "BulkLoadContainersFromSDFController"
	,
		isHeader: false
		menuName: "Load Sample Transfer Log"
		mainControllerClassName: "BulkLoadSampleTransfersController"
	,
		isHeader: true
		menuName: "Search and Edit"
	,
		isHeader: false, menuName: "Experiment Browser"
		mainControllerClassName: "ExperimentBrowserController"
	]

