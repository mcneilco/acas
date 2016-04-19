(function() {
  var REL_PATH_TO_MODULES, TEMPLATE_REPLACE_STRING, TEMPLATE_SOURCE_Dir, custom, error, error1, files, fs, glob, moduleName, ncp,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  fs = require('fs');

  glob = require('glob');

  ncp = require('ncp');

  TEMPLATE_SOURCE_Dir = "../conf/TemplateModule";

  TEMPLATE_REPLACE_STRING = "TemplateModule";

  REL_PATH_TO_MODULES = "../public/src/modules";

  process.argv.shift();

  process.argv.shift();

  moduleName = process.argv.shift();

  if (moduleName == null) {
    console.log("You must provide a module name.");
    console.log("For additional help, type 'node CopyModuleTemplate.js -h'");
    process.exit(-1);
  }

  while (process.argv.length > 0) {
    custom = process.argv.shift();
    if (custom === "-t") {
      TEMPLATE_SOURCE_Dir = process.argv.shift();
      if (TEMPLATE_SOURCE_Dir == null) {
        console.log("Please provide a source directory for the template after the -t flag");
        moduleName = "-h";
      }
    } else if (custom === "custom") {
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
      console.log(custom + " is not a valid argument\n");
      moduleName = "-h";
    }
  }

  console.log("Template source directory is " + TEMPLATE_SOURCE_Dir + "\n");

  try {
    files = fs.readdirSync(REL_PATH_TO_MODULES + "/" + TEMPLATE_SOURCE_Dir);
    if (!(indexOf.call(files, "spec") >= 0 & indexOf.call(files, "src") >= 0)) {
      console.log("Warning, the directory " + TEMPLATE_SOURCE_Dir + " does not include the expected folders src and spec.");
      console.log("Directory contents: " + files);
      console.log("Ensure that this is the desired directory.");
      console.log("Note, the rest of the program will still run.\n");
    }
  } catch (error1) {
    error = error1;
    console.log("The directory " + TEMPLATE_SOURCE_Dir + " does not exist.");
    moduleName = "-h";
  }

  if (moduleName === "-h") {
    console.log("Usage: node CopyModuleTemplate.js [module name]");
    console.log("       To create a module in the acas_custom directory, add 'custom' at the end of the line");
    console.log("       To specify the directory to copy from, use the -t flag");
    console.log("       paths are relative to public/src/modules\n");
    console.log("Examples: node CopyModuleTemplate.js TestModule");
    console.log("          node CopyModuleTemplate.js TestModule custom");
    console.log("          node CopyModuleTemplate.js TestModule -t ../conf/TemplateModule\n");
    console.log("To view your module in the GUI, edit the ModuleMenusConfiguration.coffee file in the modules/ModuleMenus directory.");
    console.log("If the module is a custom module, edit the file in acas_custom.");
    process.exit(-1);
  }

  process.chdir(REL_PATH_TO_MODULES);

  ncp(TEMPLATE_SOURCE_Dir, moduleName, function(err) {
    var fname, i, len, newName;
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
