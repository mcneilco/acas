(function() {
  exports.setupRoutes = function(app, loginRoutes) {
    return app.get('/excelApps', loginRoutes.ensureAuthenticated, exports.excelAppIndex);
  };

  exports.excelAppIndex = function(req, resp) {
    var config, csUtilities, loginUser, loginUserName;
    csUtilities = require('../public/src/conf/CustomerSpecificServerFunctions.js');
    csUtilities.logUsage("Index requested", "" + req.url, req.body.user);
    global.specRunnerTestmode = global.stubsMode ? true : false;
    config = require('../conf/compiled/conf.js');
    if (config.all.client.require.login) {
      loginUserName = req.user.username;
      loginUser = req.user;
    } else {
      loginUserName = "nouser";
      loginUser = {
        id: 0,
        username: "nouser",
        email: "nouser@nowhere.com",
        firstName: "no",
        lastName: "user"
      };
    }
    return resp.render('ExcelApp', {
      title: 'ExcelApps',
      AppLaunchParams: {
        loginUserName: loginUserName,
        loginUser: loginUser,
        testMode: global.specRunnerTestmode,
        deployMode: global.deployMode
      }
    });
  };

}).call(this);
