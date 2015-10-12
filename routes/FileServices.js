(function() {
  var serverUtilityFunctions, setupRoutes;

  serverUtilityFunctions = require('./ServerUtilityFunctions.js');

  setupRoutes = function(app, loginRoutes, requireLogin) {
    var config, dataFilesPath, tempFilesPath, upload;
    config = require('./compiled/conf.js');
    upload = require('../node_modules_customized/jquery-file-upload-middleware');
    dataFilesPath = serverUtilityFunctions.makeAbsolutePath(config.all.server.datafiles.relative_path);
    tempFilesPath = serverUtilityFunctions.makeAbsolutePath(config.all.server.tempfiles.relative_path);
    upload.configure({
      uploadDir: dataFilesPath,
      ssl: config.all.client.use.ssl,
      uploadUrl: "/dataFiles"
    });
    app.use('/uploads', upload.fileHandler());
    upload.on("error", function(e) {
      return console.log("fileUpload: ", e.message);
    });
    upload.on("end", function(fileInfo) {
      return app.emit("file-uploaded", fileInfo);
    });
    serverUtilityFunctions.ensureExists(dataFilesPath, 0x1e4, function(err) {
      if (err != null) {
        console.log("Can't find or create data files dir: " + dataFilesPath);
        return process.exit(-1);
      } else {
        if (config.all.server.datafiles.without.login || !requireLogin) {
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
    return serverUtilityFunctions.ensureExists(tempFilesPath, 0x1e4, function(err) {
      if (err != null) {
        console.log("Can't find or create temp files dir: " + dataFilesPath);
        return process.exit(-1);
      } else {
        if (requireLogin) {
          return app.get('/tempfiles/*', loginRoutes.ensureAuthenticated, function(req, resp) {
            return resp.sendfile(tempFilesPath + req.params[0]);
          });
        } else {
          return app.get('/tempfiles/*', function(req, resp) {
            return resp.sendfile(tempFilesPath + req.params[0]);
          });
        }
      }
    });
  };

  exports.setupAPIRoutes = function(app, loginRoutes) {
    return setupRoutes(app, loginRoutes, false);
  };

  exports.setupRoutes = function(app, loginRoutes) {
    return setupRoutes(app, loginRoutes, true);
  };

}).call(this);
