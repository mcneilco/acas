fs = require 'fs'
glob = require 'glob'
ncp = require 'ncp'

TEMPLATE_SOURCE_Dir = "../conf/TemplateModule"
TEMPLATE_REPLACE_STRING = "TemplateModule"
REL_PATH_TO_MODULES = "../public/src/modules"

moduleName = process.argv[2]
unless moduleName?
	console.log "You must provide a module name"
	process.exit -1

process.chdir REL_PATH_TO_MODULES


ncp TEMPLATE_SOURCE_Dir, moduleName, (err) ->
	return console.error(err)  if err
	files =  glob.sync moduleName+"/**"
	for fname in files
		unless fname.indexOf(TEMPLATE_REPLACE_STRING) < 0
			newName = fname.replace TEMPLATE_REPLACE_STRING, moduleName
			fs.renameSync fname, newName
	return
