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

    UtilityFunctions.prototype.showProgressModal = function(node) {
      node.modal({
        backdrop: "static"
      });
      return node.modal("show");
    };

    UtilityFunctions.prototype.hideProgressModal = function(node) {
      return node.modal("hide");
    };

    UtilityFunctions.prototype.getTrimmedInput = function(selector) {
      return $.trim(selector.val());
    };

    UtilityFunctions.prototype.convertYMDDateToMs = function(inStr) {
      var dateParts;
      dateParts = inStr.split('-');
      return new Date(dateParts[0], dateParts[1] - 1, dateParts[2]).getTime();
    };

    UtilityFunctions.prototype.convertMSToYMDDate = function(ms) {
      var date, monthNum;
      date = new Date(ms);
      monthNum = date.getMonth() + 1;
      return date.getFullYear() + '-' + ("0" + monthNum).slice(-2) + '-' + ("0" + date.getDate()).slice(-2);
    };

    return UtilityFunctions;

  })();

}).call(this);
