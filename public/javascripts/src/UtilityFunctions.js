(function() {
  window.UtilityFunctions = (function() {
    function UtilityFunctions() {}

    UtilityFunctions.prototype.getFileServiceURL = function() {
      return "/uploads";
    };

    UtilityFunctions.prototype.testUserHasRole = function(user, roleNames) {
      var i, j, len, len1, match, ref, role, roleName;
      if (user.roles == null) {
        return true;
      }
      match = false;
      for (i = 0, len = roleNames.length; i < len; i++) {
        roleName = roleNames[i];
        ref = user.roles;
        for (j = 0, len1 = ref.length; j < len1; j++) {
          role = ref[j];
          if (role.roleEntry.roleName === roleName) {
            match = true;
          }
        }
      }
      return match;
    };

    UtilityFunctions.prototype.testUserHasRoleTypeKindName = function(user, roleInfo) {
      var i, j, len, len1, match, ref, role, userRole;
      if (user.roles == null) {
        return true;
      }
      match = false;
      for (i = 0, len = roleInfo.length; i < len; i++) {
        role = roleInfo[i];
        ref = user.roles;
        for (j = 0, len1 = ref.length; j < len1; j++) {
          userRole = ref[j];
          console.log("role");
          console.log(role);
          if (userRole.roleEntry.lsType === role.lsType && userRole.roleEntry.lsKind === role.lsKind && (userRole.roleEntry.roleName = role.roleName)) {
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
