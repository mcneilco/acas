(function() {
  var ensureExists;

  ensureExists = function(path, mask, cb) {
    var fs;
    fs = require('fs');
    fs.mkdir(path, mask, function(err) {
      if (err) {
        if (err.code === "EEXIST") {
          cb(null);
        } else {
          cb(err);
        }
      } else {
        console.log("Created new directory: " + path);
        cb(null);
      }
    });
  };

  exports.setupAPIRoutes = function(app, loginRoutes) {};

  exports.setupRoutes = function(app, loginRoutes) {
    var config, dataFilesPath, tempFilesPath;
    config = require('../conf/compiled/conf.js');
    dataFilesPath = process.env.PWD + '/' + config.all.server.datafiles.relative_path + '/';
    tempFilesPath = process.env.PWD + '/' + config.all.server.tempfiles.relative_path + '/';
    ensureExists(dataFilesPath, 0x1e4, function(err) {
      if (err != null) {
        console.log("Can't find or create data files dir: " + dataFilesPath);
        return process.exit(-1);
      } else {
        if (config.all.server.datafiles.without.login) {
          return app.get('/dataFiles/*', function(req, resp) {
            console.log(dataFilesPath);
            return resp.sendfile(dataFilesPath + req.params[0]);
          });
        } else {
          return app.get('/dataFiles/*', loginRoutes.ensureAuthenticated, function(req, resp) {
            console.log(dataFilesPath);
            return resp.sendfile(dataFilesPath + req.params[0]);
          });
        }
      }
    });
    return ensureExists(tempFilesPath, 0x1e4, function(err) {
      if (err != null) {
        console.log("Can't find or create temp files dir: " + dataFilesPath);
        return process.exit(-1);
      } else {
        return app.get('/tempfiles/*', loginRoutes.ensureAuthenticated, function(req, resp) {
          return resp.sendfile(tempFilesPath + req.params[0]);
        });
      }
    });
  };

}).call(this);
