###Grunt execute

This grunt task was added to run the following files for you: PrepareConfigFiles.js, PrepareModuleIncludes.js, and PrepareTestJSON.js.

The command below runs all three files at once:

	grunt execute

Running grunt in the background will automatically compile the three files for you.

Each file may also be run separately by typing:

	grunt execute:prepare_config_files
	grunt execute:prepare_module_includes
	grunt execute:prepare_test_JSON
