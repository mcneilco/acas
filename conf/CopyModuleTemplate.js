(function() {
  var REL_PATH_TO_MODULES, TEMPLATE_REPLACE_STRING, TEMPLATE_SOURCE_Dir, fs, glob, moduleName, ncp;

  fs = require('fs');

  glob = require('glob');

  ncp = require('ncp');

  TEMPLATE_SOURCE_Dir = "../conf/TemplateModule";

  TEMPLATE_REPLACE_STRING = "TemplateModule";

  REL_PATH_TO_MODULES = "../public/src/modules";

  moduleName = process.argv[2];

  if (moduleName == null) {
    console.log("You must provide a module name");
    process.exit(-1);
  }

  process.chdir(REL_PATH_TO_MODULES);

  ncp(TEMPLATE_SOURCE_Dir, moduleName, function(err) {
    var files, fname, newName, _i, _len;
    if (err) {
      return console.error(err);
    }
    files = glob.sync(moduleName + "/**");
    for (_i = 0, _len = files.length; _i < _len; _i++) {
      fname = files[_i];
      if (!(fname.indexOf(TEMPLATE_REPLACE_STRING) < 0)) {
        newName = fname.replace(TEMPLATE_REPLACE_STRING, moduleName);
        fs.renameSync(fname, newName);
      }
    }
  });

}).call(this);
