window.ModuleMenusConfiguration =
	[
		isHeader: true
		menuName: "Load Data"
		requireUserRoles: [window.conf.roles.acas.userRole]
#		collapsible: true
	,
#		isHeader: false
#		menuName: "Chem Struct"
#		mainControllerClassName: "ACASFormChemicalStructureExampleController"
#	,
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
		menuName: "Protocol Editor"
		mainControllerClassName: window.conf.protocol.mainControllerClassName
		autoLaunchName:"protocol_base"
		requireUserRoles: [window.conf.roles.acas.userRole]
	,
		isHeader: false
		menuName: "Experiment Editor"
		mainControllerClassName: window.conf.experiment.mainControllerClassName
		autoLaunchName:"experiment_base"
		requireUserRoles: [window.conf.roles.acas.userRole]
	,
		isHeader: false
		menuName: "Project Editor"
		mainControllerClassName: "ProjectController"
		autoLaunchName:"project"
		requireUserRoles: [window.conf.roles.acas.adminRole]
	,
		isHeader: false, menuName: "Example Thing"
		mainControllerClassName: "ExampleThingController"
		autoLaunchName:"example_thing"
		requireUserRoles: [window.conf.roles.acas.userRole]
	,
		isHeader: true
		menuName: "Search and Edit"
		collapsible: true
		requireUserRoles: [window.conf.roles.acas.userRole]
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
		collapsible: true
		requireUserRoles: [window.conf.roles.acas.adminRole]
	,
		isHeader: false
		menuName: "Author Editor"
		mainControllerClassName: "AuthorEditorController"
		autoLaunchName: "author"
		requireUserRoles: [window.conf.roles.acas.adminRole]
	,
		isHeader: false
		menuName: "Author Browser"
		mainControllerClassName: "AuthorBrowserController"
		requireUserRoles: [window.conf.roles.acas.adminRole]
	,
		isHeader: false
		menuName: "Admin Panel"
		mainControllerClassName: "AdminPanelController"
		autoLaunchName: "admin_panel"
		requireUserRoles: [window.conf.roles.acas.adminRole]
	,
		isHeader: false, menuName: "Logging"
		mainControllerClassName: "LoggingController"
		requireUserRoles: [window.conf.roles.acas.adminRole]
	,
		isHeader: false
		menuName: "System Test"
		mainControllerClassName: "SystemTestController"
		autoLaunchName:"system_test"
		requireUserRoles: [window.conf.roles.acas.adminRole]
	,
		isHeader: false
		menuName: "Label Sequence"
		mainControllerClassName: "ACASLabelSequenceController"
		autoLaunchName: "acasLabelSequence"
		requireUserRoles: [window.conf.roles.acas.adminRole]
	,
		isHeader: true
		menuName: "CmpdReg Admin"
		requireUserRoles: [window.conf.roles.cmpdreg.adminRole]
		collapsible: true
	,
		isHeader: false
		menuName: "CmpdReg Vendors"
		mainControllerClassName: "VendorBrowserController"
		autoLaunchName: "vendor_browser"
		requireUserRoles: [window.conf.roles.cmpdreg.adminRole]
	,
		isHeader: false
		menuName: "CmpdReg Stereo Categories"
		mainControllerClassName: "StereoCategoryBrowserController"
		autoLaunchName: "stereo_category_browser"
		requireUserRoles: [window.conf.roles.cmpdreg.adminRole]
	,
		isHeader: false
		menuName: "CmpdReg Scientists"
		mainControllerClassName: "ScientistBrowserController"
		autoLaunchName: "scientist_browser"
		requireUserRoles: [window.conf.roles.cmpdreg.adminRole]
	]
