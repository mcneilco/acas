window.ModuleMenusConfiguration =
	[
		isHeader: true
		menuName: "Load Data"
	,
		isHeader: false
		menuName: "Load Experiment"
		mainControllerClassName: "GenericDataParserController"
		autoLaunchName:"generic_data_parser"
	,
		isHeader: true
		menuName: "Register Components"
	,
		isHeader: false
		menuName: "Cationic Block"
		mainControllerClassName: "CationicBlockController"
		autoLaunchName:"cationic_block"
	,
		isHeader: false
		menuName: "Linker Small Molecule"
		mainControllerClassName: "LinkerSmallMoleculeController"
		autoLaunchName:"linker_small_molecule"
	,
		isHeader: false
		menuName: "Protein"
		mainControllerClassName: "ProteinController"
		autoLaunchName:"protein"
	,
		isHeader: false
		menuName: "Spacer"
		mainControllerClassName: "SpacerController"
		autoLaunchName:"spacer"
	,
#		isHeader: false
#		menuName: "Internalization Agent"
#		mainControllerClassName: "InternalizationAgentController"
#		autoLaunchName:"internalization_agent"
#	,
#		isHeader: false
#		menuName: "Component Picker"
#		mainControllerClassName: "ComponentPickerController"
#		autoLaunchName:"component_picker"
#	,
#		isHeader: true
#		menuName: "Inventory"
#	,
#		isHeader: false
#		menuName: "Load Containers From SDF"
#		mainControllerClassName: "BulkLoadContainersFromSDFController"
#	,
#		isHeader: false
#		menuName: "Load Sample Transfer Log"
#		mainControllerClassName: "BulkLoadSampleTransfersController"
#	,
		isHeader: true
		menuName: "Search and Edit"
	,
		isHeader: false, menuName: "Search Components"
		mainControllerClassName: "ComponentBrowserController"
#	,
#		isHeader: true
#		menuName: "Admin"
#	,
#		isHeader: false, menuName: "Logging"
#		mainControllerClassName: "LoggingController"
	]

