window.ModuleMenusConfiguration =
	[
		isHeader: true
		menuName: "Load Data"
	,
		isHeader: false
		menuName: "Load Experiment"
		mainControllerClassName: "GenericDataParserController"
		autoLaunchName:"generic_data_parser"
		requireUserRoles: ["admin", "loadData"]
	,
		isHeader: false
		menuName: "Create Protocol"
		mainControllerClassName: "ProtocolBaseController"
		autoLaunchName:"protocol_base"
	,
		isHeader: false
		menuName: ""
		mainControllerClassName: "ExperimentBaseController"
		autoLaunchName:"experiment_base"
	,
		isHeader: true
		menuName: "Search and Edit"
	,
		isHeader: false, menuName: "Protocol Browser"
		mainControllerClassName: "ProtocolBrowserController"
	,
		isHeader: false, menuName: "Experiment Browser"
		mainControllerClassName: "ExperimentBrowserController"
	,
		isHeader: false, menuName: "Gene ID Query"
	]

