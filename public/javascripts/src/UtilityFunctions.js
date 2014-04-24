(function() {
  window.UtilityFunctions = (function() {
    function UtilityFunctions() {}

    UtilityFunctions.prototype.getFileServiceURL = function() {
      return "/uploads";
    };

    UtilityFunctions.prototype.testUserHasRole = function(user, roleNames) {
      var match, role, roleName, _i, _j, _len, _len1, _ref;
      if (user.roles == null) {
        return true;
      }
      match = false;
      for (_i = 0, _len = roleNames.length; _i < _len; _i++) {
        roleName = roleNames[_i];
        _ref = user.roles;
        for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
          role = _ref[_j];
          if (role.roleEntry.roleName === roleName) {
            match = true;
          }
        }
      }
      return match;
    };

    return UtilityFunctions;

  })();

}).call(this);
