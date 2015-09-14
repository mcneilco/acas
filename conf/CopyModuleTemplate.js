(function() {
  var REL_PATH_TO_MODULES, TEMPLATE_REPLACE_STRING, TEMPLATE_SOURCE_Dir, custom, fs, glob, moduleName, ncp;

  fs = require('fs');

  glob = require('glob');

  ncp = require('ncp');

  TEMPLATE_SOURCE_Dir = "../conf/TemplateModule";

  TEMPLATE_REPLACE_STRING = "TemplateModule";

  REL_PATH_TO_MODULES = "../public/src/modules";

  moduleName = process.argv[2];

  if (moduleName == null) {
    console.log("You must provide a module name.");
    console.log("For additional help, type 'node CopyModuleTemplate.js -h'");
    process.exit(-1);
  }

  custom = process.argv[3];

  if (custom != null) {
    if (custom === "custom") {
      if (!fs.existsSync("../acas_custom")) {
        fs.mkdirSync("../acas_custom");
      }
      if (!fs.existsSync("../acas_custom/modules")) {
        fs.mkdirSync("../acas_custom/modules");
      }
      if (!fs.existsSync("../acas_custom/modules/ModuleMenus")) {
        fs.mkdirSync("../acas_custom/modules/ModuleMenus");
      }
      if (!fs.existsSync("../acas_custom/modules/ModuleMenus/src")) {
        fs.mkdirSync("../acas_custom/modules/ModuleMenus/src");
      }
      if (!fs.existsSync("../acas_custom/modules/ModuleMenus/src/client")) {
        fs.mkdirSync("../acas_custom/modules/ModuleMenus/src/client");
      }
      TEMPLATE_SOURCE_Dir = "../../public/src/conf/TemplateModule";
      REL_PATH_TO_MODULES = "../acas_custom/modules";
    } else {
      console.log('The argument after the module name is not a valid value.\n');
      moduleName = "-h";
    }
  }

  if (moduleName === "-h") {
    console.log("Usage: node CopyModuleTemplate.js [module name]");
    console.log("       To create a module in the acas_custom directory, add 'custom' at the end of the line\n");
    console.log("Examples: node CopyModuleTemplate.js TestModule");
    console.log("          node CopyModuleTemplate.js TestModule custom\n");
    console.log("To view your module in the GUI, edit the ModuleMenusConfiguration.coffee file in the modules/ModuleMenus directory.");
    console.log("If the module is a custom module, edit the file in acas_custom.");
    process.exit(-1);
  }

  process.chdir(REL_PATH_TO_MODULES);

  ncp(TEMPLATE_SOURCE_Dir, moduleName, function(err) {
    var files, fname, i, len, newName;
    if (err) {
      return console.error(err);
    }
    files = glob.sync(moduleName + "/**");
    for (i = 0, len = files.length; i < len; i++) {
      fname = files[i];
      if (!(fname.indexOf(TEMPLATE_REPLACE_STRING) < 0)) {
        newName = fname.replace(TEMPLATE_REPLACE_STRING, moduleName);
        fs.renameSync(fname, newName);
      }
    }
    console.log("Module and example files created.");
    if (custom === "custom") {
      console.log("Your files are in the acas_custom directory. Remember to run 'grunt copy' to copy all of your acas_custom files into the base acas directory.");
      ncp("../../public/src/modules/ModuleMenus/src/client/ModuleMenusConfiguration.coffee", "ModuleMenus/src/client/ModuleMenusConfiguration.coffee", moduleName, function(err) {
        if (err) {
          return console.error(err);
        }
      });
    }
    console.log("Please replace the contents of the files for your module. The current contents in these files may be used as example code.");
    console.log("To view your module in the GUI, edit the ModuleMenusConfiguration.coffee file in the modules/ModuleMenus directory.");
    console.log("If the module is in the acas_custom directory, edit the ModuleMenusConfiguration.coffee file in acas_custom.");
  });

}).call(this);
