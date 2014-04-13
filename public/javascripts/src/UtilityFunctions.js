(function() {
  window.UtilityFunctions = (function() {
    function UtilityFunctions() {}

    UtilityFunctions.prototype.getFileServiceURL = function() {
      if (window.conf.use.ssl) {
        return "https://" + window.conf.host + ":" + window.conf.service.file.port;
      } else {
        return "http://" + window.conf.host + ":" + window.conf.service.file.port;
      }
    };

    return UtilityFunctions;

  })();

}).call(this);
