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
		mainControllerClassName: window.conf.protocol.mainControllerClassName
		autoLaunchName:"protocol_base"
	,
		isHeader: false
		menuName: "Experiment Editor"
		mainControllerClassName: window.conf.experiment.mainControllerClassName
		autoLaunchName:"experiment_base"
	,
		isHeader: false
		menuName: "Project Editor"
		mainControllerClassName: "ProjectController"
		autoLaunchName:"project"
	,
		isHeader: false, menuName: "Example Thing"
		mainControllerClassName: "ExampleThingController"
		autoLaunchName:"example_thing"
	,
		isHeader: true
		menuName: "Search and Edit"
		collapsible: true
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
		collapsible: true
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
	,
		isHeader: false
		menuName: "System Test"
		mainControllerClassName: "SystemTestController"
		autoLaunchName:"system_test"
		requireUserRoles: []
	]
