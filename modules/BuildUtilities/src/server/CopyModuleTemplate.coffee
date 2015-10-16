fs = require 'fs'
glob = require 'glob'
ncp = require 'ncp'

TEMPLATE_SOURCE_Dir = "../conf/TemplateModule"
TEMPLATE_REPLACE_STRING = "TemplateModule"
REL_PATH_TO_MODULES = "../public/src/modules"

# The first two arguments simply call this script
process.argv.shift()   #node
process.argv.shift()   #CopyModuleTemplate.js

# Next argument would be module name
moduleName = process.argv.shift()
unless moduleName?
	console.log "You must provide a module name."
	console.log "For additional help, type 'node CopyModuleTemplate.js -h'"
	process.exit -1

# Loop over the rest of the arguments and treat appropriately
while process.argv.length > 0
	custom = process.argv.shift()

	if custom is "-t"
		TEMPLATE_SOURCE_Dir = process.argv.shift()
		#only handles case where there is no argument after -l
		unless TEMPLATE_SOURCE_Dir?
			console.log "Please provide a source directory for the template after the -t flag"
			moduleName = "-h"

	else if custom is "custom"
		unless fs.existsSync("../acas_custom")
			fs.mkdirSync("../acas_custom")
		unless fs.existsSync("../acas_custom/modules")
			fs.mkdirSync("../acas_custom/modules")
		unless fs.existsSync("../acas_custom/modules/ModuleMenus")
			fs.mkdirSync("../acas_custom/modules/ModuleMenus")
		unless fs.existsSync("../acas_custom/modules/ModuleMenus/src")
			fs.mkdirSync("../acas_custom/modules/ModuleMenus/src")
		unless fs.existsSync("../acas_custom/modules/ModuleMenus/src/client")
			fs.mkdirSync("../acas_custom/modules/ModuleMenus/src/client")

		TEMPLATE_SOURCE_Dir = "../../public/src/conf/TemplateModule"
		REL_PATH_TO_MODULES = "../acas_custom/modules"

	else
		console.log custom+" is not a valid argument\n"
		moduleName = "-h"

#Check that TEMPLATE_SOURCE_Dir exists and has spec and src folders
console.log "Template source directory is " +TEMPLATE_SOURCE_Dir+"\n"
try
	files = fs.readdirSync(REL_PATH_TO_MODULES+"/"+TEMPLATE_SOURCE_Dir)
	if !("spec" in files & "src" in files)
		console.log "Warning, the directory "+TEMPLATE_SOURCE_Dir+" does not include the expected folders src and spec."
		console.log "Directory contents: "+files
		console.log "Ensure that this is the desired directory."
		console.log "Note, the rest of the program will still run.\n"
catch error
	console.log "The directory "+TEMPLATE_SOURCE_Dir+" does not exist."
	moduleName = "-h"





if moduleName is "-h"
	console.log "Usage: node CopyModuleTemplate.js [module name]"
	console.log "       To create a module in the acas_custom directory, add 'custom' at the end of the line"
	console.log "       To specify the directory to copy from, use the -t flag"
	console.log "       paths are relative to public/src/modules\n"
	console.log "Examples: node CopyModuleTemplate.js TestModule"
	console.log "          node CopyModuleTemplate.js TestModule custom"
	console.log "          node CopyModuleTemplate.js TestModule -t ../conf/TemplateModule\n"
	console.log "To view your module in the GUI, edit the ModuleMenusConfiguration.coffee file in the modules/ModuleMenus directory."
	console.log "If the module is a custom module, edit the file in acas_custom."

	process.exit -1


process.chdir REL_PATH_TO_MODULES


ncp TEMPLATE_SOURCE_Dir, moduleName, (err) ->
	return console.error(err)  if err
	files =  glob.sync moduleName+"/**"
	for fname in files
		unless fname.indexOf(TEMPLATE_REPLACE_STRING) < 0
			newName = fname.replace TEMPLATE_REPLACE_STRING, moduleName
			fs.renameSync fname, newName
	console.log "Module and example files created."
	if custom is "custom"
		console.log "Your files are in the acas_custom directory. Remember to run 'grunt copy' to copy all of your acas_custom files into the base acas directory."
		ncp "../../public/src/modules/ModuleMenus/src/client/ModuleMenusConfiguration.coffee", "ModuleMenus/src/client/ModuleMenusConfiguration.coffee", moduleName, (err) ->
			return console.error(err)  if err
	console.log "Please replace the contents of the files for your module. The current contents in these files may be used as example code."
	console.log "To view your module in the GUI, edit the ModuleMenusConfiguration.coffee file in the modules/ModuleMenus directory."
	console.log "If the module is in the acas_custom directory, edit the ModuleMenusConfiguration.coffee file in acas_custom."
	return
