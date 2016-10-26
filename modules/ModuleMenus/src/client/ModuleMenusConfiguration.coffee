window.ModuleMenusConfiguration =
	[
		isHeader: true
		menuName: "Load Data"
	,
		isHeader: false
		menuName: "Experiment Loader"
		mainControllerClassName: "GenericDataParserController"
		autoLaunchName:"generic_data_parser"
		# requireUserRoles: [window.conf.roles.acas.userRole]
	,
		isHeader: false
		menuName: "Dose Response"
		mainControllerClassName: "DoseResponseFitWorkflowController"
		# requireUserRoles: [window.conf.roles.acas.userRole]
	,
		isHeader: false
		menuName: "Protocol Editor"
		mainControllerClassName: "ProtocolBaseController"
		autoLaunchName:"protocol_base"
	,
		isHeader: false
		menuName: "Experiment Editor"
		mainControllerClassName: "ExperimentBaseController"
		autoLaunchName:"experiment_base"
	,
		isHeader: false
		menuName: "Project Editor"
		mainControllerClassName: "ProjectController"
		autoLaunchName:"project"
	,
		isHeader: false, menuName: "Example Thing"
		mainControllerClassName: "ExampleThingController"
		autoLaunchName:"cationic_block"
	,
		isHeader: true
		menuName: "Inventory"
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
		isHeader: false, menuName: "Project Browser"
		mainControllerClassName: "ProjectBrowserController"
	,
		isHeader: true
		menuName: "Admin"
	,
		isHeader: false
		menuName: "Admin Panel"
		mainControllerClassName: "AdminPanelController"
		autoLaunchName: "admin_panel"
		requireUserRoles: []
	,
		isHeader: false, menuName: "Logging"
		mainControllerClassName: "LoggingController"
		requireUserRoles: []
	]
