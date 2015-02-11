(function() {
  (function(exports) {
    return exports.controllerRedirectConf = {
      PROT: {
        entityName: "protocols",
        stub: true,
        "default": {
          deepLink: "protocol_base"
        },
        "Bio Activity": {
          deepLink: "primary_screen_protocol"
        }
      },
      EXPT: {
        entityName: "experiments",
        stub: false,
        "default": {
          deepLink: "experiment_base"
        },
        "Bio Activity": {
          deepLink: "primary_screen_experiment"
        }
      }
    };
  })((typeof process === "undefined" || !process.versions ? window.controllerRedirectConf = window.controllerRedirectConf || {} : exports));

}).call(this);
