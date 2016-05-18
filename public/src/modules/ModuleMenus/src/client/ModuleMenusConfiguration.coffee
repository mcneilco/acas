window.ModuleMenusConfiguration =
	[
		isHeader: true
		menuName: "Load Data"
	,
		isHeader: false
		menuName: "Experiment Loader"
		mainControllerClassName: "GenericDataParserController"
		autoLaunchName:"generic_data_parser"
		requireUserRoles: [window.conf.roles.acas.userRole]
	,
		isHeader: false
		menuName: "Dose Response"
		mainControllerClassName: "DoseResponseFitWorkflowController"
		requireUserRoles: [window.conf.roles.acas.userRole]
	,
		isHeader: false
		menuName: "Plate Analysis Protocol Editor"
		mainControllerClassName: "PrimaryScreenProtocolModuleController"
		autoLaunchName:"primary_screen_protocol"
		requireUserRoles: [window.conf.roles.acas.userRole]
	,
		isHeader: false
		menuName: "Plate Analysis Experiment Editor"
		mainControllerClassName: "PrimaryScreenExperimentController"
		autoLaunchName:"primary_screen_experiment"
		requireUserRoles: [window.conf.roles.acas.userRole]
	,
		isHeader: false
		menuName: "Protocol Editor"
		mainControllerClassName: "ProtocolBaseController"
		autoLaunchName:"protocol_base"
		requireUserRoles: [window.conf.roles.acas.userRole]
	,
		isHeader: false
		menuName: "Experiment Editor"
		mainControllerClassName: "ExperimentBaseController"
		autoLaunchName:"experiment_base"
		requireUserRoles: [window.conf.roles.acas.userRole]
	,
		isHeader: false
		menuName: "Project Editor"
		mainControllerClassName: "ProjectController"
		autoLaunchName:"project"
		requireUserRoles: [window.conf.roles.acas.userRole]
	,
		isHeader: false
		menuName: "Data Viewer"
#		mainControllerClassName: "PrimaryScreenExperimentController"
		autoLaunchName:"dataViewer"
		requireUserRoles: [window.conf.roles.acas.userRole]
	,
		isHeader: false, menuName: "Example Thing"
		mainControllerClassName: "ExampleThingController"
		autoLaunchName:"cationic_block"
		requireUserRoles: [window.conf.roles.acas.userRole]
	,
		isHeader: true
		menuName: "Inventory"
	,
		isHeader: false
		menuName: "Load Containers From SDF"
		mainControllerClassName: "BulkLoadContainersFromSDFController"
		requireUserRoles: [window.conf.roles.acas.userRole]
	,
		isHeader: false
		menuName: "Load Sample Transfer Log"
		mainControllerClassName: "BulkLoadSampleTransfersController"
		requireUserRoles: [window.conf.roles.acas.userRole]
	,
		isHeader: true
		menuName: "Search and Edit"
	,
		isHeader: false, menuName: "Protocol Browser"
		mainControllerClassName: "ProtocolBrowserController"
		requireUserRoles: [window.conf.roles.acas.userRole]
	,
		isHeader: false, menuName: "Experiment Browser"
		mainControllerClassName: "ExperimentBrowserController"
		requireUserRoles: [window.conf.roles.acas.userRole]
	,
		isHeader: false, menuName: "Project Browser"
		mainControllerClassName: "ProjectBrowserController"
		requireUserRoles: [window.conf.roles.acas.userRole]
	,
		isHeader: true
		menuName: "Admin"
	,
		isHeader: false
		menuName: "Admin Panel"
		mainControllerClassName: "AdminPanelController"
		autoLaunchName: "admin_panel"
		requireUserRoles: [window.conf.roles.acas.userRole]
	,
		isHeader: false, menuName: "Logging"
		mainControllerClassName: "LoggingController"
		requireUserRoles: [window.conf.roles.acas.userRole]
	]
