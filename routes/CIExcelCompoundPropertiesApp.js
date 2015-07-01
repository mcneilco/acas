(function() {
  exports.setupRoutes = function(app, loginRoutes) {
    return app.get('/excelApps/compoundInfo', loginRoutes.ensureAuthenticated, exports.compoundInfoIndex);
  };

  exports.compoundInfoIndex = function(req, resp) {
    var config, loginUser, loginUserName;
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
    return resp.render('CIExcelCompoundPropertiesApp', {
      title: 'Compound Info',
      AppLaunchParams: {
        loginUserName: loginUserName,
        loginUser: loginUser,
        testMode: global.specRunnerTestmode,
        deployMode: global.deployMode
      }
    });
  };

}).call(this);
